# Spectre Miner

[![Build status](https://github.com/spectre-project/spectre-miner/actions/workflows/ci.yaml/badge.svg)](https://github.com/spectre-project/spectre-miner/actions/workflows/ci.yaml)
[![GitHub release](https://img.shields.io/github/v/release/spectre-project/spectre-miner.svg)](https://github.com/spectre-project/spectre-miner/releases)
[![GitHub license](https://img.shields.io/github/license/spectre-project/spectre-miner.svg)](https://github.com/spectre-project/spectre-miner/blob/main/LICENSE-APACHE)
[![GitHub downloads](https://img.shields.io/github/downloads/spectre-project/spectre-miner/total.svg)](https://github.com/spectre-project/spectre-miner/releases)

A Rust binary for mining Spectre with the [SpectreX](https://github.com/spectre-project/rusty-spectrex)
algorithm.

## Installation

### Install from Binaries

Pre-compiled binaries for Linux `x86_64`, Windows `x64` and macOS `x64`
and `aarch64` can be downloaded from the [GitHub release](https://github.com/spectre-project/spectre-miner/releases)
page.

### Build from Source

To compile from source you need to have a working Rust and Cargo
installation, run the following commands to build `spectre-miner`:

```
git clone https://github.com/spectre-project/spectre-miner
cd spectre-miner
cargo build --release
```

## Usage

To start mining you need to run a Spectre full node. It is highly
recommended to run the [Spectre on Rust](https://github.com/spectre-project/rusty-spectre)
version. As a fallback, deprecated and legacy option, the
[Spectre Golang Node](https://github.com/spectre-project/spectred)
is supported as well. You need to have an address to send the mining
rewards to. Running `spectre-miner -h` will show all available command
line options:

```
A Spectre high performance CPU miner

Usage: spectre-miner [OPTIONS] --mining-address <MINING_ADDRESS>

Options:
  -a, --mining-address <MINING_ADDRESS>
          The Spectre address for the miner reward
  -s, --spectred-address <SPECTRED_ADDRESS>
          The IP of the spectred instance [default: 127.0.0.1]
  -p, --port <PORT>
          Spectred port [default: Mainnet = 18110, Testnet = 18210]
  -d, --debug
          Enable debug logging level
      --testnet
          Use testnet instead of mainnet [default: false]
  -t, --threads <NUM_THREADS>
          Amount of miner threads to launch [default: number of logical cpus]
      --devfund <DEVFUND_ADDRESS>
          Mine a percentage of the blocks to the Spectre devfund [default: Off]
      --devfund-percent <DEVFUND_PERCENT>
          The percentage of blocks to send to the devfund [default: 1]
      --mine-when-not-synced
          Mine even when spectred says it is not synced, only useful when passing `--allow-submit-block-when-not-synced` to spectred  [default: false]
      --throttle <THROTTLE>
          Throttle (milliseconds) between each pow hash generation (used for development testing)
      --altlogs
          Output logs in alternative format (same as spectred)
  -h, --help
          Print help
  -V, --version
          Print version
```

To start mining you just need to run the following:

```
./spectre-miner --mining-address spectre:XXXXX
```

This will run the miner on all the available CPU cores.

## Hive OS and mmpOS

You can always download the most recent HiveOS flight sheet and mmpOS miner profile from our website.

- [HiveOS Flight Sheet](https://spectre-network.org/downloads/hive-os/)
- [mmpOS Miner Profile](https://spectre-network.org/downloads/mmp-os/)

## Development Fund

**NOTE: This feature is off by default**

The devfund is a fund managed by the Spectre community in order to
fund Spectre development.

A miner that wants to mine a percentage into the dev-fund can pass the
following flags:

```
./spectre-miner --mining-address=<spectre:XXXXX> --devfund=spectre:qrxf48dgrdkjxllxczek3uweuldtan9nanzjsavk0ak9ynwn0zsayjjh7upez
```

Without specifying `--devfund-percent` it will default to 1%. If you
want to change the percentage, you can pass the option
`--devfund-percent=XX.YY` to mine only XX.YY% of the blocks into the
devfund.

## License

Spectre miner is dual-licensed under the [MIT](https://github.com/spectre-project/spectre-miner/blob/main/LICENSE-MIT)
and [Apache 2.0](https://github.com/spectre-project/spectre-miner/blob/main/LICENSE-APACHE)
license.
