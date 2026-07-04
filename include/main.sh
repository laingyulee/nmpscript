#!/usr/bin/env bash

DB_Info=('MariaDB 10.5.24' 'MariaDB 10.6.17' 'MariaDB 10.11.18')
PHP_Info=('PHP 8.1.28' 'PHP 8.2.19' 'PHP 8.3.32' 'PHP 8.4.22')
Apache_Info=('Apache 2.4.68')

Database_Selection()
{
#which Database Version do you want to install?
    if [ -z ${DBSelect} ]; then
        DBSelect="4"
        Echo_Yellow "You have 4 options for your DataBase install."
        echo "1: Install ${DB_Info[0]}"
        echo "2: Install ${DB_Info[1]}"
        echo "3: Install ${DB_Info[2]} (Default)"
        echo "0: DO NOT Install Database"
        read -p "Enter your choice (1, 2, 3 or 0): " DBSelect
    fi

    case "${DBSelect}" in
    1)
        echo "You will install ${DB_Info[0]}"
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[0]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[0]} from Source."
                Bin="n"
                ;;
            *)
            if [ "${CheckMirror}" != "n" ]; then
                echo "Default install ${DB_Info[0]} Using Generic Binaries."
                Bin="y"
            else
                echo "Default install ${DB_Info[0]} from Source."
                Bin="n"
            fi
            ;;
        esac
    else
        # ARM architectures (aarch64, armhf) must use source compilation
        # MariaDB binary packages only available for x86_64/i686
        Echo_Yellow "Notice: MariaDB binary packages not available for ${DB_ARCH} architecture."
        Echo_Yellow "Will install from source code (compilation required)."
        Bin="n"
    fi
    ;;
    2)
        echo "You will install ${DB_Info[1]}"
        if [[ "${DB_ARCH}" = "x86_64" || "${DB_ARCH}" = "i686" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[1]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[1]} from Source."
                Bin="n"
                ;;
            *)
            if [ "${CheckMirror}" != "n" ]; then
                echo "Default install ${DB_Info[1]} Using Generic Binaries."
                Bin="y"
            else
                echo "Default install ${DB_Info[1]} from Source."
                Bin="n"
            fi
            ;;
        esac
    else
        # ARM architectures (aarch64, armhf) must use source compilation
        # MariaDB binary packages only available for x86_64/i686
        Echo_Yellow "Notice: MariaDB binary packages not available for ${DB_ARCH} architecture."
        Echo_Yellow "Will install from source code (compilation required)."
        Bin="n"
    fi
    ;;
    3)
        echo "You will install ${DB_Info[2]}"
        # MariaDB 10.11+ binary packages only available for x86_64 architecture
        if [[ "${DB_ARCH}" = "x86_64" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[2]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[2]} from Source."
                Bin="n"
                ;;
            *)
            if [ "${CheckMirror}" != "n" ]; then
                echo "Default install ${DB_Info[0]} Using Generic Binaries."
                Bin="y"
            else
                echo "Default install ${DB_Info[0]} from Source."
                Bin="n"
            fi
            ;;
        esac
    else
        # ARM architectures (aarch64, armhf) must use source compilation
        # MariaDB binary packages only available for x86_64/i686
        Echo_Yellow "Notice: MariaDB binary packages not available for ${DB_ARCH} architecture."
        Echo_Yellow "Will install from source code (compilation required)."
        Bin="n"
    fi
    ;;
    0)
        echo "Do not install Database!"
        ;;
    *)
        echo "No input,You will install ${DB_Info[2]}"
        DBSelect="3"
        # Ask about binary installation for default selection
        if [[ "${DB_ARCH}" = "x86_64" ]]; then
            if [ -z ${Bin} ]; then
                read -p "Using Generic Binaries [y/n]: " Bin
            fi
            case "${Bin}" in
            [yY][eE][sS]|[yY])
                echo "You will install ${DB_Info[2]} Using Generic Binaries."
                Bin="y"
                ;;
            [nN][oO]|[nN])
                echo "You will install ${DB_Info[2]} from Source."
                Bin="n"
                ;;
            *)
                if [ "${CheckMirror}" != "n" ]; then
                    echo "Default install ${DB_Info[2]} Using Generic Binaries."
                    Bin="y"
                else
                    echo "Default install ${DB_Info[2]} from Source."
                    Bin="n"
                fi
                ;;
            esac
        else
            # ARM architectures must use source compilation
            Echo_Yellow "Notice: MariaDB binary packages not available for ${DB_ARCH} architecture."
            Echo_Yellow "Will install from source code (compilation required)."
            Bin="n"
        fi
    esac

    if [[ "${DBSelect}" =~ ^[1-3]$ ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
    fi

    if [[ "${DBSelect}" != "0" ]]; then
        #set database root password
        if [ -z ${DB_Root_Password} ]; then
            echo "==========================="
            DB_Root_Password="root"
            Echo_Yellow "Please setup root password of Database."
            read -p "Please enter: " DB_Root_Password
            if [ "${DB_Root_Password}" = "" ]; then
                echo "NO input,password will be generated randomly."
                DB_Root_Password="nmpscript_$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 16)"
            fi
        fi
        echo "Database root password: ${DB_Root_Password}"

        #do you want to enable or disable the InnoDB Storage Engine?
        echo "==========================="

        if [ -z ${InstallInnodb} ]; then
            InstallInnodb="y"
            Echo_Yellow "Do you want to enable or disable the InnoDB Storage Engine?"
            read -p "Default enable,Enter your choice [Y/n]: " InstallInnodb
        fi

        case "${InstallInnodb}" in
        [yY][eE][sS]|[yY])
            echo "You will enable the InnoDB Storage Engine"
            InstallInnodb="y"
            ;;
        [nN][oO]|[nN])
            echo "You will disable the InnoDB Storage Engine!"
            InstallInnodb="n"
            ;;
        *)
            echo "No input,The InnoDB Storage Engine will enable."
            InstallInnodb="y"
        esac
    fi
}

