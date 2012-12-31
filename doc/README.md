##Configuration done before packaging

### Upgrading the installation
    sudo su
    # uncomment the iso cd entry from sources.list, save and exit
    pico /etc/apt/sources.list

    # deb cdrom:[Debian GNU/Linux wheezy-DI-b4 _Wheezy_ - Official Snapshot amd64 CD Binary-1 20121117-20:31]/ wheezy main

    apt-get update
    apt-get upgrade

###Install sudo

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

sudo apt-get install ruby1.8-dev
sudo apt-get install puppet

# make sure the group puppet is present

groupadd puppet

###Tweeks

    pico /etc/ssh/sshd_config

    # change UseDNS to no

    # delete cache

    sudo apt-get clean
###Reducing size
    # set up ~/vagrant-startsiden-debian-wheezy-amd64 as a shared folder with the name 'share' and boot into the vm image

    sudo su
    
    # Boot into single user mode
    init 1

    # install toll for deleting empty space
    sudo apt-get install zerofree

    # make vm image read-only
    mount -o remount,ro /dev/sda1
    
    # delete empty space
    zerofree /dev/sda1

    # make vm image writeable
    mount -o remount,ro /dev/sda1
    
    sudo apt-get remove zerofree
    exit
    
    # login to the vm image again

    sudo su
    cd /media/sf_share/utils
    sh cleanup.sh
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

    vim Vagrantfile

    # see to it that the ssh private key exist:
    # ~/vagrant-sydseter-debian-wheezy-amd64-puppet-ext/ssh/id_rsa

    # Add this to the Vagrantfile
        # Every Vagrant virtual environment requires a box to build off of.
        config.vm.box = 'vagrant-sydseter-debian-wheezy-amd64-puppet-ext'
        config.ssh.username = 'vagrant'
        config.ssh.host = '127.0.0.1'

    # Private ssh key
    config.ssh.private_key_path = File.dirname(__FILE__) + '/ssh/id_rsa'

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