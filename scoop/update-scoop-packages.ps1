#-------------------------------------------------------------------------------
# Description: Checks if there are scoop packages to update, if there are 
# packages that need to be updated the user is asked if he wants them to be 
# updated or not.
#
# Author: Álvaro José Agámez Licha (alvaroagamez@outlook.com)
# GitHub: https://github.com/aagamezl/dev-env-config
# License: MIT
# Last Update: 2023-06-16
#-------------------------------------------------------------------------------

# Run the command and capture its output
$commandOutput = & scoop update; scoop status

# Rest of the code to extract the values under the "Name" column
$lines = $commandOutput -split '\r?\n' | Select-Object

$packages = $lines | ForEach-Object {
  if ($_ -match 'Name=(\S+);') {
    $matches[1]
  }
}

# Join the names into a single line using a delimiter
$packageNames = $packages -join ' '

# Check if $packageNames is empty
if ([string]::IsNullOrEmpty($packageNames)) {
  Write-Host 'No packages to update.'

  return  # Exit the script
}

# Output the names in a single line
Write-Host 'Packages to Update: ' + $packageNames

# Prompt the user for a decision
$decision = Read-Host 'Do you want to update the packages? (yes/no)'

# Perform actions based on user decision
if ($decision -eq 'no') {
  # Finish the script
  Write-Host 'Script finished.'

  return  # Exit the script
}

# Execute something
Write-Host 'Updating packages...'

# Execute the scoop update command with the names as parameters
& scoop update $packageNames
