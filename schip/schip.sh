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

function read_output(){
  while IFS= read -r output 
  do
    if [[ $output == *"CHIP Error 0x00000032: Timeout"* ]]; then
      end=$output
    elif [[ $output == *"OS Error 0x02000065: Network is unreachable"* ]]; then
      end=$output
    fi
    if [[ $end != "" ]]; then
      break
    else
      oper="c"
    fi
    if [[ $2 == "log" ]]; then 
      echo $output 
    else
      sleep 0.003
      printf "\r${spin:i++%${#spin}:1}"
    fi
  done
  if [[ $end == "" && $1 == "pair" ]]; then
    text "" "green" "\nPAIRING COMPLETED\n"
  elif [[ $end == "" && $1 == "command" ]]; then
    text "" "green" "\ncommand sent\n"
  elif [[ $end != "" ]]; then
    text "" "yellow" "\n$end"
  fi
}

function pair_controller_manage() {
  echo -e "\n...pairing with node '$nodeID'..."
  if [[ $1 == "log" ]]; then
    ./chip-tool pairing onnetwork $nodeID 20202021 |
    read_output "pair" "log"
  elif [[ $3 == "log" ]]; then
    ./chip-tool pairing onnetwork-long $nodeID $1 $2 |
    read_output "pair" "log"
  else
    ./chip-tool pairing onnetwork $nodeID 20202021 |
    read_output "pair"
  fi
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
      if [[ $1 == "log" ]]; then
        read_output "command" "log"
      else 
        read_output "command"
      fi
    elif [[ $onoff == "4" ]]; then
      set_nodeID
      echo ""
      read -p "retry pairing? (y)" retry
      if [[ $retry == "y" ]]; then
        ./chip-tool pairing onnetwork $nodeID 20202021 |
        if [[ $1 == "log" ]]; then
          read_output "pair" "log"
        else 
          read_output "pair"
        fi
      else 
        continue
      fi
    fi
    if [[ $onoff == "5" ]]; then
      echo ""
      break
    fi
  done
}

function repo_clone(){
  text "" "red" "\n!the chip folder is missing!\n\n" ""
    read -p "clone official connectedhomeip repository from github? (y)" build
    if [ "$build" == "y" ]; then
      echo -e "\nthis operation may take a while and will require a considerable amount of disk space."
      text "bold" "" "continue? (y)\n" ""
      read confirm
      if [[ $confirm == "y" ]]; then
        git clone https://github.com/project-chip/connectedhomeip.git;
        text "bold" "green" "\nCONNECTEDHOMEIP CLONED\n" ""
        cd connectedhomeip
        echo -e "...checking out at v1.0.0...\n"
        git checkout v1.0.0;
        text "bold" "green" "\nDONE\n" ""
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

#
while getopts "hbup" opt; do
  case ${opt} in
    h | help) 
      schip_help 
      exit
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
    # controller: - / nodeID / nodeID, log / nodeID, pincode, discriminator / nodeID, pincode, discriminator, log 
      if [[ "$2" == "-c" || "$2" == "--controller" ]]; then
        if [[ $3 =~ ^[0-9]{4} && -z $4 ]]; then
          schip_pair_controller $3
        elif [[ $3 =~ ^[0-9]{4} && ( $4 == "-l" || $4 == "--log" ) ]]; then
          schip_pair_controller $3 "log"
        elif [[ $3 =~ ^[0-9]{4} && $4 =~ ^[0-9]{8} && $5 =~ ^[0-9]{4} && ( ( $6 != "-l" || $6 != "--log") || -z $6 ) ]]; then
          schip_pair_controller $3 $4 $5
        elif [[ $3 =~ ^[0-9]{4} && $4 =~ ^[0-9]{8} && $5 =~ ^[0-9]{4} && ( $6 == "-l" || $6 == "--log" ) ]]; then
          schip_pair_controller $3 $4 $5 "log"
        elif [[ $3 == "-l" || $3 == "--log" ]]; then 
          schip_pair_controller "log"
        elif [[ -z $3 ]]; then
          schip_pair_controller
        else
          echo -e "\nInvalid argument for -p -c / --pair --controller"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
        fi

    # device: - / log
      elif [[ "$2" == "-d" || "$2" == "--device" ]]; then
        if [[ $3 == "-l" || $3 == "--log" ]]; then
          schip_pair_device "log"
        elif [[ "$3" == "-s" || $3 == "--select" ]]; then
          schip_pair_device_select
        elif [[ -z $3 ]]; then
          schip_pair_device
        else
          echo -e "\nInvalid argument for -p -d: usage: schip -p -d [tag]"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
        fi
      else
          echo -e "\nInvalid argument for -p: usage: schip -p [tag] <options>"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
      fi
      ;;
    *)
      echo "Invalid option: -$option $OPTARG"
      exit 1
      ;;
      esac
    done
