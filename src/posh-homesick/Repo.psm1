using namespace System.Management.Automation
using module '.\Utilities.psm1'

class Repo {
  static [string] $BasePath = (Join-Path $env:HOME '.homesick' 'repos')
  static [string] $BaseURL = 'https://github.com'

  static [string] GetBasePath() {
    if (-not (Test-Path ([Repo]::BasePath))) {
      mkdir ([Repo]::BasePath)
    }
    return ([Repo]::BasePath)
  }

  static [string[]] GetAll() {
    return @(Get-ChildItem ([Repo]::GetBasePath()) -Directory | Select-Object -ExpandProperty Name)
  }

  static [string[]] Select($filter, $includeBasePath) {
    $searchPath = (Join-Path ([Repo]::GetBasePath()) $filter)
    $paths = @(Get-ChildItem "$searchPath*" -Directory | Select-Object -ExpandProperty Name)
    if ((-not $filter) -and $includeBasePath) { $paths += [Repo]::GetBasePath() }
    return $paths
  }

  static [boolean] IsValidURL($url) {
    return $url -match '([^/]+)/(.+)\.git'
  }

  static [string] ExpandURL($url) {
    if (-not ($url -match '^(http:|https:|git@)')) {
      return "$([Repo]::BaseURL)/$url"
    }
    return $url
  }

  static [string] GetNameFromURL($url) {
    return $url -replace '.+/([^/]+)\.git', '$1'
  }

  static [string] GetPath($name) {
    return (Join-Path ([Repo]::GetBasePath()) $name)
  }

  static [boolean] Exists($name) {
    return (Test-Path ([Repo]::GetPath($name)))
  }

  static [boolean] DoesNotExist($name) {
    return (-not [Repo]::Exists($name))
  }

  static [void] SetLocation($name) {
    if ($name -and (-not ($name -eq [Repo]::BasePath))) {
      ([Repo]::new($name)).SetLocation()
    }
    Set-Location ([Repo]::GetBasePath())
  }

  static [void] CreateFromTemplate($name) {
    $repo = [Repo]::new($name)

    if ($repo.Exists()) {
      throw "Repo: '$($repo.name)' already exists"
    }

    $templatePath = (Join-Path $PSScriptRoot 'template')
    Copy-Item -Path $templatePath -Recurse -Destination $repo.path -Verbose
  }

  static [Repo] NewFromURL($url) {
    $local:url = [Repo]::ExpandURL($url)
    $local:name = [Repo]::GetNameFromURL($url)
    $repo = [Repo]::new($name)
    $repo.url = $url
    return $repo
  }

  [string] $name
  [string] $path
  [string] $url

  Repo($name) {
    $this.name = $name
    $this.path = [Repo]::GetPath($name)
  }

  [boolean] Exists() {
    return ([Repo]::Exists($this.name))
  }

  [boolean] DoesNotExist() {
    return ([Repo]::DoesNotExist($this.name))
  }

  [void] SetLocation() {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }
    Set-Location $this.path
  }

  [void] Clone($flags) {
    # TODO check if this a real github url?
    if (-not ([Repo]::IsValidURL($this.url))) {
      throw "Repo: '$($this.name)' does not have a vaild url: '$($this.url)'"
    }
    if ($this.Exists()) {
      throw "Repo: '$($this.name)' already exists"
    }
    Invoke-Utf8ConsoleCommand {
      git -c core.symlinks=true clone --recurse-submodules -j8 $this.url $this.path @flags
    }
  }

  [string] GetHomePath() {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }

    $repoHome = if (Test-Path (Join-Path $this.path 'windows-home')) {
      Join-Path $this.path 'windows-home'
    } elseif (Test-Path (Join-Path $this.path 'home')) {
      Join-Path $this.path 'home'
    } else {
      throw "Repo: '$($this.name)' has neither 'home' nor 'windows-home' directories required for linking!"
    }
    return $repoHome
  }

  [void] CreateLinks($force) {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }

    Write-Host "linking home files from '$($this.name)' ..." -ForegroundColor Yellow

    Get-ChildItem $this.GetHomePath() | Foreach-Object {
      $linkPath = Join-Path $env:HOME $_.Name

      if (Test-Path $linkPath) {
        Write-Host "exists:`t`t'$linkPath' -> '$_'" -ForegroundColor Blue

        if ($force) {
          Write-Host "overwrite?`t'$linkPath' -> '$_'" -ForegroundColor Red
          New-Item -ItemType SymbolicLink -Path $env:HOME -Name $_.Name -Value $_ -Confirm -Force > $null
        }
      } else {
        Write-Host "linking:`t`t'$linkPath' -> '$_'" -ForegroundColor Green
        New-Item -ItemType SymbolicLink -Path $env:HOME -Name $_.Name -Value $_ > $null
      }
    }
  }

  [void] Open() {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }

    try {
      if (Get-Command $env:EDITOR) {
        Invoke-Expression "$env:EDITOR '$($this.path)'"
      }
    } catch {
      throw "Error: EDITOR command: '$env:EDITOR' does not exist!"
    }
  }

  [void] Pull($flags) {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }

    Invoke-Utf8ConsoleCommand { git -C $this.path pull @flags }
  }

  [void] Push($flags) {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }

    Invoke-Utf8ConsoleCommand { git -C $this.path push @flags }
  }

  [void] RemoveLinks() {
    if ($this.DoesNotExist()) {
      throw "Repo: '$($this.name)' does not exist"
    }

    Write-Host "unlinking home files from '$($this.name)' ..." -ForegroundColor Yellow

    Get-ChildItem $this.GetHomePath() | Foreach-Object {
      $linkPath = Join-Path $env:HOME $_.Name

      if (Test-Path $linkPath) {
        Write-Host "removing link:`t`t'$linkPath' -> '$_'" -ForegroundColor Blue
        Remove-Item $linkPath -Confirm > $null
      } else {
        Write-Host "link does not exist (noop):`t`t'$linkPath' -> '$_'" -ForegroundColor Gray
      }
    }
  }
}