PHP_Selection()
{
#which PHP Version do you want to install?
    if [ -z ${PHPSelect} ]; then
        echo "==========================="

        PHPSelect="4"
        Echo_Yellow "You have 4 options for your PHP install."
        echo "1: Install ${PHP_Info[0]}"
        echo "2: Install ${PHP_Info[1]}"
        echo "3: Install ${PHP_Info[2]}"
        echo "4: Install ${PHP_Info[3]} (Default)"
        read -p "Enter your choice (1, 2, 3, 4): " PHPSelect
    fi

    case "${PHPSelect}" in
    1)
        echo "You will install ${PHP_Info[0]}"
        ;;
    2)
        echo "You will install ${PHP_Info[1]}"
        ;;
    3)
        echo "You will install ${PHP_Info[2]}"
        ;;
    4)
        echo "You will install ${PHP_Info[3]}"
        ;;
    *)
        echo "No input,You will install ${PHP_Info[3]}"
        PHPSelect="4"
    esac
}

MemoryAllocator_Selection()
{
#which Memory Allocator do you want to install?
    if [ -z ${SelectMalloc} ]; then
        echo "==========================="

        SelectMalloc="1"
        Echo_Yellow "You have 3 options for your Memory Allocator install."
        echo "1: Don't install Memory Allocator. (Default)"
        echo "2: Install Jemalloc"
        echo "3: Install TCMalloc"
        read -p "Enter your choice (1, 2 or 3): " SelectMalloc
    fi

    case "${SelectMalloc}" in
    1)
        echo "You will install not install Memory Allocator."
        ;;
    2)
        echo "You will install JeMalloc"
        ;;
    3)
        echo "You will Install TCMalloc"
        ;;
    *)
        echo "No input,You will not install Memory Allocator."
        SelectMalloc="1"
    esac

    if [ "${SelectMalloc}" =  "1" ]; then
        MySQLMAOpt=''
        NginxMAOpt=''
    elif [ "${SelectMalloc}" =  "2" ]; then
        MySQLMAOpt='[mysqld_safe]
malloc-lib=/usr/lib/libjemalloc.so'
        NginxMAOpt="--with-ld-opt='-ljemalloc'"
    elif [ "${SelectMalloc}" =  "3" ]; then
        MySQLMAOpt='[mysqld_safe]
malloc-lib=/usr/lib/libtcmalloc.so'
        NginxMAOpt='--with-google_perftools_module'
    fi
}

Dispaly_Selection()
{
    Database_Selection
    PHP_Selection
    MemoryAllocator_Selection
}

Apache_Selection()
{
    echo "==========================="
    #set Server Administrator Email Address
    if [ -z ${ServerAdmin} ]; then
        ServerAdmin=""
        read -p "Please enter Administrator Email Address: " ServerAdmin
    fi
    if [ "${ServerAdmin}" == "" ]; then
        echo "Administrator Email Address will set to webmaster@example.com!"
        ServerAdmin="webmaster@example.com"
    else
        echo "==========================="
        echo Server Administrator Email: "${ServerAdmin}"
        echo "==========================="
    fi
    echo "==========================="

#which Apache Version do you want to install?
    if [ -z ${ApacheSelect} ]; then
        ApacheSelect="1"
        Echo_Yellow "You have 1 option for your Apache install."
        echo "1: Install ${Apache_Info[0]} (Default)"
        read -p "Enter your choice (1): " ApacheSelect
    fi

    if [ "${ApacheSelect}" = "1" ] || [ "${ApacheSelect}" = "" ]; then
        echo "You will install ${Apache_Info[0]}"
        ApacheSelect="1"
    else
        echo "No input,You will install ${Apache_Info[0]}"
        ApacheSelect="1"
    fi
}

