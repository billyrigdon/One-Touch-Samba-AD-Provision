#!/bin/bash

#Gets domain and hostname and sets the FQDN
function set-fqdn {
	echo "Enter domain name[example.com]"
	read domainName
	echo "Enter hostname[server1]"
	read serverName

	if [ -z "$domainName" ]
	then
      		echo "Cannot have empty domain"
		set-fqdn
	elif [ -z "$serverName"]
	then
		echo "Cannot have empty hostname"
		set-fqdn
	else
      		hostnamectl set-hostname "$serverName.$domainName"
	fi
}

#Allows user to enter ip address and saves it to a variable for later
function get-ip {
	echo "Enter ip address of server[192.168.1.100]"
	read ipAddress
	
	if [ -z "$ipAddress" ]
        then
        	echo "Cannot have empty IP"
                get-ip
	else
		echo "IP address is $ipAddress"
       	fi 
}

# Installs Samba dependencies
function install-samba {
	apt-get install -y acl attr samba samba-dsdb-modules samba-vfs-modules winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config krb5-user dnsutils
}

#Auto-Provision samba and start necessary services
function provision-samba {
	mv /etc/samba/smb.conf /etc/samba/smb.conf.old
	samba-tool domain provision
	mv /etc/hosts /etc/hosts.old
	touch /etc/hosts
	echo "$ipAddress $serverName.$domainName $serverName" >> /etc/hosts
	cat /etc/hosts.old >> /etc/hosts
	cp /var/lib/samba/private/krb5.conf /etc/krb5.conf
	systemctl disable --now smbd nmbd winbind systemd-resolved
	systemctl unmask samba-ad-dc
	systemctl enable --now samba-ad-dc
	rm /etc/resolv.conf
	touch /etc/resolv.conf
	echo "nameserver 127.0.0.1" >> /etc/resolv.conf
}

set-fqdn
get-ip
install-samba
provision-samba
