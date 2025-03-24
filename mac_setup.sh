#!/bin/bash

# ----------------------
# Grantly Mac Setup Script v2
# Voor Mac Mini M4 staging & onboarding
# ----------------------

clear
echo "🚀 Grantly Setup Script v2 - Let's go!"
echo "--------------------------------------"

# === Adminaccount aanmaken ===
read -p "Wil je een adminaccount aanmaken? (y/n): " createAdmin
if [[ "$createAdmin" == "y" ]]; then
    read -p "Voer naam in voor admingroep (bv. Admins): " adminGroup
    read -p "Voer gebruikersnaam in voor adminaccount: " adminUsername
    read -s -p "Voer wachtwoord in voor adminaccount: " adminPassword
    echo

    sudo dscl . -create /Groups/$adminGroup
    sudo dscl . -create /Users/$adminUsername
    sudo dscl . -create /Users/$adminUsername UserShell /bin/zsh
    sudo dscl . -create /Users/$adminUsername RealName "$adminUsername"
    sudo dscl . -create /Users/$adminUsername UniqueID "550"
    sudo dscl . -create /Users/$adminUsername PrimaryGroupID "80"
    sudo dscl . -create /Users/$adminUsername NFSHomeDirectory /Users/$adminUsername
    sudo dscl . -passwd /Users/$adminUsername "$adminPassword"
    sudo dscl . -append /Groups/admin GroupMembership $adminUsername

    echo "✅ Adminaccount '$adminUsername' aangemaakt."
fi

# === Gewone gebruiker aanmaken ===
read -p "Wil je een gewone gebruiker aanmaken? (y/n): " createUser
if [[ "$createUser" == "y" ]]; then
    read -p "Voer gebruikersnaam in: " newUsername
    read -s -p "Voer wachtwoord in: " newPassword
    echo

    sudo dscl . -create /Users/$newUsername
    sudo dscl . -create /Users/$newUsername UserShell /bin/zsh
    sudo dscl . -create /Users/$newUsername RealName "$newUsername"
    sudo dscl . -create /Users/$newUsername UniqueID "551"
    sudo dscl . -create /Users/$newUsername PrimaryGroupID "20"
    sudo dscl . -create /Users/$newUsername NFSHomeDirectory /Users/$newUsername
    sudo dscl . -passwd /Users/$newUsername "$newPassword"
    echo "✅ Gebruiker '$newUsername' aangemaakt."
fi

# === Mac type kiezen ===
echo "Wat voor type Mac is dit?"
echo "a: MacBook Pro"
echo "b: MacBook Air"
echo "c: Mac Mini"
read -p "Keuze (a/b/c): " macTypeInput

case $macTypeInput in
    a) ComputerType="MBP" ;;
    b) ComputerType="MBA" ;;
    c) ComputerType="MMI" ;;
    *) echo "❌ Ongeldige keuze. Exit."; exit 1 ;;
esac

# === Gebruikerstype kiezen ===
echo "Voor welk type medewerker is deze machine?"
echo "a: Server"
echo "b: Developer"
echo "c: Overige medewerker"
read -p "Keuze (a/b/c): " userTypeInput

case $userTypeInput in
    a) UserType="Server" ;;
    b) UserType="Developer" ;;
    c) UserType="Overige medewerker" ;;
    *) echo "❌ Ongeldige keuze. Exit."; exit 1 ;;
esac

# === Bedrijf kiezen ===
echo "Voor welk bedrijf is deze Mac?"
echo "a: Grantly"
echo "b: Het Subsidie Lab"
echo "c: PWRSTAFF"
echo "d: Meetbaar"
read -p "Keuze (a/b/c/d): " companyInput

case $companyInput in
    a) prefix="GRANTLY" ;;
    b) prefix="HSL" ;;
    c) prefix="PWR" ;;
    d) prefix="MTBR" ;;
    *) echo "❌ Ongeldige keuze. Exit."; exit 1 ;;
esac

read -p "Voer initialen in (bv. JD): " UserInnitials
read -p "Voer nummer/iteratie in (bv. 01): " iterationNumber

computerName="$prefix-$ComputerType-$(date +%y)$iterationNumber-$UserInnitials"
sudo scutil --set ComputerName "$computerName"
sudo scutil --set LocalHostName "$computerName"
echo "✅ Computernaam ingesteld als $computerName"

# === Homebrew installeren ===
echo "📦 Homebrew installatie..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

# Alleen admin toegang tot Homebrew
sudo dseditgroup -o create brewadmin
sudo dseditgroup -o edit -a $adminUsername -t user brewadmin
sudo chown -R root:brewadmin /opt/homebrew
sudo chmod -R 770 /opt/homebrew

brew analytics off
brew update && brew upgrade && brew doctor

echo "✅ Homebrew is klaar."

# === Wallpaper instellen ===
echo "🖼️ Wallpaper downloaden..."

case $companyInput in
    a) wallpaperURL="https://bedrijf.com/assets/wallpapers/grantly.jpg" ;;
    b) wallpaperURL="https://bedrijf.com/assets/wallpapers/hsl.jpg" ;;
    c) wallpaperURL="https://bedrijf.com/assets/wallpapers/pwrstaff.jpg" ;;
    d) wallpaperURL="https://bedrijf.com/assets/wallpapers/meetbaar.jpg" ;;
esac

curl -L "$wallpaperURL" -o /tmp/company-wallpaper.jpg
sudo cp /tmp/company-wallpaper.jpg /Library/Desktop\ Pictures/company-wallpaper.jpg
osascript -e 'tell application "System Events" to set picture of every desktop to POSIX file "/Library/Desktop Pictures/company-wallpaper.jpg"'

# === Conditional software install ===
echo "⚙️ Installaties voor $UserType"

brew install dockutil

dockutil --remove all --no-restart

if [[ "$UserType" == "Developer" ]]; then
    brew install git node python docker docker-compose gh wget
    brew install --cask visual-studio-code iterm2 postman

    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/Applications/Visual Studio Code.app" --no-restart
    dockutil --add "/Applications/iTerm.app" --no-restart
    dockutil --add "/System/Applications/Terminal.app" --no-restart
    dockutil --add "/Applications/Slack.app" --no-restart

elif [[ "$UserType" == "Server" ]]; then
    brew install nginx redis postgresql
    brew install --cask iterm2

    dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart
    dockutil --add "/Applications/iTerm.app" --no-restart
    dockutil --add "/System/Applications/Terminal.app" --no-restart

elif [[ "$UserType" == "Overige medewerker" ]]; then
    brew install --cask google-chrome slack zoom microsoft-teams

    dockutil --add "/System/Applications/Safari.app" --no-restart
    dockutil --add "/System/Applications/Mail.app" --no-restart
    dockutil --add "/System/Applications/Notes.app" --no-restart
    dockutil --add "/Applications/Slack.app" --no-restart
fi

killall Dock

echo "🎉 Setup voltooid voor $UserType op $computerName"
echo "--------------------------------------------"
