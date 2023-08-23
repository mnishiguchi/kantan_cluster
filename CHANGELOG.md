# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2023-08-22

- Install libcluster and simplify code (https://github.com/mnishiguchi/kantan_cluster/pull/3)

### Breaking changes
- removed: `:connect_to` option
- renamed: `start` function to `start_node`
- removed: `stop`, `connect`, `disconnect` function
- added: `:topologies` option

## [0.4.0] - 2022-12-04

- Change `node` option to explicit `name` and `sname` options
- Refactor internal logic using `Node.ping/0` and `Node.alive?/0`
- Update dependencies

## [0.3.1] - 2021-10-30

- Add `KantanCluster.unsubscribe/2`

## [0.3.0] - 2021-10-30

- Add [phoenix_pubsub](https://hexdocs.pm/phoenix_pubsub/Phoenix.PubSub.html)

## [0.2.4] - 2021-10-29

- Do not accept atom for implicit node name
- Change the return value of `KantanCluster.connect/1` to `{:ok, [pid]}`

## [0.2.3] - 2021-10-29

- Detect hostname when node option is not explicit

## [0.2.2] - 2021-10-28

- Improve KantanCluster.stop/0
- Write minimal unit tests
- Enable unit tests in CI

## [0.2.1] - 2021-10-28

- Detect hostname for the default node name
- Remove unused [singleton](https://github.com/arjan/singleton) package from dependencies
- Log when node is already started

## [0.2.0] - 2021-10-27

- Add top-level API
  - `KantanCluster.start/1`
  - `KantanCluster.stop/0`
  - `KantanCluster.connect/1`
  - `KantanCluster.disconnect/1`
- Use a local `Registy` instead of `:global`
- Do not automatically start a node on boot

## [0.1.1] - 2021-10-26

- Use [singleton](https://github.com/arjan/singleton) package for supervised global processes

## [0.1.0] - 2021-10-25
- Initial release

[Unreleased]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.5.0..HEAD
[0.5.0]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.4.0..v0.5.0
[0.4.0]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.3.1..v0.4.0
[0.3.1]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.3.0..v0.3.1
[0.3.0]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.4..v0.3.0
[0.2.4]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.3..v0.2.4
[0.2.3]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.2..v0.2.3
[0.2.2]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.1..v0.2.2
[0.2.1]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.0..v0.2.1
[0.2.0]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.1.1..v0.2.0
[0.1.1]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.1.0..v0.1.1
[0.1.0]: https://github.com/mnishiguchi/kantan_cluster/releases/tag/v0.1.0
