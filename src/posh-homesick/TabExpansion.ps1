using module '.\Subcommand.psm1'
using module '.\Repo.psm1'

Register-ArgumentCompleter -CommandName Invoke-Homesick,homesick -Native -ScriptBlock {
  param($wordToComplete, $commandAst, $cursorPosition)

  # The PowerShell completion has a habit of stripping the trailing space when completing:
  # homesick cd <tab>
  # The Expand-HomesickCommand expects this trailing space, so pad with a space if necessary.
  $padLength = $cursorPosition - $commandAst.Extent.StartOffset
  $textToComplete = $commandAst.ToString().PadRight($padLength, ' ').Substring(0, $padLength)

  # WriteTabExpLog "Expand: command: '$($commandAst.Extent.Text)', padded: '$textToComplete', padlen: $padLength"
  Expand-HomesickCommand $textToComplete
}

function Expand-HomesickCommand {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string] $Command
  )
  $results = HomesickExpansionInternal $Command
  $results
}

function HomesickExpansionInternal($lastBlock) {
  switch -Regex ($lastBlock -replace '^(Invoke-Homesick|homesick) ', '') {
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
