# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-02-20

### Added

- `Write-Debug` to several functions in key areas to accurately see a wide range of values and arisen issues.
- `Write-Verbose`
- `Get-BetterError` to have a hand in handling errors and presenting the user with usual information to troubleshoot
  issues they may be having
- Several help additions: Markdown help files, markdown about topic, and external xml help.
- Several keys to `$MaaS360Session`: `tempHeaders` to handle header building, `authEndpoint` for `Connect-MaaS360PS` to use, and `baseUrl` to eliminate the need to always use it in every function.
- `Test-MaaS360PSConnection` functionality to `Connect-MaaS360PS` so it'll validate a successful connection instead of needing to run `Test-MaaS360PSConnection` seperately. See the README for a visual of output.

### Changed

- `Test-MaaS360PSConnection` to utilize `Invoke-MaaS360Method` instead of `Invoke-RestMethod` so we could have a better
  idea if tests are actually working.
- `Get-MaaS360User` functionality so it not only uses `Invoke-MaaS360Method` but it (like most functions) uses 
  `Get-BetterError` to assist in easier error resolution.
- `Connect-MaaS360PS` error-handling to hopefully cover most instances that would cause issues and even some of the 
  edge cases. Also, added (or changed?) the `-Result` switch which brings info that was hidden under `Write-Debug`
  to the output stream so it's easier to find instead of needing to live on the debug stream.
- `Invoke-MaaS360Method` functionality by changing up how headers were handled and putting more walls in place to cover
  errors.
- `MaaS360Session` in `MaaS360PS.psd1` so it'll contain all necessary variables use throughout the session.

### Removed

- Several obsolete functions such as `New-MaaS360EnvironmentEntry` since the current design doesn't have need for them.
- `Endpoint` and `Url` as a parameter for functions and placed default values either in `MaaS360Session`, within functions, or as a `[ValidateSet()]` :arrow_left: might remove this though.

### Fixed

- An issue that would cause the `MaaS360Session` variable to not load into the session.
- MaaS360 token not being properly stored causing an inaccurate API key.
- `Connect-MaaS360PS` failing the first time it's ran even though info is 100% correct, but then running perfectly fine
  the next time it's ran.

## [0.1.1] - 2025-02-17

### Changed

- `Connect-MaaS360PS.ps1` functionality to make it a more functional function.
- `Test-MaaS360PSConnection.ps1` functionality to actually test connection against a specific endpoint.
- `Test-MaaS360PSConnection.ps1` is now a public member to allow the testing of endpoints without needing to run `Connect-MaaS360PS` and
  wait for it to hit the bottom of the function.

## [0.1.0] - 2025-02-17

### Added

- Initial commit to the repository