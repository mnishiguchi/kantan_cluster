# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.3..HEAD
[0.2.3]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.2..v0.2.3
[0.2.2]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.1..v0.2.2
[0.2.1]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.0..v0.2.1
[0.2.0]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.1.1..v0.2.0
[0.1.1]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.1.0..v0.1.1
[0.1.0]: https://github.com/mnishiguchi/kantan_cluster/releases/tag/v0.1.0
