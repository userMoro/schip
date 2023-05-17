#!/bin/bash

################################################################################################
#COLORI

text() {

  text() {
  style=0
  if [[ "$1" == "bold" ]]; then
    style=1
  elif [[ "$1" == "underlined" ]]; then
    style=4
  elif [[ "$1" == "italics" ]]; then
    style=3
  fi

  color=37
  if [[ "$2" == "red" ]]; then
    color=31
  elif [[ "$2" == "yellow" ]]; then
    color=33
  elif [[ "$2" == "green" ]]; then
    color=32
  elif [[ "$2" == "blue" ]]; then
    color=34
  else 
    color=37
  fi

  if [[ -z "$4" ]]; then
    echo -e "\033[${style};${color}m$3\033[0m"
  elif [[ "$4" == "-n" ]]; then
    echo -e -n "\033[${style};${color}m$3\033[0m"
  else
    echo -e "\033[${style};${color}m$3\033[0m"
  fi
}

# Usage: text "style" "color" "string" "-n"

}



################################################################################################à
#VARIABILI

osck=0
depck=0
depckR=0
repock=0
chiptoolck=0
submoduleck=0
envck=0
someappck=0
appck=0

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

################################################################################################
#FUNZIONI OPERATIVE

function set_nodeID(){
  while true
    nodeID=""
    echo ""
    read -e -p "set the nodeID to use : " nodeID
    do
      if [[ "$nodeID" =~ ^[0-9]+$ ]]; then
        break
      else
        echo "nodeID must be a number"
      fi
    done
  echo $nodeID
}

################################################################################################
#FUNZIONI DI CHECK

function os_check(){
  os=$(lsb_release -ds)
  if [[ $os == *"Ubuntu"* ]]; then
      osck=2
  fi
  if [[ $os == *"Ubuntu 20.04"* ]] || [[ $os == *"Ubuntu 22.04"* ]]; then
      osck=1
  fi
}

function dep_check(){

  #checking common required packkages
  if [[ "$1" == "all" || "$1" == "controller" ]]; then
    for package in "${REQUIRED_PACKAGES[@]}"; do
      if ! dpkg -s "$package" >/dev/null 2>&1; then
        MISSING_REQUIRED+=("$package")
      fi
    done
    if [[ "${#MISSING_REQUIRED[@]}" -eq 0 ]]; then #nothing is missing
      depck=1
    elif [[ "${#MISSING_REQUIRED[@]}" -gt 0 && "${#MISSING_REQUIRED[@]}" -lt "${#REQUIRED_PACKAGES[@]}" ]]; then #something is missing
      depck=2
    fi
  fi

  #checking raspberry pi required packages
  if [[ "$1" == "all" || "$1" == "device" ]]; then
    for package in "${RASP_PACKAGES[@]}"; do
      if ! dpkg -s "$package" >/dev/null 2>&1; then
        MISSING_RASP+=("$package")
      fi
    done
    if [[ "${#MISSING_RASP[@]}" -eq 0 && "${#MISSING_REQUIRED[@]}" -eq 0 ]]; then #nothing is missing
      depckR=1
    elif [[ "${#MISSING_RASP[@]}" -gt 0 && "${#MISSING_RASP[@]}" -lt "${#RASP_PACKAGES[@]}" ]]; then #something is missing
      depckR=2
    fi
  fi
}

function repo_check(){
  if [ -d connectedhomeip ]; then
    repock=1
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
        git clone https://github.com/project-chip/connectedhomeip.git;
        text "bold" "\nCONNECTEDHOMEIP CLONED\n\n" "green" ""
        cd connectedhomeip
        echo "...checking out at v1.0.0..."
        git checkout v1.0.0;
        text "bold" "DONE\n\n" "green" ""
      fi
    fi
}

function chiptool_check(){
  if ! [ -d out ]; then
    chiptoolck=1
  fi
}

function submodule_check(){
  cd connectedhomeip
  num_submodules=$(git submodule status | grep -c "^ ")
  num_total_submodules=$(git submodule status | wc -l)
  if [ $num_submodules -eq $num_total_submodules ]; then
    submoduleck=1
  fi
  if [[ $num_submodules != 0 && $num_submodules != $num_total_submodules ]]; then
    submoduleck=2
  fi
  for submodule in $(git submodule status --recursive | awk '{print $2}')
  do
    if [ -d "$submodule" ]
    then
      installed_submodules+=("$submodule")
    else
      missing_submodules+=("$submodule")
    fi
  done
}

