Register-ArgumentCompleter -CommandName Invoke-Homewick,homewick -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)

  # The PowerShell completion has a habit of stripping the trailing space when completing:
  # homewick cd <tab>
  # The Expand-HomewickCommand expects this trailing space, so pad with a space if necessary.
  $padLength = $cursorPosition - $commandAst.Extent.StartOffset
  $textToComplete = $commandAst.ToString().PadRight($padLength, ' ').Substring(0, $padLength)

  # WriteTabExpLog "Expand: command: '$($commandAst.Extent.Text)', padded: '$textToComplete', padlen: $padLength"
  Expand-HomewickCommand $textToComplete
}

function Expand-HomewickCommand {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $Command
  )
  $results = HomewickExpansionInternal $Command
  $results
}

function HomewickExpansionInternal($lastBlock) {
  switch -Regex ($lastBlock -replace '^(Invoke-Homewick|homewick) ', '') {
    "^(cd|open).* (?<repo>\S*)$" {
      homewickRepos $matches['repo'] $true
    }

    "^(link|pull|unlink).* (?<repo>\S*)$" {
      homewickRepos $matches['repo'] $false
    }

    "^help.* (?<cmd>\S*)$" {
      homewickSubcommands $matches['cmd']
    }

    default { throw }
  }
}

function script:homewickRepos($filter, $includeBasePath = $false) {
  $searchPath = Join-Path $HomewickRepoPath $filter
  $paths = Get-ChildItem "$searchPath*" -Directory | Select-Object -ExpandProperty Name
  if ((-not $filter) -and $includeBasePath) { $paths += $HomewickRepoPath }
  $paths
}

function script:homewickSubcommands($filter) {
  $subcommands = [Subcommand]::validValues 
  if (-not $filter) { return $subcommands }
  $subcommands | Where-Object { $_ -like "$filter*" }
}
