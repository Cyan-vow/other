#!/bin/bash

GID="$1";
FileNum="$2";
File="$3";
MaxSize="15728640"
RemoteDIR="";
LocalDIR="/Download/";  #Aria2下载目录，记得最后面加上/

if [[ -z $(echo "$FileNum" |grep -o '[0-9]*' |head -n1) ]]; then FileNum='0'; fi
if [[ "$FileNum" -le '0' ]]; then exit 0; fi
if [[ "$#" != '3' ]]; then exit 0; fi

function LoadFile(){
  IFS_BAK=$IFS
  IFS=$'\n'
  if [[ ! -d "$LocalDIR" ]]; then return; fi
  if [[ -e "$File" ]]; then
    if [[ $(dirname "$File") == $(readlink -f $LocalDIR) ]]; then
      ONEDRIVE="onedrive";
    else
      ONEDRIVE="onedrive-d";
    fi
    FileLoad="${File/#$LocalDIR}"
    while true
      do
        if [[ "$FileLoad" == '/' ]]; then return; fi
        echo "$FileLoad" |grep -q '/';
        if [[ "$?" == "0" ]]; then
          FileLoad=$(dirname "$FileLoad");
        else
          break;
        fi;
      done;
    if [[ "$FileLoad" == "$LocalDIR" ]]; then return; fi
    if [[ -n "$RemoteDIR" ]]; then
      Option=" -f $RemoteDIR";
    else
      Option="";
    fi
    EXEC="$(command -v $ONEDRIVE)";
    if [[ -z "$EXEC" ]]; then return; fi
    cd "$LocalDIR";
    if [[ -e "$FileLoad" ]]; then
      ItemSize=$(du -s "$FileLoad" |cut -f1 |grep -o '[0-9]*' |head -n1)
      if [[ -z "$ItemSize" ]]; then return; fi
      if [[ "$ItemSize" -ge "$MaxSize" ]]; then
        echo -ne "\033[33m$File \033[0mtoo large to spik.\n";
        return;
      fi
      eval "${EXEC}${Option}" \'"${FileLoad}"\';
      if [[ $? == '0' ]]; then
        rm -rf "$FileLoad";
      fi
    fi
  fi
  IFS=$IFS_BAK
}
LoadFile;
