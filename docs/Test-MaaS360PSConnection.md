---
external help file: MaaS360PS-help.xml
Module Name: MaaS360PS
online version:
schema: 2.0.0
---

# Test-MaaS360PSConnection

## SYNOPSIS
Test connection to a MaaS360 instance.

## SYNTAX

```
Test-MaaS360PSConnection [[-BillingID] <String>] [[-Method] <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The `Test-MaaS360PSConnection` function is used to test your connection to a MaaS360 instance utilizing the API key obtained from `Connect-MaaS360PS`. No information is actually formatted or worked on since the main goal is to return `true` if the connection was successful or `false` if it was unsuccessful. Although this function can be used separately, it's used inside of `Connect-MaaS360PS` to validate connection status upon completion.

## EXAMPLES

### EXAMPLE 1
```
Test-MaaS360PSConnection -BillingID '01234567' -Method 'Get' -Verbose -Debug

DEBUG: URI: https://apis.m3.maas360.com/user-apis/user/1.0/search/01234567
DEBUG: TOKENIZED API KEY: MaaS token="4b517b17-d245-443b-9bbd-698773d19f9a-lbfa8j"
VERBOSE: Requested HTTP/1.1 GET with 0-byte payload
VERBOSE: Received HTTP/1.1 response of content type application/json of unknown size
VERBOSE: Content encoding: utf-8
DEBUG: Debug response: @{users=}
DEBUG: Connection to [https://apis.m3.maas360.com/user-apis/user/1.0/search/01234567] successful.

True
```

## PARAMETERS

### -BillingID
The billing number of your MaaS360 account.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
HTTP method used to send a request.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

All parameter values can be found in the MaaS360 MDM portal under Setup > Manage Access Key and Setup > Documentation. You must FIRST create an app within the MaaS360 MDM portal before you can obtain most of the required information. You must be an administrator to do so.

## RELATED LINKS
