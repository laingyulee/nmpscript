#!/usr/bin/env bash

Export_PHP_Autoconf()
{
    if [[ -s /usr/local/autoconf-2.13/bin/autoconf && -s /usr/local/autoconf-2.13/bin/autoheader ]]; then
        Echo_Green "Autconf 2.13...ok"
    else
        Install_Autoconf
    fi
    export PHP_AUTOCONF=/usr/local/autoconf-2.13/bin/autoconf
    export PHP_AUTOHEADER=/usr/local/autoconf-2.13/bin/autoheader
}

Check_Curl()
{
    if [ -s /usr/local/curl/bin/curl ]; then
        Echo_Green "Curl ...ok"
    else
        Install_Curl
    fi
}

PHP_with_curl()
{
    if [[ "${DISTRO}" = "CentOS" && "${Is_ARM}" = "y" ]] || [ "${UseOldOpenssl}" = "y" ];then
        Check_Curl
        with_curl='--with-curl=/usr/local/curl'
    else
        with_curl='--with-curl'
    fi
}

PHP_with_openssl()
{
    if openssl version | grep -Eqi "OpenSSL 1\.1.*|OpenSSL 3\..*"; then
        with_openssl='--with-openssl'
    else
        Install_Openssl
        with_openssl='--with-openssl=/usr/local/openssl'
    fi
}

PHP_with_fileinfo()
{
    if [ "${Enable_PHP_Fileinfo}" = "n" ]; then
        if [[ $(awk '/MemTotal/ {printf( "%d\n", $2 / 1024 )}' /proc/meminfo) -lt 1024 ]]; then
            with_fileinfo='--disable-fileinfo'
        else
            with_fileinfo=''
        fi
    else
        with_fileinfo='--enable-fileinfo'
    fi
}

PHP_with_Exif()
{
    if [ "${Enable_PHP_Exif}" = "n" ]; then
        with_exif=''
    else
        with_exif='--enable-exif'
    fi
}

PHP_with_Ldap()
{
    if [ "${Enable_PHP_Ldap}" = "n" ]; then
        with_ldap=''
    else
        if [ "$PM" = "yum" ]; then
            yum -y install openldap-devel cyrus-sasl-devel
            if [ "${Is_64bit}" == "y" ]; then
                ln -sf /usr/lib64/libldap* /usr/lib/
                ln -sf /usr/lib64/liblber* /usr/lib/
            fi
        elif [ "$PM" = "apt" ]; then
            apt-get install -y libldap2-dev libsasl2-dev
            if [ -s /usr/lib/x86_64-linux-gnu/libldap.so ]; then
                ln -sf /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/
                ln -sf /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/
            fi
        fi
        with_ldap='--with-ldap --with-ldap-sasl'
    fi
}

PHP_with_Bz2()
{
    if [ "${Enable_PHP_Bz2}" = "n" ]; then
        with_bz2=''
    else
        Install_Libzip
        with_bz2='--with-bz2'
    fi
}

PHP_with_Sodium()
{
    with_sodium=''
}

PHP_with_Imap()
{
    if [ "${Enable_PHP_Imap}" = "n" ]; then
        with_imap=''
    else
        if [ "$PM" = "yum" ]; then
            if [ "${DISTRO}" = "Oracle" ]; then
                yum -y install oracle-epel-release
            else
                yum -y install epel-release
            fi
            yum -y install libc-client-devel krb5-devel uw-imap-devel
            if echo "${CentOS_Version}" | grep -Eqi "^9" || echo "${Alma_Version}" | grep -Eqi "^9" || echo "${Rocky_Version}" | grep -Eqi "^9"; then
                if ! rpm -qa | grep "libc-client-2007f" || ! rpm -qa | grep "uw-imap-devel"; then
                    if [ "${CheckMirror}" = "n" ]; then
                        rpm -ivh ${cur_dir}/src/libc-client-2007f-24.el9.${ARCH}.rpm ${cur_dir}/src/uw-imap-devel-2007f-24.el9.${ARCH}.rpm
                    else
                        if ! rpm -ivh ${Download_Mirror}/lib/uw-imap/libc-client-2007f-24.el9.${ARCH}.rpm ${Download_Mirror}/lib/uw-imap/uw-imap-devel-2007f-24.el9.${ARCH}.rpm; then
                            rpm -ivh ${cur_dir}/src/libc-client-2007f-24.el9.${ARCH}.rpm ${cur_dir}/src/uw-imap-devel-2007f-24.el9.${ARCH}.rpm
                        fi
                    fi
                fi
            fi
            [[ -s /usr/lib64/libc-client.so ]] && ln -sf /usr/lib64/libc-client.so /usr/lib/libc-client.so
        elif [ "$PM" = "apt" ]; then
            apt-get install -y libc-client-dev libkrb5-dev
        fi
        with_imap='--with-imap --with-imap-ssl --with-kerberos'
    fi
}

