#Brewing a DBP Machine installer for clean installs on MacOS
/bin/bash -c "$(curl -fsSL https://github.com/YloXx/dbp-brewer/edit/main/install-poc.sh)"

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

printf 'Do you want to install default DBP applications' $email_employee ' Select (y/n)?'
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

sudo ex +"r /Applications/M-RDP-config" -cwq test-rdp-output.rdp <<-EOF
armpath:s:
targetisaadjoined:i:0
hubdiscoverygeourl:s:
redirected video capture encoding quality:i:0
camerastoredirect:s:
gatewaybrokeringtype:i:0
use redirection server name:i:0
alternate shell:s:
disable themes:i:0
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
gatewayusername:s:email@debreed.nl
shell working directory:s:
wvd endpoint pool:s:
remoteapplicationappid:s:
username:s:email@debreed.nl
allow font smoothing:i:1
connect to console:i:0
disable wallpaper:i:0
gatewayaccesstoken:s:
EOF


#Checkup for the total installed packages on the machine
brew doctor
