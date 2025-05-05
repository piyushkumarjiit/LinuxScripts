#! /bin/sh
device_path='/dev/ttyUSB0'

case "$1" in
  start)
      echo "Starting Fireplace via serial connection to $device_path  ... "
      sudo fuser -k $device_path
      echo -n "TX_URH 1,304.20,2,/URH/Start3.proto.xml,2,500,3\r" > $device_path
      sleep 3
      echo "Started Fireplace."
  ;;
  stop)
    echo "Stopping Fireplace via serial connection to $device_path ..."
    sudo fuser -k $device_path
    echo -n "TX_URH 2,304.20,2,/URH/Stop3.proto.xml,2,500,5\r" > $device_path
    sleep 3
    echo "Stopped fireplace."
 ;;
  *)
    echo "Usage: $0 {start | stop}"
    exit 1
  ;;
esac
exit 0
