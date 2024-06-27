#![cfg_attr(all(test, feature = "bench"), feature(test))]

use chrono::Local;
use clap::Parser;
use log::{info, warn};
use std::error::Error as StdError;
use std::{
    io::Write,
    sync::{
        atomic::{AtomicBool, Ordering},
        Arc,
    },
    time::Duration,
};

// Add sysinfo crate for system information
use sysinfo::System;

use crate::{
    cli::Opt, client::SpectredHandler, miner::MinerManager, proto::NotifyNewBlockTemplateRequestMessage,
    target::Uint256,
};

mod cli;
mod client;
mod miner;
mod pow;
mod spectred_messages;
mod swap_rust;
mod target;

pub mod proto {
    #![allow(clippy::derive_partial_eq_without_eq)]
    tonic::include_proto!("protowire");
}

pub type Error = Box<dyn StdError + Send + Sync + 'static>;

type Hash = Uint256;

#[derive(Debug, Clone)]
pub struct ShutdownHandler(Arc<AtomicBool>);

pub struct ShutdownOnDrop(ShutdownHandler);

impl ShutdownHandler {
    #[inline(always)]
    pub fn is_shutdown(&self) -> bool {
        self.0.load(Ordering::Acquire)
    }

    #[inline(always)]
    pub fn arm(&self) -> ShutdownOnDrop {
        ShutdownOnDrop(self.clone())
    }
}

impl Drop for ShutdownOnDrop {
    fn drop(&mut self) {
        self.0 .0.store(true, Ordering::Release);
    }
}

#[tokio::main]
async fn main() -> Result<(), Error> {
    let mut opt: Opt = Opt::parse();
    opt.process()?;

    // Create a System object to get system information
    let mut sys = System::new_all();
    sys.refresh_all();

    // Display system information
    println!("=> System Information:");
    println!("System name:             {}", System::name().unwrap_or("Unknown".to_string()));
    println!("System kernel version:   {}", System::kernel_version().unwrap_or("Unknown".to_string()));
    println!("System OS version:       {}", System::os_version().unwrap_or("Unknown".to_string()));
    println!("System host name:        {}", System::host_name().unwrap_or("Unknown".to_string()));

    // Display CPU brand and frequency information only if there is a change
    let mut last_cpu_brand = String::new();
    let mut last_cpu_frequency = 0;
    for cpu in sys.cpus() {
        if cpu.brand() != last_cpu_brand {
            println!("CPU brand:               {}", cpu.brand());
            last_cpu_brand = cpu.brand().to_string();
        }
        if cpu.frequency() != last_cpu_frequency {
            println!("CPU Frequency:           {} MHz", cpu.frequency());
            last_cpu_frequency = cpu.frequency();
        }
    }

    // Display number of CPUs
    println!("Number of CPUs:          {}", sys.cpus().len());
    let total_memory_gb = sys.total_memory() as f64 / 1_073_741_824.0;
    println!("Total RAM:               {:.2} GB", total_memory_gb);

    let mut builder = env_logger::builder();
    builder.filter_level(opt.log_level()).parse_default_env();
    if opt.altlogs {
        builder.format(|buf, record| {
            let timestamp = Local::now().format("%Y-%m-%d %H:%M:%S%.3f%:z");
            writeln!(buf, "{} [{:>5}] {}", timestamp, record.level(), record.args())
        });
    }
    builder.init();

    let throttle = opt.throttle.map(Duration::from_millis);
    let shutdown = ShutdownHandler(Arc::new(AtomicBool::new(false)));
    let _shutdown_when_dropped = shutdown.arm();

    while !shutdown.is_shutdown() {
        match SpectredHandler::connect(
            opt.spectred_address.clone(),
            opt.mining_address.clone(),
            opt.mine_when_not_synced,
        )
        .await
        {
            Ok(mut client) => {
                let mut miner_manager =
                    MinerManager::new(client.send_channel.clone(), opt.num_threads, throttle, shutdown.clone());
                if let Some(devfund_address) = &opt.devfund_address {
                    client.add_devfund(devfund_address.clone(), opt.devfund_percent);
                    info!(
                        "devfund enabled, mining {}.{}% of the time to devfund address: {} ",
                        opt.devfund_percent / 100,
                        opt.devfund_percent % 100,
                        devfund_address
                    );
                }
                if let Err(e) = client.client_send(NotifyNewBlockTemplateRequestMessage {}).await {
                    warn!("Error sending block template request: {}", e);
                }
                if let Err(e) = client.client_get_block_template().await {
                    warn!("Error getting block template: {}", e);
                }
                if let Err(e) = client.listen(&mut miner_manager, shutdown.clone()).await {
                    warn!("Disconnected from spectred: {}. Retrying", e);
                }
            }
            Err(e) => {
                warn!("Failed to connect to spectred: {}. Retrying in 10 seconds...", e);
            }
        }
        tokio::time::sleep(Duration::from_secs(10)).await;
    }
    Ok(())
}
