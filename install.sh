#!/bin/bash
echo ' _     __   _______  __          __  _       _____                 _ '
echo '| |    \ \ / / ____| \ \        / / | |     |  __ \               | |'
echo '| |     \ V / |       \ \  /\  / /__| |__   | |__) |_ _ _ __   ___| |'
echo "| |      > <| |        \ \/  \/ / _ \ '_ \  |  ___/ _\` | '_ \ / _ \ |"
echo '| |____ / . \ |____     \  /\  /  __/ |_) | | |  | (_| | | | |  __/ |'
echo '|______/_/ \_\_____|     \/  \/ \___|_.__/  |_|   \__,_|_| |_|\___|_|'
echo -e '\n\nAutomatic installer\n'

if [[ "$UID" -ne "0" ]];then
	echo 'You must be root to install LXC Web Panel !'
	exit
fi

### BEGIN PROGRAM

INSTALL_DIR='/srv/lwp'

if [[ -d "$INSTALL_DIR" ]];then
	echo "You already have LXC Web Panel installed. You'll need to remove $INSTALL_DIR if you want to install"
	exit 1
fi

echo 'Installing requirement...'

hash pip &> /dev/null || {
	echo '+ Installing Python pip'
	dnf install -y python-pip > /dev/null
}

python -c 'import flask' &> /dev/null || {
	echo '| + Flask Python...'
	pip install flask==0.9 2> /dev/null
}

lxc-ls &> /dev/null || {
	echo '+ Installing LXC...'
	dnf install -y lxc lxc-templates 2> /dev/null
}

echo 'Cloning LXC Web Panel...'
hash git &> /dev/null || {
	echo '+ Installing Git'
	dnf install -y git > /dev/null
}

git clone -b 0.2 https://github.com/maxkondr/LXC-Web-Panel.git "$INSTALL_DIR"

echo -e '\nInstallation complete!\n\n'

echo 'Adding systemd service...'
install -m 644 $INSTALL_DIR/systemd/lwp.service /usr/lib/systemd/system/
systemctl daemon-reload

echo 'Done'
mkdir -p '/etc/lxc/auto/'
systemctl start lwp.service
echo 'Connect you on http://your-ip-address:5000/'
