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
  
  text "bold" "" "schip -u -c / --update --controller                                                                                              " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update prerequisites for controller                                                                                     " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -u -d / --update --device                                                                                                  " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "check and update prerequisites for device                                                                                         " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -p -c  / --pair --controller                                                                                               " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "pairing and send commands at : 'nodeID:1234, pincode:20202021, discriminator:3840' (if prerequisites satysfied)                   " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"
  
  text "bold" "" "schip -p -c [nodeID]  / --pair --controller [nodeID]                                                                             " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "pairing and send commands at : '[nodeID], pincode:20202021, discriminator:3840' (if prerequisites satysfied)                      " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -c [nodeID] -l  / --pair --controller [nodeID] --log                                                                    " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "pairing and send commands at : '[nodeID], pincode:20202021, discriminator:3840' (if prerequisites satysfied) showing logs         " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -c [nodeID] [pinCode] [discriminator] / --pair --controller [nodeID] [pinCode] [discriminator]                          " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "pairing and send commands at : '[nodeID], [pincode], [discriminator]' (if prerequisites satysfied)                                " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -c [nodeID] [pinCode] [discriminator] -l / --pair --controller [nodeID] [pinCode] [discriminator] --log                 " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "pairing and send commands at : '[nodeID], [pincode], [discriminator]' (if prerequisites satysfied) showing logs                   " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -d / --pair --device                                                                                                    " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "Pair device or receive commands translated for led. Lighting-app is default (if prerequisites satysfied)                          " "-n"

  text "" "blue" "| "
  text "" "blue" "|                                                                                                                                   |"
  text "" "blue" "| " "-n"

  text "bold" "" "schip -p -d -l / --pair --device --log                                                                                           " "-n"
  text "" "blue" " |\n| " "-n"
  text "italics" "" "Pair device or receive commands showing logs. Lighting-app is default (if prerequisites satysfied)                                " "-n"

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
  echo -e "\nChecking prerequisites...\n"
  cd ../connectedhomeip
  os_check
  dep_check "all"
  repo_check
  chiptool_check
  submodule_check
  app_check "lighting-app"

  #checklist
  echo -e "\nTo use Matter to control a device running an example application, you need a functioning controller and device."
  text "bold" "" "The prerequisite needed to build an example app (on Raspberry Pi device) and a controller (Linux) are:\n"

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

  text "italics" "" "- Some executable example apps (for raspberry device) builded" "-n"
  if [[ $appck -eq 1 ]]; then
    if [[ $spec_appck -eq 1 ]]; then
      text "bold" "green" " ✓"
    else 
      text "bold" "yellow" " ✓"
    fi
  elif [[ $appck -eq 0 ]]; then
    text "bold" "red" " ✗"
  fi
  echo -e ""

  text "italics" "" "- Lighting-app example (for raspberry device) builded" "-n"
  if [[ $spec_appck -eq 1 ]]; then
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

