
class Subcommands : System.Management.Automation.IValidateSetValuesGenerator {
  [string[]] $validValues = @(
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

  [string[]] GetValidValues() {
    return [string[]] $this.validValues
  }
}
