# docker-typecho

Docker 环境下安装部署 [Typecho](https://typecho.org/) 博客模板

## 容器环境

+ OS：Debian
+ PHP：7.4.16
+ Apache：2.4.38

## docker安装

+ Centos：`yum install docker -y`

+ 其他：
  + `curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun`
  + `curl -sSL https://get.daocloud.io/docker | sh`

## Usage

拉取镜像

```bash
docker pull linkaliu/docker-typecho
```

选择一个目录用来安装 Typecho 和 Apache

```bash
cd /var/www/blog
```

下载 Typecho 安装包，如果是迁移，就不用下载安装包，将原有目录放到`/opt/typecho`目录就可以了

```bash
wget http://typecho.org/downloads/1.1-17.10.30-release.tar.gz && \
tar -zxvf 1.1-17.10.30-release.tar.gz && \
mv build typecho && \
rm 1.1-17.10.30-release.tar.gz -rf
```

启动一个临时容器，从容器内部提取 Apache 配置文件，并修改为自己的配置

```bash
docker run -d --name temp_typecho linkaliu/docker-typecho && \
docker cp temp_typecho:/etc/apache2 . && \
docker rm temp_typecho -f
```

启动容器

```bash
docker run -d --name typecho \
-p 80:80 -p 443:443 \
-v /var/www/blog/typecho:/var/www/html \
-v /var/www/blog/apache2:/etc/apache2 linkaliu/docker-typecho
```

访问 **` http://<IP Address> `**，进行下一步操作

## 数据库连接

常用方式：云数据库、服务器数据库、Docker数据库镜像

推荐使用云数据库进行连接，方便部署和迁移，使用云数据库时，需放开80端口，如果需要使用https，还需放开443端口。其他方式需使用内网地址进行连接

常见错误：

1. 错误：*Warning: Cannot modify header information - headers already sent by (output started at /var/www/html/install.php:202) in /var/www/html/var/Typecho/Cookie.php on line 102** 或 **Warning: Cannot modify header information - headers already sent by (output started at /var/www/html/install.php:202) in /var/www/html/install.php on line 559*

   解决方案：云数据库问题，在**typecho/install.php** **56**行添加**ob_start();**

2. 错误：*安装程序捕捉到以下错误: "SQLSTATE[HY000]: General error: 3161 Storage engine MyISAM is disabled (Table creation is disallowed).". 程序被终止, 请检查您的配置信息.*

   解决方案：因为mysql当前版本不支持MyISAM引擎，将**typecho/install/Mysql.sql**中的**MyISAM**修改为**INNODB**，刷新页面

## 其他问题

### 地址重写，去掉index.php

在**设置** - **永久链接设置**下，强制启用**地址重写功能**

```bash
# 进入opt目录
cd /opt

# 启用地址重新功能rewrite
cp apache2/mods-available/rewrite.load apache2/mods-enabled/

# 修改apache2/apache2.conf
# 添加以下语句
RewriteEngine On
<Directory /var/www/html>
 Options Indexes FollowSymLinks
 AllowOverride All
 RewriteCond %{REQUEST_FILENAME} !-d
 RewriteCond %{REQUEST_FILENAME} !-f
 RewriteRule ^(.*)$ index.php [L,E=PATH_INFO:$1]
 Require all granted
</Directory>

# 重启docker容器typecho
docker restart typecho
```

### 使用域名

```bash
# 进入opt目录
cd /opt

# 修改apache2/sites-enabled/000-default.conf
# 在ServerAdmin下面增加一行，将www.example.com改为自己的域名
ServerName www.example.com

# 重启typecho容器
docker restart typecho
```

### 使用Https

```bash
# 进入opt目录
cd /opt

# 启用SSL功能
cp apache2/mods-available/ssl.* apache2/mods-enabled/ && \
cp apache2/mods-available/socache_shmcb.load apache2/mods-enabled/ && \
cp apache2/sites-available/default-ssl.conf apache2/sites-enabled/

# 删除原有镜像
docker rm typecho -f

# 暴露443端口
docker run -d --name typecho \
-p 80:80 -p 443:443 \
-v /opt/typecho:/var/www/html \
-v /opt/apache2:/etc/apache2 linkaliu/docker-typecho

# 将证书上传到apache2文件夹cert内
# 修改apache2/sites-enabled/default-ssl.conf
# 在ServerAdmin下面添加一行，将www.example.com改为自己的域名
ServerName www.example.com

# 修改对应的key，使用自己的证书
SSLCertificateFile cert/5580757_blog.bilishare.com_public.crt
SSLCertificateKeyFile cert/5580757_blog.bilishare.com.key
SSLCertificateChainFile cert/5580757_blog.bilishare.com_chain.crt
```

### http跳转https

```bash
# 进入opt目录
cd /opt

# 修改apache2/sites-enabled/000-default.conf
# 添加以下内容
RewriteCond %{SERVER_PORT} !^443$
RewriteRule ^/?(.*)$ https://%{SERVER_NAME}/$1 [L,R]
```

## License

[MIT](https://github.com/aliuq/docker-typecho/blob/main/LICENSE)
