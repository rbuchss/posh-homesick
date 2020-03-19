param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent

if ($Force -and (Get-Module posh-homesick)) {
  Remove-Module posh-homesick -Force -Verbose:$Verbose
}

Import-Module $installDir\src\posh-homesick.psd1 -Force:$Force -Verbose:$Verbose
