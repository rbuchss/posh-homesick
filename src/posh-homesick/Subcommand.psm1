using namespace System.Management.Automation

class Subcommand {
  static [string[]] $validValues = @(
    'cd',
    'clone',
    'generate',
    'help',
    'link',
    'list',
    'open',
    'pull',
    'push',
    'unlink'
  )

  static [string[]] Select($filter) {
    $subcommands = [Subcommand]::validValues
    if (-not $filter) { return [string[]] $subcommands }
    return $subcommands.Where({ $_ -like "$filter*" })
  }

  static [boolean] IsValidHelpValue($value) {
    return ($value -eq '') -or ([Subcommand]::validValues.contains($value))
  }
}
