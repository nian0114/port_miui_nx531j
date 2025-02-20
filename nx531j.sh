#!/bin/bash
DEVICE=nx531j;
CPU=arm64;
FSTABLE=4294967296;
USER=`whoami`
PORTS_ROOT=`pwd`
DOWNLOAD_LINK=`cat link`
#All var is above

XMLMERGYTOOL=$PORTS_ROOT/tools/ResValuesModify/jar/ResValuesModify

if [[ $1 == *Alpha* ]];then
	Type="Aphla"
elif [[ $1 == *xiaomi.eu* ]];then
	Type="Global"
else
	Type="Developer"
fi

echo "Start to build MIUI9 ($DEVICE-$Type)"

#check if project is still here
if [ -d "workspace" ]; then
	echo "Cleaning Up..."
	rm -rf workspace miui_$DEVICE-*-7.0.zip OTA-$DEVICE-$Type-*.zip final/*
	rm -rf /var/www/html/miui-$DEVICE-$Type-*-7.0.zip
	rm -rf /var/www/html/OTA-$DEVICE-$Type-*.zip
else
	rm -rf miui-$DEVICE-*-7.0.zip OTA-$DEVICE-$Type-*.zip final/*
	rm -rf /var/www/html/miui-$DEVICE-$Type-*-7.0.zip
	rm -rf /var/www/html/OTA-$DEVICE-$Type-*.zip
fi

if [ -n "$1" ];then
	echo $1
	mkdir -p stockrom
	wget -O tmp.zip $1 >/dev/null 2>&1
	unzip tmp.zip -d stockrom/
	rm -rf tmp.zip
elif [ -n "$DOWNLOAD_LINK" ];then
	echo $DOWNLOAD_LINK
	mkdir -p stockrom
	wget -O tmp.zip $DOWNLOAD_LINK
	unzip tmp.zip -d stockrom/
	rm -rf tmp.zip
fi

mkdir -p workspace/output workspace/app final/data/miui final/data/app final/system target

#Start to extract system(Linux)
echo "Extract system ..."
if [ -f "stockrom/system.new.dat" ]; then
	cp -f stockrom/system.transfer.list workspace/
	cp -f stockrom/system.new.dat workspace/
	cp -f stockrom/boot.img workspace/
	cd $PORTS_ROOT/workspace
	./../tools/sdat2img.py system.transfer.list system.new.dat system.img &> /dev/null
	sudo mount -t ext4 -o loop system.img output/
	sudo chown -R $USER:$USER output
elif [ -f "stockrom/system.img" ];then
	./tools/linux-x86/simg2img stockrom/system.img system_new.img
	if [ -s "system_new.img" ];then
		mv system_new.img workspace/system.img
	else
		cp -f stockrom/system.img workspace/system.img
	fi
	cp -f stockrom/boot.img workspace/
	cd $PORTS_ROOT/workspace
	sudo mount -t ext4 -o loop system.img output/
	sudo chown -R $USER:$USER output
elif [ -d "stockrom/system/framework" ];then
	cp -rf stockrom/system workspace/
	cp -f stockrom/boot.img workspace/
else
	exit
fi

rm -rf $PORTS_ROOT/stockrom

VERSION=`grep "ro.build.version.incremental" output/build.prop|cut -d"=" -f2`

git tag "$(date +'%Y%m%d%H%M%S')-$Type-$VERSION"

cd $PORTS_ROOT/workspace
if [ -d output/framework/$CPU ];then
	echo "Start Odex System ..."
	cp -rf ../tools/odex/* $PWD
	cp -rpf output/framework superr_miui/system/
	cp -rpf output/app superr_miui/system/
	cp -rpf output/vendor/app superr_miui/system/
	cp -rpf output/priv-app superr_miui/system/
	cp -rpf output/build.prop superr_miui/system/

	./superr

	#move to vendor/app
	mkdir -p superr_miui/system/vendor/app
	mv superr_miui/system/app/CABLService superr_miui/system/vendor/app/
	mv superr_miui/system/app/colorservice superr_miui/system/vendor/app/
	mv superr_miui/system/app/ims superr_miui/system/vendor/app/
	mv superr_miui/system/app/imssettings superr_miui/system/vendor/app/
	mv superr_miui/system/app/SVIService superr_miui/system/vendor/app/

	rm -rf output/app output/priv-app output/framework output/vendor/app
	mv superr_miui/system/app output/
	mv superr_miui/system/framework output/
	mv superr_miui/system/priv-app output/
	mv superr_miui/system/vendor/app output/vendor/

	rm -rf tools
	rm -rf superr
fi


echo "Disable Recovery Auto Install ..."
rm -rf output/recovery-from-boot.p
rm -rf output/bin/install-recovery.sh

rm -rf output/etc/acdbdata/adsp_avs_config.acdb
rm -rf output/etc/acdbdata/Forte/Forte_Bluetooth_cal.acdb
rm -rf output/etc/acdbdata/Forte/Forte_General_cal.acdb
rm -rf output/etc/acdbdata/Forte/Forte_Global_cal.acdb
rm -rf output/etc/acdbdata/Forte/Forte_Handset_cal.acdb
rm -rf output/etc/acdbdata/Forte/Forte_Hdmi_cal.acdb
rm -rf output/etc/acdbdata/Forte/Forte_Headset_cal.acdb
rm -rf output/etc/acdbdata/Forte/Forte_Speaker_cal.acdb
rm -rf output/etc/camera/imx230_qc2002_chromatix.xml
rm -rf output/etc/camera/imx230_qc2002_with_gyro_chromatix.xml
rm -rf output/etc/camera/imx258_mono_chromatix.xml
rm -rf output/etc/camera/imx258_mono_ofilm_chromatix.xml
rm -rf output/etc/camera/imx258_ofilm_chromatix.xml
rm -rf output/etc/camera/imx298_liteon_chromatix.xml
rm -rf output/etc/camera/imx298_semco_chromatix.xml
rm -rf output/etc/camera/imx318_chromatix.xml
rm -rf output/etc/camera/imx362_chromatix.xml
rm -rf output/etc/camera/imx378_chromatix.xml
rm -rf output/etc/camera/imx378_semco_chromatix.xml
rm -rf output/etc/camera/msm8953_camera.xml
rm -rf output/etc/camera/ov16880_chromatix.xml
rm -rf output/etc/camera/ov2680_chromatix.xml
rm -rf output/etc/camera/ov4688_primax_chromatix.xml
rm -rf output/etc/camera/ov5670_f5670bq_chromatix.xml
rm -rf output/etc/camera/ov5675_primax_chromatix.xml
rm -rf output/etc/camera/ov5695_chromatix.xml
rm -rf output/etc/camera/s5k3l8_f3l8yam_chromatix.xml
rm -rf output/etc/camera/s5k3m2xm_chromatix_bear.xml
rm -rf output/etc/camera/s5k3p3_chromatix.xml
rm -rf output/etc/camera/s5k3p3_qtech_chromatix.xml
rm -rf output/etc/camera/s5k3p3sm_chromatix.xml
rm -rf output/etc/firmware/cpp_firmware_v1_12_0.fw
rm -rf output/etc/firmware/tfa9891.cnt
rm -rf output/etc/firmware/wlan/qca_cld/WCNSS_cfg.dat
rm -rf output/etc/permissions/android.hardware.consumerir.xml
rm -rf output/etc/permissions/android.hardware.ethernet.xml
rm -rf output/etc/permissions/android.hardware.sensor.barometer.xml
rm -rf output/etc/permissions/android.hardware.sensor.hifi_sensors.xml
rm -rf output/lib64/hw/consumerir.msm8996.so
rm -rf output/lib64/hw/fingerprint.fpc.so
rm -rf output/lib/hw/consumerir.msm8996.so
rm -rf output/lib/hw/fingerprint.fpc.so
rm -rf output/lib/modules/exfat.ko
rm -rf output/vendor/lib/libactuator_ak7348.so
rm -rf output/vendor/lib/libactuator_ak7371_a4_primax.so
rm -rf output/vendor/lib/libactuator_ak7371_a7_liteon.so
rm -rf output/vendor/lib/libactuator_ak7371_a7_semco.so
rm -rf output/vendor/lib/libactuator_bu64245.so
rm -rf output/vendor/lib/libactuator_dw9763_a8_o-film.so
rm -rf output/vendor/lib/libactuator_dw9763_a8_qtech.so
rm -rf output/vendor/lib/libactuator_dw9763.so
rm -rf output/vendor/lib/libactuator_lc898212xd_qc2002.so
rm -rf output/vendor/lib/libactuator_lc898214xc.so
rm -rf output/vendor/lib/libactuator_lc898217xc_a4_semco.so
rm -rf output/vendor/lib/libactuator_lc898217xc.so
rm -rf output/vendor/lib/libchromatix_csidtg_common.so
rm -rf output/vendor/lib/libchromatix_csidtg_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_csidtg_postproc.so
rm -rf output/vendor/lib/libchromatix_csidtg_preview.so
rm -rf output/vendor/lib/libchromatix_csidtg_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx214_4k_preview_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_4k_video_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_common.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx214_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx214_default_preview_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_default_video_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_default_video.so
rm -rf output/vendor/lib/libchromatix_imx214_hdr_snapshot_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_hdr_video_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_hfr_120_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx214_hfr_60_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx214_hfr_90_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx214_postproc.so
rm -rf output/vendor/lib/libchromatix_imx214_preview.so
rm -rf output/vendor/lib/libchromatix_imx214_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx214_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx214_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx214_zsl_preview_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx214_zsl_video_lc898122.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_1080p_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_1080p_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_4k_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_4k_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_common.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_default_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_default_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_default_video.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hdr_snapshot_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hdr_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_120_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_240_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_60_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_90_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_postproc.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_preview.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_video_16M_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_1080p_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_1080p_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_4k_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_4k_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_common.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_default_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_default_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_default_video.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hdr_snapshot_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hdr_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_120_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_240_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_60_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_90_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_postproc.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_preview.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_video_16M_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_zsl_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_with_gyro_zsl_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_zsl_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_qc2002_zsl_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx258_4k_preview_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_4k_video_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_common.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx258_default_preview_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_default_video_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_default_video.so
rm -rf output/vendor/lib/libchromatix_imx258_hfr_120_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_hfr_60_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_hfr_90_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_4k_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_4k_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_common.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_default_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_default_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_default_video.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_hfr_120_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_hfr_60_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_hfr_90_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_4k_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_4k_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_common.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_default_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_default_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_default_video.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_hfr_120_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_hfr_60_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_hfr_90_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_postproc.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_zsl_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_ofilm_zsl_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_postproc.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_zsl_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_mono_zsl_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_4k_preview_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_4k_video_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_common.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_default_preview_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_default_video_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_default_video.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_hfr_120_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_hfr_60_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_hfr_90_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_postproc.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_zsl_preview_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_ofilm_zsl_video_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_postproc.so
rm -rf output/vendor/lib/libchromatix_imx258_preview.so
rm -rf output/vendor/lib/libchromatix_imx258_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx258_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx258_zsl_preview_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx258_zsl_video_bu64244gwz.so
rm -rf output/vendor/lib/libchromatix_imx268_common.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx268_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx268_default_video.so
rm -rf output/vendor/lib/libchromatix_imx268_hfr_120_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx268_hfr_60_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx268_hfr_90_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx268_postproc.so
rm -rf output/vendor/lib/libchromatix_imx268_preview.so
rm -rf output/vendor/lib/libchromatix_imx268_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_common.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_default_video.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_hfr_120_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_hfr_60_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_hfr_90_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_postproc.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_preview.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_zsl_preview_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_sunny_zsl_video_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_zsl_preview_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx268_zsl_video_bu64245.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_4K_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_4K_video.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_common.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_default_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_default_video.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hdr_snapshot_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hdr_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_postproc.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_liteon_zsl_video.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_4K_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_4K_video.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_common.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_default_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_default_video.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hdr_snapshot_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hdr_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_postproc.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_semco_zsl_video.so
rm -rf output/vendor/lib/libchromatix_imx318_1080p_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_1080p_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_4k_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_4k_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_common.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx318_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx318_default_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_default_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_default_video.so
rm -rf output/vendor/lib/libchromatix_imx318_fullsize_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_fullsize_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_hfr_120_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx318_hfr_240_lc898214xc.so
rm -rf output/vendor/lib/libchromatix_imx318_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx318_hfr_60_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx318_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx318_postproc.so
rm -rf output/vendor/lib/libchromatix_imx318_preview.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_1080p_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_1080p_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_4k_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_4k_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_common.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_default_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_default_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_fullsize_preview_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_fullsize_video_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_hfr_120_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_hfr_240_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_hfr_60_ak7371.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_postproc.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_preview.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx318_primax_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_1080p_preview_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_1080p_video_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_4k_preview_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_4k_video_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_common.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_default_preview_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_default_video_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_fullsize_preview_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_fullsize_video_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_hfr_120_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_hfr_240_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_hfr_60_lc898217.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_postproc.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_preview.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx318_semco_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx318_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx318_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx362_1080p_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_1080p_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_4k_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_4k_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_common.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx362_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx362_default_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_default_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_default_video.so
rm -rf output/vendor/lib/libchromatix_imx362_fullsize_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_fullsize_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx362_hfr_240_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx362_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx362_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx362_postproc.so
rm -rf output/vendor/lib/libchromatix_imx362_preview.so
rm -rf output/vendor/lib/libchromatix_imx362_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx362_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_1080p_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_1080p_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_4k_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_4k_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_common.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx378_default_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_default_video.so
rm -rf output/vendor/lib/libchromatix_imx378_hdr_snapshot_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_hdr_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_240_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_1080p_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_1080p_video.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_4k_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_4k_video.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_common.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_default_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_default_video.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hdr_snapshot_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hdr_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_240_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_postproc.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_video_16M_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_video.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_liteon_zsl_video.so
rm -rf output/vendor/lib/libchromatix_imx378_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx378_postproc.so
rm -rf output/vendor/lib/libchromatix_imx378_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_1080p_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_1080p_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_4k_preview_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_4k_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_common.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_default_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_default_video.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hdr_snapshot_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hdr_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_240_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_240.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_postproc.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_video_16M_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_video.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_semco_zsl_video.so
rm -rf output/vendor/lib/libchromatix_imx378_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx378_video_16M_3a.so
rm -rf output/vendor/lib/libchromatix_imx378_video_4k.so
rm -rf output/vendor/lib/libchromatix_imx378_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx378_video.so
rm -rf output/vendor/lib/libchromatix_imx378_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx378_zsl_video.so
rm -rf output/vendor/lib/libchromatix_ov13850_common.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov13850_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov13850_default_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov13850_default_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov13850_default_video.so
rm -rf output/vendor/lib/libchromatix_ov13850_hfr_120_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov13850_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov13850_hfr_60_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov13850_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov13850_hfr_90_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov13850_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov13850_postproc.so
rm -rf output/vendor/lib/libchromatix_ov13850_preview.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_common.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_default_preview_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_default_video_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_default_video.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_hfr_120_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_hfr_60_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_hfr_90_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_postproc.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_preview.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_video_full.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_zsl_preview_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_q13v06k_zsl_video_bu64297.so
rm -rf output/vendor/lib/libchromatix_ov13850_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov13850_video_full.so
rm -rf output/vendor/lib/libchromatix_ov13850_zsl_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov13850_zsl_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_ov16880_common.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov16880_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov16880_default_preview_3a.so
rm -rf output/vendor/lib/libchromatix_ov16880_default_video_3a.so
rm -rf output/vendor/lib/libchromatix_ov16880_default_video.so
rm -rf output/vendor/lib/libchromatix_ov16880_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_ov16880_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov16880_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_ov16880_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov16880_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_ov16880_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov16880_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov16880_postproc.so
rm -rf output/vendor/lib/libchromatix_ov16880_preview.so
rm -rf output/vendor/lib/libchromatix_ov16880_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov16880_zsl_preview_3a.so
rm -rf output/vendor/lib/libchromatix_ov16880_zsl_video_3a.so
rm -rf output/vendor/lib/libchromatix_ov2680_a3_default_preview.so
rm -rf output/vendor/lib/libchromatix_ov2680_a3_default_video.so
rm -rf output/vendor/lib/libchromatix_ov2680_a3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov2680_common.so
rm -rf output/vendor/lib/libchromatix_ov2680_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov2680_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov2680_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov2680_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov2680_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov2680_default_video.so
rm -rf output/vendor/lib/libchromatix_ov2680_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov2680_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov2680_postproc.so
rm -rf output/vendor/lib/libchromatix_ov2680_preview.so
rm -rf output/vendor/lib/libchromatix_ov2680_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov2680_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_common.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_default_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_hfr_120_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_hfr_60_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_hfr_90_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_postproc.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_zsl_preview_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_a7_zsl_video_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_common.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_default_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_hfr_120_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_hfr_60_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_hfr_90_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_postproc.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_zsl_preview_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_b7_zsl_video_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_common.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_default_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_hfr_120_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_hfr_60_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_hfr_90_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_postproc.so
rm -rf output/vendor/lib/libchromatix_ov4688_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_common.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_default_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_hfr_120_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_hfr_60_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_hfr_90_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_postproc.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_zsl_preview_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_a7_zsl_video_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_common.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_default_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_hfr_120_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_hfr_60_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_hfr_90_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_postproc.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_zsl_preview_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_b7_zsl_video_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_common.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_default_video.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_hfr_120_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_hfr_60_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_hfr_90_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_postproc.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_preview.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_zsl_preview_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_primax_zsl_video_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov4688_zsl_preview_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov4688_zsl_video_ad5823.so
rm -rf output/vendor/lib/libchromatix_ov5670_a3_default_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_a3_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_a3_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5670_a3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5670_a3_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5670_common.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5670_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_a3_default_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_a3_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_a3_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_a3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_a3_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_common.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_postproc.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_f5670bq_zsl_video.so
rm -rf output/vendor/lib/libchromatix_ov5670_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5670_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5670_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5670_postproc.so
rm -rf output/vendor/lib/libchromatix_ov5670_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5670_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5670_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov5670_zsl_video.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_a3_default_preview.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_a3_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_a3_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_a3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_a3_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_common.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_postproc.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_preview.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov5675_primax_zsl_video.so
rm -rf output/vendor/lib/libchromatix_ov5695_a3_default_preview.so
rm -rf output/vendor/lib/libchromatix_ov5695_a3_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5695_a3_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5695_a3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5695_a3_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5695_common.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5695_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov5695_default_video.so
rm -rf output/vendor/lib/libchromatix_ov5695_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov5695_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov5695_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov5695_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov5695_postproc.so
rm -rf output/vendor/lib/libchromatix_ov5695_preview.so
rm -rf output/vendor/lib/libchromatix_ov5695_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov5695_video_full.so
rm -rf output/vendor/lib/libchromatix_ov5695_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov5695_zsl_video.so
rm -rf output/vendor/lib/libchromatix_ov8858_a3_default_preview.so
rm -rf output/vendor/lib/libchromatix_ov8858_a3_default_video.so
rm -rf output/vendor/lib/libchromatix_ov8858_a3_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov8858_a3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov8858_a3_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov8858_common.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov8858_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov8858_default_video.so
rm -rf output/vendor/lib/libchromatix_ov8858_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov8858_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov8858_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov8858_postproc.so
rm -rf output/vendor/lib/libchromatix_ov8858_preview.so
rm -rf output/vendor/lib/libchromatix_ov8858_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov8858_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov8858_zsl_video.so
rm -rf output/vendor/lib/libchromatix_ov8865_common.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_ds_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_us_chromatix.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_video_full.so
rm -rf output/vendor/lib/libchromatix_ov8865_cpp_video.so
rm -rf output/vendor/lib/libchromatix_ov8865_default_preview_dw9714.so
rm -rf output/vendor/lib/libchromatix_ov8865_default_video_dw9714.so
rm -rf output/vendor/lib/libchromatix_ov8865_default_video.so
rm -rf output/vendor/lib/libchromatix_ov8865_hfr_120_dw9714.so
rm -rf output/vendor/lib/libchromatix_ov8865_hfr_120.so
rm -rf output/vendor/lib/libchromatix_ov8865_hfr_60_dw9714.so
rm -rf output/vendor/lib/libchromatix_ov8865_hfr_60.so
rm -rf output/vendor/lib/libchromatix_ov8865_hfr_90_dw9714.so
rm -rf output/vendor/lib/libchromatix_ov8865_hfr_90.so
rm -rf output/vendor/lib/libchromatix_ov8865_postproc.so
rm -rf output/vendor/lib/libchromatix_ov8865_preview.so
rm -rf output/vendor/lib/libchromatix_ov8865_snapshot.so
rm -rf output/vendor/lib/libchromatix_ov8865_video_full.so
rm -rf output/vendor/lib/libchromatix_ov8865_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_ov8865_zsl_video.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_1080p_preview.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_1080p_video.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_4k_preview.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_4k_video.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_common.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_default_preview.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_preview.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_video_4k.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_video.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_s5k2m8_liteon_zsl_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_common.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_default_preview_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_default_video_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_common.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_default_preview_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_default_video_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_hfr_120_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_hfr_60_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_hfr_90_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_zsl_preview_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_f3l8yam_zsl_video_dw9763.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_hfr_120_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_hfr_60_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_hfr_90_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_common.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_default_preview_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_default_video_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_hfr_120_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_hfr_60_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_hfr_90_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_zsl_preview_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_mono_zsl_video_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_zsl_preview_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3l8_zsl_video_ak7345.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_common_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_common.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_hfr_120_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_hfr_60_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_hfr_90_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_liveshot_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_preview_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_snapshot_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_video_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_default_preview_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_default_preview_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_default_video_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_default_video_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_default_video_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_120_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_120_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_120_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_60_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_60_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_60_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_90_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_90_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_90_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_postproc_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_preview_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_snapshot_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_zsl_preview_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_zsl_preview_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_zsl_video_dw9761b_bear.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xm_zsl_video_dw9761b.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_1080p_preview_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_1080p_video_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_4k_preview_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_4k_video_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_common.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_video_4k.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_default_preview_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_default_video_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_hfr_120_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_hfr_60_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_hfr_90_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_video_4k.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_zsl_preview_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3m2xx_zsl_video_ad5816g.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_common.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_default_preview_dw9800.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_default_video_dw9800.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_hfr_120_dw9800.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_hfr_60_dw9800.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_hfr_90_dw9800.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_common.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_default_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_hfr_120_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_hfr_120.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_hfr_60.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_hfr_90.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_qtech_zsl_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_common.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_cpp_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_default_preview_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_default_video_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_default_video.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_fullsize_preview_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_fullsize_video_3a.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_postproc.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_preview.so
rm -rf output/vendor/lib/libchromatix_s5k3p3sm_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_snapshot.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_zsl_preview_dw9800.so
rm -rf output/vendor/lib/libchromatix_s5k3p3_zsl_video_dw9800.so
rm -rf output/vendor/lib/libmmcamera2_memleak.so
rm -rf output/vendor/lib/libmmcamera_atmel_at24c32e_eeprom.so
rm -rf output/vendor/lib/libmmcamera_dw9761b_2d_eeprom.so
rm -rf output/vendor/lib/libmmcamera_faceproc2.so
rm -rf output/vendor/lib/libmmcamera_imx258_gt24c32_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx258_mono_gt24c32_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx258_mono_ofilm.so
rm -rf output/vendor/lib/libmmcamera_imx258_mono.so
rm -rf output/vendor/lib/libmmcamera_imx258_ofilm.so
rm -rf output/vendor/lib/libmmcamera_imx268_primax_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx268.so
rm -rf output/vendor/lib/libmmcamera_imx268_sunny_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx268_sunny.so
rm -rf output/vendor/lib/libmmcamera_imx298_liteon.so
rm -rf output/vendor/lib/libmmcamera_imx298_semco.so
rm -rf output/vendor/lib/libmmcamera_imx318_primax_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx318_primax.so
rm -rf output/vendor/lib/libmmcamera_imx318_semco_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx318_semco.so
rm -rf output/vendor/lib/libmmcamera_imx318.so
rm -rf output/vendor/lib/libmmcamera_imx362.so
rm -rf output/vendor/lib/libmmcamera_imx378_liteon.so
rm -rf output/vendor/lib/libmmcamera_imx378_semco.so
rm -rf output/vendor/lib/libmmcamera_imx378.so
rm -rf output/vendor/lib/libmmcamera_le2464c_eeprom.so
rm -rf output/vendor/lib/libmmcamera_onsemi_cat24c16_a4_eeprom.so
rm -rf output/vendor/lib/libmmcamera_onsemi_cat24c32_imx362_eeprom.so
rm -rf output/vendor/lib/libmmcamera_ov16880_ofilm_eeprom.so
rm -rf output/vendor/lib/libmmcamera_ov16880.so
rm -rf output/vendor/lib/libmmcamera_ov2680.so
rm -rf output/vendor/lib/libmmcamera_ov4688_a7.so
rm -rf output/vendor/lib/libmmcamera_ov4688_b7_eeprom.so
rm -rf output/vendor/lib/libmmcamera_ov4688_b7.so
rm -rf output/vendor/lib/libmmcamera_ov4688_primax_a7.so
rm -rf output/vendor/lib/libmmcamera_ov4688_primax_b7.so
rm -rf output/vendor/lib/libmmcamera_ov4688_primax.so
rm -rf output/vendor/lib/libmmcamera_ov5675_primax.so
rm -rf output/vendor/lib/libmmcamera_ov5695.so
rm -rf output/vendor/lib/libmmcamera_qtech_f3l8yam_eeprom.so
rm -rf output/vendor/lib/libmmcamera_qtech_f5670bq_eeprom.so
rm -rf output/vendor/lib/libmmcamera_rohm_brcg064gwz_3_eeprom.so
rm -rf output/vendor/lib/libmmcamera_s5k2m8_liteon.so
rm -rf output/vendor/lib/libmmcamera_s5k3p3_qtech_eeprom.so
rm -rf output/vendor/lib/libmmcamera_s5k3p3_qtech.so
rm -rf output/vendor/lib/libmmcamera_s5k3p3sm.so
rm -rf output/vendor/lib/libmmcamera_s5k3p3.so
rm -rf output/vendor/lib/libmmcamera_sony_imx378_eeprom.so
rm -rf output/vendor/lib/libmmcamera_sunny_a16s05e_eeprom.so
rm -rf output/vendor/lib/libmmcamera_truly_cma481_eeprom.so
rm -rf output/vendor/lib/libchromatix_imx230_zsl_preview_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx230_zsl_video_lc898212xd.so
rm -rf output/vendor/lib/libchromatix_imx298_4K_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_4K_video.so
rm -rf output/vendor/lib/libchromatix_imx298_common.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_cpp_video.so
rm -rf output/vendor/lib/libchromatix_imx298_default_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_default_video.so
rm -rf output/vendor/lib/libchromatix_imx298_hdr_snapshot_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_hdr_video_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_hfr_120.so
rm -rf output/vendor/lib/libchromatix_imx298_hfr_60_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_hfr_60.so
rm -rf output/vendor/lib/libchromatix_imx298_hfr_90_3a.so
rm -rf output/vendor/lib/libchromatix_imx298_hfr_90.so
rm -rf output/vendor/lib/libchromatix_imx298_liveshot.so
rm -rf output/vendor/lib/libchromatix_imx298_postproc.so
rm -rf output/vendor/lib/libchromatix_imx298_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_snapshot_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_snapshot.so
rm -rf output/vendor/lib/libchromatix_imx298_video_hdr.so
rm -rf output/vendor/lib/libchromatix_imx298_video.so
rm -rf output/vendor/lib/libchromatix_imx298_zsl_preview.so
rm -rf output/vendor/lib/libchromatix_imx298_zsl_video.so
rm -rf output/vendor/lib/libmmcamera_imx214.so
rm -rf output/vendor/lib/libmmcamera_imx230.so
rm -rf output/vendor/lib/libmmcamera_imx258_gt24c16_eeprom.so
rm -rf output/vendor/lib/libmmcamera_imx258.so
rm -rf output/vendor/lib/libmmcamera_ov13850_q13v06k.so
rm -rf output/vendor/lib/libmmcamera_ov13850.so
rm -rf output/vendor/lib/libmmcamera_ov2281.so
rm -rf output/vendor/lib/libmmcamera_ov2685_scv3b4035.so
rm -rf output/vendor/lib/libmmcamera_ov2685.so
rm -rf output/vendor/lib/libmmcamera_ov4688_eeprom.so
rm -rf output/vendor/lib/libmmcamera_ov4688.so
rm -rf output/vendor/lib/libmmcamera_ov5645.so
rm -rf output/vendor/lib/libmmcamera_ov5670.so
rm -rf output/vendor/lib/libmmcamera_ov8858.so
rm -rf output/vendor/lib/libmmcamera_ov8865.so
rm -rf output/vendor/lib/libmmcamera_s5k3l8_mono.so
rm -rf output/vendor/lib/libmmcamera_s5k3m2xm.so
rm -rf output/vendor/lib/libmmcamera_s5k3m2xx.so
rm -rf output/vendor/lib/libmmcamera_sonyimx135_eeprom.so
rm -rf output/vendor/lib/libmmcamera_sony_imx214_eeprom.so
rm -rf output/vendor/lib/libmmcamera_sony_imx298_eeprom.so

cp -rf ../tools/nx531j/system/* output/

# java -jar baksmali.jar x -d arm64 oat/arm64/services.odex -o services

sed -i -e "s/ro\.build\.flavor=.*/ro\.build\.flavor=nx531j-userdebug/g" output/build.prop
sed -i -e "s/ro\.build\.product=.*/ro\.build\.product=NX531J/g" output/build.prop
sed -i -e "s/ro\.product\.device=.*/ro\.product\.device=NX531J/g" output/build.prop
sed -i -e "s/ro\.product\.model=.*/ro\.product\.model=NX531J/g" output/build.prop
sed -i -e "s/ro\.product\.name=.*/ro\.product\.name=NX531J/g" output/build.prop
sed -i -e "s/ro\.product\.brand=.*/ro\.product\.brand=Nubia/g" output/build.prop

