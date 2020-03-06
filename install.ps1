param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent

if ($Force -and (Get-Module homepsick)) {
  Remove-Module homepsick -Force -Verbose:$Verbose
}

Import-Module $installDir\src\homepsick.psd1 -Force:$Force -Verbose:$Verbose
