##Configuration done before packaging

### Upgrading the installation
    sudo su
    # uncomment the iso cd entry from sources.list, save and exit
    pico /etc/apt/sources.list

    # deb cdrom:[Debian GNU/Linux wheezy-DI-b4 _Wheezy_ - Official Snapshot amd64 CD Binary-1 20121117-20:31]/ wheezy main

    apt-get update
    apt-get upgrade

###Install sudo

    sudo su # if you haven't already done so

    apt-get install sudo

    # add admin group and attach the vagrant user to the group
    visudo

    # Add this line, save and exit
    %admin	ALL=NOPASSWD: ALL

    groupadd admin
    usermod -G admin vagrant
    # Restart sudo
    /etc/init.d/sudo restart
    exit 
    exit
    # login with username vagrant and password vagrant and test sudo for vagrant
    sudo which sudo
    # should output: /usr/bin/sudo

###Install build-essentials

    sudo apt-get install linux-headers-$(uname -r) build-essential

    # restart the vm image

###Installing Guest Additions

    sudo apt-get install virtualbox-guest-utils

    # setup ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext as a shared folder with the name share the folder will be accessible from /media/sf_share for root

    # retart the vm image

###Install and configure ssh

    # Generate  ssh keys on the host machine (outside the vm image)

    mkdir -p ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh
    chmod 700 ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh
    cd ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh
    ssh-keygen -t rsa -C "vagrant@vagrantup.com"

    # passphrase was left empty

    # on the vm image

    sudo apt-get install ssh

    mkdir home/vagrant/.ssh

    sudo cat /media/sf_share/ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys

    chown -R vagrant:vagrant /home/vagrant/.ssh

    cp /home/vagrant/.ssh/authorized_keys /home/vagrant/.ssh/id_rsa.pub

    chmod 0600 ~/.ssh/*

    chmod 0700 ~/.ssh

###Install ruby and puppet

    # On the virtualbox image

    sudo apt-get install ruby1.8-dev
    sudo apt-get install puppet

    # make sure the group puppet is present

    sudo groupadd puppet

###Tweeks
    # On the virtualbox image

    pico /etc/ssh/sshd_config

    # change UseDNS to no

    # delete cache

    sudo apt-get clean
###Reducing size
    git clone https://github.com/johansyd/vm-utils ~/vm-utils
    # set up ~/vm-utils as a shared folder with the name 'share' and boot into the vm image
    # install tool for deleting empty space

    sudo apt-get install zerofree

    sudo su

    cd /media/sf_share
    
    ./freespace.sh
    
    # Boot into single user mode
    init 1

    # make vm image read-only
    mount -o remount,ro /dev/sda1
    
    # delete empty space
    zerofree /dev/sda1

    # make vm image writeable
    mount -o remount,rw /dev/sda1
    
    sudo apt-get remove zerofree
    exit
    
    # login to the vm image again

    sudo su
    cd /media/sf_share
    ./freespace.sh
    exit

###Configuring puppet

    sudo pico /etc/puppet/puppet.conf

    # Add the following lines before [master]
    external_nodes = /etc/puppet/node.rb
    node_terminus = exec

    # add a symbolic link to the external node script for parsing yaml 
    # configuration files from forman or yaml for initialization of 
    # modules by puppet

    # The defult root share, initalized by vagrant has to be /vagrant for
    # this to work.
    cd /etc/puppet
    sudo ln -s /vagrant/puppet/utils/node.rb node.rb
    sudo ln -s /vagrant/puppet/yaml yaml

###Packaging box

    # shutdown vm image and remove shared folder

    # on the host machine

    cd ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext

    vagrant init


see to it that the ssh private key exist:
    ls ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh/id_rsa

Create the vagrant file

    vim Vagrantfile

Add this to the Vagrantfile

    require './services/git_cloningservice.rb'
    # etc dir for abcn vagrant yaml configuration files 
    git_etc = File.dirname(__FILE__) + '/etc'

    # yaml configuration file suffix
    git_config_suffix = 'git'

    # Load the config
    git_cloning_service = Git::CloningService.new(
    git_etc, 
    git_config_suffix)

    # Clone out the repositories if necessary
    git_cloning_service.clone

    # Get the location of the source folder where all the git repositories are stored
    # reuse this variable as a base for all shared vagrant folders
    git_src = git_cloning_service.src

    Vagrant::Config.run do |config|
      # All Vagrant configuration is done here. The most common configuration
      # options are documented and commented below. For a complete reference,
      # please see the online documentation at vagrantup.com.

      # Every Vagrant virtual environment requires a box to build off of.
      config.vm.box = 'vagrant-sydseter-debian-wheezy-amd64-puppet-ext'
      config.ssh.username = 'vagrant'
      config.ssh.host = '127.0.0.1'

      # Private ssh key
      config.ssh.private_key_path = File.dirname(__FILE__) + '/ssh/id_rsa'

      # The url from where the 'config.vm.box' box will be fetched if it
      # doesn't already exist on the user's system.
      config.vm.box_url = "http://www.sydseter.com/vagrant/vagrant-sydseter-debian-wheezy-amd64-puppet-ext.box"

      config.vm.provision :puppet do |puppet|
          puppet.module_path    = 'puppet/modules'
          puppet.manifests_path = "puppet/manifests"
          puppet.manifest_file  = "site.pp"
      end
    end

####Adding documentation

    mkdir -p ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh/id_rsa/doc/images
    # copied the screen shots from the installation process to ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh/id_rsa/doc/images

####Saving this file as
    # Ctrl-S as ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh/id_rsa/doc/PACKAGING.md
    # Ctrl-S as ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh/id_rsa/doc/README.md

    vagrant package vagrant-sydseter-debian-wheezy-amd64-puppet-ext --base vagrant-sydseter-debian-wheezy-amd64-puppet-ext --output vagrant-sydseter-debian-wheezy-amd64-puppet-ext.box

####Testing the box
    vagrant box add vagrant-sydseter-debian-wheezy-amd64-puppet-ext vagrant-sydseter-debian-wheezy-amd64-puppet-ext.box
    vagrant up
