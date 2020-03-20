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
          [Repo]::Select('does-not-exist', $false) | Should -BeNullOrEmpty
          [Repo]::Select('does-not-exist', $true) | Should -BeNullOrEmpty
        }
      }
    }

    AfterAll {
      Remove-Item $dummyPath -Recurse -Force
    }
  }

  Context '.homesick/repos path exists and does not have repos' {
    BeforeAll {
      $dummyPath = (Join-Path $PSScriptRoot 'dummy')
      mkdir $dummyPath -Force
      [Repo]::BasePath = (Join-Path $dummyPath 'home' '.homesick' 'repos')
    }

    It '.GetAll' {
      [Repo]::GetAll() | Should -HaveCount 0
      [Repo]::GetAll() | Should -BeNullOrEmpty
    }

    Context '.Select' {
      Context 'With no filter' {
        It 'Returns no repos and includes base path' {
          [Repo]::Select($null, $true) | Should -HaveCount 1
          [Repo]::Select($null, $true) | Should -Contain ([Repo]::BasePath)
        }

        It 'Returns no repos and excludes base path' {
          [Repo]::Select($null, $false) | Should -HaveCount 0
          [Repo]::Select($null, $false) | Should -Not -Contain ([Repo]::BasePath)
        }
      }

      Context 'With filter' {
        It 'Returns null if no values match the filter' {
          [Repo]::Select('does-not-exist', $false) | Should -BeNullOrEmpty
          [Repo]::Select('does-not-exist', $true) | Should -BeNullOrEmpty
        }
      }
    }

    AfterAll {
      Remove-Item $dummyPath -Recurse -Force
    }
  }

  Context '.homesick/repos path does not exist' {
    BeforeAll {
      $dummyPath = (Join-Path $PSScriptRoot 'dummy')
      [Repo]::BasePath = (Join-Path $dummyPath 'home' '.homesick' 'repos')
    }

    It '.GetAll' {
      Test-Path ([Repo]::BasePath) | Should -BeFalse -Because 'BasePath has not been created yet'
      [Repo]::GetAll() | Should -HaveCount 0
      [Repo]::GetAll() | Should -BeNullOrEmpty
      Test-Path ([Repo]::BasePath) | Should -BeTrue -Because 'BasePath has automatically been created'
    }

    Context '.Select' {
      Context 'With no filter' {
        It 'Returns no repos and includes base path' {
          [Repo]::Select($null, $true) | Should -HaveCount 1
          [Repo]::Select($null, $true) | Should -Contain ([Repo]::BasePath)
        }

        It 'Returns no repos and excludes base path' {
          [Repo]::Select($null, $false) | Should -HaveCount 0
          [Repo]::Select($null, $false) | Should -Not -Contain ([Repo]::BasePath)
        }
      }

      Context 'With filter' {
        It 'Returns null if no values match the filter' {
          [Repo]::Select('does-not-exist', $false) | Should -BeNullOrEmpty
          [Repo]::Select('does-not-exist', $true) | Should -BeNullOrEmpty
        }
      }
    }

    AfterAll {
      Remove-Item $dummyPath -Recurse -Force
    }
  }
}
