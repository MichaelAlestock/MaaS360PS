[![Build](https://github.com/MichaelAlestock/MaaS360PS/actions/workflows/build.yml/badge.svg)](https://github.com/MichaelAlestock/MaaS360PS/actions/workflows/build.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

A PowerShell API wrapper for the [IBM MaaS360 Web Services API](https://www.ibm.com/docs/en/maas360?topic=services-maas360-api-reference-web). 


> :warning: **_WARNING_**: **This is a work-in-progress and a complete rewrite of my original idea. Most functions will not work for 
> a few updates since they followed old design ideas. Please take this into account before cloning.  If you have any issues please utilize the Github Issues or submit a pull request. You can also feel free to contact me on PowerShell Gallery to report issues and I will manually open an issue for you.**

## Installation

```powershell
Install-Module -Name 'MaaS360PS'
```

## Usage

> **_NOTE_** : All values for parameters are found in the MaaS360 portal under Setup > Documentation.

```powershell
# Retrieving an API key from MaaS360 will also automatically test your connection by calling the users endpoint.
Connect-MaaS360PS -PlatformID '0' -BillingID '0123456789' -AppID '01234567_apple' -AppVersion '1.0' `
-AppAccessKey 'cIENUGZ' -Credentials 'your_email_address' -Method 'Post'

# Returns 'assumed successful' but the -Result switch can show more detail.
Connect-MaaS360PS -Validate

# View details regarding your session such as [API KEY] and complete [URI].
Connect-MaaS360PS -Validate -Result

# OPTIONAL: Test your connection to MaaS360 with the retrieved API key.
Test-MaaS360PSConnection -BillingID '0123456789' -Method 'Get'

# EXAMPLE: Connect-MaaS360PS with [-DEBUG] and [-VERBOSE] for full visual of the command output.
# [API KEY] and [BILLING ID] are not real

---

VERBOSE: Requested HTTP/1.1 POST with 443-byte payload
VERBOSE: Received HTTP/1.1 91-byte response of content type application/json
VERBOSE: Content encoding: utf-8
DEBUG: RAW API KEY: 7069c49e-8775-4032-ab59-940c39c07723-IOd45z3
DEBUG: URI: https://apis.m3.maas360.com/auth-apis/auth/1.0/authenticate/01234567
DEBUG: SECURE API KEY: System.Security.SecureString
Successfully obtained API KEY.
DEBUG: URI: https://apis.m3.maas360.com/user-apis/user/1.0/search/01234567
DEBUG: TOKENIZED API KEY: MaaS token="7069c49e-8775-4032-ab59-940c39c07723-IOd45z3"
VERBOSE: Requested HTTP/1.1 GET with 0-byte payload
VERBOSE: Received HTTP/1.1 response of content type application/json of unknown size
VERBOSE: Content encoding: utf-8
DEBUG: Debug response: @{users=}
DEBUG: Connection to [https://apis.m3.maas360.com/user-apis/user/1.0/search/01234567] successful.
Connection to your MaaS360 instance is fully confirmed. Feel free to use all commands.

---
```

## Help

```powershell

# Utilize PowerShell's discoverability to learn more about functions and their usages.

Get-Help about_MaaS360PS

Get-Command -Module 'MaaS360PS'

Get-Help Get-MaaS360User -ShowWindow

```

