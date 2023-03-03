#! /bin/bash
sudo yum update -y
sudo amazon-linux-extras install php8.0 mariadb10.5
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<html>" > index.html
echo "<h1><center>Welcome to Mastery23</center></h1>" >> index.html
echo "</html>" >> index.html
sudo cp index.html /var/www/html/index.html