#!/usr/bin/env bash
#
# bootstrap.sh - setup chef solo
#
# NODENAME='foo' CHEF_ENV='production' RUNLIST='["role[foo]","recipe[bar]"]' CHEFREPO='git@example.com:repo.git' bash <( curl -L https://raw.github.com/gist/1026628 )
# You will need to ensure that the ssh key is already set up on the server.
NODENAME='cybertron'
CHEF_ENV='production'
RUNLIST=''
CHEFREPO=''

 
set -e
 
export CHEF_DIR="${HOME}/chef"
sudo rm -rf $CHEF_DIR
mkdir -p "$CHEF_DIR"
 
echo "-- Installing Packages"
 
sudo apt-get install -y ruby ruby-dev libopenssl-ruby rdoc ri irb build-essential wget ssl-cert git-core rubygems
 
echo "-- Installing RubyGems"
 
if [[ ! (`command -v ohai` && `command -v chef-solo`) ]]; then
  sudo gem install chef ohai --no-ri --no-rdoc
fi
 
mkdir -p "$HOME/.chef"
cat <<EOF > $HOME/.chef/knife.rb
log_level                :debug
log_location             STDOUT
node_name                '$NODENAME'
cookbook_path [ '$CHEF_DIR/cookbooks', '$CHEF_DIR/site-cookbooks' ]
cookbook_copyright "Cheftest Inc."
EOF
 
echo "-- Cloning repository"
 
cd $CHEF_DIR
git clone $CHEFREPO .
 
echo "-- Setting up chef config"
 
cat <<EOF > $CHEF_DIR/config/solo.rb
log_level                :debug
data_bag_path "$CHEF_DIR/data_bags"
file_cache_path "$CHEF_DIR"
cookbook_path "$CHEF_DIR/cookbooks"
role_path "$CHEF_DIR/roles"
json_attribs "$CHEF_DIR/config/default.json"
EOF
 
cat <<EOF > $CHEF_DIR/config/default.json
{ "chef_environment":"$CHEF_ENV","run_list": $RUNLIST }
EOF
 
printf "
=== Run the following ===
sudo chef-solo -c $CHEF_DIR/config/solo.rb
"