function schip_update { # implementazione della funzione schip -u -a -c

  echo -e "\n...checking prerequisites...\n"

  #checking connectedhomeip folder
  repo_check
  if [[ $repock -eq 0 ]]; then
    repo_clone
    text "bold" "" "check your controller prerequisites again with 'schip -u -a -c'\n"
  elif [[ $repock -eq 1 ]]; then
    text "" "green" "connectedhomeip folder found\n"

    #checking dependecies
    dep_check "all"
    some_missing=false

  
    if [[ ( $1 == "device" && ( $depck -eq 2 || $depckR -eq 2 || $depckR -eq 0 ) ) || ( $1 == "controller" && $depck -eq 2 ) ]]; then
      text "" "yellow" "some dependencies are missing:"
      some_missing=true
    elif [[ ( ( $1 == "controller" ) || ( $1 == "device" && $depckR -eq 0 ) ) && $depck -eq 0 ]]; then
      text "" "red" "you are missing all the required dependencies:"
      some_missing=true
    fi
    if [[ $some_missing == true ]]; then
      for i in "${MISSING_REQUIRED[@]}"; do
          text "" "" "-$i"
      done
      if [[ $1 == "device" ]]; then
        for i in "${MISSING_RASP[@]}"; do
          text "" "" "-$i"
        done
      fi
    else
      text "" "green" "all required dependencies already installed"
    fi

    #checking submodules
    submodule_check
    if [[ $submoduleck -eq 1 ]]; then
      text "" "green" "\nall submodules already up to date\n"
    elif [[ $submoduleck -eq 0 ]]; then
      text "" "red" "y\nou are missing all the required submodules!\n"
    else 
      text "" "\nyellow" "some submodules are missing:\n"
      for i in "${MISSING_SUBMODULES[@]}"; do
        text "" "" "-$i"
      done
    fi

    #considerations
    if [[ $some_missing == false && $submoduleck -eq 1 ]]; then
      text "" "" "It seems like you got all the prerequisites. You may consider updating, just to make sure."
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
      chiptool_check
      if [[ $chiptoolck -eq 1 ]]; then
        text "" "green" "\nchip-tool executable found\n"
      else
        text "" "red" "chip-tool executable not found\n"
        read -p "build chip-tool executable? (yes)  " build
        if [[ "$build" == "yes" ]]; then
          ./gn_build.sh;
        fi
      fi
    else #checking executable for device
      echo -e "\nHere's the list of the apps:"
      sleep 0.3s
      app_list "all"
      app_check "lighting-app"
      if [[ $spec_appck -eq 0 ]]; then
        echo -e -n "\nThe recommanded default example"
        text "bold" "" " lighting-app" "-n"
        echo " is missing."
        read -p "activate anvironment and build the executable for it? (y)" build
        if [ "$build" == "y" ]; then
          cd lighting-app/linux;
          source third_party/connectedhomeip/scripts/activate.sh;
          gn gen out/debug;
          ninja -C out/debug;
          app_check "lighting-app"
        fi
      fi
      if [[ $appck -eq 1 ]]; then
        text "" "green" "\nexecutable for lighting-app found\n"
      else 
        text "" "yellow" "executable for lighting-app not found\n"
      fi
      echo -e "\n(not adviced)"
      text "bold" "" "If you want to build any other app, enter the full name here: " "-n"
      read newapp
      match=false
      for dir in */; do
        if [[ $dir == "$newapp/" ]]; then
          match=true
          cd $dir/linux;
          source third_party/connectedhomeip/scripts/activate.sh;
          gn gen out/debug;
          ninja -C out/debug;
          app_check $newapp
        fi
      done
      if [[ $match == false ]]; then
        text "" "yellow" "no matching app found.\n"
      fi
    fi

      #final considerations
    if [[ ( $1 == "device" && $spec_appck == 1 ) || ( $1 == "controller" && $chiptoolck == 1 ) && $submoduleck -eq 1 && $some_missing == false ]]; then
      text "bold" "green" "v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v v"
      text "" "" "It seems like you are ready to go. You should be able to use the $1 with:"
      if [[ $1 == "controller" ]]; then
        text "bold" "" "schip -p -d\n"
      elif [[ $1 == "device" ]]; then
        text "bold" "" "schip -p -d\n"
      fi
    elif [[ $1 == "device" && $spec_appck == 0 && $appck = 1 && $submoduleck -eq 1 && $some_missing == false ]]; then
      text "" "" "You may be good to go, but you are missing the" "-n"
      text "bold" "" " lighting-app" "-n"
      text "" "" " executable which is recommanded. You can still use one other app with:"
      text "bold" "" "schip -d"
    else
      text "" "yellow" "\nYou are still missing some prerequisites. Consider updating.\n"
    fi
  fi
}