function app_check(){
  if [[ $1 == "all" ]]; then
    for app in connectedhomeip/examples; do
      if [[ -d $app/linux/out ]]; then
        someappck=2
      fi
    done
    if [[ -d connectedhomeip/examples/lighting-app/linux/out ]]; then
      someappck=1
    fi
  else 
    if [[ -d connectedhomeip/examples/$1/linux/out ]]; then
      appck=1
    fi
  fi
}

################################################################################################
#FUNZIONI DI ESECUZIONE

function schip_help() { # implementazione della funzione schip -h

  

  text "" "blue" "____________________________________________________________________________________________________________________________________" 
  text "underlined" "blue" "\nDESCRIPTION:                                                                                                                        "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  echo -n "schip is used to simplify the setup, building and usage of controller and device matter examples from connectedhomeip repository;"
  text "" "blue" " |\n| " "-n"
  echo -n "The controller is meant to run on linux and it is capable to pair and send messages of onoff type to the device.                 "
  text "" "blue" " |\n| " "-n"
  echo -n "The device is meant to function on linux on a raspberryPi, and the tested application in 'lighting-app', on which is possible to "
  text "" "blue" " |\n| " "-n"
  echo -n "trigger a led pinned on to the raspberryPi.                                                                                      "
  text "" "blue" " |\n|" "-n"
  text "underlined" "blue" "                                                                                                                                   |"
  echo ""


  text "underlined" "blue" "\nUSAGE:                                                                                                                              "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -h / --help                                                                                                                " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "schip guide: description, usage and parameters                                                                                   " "-n"
  
  text "" "blue" " | "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -b / --begin                                                                                                               " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and shows status of all the prerequisites                                                                                  " "-n"
  
  text "" "blue" " | "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -u -s / --update --submodules                                                                                              " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update connectedhomeip's submodules (same for both controller and device)                                               " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -u -l -c / --update --libreries --controller                                                                               " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update dependencies for controller                                                                                      " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -u -l -d / --update --libreries --device                                                                                   " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update dependencies for device                                                                                          " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -u -a -c / --update --all --controller                                                                                     " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update prerequisites for controller                                                                                     " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -u -a -d / --update --all --device                                                                                         " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update prerequisites for device                                                                                         " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -c [nodeID] / --pair --controller [nodeID]                                                                              " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "starts pairing with : '[nodeID], pincode 20202021, discriminator 3840' (if prerequisites satysfied)                               " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -c [nodeID] [pinCode] [discriminator] / --pair --controller [nodeID] [pinCode] [discriminator]                          " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "starts pairing with : '[nodeID], [pincode], [discriminator]' (if prerequisites satysfied)                                         " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -d -l / --pair --device --led                                                                                           " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "Pair device or receive commands translated for led. Default example application used is lighting-app (if prerequisites satysfied) " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -d -n / --pair --device --n                                                                                             " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "Pair device or receive commands showing logs. Default example application used is lighting-app (if prerequisites satysfied)       " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -d -s / --pair --device --select                                                                                        " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "Pair device or receive commands for selected example application (if prerequisites satysfied)                                     " "-n"


  text "" "blue" "|\n|" "-n"
  text "underlined" "blue" "                                                                                                                                   |"

  echo -e "\n"
}

