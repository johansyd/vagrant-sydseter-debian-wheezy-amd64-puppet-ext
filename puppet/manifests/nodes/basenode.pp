# == node: basenode
# manifest for base configuration, will be used by all scripts
# See: http://projects.puppetlabs.com/projects/1/wiki/Advanced_Puppet_Pattern
# Johan Sydseter, <johan.sydseter@startsiden.no>
Exec { path => '/usr/bin:/bin:/usr/sbin:/sbin' }

node basenode {
}