Kill_PM()
{
    if ps aux | grep -E "yum|dnf" | grep -qv "grep"; then
        kill -9 $(ps -ef|grep -E "yum|dnf"|grep -v grep|awk '{print $2}')
        if [ -s /var/run/yum.pid ]; then
            rm -f /var/run/yum.pid
        fi
    elif ps aux | grep -E "apt-get|dpkg|apt" | grep -qv "grep"; then
        kill -9 $(ps -ef|grep -E "apt-get|apt|dpkg"|grep -v grep|awk '{print $2}')
        if [[ -s /var/lib/dpkg/lock-frontend || -s /var/lib/dpkg/lock ]]; then
            rm -f /var/lib/dpkg/lock-frontend
            rm -f /var/lib/dpkg/lock
            dpkg --configure -a
        fi
    fi
}

Press_Install()
{
    if [ -z ${LNMP_Auto} ]; then
        echo ""
        Echo_Green "Press any key to install...or Press Ctrl+c to cancel"
        OLDCONFIG=`stty -g`
        stty -icanon -echo min 1 time 0
        dd count=1 2>/dev/null
        stty ${OLDCONFIG}
    fi
    . include/version.sh
    Kill_PM
}

Press_Start()
{
    echo ""
    Echo_Green "Press any key to start...or Press Ctrl+c to cancel"
    OLDCONFIG=`stty -g`
    stty -icanon -echo min 1 time 0
    dd count=1 2>/dev/null
    stty ${OLDCONFIG}
}

Install_LSB()
{
    echo "[+] Installing lsb..."
    if [ "$PM" = "yum" ]; then
        yum -y install redhat-lsb
    elif [ "$PM" = "apt" ]; then
        apt-get update
        apt-get --no-install-recommends install -y lsb-release
    fi
}

Get_Dist_Version()
{
    if command -v lsb_release >/dev/null 2>&1; then
        DISTRO_Version=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        DISTRO_Version="$DISTRIB_RELEASE"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO_Version="$VERSION_ID"
    fi
    if [[ "${DISTRO}" = "" || "${DISTRO_Version}" = "" ]]; then
        if command -v python2 >/dev/null 2>&1; then
            DISTRO_Version=$(python2 -c 'import platform; print platform.linux_distribution()[1]')
        elif command -v python3 >/dev/null 2>&1; then
            DISTRO_Version=$(python3 -c 'import platform; print(platform.linux_distribution()[1])')
        else
            Install_LSB
            DISTRO_Version=`lsb_release -rs`
        fi
    fi
    printf -v "${DISTRO}_Version" '%s' "${DISTRO_Version}"
}

