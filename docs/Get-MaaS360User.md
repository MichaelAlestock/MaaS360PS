---
external help file: MaaS360PS-help.xml
Module Name: MaaS360PS
online version:
schema: 2.0.0
---

# Get-MaaS360User

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### PartialMatch (Default)
```
Get-MaaS360User [-IncludeAllUsers <Int32>] [-PageNumber <Int32>] [-PageSize <Int32>] [[-PartialMatch] <Int32>]
 [[-PartialEmailAddress] <String>] [-FullName <String>] [-Username <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ExactMatch
```
Get-MaaS360User [-IncludeAllUsers <Int32>] [-PageNumber <Int32>] [-PageSize <Int32>] [-ExactMatch <Int32>]
 [-EmailAddress <String>] [-FullName <String>] [-Username <String>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -EmailAddress
{{ Fill EmailAddress Description }}

```yaml
Type: String
Parameter Sets: ExactMatch
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ExactMatch
{{ Fill ExactMatch Description }}

```yaml
Type: Int32
Parameter Sets: ExactMatch
Aliases:
Accepted values: 1

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FullName
{{ Fill FullName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: PartialFullUserName

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeAllUsers
{{ Fill IncludeAllUsers Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:
Accepted values: 0, 1, 2

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageNumber
{{ Fill PageNumber Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PageSize
{{ Fill PageSize Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:
Accepted values: 25, 50, 100, 200, 250

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartialEmailAddress
{{ Fill PartialEmailAddress Description }}

```yaml
Type: String
Parameter Sets: PartialMatch
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PartialMatch
{{ Fill PartialMatch Description }}

```yaml
Type: Int32
Parameter Sets: PartialMatch
Aliases:
Accepted values: 0

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
{{ Fill Username Description }}

```yaml
Type: String
Parameter Sets: PartialMatch
Aliases: PartialUserName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: ExactMatch
Aliases: PartialUserName

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
