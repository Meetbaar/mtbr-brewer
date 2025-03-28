#!/bin/bash

# ----------------------
# Grantly Mac Setup Script v2
# Voor Mac Installs M4 staging & onboarding
# ----------------------
clear
CYAN='\033[1;36m'
NC='\033[0m' # Geen kleur

ascii_art='
         _              _           _                   _           _            _    _        _   
        /\ \           /\ \        / /\                /\ \     _  /\ \         _\ \ /\ \     /\_\ 
       /  \ \         /  \ \      / /  \              /  \ \   /\_\\_\ \       /\__ \\ \ \   / / / 
      / /\ \_\       / /\ \ \    / / /\ \            / /\ \ \_/ / //\__ \     / /_ \_\\ \ \_/ / /  
     / / /\/_/      / / /\ \_\  / / /\ \ \          / / /\ \___/ // /_ \ \   / / /\/_/ \ \___/ /   
    / / / ______   / / /_/ / / / / /  \ \ \        / / /  \/____// / /\ \ \ / / /       \ \ \_/    
   / / / /\_____\ / / /__\/ / / / /___/ /\ \      / / /    / / // / /  \/_// / /         \ \ \     
  / / /  \/____ // / /_____/ / / /_____/ /\ \    / / /    / / // / /      / / / ____      \ \ \    
 / / /_____/ / // / /\ \ \  / /_________/\ \ \  / / /    / / // / /      / /_/_/ ___/\     \ \ \   
/ / /______\/ // / /  \ \ \/ / /_       __\ \_\/ / /    / / //_/ /      /_______/\__\/      \ \_\  
\/___________/ \/_/    \_\/\_\___\     /____/_/\/_/     \/_/ \_\/       \_______\/           \/_/  
'

# Optioneel: centreren op scherm (vereist terminal breedte)
terminal_width=$(tput cols)
while IFS= read -r line; do
    padding=$(( (terminal_width - ${#line}) / 2 ))
    printf "%*s" $padding ''
    printf "${CYAN}%s${NC}\n" "$line"
done <<< "$ascii_art"

array=$( system_profiler SPSoftwareDataType )

for i in "${array[@]}"; do
    echo "- $i"
done

osascript -e 'tell application "System Preferences" to quit'
sleep 2

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

    echo "[DONE] Adminaccount '$adminUsername' aangemaakt."
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
    echo "[DONE] Gebruiker '$newUsername' aangemaakt."
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
    *) echo "[ERROR] Ongeldige keuze. Exit."; exit 1 ;;
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
    *) echo "[ERROR] Ongeldige keuze. Exit."; exit 1 ;;
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
    c) prefix="PWRS" ;;
    d) prefix="MTBR" ;;
    *) echo "[ERROR] Ongeldige keuze. Exit."; exit 1 ;;
esac

read -p "Voer initialen in (bv. JD): " UserInnitials
read -p "Voer nummer/iteratie in (bv. 01): " iterationNumber

computerName="$prefix-$ComputerType-$(date +%y)$iterationNumber-$UserInnitials"
sudo scutil --set ComputerName "$computerName"
sudo scutil --set LocalHostName "$computerName"
echo "[DONE] Computernaam ingesteld als $computerName"

# === Homebrew installeren ===
echo "Homebrew installatie..."
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

echo "[DONE] Homebrew is klaar."

# === Wallpaper instellen ===
echo "Wallpaper downloaden..."

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
echo "Installaties voor $UserType"

brew install dockutil

dockutil --remove all --no-restart

if [[ "$UserType" == "Developer" ]]; then
    brew install git node python docker docker-compose gh wget
    brew install --cask google-chrome google-drive google-chat filezilla spotify visual-studio-code postman

    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/Applications/Visual Studio Code.app" --no-restart
    dockutil --add "/System/Applications/Terminal.app" --no-restart

elif [[ "$UserType" == "Server" ]]; then
    brew install nginx docker docker-compose redis postgresql
    brew install --cask iterm2

    dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart
    dockutil --add "/Applications/iTerm.app" --no-restart
    dockutil --add "/System/Applications/Terminal.app" --no-restart

elif [[ "$UserType" == "Overige medewerker" ]]; then
    brew install --cask google-chrome 

    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/System/Applications/Mail.app" --no-restart
    dockutil --add "/System/Applications/Notes.app" --no-restart
    dockutil --add "/Applications/Slack.app" --no-restart
fi

killall Dock

echo "[OK] Setup voltooid voor $UserType op $computerName"
echo "--------------------------------------------"




#!/bin/bash

# ----------------------
# Grantly Mac Setup Script v3
# Voor Mac Installs M4 staging & onboarding (inclusief rollback optie)
# ----------------------