Get_Dist_Name()
{
    if grep -Eqi "Alibaba" /etc/issue || grep -Eq "Alibaba Cloud Linux" /etc/*-release; then
        DISTRO='Alibaba'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun Linux" /etc/*-release; then
        DISTRO='Aliyun'
        PM='yum'
    elif grep -Eqi "Amazon Linux" /etc/issue || grep -Eq "Amazon Linux" /etc/*-release; then
        DISTRO='Amazon'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        DISTRO='Fedora'
        PM='yum'
    elif grep -Eqi "Oracle Linux" /etc/issue || grep -Eq "Oracle Linux" /etc/*-release; then
        DISTRO='Oracle'
        PM='yum'
    elif grep -Eqi "rockylinux" /etc/issue || grep -Eq "Rocky Linux" /etc/*-release; then
        DISTRO='Rocky'
        PM='yum'
    elif grep -Eqi "almalinux" /etc/issue || grep -Eq "AlmaLinux" /etc/*-release; then
        DISTRO='Alma'
        PM='yum'
    elif grep -Eqi "openEuler" /etc/issue || grep -Eq "openEuler" /etc/*-release; then
        DISTRO='openEuler'
        PM='yum'
    elif grep -Eqi "Anolis OS" /etc/issue || grep -Eq "Anolis OS" /etc/*-release; then
        DISTRO='Anolis'
        PM='yum'
    elif grep -Eqi "Kylin Linux Advanced Server" /etc/issue || grep -Eq "Kylin Linux Advanced Server" /etc/*-release; then
        DISTRO='Kylin'
        PM='yum'
    elif grep -Eqi "OpenCloudOS" /etc/issue || grep -Eq "OpenCloudOS" /etc/*-release; then
        DISTRO='OpenCloudOS'
        PM='yum'
    elif grep -Eqi "Huawei Cloud EulerOS" /etc/issue || grep -Eq "Huawei Cloud EulerOS" /etc/*-release; then
        DISTRO='HCE'
        PM='yum'
    elif grep -Eqi "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        DISTRO='CentOS'
        PM='yum'
        if grep -Eq "CentOS Stream" /etc/*-release; then
            isCentosStream='y'
        fi
    elif grep -Eqi "Red Hat Enterprise Linux" /etc/issue || grep -Eq "Red Hat Enterprise Linux" /etc/*-release; then
        DISTRO='RHEL'
        PM='yum'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        DISTRO='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        DISTRO='Raspbian'
        PM='apt'
    elif grep -Eqi "Deepin" /etc/issue || grep -Eq "Deepin" /etc/*-release; then
        DISTRO='Deepin'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release; then
        DISTRO='Mint'
        PM='apt'
    elif grep -Eqi "Kali" /etc/issue || grep -Eq "Kali" /etc/*-release; then
        DISTRO='Kali'
        PM='apt'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        DISTRO='Debian'
        PM='apt'
    elif grep -Eqi "UnionTech OS|UOS" /etc/issue || grep -Eq "UnionTech OS|UOS" /etc/*-release; then
        DISTRO='UOS'
        if command -v apt >/dev/null 2>&1; then
            PM='apt'
        elif command -v yum >/dev/null 2>&1; then
            PM='yum'
        fi
    elif grep -Eqi "Kylin Linux Desktop" /etc/issue || grep -Eq "Kylin Linux Desktop" /etc/*-release; then
        DISTRO='Kylin'
        PM='apt'
    else
        DISTRO='unknow'
    fi
    Get_OS_Bit
}

Get_RHEL_Version()
{
    Get_Dist_Name
    if [ "${DISTRO}" = "RHEL" ]; then
        if grep -Eqi "release 5." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 5"
            RHEL_Ver='5'
        elif grep -Eqi "release 6." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 6"
            RHEL_Ver='6'
        elif grep -Eqi "release 7." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 7"
            RHEL_Ver='7'
        elif grep -Eqi "release 8." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 8"
            RHEL_Ver='8'
        elif grep -Eqi "release 9." /etc/redhat-release; then
            echo "Current Version: RHEL Ver 9"
            RHEL_Ver='9'
        fi
        RHEL_Version="$(cat /etc/redhat-release | sed 's/.*release\ //' | sed 's/\ .*//')"
    fi
}

Get_OS_Bit()
{
    if [[ `getconf WORD_BIT` = '32' && `getconf LONG_BIT` = '64' ]] ; then
        Is_64bit='y'
        ARCH='x86_64'
        DB_ARCH='x86_64'
    else
        Is_64bit='n'
        ARCH='i386'
        DB_ARCH='i686'
    fi

    if uname -m | grep -Eqi "arm|aarch64"; then
        Is_ARM='y'
        if uname -m | grep -Eqi "armv7|armv6"; then
            ARCH='armhf'
        elif uname -m | grep -Eqi "aarch64"; then
            ARCH='aarch64'
            DB_ARCH='aarch64'
        else
            ARCH='arm'
        fi
    fi
}

