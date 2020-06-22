#!/bin/bash
#Author: Piyush Kumar (piyushkumar.jiit@gmail.com)
#Input:
# $1 = URL_TO_EXPOSE
# $2 = BASE_DIR

#Usage:
#./ngrok_proxy.sh 
#./ngrok_proxy.sh http://localhost:9080
#./ngrok_proxy.sh | tee ngrok_proxy_output.log

#ngrok binary URL
ZIP_BINARY_URL="https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip"

#Set the URL to be exposed
if [[ -z $1 ]]
then 
	URL_TO_EXPOSE="http://localhost:8080"
	echo "Using Default URL :" $URL_TO_EXPOSE
else
	URL_TO_EXPOSE=$1
	echo "Using URL :" $URL_TO_EXPOSE
fi


#Set the BASE_DIR
if [[ -z $2 ]]
then 
	BASE_DIR="$HOME"
	echo "Using Default BASE DIR :" $BASE_DIR
else
	BASE_DIRE=$2
	echo "Using BASE DIR :" $BASE_DIR
fi

#Check if ngrok needs to be installed
ngrok_installed=$($BASE_DIR/ngrok/ngrok version > /dev/null 2>&1; echo $?)
if [[ $ngrok_installed -gt 0 ]]
then
	#Install ngrok
	echo "ngrok does not seem to be available. Trying to setup ngrok."
	cd ~
	mkdir ngrok
	cd ngrok
	wget "$ZIP_BINARY_URL" -O ngrok.zip
	unzip -qo ngrok.zip
	rm -f ngrok.zip
	#sudo chmod +x $BASE_DIR/ngrok/ngrok
	#Move to local bin if you want it to be accessible across. Keeping here for my usecase.
	#sudo mv $BASE_DIR/ngrok/ngrok /usr/local/bin/ngrok
	
	#Check again
	ngrok_installed=$($BASE_DIR/ngrok/ngrok version > /dev/null 2>&1; echo $?)
	if [[ $ngrok_installed == 0 ]]
	then
		echo "ngrok seems to be working. Proceeding with Proxy start."
		#Start proxy
		#./ngrok http -bind-tls=true -inspect=false  --log=ngrok.log http://localhost:8080 &
		NGROK_RUNNING_PID=$(ps aux | grep ngrok | grep http | grep -v "grep" | grep -v "ngrok_proxy.sh"  | awk -F " " '{print $2}')
		if [[ -n $NGROK_RUNNING_PID ]]
		then
			echo "Killing running ngrok process with PID: "$NGROK_RUNNING_PID
			killed=$(kill -9 $NGROK_RUNNING_PID > /dev/null 2>&1; echo $?)
			if [[ $killed == 0 ]]
			then
				echo "Process terminated."
			else
				echo "Unable to kill the process."
				#exit 1
			fi
		else
			echo "No PID found for ngrok."
		fi
		nohup $BASE_DIR/ngrok/ngrok http -bind-tls=true -inspect=false --log=stdout $URL_TO_EXPOSE > $BASE_DIR/ngrok/ngrok.log 2>&1 &
		sleep 10
		#cat $BASE_DIR/ngrok/ngrok.log
		#ps aux
		EXTERNAL_URL=$(cat $BASE_DIR/ngrok/ngrok.log | awk -F "url=" '{print $2}' | awk -F " " '{print $1}')
		echo "External URL: " $EXTERNAL_URL
		echo $EXTERNAL_URL > EXTERNAL_URL.txt
	else
		echo "Unable to install ngrok. Exiting."
		sleep 10
		exit 1
	fi
else
	echo "ngrok already installed. Checking for running processes."
	NGROK_RUNNING_PID=$(ps aux | grep ngrok | grep http | grep -v "grep" | grep -v "ngrok_proxy.sh"  | awk -F " " '{print $2}')
	if [[ -n $NGROK_RUNNING_PID ]]
	then
		echo "Killing running ngrok process with PID: "$NGROK_RUNNING_PID
		killed=$(kill -9 $NGROK_RUNNING_PID > /dev/null 2>&1; echo $?)
		if [[ $killed == 0 ]]
		then
			echo "Process terminated."
		else
			echo "Unable to kill the process."
			#exit 1
		fi
	else
		echo "No PID found for ngrok."
	fi
	echo "Proceeding with Proxy start."
	#Start proxy
	#./ngrok http -bind-tls=true -inspect=false  --log=stdout http://localhost:8080 > /dev/null &
	nohup $BASE_DIR/ngrok/ngrok http -bind-tls=true -inspect=false --log=stdout $URL_TO_EXPOSE > $BASE_DIR/ngrok/ngrok.log 2>&1 &
	sleep 10
	#cat $BASE_DIR/ngrok/ngrok.log
	#ps aux
	EXTERNAL_URL=$(cat $BASE_DIR/ngrok/ngrok.log | awk -F "url=" '{print $2}' | awk -F " " '{print $1}')
	echo "External URL: " $EXTERNAL_URL
	echo $EXTERNAL_URL > $BASE_DIR/ngrok/EXTERNAL_URL.txt
fi

