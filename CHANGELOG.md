# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2021-10-27

- Add top-level API
  - `KantanCluster.start/1`
  - `KantanCluster.stop/0`
  - `KantanCluster.connect/1`
  - `KantanCluster.disconnect/1`
- Use a local `Registy` instead of `:global`
- Do not automatically start a node on boot

## [0.1.1] - 2021-10-26

Improvements

- Use [singleton](https://github.com/arjan/singleton) package for supervised global processes

## [0.1.0] - 2021-10-25
- Initial release

[Unreleased]: https://github.com/mnishiguchi/kantan_cluster/compare/v0.2.0..HEAD
[0.2.0]: https://github.com/mnishiguchi/kantan_cluster/releases/tag/v0.2.0
[0.1.1]: https://github.com/mnishiguchi/kantan_cluster/releases/tag/v0.1.1
[0.1.0]: https://github.com/mnishiguchi/kantan_cluster/releases/tag/v0.1.0
