#Brewing a DBP Machine installer for clean installs on MacOS
#/bin/bash -c "$(curl -fsSL https://github.com/YloXx/dbp-brewer/edit/main/install-poc.sh)"

#Get and Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#Install tree
brew install tree

#install employee and applications for employee
echo "Please enter e-mail employee? "
read email_employee
echo "Install started for user: $email_employee on MacOS"

echo -ne '#####                     (33%)\r'
sleep 1
echo -ne '#########                 (41%)\r'
sleep 1
echo -ne '##################        (73%)\r'
sleep 2
echo -ne '#######################   (100%)\r'
echo -ne '\n'

printf "Do you want to install default DBP applications" $email_employee " Select (y/n)?"
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


#delete applications
#delete garageband
#rm -rf file:///Applications/GarageBand.app
rm -rf file:///Applications//Applications/Betaflight\ Configurator.app 


#config the remote desktop app with setup except credentials

#als de dir niet bestaat aanmaken
mkdir /Applications/M-RDP-config
nano /Applications/M-RDP-config/eLive-WerkplekOnline.rdp


#Checkup for the total installed packages on the machine
brew doctor
