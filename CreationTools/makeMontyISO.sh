#!/bin/bash

installMedia="$1"
currentUser=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
outputPath="$(eval echo "~$currentUser")/Desktop"

if [[ $(whoami) != 'root' ]]; then
	echo "sudo make me a sammich"
	exit 1
fi

if [[ -z "$installMedia" ]]; then
	echo "Specify install app path as script arg."
	exit 2
elif [[ ! -e "$installMedia" ]]; then
	echo "Install app path does not exist."
	exit 2
fi

echo "Creating new dmg..."
rm /tmp/Monterey.dmg 2>/dev/null
hdiutil create -o /tmp/Monterey -size 13850m -volname Monterey -layout SPUD -fs HFS+J > /dev/null
hdiutil attach /tmp/Monterey.dmg -noverify -mountpoint /Volumes/Monterey > /dev/null
if [[ $? -ne 0 ]]; then
	echo "Problem creating dmg..."
	exit 3
fi

echo "Preparing install media dmg..."
"$installMedia"/Contents/Resources/createinstallmedia --volume /Volumes/Monterey --nointeraction
if [[ $? -ne 0 ]]; then
	echo "Problem creating install media."
	exit 3
fi

echo "Converting dmg to iso..."
hdiutil detach /Volumes/"Install macOS Monterey" > /dev/null #(-force if needed)
hdiutil convert /tmp/Monterey.dmg -format UDTO -o "$outputPath"/Monterey.cdr 1>/dev/null
mv "$outputPath"/Monterey.cdr "$outputPath"/Monterey.iso
chmod 777 "$outputPath"/Monterey.iso
rm /tmp/Monterey.dmg

echo "All done!"

exit 0