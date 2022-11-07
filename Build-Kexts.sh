#!/bin/bash

##########################################################
# Script made by Jaimie de Haas (sjemmeh @ Github)       #
# Credits to racka98 @ Github for firmware removal parts #
##########################################################
######################
# Check requirements #
######################

# Check if xcode is installed
xcode-select -p 1>/dev/null; 
XCODE_INSTALLED=$?

# Check if git is installed
git --version 2>&1 >/dev/null;
GIT_INSTALLED=$?

if ! (test $XCODE_INSTALLED -eq 0 && test $GIT_INSTALLED -eq 0)
then 
    echo "Requirements not met, please install xcode and git."
    exit
fi

#######################
# Prepare Directories #
#######################

# Set working dir
cd "$(dirname "$0")"

# Delete folders if they exist
[ -d "./ventura-bt-wifi-kexts/" ] && rm -Rf ./ventura-bt-wifi-kexts/

#(Re-)Create folders
mkdir ventura-bt-wifi-kexts
cd ventura-bt-wifi-kexts

# Clone Repos
git clone https://github.com/OpenIntelWireless/IntelBluetoothFirmware.git
git clone https://github.com/OpenIntelWireless/itlwm.git
git clone https://github.com/acidanthera/MacKernelSDK.git

# Copy to folders
cp -r ./MacKernelSDK/ ./IntelBluetoothFirmware/MacKernelSDK/
cp -r ./MacKernelSDK/ ./itlwm/MacKernelSDK/

# Remove MacKernelSDK, since it's not neccesary anymore.
rm -Rf MacKernelSDK

#############
# Bluetooth #
#############

cd IntelBluetoothFirmware

# remove firmware for other BT cards
find IntelBluetoothFirmware/fw/ -type f ! -name 'ibt-20*' -delete

# build the kext
xcodebuild -project IntelBluetoothFirmware.xcodeproj -target IntelBluetoothFirmware -configuration Release -sdk macosx

# Move kext to folder and remove 
cd ..
mv ./IntelBluetoothFirmware/build/Release/IntelBluetoothFirmware.kext ./
rm -Rf IntelBluetoothFirmware

#########
# Wi-Fi #
#########

cd itlwm

# remove firmware for other wifi cards
find itlwm/firmware/ -type f ! -name 'iwlwifi*' -delete

# generate firmware
xcodebuild -project itlwm.xcodeproj -target fw_gen -configuration Release -sdk macosx

## AirportItlwm Ventura - Change to your MacOS version
xcodebuild -project itlwm.xcodeproj -target AirportItlwm-Ventura -configuration Release -sdk macosx

# Move kext to folder and remove
cd .. 
mv ./itlwm/build/Release/Ventura/AirportItlwm.kext ./
rm -Rf itlwm

# Done - Clear
Clear

echo "Complete. Check folder for the kexts."
