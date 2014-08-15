sudo su
mkdir /etc/docker-gitlab
wget https://gist.github.com/hydra1983/125d2dc9885259308ed2/raw/2aba13ec60893b6652e5c3e0c5b08b6e54af0527/gitlab.conf -O /etc/docker-gitlab/gitlab.conf
wget https://gist.github.com/hydra1983/125d2dc9885259308ed2/raw/fe9b15e73c836128c5cce264a49b81b0212a9f77/daemon.conf -O /etc/docker-gitlab/daemon.conf

curl -sSL https://get.docker.io/ubuntu/ | sh

#host_ip=`ifconfig eth0|awk -F"[: ]+" '/inet addr/{print $4}'`
apt-get install -y --force-yes sshpass mysql-client-core-5.5

mkdir -p /opt/mysql/data
mkdir -p /opt/gitlab/data

docker run --name=mysql -d -p 20022:22 -p 3306:3306 -v /opt/mysql/data:/var/lib/mysql sameersbn/mysql:latest

mysql_ssh_host=`docker inspect mysql | grep IPAddres | awk -F'"' '{print $4}'`
mysql -h$mysql_ssh_host -uroot -e "CREATE USER 'gitlab'@'172.17.%.%' IDENTIFIED BY 'password';"
mysql -h$mysql_ssh_host -uroot -e "CREATE DATABASE IF NOT EXISTS \`gitlabhq_production\` DEFAULT CHARACTER SET \`utf8\` COLLATE \`utf8_unicode_ci\`;"
mysql -h$mysql_ssh_host -uroot -e "GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON \`gitlabhq_production\`.* TO 'gitlab'@'172.17.%.%';"
mysql -h$mysql_ssh_host -uroot -e "FLUSH PRIVILEGES;"

docker run --name=gitlab -i -t --rm --link mysql:mysql -e "DB_USER=gitlab" -e "DB_PASS=password" -e "DB_NAME=gitlabhq_production" -v /opt/gitlab/data:/home/git/data sameersbn/gitlab:7.0.0 app:rake gitlab:setup

docker stop mysql
docker rm mysql
wget https://gist.github.com/hydra1983/125d2dc9885259308ed2/raw/fa2fd21f8d85a8e0ba2aa35d052fe5ae27702fbc/docker-gitlab.sh -O /etc/init.d/docker-gitlab
chmod +x /etc/init.d/docker-gitlab
/etc/init.d/docker-gitlab start
