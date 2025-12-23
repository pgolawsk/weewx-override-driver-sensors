# Changelog

All notable changes to this project will be documented in this file.

- Designed to replace unreliable hardware sensors with MQTT-based sensors
- Intended to be used as a `process_service` before `StdConvert` and `StdCalibrate`

This project follows:

- [Semantic Versioning](https://semver.org/)
- Changelog format inspired by [Keep a Changelog](https://keepachangelog.com/)

---

## [0.1.2] - 2025-12-23

DEV pipeline enhancements.

- Pylint workflow while making a push

---

## [0.1.1] - 2025-12-23

Publish DEV pipeline changes.

- Created [CHANGELOG.md](CHANGELOG.md)
- Added `generate-changelog.sh` to update CHANGELOG.md with commits as draft
- Added `prepare_release.sh` to make release zip including RELEASE_NOTES.md
- Added `publish_release.sh` to publish release on GitHub

---

## [0.1.0] - 2025-12-21

- Initial WeeWX extension for overriding driver sensor values
- Configurable override rules via `[OverrideDriverSensors]` section in `weewx.conf`
- Support for multiple source sensors with priority order
- Overrides applied to both LOOP packets and ARCHIVE records
- Validation to ensure only numeric values are applied
- Optional remapping to extra sensors (e.g. `extraTemp4`, `extraHumid4`)
- Logging of loaded rules and applied overrides
- Safe handling of missing or invalid values
