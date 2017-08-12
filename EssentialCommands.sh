# copy th admin.pem 
cp chef-server/secrets/admin.pem .chef

# set FDQN for Chef Server based on IP from Vagrantfile (Chef Server and Node1)
echo "10.1.1.33 chef-server.test" | tee -a /etc/hosts

#  run these commands to fetch and verify the SSL certificate from your Chef server.
knife ssl fetch

#The certificate is added to your .chef/trusted_certs directory.
knife ssl check

#UPLOAD COOKBOOKS TO CHEF SERVER
# Run this command from anywhere under your ROOT directory.
knife cookbook upload jenkins

# verify cookbook exists on chef server
knife cookbook list

# https://learn.chef.io/tutorials/manage-a-node/ubuntu/virtualbox/run-chef-client-periodically/

# a onetime setup Bootstraping
# knife bootstrap is the command you use to bootstrap a node. As part of the knife bootstrap command, you specify 
# arguments depending on how you would normally connect to your node over SSH. For example, you might connect to your 
# system using key-based authentication or password authentication.
# to build this command we can execute the following:
# vagrant ssh-config node1-ubuntu which provides port and indentity file location on our environment
knife bootstrap localhost --ssh-port 2200 --ssh-user vagrant --sudo --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node1-ubuntu/virtualbox/private_key --node-name node1-ubuntu --run-list 'recipe[learn_chef_apache2]'


#get the node IP address
knife ssh localhost 'sudo chef-client' --ssh-user vagrant --sudo --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node1-ubuntu/virtualbox/private_key   --attribute 'node[:ipaddress]'

# we can verify by executing 
# knife node list
# knife node show node1-ubuntu


# modifying and re-uploading a Cookbook
# runs chef-client on the node itself from our workstation (OX X in my case)
# NOTE: running knife ssh actually executes on all nodes!
#  Remember, in practice it's common to configure Chef to act as a service that runs periodically or as part of a 
#  continuous integration or continuous delivery (CI/CD) pipeline. For now, we're updating our server configuration by #  running chef-client manually.

# upload changes
knife cookbook upload jenkins

#finally trigger node to execute changes	
knife ssh  'node1-ubuntu' --ssh-port 2200 'sudo chef-client' --manual-list --ssh-user vagrant --identity-file /Users/sharepointoscar/git-repos/OscarTheChef/chef-server/.vagrant/machines/node1-ubuntu/virtualbox/private_key


# Updating All Cookbooks and corresponding dependencies
# You could run knife cookbook upload to manually upload each cookbook. 
# An easier way is to run berks upload. Like berks install, berks upload handles dependencies for you
SSL_CERT_FILE='.chef/trusted_certs/chef-server_test.crt' berks upload


#To update your node's run-list, you could use the knife node run_list set command. However, that does not set the appropriate node attributes.
# To accomplish both tasks, you'll use a role. Roles enable you to focus on the function your node performs collectively rather than each of its 
# individual components (its run-list, node attributes, and so on). For example, you might have a web server role, a database role, 
# or a load balancer role. Here, you'll create a role named web to define your node's function as a web server.

# Roles are stored as objects on the Chef server. To create a role, you can use the knife role create command. 
# Another common way is to create a file (in JSON format) that describes your role and then run the knife role from file command 
# to upload that file to the Chef server. The advantage of creating a file is that you can store that file in a version control system such as Git.

#create role json file example in /roles/web.json
# next execute the following command to upload
#Next, run the following knife role from file command to upload your role to the Chef server.
knife role from file roles/web.json

#verify
knife role list

# or for more detail
knife role show web

#The final step is to set your node's run-list. Run the following knife node run_list set command to do that.

knife node run_list set node1-ubuntu "role[web]"

#As a verification step, you can run the knife node show command to view your node's run-list.

knife node show node1-ubuntu --run-list

#You're now ready to run chef-client on your node. 
# NOTE: Difference is the runlist is now the role web we created "role[web]" vs 
knife ssh localhost --ssh-port 2201 'sudo chef-client' --manual-list --ssh-user vagrant --identity-file /Users/sharepointoscar/learn-chef/chef-server/.vagrant/machines/node1-ubuntu/virtualbox/private_key

# verify
# Every 5–6 minutes you'll see that your node performed a recent check-in with the Chef server and ran chef-client
knife status 'role:web' --run-list


