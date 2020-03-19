using module '..\src\posh-homesick\Subcommand.psm1'

Describe 'Subcommand' {
  It 'Has valid values' {
    [Subcommand]::validValues | Should -HaveCount 10
  }

  Context '.Select' {
    It 'Returns all values with no filter' {
      [Subcommand]::Select($null) | Should -Be @([Subcommand]::validValues)
    }

    It 'Returns all values matching filter' {
      [Subcommand]::Select('c') | Should -Be @('cd', 'clone')
      [Subcommand]::Select('op') | Should -Be @('open')
    }

    It 'Returns null if no values match the filter' {
      [Subcommand]::Select('does-not-exist') | Should -BeNull
    }
  }

  Context '.IsValidHelpValue' {
    It 'Returns true for a blank value' {
      [Subcommand]::IsValidHelpValue('') | Should -BeTrue
    }

    It 'Returns true if value is a valid value' {
      [Subcommand]::IsValidHelpValue('cd') | Should -BeTrue
      [Subcommand]::IsValidHelpValue('open') | Should -BeTrue
    }

    It 'Returns false if value is not blank or not a valid value' {
      [Subcommand]::IsValidHelpValue('does-not-exist') | Should -BeFalse
      [Subcommand]::IsValidHelpValue($null) | Should -BeFalse
    }
  }
}
