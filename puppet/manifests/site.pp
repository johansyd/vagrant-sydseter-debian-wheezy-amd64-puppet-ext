# Author: Johan Sydseter, <johan.sydseter@startsiden.no>
# File resources are not refreshed if nodes are globed into site.pp
# import "nodes/*.pp"

# import nodes
import "nodes/wheezybuild64.startsiden.no.pp"
import "nodes/vagrant-sydseter-debian-wheezy-amd64-puppet-ext.vagrantup.com.pp"
