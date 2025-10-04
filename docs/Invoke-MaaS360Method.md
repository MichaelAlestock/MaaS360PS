---
external help file: MaaS360PS-help.xml
Module Name: MaaS360PS
online version:
schema: 2.0.0
---

# Invoke-MaaS360Method

## SYNOPSIS
Alternative to `Invoke-RestMethod` to send an HTTP request.

## SYNTAX

```
Invoke-MaaS360Method [[-Body] <Hashtable>] [[-Method] <String>] [[-Uri] <String>] [[-Headers] <Hashtable>]
 [[-ContentType] <String>] [[-Authentication] <String>] [[-Token] <SecureString>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
The `Invoke-MaaS360Method` function is used internally by other functions to handle the HTTP request instead of utilizing `Invoke-RestMethod`.

## PARAMETERS

### -Authentication
Authentication method used.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
Data being sent via POST or PATCH.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ContentType
Used for POST requests where form data is usually sent instead of JSON.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Headers
HTTP headers used in the request.

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

### -Token
API token being sent in the request.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Uri
Full URL that the request is being sent to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
