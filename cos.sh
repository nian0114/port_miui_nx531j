wget https://github.com/tencentyun/cosfs/releases/download/v1.0.2/cosfs_1.0.2-ubuntu14.04_amd64.deb
sudo dpkg -i cosfs_1.0.2-ubuntu14.04_amd64.deb

echo ${bucket}:${access-key-id}:${access-key-secret} > /etc/passwd-cosfs
chmod 640 /etc/passwd-cosfs
mkdir /tmp/cosfs
cosfs ${appid}:${bucket} /tmp/cosfs -ourl=http://cn-east.myqcloud.com -odbglevel=info
