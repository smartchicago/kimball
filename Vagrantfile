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
  config.vm.box = 'ubuntu/trusty64'

  # config.vm.network "forwarded_port", guest: 80, host: 3000

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.

  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
    config.cache.enable :generic

    unless Gem.win_platform?
      # passwordless nfs
      # https://gist.github.com/cromulus/5044b9558319769aaf0b
      config.cache.synced_folder_opts = {
        type: :nfs,
        mount_options: ['rw', 'vers=3', 'tcp', 'nolock']
      }
    end
  else
    puts "please run 'vagrant plugin install vagrant-cachier'"
    puts 'It will make vagrant substantially faster'
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
    puts 'It will help you find your dev environment!'
  end

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #

  config.vm.provider 'virtualbox' do |vb, override|
    # Don't display the VirtualBox GUI when booting the machine
    vb.gui = false

    # linked clones, they are speedy
    vb.linked_clone = true if Vagrant::VERSION =~ /^1.8/
    # Customize the amount of memory on the VM:
    vb.memory = '2048'
    vb.cpus = '2'

    # passwordless nfs
    # https://gist.github.com/cromulus/5044b9558319769aaf0b
    # also this one: https://gist.github.com/GUI/2864683
    override.vm.synced_folder '.', '/vagrant', type: 'nfs'
    override.vm.network 'private_network', ip: '192.168.33.124'
  end

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

  # splitting shell provisioning for caching benefits.
  config.vm.provision :shell, privileged: false, inline: %(
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
    sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'

    # installing elastic search
    wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
    echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" |  sudo tee -a /etc/apt/sources.list.d/elasticsearch-2.x.list
    sudo apt-get -qq update
    sudo apt-get -qq install -y \
      mysql-server-5.6 \
      libmysqlclient-dev \
      mysql-client-5.6 \
      rbenv \
      ruby-build \
      ruby-dev \
      libgmp3-dev \
      git \
      nodejs \
      graphviz \
      nginx-full \
      openjdk-7-jre \
      phantomjs \
      elasticsearch

    mysqladmin -u root -ppassword password '';
    sudo update-rc.d elasticsearch defaults;
    sudo service elasticsearch start;
    # automatically cd to /vagrant/
    echo 'if [ -d /vagrant/ ]; then cd /vagrant/; fi' >> /home/vagrant/.bashrc
  )

  config.vm.provision :shell, privileged: false, inline: %(
    echo 'gem: --no-rdoc --no-ri' | sudo tee /etc/gemrc;
    # rvm install is idempotent
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles
    source ~/.profile
  )

  config.vm.provision :shell, privileged: false, inline: %(
    # cleanup and install the appropriate ruby version
    source ~/.profile
    rvm reload
    rvm use --default install `cat /vagrant/.ruby-version`
    rvm cleanup all
  )
  config.vm.provision :shell, privileged: false, inline: %(
    # setup our particular rails app
    source ~/.profile
    cd /vagrant/
    gem update --system
    gem install bundler --no-ri --no-rdoc
    bundle install --quiet
    bundle exec rake db:setup
    bundle exec unicorn_rails -D

    # setting up nginx to serve our app
    if [ -L /etc/nginx/sites-enabled/default ]; then
      sudo rm /etc/nginx/sites-enabled/default
    fi
    sudo ln -s /vagrant/config/server_conf/vagrant_nginx.conf /etc/nginx/sites-enabled
    sudo mkdir -p /var/run/nginx/tmp
    sudo chown -R www-data:www-data /var/run/nginx/
    sudo service nginx restart
  )
end
