DEVICE=$1
Type=$2
VERSION=$3

#move to httpd server
mv miui-$DEVICE-$Type-$VERSION-7.0.zip /var/www/html/
mv OTA-$DEVICE-$Type-$VERSION.zip /var/www/html/

#upload to qiniu
./tools/upload/qiniu/qshell_linux_amd64 rput ttotoo-addons-south miui-$DEVICE-$Type-$VERSION-7.0.zip /var/www/html/miui-$DEVICE-$Type-$VERSION-7.0.zip
./tools/upload/qiniu/qshell_linux_amd64 rput ttotoo-ota-miui9 OTA-$DEVICE-$Type-$VERSION.zip /var/www/html/OTA-$DEVICE-$Type-$VERSION.zip

#upload to mega
megamkdir /Root/MIUI9/$VERSION
megaput --path /Root/MIUI9/$VERSION/miui-$DEVICE-$Type-$VERSION-7.0.zip /var/www/html/miui-$DEVICE-$Type-$VERSION-7.0.zip
megaput --path /Root/MIUI9/$VERSION/OTA-$DEVICE-$Type-$VERSION.zip /var/www/html/OTA-$DEVICE-$Type-$VERSION.zip

#upload to baidu
bypy mkdir MIUI9/$VERSION
bypy upload /var/www/html/miui-$DEVICE-$Type-$VERSION-7.0.zip MIUI9/$VERSION/
bypy upload /var/www/html/OTA-$DEVICE-$Type-$VERSION.zip MIUI9/$VERSION/
