#!/bin/bash

. ./colors.sh
. ./check.sh
. ./funct.sh

osck=0
depck=0
depckR=0
repock=0
chiptoolck=0
submoduleck=0
envck=0
appck=0
spec_appck=0

REQUIRED_PACKAGES=(
  git
  gcc
  g++
  pkg-config
  libssl-dev
  libdbus-1-dev
  libglib2.0-dev
  libavahi-client-dev
  ninja-build
  python3-venv
  python3-dev
  python3-pip
  unzip
  libgirepository1.0-dev
  libcairo2-dev
  libreadline-dev
)
MISSING_REQUIRED=()

RASP_PACKAGES=(
  pi-bluetooth 
  avahi-utils
)
MISSING_RASP=()

function set_nodeID(){
  echo ""
  read -e -p "set the nodeID to use: " nodeID
  if ! [[ "$nodeID" =~ ^[0-9]+$ ]]; then
    text "bold" "" "\nnodeID" "-n"
    echo -n " setted not valid. Using default value "
    text "bold" "" "'1234'."
    nodeID=1234
  fi
}

function repo_clone(){
  text "" "\n!the chip folder is missing!\n\n" "red" ""
    read -p "clone official connectedhomeip repository from github? (y)" build
    if [ "$build" == "y" ]; then
      echo -e "\nthis operation may take a while and will require a considerable amount of disk space."
      text "bold" "continue? (y)\n" "yellow" ""
      read confirm
      if [[ $confirm == "y" ]]; then
        cd ..
        git clone https://github.com/project-chip/connectedhomeip.git;
        text "bold" "\nCONNECTEDHOMEIP CLONED\n\n" "green" ""
        cd connectedhomeip
        echo -e "...checking out at v1.0.0...\n"
        git checkout v1.0.0;
        text "bold" "DONE\n\n" "green" ""
      fi
    fi
}

while getopts "ihbcdualps" opt; do
  case ${opt} in
    h)
      schip_help
      ;;
    b)
      schip_begin
      ;;
    u)
      if [[ "$2" == "-c" || "$2" == "--controller" ]]; then
          schip_update_all "controller"
      elif [[ "$2" == "-d" || "$2" == "--device" ]]; then
          schip_update_all "device"
      else
          echo -e "\nInvalid argument for -u: usage: schip -u [tag]"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
      fi
      ;;
    p)
      if [[ "$2" == "-c" || "$2" == "--controller" ]]; then
        if [[ $3 == "-l" || $3 == "--log" ]]; then
          schip_pair_controller "log"
        elif [[ -z "$3" ]]; then
          schip_pair_controller
        else 
          echo -e "\nInvalid argument for -p -c: usage: schip -p -c [tag]"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
        fi
      elif [[ "$2" == "-d" || "$2" == "--device" ]]; then
        if [[ $3 == "-l" || $3 == "--log" ]]; then
          schip_pair_device "log"
        elif [[ -z "$3" ]]; then
          schip_pair_device
        else
          echo -e "\nInvalid argument for -p -d: usage: schip -p -d [tag]"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
        fi
      else
          echo -e "\nInvalid argument for -p: usage: schip -p [tag] [tag]"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
      fi
      ;;
  esac
done

#schip -u -a -c / --update --all --controller : (fa update e controlla tutti i prerequisiti e per controller)

#schip -u -a -d / --update --all --device (fa update e controlla tutti i prerequisiti per device

#schip -u -s / --update --submodules : (fa update dei sottomoduli se repo esiste)

#schip -u -l / --u --libreries : (fa update delle librerie necessarie e controlla esistenza repo)

#schip -p -c [nodeID] / --pair --controller [nodeID] : (se prerequisiti presenti prova il pairing con [nodeID], pincode 20202021, discriminator 3840; a seconda del risultato printa azioni consigliate)

#schip -p -c [nodeID] [pinCode] [discriminator] / --pair --controller [nodeID] [pinCode] [discriminator] : ( se prerequisiti presenti prova il pairing con il nodo dato, [pinCode], [discriminator]; a seconda del risultato printa azioni consigliate)

#schip -p -d / --pair --device : (lista applicazioni che possono essere eseguite, fa selezioinare applicazione da eseguire, controlla esistenza file eseguibili: se non esiste eseguibile per app scelta chiede se crearlo e poi lo esegue; per lighting-app permette di scegliere se operare sul led, per le altre mostra i log)



#trovare modo per fare lista di sottomoduli mancanti

