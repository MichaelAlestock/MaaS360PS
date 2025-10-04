---
external help file: MaaS360PS-help.xml
Module Name: MaaS360PS
online version:
schema: 2.0.0
---

# Connect-MaaS360PS

## SYNOPSIS

Retrieve an API key from the MaaS360 web services API.

## SYNTAX

### New API token (Default)
```
Connect-MaaS360PS -BillingID <String> -Method <String> -PlatformID <String> -AppID <String>
 -AppVersion <String> -AppAccessKey <String> -Credentials <PSCredential> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

### Retrieve info
```
Connect-MaaS360PS [-Validate] [-Result] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The `Connect-MaaS360PS` function retrieves an API key from the MaaS360 web services API.

The first time the function is ran, you must utilize the `[POST]` method as well as all applicable parameters to authenticate against MaaS360's endpoint. If you follow-up your initial run with another but utilizing the `[VALIDATE]` switch parameter, you can retrieve information regarding your session.

## EXAMPLES

### EXAMPLE 1
```
Connect-MaaS360PS -PlatformID '0' -BillingID '01234567' -AppID '01234567_beans' -AppVersion '1.0' -AppAccessKey 'bDrt224GZ' -Credentials 'john_bono@u2.music' -Method 'Post'

Initial command that should be run when first connecting to your MaaS360 instance. If an API key is successfully retrieved it will run Test-MaaS360PSConnection to be sure the API key is valid. If the default 'MaaS token=""' is returned, then the command will fail asking the user to run the command again to generate a new API key.
```

### EXAMPLE 2
```
Connect-MaaS360PS -Validate

Retrieving assumed connection status. If the command is ran with the [VALIDATE] switch before retrieving an API key, the command will fail asking the user to run the command with the [POST] method to retrieve one.
```

## PARAMETERS

### -AppAccessKey
Randomly generated identifier usually containing your billing number.

```yaml
Type: String
Parameter Sets: New API token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppID
Randomly generated identifier granted to user.

```yaml
Type: String
Parameter Sets: New API token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppVersion
Version of the application in your MaaS360 instance.

```yaml
Type: String
Parameter Sets: New API token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BillingID
Billing number for your MaaS360 account.

```yaml
Type: String
Parameter Sets: New API token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credentials
Enter same credentials utilized to log into MaaS360 web portal.

```yaml
Type: PSCredential
Parameter Sets: New API token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
HTTP method used to send a request.

```yaml
Type: String
Parameter Sets: New API token
Aliases:
Accepted values: Post

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlatformID
Identifier for the API platform.

```yaml
Type: String
Parameter Sets: New API token
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Result
Return more details information regarding your connection.

```yaml
Type: SwitchParameter
Parameter Sets: Retrieve info
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Validate
Return an assumed success message.

```yaml
Type: SwitchParameter
Parameter Sets: Retrieve info
Aliases:

Required: False
Position: Named
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
