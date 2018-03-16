git clone https://github.com/nian0114/cosfs.git
cd cosfs
./autogen.sh
./configure
make
sudo make install

echo ${bucket}:${access-key-id}:${access-key-secret} > /home/travis/passwd-cosfs
chmod 640 /home/travis/passwd-cosfs
mkdir /tmp/cosfs
cosfs ${appid}:${bucket} /tmp/cosfs -ourl=http://cn-east.myqcloud.com -odbglevel=info
