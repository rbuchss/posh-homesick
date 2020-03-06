using module '.\homewick\Subcommands.psm1'

<# Module Vars #>
if (-not $env:EDITOR) {
  $env:EDITOR = 'code'  # defaults to VSCode
}

<# Module Aliases #>
Set-Alias -Name homewick -Value Invoke-Homewick

<#
  Wrapper for homewick task invoking
#>
function Invoke-Homewick {
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
    'cd' { Set-HomewickLocation -Path $Subject }
    'clone' { Get-HomewickClone -URL $Subject $Arguments }
    'generate' { New-HomewickRepo $Subject }
    'help' { Get-HomewickHelp $Subject }
    'link' { Set-HomewickRepoLinks $Subject }
    'list' { Get-HomewickRepos }
    'open' { Open-HomewickRepo $Subject }
    'pull' { Invoke-HomewickRepoPull -Name $Subject $Arguments }
    'push' { Invoke-HomewickRepoPush -Name $Subject $Arguments }
    'unlink' { Remove-HomewickRepoLinks $Subject }
    Default { throw }
  }
}

function Set-HomewickLocation {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Name
  )
  [Repo]::SetLocation($Name)
}

function Get-HomewickClone {
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

function New-HomewickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::DoesNotExist($_) })]
    [string]
    $Name
  )
  [Repo]::CreateFromTemplate($Name)
}

function Get-HomewickHelp {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateScript({ [Subcommand]::IsValidHelpValue($_) })]
    [string]
    $Task
  )
  switch ($Task) {
    'cd' { Get-Help Set-HomewickLocation }
    'clone' { Get-Help Get-HomewickClone }
    'generate' { Get-Help New-HomewickRepo }
    'link' { Get-Help Set-HomewickRepoLinks }
    'list' { Get-Help Get-HomewickRepos }
    'open' { Get-Help Open-HomewickRepo }
    'pull' { Get-Help Invoke-HomewickRepoPull }
    'push' { Get-Help Invoke-HomewickRepoPush }
    'unlink' { Get-Help Remove-HomewickRepoLinks }
    default { Get-Help Invoke-Homewick }
  }
}

<#
  Creates symlinks for all files in repo home dir in $HOME
#>
function Set-HomewickRepoLinks {
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

function Get-HomewickRepos {
  [Repo]::GetAll()
}

function Open-HomewickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name
  )
  ([Repo]::new($Name)).Open()
}

function Invoke-HomewickRepoPull {
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

function Invoke-HomewickRepoPush {
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
function Remove-HomewickRepoLinks {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({ [Repo]::Exists($_) })]
    [string]
    $Name
  )
  ([Repo]::new($Name)).RemoveLinks()
}
