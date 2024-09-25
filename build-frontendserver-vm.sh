#!/bin/bash

# allow services to run
echo exit 0 > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

# Ensure that packages do not request user input from console.
export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
# Set timezone options without needing to interact with console.
echo "tzdata tzdata/Areas select Pacific" | debconf-set-selections
echo "tzdata tzdata/Zones/Europe select Auckland" | debconf-set-selections

apt-get update
apt-get install -y apache2 php libapache2-mod-php php-mysql
            
# Change VM's webserver's configuration to use shared folder.
# (Look inside front-website.conf for specifics.)
cp /vagrant/front-website.conf /etc/apache2/sites-available/

# activate our website configuration ...
a2ensite front-website
# ... and disable the default website provided with Apache
a2dissite 000-default
# Restart the webserver, to pick up our configuration changes
service apache2 restart
