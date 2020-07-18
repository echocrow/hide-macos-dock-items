#!/usr/bin/env bash

T=$'\t'
N=$'\n'

KEY_DATA_INSERT="
$T$T<dict>
$T$T$T<key>command</key>
$T$T$T<integer>1004</integer>
$T$T$T<key>name</key>
$T$T$T<string>REMOVE_FROM_DOCK</string>
$T$T</dict>"

function graceful_exit {
  message="$1"
  echo "Error: ${message}" >&2
  exit 1
}

function find_str_index {
  text="$1"
  search="$2"
  offset="$3-0"

  textPrefix="${text:0:$offset}"
  textSuffix="${text:$offset}"

  searchPrefix="${textSuffix%%$search*}"
  [[ "$textSuffix" == "$searchPrefix" ]] && graceful_exit "Failed to find substring \"${search}\"."

  prefix="${textPrefix}${searchPrefix}"
  echo "${#prefix}"
}

function inject_remove_option {
  plistStr="$1"
  keyItem="$2"
  keyDataInsert="$3"

  keyStr="<key>${keyItem}</key>"
  keyArrayCloseStr="$N$T</array>"

  keyPos=$(find_str_index "$plistStr" "$keyStr")
  [[ -z "$keyPos" ]] && graceful_exit "Failed to find Key position for \"${keyItem}\"."

  keyArrayClosePos=$(find_str_index "$plistStr" "$keyArrayCloseStr" "$keyPos")
  [[ -z "$keyArrayClosePos" ]] && graceful_exit "Failed to find Key Close position for \"${keyItem}\"."

  prefix="${plistStr:0:$keyArrayClosePos}"
  suffix="${plistStr:$keyArrayClosePos}"

  extPlistStr="${prefix}${keyDataInsert}${suffix}"
  echo "$extPlistStr"
}

function main {
  plistPath="$1"
  keyItem="$2"

  plistStr=$(cat "$plistPath")
  [[ -z "$plistStr" ]] && graceful_exit "Failed to read PLIST file \"${plistPath}\"."

  extPlistStr=$(inject_remove_option "$plistStr" "$keyItem" "$KEY_DATA_INSERT")
  [[ -z "$extPlistStr" ]] && graceful_exit "Failed to extend PLIST."

  echo "$extPlistStr" > "$plistPath" || graceful_exit "Failed to write PLIST file \"${plistPath}\"."

  exit 0
}

main "$@"
