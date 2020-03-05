param([switch]$WhatIf = $false, [switch]$Force = $false, [switch]$Verbose = $false)

$installDir = Split-Path $MyInvocation.MyCommand.Path -Parent

if ($Force) {
  Remove-Module homewick
}

Import-Module $installDir\src\homewick.psd1
