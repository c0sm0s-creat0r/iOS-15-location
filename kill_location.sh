#!/bin/bash
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

rsd_data=$(head -n 1 loc-spoof.txt)
sudo $python_path -m pymobiledevice3 developer dvt simulate-location clear --rsd $rsd_data