sed -i -e "s/#ro.bluetooth.wipower=false/ro.bluetooth.wipower=false/g" output/build.prop
sed -i -e "s/#ro.bluetooth.emb_wp_mode=false/ro.bluetooth.emb_wp_mode=false/g" output/build.prop
sed -i -e "s/ril.subscription.types=RUIM/ril.subscription.types=NV,RUIM/g" output/build.prop

sed -i '/qcom.hw.aac.encoder=false/d' output/build.prop
sed -i '/ro.qc.sdk.audio.ssr=false/d' output/build.prop
sed -i '/ro.qc.sdk.audio.fluencetype=fluence/d' output/build.prop
sed -i '/persist.audio.fluence.voicecall=true/d' output/build.prop
sed -i '/persist.audio.fluence.voicerec=false/d' output/build.prop
sed -i '/persist.audio.fluence.speaker=true/d' output/build.prop
sed -i '/tunnel.audio.encode=false/d' output/build.prop
sed -i '/audio.offload.buffer.size.kb=32/d' output/build.prop
sed -i '/audio.offload.video=true/d' output/build.prop
sed -i '/audio.offload.pcm.16bit.enable=true/d' output/build.prop
sed -i '/audio.offload.pcm.24bit.enable=true/d' output/build.prop
sed -i '/audio.offload.track.enable=false/d' output/build.prop
sed -i '/audio.deep_buffer.media=true/d' output/build.prop
sed -i '/use.voice.path.for.pcm.voip=true/d' output/build.prop
sed -i '/audio.offload.multiaac.enable=true/d' output/build.prop
sed -i '/audio.offload.gapless.enabled=true/d' output/build.prop
sed -i '/audio.offload.min.duration.secs=15/d' output/build.prop
sed -i '/audio.safx.pbe.enabled=true/d' output/build.prop
sed -i '/audio.parser.ip.buffer.size=0/d' output/build.prop
sed -i '/audio.dolby.ds2.enabled=false/d' output/build.prop
sed -i '/audio.dolby.ds2.hardbypass=false/d' output/build.prop
sed -i '/audio.offload.multiple.enabled=true/d' output/build.prop
sed -i '/persist.sys.button_jack_profile=volume/d' output/build.prop
sed -i '/persist.sys.button_jack_switch=0/d' output/build.prop
sed -i '/audio.offload.passthrough=false/d' output/build.prop
sed -i '/persist.ts.postmakeup=false/d' output/build.prop
sed -i '/persist.ts.rtmakeup=false/d' output/build.prop

