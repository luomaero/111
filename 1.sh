#！/bin/bash
sudo apt-get install lighttpd git hostapd dnsmasq iptables-persistent vnstat qrencode php7.3-cgi
sudo lighttpd-enable-mod fastcgi-php
sudo service lighttpd force-reload
sudo systemctl restart lighttpd.service
sudo rm -rf /var/www/html
sudo git clone https://gitee.com/ursaminor68/raspap-webgui.git /var/www/html
cd /var/www/html
sudo cp installers/raspap.sudoers /etc/sudoers.d/090_raspap
sudo mkdir /etc/raspap/
sudo mkdir /etc/raspap/backups
sudo mkdir /etc/raspap/networking
sudo mkdir /etc/raspap/hostapd
sudo mkdir /etc/raspap/lighttpd
cat /etc/dhcpcd.conf | sudo tee -a /etc/raspap/networking/defaults > /dev/null
sudo cp raspap.php /etc/raspap
sudo chown -R www-data:www-data /var/www/html
sudo chown -R www-data:www-data /etc/raspap
sudo mv installers/*log.sh /etc/raspap/hostapd
sudo mv installers/service*.sh /etc/raspap/hostapd
sudo chown -c root:www-data /etc/raspap/hostapd/*.sh
sudo chmod 750 /etc/raspap/hostapd/*.sh
sudo cp installers/configport.sh /etc/raspap/lighttpd
sudo chown -c root:www-data /etc/raspap/lighttpd/*.sh
sudo mv installers/raspapd.service /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable raspapd.service
sudo mv /etc/default/hostapd ~/default_hostapd.old
sudo cp /etc/hostapd/hostapd.conf ~/hostapd.conf.old
sudo cp config/default_hostapd /etc/default/hostapd
sudo cp config/hostapd.conf /etc/hostapd/hostapd.conf
sudo cp config/dnsmasq.conf /etc/dnsmasq.d/090_raspap.conf
sudo cp config/dhcpcd.conf /etc/dhcpcd.conf
sudo cp config/config.php /var/www/html/includes/
sudo systemctl stop systemd-networkd
sudo systemctl disable systemd-networkd
sudo cp config/raspap-bridge-br0.netdev /etc/systemd/network/raspap-bridge-br0.netdev
sudo cp config/raspap-br0-member-eth0.network /etc/systemd/network/raspap-br0-member-eth0.network
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/90_raspap.conf > /dev/null
sudo sysctl -p /etc/sysctl.d/90_raspap.conf
sudo /etc/init.d/procps restart
sudo iptables -t nat -A POSTROUTING -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 192.168.50.0/24 ! -d 192.168.50.0/24 -j MASQUERADE
sudo iptables-save | sudo tee /etc/iptables/rules.v4
sudo systemctl unmask hostapd.service
sudo systemctl enable hostapd.service