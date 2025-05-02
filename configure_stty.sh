#!/bin/bash

SERIAL_PORT="/dev/ttyUSB0"
BAUD_RATE=115200

# Set the serial port configuration
stty -F "$SERIAL_PORT" "$BAUD_RATE" cs8 -parenb -cstopb

if [ $? -eq 0 ]; then
  echo "Serial port $SERIAL_PORT configured successfully with:"
  echo "  Baud rate: $BAUD_RATE"
  echo "  Data bits: 8"
  echo "  Parity: None"
  echo "  Stop bits: 1"
else
  echo "Error configuring serial port $SERIAL_PORT."
fi
