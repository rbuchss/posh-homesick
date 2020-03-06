@{

# Script module or binary module file associated with this manifest.
RootModule = 'homewick.psm1'

# Version number of this module.
ModuleVersion = '0.0.0.0'

# ID used to uniquely identify this module
GUID = '03ca21c5-f151-40e7-a9ee-a26e83da7836'

# Author of this module
Author = 'Russell Buchanan'

# Copyright statement for this module
Copyright = '(c) 2020 Russell Buchanan and contributors'

# Description of the functionality provided by this module
Description = 'Provides user config file management like homesick & homeshick.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Functions to export from this module
FunctionsToExport = @(
    'Invoke-Homewick'
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @(
    'homewick'
)

NestedModules = @(
    'homewick/Subcommand.psm1',
    'homewick/Subcommands.psm1',
    'homewick/Utilities.ps1',
    'homewick/TabExpansion.ps1'
)

# Private data to pass to the module specified in RootModule/ModuleToProcess.
# This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('dot-file', 'homesick', 'homeshick')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/rbuchss/homewick/blob/master/LICENSE.txt'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/rbuchss/homewick'

        # ReleaseNotes of this module
        ReleaseNotes = 'https://github.com/rbuchss/homewick/blob/master/CHANGELOG.md'

        # OVERRIDE THIS FIELD FOR PUBLISHED RELEASES - LEAVE AT 'alpha' FOR CLONED/LOCAL REPO USAGE
        Prerelease = 'beta3x'
    }
}
}
