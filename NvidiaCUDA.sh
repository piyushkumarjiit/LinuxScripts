#!/bin/bash

#Abort installation if any of the commands fail
set -e

#This script tries to use existing proprietory NVIDIA drivers.In case of other OS-Version combo, please update the default values with valid values and script should work as expected.

#Update the default OS and Version based on availability on "http://developer.download.nvidia.com/compute/cuda/repos/" and "http://developer.download.nvidia.com/compute/machine-learning/repos"
default_os_name="ubuntu"
default_os_version="1804"
default_ppa_driver_version="nvidia-driver-440"
default_cuda_version="cuda-10-1"
deafult_libcudn_version="libcudnn7"

#Extract OS Name from /etc/os-release
os_name=$(cat /etc/os-release | grep ID= | grep -Po 'ID=\K[^ ]+' | grep '[a-zA-Z]')
echo "Fetched OS:"$os_name
#Extract OS Version from /etc/os-release
os_version=$(cat /etc/os-release | grep ID= | grep -Po 'VERSION_ID="\K[^"]+')
echo "Fetched OS Version:"$os_version

#Add public key of the repo
url="http://developer.download.nvidia.com/compute/cuda/repos/$os_name$os_version/x86_64/3bf863cc.pub"
if wget -S $url >/dev/null 2>&1; then
	echo "Url : Public Key URL ($url) exists..."
else
	echo "Url : $url doesn't exist."
	url="http://developer.download.nvidia.com/compute/cuda/repos/$default_os_name$default_os_version/x86_64/3bf863cc.pub"
	echo "Url : Falling to default:"$url
fi
echo "Key URL:"$url
#sudo apt-key adv --fetch-keys  http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
#sudo apt-key adv --fetch-keys  "http://developer.download.nvidia.com/compute/cuda/repos/"$os_name$os_version"/x86_64/7fa2af80.pub"
sudo apt-key adv --fetch-keys $url

#Add cuda repo to cuda.list
url="http://developer.download.nvidia.com/compute/cuda/repos/"$os_name$os_version"/x86_64/"

if wget -S $url>/dev/null 2>&1; then
	echo "Url : CUDA URL ($url) exists..."
else
	echo "Url : $url doesn't exist."
	url="http://developer.download.nvidia.com/compute/cuda/repos/"$default_os_name$default_os_version"/x86_64/"
	echo "Url : Falling to default:"$url
fi
echo "CUDA URL:"$url
#sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
#sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/cuda/repos/"$os_name$os_version"/x86_64 /" > /etc/apt/sources.list.d/cuda.list'
sudo bash -c "echo deb "$url" / > /etc/apt/sources.list.d/cuda.list"

#Add machine learning repo to cuda_learn.list
url="http://developer.download.nvidia.com/compute/machine-learning/repos/"$os_name$os_version"/x86_64/"
if wget -S $url >/dev/null 2>&1; then
	echo "Url : ML URL ($url) exists..."
else
	echo "Url : $url doesn't exist."
	url="http://developer.download.nvidia.com/compute/machine-learning/repos/"$default_os_name$default_os_version"/x86_64/"
	echo "Url : Falling to default:"$url
fi
echo "ML URL:"$url
#sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda_learn.list'
#sudo bash -c 'echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/"$os_name$os_version"/x86_64 /" > /etc/apt/sources.list.d/cuda_learn.list'
sudo bash -c "echo deb "$url" / > /etc/apt/sources.list.d/cuda_learn.list"

#Call update to refresh package list
sudo apt update

#Install Cuda 10-1 with default yes
sudo apt install cuda-10-1 -y

#Install libcudnn7
sudo apt install libcudnn7 -y
#Update Path in ~/.profile file for CUDA 10.1
cd ~
cuda_path=$(cat ~/.profile | grep -Fxq "cuda-10.1")
if $cuda_path;
then
    # CUDA present in profile
	echo "CUDA already present in Path!!!"
else
    # CUDA not present in profile
	echo "CUDA config not present. Adding CUDA to path."
	cat << EOF >> ~/.profile
	if [ -d \"/usr/local/cuda-10.1/bin/\" ]; then
		export PATH=/usr/local/cuda-10.1/bin${PATH:+:${PATH}}
		export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
	fi
EOF

fi

sudo apt install nvidia-cuda-toolkit -y

echo $(nvcc --version)
