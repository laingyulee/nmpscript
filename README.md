# NMPScript

一键安装 **Nginx + MariaDB + PHP** 环境脚本

LNMP Fork，仅支持 PHP 8.1+ 和 MariaDB。

## 组件版本

| 组件 | 版本 | 说明 |
|------|------|------|
| Nginx | 1.30.3 | 稳定版 |
| MariaDB | 10.5.24 / 10.6.17 / 10.11.18 | 三选一 |
| PHP | 8.1.28 / 8.2.19 / 8.3.32 / 8.4.22 | 四选一，默认 8.4 |
| Apache | 2.4.68 | LNMPA / LAMP 模式可选 |
| phpMyAdmin | 5.2.1 | |
| libmemcached | 1.1.4 (libmemcached-awesome) | 活跃维护分支 |
| Redis / Memcached / ImageMagick / ionCube / etc. | | 通过 `addons.sh` 安装 |

## 系统要求

- Linux（CentOS / Debian / Ubuntu / Rocky / AlmaLinux）
- 内存 ≥ 512MB
- 已安装 `wget`、`curl`、`tar`

## 安装

### 使用 screen 避免断线（推荐）

长时间编译过程中，如果 SSH 连接中断会导致安装失败。建议使用 `screen` 创建虚拟终端：

```bash
# 安装 screen（如果未安装）
# CentOS/Rocky/AlmaLinux
yum install screen -y

# Debian/Ubuntu
apt-get install screen -y

# 创建新的 screen 会话
screen -S lnmp

# 查看当前会话列表
screen -ls

# 重新连接会话
screen -r lnmp

# 分离会话（按 Ctrl+A 然后按 D）
# 退出会话（在会话内执行 exit）
```

### 安装步骤

```bash
# 下载
git clone https://github.com/laingyulee/nmpscript.git
cd nmpscript

# 按提示逐步选择组件版本
chmod +x install.sh
./install.sh
```

也可通过 `lnmp.conf` 预设参数实现静默安装：

```bash
# lnmp.conf 预设示例
DBSelect="3"       # MariaDB 10.11
PHPSelect="4"      # PHP 8.4
SelectMalloc="1"   # 不安装 Jemalloc/TCMalloc
```

## 使用

### 管理命令

```bash
lnmp start          # 启动所有服务
lnmp stop           # 停止所有服务
lnmp restart        # 重启所有服务
lnmp status         # 查看状态
lnmp reload         # 重载配置
```

### 添加虚拟主机

```bash
lnmp vhost add      # 交互式添加
lnmp vhost list     # 列出所有
lnmp vhost del      # 删除
```

### 安装扩展

```bash
./addons.sh install {memcached|redis|apcu|imagemagick|ioncube|sg|exif|fileinfo|ldap|bz2|sodium|imap|swoole}
```

### 升级

```bash
./upgrade.sh
# 1: Nginx
# 2: MariaDB
# 3: PHP (LNMP 模式)
# 4: PHP (LNMPA / LAMP 模式)
# 5: phpMyAdmin
# 6: 多 PHP 版本
```

## 目录结构

```
├── install.sh         # 主安装脚本
├── upgrade.sh         # 升级脚本
├── uninstall.sh       # 卸载脚本
├── addons.sh          # 扩展安装
├── lnmp.conf          # 配置
├── include/           # 核心脚本
│   ├── main.sh        # 公共函数
│   ├── init.sh        # 依赖安装
│   ├── mariadb.sh     # MariaDB 安装
│   ├── php.sh         # PHP 安装
│   ├── nginx.sh       # Nginx 安装
│   ├── apache.sh      # Apache 安装
│   └── upgrade_*.sh   # 升级模块
├── conf/              # 配置文件模板
├── src/               # 源码包缓存
└── tools/             # 辅助工具
```

## 与原始 LNMP 的区别

- ✅ 所有下载源替换为官方 URL，不再依赖失效镜像站
- ✅ 默认 PHP 版本 8.4.22
- ✅ libmemcached 升级为 libmemcached-awesome 活跃维护分支

## License

Apache 2.0