# === Functie: Rollback uitvoeren ===
perform_rollback() {
  echo "[ROLLBACK] Herstellen van systeem naar pre-installatiestatus..."

  # Verwijder gebruikers als aangemaakt
  if id "$adminUsername" &>/dev/null; then
    sudo dscl . -delete /Users/$adminUsername
    echo "[ROLLBACK] Adminaccount '$adminUsername' verwijderd."
  fi

  if id "$newUsername" &>/dev/null; then
    sudo dscl . -delete /Users/$newUsername
    echo "[ROLLBACK] Gebruiker '$newUsername' verwijderd."
  fi

  # Herstel computernaam
  sudo scutil --set ComputerName "Macintosh"
  sudo scutil --set LocalHostName "Macintosh"
  echo "[ROLLBACK] Computernaam hersteld."

  # Verwijder Homebrew (optioneel)
  if [[ -d "/opt/homebrew" ]]; then
    echo "[ROLLBACK] Homebrew verwijderen..."
    sudo rm -rf /opt/homebrew
  fi

  # Verwijder wallpaper indien ingesteld
  if [[ -f "/Library/Desktop Pictures/company-wallpaper.jpg" ]]; then
    sudo rm "/Library/Desktop Pictures/company-wallpaper.jpg"
    echo "[ROLLBACK] Wallpaper verwijderd."
  fi

  # Dock resetten
  dockutil --remove all --no-restart
  killall Dock

  echo "[ROLLBACK] Voltooid."
  exit 0
}

# === Optie voor rollback aanbieden ===
if [[ "$1" == "--rollback" ]]; then
  perform_rollback
fi

# === Verder met setup (oorspronkelijk script start hieronder) ===

# ----------------------
# Grantly Mac Setup Script v3
# Voor Mac Installs M4 staging & onboarding
# ----------------------
clear
CYAN='\033[1;36m'
NC='\033[0m' # Geen kleur

ascii_art='
         _              _           _                   _           _            _    _        _   
        /\ \           /\ \        / /\                /\ \     _  /\ \         _\ \ /\ \     /\_\ 
       /  \ \         /  \ \      / /  \              /  \ \   /\_\\_\ \       /\__ \\ \ \   / / / 
      / /\ \_\       / /\ \ \    / / /\ \            / /\ \ \_/ / //\__ \     / /_ \_\\ \ \_/ / /  
     / / /\/_/      / / /\ \_\  / / /\ \ \          / / /\ \___/ // /_ \ \   / / /\/_/ \ \___/ /   
    / / / ______   / / /_/ / / / / /  \ \ \        / / /  \/____// / /\ \ \ / / /       \ \ \_/    
   / / / /\_____\ / / /__\/ / / / /___/ /\ \      / / /    / / // / /  \/_// / /         \ \ \     
  / / /  \/____ // / /_____/ / / /_____/ /\ \    / / /    / / // / /      / / / ____      \ \ \    
 / / /_____/ / // / /\ \ \  / /_________/\ \ \  / / /    / / // / /      / /_/_/ ___/\     \ \ \   
/ / /______\/ // / /  \ \ \/ / /_       __\ \_\/ / /    / / //_/ /      /_______/\__\/      \ \_\  
\/___________/ \/_/    \_\/\_\___\     /____/_/\/_/     \/_/ \_\/       \_______\/           \/_/  
'

# Optioneel: centreren op scherm (vereist terminal breedte)
terminal_width=$(tput cols)
while IFS= read -r line; do
    padding=$(( (terminal_width - ${#line}) / 2 ))
    printf "%*s" $padding ''
    printf "${CYAN}%s${NC}\n" "$line"
done <<< "$ascii_art"

array=$( system_profiler SPSoftwareDataType )

for i in "${array[@]}"; do
    echo "- $i"
done

#SysPref close ===
osascript -e 'try
tell application "System Preferences" to quit
end try
try
tell application "System Settings" to quit
end try'

# === Hulpfunctie voor dynamische UniqueID ===
get_next_uid() {
  dscl . -list /Users UniqueID | awk '{print $2}' | sort -n | tail -1 | awk '{print $1+1}'
}

# === Adminaccount aanmaken ===
read -p "Wil je een adminaccount aanmaken? (y/n): " createAdmin
if [[ "$createAdmin" == "y" ]]; then
    read -p "Voer naam in voor admingroep (bv. Admins): " adminGroup
    read -p "Voer gebruikersnaam in voor adminaccount: " adminUsername
    read -s -p "Voer wachtwoord in voor adminaccount: " adminPassword
    echo

    adminUID=$(get_next_uid)
    sudo dscl . -create /Groups/$adminGroup
    sudo dscl . -create /Users/$adminUsername
    sudo dscl . -create /Users/$adminUsername UserShell /bin/zsh
    sudo dscl . -create /Users/$adminUsername RealName "$adminUsername"
    sudo dscl . -create /Users/$adminUsername UniqueID "$adminUID"
    sudo dscl . -create /Users/$adminUsername PrimaryGroupID "80"
    sudo dscl . -create /Users/$adminUsername NFSHomeDirectory /Users/$adminUsername
    sudo dscl . -passwd /Users/$adminUsername "$adminPassword"
    sudo dscl . -append /Groups/admin GroupMembership $adminUsername
    echo "[DONE] Adminaccount '$adminUsername' aangemaakt."
fi

# === Gewone gebruiker aanmaken ===
read -p "Wil je een gewone gebruiker aanmaken? (y/n): " createUser
if [[ "$createUser" == "y" ]]; then
    read -p "Voer gebruikersnaam in: " newUsername
    read -s -p "Voer wachtwoord in: " newPassword
    echo

    userUID=$(get_next_uid)
    sudo dscl . -create /Users/$newUsername
    sudo dscl . -create /Users/$newUsername UserShell /bin/zsh
    sudo dscl . -create /Users/$newUsername RealName "$newUsername"
    sudo dscl . -create /Users/$newUsername UniqueID "$userUID"
    sudo dscl . -create /Users/$newUsername PrimaryGroupID "20"
    sudo dscl . -create /Users/$newUsername NFSHomeDirectory /Users/$newUsername
    sudo dscl . -passwd /Users/$newUsername "$newPassword"
    echo "[DONE] Gebruiker '$newUsername' aangemaakt."
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
    *) echo "[ERROR] Ongeldige keuze. Exit."; exit 1 ;;
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
    *) echo "[ERROR] Ongeldige keuze. Exit."; exit 1 ;;
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
    c) prefix="PWRS" ;;
    d) prefix="MTBR" ;;
    *) echo "[ERROR] Ongeldige keuze. Exit."; exit 1 ;;
