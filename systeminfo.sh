#!/bin/bash

#Here is the path to  Function library
source "$(dirname "$0")/reportfunctions.sh"

LOG_FILE="/var/log/systeminfo.log"

usage() {
    echo "Usage: $0 [-h] [-v] [--system] [--disk] [--network]"
    echo "Options:"
    echo "  -h, --help         Display help for the script and exit"
    echo "  -v, --verbose      Run the script verbosely, showing errors to the user instead of sending them to the logfile"
    echo "      --system       Run only the computerreport, osreport, cpureport, ramreport, and videoreport"
    echo "      --disk         Run only the diskreport"
    echo "      --network      Run only the networkreport"
    exit 1
}

errormessage() {
    local message="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $message" >> "$LOG_FILE"
    if [ "$VERBOSE" = true ]; then
        echo "Error: $message" >&2
    fi
}

if [ $# -eq 0 ]; then
    cpureport
    computerreport
    osreport
    ramreport
    videoreport
    diskreport
    networkreport
fi


while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --system)
            cpureport
            computerreport
            osreport
            ramreport
            videoreport
            shift
            continue
            ;;
        --disk)
            diskreport
            shift
            continue
            ;;
        --network)
            networkreport
            shift
            continue
            ;;
        *)
            errormessage "Invalid: $1"
            usage
            ;;
    esac
done


if [ $# -ne 0 ]; then
    errormessage "Unknown options: $*"
    usage
fi

