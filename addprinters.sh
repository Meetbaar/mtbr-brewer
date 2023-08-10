#!/bin/bash

# Tests to see if printer exists - sidesteps a variable scope issue
# Requires the printer name as a parameter.  Returns 1 if the printer exists.
function printerExists()
{
  if [ $# -ne 1 ]; then
    echo "Incorrect parameters"
    return 0
  else
    lpstat -p | awk '{print $2}' | while read printer
    do
      if [ $1 = "${printer}" ]; then
        return 1
      fi
    done
  fi	
}


# Printer Name cannot Include any spaces
prName="Canon DX 527i"
# User friendly printer name"
prDescription="Canon DX 527i (Printruimte)"
# Location
prLocation="Canon DX 527i (Printruimte Breda)"
# IP Address of printer
prAddress="192.168.0.28"
# PPD Filename... assumes it is installed on machine
prPPD="CNADV527X1.PPD.gz"

#Test If Printer is already installed
printerExists $prName
prExists=$?

if [ $prExists -eq 1 ]; then
  echo "Printer already exists. Skipping: \"$prName\""
else
  # Add Printer Command 
  lpadmin -p "${prName}" -D "${prDescription}" -L "${prLocation}" \
  -E -v lpd://"${prAddress}" -P "/Library/Printers/PPDs/Contents/Resources/en.lproj/$prPPD" \
  -o HPOption_Duplexer=True -o Resolution=1200x1200dpi
fi

echo "Add admin printrights for user:"
read adminUser
if [ "$adminUser" != "" ] ; then
  sudo dseditgroup -o edit -n /Local/Default -a $adminUser -t user _lpadmin
fi
