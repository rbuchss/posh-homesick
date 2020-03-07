using module '..\src\homepsick\Subcommand.psm1'

Describe 'Subcommand' {
  It 'Has valid values' {
    [Subcommand]::validValues.Count | Should Be 10
  }

  Context '.Select' {
    It 'Returns all values with no filter' {
      [Subcommand]::Select($null) | Should Be @([Subcommand]::validValues)
    }

    It 'Returns all values matching filter' {
      [Subcommand]::Select('c') | Should Be @('cd', 'clone')
      [Subcommand]::Select('op') | Should Be @('open')
    }

    It 'Returns null if no values match the filter' {
      [Subcommand]::Select('does-not-exist') | Should Be $null
    }
  }

  Context '.IsValidHelpValue' {
    It 'Returns true for a blank value' {
      [Subcommand]::IsValidHelpValue('') | Should Be $true
    }

    It 'Returns true if value is a valid value' {
      [Subcommand]::IsValidHelpValue('cd') | Should Be $true
      [Subcommand]::IsValidHelpValue('open') | Should Be $true
    }

    It 'Returns false if value is not blank or not a valid value' {
      [Subcommand]::IsValidHelpValue('does-not-exist') | Should Be $false
      [Subcommand]::IsValidHelpValue($null) | Should Be $false
    }
  }
}
