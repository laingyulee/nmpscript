#!/usr/bin/env bash

Autoconf_Ver='autoconf-2.13'
Libiconv_Ver='libiconv-1.17'
LibMcrypt_Ver='libmcrypt-2.5.8'
Mcypt_Ver='mcrypt-2.6.8'
Mhash_Ver='mhash-0.9.9.9'
# NOTE: Freetype_Ver (2.7) is legacy version for older systems, use Freetype_New_Ver for modern systems
Freetype_Ver='freetype-2.7'
Freetype_New_Ver='freetype-2.13.0'
# NOTE: Curl_Ver should be updated to latest stable version (8.x series) for security fixes
Curl_Ver='curl-8.7.1'
Pcre_Ver='pcre-8.45'
Jemalloc_Ver='jemalloc-5.3.0'
TCMalloc_Ver='gperftools-2.9.1'
Libunwind_Ver='libunwind-1.2.1'
Libicu4c_Ver='icu4c-58_3'
# NOTE: OpenSSL 1.0.2u is EOL (End of Life) since Dec 2019, use Openssl_New_Ver for new installations
# Kept for compatibility with older nginx versions
Openssl_Ver='openssl-1.0.2u'
Openssl_New_Ver='openssl-3.0.13'
Nghttp2_Ver='nghttp2-1.52.0'
Libzip_Ver='libzip-1.3.2'
Luajit_Ver='luajit2-2.1-20230119'
LuaNginxModule='lua-nginx-module-0.10.26'
LuaRestyCore='lua-resty-core-0.1.28'
LuaRestyLrucache='lua-resty-lrucache-0.13'
NgxDevelKit='ngx_devel_kit-0.3.3'
Nginx_Ver='nginx-1.30.3'
NgxFancyIndex_Ver='ngx-fancyindex-0.5.2'
if [ "${DBSelect}" = "1" ]; then
    Mariadb_Ver='mariadb-10.5.24'
elif [ "${DBSelect}" = "2" ]; then
    Mariadb_Ver='mariadb-10.6.17'
elif [ "${DBSelect}" = "3" ]; then
    Mariadb_Ver='mariadb-10.11.18'
fi
# Default PHP version (PHP 8.4.22)
Php_Ver='php-8.4.22'
if [ "${PHPSelect}" = "1" ]; then
    Php_Ver='php-8.1.28'
elif [ "${PHPSelect}" = "2" ]; then
    Php_Ver='php-8.2.19'
elif [ "${PHPSelect}" = "3" ]; then
    Php_Ver='php-8.3.32'
elif [ "${PHPSelect}" = "4" ]; then
    Php_Ver='php-8.4.22'
fi
PhpMyAdmin_Ver='phpMyAdmin-5.2.1-all-languages'
APR_Ver='apr-1.7.4'
APR_Util_Ver='apr-util-1.6.3'
Apache_Ver='httpd-2.4.68'

Pureftpd_Ver='pure-ftpd-1.0.49'
ImageMagick_Ver='ImageMagick-7.1.1-8'
Imagick_Ver='imagick-3.7.0'
Redis_Stable_Ver='redis-7.0.11'
PHPRedis_Ver='redis-5.3.7'
Memcached_Ver='memcached-1.6.15'
Libmemcached_Ver='libmemcached-awesome-1.1.4'
PHPMemcached_Ver='memcached-2.2.0'
PHP7Memcached_Ver='memcached-3.1.5'
PHP8Memcached_Ver='memcached-3.2.0'
PHPMemcache_Ver='memcache-3.0.8'
PHP7Memcache_Ver='memcache-4.0.5.2'
PHP8Memcache_Ver='memcache-8.2'
PHPOldApcu_Ver='apcu-4.0.11'
PHPNewApcu_Ver='apcu-5.1.22'
PHPApcu_Bc_Ver='apcu_bc-1.0.5'
PHPSodium_Ver='libsodium-2.0.23'
PHPSwoole_Ver='swoole-5.1.1'
