#!/usr/bin/env bash
###
# Project:  whatsmyip-bash ( https//https://gitlab.com/ialokin/whatsmyip-bash )
# Version:  0.2
# License:  GNU GPL v3 ( https://www.gnu.org/licenses/gpl-3.0.en.html )
# Author:   Nikolai Stensen (ialokin) < dev@ialokin.no >
#
# Desc:     Bash script to get your public IP address using one of several
#           free online services. Useful if you have a dynamic IP address
#           and need a quick way to get it.
#
# Requires: curl or wget
#
# Usage:    whatsmyip.sh [OPTIONS]
#
# Options:  -h, --help          Print `help`
#           -v, --version       Print version
#           -4, --ipv4          Request IPv4 address
#           -6, --ipv6          Request IPv6 address
#           -s, --server <url>  Use a specific web service
#
# Install:  See https//https://gitlab.com/ialokin/whatsmyip-bash
###

# List of URLs that sends you your IP address in clear text.
# Make sure any URLs added here supports both IPv4 and IPv6 and that they
# only reply with the IP address in clear text.
ipWebServer=(
  "https://icanhazip.com/"
  "https://wtfismyip.com/text"
  "http://ipecho.net/plain"
  "https://ifconfig.me/ip"
  "https://ifconfig.co/"
  "https://api.seeip.org/"
  "https://ident.me/"
  "https://checkip.dedyn.io/"
  "https://myip.dk/"
  "https://myexternalip.com/raw"
  "https://ipapi.co/ip/"
)

# Function to display help
ipShowHelp() {
  cat << EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help       Show this help message and exit
  -v, --version    Show information about this script
  -4, --ipv4       Use IPv4
  -6, --ipv6       Use IPv6
  -s, --server     Specify the URL to query for the IP address.
                   Make sure it ONLY replies with the IP address.
  -l, --list       List available web services

Examples:
  $(basename "$0") --ipv6
  $(basename "$0") -h
  $(basename "$0") -s https://myip.dk/ -4
EOF
}

# Function to display about information
ipShowVersion() {
  cat << EOF
Project: whatsmyip-bash v0.2 ( https://gitlab.com/ialokin/whatsmyip )
Author:  Nikolai Stensen (ialokin)
         https://ialokin.no/ Email: dev@ialokin.no
License: GNU GPL v3.0 ( https://www.gnu.org/licenses/gpl-3.0.en.html )
EOF
}

# Function to check for curl/wget
function ipCheckBrowser() {
  if [[ -x "$(which curl)" ]]; then
    echo "curl -s"  # Return the curl command string
  elif [[ -x "$(which wget)" ]]; then
    echo "wget -O -q -"  # Return the wget command string
  else
    return 1  # Return an error if neither curl nor wget is found
  fi
}

# Function to check the IP address and try to verify if it looks like a valid
# IPv4 or IPv6 address.
function ipCheckVer() {
  # Check for IPv4
  if [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "4"  # IPv4
  # Check for IPv6
  elif [[ "$1" =~ ^([0-9a-fA-F]{1,4}:){1,7}[0-9a-fA-F]{1,4}$ ]]; then
    echo "6"  # IPv6
  else
    echo "0"  # Unknown
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
  -h|--help)
    ipShowHelp
    exit 0
  ;;
  -4|--ipv4)
    ipProt=-4
    shift
  ;;
  -6|--ipv6)
    ipProt=-6
    shift
  ;;
  -v|--version)
    ipShowVersion
    exit 0
  ;;
  -s|--server)
    if [[ -z "$2" ]]; then
      echo "No server specified!" >&2;
      exit 1;
    fi
    ipServer="$2"
    shift 2
  ;;
  -l|--list)
    echo "Available web services:"
    echo
    for server in "${ipWebServer[@]}"; do
      echo "- ${server}"
    done
    exit 0
  ;;
  -*)
    echo "Unknown option: $1" >&2
    echo "Use --help to see available options." >&2
    exit 1
  ;;
  *)
    echo "Unexpected argument: $1" >&2
    echo "Use --help to see available options." >&2
    exit 1
  ;;
  esac
done

# Select browser, or die if neither curl or wget is available.
ipBrowser=$(ipCheckBrowser)
if [[ -z "$ipBrowser" ]]; then
  echo "Error: curl or wget is required to run this script." >&2
  exit 1
fi

# Choose a random website from the list above unless a server is specified
# with -s|--server.
if [ -z "${ipServer}" ]; then
  ipServer=${ipWebServer[$RANDOM % ${#ipWebServer[@]}]}
fi

# Get your IP address from the server and try to verify it.
ipReceived=$($ipBrowser "$ipProt" "$ipServer")
ipVersion=$(ipCheckVer "$ipReceived")

# Verify that we got the correct IP. If we tried to get IPv4 and got IPv6
# it could mean that we dont have IPv4 connectiviity or vice versa.
# Verify the IP address
if [[ "$ipVersion" == "4" && "$ipProt" == "-6" ]]; then
  echo "ERROR! Asked for IPv6, but got IPv4. Is the IPv6 connection down?" >&2
  exit 1
elif [[ "$ipVersion" == "6" && "$ipProt" == "-4" ]]; then
  echo "ERROR! Asked for IPv4, but got IPv6. Is the IPv4 connection down?" >&2
  exit 1
elif [[ "$ipVersion" == "0" ]]; then
  echo "ERROR! You asked for IPv4/IPv6, but the web service replied with something else!" >&2
  exit 1
fi

# When printing the IP, make sure we have a newline at the end.
if [[ "${ipReceived: -1}" == $'\n' ]]; then
  echo -n "$ipReceived"
else
  echo "$ipReceived"
fi