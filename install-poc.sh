#! /bin/bash

echo "dbp-brewer ¯\\\_(ツ)_/¯ V1.1 \r\r"
echo ""
echo "You are going to install the dbp-brewer for the following system!"
array=$( system_profiler SPSoftwareDataType )

for i in "${array[@]}"; do
    echo "- $i"
done

sleep 2
osascript -e 'tell application "System Preferences" to quit'
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo -ne "#                         (1%)\r"
sleep 2
echo -ne "##############            (56%)\r"
sleep 1
echo -ne "##################        (73%)\r"
sleep 1
echo -ne "#######################   (100%)\r"
echo -ne "\n"
echo "Get and install homebrew"
sleep 1

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
eval "$(/opt/homebrew/bin/brew shellenv)"

echo "Checking Homebrew"
echo -ne "##                        (4%)\r"
sleep 1
echo -ne "##################        (73%)\r"
sleep 1
echo -ne "#######################   (100%)\r"
echo -ne "\n"
echo "Checking installed brew version"
brew -v
sleep 3

brew install tree
sleep 1
echo $(whoami)
echo "[CONFIG] installation for $USER"
echo "Please enter the e-mailaddress of the current employee?"
read email_employee
echo "We are creating config files for: $email_employee on MacOS"
echo "Please enter the employee initials, example: Name is John Doe, fill in JD"
read computerName

if [ "$computerName" != "" ] ;then
	$(sudo scutil --set ComputerName "DBP-"$computerName)
	$(sudo scutil --set LocalHostName "DBP-"$computerName)
fi

echo "Do you want to add an default Admin account, select (y/n)?"
read default_admin

if [ "$default_admin" != "${default_admin#[Yy]}" ] ; then
	
	adminpass=
	echo "Fill in a password for the default Admin"
	while [[ $adminpass == "" ]]; do
		read adminpass
	done

	if [ "$adminpass" != "" ] ; then
		$(sudo dscl . -create /Users/beheer)
		$(sudo dscl . -create /Users/beheer UserShell /bin/bash)
		$(sudo dscl . -create /Users/beheer RealName Beheer)
		$(sudo dscl . -create /Users/beheer UniqueID 1337)
		$(sudo dscl . -create /Users/beheer PrimaryGroupID 1000)
		$(sudo dscl . -create /Users/beheer NFSHomeDirectory /Users/beheer)
		$(sudo dscl . -passwd /Users/beheer "$adminpass")
		$(sudo dscl . -append /Groups/admin GroupMembership beheer)	
		
	fi
	
	echo "Admin succesfully created"
fi

echo  "Do you want to install default DBP applications $email_employee select (y/n)?"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo "Hold your seat..! \n"
    echo -ne 'Prepare: Google Chrome, Drive, Chat, MS Remote desktop, teamviewer, Spotify and many more...\n'
    sleep 2
    echo -ne '#                         (2%)\r'
    sleep 1
    echo -ne '#############             (66%)\r'
    sleep 1
    echo -ne '#######################   (100%)\r'
    echo -ne '\n'
    brew install --cask google-chrome
    brew install --cask google-drive
    brew install --cask google-chat
    brew install --cask microsoft-remote-desktop
    brew install --cask teamviewer
    brew install --cask spotify
    brew install --cask vlc

    echo -ne '#############             (66%)\r'
    sleep 1
    echo -ne '#######################   (100%)\r'
    echo -ne '\n'
    rdpconfigfile=/Applications/M-RDP-config/eLive-WerkplekOnline.rdp
    if [ -f "$rdpconfigfile" ]; then
        echo "RDP config exists."
    else 
        echo "RDP config does not exist."
        echo "So lets create some configs!"
        echo -ne '#################         (81%)\r'
        sleep 1
        echo -ne '#######################   (100%)\r'
        echo -ne '\n'
        mkdir /Applications/M-RDP-config && touch $rdpconfigfile
        
        cat <<< "smart sizing:i:0
armpath:s:
targetisaadjoined:i:0
hubdiscoverygeourl:s:
redirected video capture encoding quality:i:0
camerastoredirect:s:
gatewaybrokeringtype:i:0
use redirection server name:i:0
alternate shell:s:
disable themes:i:0
geo:s:
disable cursor setting:i:1
remoteapplicationname:s:
resourceprovider:s:
disable menu anims:i:1
remoteapplicationcmdline:s:
promptcredentialonce:i:0
gatewaycertificatelogonauthority:s:
audiocapturemode:i:0
prompt for credentials on client:i:0
gatewayhostname:s:desktop.elive.nl
remoteapplicationprogram:s:
gatewayusagemethod:i:2
screen mode id:i:2
use multimon:i:0
authentication level:i:2
desktopwidth:i:0
desktopheight:i:0
redirectsmartcards:i:0
redirectclipboard:i:1
forcehidpioptimizations:i:0
full address:s:eli-ts-dbp.elive.nl:3389
drivestoredirect:s:*
loadbalanceinfo:s:
networkautodetect:i:1
enablecredsspsupport:i:1
redirectprinters:i:1
autoreconnection enabled:i:1
session bpp:i:32
administrative session:i:0
audiomode:i:0
bandwidthautodetect:i:1
authoring tool:s:
connection type:i:7
remoteapplicationmode:i:0
disable full window drag:i:0
gatewayusername:s:$email_employee
dynamic resolution:i:0
shell working directory:s:
wvd endpoint pool:s:
remoteapplicationappid:s:
username:s:$email_employee
allow font smoothing:i:1
connect to console:i:0
disable wallpaper:i:0
gatewayaccesstoken:s:" > $rdpconfigfile
        cat $rdpconfigfile

    fi

else
    echo "Clean installation without apps!"
fi

sleep 1

LOGGED_USER=`stat -f%Su /dev/console` 
sudo su $LOGGED_USER -c 'defaults delete com.apple.dock persistent-apps' 

dock_item() { 
    printf "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>", "$1" 
} 

chrome=$(dock_item /Applications/Google Docs.app) 
docs=$(dock_item /Applications/Google Docs.app)
sheets=$(dock_item /Applications/Google Sheets.app) 
slides=$(dock_item /Applications/Google Slides.app) 
drive=$(dock_item /Applications/Google Drive.app) 
teamviewer=$(dock_item /Applications/TeamViewer.app)
msrdp=$(dock_item /Applications/Microsoft Remote Desktop.app) 
spotify=$(dock_item /Applications/Spotify.app)

sudo su $LOGGED_USER -c "defaults write com.apple.dock persistent-apps -array-add '$chrome' '$docs' '$sheets' '$slides' '$drive' '$teamviewer' '$msrdp' '$spotify'"; killall Dock 

echo "Preparing system essentials\n"
sleep 1
echo "Turn on firewall\n"
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 

echo -ne 'Closing installer and prepare to work\n'
sleep 2
killall terminal
