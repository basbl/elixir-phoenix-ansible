#If your Vagrant version is lower than 1.5, you can still use this provisioning
#by commenting or removing the line below and providing the config.vm.box_url parameter,
#if it's not already defined in this Vagrantfile. Keep in mind that you won't be able
#to use the Vagrant Cloud and other newer Vagrant features.
Vagrant.require_version ">= 1.5"

# Set Ansible roles path to custom roles
ENV['ANSIBLE_ROLES_PATH'] = "ansible/vendor/roles"

Vagrant.configure("2") do |config|

    config.vm.provider :virtualbox do |v|
        v.name = "elixir-phoenix.dev.basbloembergen.nl"
        v.customize [
            "modifyvm", :id,
            "--name", "elixir-phoenix.dev.basbloembergen.nl",
            "--memory", 2048,
            "--natdnshostresolver1", "on",
            "--cpus", 2,
        ]
    end

    config.vm.box = "ubuntu/xenial64"

    config.vm.network :private_network, ip: "192.168.56.137"
    config.vm.hostname = "elixir-phoenix.dev.basbloembergen.nl"

    if Vagrant.has_plugin?("vagrant-hostsupdater")
        config.hostsupdater.aliases = [
            'www.dev.elixir-phoenix.com',
            'dev.elixir-phoenix.com'
        ]
    end

    config.ssh.forward_agent = true

    config.vm.provision "ansible" do |ansible|
        ansible.galaxy_role_file = "ansible/requirements.yml"
        ansible.galaxy_roles_path = "ansible/vendor/roles"
        ansible.playbook = "ansible/dev.yml"
        ansible.inventory_path = "ansible/inventory/dev-hosts"
        ansible.verbose = 'vv'
        ansible.limit = 'dev'
    end

    # Mount host directories
    if (/darwin/ =~ RUBY_PLATFORM) != nil
        # OS X
        config.vm.synced_folder "./", "/vagrant", type: "nfs", mount_options: ['nolock,vers=3,udp,noatime,actimeo=1']
    else
        # Assume Linux
        config.vm.synced_folder "./", "/vagrant", type: "nfs", mount_options: ['nolock,udp,noatime,actimeo=1']
    end
end
