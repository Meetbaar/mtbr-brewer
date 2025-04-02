#!/bin/bash
 
 # ----------------------
 # Grantly Mac Setup Script v4.2
 # Voor Mac Installs M4 staging & onboarding (inclusief rollback optie) nieuw
 # ----------------------
 
 # === Functie: Rollback uitvoeren ===
 perform_rollback() {
   echo "[ROLLBACK] Herstellen van systeem naar pre-installatiestatus..."
 
   if id "$adminUsername" &>/dev/null; then
     sudo dscl . -delete /Users/$adminUsername
     echo "[ROLLBACK] Adminaccount '$adminUsername' verwijderd."
   fi
 
   if id "$newUsername" &>/dev/null; then
     sudo dscl . -delete /Users/$newUsername
     echo "[ROLLBACK] Gebruiker '$newUsername' verwijderd."
   fi
 
   sudo scutil --set ComputerName "Macintosh"
   sudo scutil --set LocalHostName "Macintosh"
   echo "[ROLLBACK] Computernaam hersteld."
 
   if [[ -d "/opt/homebrew" ]]; then
     echo "[ROLLBACK] Homebrew verwijderen..."
     sudo rm -rf /opt/homebrew
   fi
 if [[ -d "/usr/local/homebrew" ]]; then
   echo "[ROLLBACK] Homebrew verwijderen..."
   sudo rm -rf /usr/local/homebrew
 fi
 
 
   if [[ -f "/Library/Desktop Pictures/company-wallpaper.jpg" ]]; then
     sudo rm "/Library/Desktop Pictures/company-wallpaper.jpg"
 @@ -185,97 +186,98 @@
 echo "Homebrew installatie..."
 if ! command -v brew &>/dev/null; then
     echo "[INFO] Homebrew wordt geïnstalleerd..."
     NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   export HOMEBREW_PREFIX="/usr/local/homebrew"
   NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
 else
     echo "[INFO] Homebrew is al geïnstalleerd."
 fi
 
 # Zorg ervoor dat Homebrew goed is ingesteld
 eval "$(/opt/homebrew/bin/brew shellenv)"
 eval "$(/usr/local/homebrew/bin/brew shellenv)"
 
 # Maak Homebrew directory toegankelijk voor de juiste gebruiker
 sudo chown -R $(whoami) /opt/homebrew
 sudo chmod -R 755 /opt/homebrew
 
 brew update --force --quiet
 brew doctor
 
 echo "[DONE] Homebrew is klaar."
 
 # === Wallpaper instellen ===
 echo "Wallpapers downloaden..."
 
 case $companyInput in
     a) wallpaperURL="https://www.grantly.nl/public-img/wall/GRANTLY-macwallpaper.jpg" ;;
     b) wallpaperURL="https://www.grantly.nl/public-img/wall/HSL-macwallpaper.jpg" ;;
     c) wallpaperURL="https://www.grantly.nl/public-img/wall/PWRS-macwallpaper.jpg" ;;
     d) wallpaperURL="https://www.grantly.nl/public-img/wall/GRANTLY-macwallpaper.jpg" ;;
 esac
 
 wallpaperPath="/Library/Desktop Pictures/company-wallpaper.jpg"
 sudo mkdir -p "/Library/Desktop Pictures"
 
 if curl -L "$wallpaperURL" -o /tmp/company-wallpaper.jpg; then
   sudo cp /tmp/company-wallpaper.jpg "$wallpaperPath"
   osascript -e "tell application \"System Events\" to set picture of every desktop to POSIX file \"$wallpaperPath\""
   rm /tmp/company-wallpaper.jpg
 else
   echo "[ERROR] Wallpaper downloaden mislukt voor $companyInput"
 fi
 
 echo "[DONE] Wallpaper gedownload en geinstalleerd."
 sleep 2
 
 # === Conditional software install ===
 echo "Installaties voor $UserType"
 
 brew install dockutil || echo "[WAARSCHUWING] dockutil kon niet worden geïnstalleerd."
 
 if command -v dockutil &> /dev/null; then
   dockutil --remove all --no-restart
 fi
 
 if [[ "$UserType" == "Developer" ]]; then
     brew install docker docker-compose gh wget curl php
     brew install --cask google-chrome google-drive google-chat filezilla spotify visual-studio-code postman
 
     if command -v dockutil &> /dev/null; then
       dockutil --add "/Applications/Google Chrome.app" --no-restart
       dockutil --add "/Applications/Visual Studio Code.app" --no-restart
       dockutil --add "/System/Applications/Terminal.app" --no-restart
     fi
 
     if command -v code &> /dev/null; then
       code --install-extension esbenp.prettier-vscode
       code --install-extension dbaeumer.vscode-eslint
       code --install-extension ms-vscode.vscode-typescript-next
       code --install-extension github.copilot
     fi
 
 elif [[ "$UserType" == "Server" ]]; then
     brew install nginx docker docker-compose redis postgresql
     brew install --cask iterm2
 
     if command -v dockutil &> /dev/null; then
       dockutil --add "/System/Applications/Utilities/Activity Monitor.app" --no-restart
       dockutil --add "/Applications/iTerm.app" --no-restart
       dockutil --add "/System/Applications/Terminal.app" --no-restart
     fi
 
 elif [[ "$UserType" == "Overige medewerker" ]]; then
     brew install --cask google-chrome 
 
     if command -v dockutil &> /dev/null; then
       dockutil --add "/Applications/Google Chrome.app" --no-restart
       dockutil --add "/System/Applications/Mail.app" --no-restart
       dockutil --add "/System/Applications/Notes.app" --no-restart
       dockutil --add "/Applications/Slack.app" --no-restart
     fi
 fi
 
 if [[ "$USER" == "$newUsername" && $(command -v dockutil) ]]; then
   killall Dock
 fi
 
 echo "[OK] Setup voltooid voor $UserType op $computerName"
 echo "--------------------------------------------"
