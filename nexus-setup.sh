#!/bin/bash
# Update the system
sudo yum update -y

# Install Java (Nexus requires Java 8 or higher)
sudo yum install java-1.8.0-amazon-corretto-devel.x86_64 -y

# Create a nexus user
sudo adduser nexus
sudo echo "nexus  ALL=(ALL)       NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nexus

# Download Nexus (adjust the URL to the latest version if needed)
cd /opt
sudo wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz

# Extract the Nexus tarball
sudo tar -xvzf latest-unix.tar.gz
sudo mv nexus-3.* nexus

# Set permissions
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work

# Create a systemd service file for Nexus
sudo tee /etc/systemd/system/nexus.service <<EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Nexus
sudo systemctl enable nexus
sudo systemctl start nexus

# Firewall rule to allow Nexus (if using AWS security groups, ensure the port is open there as well)
sudo firewall-cmd --permanent --add-port=8081/tcp
sudo firewall-cmd --reload
