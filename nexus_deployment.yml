---
- name: Deploy Nexus as Docker Container
  hosts: all
  become: true

  vars:
    nexus_data_dir: /opt/nexus-data
    nexus_image: sonatype/nexus3
    nexus_port: 8081

  tasks:
    # Update and upgrade system
    - name: Update and upgrade the system
      apt:
        update_cache: yes
        upgrade: dist

    # Install Docker
    - name: Install prerequisites for Docker
      apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - software-properties-common
        state: present

    - name: Add Docker GPG key
      shell: |
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
      args:
        executable: /bin/bash

    - name: Add Docker repository
      lineinfile:
        path: /etc/apt/sources.list.d/docker.list
        line: "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        state: present

    - name: Install Docker
      apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
        state: present

    # Create Nexus data directory
    - name: Create Nexus data directory
      file:
        path: "{{ nexus_data_dir }}"
        state: directory
        mode: '0200'

    # Run Nexus container
    - name: Run Nexus container
      docker_container:
        name: nexus
        image: "{{ nexus_image }}"
        state: started
        ports:
          - "8081:8081"
        volumes:
          - "{{ nexus_data_dir }}:/nexus-data"
        restart_policy: unless-stopped

    # Configure firewall
    - name: Allow required ports in UFW
      ufw:
        rule: allow
        port: "{{ nexus_port }}"
        proto: tcp
