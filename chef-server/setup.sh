#!/bin/bash

#run these commands to fetch and verify the SSL certificate from your Chef server.
echo "fetch ssl cert from Chef Server"
knife ssl fetch

#The certificate is added to your .chef/trusted_certs directory.
echo "check ssl cert"
knife ssl check

# a onetime setup Bootstraping
# knife bootstrap is the command you use to bootstrap a node. As part of the knife bootstrap command, you specify 
# arguments depending on how you would normally connect to your node over SSH. For example, you might connect to your 
# system using key-based authentication or password authentication.
# to build this command we can execute the following:
# vagrant ssh-config node1-ubuntu which provides port and indentity file location on our environment
echo "Bootstrapping Node1-Ubuntu..."
knife bootstrap localhost --ssh-port 2200 --ssh-user vagrant --sudo --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node1-ubuntu/virtualbox/private_key --node-name node1-ubuntu

echo "Bootstrapping Node2-Ubuntu..."
knife bootstrap localhost --ssh-port 2201 --ssh-user vagrant --sudo --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node2-ubuntu/virtualbox/private_key --node-name node2-ubuntu

echo "Running Berks install"
cd ../ && berks install

echo "Running berks upload to Chef Server"
# Updating All Cookbooks and corresponding dependencies
# You could run knife cookbook upload to manually upload each cookbook. 
# An easier way is to run berks upload. Like berks install, berks upload handles dependencies for you
SSL_CERT_FILE='.chef/trusted_certs/chef-server_test.crt' berks upload

echo "Upload Roles to Chef Server"
# next execute the following command to upload
#Next, run the following knife role from file command to upload your role to the Chef server.
knife role from file roles/web.json && knife role from file roles/database.json

echo "Verify roles are on Chef Servr"
knife role list

echo "Set run_list for reach node to a specific Role"
#The final step is to set your node's run-list. Run the following knife node run_list set command to do that.
knife node run_list set node1-ubuntu "role[web]" && knife node run_list set node2-ubuntu "role[database]"

echo "Verify Run Lists are on our Nodes"
knife node show node1-ubuntu --run-list && knife node show node2-ubuntu --run-list

echo "Run Chef Client on Node1, execute Recipes from Role"
knife ssh localhost --ssh-port 2200 'sudo chef-client' --manual-list --ssh-user vagrant --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node1-ubuntu/virtualbox/private_key

echo "Run Chef Client on Node2, execute Recipes from Role"
knife ssh localhost --ssh-port 2201 'sudo chef-client' --manual-list --ssh-user vagrant --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node2-ubuntu/virtualbox/private_key