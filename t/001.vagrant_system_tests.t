#!/bin/sh
puppet apply --modulepath=puppet/modules; ./puppet/manifests/site.pp;
sleep 1;
perl tests/001.vagrant_system_tests.t;
