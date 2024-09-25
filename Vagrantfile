# -*- mode: ruby -*-
# vi: set ft=ruby :

# A Vagrantfile to set up two VMs, a frontend UI, database, and a backend.

Vagrant.configure("2") do |config|
    config.vm.hostname = "ubuntu"

    # Typical `vagrant up` seems to assume the Docker provider anyway, but
    # `vagrant up --provider=docker` would be even more explicit.
    # Thanks to https://github.com/rofrano/vagrant-docker-provider and example given by dme26 in lab files
    config.vm.provider :docker do |docker, override|
        override.vm.box = nil
        docker.image = "anthonyydng/vagrant-provider:ubuntu"
        docker.remains_running = true
        docker.has_ssh = true
        docker.privileged = true
        docker.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
        docker.create_args = ["--cgroupns=host"]
      end
    
    # VM 1 - Frontend UI
    config.vm.define "frontendserver" do |frontendserver|
        frontendserver.vm.hostname = "frontendserver"
        frontendserver.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
        frontendserver.vm.network "private_network", ip: "192.168.56.11"
        # may be important for markers
        frontendserver.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", mount_options: ["dmode=775,fmode=777"]
        frontendserver.vm.provision "shell", path: "build-frontendserver-vm.sh"
    end

    # VM 2 - Database
    config.vm.define "dbserver" do |dbserver|
        dbserver.vm.hostname = "dbserver"
        dbserver.vm.network "forwarded_port", guest: 80, host: 8088, host_ip: "127.0.0.1"
        # note that no two vms should use the same private_network ip address
        dbserver.vm.network "private_network", ip: "192.168.56.12"
        dbserver.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", mount_options: ["dmode=775,fmode=777"]

        dbserver.vm.provision "shell", path: "build-dbserver-vm.sh"
    end

    # VM 3 - Backend
    config.vm.define "backendserver" do |backendserver|
        backendserver.vm.hostname = "backendserver"
        backendserver.vm.network "forwarded_port", guest: 80, host: 8081, host_ip: "127.0.0.1"
        # note that no two vms should use the same private_network ip address
        backendserver.vm.network "private_network", ip: "192.168.56.13"
        # may be important for markers
        backendserver.vm.synced_folder ".", "/vagrant", owner: "vagrant", group: "vagrant", mount_options: ["dmode=775,fmode=777"]
        backendserver.vm.provision "shell", path: "build-backendserver-vm.sh"
    end
end