# Gonna play with this and see how much more beneficial this is compared
# to creating a new object and object information per function

class User
{
    [string]$Name
    [string]$Email
    [string]$Username
    [string]$Alias
    [string]$Domain
    [string]$Active
    [DateTime]$CreatedDate
    [DateTime]$UpdatedDate

    # Default constructor
    User() {}

    # Main constructor
    User([string]$Email, [string]$Name, [string]$Username, [string]$Alias, [string]$Domain, [string]$Active, [DateTime]$CreatedDate, [DateTime]$UpdatedDate)
    {
        $this.Email = $Email
        $this.Name = $Name
        $this.Username = $Username
        $this.Alias = $Alias
        $this.Domain = $Domain
        $this.Active = $Active
        $this.CreatedDate = $CreatedDate
        $this.UpdatedDate = $UpdatedDate
    }
}