esac

read -p "Voer initialen in (bv. JD): " UserInnitials
read -p "Voer nummer/iteratie in (bv. 01): " iterationNumber

computerName="$prefix-$ComputerType-$(date +%y)$iterationNumber-$UserInnitials"
sudo scutil --set ComputerName "$computerName"
sudo scutil --set LocalHostName "$computerName"
echo "[DONE] Computernaam ingesteld als $computerName"

# === Homebrew installeren ===
echo "Homebrew installatie..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile

sudo dseditgroup -o create brewadmin
sudo dseditgroup -o edit -a $adminUsername -t user brewadmin
sudo chown -R root:brewadmin /opt/homebrew
sudo chmod -R 770 /opt/homebrew

brew analytics off
brew update && brew upgrade && brew doctor

echo "[DONE] Homebrew is klaar."

# === Wallpaper instellen ===
echo "Wallpaper downloaden..."

case $companyInput in
    a) wallpaperURL="https://bedrijf.com/assets/wallpapers/grantly.jpg" ;;
    b) wallpaperURL="https://bedrijf.com/assets/wallpapers/hsl.jpg" ;;
    c) wallpaperURL="https://bedrijf.com/assets/wallpapers/pwrstaff.jpg" ;;
    d) wallpaperURL="https://bedrijf.com/assets/wallpapers/meetbaar.jpg" ;;
esac

wallpaperPath="/Library/Desktop Pictures/company-wallpaper.jpg"
curl -L "$wallpaperURL" -o /tmp/company-wallpaper.jpg
sudo cp /tmp/company-wallpaper.jpg "$wallpaperPath"
osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$wallpaperPath\""
rm /tmp/company-wallpaper.jpg

# === Conditional software install ===
echo "Installaties voor $UserType"

brew install dockutil
dockutil --remove all --no-restart

if [[ "$UserType" == "Developer" ]]; then
    brew install git node python docker docker-compose gh wget
    brew install --cask google-chrome google-drive google-chat filezilla spotify visual-studio-code postman

    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/Applications/Visual Studio Code.app" --no-restart
    dockutil --add "/System/Applications/Terminal.app" --no-restart

    if command -v code &> /dev/null; then
      code --install-extension esbenp.prettier-vscode
      code --install-extension dbaeumer.vscode-eslint
      code --install-extension ms-vscode.vscode-typescript-next
      code --install-extension github.copilot
    fi

elif [[ "$UserType" == "Server" ]]; then
    brew install nginx docker docker-compose redis postgresql
    brew install --cask iterm2

    dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart
    dockutil --add "/Applications/iTerm.app" --no-restart
    dockutil --add "/System/Applications/Terminal.app" --no-restart

elif [[ "$UserType" == "Overige medewerker" ]]; then
    brew install --cask google-chrome 

    dockutil --add "/Applications/Google Chrome.app" --no-restart
    dockutil --add "/System/Applications/Mail.app" --no-restart
    dockutil --add "/System/Applications/Notes.app" --no-restart
    dockutil --add "/Applications/Slack.app" --no-restart
fi

if [[ "$USER" == "$newUsername" ]]; then
  killall Dock
fi

echo "[OK] Setup voltooid voor $UserType op $computerName"
echo "--------------------------------------------"

