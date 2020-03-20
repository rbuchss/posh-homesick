using module '.\posh-homesick\Subcommands.psm1'

<# Module Vars #>
if (-not $env:EDITOR) {
  $env:EDITOR = 'code'  # defaults to VSCode
}

<# Module Aliases #>
Set-Alias -Name homesick -Value Invoke-Homesick

<#
  Wrapper for homesick task invoking
#>
function Invoke-Homesick {
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
    'cd' { Set-HomesickLocation -Name $Subject }
    'clone' { Get-HomesickClone -URL $Subject $Arguments }
    'generate' { New-HomesickRepo $Subject }
    'help' { Get-HomesickHelp $Subject }
    'link' { Set-HomesickRepoLinks $Subject }
    'list' { Get-HomesickRepos }
    'open' { Open-HomesickRepo $Subject }
    'pull' { Invoke-HomesickRepoPull -Name $Subject $Arguments }
    'push' { Invoke-HomesickRepoPush -Name $Subject $Arguments }
    'unlink' { Remove-HomesickRepoLinks $Subject }
    Default { throw }
  }
}

function Set-HomesickLocation {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Name
  )
  [Repo]::SetLocation($Name)
}

function Get-HomesickClone {
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

function New-HomesickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::DoesNotExist($_) })]
    [string]
    $Name
  )
  [Repo]::CreateFromTemplate($Name)
}

function Get-HomesickHelp {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateScript({ [Subcommand]::IsValidHelpValue($_) })]
    [string]
    $Task
  )
  switch ($Task) {
    'cd' { Get-Help Set-HomesickLocation }
    'clone' { Get-Help Get-HomesickClone }
    'generate' { Get-Help New-HomesickRepo }
    'link' { Get-Help Set-HomesickRepoLinks }
    'list' { Get-Help Get-HomesickRepos }
    'open' { Get-Help Open-HomesickRepo }
    'pull' { Get-Help Invoke-HomesickRepoPull }
    'push' { Get-Help Invoke-HomesickRepoPush }
    'unlink' { Get-Help Remove-HomesickRepoLinks }
    default { Get-Help Invoke-Homesick }
  }
}

<#
  Creates symlinks for all files in repo home dir in $HOME
#>
function Set-HomesickRepoLinks {
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

function Get-HomesickRepos {
  [Repo]::GetAll()
}

function Open-HomesickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name
  )
  ([Repo]::new($Name)).Open()
}

function Invoke-HomesickRepoPull {
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

function Invoke-HomesickRepoPush {
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
function Remove-HomesickRepoLinks {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name
  )
  ([Repo]::new($Name)).RemoveLinks()
}
