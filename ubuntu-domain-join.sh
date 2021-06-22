function install-deps {
	sudo apt -y install realmd libnss-sss libpam-sss sssd sssd-tools adcli samba-common-bin oddjob oddjob-mkhomedir packagekit
}

function join-realm {
	echo "Enter in hostname:"
	read hostName
	echo "Enter in domain:"	
	read domainName
	echo "Enter domain admin username"
	read domainAdmin
	
	if [ -z "$hostName" ]
	then
		echo "Cannot have empty hostname"
		join-realm
	elif [ -z "$domainName" ]
	then
		echo "Cannot have empty domain"
		join-realm
	elif [ -z "$domainAdmin" ]
	then
		echo "Must enter domain admin username"
		join-realm
	else
		sudo hostnamectl set-hostname $hostName.$domainName
		sudo realm join -U $domainAdmin $domainName
	fi
}
function configure-realm {
	sudo bash -c "cat > /usr/share/pam-configs/mkhomedir" <<EOF
Name: activate mkhomedir
Default: yes
Priority: 900
Session-Type: Additional
Session:
        required                        pam_mkhomedir.so umask=0022 skel=/etc/skel
EOF
	sudo pam-auth-update
	sudo systemctl restart sssd
	echo "\"%domain admins@$domainName\" ALL=(ALL) ALL" | sudo EDITOR='tee -a' visudo
}

install-deps
join-realm
configure-realm
