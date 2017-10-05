DEVICE=$1
Type=$2
VERSION=$3

##upload to sourceforge
sshpass -p admin12051 scp miui-$DEVICE-$Type-$VERSION-7.0.zip gybb666@shell.sourceforge.net:/home/frs/project/nx531j-miui9/

#move to httpd server
mv miui-$DEVICE-$Type-$VERSION-7.0.zip /var/www/html/

#upload to qiniu
./tools/upload/qiniu/qshell_linux_amd64 rput ttotoo-addons-south miui-$DEVICE-$Type-$VERSION-7.0.zip /var/www/html/miui-$DEVICE-$Type-$VERSION-7.0.zip

#upload to baidu
bypy mkdir MIUI9/$VERSION
bypy upload /var/www/html/miui-$DEVICE-$Type-$VERSION-7.0.zip MIUI9/$VERSION/

#upload to mega
./tools/upload/mega/megamkdir /Root/MIUI9/$VERSION
./tools/upload/mega/megaput --path /Root/MIUI9/$VERSION/miui-$DEVICE-$Type-$VERSION-7.0.zip /var/www/html/miui-$DEVICE-$Type-$VERSION-7.0.zip
