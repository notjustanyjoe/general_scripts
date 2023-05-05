#!/bin/bash
# This was created with material from the Red Hat solution
# at URL https://access.redhat.com/solutions/221403
# if you are using RHEL 8, you need ansible to run this
# Some modifications have been made to work with rocky linux 8

# this is for rhel8/rocky8, if it isn't this gets printed and exits
forrhel8(){
echo -e "\n\t This is for RHEL/Rocky 8 per Red Hat solution https://access.redhat.com/solutions/221403"
exit
}
# One of these is for RHEL8 and the other for Rocky8. change which is commented for OS.
#rpm -q redhat-release | grep -q redhat-release-8 && echo -e "\n\tRHEL 8 detectedm proceeding.\n" || forrhel8
rpm -q rocky-release | grep -q rocky-release-8 && echo -e "\n------> Rocky 8 detected, proceeding.\n" || forrhel8

# this runs if ansible is not installed
needansible() {
echo -e "\n\tThis script requires ansible to run. \n\tThese are the commands to enable ansible:\n"
echo "subscription-manager repos --enable ansible-2.9-for-rhel-8-x86_64-rpms"
echo -e "yum install ansible -y\n"
exit 
}

# this runs if ansible is installed
runit() {
echo -e "\nThis script creates a SHA-512 shadow-compatible hash.\n\tsee URL https://access.redhat.com/solutions/221403"

echo -e "\n\tPlease carefully enter the password you wish to use ONCE. \n\tThis ansible method will not ask for a second verification."
echo -e "\n\tNOTE: This takes a moment to process\n\tTHERE IS A DELAY AFTER YOU HIT ENTER!!"
read -p "Enter Password: " -s pw
password=$(ansible -m debug -a msg="{{ '$pw'  | password_hash('sha512') }}" localhost | awk '/msg/ {print $NF}' | sed 's/^"//' | sed 's/"$//')
echo -e "\n\n------> Example 1: This is your raw SHA-512 shadow-compliant password hash: \n$password"
string="echo 'elvis:$password' | /usr/sbin/chpasswd -e && logger 'Successfully changed password for account elvis'"
string2="rootpw --iscrypted $password" 
echo -e "\n------> Example 2: Using chpasswd to change a password.\n$string"
echo -e "\n------> Example 3: For use in a kickstart.\n$string2"
echo -e "\n\tThere are three use examples above. The raw hash, an example to change a password with 'chpasswd' and an example for a kickstart.\n"
echo -e "See this for more details: URL https://access.redhat.com/solutions/221403"
} # end runit function

# this only runs if ansible installed, else it prints what is needed
rpm -q ansible > /dev/null && runit || needansible
