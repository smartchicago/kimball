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

apt-get update && apt-get install -y mysql-server libmysqlclient-dev redis-server openjdk-6-jre elasticsearch git git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libgmp-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev nginx gpgv2 ruby-dev openjdk-7-jre autoconf libgdbm-dev libncurses5-dev automake libtool bison gawk g++ gcc make libreadline6-dev zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev nodejs

service elasticsearch start
# we don't want the default nginx server setup.
rm /etc/nginx/sites-enabled/default
openssl dhparam -dsaparam -out /etc/nginx/dhparam.pem 2048
#service nginx stop
cd /root
git clone https://github.com/letsencrypt/letsencrypt
/root/letsencrypt/letsencrypt-auto certonly --standalone --agree-tos --email blueridgelabs@robinhood.org -d patterns.brl.nyc

#service nginx start
cat >/etc/cron.weekly/letsencrypt.sh <<EOL
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH
/root/letsencrypt/letsencrypt-auto certonly --webroot -w /var/www/logan-production/current/public --agree-tos --email blueridgelabs@robinhood.org -d patterns.brl.nyc
service nginx restart
EOL
chmod +x /etc/cron.weekly/letsencrypt.sh

#passwordless sudo for logan, or else we can't install rvm
echo 'logan ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/logan

mkdir /var/www/logan-production
mkdir /var/www/logan-staging


# creating the logan user.
getent passwd logan  > /dev/null
if [ $? -eq 0 ]; then
  echo "skipping user creation"
else
  useradd -m -s /bin/bash logan;
  su - logan
  mkdir ~/.ssh/
  cat >~/.ssh/authorized_keys <<EOL
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUkhUCqUdEjpm92sN5OGW7cLekAJNdT0HTDqCsUR28I3eB1lelKLWGDhIkR2L3TZmiX511+ZfaydgrFJEUqT+gotUKmWmW9CVpt5OQTZPPNJBkZ99uXYqg2sLHpAptacVIn/UGS4RRvMG6gT+pYiI1epyY0F0uqeNDVwO0HAo7pLxS7K/eK49QUZQMszjkv7TxykIDDe8wjVkkNIABbnz0vYWibaCdyYsTOqqDhrywXhX3uIoUHYqlQdN5Wk11jqnxGFrixojEhy0LEosHry8qjFBNP6H/jyfuFQeZW6+tDW8H3dY+WXYRkcN6harXmi4o/GewkAkukRVE12+nLXdX deploy@patterns
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRCFqdXUioU3N1GIRK5bowUfJ9DKswJeMp6diQDOfCU4rKN4Y6jg/Xzl8ijTXsH3e+q3hvpPAbynjNF9cK3af93tdMQ49fJajPRVlM+mZW2MXkJAnI0TkqGWqwk93KqnVAajVdaDo+jEFqdNvYzYLeqwAJUaED0OyD/GlOBlF0NV9kT2mVXGtCdcJ+ItTqFwtn6NcAuXg+/5S2ZpBJGjf1mOVyLAHdbGg00L5YY2GpU4s7L02fKqIdOzNgmU2ek74ba0F74KTcEvReRNePFjlCNZqrbqiw6dgOoo9BGjbCploNdmUzA4DJ9CQHx3lBPQXLjEiNx+kMUkxC0JxlVQbb cromie@zephyr.local
EOL
  # so we don't have key failures for github
  ssh-keyscan -H github.com >> ~/.ssh/known_hosts

  # installing ruby and rvm
  gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  curl -sSL https://get.rvm.io | bash -s stable
  source /home/logan/.rvm/scripts/rvm
  rvm install 2.2.4
  rvm use 2.2.4@staging --create
  rvm use 2.2.4@production --create
  rvm @global do gem install backup bundler rake
  ln -s /var/www/logan-production
  ln -s /var/www/logan-staging
  exit # back to root.
fi

# remove our logan passwordless sudo, for security
rm /etc/sudoers.d/logan
chown -R logan:logan /var/www/logan*

#we've provisioned this server
touch /etc/provisioned

# now run:
# cap staging deploy:setup
# cap staging deploy:cold