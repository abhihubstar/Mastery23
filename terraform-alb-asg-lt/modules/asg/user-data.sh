#! /bin/bash
# exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
# echo "Hello from user-data!"
# sudo yum install httpd -y
# sudo systemctl enable httpd
# sudo systemctl start httpd
sudo yum update -y
sudo amazon-linux-extras install php8.0 mariadb10.5
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd


echo "<html>" > index.html
echo "<h1><center>Welcome to Mastery23</center></h1>" >> index.html
# echo "<p>Instance ID: $(curl http://169.254.169.254/latest/meta-data/instance-id)</p>" >> index.html
# echo "<p>Host: $(curl http://169.254.169.254/latest/meta-data/hostname)</p>" >> index.html
# echo "<p>Availability Zone: $AZ</p>" >> index.html
# echo "<p>AMI: $(curl http://169.254.169.254/latest/meta-data/ami-id)</p>" >> index.html
# echo "<p>Public IP: $(curl http://169.254.169.254/latest/meta-data/public-ipv4)</p>" >> index.html

echo "</html>" >> index.html
sudo cp index.html /var/www/html/index.html