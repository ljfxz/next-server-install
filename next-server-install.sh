#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
BLUE="\033[0;36m"
echo -e "${BLUE}
-----------------------------write by tg:@ljfxz-----------------------------
"
[[ $EUID -ne 0 ]] && echo -e "错误 必须使用root用户运行此脚本！\n" && exit 1

last_version=$(curl -Ls "https://api.github.com/repos/SSPanel-NeXT/NeXT-Server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

arch=$(arch)
if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
    arch="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
    arch="arm64"
else
  arch="riscv64"
fi

install_next-server(){
if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi    
if [[ $release = "ubuntu" || $release = "debian" ]]; then
apt update -y && apt install wget unzip vim -y
elif [[ $release = "centos" ]]; then
yum update -y && yum install wget unzip vim -y
else
exit 1
fi
mkdir -p /etc/next-server
wget -q -N --no-check-certificate -P /etc/next-server "https://github.com/SSPanel-NeXT/NeXT-Server/releases/download/${last_version}/next-server-linux-${arch}.zip"
unzip /etc/next-server/next-server-linux-${arch}.zip
chmod +x /etc/next-server/next-server
mv /etc/next-server/next-server /usr/bin/
wget -q -N --no-check-certificate -P /etc/systemd/system/ "https://raw.githubusercontent.com/ljfxz/next-server-install/main/next-server.service"
systemctl daemon-reload
systemctl enable next-server
menu
}

manage_next-server(){
echo -e "
 ${GREEN} 1.停止next-server
 ${GREEN} 2.启动next-server
 ${GREEN} 3.重启next-server
"
read -p "请输入选项:" Num
if [ "$Num" = "1" ];then
systemctl stop next-server
elif [ "$Num" = "2" ];then
systemctl start next-server
elif [ "$Num" = "3" ];then
systemctl restart next-server
fi
menu
}

next-server_config(){
vim /etc/next-server/config.yml
sleep 2
systemctl restart next-server
}

show_log() {
    journalctl -u next-server.service -e --no-pager -f
}

menu(){
echo -e " 
  1.安装next-server
  2.编辑next-server
  3.管理next-server
  4.next-server日志
  0.退出脚本"
 read -p " 请输入数字后[0-4] 按回车键:" num
case "$num" in
	1)
	install_next-server
	;;
	2)
	next-server_config
	;;
	3)
	manage_next-server
	;;
	4)
	show_log
	;;
	0)
	exit 1
	;;
	*)	
	echo "请输入正确数字 [0-4] 按回车键"
	sleep 1s
	menu
	;;
esac
}
menu
