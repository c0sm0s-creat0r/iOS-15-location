#!/bin/bash

# check for prerequisites
# Check and delete "fuel-spoof.txt" if it exists
if [ -e "loc-spoof.txt" ]; then
    rm "loc-spoof.txt"
fi

# Check if python3 is installed
if sudo command -v python3 &> /dev/null; then
    #echo "Python3 is installed"
    # Store the Python path using sudo
    python_path=$(sudo which python3)
    #echo "Python path: $python_path"
else
    echo "python3 not found"
    echo "Please install Python"
    exit 1
fi

# Check if pymobiledevice3 is installed
# Check if the module is installed
if sudo $python_path -m pip show pymobiledevice3 &>/dev/null; then
    #echo "pymobiledevice3 is installed"
    echo -e "\n"
else
    echo "pymobiledevice3 not found"
    echo "Please install using 'sudo python3 -m pip install pymobiledevice3'"
    exit 1
fi
# Check if jq is installed
if command -v jq &>/dev/null; then
    #echo "pymobiledevice3 is installed"
    echo -e "\n"
else
    echo "jq not found"
    echo "Please install jq"
    exit 1
fi


get_location_data() {
    # Set the location variable
    read -p "Enter a location address: " loc_address
    url='http://www.mapquestapi.com/geocoding/v1/address?key='
    args='&location='
    key='VzDGw2u65p0PeEWA1MNIDZSFbCyZs6ek'
    #addr="$(echo $* | sed 's/ /+/g')"
    echo -e "\nFinding location at $loc_address...\n"
    addr="$(echo $loc_address | sed 's/ /+/g' | tr -d ',')"
    location="$(curl -s "$url$key$args$addr" | cut -d, -f30,31 | sed 's/[^0-9\.\,\-]//g;s/,$//' | tr ',' ' ')"
    echo -e "Address ($loc_address) located at $location\n"
}

#Check type of spoofing
echo -e "\n==Location Spoofing iOS17=="
echo -e "Please select desired action: "
echo -e "\n - Coordinates (c)\n - Location (l)\n" 
read -p "Select the type with the associated character: " type_choice

if [[ $type_choice = "c" ]] || [[ $type_choice = "l" ]]; then
    get_location_data
    if [[ $type_choice = "c" ]]; then
        exit 0
    fi
fi

# Execute Step 1 and save the output to a file
echo -e "Starting the tunnel - please wait..."
sudo $python_path -m pymobiledevice3 remote start-tunnel --script-mode > loc-spoof.txt &
# Give Step 1 some time to start before proceeding
# Wait until loc-spoof.txt has some text
while [[ ! -s loc-spoof.txt ]]; do
    sleep 1
done


# Combine RSD Address and RSD Port
rsd_data=$(head -n 1 loc-spoof.txt)

echo -e "\nDevice RSD data is: $rsd_data"


# Step 2 - Mount developer image
echo -e "\nMounting the developer image\n"
sudo $python_path -m pymobiledevice3 mounter auto-mount


# Step 4 - spoof location
echo -e "\nLocation Simulation is now running\n"
echo -e "Spoofing location to ($location)"
echo -e "You can now open your app and your location will be simulated"
echo -e "You will need to press CTRL-C to continue the script once you've completed your location activities"

# full_command="sudo $python_path -m pymobiledevice3 developer dvt simulate-location set --rsd $rsd_data -- $location"
# echo $full_command
# $full_command
#echo -e "\nExecuting: $full_command\n"
sudo $python_path -m pymobiledevice3 developer dvt simulate-location set --rsd $rsd_data -- $location

# Step 5 - Clear the simulated location
echo -e "\n"
read -p "Press Enter to clear the simulated location..."
sudo $python_path -m pymobiledevice3 developer dvt simulate-location clear --rsd $rsd_data

echo -e "\nScript complete - Hope you enjoyed!"
