#!/bin/bash
#Verify user is elevated
i=`whoami`
echo "I am "$i
case "$i" in
        "root" )
        


if [ -e /etc/redhat-release ] || [ -e /etc/system-release ] # checks if rhel or centos
then
  echo "Installing/Checking latest Gitlab-Runner RPM package. Process may take a while..."
    if rpm -q gitlab-runner | grep "not installed" > /dev/null #If package not yet installed
      then
        echo "Installing gitlab-runner repo and package ..."
          yum -y install curl
          curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash > /dev/null #Installs repo
          yum -y install gitlab-runner
      else
        echo "gitlab-runner rpm is already installed"
    fi
fi

if [ -e /etc/lsb-release ] # checks if ubuntu/debian
then
  echo "Installing/Checking latest Gitlab-Runner DEB package. Process may take a while..."
    if dpkg-query -s gitlab-runner 1>/dev/null 2>&1  #If package not yet installed
      then
        echo "gitlab-runner deb is already installed"
      else
        echo "Installing gitlab-runner repo and package ..."
          apt-get install curl
          curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
          cat <<EOF | sudo tee /etc/apt/preferences.d/pin-gitlab-runner.pref
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF
          apt-get install gitlab-runner
    fi
fi

;;
* )
echo "You are not root!"
esac