function schip_begin { # implementazione della funzione schip -b 

  #controllo dprerequisiti
  os_check
  dep_check "all"
  repo_check
  chiptool_check
  submodule_check
  app_check "all"
  app_check "lighting-app"

  #checklist
  echo -e "\nTo use Matter to control a device running an example application, you need a functioning controller and device."
  text "bold" "" "\nThe prerequisite needed to build an example app (on Raspberry Pi device) and a controller (Linux) to use it are:\n"
  text "bold" "" "The prerequisite needed to build an example app (on Raspberry Pi device) and a controller (Linux) to use it are:\n"

  text "italics" "" "- Ubuntu 20.04/22.04 LTS" "-n"
  if [[ $osck -eq 1 ]]; then
    text "bold" "green" " ✓"
  elif [[ $osck -eq 2 ]]; then
    text "bold" "yellow" " ✗"
  else
    text "bold" "red" " ✗"
  fi
  echo ""

  text "italics" "" "- Required dependencies installed" "-n"
  if [[ $depck -eq 1 ]]; then
    MISSING_REQUIRED=()
    text "bold" "green" " ✓"
  elif [[ $depck -eq 2 ]]; then
    text "bold" "yellow" " ✗"
  else
    text "bold" "red" " ✗"
  fi
  echo ""

  text "italics" "" "- Connectedhomeip repository cloned" "-n"
  if [[ $repock -eq 1 ]]; then 
    text "bold" "green" " ✓"
  else 
    text "bold" "red" " ✗"
  fi
  echo ""

  text "italics" "" "- Updated submodules" "-n"
  if [[ $submoduleck -eq 1 ]]; then
    text "bold" "green" " ✓"
  elif [[ $submoduleck -eq 2 ]]; then
    text "bold" "yellow" " ✗"
  else
    text "bold" "red" " ✗"
  fi
  echo ""

  text "italics" "" "- Chip-tool executable (for controller)" "-n" 
  if [[ $chiptoolck -eq 1 ]]; then
    text "bold" "green" " ✓"
  else
    text "bold" "red" " ✗"
  fi
  echo ""

  text "italics" "" "- RaspberryPi dependencies installed" "-n"
  if [[ $depckR -eq 1 ]]; then
    MISSING_RASP=()
    text "bold" "green" " ✓"
  elif [[ $depckR -eq 2 ]]; then
    text "bold" "yellow" " ✗"
  else
    text "bold" "red" " ✗"
  fi
  echo ""

  text "italics" "" "- some executable example apps (for raspberry device) builded" "-n"
  if [[ $someappck -eq 1 ]]; then
    text "bold" "green" " ✓"
  elif [[ $someappck -eq 2 ]]; then
    text "bold" "yellow" " ✓"
  else 
    text "bold" "red" " ✗"
  fi
  echo -e ""

  text "italics" "" "- lighting-app example (for raspberry device) builded" "-n"
  if [[ $someapp -eq 1 ]]; then
    text "bold" "green" " ✓"
  else
    text "bold" "red" " ✗"
  fi
  echo -e ""

  text "italics" "" "- Matter environment activated" "-n"
  if [[ $envck -eq 1 ]]; then
    text "bold" "green" " ✓"
  else
    text "bold" "yellow" " ?"
  fi
  echo -e "\n"

}