PHP_with_Intl()
{
    if pkg-config --modversion icu-i18n | grep -Eqi '^6[89]|7[0-9]'; then
        export CXX="g++ -DTRUE=1 -DFALSE=0"
        export  CC="gcc -DTRUE=1 -DFALSE=0"
    fi
}

Check_PHP_Option()
{
    PHP_with_openssl
    PHP_with_curl
    PHP_with_fileinfo
    PHP_with_Exif
    PHP_with_Ldap
    PHP_with_Bz2
    PHP_with_Sodium
    PHP_with_Imap
    PHP_with_Intl
    PHP_Buildin_Option="${with_exif} ${with_ldap} ${with_bz2} ${with_sodium} ${with_imap} ${with_icu_dir}"
}

Ln_PHP_Bin()
{
    ln -sf /usr/local/php/bin/php /usr/bin/php
    ln -sf /usr/local/php/bin/phpize /usr/bin/phpize
    ln -sf /usr/local/php/bin/pear /usr/bin/pear
    ln -sf /usr/local/php/bin/pecl /usr/bin/pecl
    if [ "${Stack}" = "lnmp" ]; then
        ln -sf /usr/local/php/sbin/php-fpm /usr/bin/php-fpm
    fi
    rm -f /usr/local/php/conf.d/*
}

Pear_Pecl_Set()
{
    pear config-set php_ini /usr/local/php/etc/php.ini
    pecl config-set php_ini /usr/local/php/etc/php.ini
}

Install_Composer()
{
    if [ "${CheckMirror}" != "n" ]; then
        echo "Downloading Composer..."
        wget --progress=dot:giga --prefer-family=IPv4 --no-check-certificate -T 120 -t3 https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer
        if [ $? -eq 0 ]; then
            echo "Composer install successfully."
            chmod +x /usr/local/bin/composer
        else
            echo "Composer install failed, try to from composer official website..."
            curl -sS --connect-timeout 30 -m 60 https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
            if [ $? -eq 0 ]; then
                echo "Composer install successfully."
            fi
        fi
    fi
}

PHP_Openssl3_Patch()
{
    if [ "${isOpenSSL3}" = "y" ]; then
        if [ "${Php_Ver}" != "" ]; then
            PHP_Short_Ver="$(echo ${Php_Ver} | cut -d- -f2 | cut -d. -f1-2)"
        elif [ "${php_version}" != "" ]; then
            PHP_Short_Ver="$(echo ${php_version} | cut -d. -f1-2)"
        fi
        echo "OpenSSL 3.0, apply a patch to PHP ${PHP_Short_Ver}..."
        patch -p1 < ${cur_dir}/src/patch/php-${PHP_Short_Ver}-openssl3.0.patch
    fi
}

PHP_ICU70_Patch()
{
    if pkg-config --modversion icu-i18n | grep -Eqi '^[7-9][0-9]'; then
        if [ "${Php_Ver}" != "" ]; then
            PHP_Short_Ver="$(echo ${Php_Ver} | cut -d- -f2 | cut -d. -f1-2)"
        elif [ "${php_version}" != "" ]; then
            PHP_Short_Ver="$(echo ${php_version} | cut -d. -f1-2)"
        fi
        echo "icu 7x+, apply a patch to PHP ${PHP_Short_Ver}..."
        patch -p1 < ${cur_dir}/src/patch/php-${PHP_Short_Ver}-icu70.patch
    fi
}

Install_PHP_81()
{
    Install_Libzip
    Echo_Blue "[+] Installing ${Php_Ver}"
    Tar_Cd ${Php_Ver}.tar.bz2 ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --with-apxs2=/usr/local/apache/bin/apxs --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    fi

    PHP_Make_Install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/{etc,conf.d}
    \cp php.ini-production /usr/local/php/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.filename =.*/user_ini.filename = ".user.ini"/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.cache_ttl =.*/user_ini.cache_ttl = 300/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    cd ${cur_dir}/src

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 1024
pm.process_idle_timeout = 10s
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    \cp ${cur_dir}/init.d/php-fpm.service /etc/systemd/system/php-fpm.service
    chmod +x /etc/init.d/php-fpm
fi
}

Install_PHP_82()
{
    Install_Libzip
    Echo_Blue "[+] Installing ${Php_Ver}"
    Tar_Cd ${Php_Ver}.tar.bz2 ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --with-apxs2=/usr/local/apache/bin/apxs --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    fi

    PHP_Make_Install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/{etc,conf.d}
    \cp php.ini-production /usr/local/php/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.filename =.*/user_ini.filename = ".user.ini"/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.cache_ttl =.*/user_ini.cache_ttl = 300/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    cd ${cur_dir}/src

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 1024
pm.process_idle_timeout = 10s
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    \cp ${cur_dir}/init.d/php-fpm.service /etc/systemd/system/php-fpm.service
    chmod +x /etc/init.d/php-fpm
fi
}

