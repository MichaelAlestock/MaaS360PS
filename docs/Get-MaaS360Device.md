---
external help file: Maas360PS-help.xml
Module Name: MaaS360PS
online version:
schema: 2.0.0
---

# Get-MaaS360Device

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
Get-MaaS360Device [[-PageNumber] <Int32>] [[-PageSize] <Int32>] [[-Match] <Int32>] [[-DeviceName] <String>]
 [[-PhoneNumber] <String>] [[-Username] <String>] [[-EmailAddress] <String>] [[-DeviceStatus] <String>]
 [[-IMEI] <String>] [[-ManagedStatus] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -DeviceName
{{ Fill DeviceName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DeviceStatus
{{ Fill DeviceStatus Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Active, Inactive

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EmailAddress
{{ Fill EmailAddress Description }}

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

### -IMEI
{{ Fill IMEI Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ManagedStatus
{{ Fill ManagedStatus Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Inactive, Activated, Control Removed, Pending Control Removed, User Removed Control, Not Enrolled, Enrolled

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Match
{{ Fill Match Description }}

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:
Accepted values: 0, 1

Required: False
Position: 2
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
Position: 0
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
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PhoneNumber
{{ Fill PhoneNumber Description }}

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

### -Username
{{ Fill Username Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName)
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
