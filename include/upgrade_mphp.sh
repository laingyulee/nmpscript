#!/usr/bin/env bash

Upgrade_Multiplephp()
{
    Get_Dist_Name
    Check_DB
    Check_Stack
    . include/upgrade_php.sh

    if [ "${Get_Stack}" != "lnmp" ]; then
        echo "Multiple PHP Versions ONLY for LNMP Stack!"
        exit 1
    fi

    if [[ ! -s /usr/local/php8.1/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.1.conf ]] && [[ ! -s /usr/local/php8.2/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.2.conf ]] && [[ ! -s /usr/local/php8.3/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.3.conf ]] && [[ ! -s /usr/local/php8.4/sbin/php-fpm && ! -s /usr/local/nginx/conf/enable-php8.4.conf ]]; then
        echo "Multiple php version not found!"
        exit 1
    else
        echo "List all mutiple php, Please select the PHP version."
        if [[ -s /usr/local/php8.1/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.1.conf && -s /etc/init.d/php-fpm8.1 ]]; then
            Echo_Green "1: PHP 8.1 [found]"
        fi
        if [[ -s /usr/local/php8.2/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.2.conf && -s /etc/init.d/php-fpm8.2 ]]; then
            Echo_Green "2: PHP 8.2 [found]"
        fi
        if [[ -s /usr/local/php8.3/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.3.conf && -s /etc/init.d/php-fpm8.3 ]]; then
            Echo_Green "3: PHP 8.3 [found]"
        fi
        if [[ -s /usr/local/php8.4/sbin/php-fpm && -s /usr/local/nginx/conf/enable-php8.4.conf && -s /etc/init.d/php-fpm8.4 ]]; then
            Echo_Green "4: PHP 8.4 [found]"
        fi
    fi

    while :;do
        MPHP_Select=""
        read -p "Please select which multiple php version to upgrade: " MPHP_Select
        if [ "${MPHP_Select}" = "" ]; then
            Echo_Red "Error: Please input number!"
        else
            break
        fi
    done

    if [ "${MPHP_Select}" = "1" ]; then
        Cur_MPHP_Big_Ver="8.1"
        Cur_MPHP_Path='/usr/local/php8.1'
    elif [ "${MPHP_Select}" = "2" ]; then
        Cur_MPHP_Big_Ver="8.2"
        Cur_MPHP_Path='/usr/local/php8.2'
    elif [ "${MPHP_Select}" = "3" ]; then
        Cur_MPHP_Big_Ver="8.3"
        Cur_MPHP_Path='/usr/local/php8.3'
    elif [ "${MPHP_Select}" = "4" ]; then
        Cur_MPHP_Big_Ver="8.4"
        Cur_MPHP_Path='/usr/local/php8.4'
    fi

    Echo_Yellow "Please choose whic multiple php version to upgrade."
    Echo_Yellow "Note: you can't upgrade php cross-version!"

    php_version=""
    Cur_MPHP_Version=$("${Cur_MPHP_Path}/bin/php-config" --version)
    echo "Current PHP Version: ${Cur_MPHP_Version}"
    echo "You can get version number from http://www.php.net"
    read -p "Please enter a PHP Version you want: " php_version
    if [ "${php_version}" = "" ]; then
        Echo_Red "Error: You must enter a corrent php version!!"
        exit 1
    fi
    if echo "${php_version}" | grep -Eqi "${Cur_MPHP_Big_Ver}"; then
        Echo_Blue "You will upgrade php ${Cur_MPHP_Version} from to ${php_version}."
    else
        Echo_Red "Error: You can't upgrade php cross-version!"
        exit 1
    fi
    Press_Start
    cd ${cur_dir}/src
    if [ -s php-${php_version}.tar.bz2 ]; then
        echo "php-${php_version}.tar.bz2 [found]"
    else
        Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    fi

    lnmp stop

    Echo_Blue "Backup old multiple php version..."
    mv ${Cur_MPHP_Path} /usr/local/mphp-${Cur_MPHP_Big_Ver}-backup${Upgrade_Date}
    mv /etc/init.d/php-fpm${Cur_MPHP_Big_Ver} /usr/local/mphp-${Cur_MPHP_Big_Ver}-backup${Upgrade_Date}/init.d.php-fpm.bak.${Upgrade_Date}

    Check_PHP_Option
    cat /etc/issue
    cat /etc/*-release
    Install_PHP_Dependent
    Check_Openssl

    if [ "${MPHP_Select}" = "1" ]; then
        Upgrade_MPHP8.1
    elif [ "${MPHP_Select}" = "2" ]; then
        Upgrade_MPHP8.2
    elif [ "${MPHP_Select}" = "3" ]; then
        Upgrade_MPHP8.3
    elif [ "${MPHP_Select}" = "4" ]; then
        Upgrade_MPHP8.4
    else
        Echo_Red "PHP version: ${php_version} is not supported."
        exit 1
    fi
}

Upgrade_MPHP8.4()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Install_Libzip
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tar_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}/src

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi8.4.sock
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
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm8.4
    chmod +x /etc/init.d/php-fpm8.4
    sed -i 's@# Provides:          php-fpm@# Provides:          php-fpm8.4@g' /etc/init.d/php-fpm8.4

    StartUp php-fpm8.4

    \cp ${cur_dir}/conf/enable-php8.4.conf /usr/local/nginx/conf/enable-php8.4.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP8.1()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Install_Libzip
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tar_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}/src

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi8.1.sock
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
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm8.1
    chmod +x /etc/init.d/php-fpm8.1
    sed -i 's@# Provides:          php-fpm@# Provides:          php-fpm8.1@g' /etc/init.d/php-fpm8.1

    StartUp php-fpm8.1

    \cp ${cur_dir}/conf/enable-php8.1.conf /usr/local/nginx/conf/enable-php8.1.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP8.2()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Install_Libzip
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tar_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}/src

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi8.2.sock
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
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm8.2
    chmod +x /etc/init.d/php-fpm8.2
    sed -i 's@# Provides:          php-fpm@# Provides:          php-fpm8.2@g' /etc/init.d/php-fpm8.2

    StartUp php-fpm8.2

    \cp ${cur_dir}/conf/enable-php8.2.conf /usr/local/nginx/conf/enable-php8.2.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}

Upgrade_MPHP8.3()
{
    cd ${cur_dir}/src
    Download_Files ${Download_Mirror}/web/php/php-${php_version}.tar.bz2 php-${php_version}.tar.bz2
    Install_Libzip
    Echo_Blue "[+] Upgrading php-${php_version}"
    Tar_Cd php-${php_version}.tar.bz2 php-${php_version}
    ./configure --prefix=${Cur_MPHP_Path} --with-config-file-path=${Cur_MPHP_Path}/etc --with-config-file-scan-dir=${Cur_MPHP_Path}/conf.d --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv=/usr/local --with-freetype=/usr/local/freetype --with-jpeg --with-zlib --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem ${with_curl} --enable-mbregex --enable-mbstring --enable-intl --enable-pcntl --enable-ftp --enable-gd ${with_openssl} --with-mhash --enable-pcntl --enable-sockets --with-zip --enable-soap --with-gettext ${with_fileinfo} --enable-opcache --with-xsl --with-pear --with-webp ${PHP_Buildin_Option} ${PHP_Modules_Options}

    PHP_Make_Install

    echo "Copy new php configure file..."
    mkdir -p ${Cur_MPHP_Path}/{etc,conf.d}
    \cp php.ini-production ${Cur_MPHP_Path}/etc/php.ini

    # php extensions
    echo "Modify php.ini......"
    sed -i 's/post_max_size =.*/post_max_size = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/upload_max_filesize =.*/upload_max_filesize = 50M/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;date.timezone =.*/date.timezone = PRC/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/short_open_tag =.*/short_open_tag = On/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/max_execution_time =.*/max_execution_time = 300/g' ${Cur_MPHP_Path}/etc/php.ini
    sed -i 's/disable_functions =.*/disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,popen,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server/g' ${Cur_MPHP_Path}/etc/php.ini

    cd ${cur_dir}/src

    echo "Creating new php-fpm configure file..."
    cat >${Cur_MPHP_Path}/etc/php-fpm.conf<<EOF
[global]
pid = ${Cur_MPHP_Path}/var/run/php-fpm.pid
error_log = ${Cur_MPHP_Path}/var/log/php-fpm.log
log_level = notice

[www]
listen = /tmp/php-cgi8.3.sock
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
request_terminate_timeout = 100
request_slowlog_timeout = 0
slowlog = var/log/slow.log
EOF

    echo "Copy php-fpm init.d file..."
    \cp ${cur_dir}/src/php-${php_version}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm8.3
    chmod +x /etc/init.d/php-fpm8.3
    sed -i 's@# Provides:          php-fpm@# Provides:          php-fpm8.3@g' /etc/init.d/php-fpm8.3

    StartUp php-fpm8.3

    \cp ${cur_dir}/conf/enable-php8.3.conf /usr/local/nginx/conf/enable-php8.3.conf

    sleep 2

    lnmp start

    rm -rf ${cur_dir}/src/php-${php_version}

    if [ -s ${Cur_MPHP_Path}/sbin/php-fpm ] && [ -s ${Cur_MPHP_Path}/etc/php.ini ] && [ -s ${Cur_MPHP_Path}/bin/php ]; then
        echo "==========================================="
        Echo_Green "You have successfully upgrade to php-${php_version} "
        echo "==========================================="
    else
        rm -rf ${Cur_MPHP_Path}
        Echo_Red "Failed to upgrade php-${php_version}, you can download /root/upgrade_mphp${Upgrade_Date}.log from your server, and upload it to LNMP Forum."
    fi
}
