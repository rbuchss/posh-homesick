using module '.\Subcommand.psm1'
using module '.\Repo.psm1'

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
      [Repo]::Select($matches['repo'], $true)
    }

    "^(link|pull|push|unlink).* (?<repo>\S*)$" {
      [Repo]::Select($matches['repo'], $false)
    }

    "^help.* (?<cmd>\S*)$" {
      [Subcommand]::Select($matches['cmd'])
    }

    default { throw }
  }
}
