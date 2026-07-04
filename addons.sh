#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script"
    exit 1
fi

cur_dir=$(cd "$(dirname "$0")" && pwd)
action=$1
action2=$2

. lnmp.conf
. include/main.sh
. include/init.sh
. include/version.sh
. include/memcached.sh
. include/redis.sh
. include/imageMagick.sh
. include/ionCube.sh
. include/apcu.sh
. include/php_exif.sh
. include/php_fileinfo.sh
. include/php_ldap.sh
. include/php_bz2.sh
. include/php_sodium.sh
. include/php_imap.sh
. include/php_swoole.sh
. include/php_SourceGuardian.sh

Display_Addons_Menu()
{
    echo "##### cache / optimizer / accelerator #####"
    echo "  1: Memcached"
    echo "  2: Redis"
    echo "  3: apcu"
    echo "##### Image Processing #####"
    echo "  4: imageMagick"
    echo "##### encryption/decryption utility for PHP #####"
    echo "  5: ionCube Loader"
    echo "  6: SourceGuardian Loader"
    echo "##### PHP Modules/Extensions #####"
    echo "  7: Exif"
    echo "  8: Fileinfo"
    echo "  9: Ldap"
    echo " 10: Bz2"
    echo " 11: Sodium"
    echo " 12: Imap"
    echo " 13: Swoole"
    echo "#################################################"
    echo " exit: Exit current script"
    echo "#################################################"
    read -p "Enter your choice (1, 2, 3, 4, 5, 6... or exit): " action2
}

Restart_PHP()
{
    if [ -s /usr/local/apache/bin/httpd ] && [ -s /usr/local/apache/conf/httpd.conf ] && [ -s /etc/init.d/httpd ]; then
        echo "Restarting Apache......"
        /etc/init.d/httpd restart
    else
        echo "Restarting php-fpm......"
        ${PHPFPM_Initd} restart
    fi
}

clear
echo "+-----------------------------------------------------------------------+"
echo "|                     Addons script for NMPScript                       |"
echo "+-----------------------------------------------------------------------+"
echo "|    A tool to Install cache,optimizer,accelerator...addons for LNMP    |"
echo "+-----------------------------------------------------------------------+"
echo "|                https://github.com/laingyulee/nmpscript                |"
echo "+-----------------------------------------------------------------------+"

Select_PHP()
{
    # NOTE: This function sets default PHP path for addons installation
    # PHP version selection is handled by the main installation script
    if [ "${action2}" == "exit" ]; then
        exit 1
    fi
    PHP_Path='/usr/local/php'
    PHPFPM_Initd='/etc/init.d/php-fpm'
}

Addons_Get_PHP_Ext_Dir()
{
    Cur_PHP_Version="`${PHP_Path}/bin/php-config --version`"
    zend_ext_dir="`${PHP_Path}/bin/php-config --extension-dir`/"
}

Download_PHP_Src()
{
     if [ -s php-${Cur_PHP_Version}.tar.bz2 ]; then
        echo "php-${Cur_PHP_Version}.tar.bz2 [found]"
    else
        Download_Files ${Download_Mirror}/web/php/php-${Cur_PHP_Version}.tar.bz2 php-${Cur_PHP_Version}.tar.bz2
    fi
}

if [[ "${action}" == "" || "${action2}" == "" ]]; then
    action='install'
    Display_Addons_Menu
fi
Get_Dist_Name
Select_PHP

    case "${action}" in
    install)
        case "${action2}" in
            1|[mM]emcached)
                Install_Memcached
                ;;
            2|[rR]edis)
                Install_Redis
                ;;
            3|apcu)
                Install_Apcu
                ;;
            4|image[mM]agick)
                Install_ImageMagic
                ;;
            5|ion[cC]ube)
                Install_ionCube
                ;;
            6|[sS][gG])
                Install_SourceGuardian
                ;;
            7|[eE]xif)
                Install_PHP_Exif
                ;;
            8|[fF]ileinfo)
                Install_PHP_Fileinfo
                ;;
            9|[lL]dap)
                Install_PHP_Ldap
                ;;
            10|[bB]z2)
                Install_PHP_Bz2
                ;;
            11|[sS]odium)
                Install_PHP_Sodium
                ;;
            12|[iI]map)
                Install_PHP_Imap
                ;;
            13|[sS]woole)
                Install_PHP_Swoole
                ;;
            [eE][xX][iI][tT])
                exit 1
                ;;
            *)
                echo "Usage: ./addons.sh install {memcached|redis|apcu|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}"
                ;;
        esac
        ;;
    uninstall)
        case "${action2}" in
            [mM]emcached)
                Uninstall_Memcached
                ;;
            [rR]edis)
                Uninstall_Redis
                ;;
            apcu)
                Uninstall_Apcu
                ;;
            image[mM]agick)
                Uninstall_ImageMagick
                ;;
            ion[cC]ube)
                Uninstall_ionCube
                ;;
            [sS][gG])
                Uninstall_SourceGuardian
                ;;
            [eE]xif)
                Uninstall_PHP_Exif
                ;;
            [fF]ileinfo)
                Uninstall_PHP_Fileinfo
                ;;
            [lL]dap)
                Uninstall_PHP_Ldap
                ;;
            [bB]z2)
                Uninstall_PHP_Bz2
                ;;
            [sS]odium)
                Uninstall_PHP_Sodium
                ;;
            [iI]map)
                Uninstall_PHP_Imap
                ;;
            [sS]woole)
                Uninstall_PHP_Swoole
                ;;
            *)
                echo "Usage: ./addons.sh uninstall {memcached|redis|apcu|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}"
                ;;
        esac
        ;;
    [eE][xX][iI][tT])
        exit 1
        ;;
    *)
        echo "Usage: ./addons.sh {install|uninstall} {memcached|redis|apcu|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}"
        exit 1
        ;;
    esac
