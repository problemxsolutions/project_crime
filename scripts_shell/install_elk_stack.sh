#!/bin/bash/
# System: Linux 5.4.0-40-generic, Ubuntu 20.04

# ***********************************************************************************
# Installing the ELK Stack [Elasticsearch, Logstash, Kibana] from simple bash script
# ***********************************************************************************
# Elasticsarch (version 7.10.0) on Linux/Ubuntu 20.04 through APT
# URL : https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html#deb-repo
# ***********************************************************************************
echo '***********************************************'
echo 'Welcome to the my ELK stack installation script'
echo '***********************************************'

# Import the Elasticsearch PGP Keyedit
# Elastic signs all of their packages with the Elasticsearch Signing Key 
# (PGP key D88E42B4, available from https://pgp.mit.edu) with fingerprint:
#   4609 5ACC 8548 582C 1A26 99A9 D27D 666C D88E 42B4

# Download and install the public signing key:
echo 'get public signing key...'
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "download and install of public signging key complete"
printf '\n'


# You may need to install the apt-transport-https package on Debian before proceeding:
read -p 'Do you need to install apt-transport-https package? [Y/n]: ' ans

if [ "${ans^^}" = "Y" ]; then
  echo "installing..."
  sudo apt-get install apt-transport-https
  printf '\n'
  echo "installation complete"
else 
  echo "skipping install.  You may encounter errors if not installed already..."
fi

# Save the repository definition to /etc/apt/sources.list.d/elastic-7.x.list:
echo "Saving the repo definition to /etc/apt/sources.list.d/elastic-7.x.list...."
"deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
printf '\n'

echo "Install the ELK stack components...please wait"
sudo apt-get update && sudo apt-get install elasticsearch logstash kibana
printf '\n'
echo "installation complete"

# What is my system running init or systemd?
# this response will tell you which you are using
echo "ps -p 1"
ps -p 1
printf '\n'

read -p "Which is your system running? [init or systemd]: " systemtype
echo "INPUT $systemtype CONFIRMED"
printf '\n'

# I do not have init so did not build out or test the init commands.
read -p "Do you want to configure your ELK stack components to start automatically when system boots up? [Y/n]: " ans
printf '\n'
sleep 1

if [ "${ans^^}" = "Y" ]; then
  if [ "$systemtype" = "systemd" ] ; then
    echo 'please wait....configuring system services...'
    # Run ELK stack components with systemd.  
    # To configure the ELK tack to start automatically when the system boots up
    sudo /bin/systemctl daemon-reload
    sudo /bin/systemctl enable elasticsearch.service
    echo "elasticsearch service enabled"
    sudo /bin/systemctl enable logstash.service
    echo "logstash service enabled"
    sudo /bin/systemctl enable kibana.service
    echo "kibana service enabled"
    printf '\n'
    echo "You can now run the start_elk_stack.sh script!"
    printf '\n'
    echo "To verify that Elasticsearch is running use this command in your terminal:  curl -X GET http://localhost:9200/"
    printf '\n'
  else
    echo "Check official documentation for instructions:"
    echo "https://www.elastic.co/guide/en/elasticsearch/reference/current/deb.html"
  fi
else  
  echo "You are on your own at this point."
fi
echo "Please refer to official documentation at:"
echo "https://www.elastic.co/"

echo "Process Complete"