Install_PHP_83()
{
    Install_Libzip
    Echo_Blue "[+] Installing ${Php_Ver}"
    Tar_Cd ${Php_Ver}.tar.bz2 ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --with-apxs2=/usr/local/apache/bin/apxs --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    fi

    PHP_Make_Install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/{etc,conf.d}
    \cp php.ini-production /usr/local/php/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.filename =.*/user_ini.filename = ".user.ini"/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.cache_ttl =.*/user_ini.cache_ttl = 300/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    cd ${cur_dir}/src

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 1024
pm.process_idle_timeout = 10s
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    \cp ${cur_dir}/init.d/php-fpm.service /etc/systemd/system/php-fpm.service
    chmod +x /etc/init.d/php-fpm
fi
}

Install_PHP_84()
{
    Install_Libzip
    Echo_Blue "[+] Installing ${Php_Ver}"
    Tar_Cd ${Php_Ver}.tar.bz2 ${Php_Ver}
    if [ "${Stack}" = "lnmp" ]; then
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    else
        ./configure --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc --with-config-file-scan-dir=/usr/local/php/conf.d --with-apxs2=/usr/local/apache/bin/apxs --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}
    fi

    PHP_Make_Install

    Ln_PHP_Bin

    echo "Copy new php configure file..."
    mkdir -p /usr/local/php/{etc,conf.d}
    \cp php.ini-production /usr/local/php/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' /usr/local/php/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' /usr/local/php/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' /usr/local/php/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' /usr/local/php/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' /usr/local/php/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.filename =.*/user_ini.filename = ".user.ini"/g' /usr/local/php/etc/php.ini
    sed -i 's/;user_ini.cache_ttl =.*/user_ini.cache_ttl = 300/g' /usr/local/php/etc/php.ini
    Pear_Pecl_Set
    Install_Composer

    cd ${cur_dir}/src

if [ "${Stack}" = "lnmp" ]; then
    echo "Creating new php-fpm configure file..."
    cat >/usr/local/php/etc/php-fpm.conf<<EOF
[global]
pid = /usr/local/php/var/run/php-fpm.pid
error_log = /usr/local/php/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www
pm = dynamic
pm.max_children = 10
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 6
pm.max_requests = 1024
pm.process_idle_timeout = 10s
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/${Php_Ver}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
    \cp ${cur_dir}/init.d/php-fpm.service /etc/systemd/system/php-fpm.service
    chmod +x /etc/init.d/php-fpm
fi
}

LNMP_PHP_Opt()
{
    if [[ ${MemTotal} -gt 1024 && ${MemTotal} -le 2048 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 20#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 10#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 10#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 20#" /usr/local/php/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 2048 && ${MemTotal} -le 4096 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 40#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 20#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 20#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 40#" /usr/local/php/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 4096 && ${MemTotal} -le 8192 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 60#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 30#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 30#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 60#" /usr/local/php/etc/php-fpm.conf
    elif [[ ${MemTotal} -gt 8192 ]]; then
        sed -i "s#pm.max_children.*#pm.max_children = 80#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.start_servers.*#pm.start_servers = 40#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.min_spare_servers.*#pm.min_spare_servers = 40#" /usr/local/php/etc/php-fpm.conf
        sed -i "s#pm.max_spare_servers.*#pm.max_spare_servers = 80#" /usr/local/php/etc/php-fpm.conf
    fi
}

Creat_PHP_Tools()
{
    echo "Create PHP Info Tool..."
    cat >${Default_Website_Dir}/phpinfo.php<<eof
<?php
phpinfo();
?>
eof

    echo "Copy PHP Prober..."
    cd ${cur_dir}/src
    unzip -o probe.zip
    \cp probe.php ${Default_Website_Dir}/probe.php

    \cp ${cur_dir}/conf/index.html ${Default_Website_Dir}/index.html
    \cp ${cur_dir}/conf/lnmp.gif ${Default_Website_Dir}/lnmp.gif

    if [ ${PHPSelect} -ge 1 ]; then
        echo "Copy Opcache Control Panel..."
        \cp ${cur_dir}/conf/ocp.php ${Default_Website_Dir}/ocp.php
    fi
    echo "============================Install PHPMyAdmin================================="
    [[ -d ${Default_Website_Dir}/phpmyadmin ]] && rm -rf ${Default_Website_Dir}/phpmyadmin
    tar Jxf ${PhpMyAdmin_Ver}.tar.xz
    mv ${PhpMyAdmin_Ver} ${Default_Website_Dir}/phpmyadmin
    \cp ${cur_dir}/conf/config.inc.php ${Default_Website_Dir}/phpmyadmin/config.inc.php
    sed -i 's/nmpscript_generate_random_secret/nmpscript_'`date +%s%N | head -c 16`'/g' ${Default_Website_Dir}/phpmyadmin/config.inc.php
    mkdir ${Default_Website_Dir}/phpmyadmin/{upload,save}
    chmod 755 -R ${Default_Website_Dir}/phpmyadmin/
    chown www:www -R ${Default_Website_Dir}/phpmyadmin/
    echo "============================phpMyAdmin install completed======================="
}
