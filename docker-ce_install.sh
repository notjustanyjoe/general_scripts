i=`whoami`
echo "I am "$i
case "$i" in
        "root" )

if [ -e /etc/redhat-release ] || [ -e /etc/system-release ] # checks if rhel or centos
then
  echo "Installing/Checking latest Docker CE RPM package. Process may take a while..."
    if rpm -q docker-ce |grep "not installed" > /dev/null #If package not yet installed
      then
    	echo "Installing Docker CE repo and package..."
    	  yum install -y yum-utils container-selinux
    	  yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    	  yum makecache fast
    	  yum install -y docker-ce
    	echo "Starting Docker Service and enabling for startup"
    	  systemctl enable docker
    	  systemctl start docker
    	  mkdir /etc/systemd/system/docker.service.d
        echo "Configuring Docker service with proxy to work in Environment..."
          tee /etc/systemd/system/docker.service.d/http-proxy.conf <<-'EOF'
[Service]
Environment="HTTP_PROXY=http://user:pass@proxy.example.com:80/"
Environment="HTTPS_PROXY=http://user:pass@proxy.example.com:80/"
Environment="NO_PROXY=localhost,127.0.0.1,*.local,169.254/16"
EOF
 		echo "Configuring Docker daemon to use DNS..."
 		  bash -c "cat >> /etc/docker/daemon.json" << 'EOL'
{"dns": ["192.168.1.2", "192.168.1.3"]}
EOL
		echo "Reload Docker Daemon to recognize settings..." 
		  systemctl daemon-reload
		  systemctl restart docker
 		echo "Showing Docker Environment"
 		  systemctl show --property=Environment docker
	  else
	  	echo "Docker CE rpm is already installed"
	  fi
fi

if [ -e /etc/lsb-release ] #checks if ubuntu/debian
then
	echo "Installing/Checking latest Docker CE DEB package. Proecess may take a while..."
	  if dpkg-query -s docker-ce 1>/dev/null 2>&1 #if package not yet installed
	  	then
	  		echo "Docker CE DEB is already installed"
	  	else
	  		echo "Installing Docker CE repo and package..."
	  		  apt-get install apt-transport-https ca-certificates curl software-properties-common -y
	  		  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	  		  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	  		  apt update
	  		  apt-get install docker-ce -y
	  		echo "Starting Docker Service and enabling for startup"
	  		  systemctl start docker
	  		  systemctl enable docker
	  		  mkdir /etc/systemd/system/docker.service.d
        	echo "Configuring Docker service with proxy to work in Environment..."
          	  tee /etc/systemd/system/docker.service.d/http-proxy.conf <<-'EOF'
[Service]
Environment="HTTP_PROXY=http://user:pass@proxy.example.com:80/"
Environment="HTTPS_PROXY=http://user:pass@proxy.example.com:80/"
Environment="NO_PROXY=localhost,127.0.0.1,*.local,169.254/16"
EOF
 			echo "Configuring Docker daemon to use DNS..."
 		  	  bash -c "cat >> /etc/docker/daemon.json" << 'EOL'
{"dns": ["192.168.1.2", "192.168.1.3"]}
EOL
			echo "Reload Docker Daemon to recognize settings..." 
		  	  systemctl daemon-reload
		  	  systemctl restart docker
 			echo "Showing Docker Environment"
 		  	  systemctl show --property=Environment docker
 	  fi
fi
;;

* )
echo "You are not root!"
esac
