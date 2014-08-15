# Run under root
sudo su

# Prepare ENV
curl -sSL https://get.docker.io/ubuntu/ | sh
apt-get install -y --force-yes sshpass mysql-client-core-5.5

mkdir -p /etc/docker-gitlab
mkdir -p /opt/mysql/data
mkdir -p /opt/gitlab/data

# Initialise MySQL
wget https://github.com/hydra1983/docker-gitlab-helper/blob/master/etc/docker-gitlab/gitlab.conf -O /etc/docker-gitlab/gitlab.conf
source /etc/docker-gitlab/gitlab.conf
docker run --name=mysql -d -p 3306:3306 -v /opt/mysql/data:/var/lib/mysql sameersbn/mysql:latest
mysql_ssh_host=`docker inspect mysql | grep IPAddres | awk -F'"' '{print $4}'`
mysql -h$mysql_ssh_host -uroot -e "CREATE USER '$DB_USER'@'172.17.%.%' IDENTIFIED BY '$DB_PASS';"
mysql -h$mysql_ssh_host -uroot -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` DEFAULT CHARACTER SET \`utf8\` COLLATE \`utf8_unicode_ci\`;"
mysql -h$mysql_ssh_host -uroot -e "GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON \`$DB_NAME\`.* TO '$DB_USER'@'172.17.%.%';"
mysql -h$mysql_ssh_host -uroot -e "FLUSH PRIVILEGES;"
docker run --name=gitlab -i -t --rm --link mysql:mysql -e "DB_USER=$DB_USER" -e "DB_PASS=$DB_PASS" -e "DB_NAME=$DB_NAME" -v /opt/gitlab/data:/home/git/data sameersbn/gitlab:$CURRENT_VERSION app:rake gitlab:setup
docker stop mysql
docker rm mysql

# Start Gitlab
wget https://github.com/hydra1983/docker-gitlab-helper/raw/master/etc/init.d/docker-gitlab -O /etc/init.d/docker-gitlab
chmod +x /etc/init.d/docker-gitlab
/etc/init.d/docker-gitlab start