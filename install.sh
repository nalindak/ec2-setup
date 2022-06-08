#!/bin/bash

# Add nice .bashrc
if [ -r ~/.bashrc ]; then
    if [ -r ~/.bashrc_original ]; then
        echo 'Original bash file is exists!'
    else
        mv ~/.bashrc ~/.bashrc_original
    fi
    curl -s 'https://raw.githubusercontent.com/nalindak/ec2-setup/main/.bashrc' -o ~/.bashrc
    source ~/.bashrc
fi

# Add kubectl command aliases
if [ ! -f ~/.kubectl_aliases ]; then
    curl -s 'https://raw.githubusercontent.com/nalindak/ec2-setup/main/.kubectl_aliases' -o ~/.kubectl_aliases
    source ~/.kubectl_aliases
fi

# Show the current distribution
function distribution ()
{
	local dtype
	# Assume unknown
	dtype="unknown"
	
	# First test against Fedora / RHEL / CentOS / generic Redhat derivative
	if [ -r /etc/rc.d/init.d/functions ]; then
		source /etc/rc.d/init.d/functions
		[ zz`type -t passed 2>/dev/null` == "zzfunction" ] && dtype="redhat"
	
	# Then test against SUSE (must be after Redhat,
	# I've seen rc.status on Ubuntu I think? TODO: Recheck that)
	elif [ -r /etc/rc.status ]; then
		source /etc/rc.status
		[ zz`type -t rc_reset 2>/dev/null` == "zzfunction" ] && dtype="suse"
	
	# Then test against Debian, Ubuntu and friends
	elif [ -r /lib/lsb/init-functions ]; then
		source /lib/lsb/init-functions
		[ zz`type -t log_begin_msg 2>/dev/null` == "zzfunction" ] && dtype="debian"
	
	# Then test against Gentoo
	elif [ -r /etc/init.d/functions.sh ]; then
		source /etc/init.d/functions.sh
		[ zz`type -t ebegin 2>/dev/null` == "zzfunction" ] && dtype="gentoo"
	
	# For Mandriva we currently just test if /etc/mandriva-release exists
	# and isn't empty (TODO: Find a better way :)
	elif [ -s /etc/mandriva-release ]; then
		dtype="mandriva"

	# For Slackware we currently just test if /etc/slackware-version exists
	elif [ -s /etc/slackware-version ]; then
		dtype="slackware"

	fi
	echo $dtype
}

# Install docker-compose
function install_docker_compose ()
{
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/bin/docker-compose && sudo chmod +x /usr/bin/docker-compose && sudo docker-compose --version
}

# Show the current version of the operating system
function ec2_setup ()
{
	local dtype
	dtype=$(distribution)

	if [ $dtype == "redhat" ]; then
        sudo yum update -y
        sudo yum install git jq tree awscli -y
        sudo amazon-linux-extras install docker
        sudo service docker start
        sudo usermod -aG docker $USER
        sudo chmod 666 /var/run/docker.sock
        sudo chkconfig docker on
        install_docker_compose
	elif [ $dtype == "suse" ]; then
		cat /etc/SuSE-release
	elif [ $dtype == "debian" ]; then
        sudo apt-get update
        sudo apt-get install docker git jq tree awscli -y
        sudo usermod -aG docker $USER
        sudo service docker start
        sudo chmod 666 /var/run/docker.sock
	elif [ $dtype == "gentoo" ]; then
		cat /etc/gentoo-release
	elif [ $dtype == "mandriva" ]; then
		cat /etc/mandriva-release
	elif [ $dtype == "slackware" ]; then
		cat /etc/slackware-version
	else
		if [ -s /etc/issue ]; then
			cat /etc/issue
		else
			echo "Error: Unknown distribution"
			exit 1
		fi
	fi
}

echo "#########################################"
echo "######## EC2 Setup ######################"
echo "#########################################"
ec2_setup
