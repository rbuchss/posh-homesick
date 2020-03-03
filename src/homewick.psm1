$global:HomewickRepoPath = Join-Path $HOME '.homesick' 'repos'
$script:DefaultGithubUrl = 'https://github.com'

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
      'cd',
      'clone',
      'generate',
      'help',
      'link',
      'list',
      'open',
      'pull',
      'push',
      'unlink',
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
    'help' { Show-HomewickHelp }
    'link' { throw 'not implemented!' }
    'list' { throw 'not implemented!' }
    'open' { throw 'not implemented!' }
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
    [ArgumentCompleter({
      [OutputType([System.Management.Automation.CompletionResult])]  # zero to many
      param(
        [string] $CommandName,
        [string] $ParameterName,
        [string] $WordToComplete,
        [System.Management.Automation.Language.CommandAst] $CommandAst,
        [System.Collections.IDictionary] $FakeBoundParameters
      )
      $searchPath = Join-Path $HomewickRepoPath $WordToComplete
      $paths = Get-ChildItem "$searchPath*" -Directory | Select-Object -ExpandProperty Name
      if (-not $WordToComplete) { $paths += $HomewickRepoPath }
      $paths
    })]
    [string] $Path
  )
  $Path = Join-Path $HomewickRepoPath $Path
  Set-Location $Path
}

function Get-HomewickClone {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    # TODO add '<username>/*.git$' validation
    [string]
    $URL
  )
  if (-not ($URL -match '^(http:|https:|git@)')) {
    $URL = "$DefaultGithubUrl/$URL"
  }

  $repoName = $URL -replace '.+/([^/]+)\.git', '$1'
  $clonePath = Join-Path $HomewickRepoPath $repoName
  Invoke-Utf8ConsoleCommand { git clone $URL $clonePath }
}

function Show-HomewickHelp {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]
    $Task
  )
  Write-Host "Help"
}

<#
  Creates symlinks for all files in repo home dir in $HOME
#>

  # $repoPath = (Get-Item $PSScriptRoot).Parent
  # $repoName = $repoPath.BaseName

  # $repoHome = if (Test-Path (Join-Path $repoPath "windows-home")) {
  #   (Join-Path $repoPath "windows-home")
  # } elseif (Test-Path (Join-Path $repoPath "home")) {
  #   (Join-Path $repoPath "home")
  # } else {
  #   throw "Repo has neither 'home' nor 'windows-home' directories required for linking!"
  # }

  # $force = $true

  # Write-Host "linking home files from '$repoName' ..." -ForegroundColor Yellow

  # Get-ChildItem $repoHome |
  # Foreach-Object {
  #   $linkPath = "$HOME\$($_.Name)"

  #   if (Test-Path $linkPath) {
  #     Write-Host "exists:`t`t'$linkPath' -> '$_'" -ForegroundColor Blue 
  #     if ($force) {
  #       Write-Host "overwrite?`t'$linkPath' -> '$_'" -ForegroundColor Red
  #       New-Item -ItemType SymbolicLink -Path $HOME -Name $_.Name -Value $_ -Confirm -Force > $null
  #     }
  #   } else {
  #     Write-Host "linking:`t`t'$linkPath' -> '$_'" -ForegroundColor Green
  #     New-Item -ItemType SymbolicLink -Path $HOME -Name $_.Name -Value $_ > $null
  #   }
  # }