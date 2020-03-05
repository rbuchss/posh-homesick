using module '.\subcommands.psm1'

<# Module Vars #>
$global:HomewickRepoPath = Join-Path $HOME '.homesick' 'repos'
$script:DefaultGithubUrl = 'https://github.com'

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
      [SubCommands],
      ErrorMessage = "Value '{0}' is invalid. Try one of: '{1}'"
    )]
    [string] $Task,

    [Parameter(Position = 1)]
    [string] $Subject,

    [Parameter(Position = 2, ValueFromRemainingArguments)]
    [string[]] $Arguments
  )
  switch ($Task) {
    'cd' { Set-HomewickLocation -Path $Subject }
    'clone' { Get-HomewickClone -URL $Subject $Arguments }
    'generate' { throw 'not implemented!' }
    'help' { Get-HomewickHelp $Subject }
    'link' { Set-HomewickRepoLinks $Subject }
    'list' { Get-HomewickRepos }
    'open' { Open-HomewickRepo $Subject }
    'pull' { throw 'not implemented!' }
    'push' { throw 'not implemented!' }
    'unlink' { throw 'not implemented!' }
    Default { throw }
  }
}

function Set-HomewickLocation {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string] $Path
  )
  $Path = Join-Path $HomewickRepoPath $Path
  Set-Location $Path
}

function Get-HomewickClone {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({
      $_ -match '([^/]+)/(.+)\.git'
    })]
    [string]
    $URL,

    # TODO support autocomplete
    [Parameter(ValueFromRemainingArguments)]
    [string[]]
    $Arguments
  )
  if (-not ($URL -match '^(http:|https:|git@)')) {
    $URL = "$DefaultGithubUrl/$URL"
  }

  $repoName = $URL -replace '.+/([^/]+)\.git', '$1'
  $clonePath = Join-Path $HomewickRepoPath $repoName
  Invoke-Utf8ConsoleCommand { git clone $URL $clonePath $Arguments }
}

function Get-HomewickHelp {
  [CmdletBinding()]
  param (
    [Parameter()]
    [ValidateScript({
      ($_ -eq '') -or ([Subcommand]::validValues.contains($_))
    })]
    [string]
    $Task
  )
  switch ($Task) {
    'cd' { Get-Help Set-HomewickLocation }
    'clone' { Get-Help Get-HomewickClone }
    'link' { Get-Help Set-HomewickRepoLinks }
    'list' { Get-Help Get-HomewickRepos }
    'open' { Get-Help Open-HomewickRepo }
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
    [ValidateScript({
      $path = Join-Path $HomewickRepoPath $_
      Test-Path $path
    })]
    [string]
    $Repo
  )

  $force = $true
  $path = Join-Path $HomewickRepoPath $Repo

  $repoHome = if (Test-Path (Join-Path $path 'windows-home')) {
    Join-Path $path 'windows-home'
  } elseif (Test-Path (Join-Path $path 'home')) {
    Join-Path $path 'home'
  } else {
    throw "Repo: '$Repo' has neither 'home' nor 'windows-home' directories required for linking!"
  }

  Write-Host "linking home files from '$Repo' ..." -ForegroundColor Yellow

  Get-ChildItem $repoHome | Foreach-Object {
    $linkPath = Join-Path $env:HOME $_.Name

    if (Test-Path $linkPath) {
      Write-Host "exists:`t`t'$linkPath' -> '$_'" -ForegroundColor Blue 

      if ($force) {
        Write-Host "overwrite?`t'$linkPath' -> '$_'" -ForegroundColor Red
        New-Item -ItemType SymbolicLink -Path $HOME -Name $_.Name -Value $_ -Confirm -Force > $null
      }
    } else {
      Write-Host "linking:`t`t'$linkPath' -> '$_'" -ForegroundColor Green
      New-Item -ItemType SymbolicLink -Path $HOME -Name $_.Name -Value $_ > $null
    }
  }
}

function Get-HomewickRepos {
  Get-ChildItem $HomewickRepoPath -Directory | Select-Object -ExpandProperty Name
}

function Open-HomewickRepo {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [ValidateScript({
      $path = Join-Path $HomewickRepoPath $_
      Test-Path $path
    })]
    [string]
    $Repo
  )
  try {
    if (Get-Command $env:EDITOR) {
      $path = Join-Path $HomewickRepoPath $Repo
      Invoke-Expression "$env:EDITOR '$path'"
    }
  } catch {
    throw "Error: EDITOR command: '$env:EDITOR' does not exist!"
  }
}
