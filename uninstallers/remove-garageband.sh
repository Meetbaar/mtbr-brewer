#!/bin/bash

######################
### make it pretty ###
######################

if [ -t 1 ]; then
    BLACK=$(tput setaf 0)
    BLUE=$(tput setaf 4)
    BOLD=$(tput bold)
    CYAN=$(tput setaf 6)
    GREEN=$(tput setaf 2)
    MAGENTA=$(tput setaf 5)
    RED=$(tput setaf 1)
    RESET=$(tput sgr0)
    UNDERLINE=$(tput smul)
    WHITE=$(tput setaf 7)
    YELLOW=$(tput setaf 3)
else
    BLACK=""
    BLUE=""
    BOLD=""
    CYAN=""
    GREEN=""
    MAGENTA=""
    RED=""
    RESET=""
    UNDERLINE=""
    WHITE=""
    YELLOW=""
fi

export BLACK
export BLUE
export BOLD
export CYAN
export GREEN
export MAGENTA
export RED
export RESET
export UNDERLINE
export WHITE
export YELLOW

###############
### helpers ###
###############

header() {
    printf "\n%s%s" "${BOLD}" "${BLUE}"
    printf "===========================================================\n"
    printf " (⌐■_■) %s\n" "$1"
    printf "===========================================================\n"
    printf "%s" "${RESET}"
}

sub_header() {
    printf "\n%s%s...%s\n" "${BOLD}" "$1" "${RESET}"
}

not_found() {
    printf "%s%s[not found]%s " "${BOLD}" "${GREEN}" "${RESET}"
}

deleted() {
    printf "%s%s[deleted]%s " "${BOLD}" "${YELLOW}" "${RESET}"
}

terminated() {
    printf "%s%s[terminated]%s " "${BOLD}" "${RED}" "${RESET}"
}

###################
### prompt user ###
###################

loggedInUser=$(stat -f "%Su" /dev/console)

# prompt the user for their password if required
printf "\n%sPlease Note:%s This script will prompt for your password if you are not already running as sudo.\n" "${BOLD}" "${RESET}"

sudo -v

####################
### kill process ###
####################

header "Garageband Application"

sub_header "Checking to see if the garageband process is running"

if pgrep -i "garageband" &>/dev/null; then

    sudo kill "$(pgrep -i garageband)"
    terminated
    printf "Garageband process\n"

else

    not_found
    printf " Garageband process\n"

fi

##########################
### remove application ###
##########################

sub_header "Removing the Garageband Application"

declare -a GB_APPLICATION=(
    /Applications/GarageBand.app
    /Users/"$loggedInUser"/Applications/GarageBand.app
)

for ENTRY in "${GB_APPLICATION[@]}"; do
    if [ -f "${ENTRY}" ] || [ -d "${ENTRY}" ]; then
        sudo rm -rf "${ENTRY}"
        deleted
        printf "  %s\n" "${ENTRY}"
    else
        not_found
        printf "%s\n" "${ENTRY}"
    fi
done

exit 0
