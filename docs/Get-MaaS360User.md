---
external help file: MaaS360PS-help.xml
Module Name: MaaS360PS
online version:
schema: 2.0.0
---

# Get-MaaS360User

## SYNOPSIS
Get user(s) from a MaaS360 instance.

## SYNTAX

```
Get-MaaS360User [[-IncludeAllUsers] <Int32>] [[-PageNumber] <Int32>] [[-PageSize] <Int32>] [[-Match] <Int32>]
 [[-EmailAddress] <String>] [[-FullName] <String>] [[-Username] <String>] [<CommonParameters>]
```

## DESCRIPTION
The `Get-MaaS360User` function is used to obtain a single, few, or many users from a MaaS360 instance.

Without any parameters, this function will return ALL users up to the maximum of 250. Luckily, this number can be
limited to improve performance. 

## EXAMPLES

### Example 1
```powershell
Get-MaaS360User -EmailAddress 'jim_bean@drinks.net'
```

Returns info relating to the user Jim Bean.

## PARAMETERS

### -EmailAddress
Email address of the user that should be returned.

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

### -FullName
Full name of the user that should be returned.

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

### -IncludeAllUsers
Specification of all users should be included. 

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Match
Specify if the search should be an exact match or a partial match.

[0] - Partial match
[1] - Exact match

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageNumber
Specification of what page number should to be returned.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize
Maximum amount of objects that should be returned at once.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Username of the user being searched for.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
