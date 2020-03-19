using module '..\src\posh-homesick\Repo.psm1'

Describe 'Repo' {
  Context '.homesick/repos path exists and has repos' {
    BeforeAll {
      $dummyPath = (Join-Path $PSScriptRoot 'dummy')
      mkdir $dummyPath -Force
      Copy-Item -Recurse (Join-Path $PSScriptRoot 'fixtures' 'home') $dummyPath
      [Repo]::BasePath = (Join-Path $dummyPath 'home' '.homesick' 'repos')
    }

    It '.GetAll' {
      [Repo]::GetAll() | Should -HaveCount 4
      [Repo]::GetAll() | Should -Be @('bar', 'baz', 'foo', 'qux')
    }

    Context '.Select' {
      Context 'With no filter' {
        It 'Returns all repos and includes base path' {
          [Repo]::Select($null, $true) | Should -HaveCount 5
          [Repo]::Select($null, $true) | Should -Contain ([Repo]::BasePath)
        }

        It 'Returns all repos and excludes base path' {
          [Repo]::Select($null, $false) | Should -HaveCount 4
          [Repo]::Select($null, $false) | Should -Not -Contain ([Repo]::BasePath)
        }
      }

      Context 'With filter' {
        It 'Returns all values matching filter' {
          [Repo]::Select('b', $false) | Should -Be @('bar', 'baz')
          [Repo]::Select('b', $true) | Should -Be @('bar', 'baz')
        }

        It 'Returns null if no values match the filter' {
          [Repo]::Select('does-not-exist', $false) | Should -BeNull
          [Repo]::Select('does-not-exist', $true) | Should -BeNull
        }
      }
    }

    AfterAll {
      Remove-Item $dummyPath -Recurse -Force
    }
  }
}
