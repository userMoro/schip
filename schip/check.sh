#!/bin/bash

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

  #checking common required packages
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
  cd ..
  if [ -d connectedhomeip ]; then
    repock=1
  fi
  cd connectedhomeip
}

function chiptool_check(){
  if [ -d out ]; then
    chiptoolck=1
  fi
}

function submodule_check(){
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
  appck=0
  spec_appck=0
  for app in connectedhomeip/examples; do
    echo $app "tutte"
    if [[ -d $app/linux/out ]]; then
      appck=1
      echo $app "presente"
    fi
  done
  if [[ -d $1/linux/out ]]; then
    spec_appck=1
  fi
}