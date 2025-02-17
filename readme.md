# PSMaaS360

PowerShell API Wrapper for MaaS360

<img src='https://raw.githubusercontent.com/PowerShell/PowerShell/refs/heads/master/assets/Powershell_256.png'>

---

This is a primitive PowerShell module for querying the [IBM MaaS360 Web Services API](https://www.ibm.com/docs/en/maas360?topic=services-maas360-api-reference-web), written to quickly pull relevant information from our MaaS360 instance to be consumed by other tools or APIs.

> **This is not fully featured, but is expected to work at a basic level.**

## Instructions

---

### One Time Setup

* Download the repository
  
* Unzip the archive to its respective module path:
  
   _Windows PowerShell_: `$env:USERPROFILE\Documents\WindowsPowerShell\Modules\`

    _PowerShell 7_: `$env:userprofile\Documents\PowerShell\Modules\`

* Set execution policy (in your preferred scope) to 'Remote Signed'

    * If necessary the `Unblock-File` cmdlet may need to be ran do to absence of digital signature

* Import the module.
  
    `Import-Module -Name 'PSMaaS360'` **-or** `Import-Module \\Path\To\PSMaaS360`

#### Getting Commands

##### Get commands from the module

    Get-Command -Module PSMaaS360

#### Getting Help

##### Get help with an external window

   ` Get-Help -Name Get-PSMaaS360User -ShowWindow` <- My Preferred way

##### Get help via the about topic

   ` Get-Help -Name about_PSMaaS360`
