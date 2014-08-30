# Run under root
sudo su

# Prepare
mkdir -p /etc/docker-gitlab
curl -sSL https://raw.githubusercontent.com/hydra1983/docker-gitlab-helper/master/etc/docker-gitlab/gitlab.conf > /etc/docker-gitlab/gitlab.conf

# Modify parameters
vi /etc/docker-gitlab/gitlab.conf

# Start to install
https://github.com/hydra1983/docker-gitlab-helper/raw/master/install.sh | sh