cat ../tools/build.prop.part >> output/build.prop

echo "Start Modify APPS  ..."
cd app

cp -rf ../../tools/apktool* $PWD
cp -rf ../../tools/git.apply $PWD
cp -rf ../../tools/rmline.sh $PWD

cp -rf ../output/framework/services.jar services.jar
./apktool d services.jar &> /dev/null

if [ $Type != "Global" ];then
	./git.apply  ../../tools/patches/system_assest.patch
fi

./apktool b services.jar.out &> /dev/null
mv services.jar.out/dist/services.jar ../output/framework/
rm -rf ../output/framework/oat/arm64/services.odex

cp -rf ../output/framework/framework.jar framework.jar
./apktool d framework.jar &> /dev/null

cp -rf ../../tools/nx531j/modify_apps/framework/smali/android/hardware/fingerprint/* framework.jar.out/smali/android/hardware/fingerprint
cp -rf ../../tools/nx531j/modify_apps/framework/smali_classes2/org/ifaa framework.jar.out/smali_classes2/org/

./apktool b framework.jar.out &> /dev/null
mv framework.jar.out/dist/framework.jar ../output/framework/
rm -rf ../output/framework/oat/arm64/framework.odex

mkdir -p framework-res_tmp
mv ../output/framework/framework-res.apk framework-res.apk
./apktool d framework-res.apk &> /dev/null
$XMLMERGYTOOL ../../tools/nx531j/modify_apps/framework-res/res/values framework-res/res/values
./apktool b framework-res &> /dev/null
mv framework-res.apk framework-res_tmp/framework-res.zip
cd framework-res_tmp
unzip framework-res.zip &> /dev/null
cp -rf ../framework-res/build/apk/resources.arsc resources.arsc
zip -q -r "../../output/framework/framework-res.apk" 'assets' 'resources.arsc' 'res' 'AndroidManifest.xml' &> /dev/null
cd ..

cd ..
rm -rf app

echo "Build system.img ..."
#./../tools/sefcontext/sefcontext -o file_contexts ../stockrom/file_contexts.bin
#./../tools/make_ext4fs -T 0 -S file_contexts -l $FSTABLE -a system system_new.img output/ &> /dev/null

echo "Build target_files.zip && OTA ..."
cp -rf output/data-app/* ../final/data/app/

cp -rf ../tools/OTA .
cp -rf ../tools/nx531j/boot.img OTA/tools/target_files_template/BOOTABLE_IMAGES/boot.img
cp -rf output/* OTA/tools/target_files_template/SYSTEM/
rm -rf OTA/tools/target_files_template/SYSTEM/xbin/su
cd OTA/tools/target_files_template
zip -q -r "../../../../target/$DEVICE-$Type-target_files.zip" *
cd ../../../..
rm -rf OTA

echo "Final Step ..."

cd $PORTS_ROOT
cp -rf tools/META-INF final/META-INF
cp -rf workspace/output/* final/system/
#cp -rf workspace/system_new.img final/system.img
cp -rf tools/firmware-update final/
#cp -rf tools/root final/
cp -rf tools/nx531j/boot.img final/boot.img
./tools/boot_signer/boot_signer /boot tools/nx531j/boot.img tools/boot_signer/security/verity.pk8 tools/boot_signer/security/verity.x509.pem final/boot.img

if [ -d tools/third-app ];then
	echo "Add Third App ..."
	cp -rf tools/third-app/* final/system/priv-app/
fi

cd final
zip -q -r "../miui-$DEVICE-$Type-7.0.zip" 'boot.img' 'META-INF' 'system' 'firmware-update' 'data' 'RADIO'
cd ..

sudo umount $PORTS_ROOT/workspace/output
rm -rf workspace final/*

if [ -f /tmp/cosfs/target/$DEVICE-$Type-target_files.zip ]; then
    cd tools/OTA
    . build/envsetup.sh
    ./tools/releasetools/ota_from_target_files -k build/security/testkey -i /tmp/cosfs/target/$DEVICE-$Type-target_files.zip ../../target/$DEVICE-$Type-target_files.zip ../../OTA-$DEVICE-$Type.zip
		cd $PORTS_ROOT
fi

if [ -f OTA-$DEVICE-$Type.zip ]; then
    echo "OTA is support!"
else
	  touch OTA-$DEVICE-$Type.zip
fi
mv target/$DEVICE-$Type-target_files.zip /tmp/cosfs/miui_target/$DEVICE-$Type-target_files.zip
