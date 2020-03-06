using namespace System.Management.Automation
using module '.\Subcommand.psm1'

class Subcommands : IValidateSetValuesGenerator {
  [string[]] GetValidValues() {
    return [string[]] [Subcommand]::validValues
  }
}
