[![Build](https://github.com/MichaelAlestock/MaaS360PS/actions/workflows/build.yml/badge.svg)](https://github.com/MichaelAlestock/MaaS360PS/actions/workflows/build.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

A PowerShell API wrapper for the [IBM MaaS360 Web Services API](https://www.ibm.com/docs/en/maas360?topic=services-maas360-api-reference-web). 

> :warning: **_WARNING_**: **This is a work-in-progress and a complete rewrite of my original idea. Most functions are will not work for 
> a few updates since they followed old design ideas. Please take this into account before cloning.  If you have any issues please utilize the Github Issues or submit a pull request.**

---

> This will soon be published to PSGallery, I apologize for the inconvenience.

## Installation

```powershell

# Step 1. Clone the repository to your respective PowerShell module path.

# Step 2. Import the module into your session.

Import-Module -Name //path/to/module/

# Step 3. Create a session to generate an API key

# NOTE: All parameters values are found in the MaaS360 portal under Setup > Documentation.

Connect-MaaS360PS -platformID '0' -BillingID '0123456789' -AppID '01234567_apple' -AppVersion '1.0' `
-AppAccessKey 'cyMQIENUGZ' -Credentials 'your_email_address' -Url 'https://apis.m3.maas360.com/auth-apis/auth/1.0/' `
-Endpoint 'authenticate' -Method 'Post'

```

## Usage

```powershell

# Utilize PowerShell's discoverability to learn more about functions and their usages.

Get-Help about_MaaS360PS

Get-Command -Module 'MaaS360PS'

Get-Help Get-MaaS360User -ShowWindow

```

