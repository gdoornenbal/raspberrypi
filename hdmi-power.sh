#!/bin/bash
#
# Manage power state from your Monitor or TV.
# must be called with a parameter: hdmi-power.sh [command]
# will send the associated command to the TV or Monitor over CEC or HDMI-status. 
#
# shameless copied from https://www.raspberrypi.org/forums/viewtopic.php?f=91&t=67899
#
# how to install cec-client: sudo apt-get install cec-utils
# 
# V 0.1 09-12-2016 by Gerrit Doornenbal
#  - added options for tvservice
#

if [ $# -lt 1 ] #Check to see if at least one parameter was supplied
then
  echo "Must be called with the command to send to the television"
  echo "Examples include tvon, tvoff, monon, monoff, status, and input."
  echo "example: " $0 "input PC"        # $0 is the name of the program
  echo "For help, use: " $0 " -? "
  exit 1
fi

case $1 in
  "-?")       echo "Supported commands include: on, off, status,"
              echo "input [source]" ;;
  ## begin list of commands.
  ## most of these came from http://www.cec-o-matic.com/
  ## more can be added, including proprietary commands.
  "tvon")     echo "on 0" | cec-client -s && sleep 5 &&  echo "as" | cec-client -s ;;
  "tvoff")    echo "standby 0" | cec-client -s ;;
  "monoff")   sudo tvservice -o ;;
  "monon")    sudo tvservice -p && sudo chvt 6 && sudo chvt 7 ;;
  "status")   echo "pow 0" | cec-client -s |grep "power status:" && tvservice -s ;;
  "as")       echo "as" | cec-client -s ;; ## Switch Active Source to this device.
  "active")   echo "as" | cec-client -s ;; ## Same as as. This is better for voice control.

  "input")
  if [ $# -ge 2 ]       # if there were 2 or more parameters
  then
    case $2 in          # check the second one
        # NOTE: These must all be broadcast to work. (2nd nibble must be F)
      "1")      echo "tx 1F 82 10 00" | cec-client -s ;;
      "bluray") echo "tx 1F 82 10 00" | cec-client -s ;; # same as 1
      "2")      echo "tx 1F 82 20 00" | cec-client -s ;;
      "3")      echo "tx 1F 82 30 00" | cec-client -s ;;
      "pc")     echo "tx 1F 82 30 00" | cec-client -s ;; # same as 3
      "raspi")  echo "tx 1F 82 30 00" | cec-client -s ;; # same as 3
      "4")      echo "tx 1F 82 40 00" | cec-client -s ;;
    esac
  else
    echo "input needs a second parameter"
    echo "usage: " $0 " input [input name]"
    echo "input name is 1-4, bluray, pc, or raspi"
  fi
  ;;  # end of the input case

  *) echo $1 "is not a recognized parameter. " $0 " -? for a list." ;;
esac
exit 0