Get_Official_URL()
{
    local url=$1
    local filename=$(basename "$url")
    case "$url" in
        */php/php-*.tar.bz2|*/php/php-*.tar.gz)
            echo "https://www.php.net/distributions/${filename}" ;;
        */nginx/nginx-*.tar.gz)
            echo "https://nginx.org/download/${filename}" ;;
        */nginx/nginx-*.tar.xz)
            echo "https://nginx.org/download/${filename}" ;;
        */openssl/openssl-*.tar.gz)
            echo "https://www.openssl.org/source/${filename}" ;;
        */curl/curl-*.tar.bz2)
            echo "https://curl.se/download/${filename}" ;;
        */freetype/freetype-*.tar.xz|*/freetype/freetype-*.tar.bz2)
            echo "https://download.savannah.gnu.org/releases/freetype/${filename}" ;;
        */icu4c/icu4c-*-src.tgz)
            local ver_tag="${filename#icu4c-}"; ver_tag="${ver_tag%-src.tgz}"; ver_tag="${ver_tag//_/-}"
            echo "https://github.com/unicode-org/icu/releases/download/release-${ver_tag}/${filename}" ;;
        */nghttp2/nghttp2-*.tar.xz)
            local ver="${filename#nghttp2-}"; ver="${ver%.tar.xz}"
            echo "https://github.com/nghttp2/nghttp2/releases/download/v${ver}/${filename}" ;;
        */libzip/libzip-*.tar.xz)
            echo "https://libzip.org/download/${filename}" ;;
        */jemalloc/jemalloc-*.tar.bz2)
            local ver="${filename#jemalloc-}"; ver="${ver%.tar.bz2}"
            echo "https://github.com/jemalloc/jemalloc/releases/download/${ver}/${filename}" ;;
        */tcmalloc/gperftools-*.tar.gz)
            local ver="${filename#gperftools-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/gperftools/gperftools/releases/download/gperftools-${ver}/${filename}" ;;
        */libunwind/libunwind-*.tar.gz)
            local ver="${filename#libunwind-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/libunwind/libunwind/releases/download/v${ver}/${filename}" ;;
        */autoconf/autoconf-*.tar.gz)
            echo "https://ftp.gnu.org/gnu/autoconf/${filename}" ;;
        */pcre/pcre-*.tar.bz2)
            local ver="${filename#pcre-}"; ver="${ver%.tar.bz2}"
            echo "https://sourceforge.net/projects/pcre/files/pcre/${ver}/${filename}" ;;
        */apache/httpd-*.tar.bz2)
            echo "https://archive.apache.org/dist/httpd/${filename}" ;;
        */apache/apr-*.tar.bz2)
            echo "https://archive.apache.org/dist/apr/${filename}" ;;
        */apache/apr-util-*.tar.bz2)
            echo "https://archive.apache.org/dist/apr/${filename}" ;;
        */libiconv/libiconv-*.tar.gz)
            echo "https://ftp.gnu.org/pub/gnu/libiconv/${filename}" ;;
        */libmcrypt/libmcrypt-*.tar.gz)
            local ver="${filename#libmcrypt-}"; ver="${ver%.tar.gz}"
            echo "https://sourceforge.net/projects/mcrypt/files/Libmcrypt/${ver}/${filename}" ;;
        */mcrypt/mcrypt-*.tar.gz)
            local ver="${filename#mcrypt-}"; ver="${ver%.tar.gz}"
            echo "https://sourceforge.net/projects/mcrypt/files/MCrypt/${ver}/${filename}" ;;
        */mhash/mhash-*.tar.bz2)
            local ver="${filename#mhash-}"; ver="${ver%.tar.bz2}"
            echo "https://sourceforge.net/projects/mhash/files/mhash/${ver}/${filename}" ;;
        */datebase/phpmyadmin/phpMyAdmin-*.tar.xz)
            local ver="${filename#phpMyAdmin-}"; ver="${ver%-all-languages*}"
            echo "https://files.phpmyadmin.net/phpMyAdmin/${ver}/${filename}" ;;
        */ftp/pure-ftpd/pure-ftpd-*.tar.bz2)
            echo "https://download.pureftpd.org/pub/pure-ftpd/releases/${filename}" ;;
        */lua/luajit2-*.tar.gz)
            local ver="${filename#luajit2-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/openresty/luajit2/releases/download/v${ver}/${filename}" ;;
        */lua/ngx_devel_kit-*.tar.gz)
            local ver="${filename#ngx_devel_kit-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/vision5/ngx_devel_kit/archive/v${ver}/${filename}" ;;
        */lua/lua-resty-core-*.tar.gz)
            local ver="${filename#lua-resty-core-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/openresty/lua-resty-core/archive/v${ver}/${filename}" ;;
        */lua/lua-resty-lrucache-*.tar.gz)
            local ver="${filename#lua-resty-lrucache-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/openresty/lua-resty-lrucache/archive/v${ver}/${filename}" ;;
        */lua/lua-nginx-module-*.tar.gz)
            local ver="${filename#lua-nginx-module-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/openresty/lua-nginx-module/archive/v${ver}/${filename}" ;;
        */web/nginx/ngx-fancyindex-*.tar.xz)
            local ver="${filename#ngx-fancyindex-}"; ver="${ver%.tar.xz}"
            echo "https://github.com/aperezdc/ngx-fancyindex/releases/download/v${ver}/${filename}" ;;
        */lib/boost/boost_*.tar.bz2)
            local ver2="${filename#boost_}"; ver2="${ver2%.tar.bz2}"; ver2="${ver2//_/.}"
            echo "https://archives.boost.io/release/${ver2}/source/${filename}" ;;
        */libmemcached/libmemcached-awesome-*.tar.gz)
            local ver="${filename#libmemcached-awesome-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/awesomized/libmemcached/releases/download/${ver}/${filename}" ;;
        */memcached/memcached-*.tar.gz)
            echo "https://www.memcached.org/files/${filename}" ;;
        */fail2ban/fail2ban-*.tar.gz)
            local ver="${filename#fail2ban-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/fail2ban/fail2ban/releases/download/${ver}/${filename}" ;;
        */denyhosts/denyhosts-*.tar.gz)
            local ver="${filename#denyhosts-}"; ver="${ver%.tar.gz}"
            echo "https://github.com/denyhosts/denyhosts/releases/download/v${ver}/${filename}" ;;
        */memcache/memcache-*.tgz|*/memcached/memcached-*.tgz|*/php-memcached/memcached-*.tgz|*/apcu/apcu-*.tgz|*/imagick/imagick-*.tgz|*/swoole/swoole-*.tgz|*/sodium/libsodium-*.tgz|*/apcu_bc/apcu_bc-*.tgz)
            local name="${filename%-*}"; local ver="${filename#*-}"; ver="${ver%.*}"
            echo "https://pecl.php.net/get/${filename}" ;;
        */imagemagick/ImageMagick-*.tar.xz|*/imagemagick/ImageMagick-*.tar.gz)
            echo "https://www.imagemagick.org/download/${filename}" ;;
        */ioncube/ioncube_loaders_lin_*.tar.gz)
            echo "https://downloads.ioncube.com/loader_downloads/${filename}" ;;
        */composer/composer-*.phar)
            echo "https://getcomposer.org/${filename}" ;;
        */rest-api/mariadb/*/mariadb-*.tar.gz)
            local base="${filename%.tar.gz}"
            if echo "$base" | grep -q "linux-systemd"; then
                local ver="${base%%-linux-systemd*}"
                local arch="${base##*-}"
                echo "https://archive.mariadb.org/mariadb-${ver#mariadb-}/bintar-linux-systemd-${arch}/${filename}"
            else
                local ver="${base#mariadb-}"
                echo "https://archive.mariadb.org/mariadb-${ver}/source/${filename}"
            fi ;;
        */mariadb/mariadb-*.tar.gz)
            local base="${filename%.tar.gz}"
            if echo "$base" | grep -q "linux-systemd"; then
                local ver="${base%%-linux-systemd*}"
                local arch="${base##*-}"
                echo "https://archive.mariadb.org/mariadb-${ver#mariadb-}/bintar-linux-systemd-${arch}/${filename}"
            else
                local ver="${base#mariadb-}"
                echo "https://archive.mariadb.org/mariadb-${ver}/source/${filename}"
            fi ;;
        *)
            echo "$url" ;;
    esac
}

