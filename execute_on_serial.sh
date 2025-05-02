#! /bin/sh

device_path="/dev/ttyUSB0"
baud_rate="115200"

case "$1" in
  start)
    if [ "$2" = "log" ]; then
      echo "Starting serial connection to EvilCrow RF V2 with logging... "
      /usr/bin/screen -dmS ECRFV2 $device_path $baud_rate
    else 
      echo "Starting serial connection to EvilCrow RF V2 without logging... "
      /usr/bin/screen -dmS ECRFV2 $device_path $baud_rate
    fi
  ;;
  stop)
    echo "Stopping serial connection to EvilCrow RF V2 ..."
    /usr/bin/screen -S ECRFV2 -X kill
  ;;
  restart)
     echo "Restarting serial connection to EvilCrow RF V2 ..."
    /usr/bin/screen -S ECRFV2 -X kill
    /usr/bin/screen -dmS ECRFV2 $device_path $baud_rate
  ;;
  send)
    if [ -n "$2" ]; then
      /usr/bin/screen -S ECRFV2 -X stuff "$2\r"
    else 
      echo "Usage: $0 $1 {command}"
    fi
  ;;
  cmd)
    if [ -n "$2" ]; then
	  /usr/bin/screen -dmS ECRFV2 $device_path $baud_rate
      /usr/bin/screen -S ECRFV2 -X stuff "$2\r"
      /usr/bin/screen -S ECRFV2 -X kill
    else 
      echo "Usage: $0 $1 {command}"
    fi
  ;;
  *)
    echo "Usage: $0 {start (log) | stop | restart | send|cmd command}"
    exit 1
  ;;
esac
exit 0