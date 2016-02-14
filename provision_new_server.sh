#!/bin/bash

# currently setup for a production server... prepend `staging.`
# to `patterns.brl.nyc` for a staging server
# additionally, change the RAILS_ENV value.

#as root only
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [ -f /etc/provisioned ];
then
   echo "server is provisioned, exiting."
   exit 1
fi

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" | sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
apt-get update && apt-get dist-upgrade -y
apt-get install -y python-software-properties software-properties-common
apt-add-repository -y ppa:nginx/development

debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'

echo "MYSQL_USER=root" >> /etc/environment
echo "MYSQL_PASSWORD=password" >> /etc/environment
echo "MYSQL_HOST=localhost" >> /etc/environment
echo "RAILS_ENV=production" >> /etc/environment

apt-get update && apt-get install -y mysql-server libmysqlclient-dev redis-server openjdk-6-jre elasticsearch git git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libgmp-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nginx gpg ruby1.8-dev openjdk-7-jre elasticsearch


# we don't want the default nginx server setup.
rm /etc/nginx/sites-enabled/default
openssl dhparam -out /etc/nginx/dhparam.pem 4096
service nginx stop
cd /root
git clone https://github.com/letsencrypt/letsencrypt
/root/letsencrypt/letsencrypt-auto certonly --standalone --agree-tos --email blueridgelabs@robinhood.org -d patterns.brl.nyc

cat >/etc/cron.weekly/letsencrypt.sh <<EOL
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH
/root/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/logan-production/current/public --agree-tos --email blueridgelabs@robinhood.org -d patterns.brl.nyc
service nginx restart
EOL
chmod +x /etc/cron.weekly/letsencrypt.sh

# creating the logan user.
getent passwd logan  > /dev/null
if [ $? -eq 0 ]; then
  echo "skipping user creation"
else
  useradd -m -s /bin/bash logan;
  su - logan
  mkdir ~/.ssh/
  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUkhUCqUdEjpm92sN5OGW7cLekAJNdT0HTDqCsUR28I3eB1lelKLWGDhIkR2L3TZmiX511+ZfaydgrFJEUqT+gotUKmWmW9CVpt5OQTZPPNJBkZ99uXYqg2sLHpAptacVIn/UGS4RRvMG6gT+pYiI1epyY0F0uqeNDVwO0HAo7pLxS7K/eK49QUZQMszjkv7TxykIDDe8wjVkkNIABbnz0vYWibaCdyYsTOqqDhrywXhX3uIoUHYqlQdN5Wk11jqnxGFrixojEhy0LEosHry8qjFBNP6H/jyfuFQeZW6+tDW8H3dY+WXYRkcN6harXmi4o/GewkAkukRVE12+nLXdX deploy@patterns" >> ~/.ssh/authorized_keys

  ssh-keyscan -H github.com >> ~/.ssh/known_hosts
  exit # back to root.
fi

#we've provisioned this server

touch /etc/provisioned