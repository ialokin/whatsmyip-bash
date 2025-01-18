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

Examples:
  $(basename "$0") --ipv6
  $(basename "$0") -h
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

# Make sure we have either curl or wget installed.
if [[ -x "$(which curl)" ]]; then
  ipBrowser="curl -s"
elif [[ -x "$(which wget)" ]]; then
  ipBrowser="wget -O -q -"
else
  echo "ERROR! This script needs either curl or wget!"
  exit 1
fi

# Choose a random website from the list above unless a server is specified
# with -s|--server.
if [ -z "${ipServer}" ]; then
  ipServer=${ipWebServer[$RANDOM % ${#ipWebServer[@]}]}
fi
# Get your IP address from the server.
ipReceived=$($ipBrowser "$ipProt" "$ipServer")
# Check if there is a newline at the end of the IP address.
if [[ "${ipReceived: -1}" == $'\n' ]]; then
  echo -n "$ipReceived"
else
  echo "$ipReceived"
fi