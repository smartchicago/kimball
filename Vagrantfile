# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 3000

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
    config.cache.enable :generic, {
      "rbenv"=>{:cache_dir => "/home/vagrant/.rbenv" }
    }

    if !Gem.win_platform?
      # passwordless nfs
      # https://gist.github.com/cromulus/5044b9558319769aaf0b
      config.cache.synced_folder_opts = {
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
    end
  else
    puts "please run 'vagrant plugin install vagrant-cachier'"
    puts "It will make vagrant substantially faster"
  end

  if Vagrant.has_plugin?('vagrant-hostmanager')
    # passwordless
    # https://github.com/smdahlen/vagrant-hostmanager#passwordless-sudo
    if !Gem.win_platform?
      me = `whoami`.chomp
      config.vm.hostname = "#{me}.patterns.dev"
    else
      # this should work:
      # http://stackoverflow.com/questions/3251757/ruby-get-currently-logged-in-user-on-windows
      config.vm.hostname = "#{ENV['USERNAME']}.patterns.dev"
    end
    config.hostmanager.enabled = true
    config.hostmanager.include_offline = true
    config.hostmanager.manage_host = true
  else
    puts "run 'vagrant plugin install vagrant-hostmanager'"
    puts "It will help you find your dev environment!"
  end

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../relay", "/relay"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #

  config.vm.provider "virtualbox" do |vb, override|
  # Don't display the VirtualBox GUI when booting the machine
    vb.gui = false

  # Customize the amount of memory on the VM:
    vb.memory = "1024"

    # passwordless nfs
    # https://gist.github.com/cromulus/5044b9558319769aaf0b
    # also this one: https://gist.github.com/GUI/2864683
    override.vm.synced_folder '.', '/vagrant', type: 'nfs'
    override.vm.network "private_network", ip: "192.168.33.124"
  end

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    sudo apt-get -qq update
    sudo apt-get -qq install -y \
      mysql-server-5.6 \
      libmysqlclient-dev \
      mysql-client-5.6 \
      rbenv \
      ruby-build \
      git \
      nodejs \
      redis-server \
      graphviz \
      nginx-full

    #   postgresql-server-dev-9.3 \
    #   postgresql-9.3
    # # configuring postgres
    # sudo -u postgres psql -c "create role root with createdb login password 'password';"
    # sudo cp -rf /vagrant/config/server_conf/pg_hba.conf /etc/postgresql/9.3/main/
    # sudo service postgresql restart

    # set path and init rbenv
    echo 'export PATH="$HOME/.rbenv/bin:/vagrant/bin/:$PATH"' >> /home/vagrant/.profile
    echo 'eval "$(rbenv init -)"' >> /home/vagrant/.profile

    # automatically cd to /vagrant/
    echo 'if [ -d /vagrant/ ]; then cd /vagrant/; fi' >> /home/vagrant/.bashrc

    if [ ! -d /home/vagrant/.rbenv ]; then
      git clone -q https://github.com/sstephenson/rbenv.git ~/.rbenv
      git clone -q https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    else
      cd ~/.rbenv && git pull;
      cd ~/.rbenv/plugins/ruby-build && git pull;
    fi
    cd ~
    source ~/.profile

    rbenv install `cat /vagrant/.ruby-version`
    rbenv rehash
    # setup our particular rails app
    cd /vagrant/
    gem install bundler --no-ri --no-rdoc
    bundle install --quiet
    bundle exec rake db:setup
    bundle exec unicorn_rails -D

    # setting up nginx to serve our app
    if [ -L /etc/nginx/sites-enabled/default ]; then
      sudo rm /etc/nginx/sites-enabled/default
    fi
    sudo ln -s /vagrant/config/server_conf/nginx.conf /etc/nginx/sites-enabled
    sudo mkdir -p /var/run/nginx/tmp
    sudo chown -R www-data:www-data /var/run/nginx/
    sudo service nginx restart
  SHELL
end
