#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script"
    exit 1
fi

cur_dir=$(cd "$(dirname "$0")" && pwd)
action=$1
shopt -s extglob
Upgrade_Date=$(date +"%Y%m%d%H%M%S")

. ${cur_dir}/lnmp.conf
. ${cur_dir}/include/version.sh
. ${cur_dir}/include/main.sh
. ${cur_dir}/include/init.sh
. ${cur_dir}/include/php.sh
. ${cur_dir}/include/nginx.sh
. ${cur_dir}/include/mariadb.sh
. ${cur_dir}/include/upgrade_nginx.sh
. ${cur_dir}/include/upgrade_php.sh
. ${cur_dir}/include/upgrade_mariadb.sh
. ${cur_dir}/include/upgrade_phpmyadmin.sh
. ${cur_dir}/include/upgrade_mphp.sh

Get_Dist_Name
Get_Dist_Version
MemTotal=$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024 )}' /proc/meminfo)

Display_Upgrade_Menu()
{
    echo "1: Upgrade Nginx"
    echo "2: Upgrade MariaDB"
    echo "3: Upgrade PHP for LNMP"
    echo "4: Upgrade PHP for LNMPA or LAMP"
    echo "5: Upgrade phpMyAdmin"
    echo "6: Upgrade Multiple PHP"
    echo "exit: Exit current script"
    echo "###################################################"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6 or exit): " action
}

clear
echo "+-----------------------------------------------------------------------+"
echo "|                     Upgrade script for NMPScript                      |"
echo "+-----------------------------------------------------------------------+"
echo "|        A tool to upgrade Nginx,MariaDB,PHP for LNMP/LNMPA/LAMP        |"
echo "+-----------------------------------------------------------------------+"
echo "|                https://github.com/laingyulee/nmpscript                |"
echo "+-----------------------------------------------------------------------+"

if [ "${action}" == "" ]; then
    Display_Upgrade_Menu
fi

    case "${action}" in
    1|[nN][gG][iI][nN][xX])
        Upgrade_Nginx 2>&1 | tee /root/upgrade_nginx${Upgrade_Date}.log
        ;;
    2|[mM][aA][rR][iI][aA][dD][bB])
        Upgrade_MariaDB 2>&1 | tee /root/upgrade_mariadb${Upgrade_Date}.log
        ;;
    3|[pP][hP][pP])
        Stack="lnmp"
        Upgrade_PHP 2>&1 | tee /root/upgrade_lnmp_php${Upgrade_Date}.log
        ;;
    4|[pP][hP][pP][aA])
        Upgrade_PHP 2>&1 | tee /root/upgrade_a_php${Upgrade_Date}.log
        ;;
    5|[pP][hH][pP][mM][yY][aA][dD][mM][iI][nN])
        Upgrade_phpMyAdmin 2>&1 | tee /root/upgrade_phpmyadmin${Upgrade_Date}.log
        ;;
    6|[mM][pP][hH][pP])
        Upgrade_Multiplephp 2>&1 | tee /root/upgrade_mphp${Upgrade_Date}.log
        ;;
    [eE][xX][iI][tT])
        exit 1
        ;;
    *)
        echo "Usage: ./upgrade.sh {nginx|mariadb|php|phpa|phpmyadmin}"
        exit 1
    ;;
    esac