Download_Files()
{
    local URL=$1
    local FileName=$2
    if [ -s "${FileName}" ]; then
        echo "${FileName} [found]"
    else
        echo "Notice: ${FileName} not found!!!download now..."
        URL=$(Get_Official_URL "$URL")
        wget -c --progress=dot -e dotbytes=20M --prefer-family=IPv4 --no-check-certificate ${URL}
        # Check if download succeeded
        if [ ! -s "${FileName}" ]; then
            Echo_Red "Error: Failed to download ${FileName} from ${URL}"
            Echo_Red "Please check your network connection or try again later."
            exit 1
        fi
    fi
}

Tar_Cd()
{
    local FileName=$1
    local DirName=$2
    local extension=${FileName##*.}
    cd ${cur_dir}/src
    # Check if file exists before extracting
    if [ ! -s "${FileName}" ]; then
        Echo_Red "Error: ${FileName} not found or empty!"
        Echo_Red "Please ensure the file was downloaded successfully."
        exit 1
    fi
    [[ -d "${DirName}" ]] && rm -rf ${DirName}
    echo "Uncompress ${FileName}..."
    if [ "$extension" == "gz" ] || [ "$extension" == "tgz" ]; then
        tar zxf "${FileName}"
    elif [ "$extension" == "bz2" ]; then
        tar jxf "${FileName}"
    elif [ "$extension" == "xz" ]; then
        tar Jxf "${FileName}"
    fi
    # Check if extraction succeeded
    if [ $? -ne 0 ]; then
        Echo_Red "Error: Failed to extract ${FileName}"
        exit 1
    fi
    if [ -n "${DirName}" ]; then
        echo "cd ${DirName}..."
        cd ${DirName}
    fi
}

Check_LNMPConf()
{
    if [ ! -s "${cur_dir}/lnmp.conf" ]; then
        Echo_Red "lnmp.conf was not exsit!"
        exit 1
    fi
    if [[ "${MySQL_Data_Dir}" = "" || "${MariaDB_Data_Dir}" = "" || "${Default_Website_Dir}" = "" ]]; then
        Echo_Red "Can't get values from lnmp.conf!"
        exit 1
    fi
    if [[ "${MySQL_Data_Dir}" = "/" || "${MariaDB_Data_Dir}" = "/" || "${Default_Website_Dir}" = "/" ]]; then
        Echo_Red "Can't set MySQL/MariaDB/Website Directory to / !"
        exit 1
    fi
}

Print_APP_Ver()
{
    echo "You will install ${Stack} stack."
    if [ "${Stack}" != "lamp" ]; then
        echo "${Nginx_Ver}"
    fi

    if [[ "${DBSelect}" =~ ^[1-3]$ ]]; then
        echo "${Mariadb_Ver}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install Database!"
    fi

    echo "${Php_Ver}"

    if [ "${Stack}" != "lnmp" ]; then
        echo "${Apache_Ver}"
    fi

    if [ "${SelectMalloc}" = "2" ]; then
        echo "${Jemalloc_Ver}"
    elif [ "${SelectMalloc}" = "3" ]; then
        echo "${TCMalloc_Ver}"
    fi
    echo "Enable InnoDB: ${InstallInnodb}"
    echo "Print lnmp.conf infomation..."
    echo "Download Mirror: ${Download_Mirror}"
    echo "Nginx Additional Modules: ${Nginx_Modules_Options}"
    echo "PHP Additional Modules: ${PHP_Modules_Options}"
    if [ "${Enable_PHP_Fileinfo}" = "y" ]; then
        echo "enable PHP fileinfo."
    fi
    if [ "${Enable_Nginx_Lua}" = "y" ]; then
        echo "enable Nginx Lua."
    fi
    if [[ "${DBSelect}" =~ ^[1-3]$ ]]; then
        echo "Database Directory: ${MariaDB_Data_Dir}"
    elif [ "${DBSelect}" = "0" ]; then
        echo "Do not install Database!"
    fi
    echo "Default Website Directory: ${Default_Website_Dir}"
}

Print_Sys_Info()
{
    echo "NMPScript Version: 1.0"
    eval echo "${DISTRO} \${${DISTRO}_Version}"
    cat /etc/issue
    cat /etc/*-release
    uname -a
    MemTotal=$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024 )}' /proc/meminfo)
    echo "Memory is: ${MemTotal} MB "
    df -h
    Check_Openssl
    Check_WSL
    Check_Docker
    if [ "${CheckMirror}" != "n" ]; then
        Get_Country
        echo "Server Location: ${country}"
    fi
}

StartUp()
{
    init_name=$1
    echo "Add ${init_name} service at system startup..."
    [[ "${isWSL}" = "" ]] && Check_WSL
    [[ "${isDocker}" = "" ]] && Check_Docker
    if [ "${isWSL}" = "n" ] && [ "${isDocker}" = "n" ] && command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${init_name}.service || -s /lib/systemd/system/${init_name}.service || -s /usr/lib/systemd/system/${init_name}.service ]]; then
        systemctl daemon-reload
        systemctl enable ${init_name}.service
    else
        if [ "$PM" = "yum" ]; then
            chkconfig --add ${init_name}
            chkconfig ${init_name} on
        elif [ "$PM" = "apt" ]; then
            update-rc.d -f ${init_name} defaults
        fi
    fi
}

Remove_StartUp()
{
    init_name=$1
    echo "Removing ${init_name} service at system startup..."
    [[ "${isWSL}" = "" ]] && Check_WSL
    [[ "${isDocker}" = "" ]] && Check_Docker
    if [ "${isWSL}" = "n" ] && [ "${isDocker}" = "n" ] && command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${init_name}.service || -s /lib/systemd/system/${init_name}.service || -s /usr/lib/systemd/system/${init_name}.service ]]; then
        systemctl disable ${init_name}.service
    else
        if [ "$PM" = "yum" ]; then
            chkconfig ${init_name} off
            chkconfig --del ${init_name}
        elif [ "$PM" = "apt" ]; then
            update-rc.d -f ${init_name} remove
        fi
    fi
}

Get_Country()
{
    country=""
}

Check_Mirror()
{
    if ! command -v curl >/dev/null 2>&1; then
        if [ "$PM" = "yum" ]; then
            yum install -y curl
        elif [ "$PM" = "apt" ]; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y curl
        fi
    fi
}

Check_CMPT()
{
    if [[ "${PHPSelect}" =~ ^[1-4]$ ]]; then
        if echo "${Ubuntu_Version}" | grep -Eqi "^1[0-7]\." || echo "${Debian_Version}" | grep -Eqi "^[4-8]" || echo "${Raspbian_Version}" | grep -Eqi "^[4-8]" || echo "${CentOS_Version}" | grep -Eqi "^[4-6]"  || echo "${RHEL_Version}" | grep -Eqi "^[4-6]" || echo "${Fedora_Version}" | grep -Eqi "^2[0-3]"; then
            Echo_Red "PHP 8.* please use latest linux distributions!"
            exit 1
        fi
    fi
}

Color_Text()
{
  echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
  echo $(Color_Text "$1" "31")
}

Echo_Green()
{
  echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
  echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
  echo $(Color_Text "$1" "34")
}

Get_PHP_Ext_Dir()
{
    Cur_PHP_Version="`/usr/local/php/bin/php-config --version`"
    zend_ext_dir="`/usr/local/php/bin/php-config --extension-dir`/"
}

Check_Stack()
{
    if [[ -s /usr/local/php/sbin/php-fpm && -s /usr/local/php/etc/php-fpm.conf && -s /etc/init.d/php-fpm && -s /usr/local/nginx/sbin/nginx ]]; then
        Get_Stack="lnmp"
    elif [[ -s /usr/local/nginx/sbin/nginx && -s /usr/local/apache/bin/httpd && -s /usr/local/apache/conf/httpd.conf && -s /etc/init.d/httpd && ! -s /usr/local/php/sbin/php-fpm ]]; then
        Get_Stack="lnmpa"
    elif [[ -s /usr/local/apache/bin/httpd && -s /usr/local/apache/conf/httpd.conf && -s /etc/init.d/httpd && ! -s /usr/local/php/sbin/php-fpm ]]; then
        Get_Stack="lamp"
    else
        Get_Stack="unknow"
    fi
}

Check_DB()
{
    if [[ -s /usr/local/mariadb/bin/mysql && -s /usr/local/mariadb/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        MySQL_Bin="/usr/local/mariadb/bin/mysql"
        MySQL_Config="/usr/local/mariadb/bin/mysql_config"
        MySQL_Dir="/usr/local/mariadb"
        Is_MySQL="n"
        DB_Name="mariadb"
    elif [[ -s /usr/local/mysql/bin/mysql && -s /usr/local/mysql/bin/mysqld_safe && -s /etc/my.cnf ]]; then
        MySQL_Bin="/usr/local/mysql/bin/mysql"
        MySQL_Config="/usr/local/mysql/bin/mysql_config"
        MySQL_Dir="/usr/local/mysql"
        Is_MySQL="y"
        DB_Name="mysql"
    else
        Is_MySQL="None"
        DB_Name="None"
    fi
}

Do_Query()
{
    echo "$1" >/tmp/.mysql.tmp
    Check_DB
    ${MySQL_Bin} --defaults-file=~/.my.cnf </tmp/.mysql.tmp
    return $?
}

Make_TempMycnf()
{
    cat >~/.my.cnf<<EOF
[client]
user=root
password='$1'
EOF
    chmod 600 ~/.my.cnf
}

Verify_DB_Password()
{
    Check_DB
    status=1
    while [ $status -eq 1 ]; do
        read -s -p "Enter current root password of Database (Password will not shown): " DB_Root_Password
        Make_TempMycnf "${DB_Root_Password}"
        Do_Query ""
        status=$?
    done
    echo "OK, MySQL root password correct."
}

TempMycnf_Clean()
{
    if [ -s ~/.my.cnf ]; then
        rm -f ~/.my.cnf
    fi
    if [ -s /tmp/.mysql.tmp ]; then
        rm -f /tmp/.mysql.tmp
    fi
}

StartOrStop()
{
    local action=$1
    local service=$2
    [[ "${isWSL}" = "" ]] && Check_WSL
    [[ "${isDocker}" = "" ]] && Check_Docker
    if [ "${isWSL}" = "n" ] && [ "${isDocker}" = "n" ] && command -v systemctl >/dev/null 2>&1 && [[ -s /etc/systemd/system/${service}.service ]]; then
        systemctl ${action} ${service}.service
    else
        /etc/init.d/${service} ${action}
    fi
}

Check_WSL() {
    if [[ "$(< /proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ]]; then
        echo "running on WSL"
        isWSL="y"
    else
        isWSL="n"
    fi
}

Check_Docker() {
    if [ -f /.dockerenv ]; then
        echo "running on Docker"
        isDocker="y"
    elif [ -f /proc/1/cgroup ] && grep -q docker /proc/1/cgroup; then
        echo "running on Docker"
        isDocker="y"
    elif [ -f /proc/self/cgroup ] && grep -q docker /proc/self/cgroup; then
        echo "running on Docker"
        isDocker="y"
    else
        isDocker="n"
    fi
}

Check_Openssl()
{
    if ! command -v openssl >/dev/null 2>&1; then
        Echo_Blue "[+] Installing openssl..."
        if [ "${PM}" = "yum" ]; then
            yum install -y openssl
        elif [ "${PM}" = "apt" ]; then
            apt-get update -y
            [[ $? -ne 0 ]] && apt-get update --allow-releaseinfo-change -y
            apt-get install -y openssl
        fi
    fi
    openssl version
    if openssl version | grep -Eqi "OpenSSL 3.*"; then
        isOpenSSL3='y'
    fi
}
