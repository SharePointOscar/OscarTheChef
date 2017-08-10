# Oscar The Chef

My Chef Vagrant environment (uses one node)

## Getting Started
To get started, first bring up the Vagrant environment by executing the following

`$ vagrant up

The Vagrantfile contains two provisioning scripts, one for the Chef Server and one for the Node server.  


**The Server Script**

This script does the following
* Peform updates to the Linux box
* Sync time
* Download the Chef Server version indicated in the script
* Install Chef Server
* Create an admin user (this is helpful for when you sign into the web management console)
* Ensures services are up and running
* Copy the private key to the chef server

**Testing install**
more soon..