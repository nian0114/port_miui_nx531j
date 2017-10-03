#add support for digitalocean
cd /usr/local/src 
wget -c http://mirrors.kernel.org/fedora-epel/epel-release-latest-7.noarch.rpm 
rpm -ivh epel-release-latest-7.noarch.rpm 
cd

yum -y install gcc zip unzip java git p7zip 
yum -y install glibc.i686 zlib.i686 glibc-devel libstdc++* libgcc_s.so.1
