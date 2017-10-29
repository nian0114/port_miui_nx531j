#!/bin/bash
#
# Add miui smali files
#
# $1: miui dir
# $2: target dir
#

MIUI_DIR=$1
TARGET_DIR=$2
OVERLAY_DIR=$PORT_ROOT/android/overlay
OVERLAY_CLASSES=$OVERLAY_DIR/OVERLAY_CLASSES

for class in `cat $OVERLAY_CLASSES | grep -Ev "^$|^#.*$"`
do
    target_smali=$TARGET_DIR/smali/$class.smali
    target_classes=$TARGET_DIR/smali/$class*
    if [ -f "$target_smali" ];then
        rm -f $target_classes
    fi
done


for overlay_smali in `find $OVERLAY_DIR -name "*.smali" | sed 's/\$.*/.smali/' | uniq`
do
    target_smali=${overlay_smali/$OVERLAY_DIR/$TARGET_DIR}
    if [ -f "$target_smali" ];then
        cp -f ${overlay_smali/.smali/}*.smali `dirname $target_smali`
    fi
done


for file in `find $MIUI_DIR -name "*.smali"`
do
        newfile=${file/$MIUI_DIR/$TARGET_DIR}
        if [ ! -f "$newfile" ]
        then
                mkdir -p `dirname $newfile`
                echo "add smali from miui: $file"
                cp $file $newfile
        fi
done

if [ -f "customize_framework.sh" ]; then
	./customize_framework.sh $1 $2
fi
