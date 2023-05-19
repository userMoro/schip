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

function pair_controller() {
  echo -e "\n...pairing with node '$nodeID'..."
  ./chip-tool pairing onnetwork $nodeID 20202021 |
  while IFS= read -r output 
  do
    if [[ $output == *"CHIP Error 0x00000032: Timeout"* ]]; then
      text "" "yellow" "\nTIMEOUT"
    elif [[ $output == *"OS Error 0x02000065: Network is unreachable"* ]]; then
      text "" "yellow" "\nUNREACHABLE NETWORK"
    else
      oper="c"
    fi
    sleep 0.03s
    printf "\r${spin:i++%${#spin}:1}"
  done
}

function command_controller () {
  while true
  do
    spec=""
    text "bold" "" "\ntoggle = 1\non = 2\noff = 3\nset new nodeID / retry pairing = 4\nunpair and quit = 5\n"
    read onoff
    if [[ "$onoff" ==  "1" ]]; then
      spec="onoff toggle $nodeID 1"
    elif [[ "$onoff" == "2" ]]; then
      spec="onoff on $nodeID 1"
    elif [[ "$onoff" == "3" ]]; then
      spec="onoff off $nodeID 1"
    elif [[ "$onoff" == "5" ]]; then
      spec="pairing unpair $nodeID"
    fi
    if [[ $onoff == "1" || $onoff == "2" || $onoff == "3" || $onoff == "5" ]]; then
      echo -n "command "
      text "italics" "" "'$spec'" "-n"
      echo " sent"
      eval "./chip-tool ${spec}" |
      while IFS= read -r outputb
      do
        err=false
        if [[ $outputb == *"CHIP Error 0x00000032: Timeout"* ]]; then
          text "" "yellow" "\nTIMEOUT" 
          err=true
        elif [[ $outputb == *"OS Error 0x02000065: Network is unreachable"* ]]; then
          text "" "red" "\nUNREACHABLE NETWORK"
          err=true
        fi
        sleep 0.01s
        printf "\r${spin:i++%${#spin}:1}"
      done
      if [[ $err == false ]]; then
        text "" "green" "\nDONE\n"
      fi
    elif [[ $onoff == "4" ]]; then
      set_nodeID
      echo ""
      read -p "retry pairing? (y)" retry
      if [[ $retry == "y" ]]; then
        pair_controller
      fi
    fi
    if [[ $onoff == "5" ]]; then
      echo ""
      break
    fi
  done
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

function app_list(){
  cd examples
    spec_appck=0
    n=0
    for dir in */; do
      n=$((n+1))
      sleep 0.02s
      app_check $dir
      if [[ $1 == "green" && $spec_appck -eq 1 ]]; then
        text "" "" "\n$n = $dir" "-n"
      elif [[ $1 == "all" ]]; then
        text "" "" "-$dir" "-n"
      fi
      if [[ $spec_appck == 0 ]]; then
        if [[ $1 == "all" ]]; then
          text "" "red" " ✗"
        fi
      else
        text "" "green" " ✓"
        spec_appck=1
      fi
    done
    n=0
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
          schip_update "controller"
      elif [[ "$2" == "-d" || "$2" == "--device" ]]; then
          schip_update "device"
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
          if [[ -d $5 && -d $6 ]]; then 
            if [[ $4 =~ ^[0-9]{4} && $5 =~ ^[0-9]{8}$ && $6 =~ ^[0-9]{4} ]]; then
              schip_pair_controller "log" $4 $5 $6
            else
              echo -e "\nInvalid argument for -p -c -l [nodeID] [pinCode] [discriminator]: \nnodeID and discriminator have to be a 4 digit number; pinCode has to be a 8 digit number"
              echo -e "try 'schip -h' / 'schip --help'\n"
              exit 1
            fi
          elif [[ -d $4 && -z $5 ]]; then
            if [[ $4 =~ ^[0-9]{4}$ ]]; then
              schip_pair_controller "log" $4
            else
              echo -e "\nInvalid argument for -p -c -l [nodeID]: nodeID has to be a 4 digit number"
              echo -e "try 'schip -h' / 'schip --help'\n"
              exit 1
            fi
          fi
        elif [[ -d $3 && $3 != "-l" && $3 != "--log" && $3 =~ ^[0-9]{4} ]]; then
          schip_pair_controller $3
        else 
          echo -e "\nInvalid argument for -p -c [nodeID]: nodeID has to be a 4 digit number"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
        elif [[ -z "$3" ]]; then
          schip_pair_controller
        fi
      elif [[ "$2" == "-d" || "$2" == "--device" ]]; then
        if [[ $3 == "-l" || $3 == "--led" ]]; then
          schip_pair_device "led"
        elif [[ $3 == "-n" || $3 == "--normal" ]]; then 
          schip_pair_device "normal"
        elif [[ "$3" == "-s" || $3 == "--select" ]]; then
          schip_pair_device_select
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

