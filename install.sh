#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

cur_dir=$(cd "$(dirname "$0")" && pwd)
Stack=$1
if [ "${Stack}" = "" ]; then
    Stack="lnmp"
else
    Stack=$1
fi

. ${cur_dir}/lnmp.conf
. ${cur_dir}/include/main.sh
. ${cur_dir}/include/init.sh
. ${cur_dir}/include/mariadb.sh
. ${cur_dir}/include/php.sh
. ${cur_dir}/include/nginx.sh
. ${cur_dir}/include/apache.sh
. ${cur_dir}/include/end.sh
. ${cur_dir}/include/only.sh
. ${cur_dir}/include/multiplephp.sh

Get_Dist_Name

if [ "${DISTRO}" = "unknow" ]; then
    Echo_Red "Unable to get Linux distribution name, or do NOT support the current distribution."
    exit 1
fi

if [[ "${Stack}" = "lnmp" || "${Stack}" = "lnmpa" || "${Stack}" = "lamp" ]]; then
    if [ -f /bin/lnmp ]; then
        Echo_Red "You have installed LNMP!"
        echo -e "If you want to reinstall LNMP, please BACKUP your data.\nand run uninstall script: ./uninstall.sh before you install."
        exit 1
    fi
fi

Check_LNMPConf

clear
echo "+------------------------------------------------------------------------+"
echo "|               NMPScript for ${DISTRO} Linux Server             |"
echo "+------------------------------------------------------------------------+"
echo "|        A tool to auto-compile & install LNMP/LNMPA/LAMP on Linux       |"
echo "+------------------------------------------------------------------------+"
echo "|               https://github.com/laingyulee/nmpscript                  |"
echo "+------------------------------------------------------------------------+"

Init_Install()
{
    Press_Install
    Print_APP_Ver
    Get_Dist_Version
    Print_Sys_Info
    Check_Hosts
    Check_CMPT
    if [ "${CheckMirror}" != "n" ]; then
        Modify_Source
        Check_Mirror
    fi
    Add_Swap
    Set_Timezone
    if [ "$PM" = "yum" ]; then
        CentOS_InstallNTP
        CentOS_RemoveAMP
        CentOS_Dependent
    elif [ "$PM" = "apt" ]; then
        Deb_InstallNTP
        Xen_Hwcap_Setting
        Deb_RemoveAMP
        Deb_Dependent
    fi
    Disable_Selinux
    Check_Download
    Install_Libiconv
    Install_Libmcrypt
    Install_Mhash
    Install_Mcrypt
    Install_Freetype
    Install_Pcre
    Install_Icu4c
    if [ "${SelectMalloc}" = "2" ]; then
        Install_Jemalloc
    elif [ "${SelectMalloc}" = "3" ]; then
        Install_TCMalloc
    fi
    if [ "$PM" = "yum" ]; then
        CentOS_Lib_Opt
    elif [ "$PM" = "apt" ]; then
        Deb_Lib_Opt
    fi
    if [ "${DBSelect}" = "1" ]; then
        Install_MariaDB_105
    elif [ "${DBSelect}" = "2" ]; then
        Install_MariaDB_106
    elif [ "${DBSelect}" = "3" ]; then
        Install_MariaDB_1011
    fi
    TempMycnf_Clean
    Clean_DB_Src_Dir
    Check_PHP_Option
}

Install_PHP()
{
    if [ "${PHPSelect}" = "1" ]; then
        Install_PHP_81
    elif [ "${PHPSelect}" = "2" ]; then
        Install_PHP_82
    elif [ "${PHPSelect}" = "3" ]; then
        Install_PHP_83
    elif [ "${PHPSelect}" = "4" ]; then
        Install_PHP_84
    fi
    Clean_PHP_Src_Dir
}

LNMP_Stack()
{
    Init_Install
    Install_PHP
    LNMP_PHP_Opt
    Install_Nginx
    Creat_PHP_Tools
    Add_Iptables_Rules
    Add_LNMP_Startup
    Check_LNMP_Install
}

LNMPA_Stack()
{
    Apache_Selection
    Init_Install
    Install_Apache_24
    Install_PHP
    Install_Nginx
    Creat_PHP_Tools
    Add_Iptables_Rules
    Add_LNMPA_Startup
    Check_LNMPA_Install
}

LAMP_Stack()
{
    Apache_Selection
    Init_Install
    Install_Apache_24
    Install_PHP
    Creat_PHP_Tools
    Add_Iptables_Rules
    Add_LAMP_Startup
    Check_LAMP_Install
}

case "${Stack}" in
    lnmp)
        Dispaly_Selection
        LNMP_Stack 2>&1 | tee /root/lnmp-install.log
        ;;
    lnmpa)
        Dispaly_Selection
        LNMPA_Stack 2>&1 | tee /root/lnmp-install.log
        ;;
    lamp)
        Dispaly_Selection
        LAMP_Stack 2>&1 | tee /root/lnmp-install.log
        ;;
    nginx)
        Install_Only_Nginx 2>&1 | tee /root/nginx-install.log
        ;;
    db)
        Install_Only_Database
        ;;
    mphp)
        Install_Multiplephp
        ;;
    *)
        Echo_Red "Usage: $0 {lnmp|lnmpa|lamp}"
        Echo_Red "Usage: $0 {nginx|db|mphp}"
        ;;
esac

exit 0
