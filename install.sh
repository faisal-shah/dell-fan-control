#!/usr/bin/env bash

# install i8kutils package
sudo apt -y install i8kutils

#add i8k to /etc/modules
sudo bash -c "grep -wq i8k /etc/modules || echo i8k >> /etc/modules"

# copy stuff
sudo cp fan-control.bash /usr/local/bin/
sudo cp fan-control.service /etc/systemd/system/
sudo cp cpu-temp-stable-path.rules /etc/udev/rules.d/

# Reload udev rules and trigger
sudo udevadm control --reload-rules && udevadm trigger

# enable systemd unit and start it
sudo systemctl enable fan-control
sudo systemctl start fan-control