function schip_update_all { # implementazione della funzione schip -u -a -c

  echo -e "\n...checking prerequisites...\n"

  #checking connectedhomeip folder
  repo_check
  if [[ $repock -eq 0 ]]; then
    repo_clone
    text "bold" "" "check your controller prerequisites again with 'schip -u -a -c'\n"
  elif [[ $repock -eq 1 ]]; then
    text "" "green" "connectedhomeip folder found\n\n"
    text "" "green" "connectedhomeip folder found\n"

    #checking dependecies
    dep_check $1
    some_missing=false
    
    #for device
    if [[ $1 == "device" ]]; then
      if [[ $depck -eq 2 || $depckR -eq 2 ]]; then
        text "" "yellow" "some reqired dependencies are missing:"
        some_missing=true
      elif [[ $depck -eq 0 && $depckR -eq 0 ]]; then
        text "" "red" "you are missing all the required dependencies!:"
        some_missing=true
      fi 
      if [[ $some_missing == true ]]; then
        for i in "${MISSING_REQUIRED[@]}"; do
            text "" "" "-$i"
        done
        for i in "${MISSING_RASP[@]}"; do
            text "" "" "-$i"
        done
        echo ""
      fi

    #for controller
    elif [[ $1 == "controller" ]]; then
      if [[ $depck -eq 2 ]]; then
        text "" "yellow" "some dependencies are missing:"
        some_missing=true
      elif [[ $depck -eq 0 ]]; then
        text "" "red" "you are missing all the required dependencies:"
        some_missing=true
      fi
      if [[ $some_missing == true ]]; then
        for i in "${MISSING_REQUIRED[@]}"; do
            text "" "" "-$i"
        done
        echo ""
      fi
    fi

    if [[ $some_missing == false ]]; then
      text "" "green" "all required dependencies already installed\n"
    fi

    #checking submodules
    submodule_check
    if [[ $submoduleck -eq 1 ]]; then
      text "" "green" "all submodules already up to date\n"
    elif [[ $submoduleck -eq 0 ]]; then
      text "" "red" "you are missing all the required submodules!\n"
    else 
      text "" "yellow" "some submodules are missing:\n"
      for i in "${MISSING_SUBMODULES[@]}"; do
        text "" "" "-$i"
      done
    fi

    #considerations
    if [[ $some_missing == false && $submoduleck -eq 1 ]]; then
      text "" "" "It seems like you got all the prerequisites. You may consider updating, just to make sure.\n"
    else
      text "bold" "" "update submodules and dependencies?"
      echo -n -e "Depending on the number of submodules that need to be updated,\nthis operation may take a considerable amount of " 
      text "bold" "" "time" "-n"
      echo -n " and "
      text "bold" "" "disk space"
    fi
    
    #call to action for updates
    read -p "update? (yes)  " update
    if [[ "$update" == "yes" ]]; then
      echo -e "\n...updating submodules...\n"
      git submodule update --init;
      text "" "green" "SUBMODULES UPDATED!\n"
      submoduleck=1
      sleep 1.5s
      echo -e "...checking dependencies...\n"
      sudo apt-get install git gcc g++ pkg-config libssl-dev libdbus-1-dev libglib2.0-dev libavahi-client-dev ninja-build python3-venv python3-dev python3-pip unzip libgirepository1.0-dev libcairo2-dev libreadline-dev
      text "" "green" "\nDEPENDENCIES UPDATED!"
      depck=1
      sleep 1.5s
    fi

    #checking executable for controller
    if [[ $1 == "controller" ]]; then
      condition=-d out
      if [ $condition == false ]; then
        echo "the chip-tool executable for the controller app is missing."
        read -p "activate anvironment and build executable? (y)" build
        if [ "$build" == "y" ]; then
          ./gn_build.sh;
        fi
      else 
        text "" "green" "\nchip-tool executable found\n"
      fi 

    #checking for executable for lighting app as default and asking if that one is the preferred one or if to use one other
    elif [[ $1 == "device" ]]; then
      cd examples
      condition=-d lighting-app/linux/out
      echo "here's the disposable exaples app for the device:"
      ex_presence=false
      for dir in */; do
        nldir=$(echo "$dir" | sed 's/.$//')
        echo -n "- $nldir"
        app_check $dir
        if [[ $appck -eq 1 ]]; then
          text "bold" "green" " ✓"
          appck=0
          ex_presence=true
        else 
          text "bold" "red" " ✗"
        fi
        done
      if [[ $condition == false ]]; then
        echo -n "the recommanded default example"
        text "bold" "" " lighting-app" "-n"
        echo " is missing.\n"
        read -p "activate anvironment and build the executable for it? (y)" build
        if [ "$build" == "y" ]; then
          cd lighting-app/linux;
          source third_party/connectedhomeip/scripts/activate.sh;
          gn gen out/debug;
          ninja -C out/debug;
        else 
          text "" "red" "\nexecutable for lighting-app not found\n"
      fi

      if [[ -d lighting-app/linux/out ]]; then
        text "" "green" "\nexecutable for lighting-app found\n"
      fi

      #final considerations
    if [[ $some_missing == false && $submoduleck -eq 1 && $condition == true ]]; then
      text "" "" "It seems like you are ready to go. You should be able to use the $1 with:"
      if [[ $1 == "controller" ]]; then
        text "bold" "" "schip -c"
      elif [[ $1 == "device" ]]; then
        text "bold" "" "schip -d"
      fi
    else
      text "" "yellow" "You are still missing some prerequisites. You should consider updating.\n"
    fi
  fi
}

function schip_update_submodules { # implementazione della funzione schip -u -s / --update --submodules
  pass
}

