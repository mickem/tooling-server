# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.box = "precise64"
	config.vm.box_url = "http://files.vagrantup.com/precise64.box"
	config.vm.hostname = "tooling.medin.name"
	config.vm.synced_folder "files", "/etc/puppet/files"
	config.vm.synced_folder "templates", "/tmp/vagrant-puppet/templates"

	config.ssh.forward_agent = true
	config.vm.network "forwarded_port", guest: 80, host: 8080

	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, "--memory", "1024"]
		vb.gui = false
	end


	config.vm.provision :shell do |shell|
		shell.inline = "mkdir -p /etc/puppet/modules;
				if [ ! -d /etc/puppet/modules/nginx/ ]; then puppet module install jfryman-nginx; fi;
				if [ ! -d /etc/puppet/modules/vcsrepo/ ]; then puppet module install puppetlabs-vcsrepo; fi;
				if [ ! -d /etc/puppet/modules/ruby/ ]; then puppet module install puppetlabs-ruby; fi;
				if [ ! -d /etc/puppet/modules/mysql/ ]; then puppet module install puppetlabs-mysql; fi;
				if [ ! -d /etc/puppet/modules/redis/ ]; then puppet module install thomasvandoren-redis; fi;
				if [ ! -d /etc/puppet/modules/ldap/ ]; then puppet module install torian-ldap; fi;
				"
	end

	config.vm.provision :puppet do |puppet|
		puppet.manifests_path = "manifests"
		puppet.module_path    = "modules"
		puppet.manifest_file  = "base.pp"
	end

end
