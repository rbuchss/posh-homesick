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
}

class Subcommands : IValidateSetValuesGenerator {
  [string[]] GetValidValues() {
    return [string[]] [Subcommand]::validValues
  }
}
