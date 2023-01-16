#! /bin/bash

echo system_profiler SPSoftwareDataType

curl -fsSL https://github.com/YloXx/dbp-brewer/edit/main/install-poc.sh

curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

brew install tree

echo "Please enter e-mail employee?"
read email_employee
echo "Install started for user: $email_employee on MacOS"

echo -ne "#####                     (33%)\r"
sleep 1
echo -ne "#########                 (41%)\r"
sleep 1
echo -ne "##################        (73%)\r"
sleep 2
echo -ne "#######################   (100%)\r"
echo -ne "\n"

printf "Do you want to install default DBP applications $email_employee, Select (y/n)?"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
    echo Hold your seat!
    echo -ne 'Prepare: Google Chrome, Drive, Chat, MS Remote desktop, Teamviewer, Spotify and many more...'
    sleep 1
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
else
    echo 'No'
    sleep 5
fi


# Delete obsolete applications
#rm -rf file:///Applications/GarageBand.app
sudo rm –rf /System/Applications/Betaflight Configurator.app
sudo rm –rf /System/Applications/Stocks.app


# config the remote desktop app with setup except credentials

#als de dir niet bestaat aanmaken
mkdir /Applications/M-RDP-config
nano /Applications/M-RDP-config/eLive-WerkplekOnline.rdp


# Dockinstall make shure it is bash and sudo 
LOGGED_USER=`stat -f%Su /dev/console` 
sudo su $LOGGED_USER -c 'defaults delete com.apple.dock persistent-apps' 

dock_item() { 
    printf '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>%s</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>', "$1" 
} 

chrome=$(dock_item /Applications/Google Chrome.app) 
docs=$(dock_item /Applications/Google Docs.app)
sheets=$(dock_item /Applications/Google Sheets.app) 
slides=$(dock_item /Applications/Google Slides.app) 
drive=$(dock_item /Applications/Google Drive.app) 
teamviewer=$(dock_item /Applications/TeamViewer.app)
msrdp=$(dock_item /Applications/TeamViewer.app) 
spotify=$(dock_item /Applications/Spotify.app) 

sudo su $LOGGED_USER -c "defaults write com.apple.dock persistent-apps -array '$chome' '$docs' '$sheets' '$slides' '$drive' '$teamviewer' '$msrdp' '$spotify'" 
killall Dock 


# Checkup for the total installed packages on the machine
brew doctor

# turnon fireall for everyone
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 