function schip_update_libraries {
  dep_check $1
  echo ""
  text "bold" "" "confirm to install the following missing dependencies? (y)"
  #check if there are elements inside MISSING_REQUIRED and MISSING_RASP
  if [[ ${#MISSING_REQUIRED[@]} -eq 0 ]] && [[ ${#MISSING_RASP[@]} -eq 0 ]]; then
    text "italics" "green" "no missing dependencies found"
  else
    text "bold" "" "confirm to install the following missing dependencies?"
    for req in "${MISSING_REQUIRED[@]}"; do
      text "italics" "" "- $req" 
    done
    if [[ $1 == "device" ]]; then
      for reqr in "${MISSING_RASP[@]}"; do
        text "italics" "" "- $reqr" 
      done
    fi
    text "bold" "" "enter 'y' to confirm"
    read confirm
    if [[ "$confirm" == "y" ]]; then
      sudo apt-get install "${MISSING_REQUIRED[@]}"
      if [[ $1 == "device" ]]; then
        sudo apt-get install "${MISSING_RASP[@]}"
      fi
    fi
  fi
  echo ""
}

function schip_pair_controller {
  pass
    # implementazione della funzione schip -p -c [nodeID] [pinCode] [discriminator] / --pair --controller [nodeID] [pinCode] [discriminator]
}

function schip_pair_device {
  set_nodeID
  echo -e "\npairing = 'p'\nsend commands = 'c'"
  read oper
  while true
  do
    spin='|/-\'
    i=0
    if [[ "$oper" == "p" ]]; then
      echo -e "\n...pairing with node '$nodeID'..."
      cd connectedhomeip/out/debug/standalone
      pwd
      ./chip-tool pairing onnetwork $nodeID 20202021 |
      while IFS= read -r output 
      do
        if [[ $output == *"CHIP Error 0x00000032: Timeout"* ]]; then
          echo -e "\nTIMEOUT"
        elif [[ $output == *"OS Error 0x02000065: Network is unreachable"* ]]; then
          echo -e "\nUNREACHABLE NETWORK"
        else
          oper="c"
        fi
        sleep 0.03s
        printf "\r${spin:i++%${#spin}:1}"
      done
      if [[ "$oper" == "p" ]]; then
        read -p "retry pairing? (y)" retry
        if [[ "$retry" == "y" ]]; then
          continue
        fi
      fi
    fi
    if [[ "$oper" == "c" ]]; then
      echo -e "\n...select an onoff command to send at node $nodeID:"
      while true
      do
        echo -e "\ntoggle = 1\non = 2\noff = 3\nquit = 4"
        read onoff
        if [[ "$onoff" ==  "1" ]]; then
          spec="onoff toggle $nodeID 1"
        elif [[ "$onoff" == "2" ]]; then
          spec="onoff on $nodeID 1"
        elif [[ "$onoff" == "3" ]]; then
          spec="onoff off $nodeID 1"
        elif [[ "$onoff" == "4" ]]; then
          break
        fi
        cd connectedhomeip/out/debug/standalone
        eval "./chip-tool ${spec}" |
        while IFS= read -r outputb
        do
          if [[ $outputb == *"CHIP Error 0x00000032: Timeout"* ]]; then
            echo -e "\nTIMEOUT"
          elif [[ $outputb == *"OS Error 0x02000065: Network is unreachable"* ]]; then
            echo -e "\nUNREACHABLE NETWORK"
          fi
          sleep 0.01s
          printf "\r${spin:i++%${#spin}:1}"
        done
      done
      read -p "try again? (y)" again
      if [[ "$again" != "y" ]]; then
        echo -e "\nset new nodeID = 1\nunpair and quit = 2\n"
        read last
        if [[ "$last" == "1" ]]; then
          read -p "nodeID : " nodeID
        elif [[ "$last" == "2" ]]; then
          echo -e "\n...unpairing '$nodeID'...\n"
          ./chip-tool pairing unpair $nodeID
          break
        fi
      fi
    fi
    echo -e "\npairing = 'p'\nsend commands = 'c'"
    read oper
  done

    # implementazione della funzione schip -p -c [nodeID] / --pair --controller [nodeID]
}

function schip_pair_controller_custom {
  cd connectedhomeip/examples/linux
  echo -e "Seleziona l'esempio che vuoi utilizzare:\n"
  ex=0
  while true
  do
    n=1
    pwd
    cd connectedhomeip/examples
    for dir in */; do
        nldir=$(echo "$dir" | sed 's/.$//')
        echo "$n = $nldir"
        ((n++))
    done
    echo ""
    read -p "insert number: " num
    n=1
    for dir in */
    do
      if [ "$n" == "$num" ]; then
        app=${dir%/}
        echo -e "\n'$app' selected\n"
        ex=1
        break
      fi
      ((n++))
    done
    if [[ "$ex" == 1 ]]; then
      break
    fi
    echo -e "\n!bad input!\n"
  done

  cd $app/linux;
  if ! [ -d out ]; then
    echo "the executable for this app is missing."
    read -p "activate anvironment and build executable? (y)" build
    if [ "$build" == "y" ]; then
      git submodule update --init;
      source third_party/connectedhomeip/scripts/activate.sh;
      gn gen out/debug;
      ninja -C out/debug;
    fi
  fi

  echo ""
  echo "-----------------------------------------------------------------------------------------------------------------------------------"
  if [ "$app" == "lighting-app" ]; then
    echo -e "SELCET AN OPTION:\n-normal pairing = N\n-enable led = L"
    read p_mode
  else 
    p_mode="N"
  fi

  echo ""
  echo "-----------------------------------------------------------------------------------------------------------------------------------"
  if [ "$app" == "lighting-app" ]; then
    echo -e "SELCET AN OPTION:\n-normal pairing = N\n-enable led = L"
    read p_mode
  else 
    p_mode="N"
  fi

  if [ "$p_mode" == "N" ]; then
    out/debug/chip-$app --ble-device 0
  elif [ "$p_mode" == "L" ]; then
    echo -e "\nwaiting for incoming messages..."
    ./out/debug/chip-$app --ble-device 0 |
    while IFS= read -r output; do
      if [ -d "/sys/class/gpio/gpio17" ]; then
        exist=1
      else
        exist=0
      fi
      if [ "$exist" -eq 0 ]; then
        cd /sys/class/gpio
        echo 17 > export
        cd gpio17
        echo out > direction
      fi
      if [[ $output == *"On Command"* ]]; then
        cd /sys/class/gpio/gpio17
        echo 1 >value
        echo "ON received"
      elif [[ $output == *"Off Command"* ]]; then
        cd /sys/class/gpio/gpio17
        echo 0 >value
        echo "OFF received"
      fi
    done
  else 
    echo "bye"
  fi



    # implementazione della funzione schip -p -d / --pair --device
}

################################################################################################
#PARSING

while getopts "ihbcdualps" opt; do
  case ${opt} in
    h)
      schip_help
      ;;
    b)
      schip_begin
      ;;
    u)
      if [[ "$2" == "-a" || "$2" == "--all" ]]; then
          if [[ "$3" == "-c" || "$3" == "--controller" ]]; then
              schip_update_all "device"
          elif [[ "$3" == "-d" || "$3" == "--device" ]]; then
              schip_update_all "controller"
          else
              echo -e "\nInvalid argument for -u: usage: schip -u [tag] [tag]"
              echo -e "try 'schip -h' / 'schip --help'\n"
              exit 1
          fi
      elif [[ "$2" == "-s" || "$2" == "--submodules" ]]; then
          schip_update_submodules
      elif [[ "$2" == "-l" || "$2" == "--libraries" ]]; then
        if [[ "$3" == "-c" || "$3" == "--controller" ]]; then
          schip_update_libraries "controller"
        elif [[ "$3" == "-d" || "$3" == "--device" ]]; then
          schip_update_libraries "device"
        else
          echo -e "\nInvalid argument for -u: usage: schip -u [tag] [tag]"
          echo -e "try 'schip -h' / 'schip --help'\n"
          exit 1
        fi
      else
        echo -e "\nInvalid argument for -u: usage: schip -u [tag] [tag]"
        echo -e "try 'schip -h' / 'schip --help'\n"
        exit 1
      fi
      ;;
    p)
      echo $2
      if [[ "$2" == "-c" || "$2" == "--controller" ]]; then
        echo $2
        schip_pair_device
      elif [[ "$2" == "-d" || "$2" == "--device" ]]; then
          schip_pair_controller_custom 
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

