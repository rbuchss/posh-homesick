using module '.\homepsick\Subcommands.psm1'

<# Module Vars #>
if (-not $env:EDITOR) {
  $env:EDITOR = 'code'  # defaults to VSCode
}

<# Module Aliases #>
Set-Alias -Name homepsick -Value Invoke-Homepsick

<#
  Wrapper for homepsick task invoking
#>
function Invoke-Homepsick {
  [CmdletBinding()]
  param (
    [Parameter(
      Mandatory = $true,
      Position = 0,
      HelpMessage = 'yipp!'
    )]
    [ValidateSet(
      [Subcommands],
      ErrorMessage = "Value '{0}' is invalid. Try one of: '{1}'"
    )]
    [string]
    $Task,

    [Parameter(Position = 1)]
    [string]
    $Subject,

    [Parameter(Position = 2, ValueFromRemainingArguments)]
    [string[]]
    $Arguments
  )
  switch ($Task) {
    'cd' { Set-HomepsickLocation -Path $Subject }
    'clone' { Get-HomepsickClone -URL $Subject $Arguments }
    'generate' { New-HomepsickRepo $Subject }
    'help' { Get-HomepsickHelp $Subject }
    'link' { Set-HomepsickRepoLinks $Subject }
    'list' { Get-HomepsickRepos }
    'open' { Open-HomepsickRepo $Subject }
    'pull' { Invoke-HomepsickRepoPull -Name $Subject $Arguments }
    'push' { Invoke-HomepsickRepoPush -Name $Subject $Arguments }
    'unlink' { Remove-HomepsickRepoLinks $Subject }
    Default { throw }
  }
}

function Set-HomepsickLocation {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Name
  )
  [Repo]::SetLocation($Name)
}

function Get-HomepsickClone {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::IsValidURL($_) })]
    [string]
    $URL,

    # TODO support autocomplete
    [Parameter(ValueFromRemainingArguments)]
    [string[]]
    $Arguments
  )
  ([Repo]::NewFromURL($URL)).Clone($Arguments)
}

function New-HomepsickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::DoesNotExist($_) })]
    [string]
    $Name
  )
  [Repo]::CreateFromTemplate($Name)
}

function Get-HomepsickHelp {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateScript({ [Subcommand]::IsValidHelpValue($_) })]
    [string]
    $Task
  )
  switch ($Task) {
    'cd' { Get-Help Set-HomepsickLocation }
    'clone' { Get-Help Get-HomepsickClone }
    'generate' { Get-Help New-HomepsickRepo }
    'link' { Get-Help Set-HomepsickRepoLinks }
    'list' { Get-Help Get-HomepsickRepos }
    'open' { Get-Help Open-HomepsickRepo }
    'pull' { Get-Help Invoke-HomepsickRepoPull }
    'push' { Get-Help Invoke-HomepsickRepoPush }
    'unlink' { Get-Help Remove-HomepsickRepoLinks }
    default { Get-Help Invoke-Homepsick }
  }
}

<#
  Creates symlinks for all files in repo home dir in $HOME
#>
function Set-HomepsickRepoLinks {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name,

    [Parameter()]
    [switch]
    $Force
  )
  ([Repo]::new($Name)).CreateLinks($Force)
}

function Get-HomepsickRepos {
  [Repo]::GetAll()
}

function Open-HomepsickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name
  )
  ([Repo]::new($Name)).Open()
}

function Invoke-HomepsickRepoPull {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name,

    # TODO support autocomplete
    [Parameter(ValueFromRemainingArguments)]
    [string[]]
    $Arguments
  )
  ([Repo]::new($Name)).Pull($Arguments)
}

function Invoke-HomepsickRepoPush {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name,

    # TODO support autocomplete
    [Parameter(ValueFromRemainingArguments)]
    [string[]]
    $Arguments
  )
  ([Repo]::new($Name)).Push($Arguments)
}

<#
  Removes symlinks for all files in repo home dir in $HOME
#>
function Remove-HomepsickRepoLinks {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name
  )
  ([Repo]::new($Name)).RemoveLinks()
}