function schip_pair_controller { # implementazione dellla funzione schip -p -c
# controller: - / nodeID / nodeID, log / nodeID, pincode, discriminator / nodeID, pincode, discriminator, log 
  text "" "blue" "\nBe sure to have all the prerequisites for the correct functioning of the controller before proceding using " "-n"
  text "bold" "" "schip -b" ""

  if [[ $1 =~ ^[0-9]{4} ]]; then
    nodeID=$1
  else 
    set_nodeID
  fi

  cd ../connectedhomeip/out/debug/standalone
  #set a variable that is true only if the current directory is standalone
  standalone=$(pwd | grep standalone)
  if [[ $standalone == "" ]]; then
    text "" "red" "\nERROR: connectedhomeip missing or not initialized or not in the right position\n"
  else
    echo -e "\npairing = 'p'\nsend commands = 'c'"
    read oper
    if [[ $oper == "p" || $oper == "c" ]]; then
      while true
      do
        if [[ $onoff == "5" ]]; then
          echo ""
          break 
        fi
        spin='|/-\'
        i=0
        if [[ "$oper" == "p" ]]; then
          #check if one of the values given at the function is "log"
          if [[ $1 == "log" || $2 == "log" ]]; then
            pair_controller_manage "log"
          elif [[ $4 == "log" ]]; then
            pair_controller_manage $2 $3 "log"
          else
            pair_controller_manage
          fi
          if [[ "$oper" == "p" ]]; then
            read -p "retry pairing? (y)" retry
          fi
        fi
        if [[ "$oper" == "c" ]]; then
          echo -e "\n...select an onoff command to send at node $nodeID:"
          if [[ $1 == "log" || $2 == "log" || $4 == "log" ]]; then
            command_controller "log"
          else
            command_controller
          fi
        fi
        if [[ $retry != "y" ]]; then
          break
        fi
      done
    fi
  fi
}

function schip_pair_device_select { # implementazione della funzione schip -p -d -s
  text "" "blue" "\nBe sure to have all the prerequisites for the correct functioning of the device before proceding using " "-n"
  text "bold" "" "schip -b" ""
  cd ../connectedhomeip
  echo -e "\nSeleziona l'esempio che vuoi utilizzare:\n"
  ex=0
  while true
  do
    app_check
    if [[ $appck -eq 0 ]]; then
      text "" "yellow" "no app executable found. Consider updating using " "-n"
      text "bold" "" "schip -u -d\n"
      break
    else 
      echo -e "\nHere's the list of the apps:"
      app_list "green"
      echo ""
      read -p "insert number: " num
      n=1
      for dir in */
      do
        if [ $n -eq $num ]; then
          app=${dir%/}
          echo -e "\n'$app' selected\n"
          ex=1
          break
        fi
        ((n++))
      done
      if [[ "$ex" == 1 ]]; then
        ./out/debug/chip-lighting-app --ble-device 0 |
        while IFS= read -r output
        do
          echo $output
        done
      fi
  done
}

function schip_pair_device(){ # implementazione della funzione schip -p -d -n/-l
# device: - / log
  text "" "blue" "\nBe sure to have all the prerequisites for the correct functioning of the controller before proceding using " "-n"
  text "bold" "" "schip -b" ""
  cd ../connectedhomeip/examples
  app_check "lighting-app"
  if [[ $spec_appck -eq 1 ]]; then
    if [[ $1 != "log" ]]; then
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
    fi
    echo -e "\nwaiting for incoming messages..."
    echo -e "attach a let to the pin 17 to use it\n"
    ./out/debug/chip-lighting-app --ble-device 0 |
    while IFS= read -r output
    do
      if [[ $1 == "log" ]]; then 
        echo $output
      else
        if [[ $output == *"On Command"* ]]; then
          cd /sys/class/gpio/gpio17
          echo 1 >value
          echo "ON received"
        elif [[ $output == *"Off Command"* ]]; then
          cd /sys/class/gpio/gpio17
          echo 0 >value
          echo "OFF received"
        fi
      fi
    done
  else
  else 
    text "" "red" "\n'lighting-app' executable not found. Build it using " "-n" 
    text "bold" "" "schip -u -d\n"
  fi
}

#riclonare a provare su raspberry