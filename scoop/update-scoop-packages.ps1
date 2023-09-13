#-------------------------------------------------------------------------------
# Description: Checks if there are scoop packages to update, if there are
# packages that need to be updated the user is asked if he wants them to be
# updated or not.
#
# Author: Álvaro José Agámez Licha (alvaroagamez@outlook.com)
# License: MIT
# Last Update: 2023-07-10
#-------------------------------------------------------------------------------

scoop update

# Run the command and capture its output
$commandOutput = & scoop status

# Rest of the code to extract the values under the "Name" column
$lines = $commandOutput -split '\r?\n' | Select-Object

$packages = $lines | ForEach-Object {
  if ($_ -match 'Name=(\S+);') {
    $matches[1]
  }
}

# Join the names into a single line using a delimiter
# $packageNames = $packages -join ' '
$packageNames = $packages
# $packageNames = @('xnviewmp', 'vlc', 'rufus', 'robo3t')

# Check if $packageNames is empty
if ([string]::IsNullOrEmpty($packageNames)) {
  Write-Host 'No packages to update.'

  return  # Exit the script
}

# Function to clear the terminal
function Clear-Terminal {
  $ESC = [char]27
  $hideCursor = "${ESC}[?25l"
  Write-Host -NoNewline $hideCursor # Hide terminal cursor

  [Console]::SetCursorPosition(0, 0)
  [Console]::Clear()
}

# Function to close the terminal
Function Close-Terminal {
  $ESC = [char]27
  $showCursor = "${ESC}[?25h"

  Write-Host -NoNewline $showCursor
}

# Function to confirm the selection and exit
function Confirm-Selection {
  $selectedOptions.sort()
  $selectedOptionNames = $selectedOptions | ForEach-Object { $packageNames[$_] }

  # Output the names in a single line
  Write-Host "`nPackages to Update: $selectedOptionNames`n"

  # Execute something
  Write-Host "Updating packages...`n"

  # Execute the scoop update command with the names as parameters
  & scoop update $selectedOptionNames

  Close-Terminal

  exit
}

# Function to display the list with the selected options
function Display-List {
  Clear-Terminal

  Write-Host "Select option(s) (press spacebar to toggle selection):`n"

  $packageNames | ForEach-Object -Begin { $index = 0 } -Process {
    $isSelected = $selectedOptions.Contains($index)
    $prefix = if ($index -eq $selectedOption.Value) { ">"  } else { " " }
    $checkbox = if ($isSelected) { "[X]"  } else { "[ ]"  }
    $formattedOption = "$prefix $checkbox $_"

    Write-Host $formattedOption
    $index++
  }
}

# Function to handle key press events
function Handle-Key-Press([System.ConsoleKeyInfo]$keyInfo) {
  $key = $keyInfo.Key

  # Perform actions based on the pressed key
  switch ($key) {
    "DownArrow" {
      $selectedOption.Value = (($selectedOption.Value + 1) % $packageNames.Length)
      Display-List($selectedOption.Value, $selectedOptions)
    }

    "Enter" {
      Confirm-Selection
    }

    "Escape" {
      Close-Terminal

      exit
    }

    "Spacebar" {
      $currentOption = $selectedOption.Value
      $isSelected = $selectedOptions.Contains($currentOption)

      Write-Host "isSelected: $isSelected"

      if ($isSelected) {
        $optionIndex = $selectedOptions.IndexOf($currentOption)
        $selectedOptions.RemoveAt($optionIndex)
      } else {
        $selectedOptions.Add($currentOption)
      }

      Display-List($selectedOption.Value, $selectedOptions)
    }

    "UpArrow" {
      $selectedOption.Value = (($selectedOption.Value - 1 + $packageNames.Length) % $packageNames.Length)
      Display-List($selectedOption.Value, $selectedOptions)
    }
  }
}

# Selected options
$selectedOptions = New-Object System.Collections.ArrayList

# Current selected option
$selectedOption = [ref]0

# Display the initial list
Display-List($selectedOption.Value, $selectedOptions)

# Main script
while ($true) {
  $keyInfo = [System.Console]::ReadKey($true)
  Handle-Key-Press($keyInfo)

  Start-Sleep -Milliseconds 50
}
