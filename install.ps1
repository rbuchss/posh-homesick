param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent

if ($Force -and (Get-Module homewick)) {
  Remove-Module homewick -Force -Verbose:$Verbose
}

Import-Module $installDir\src\homewick.psd1 -Force:$Force -Verbose:$Verbose
