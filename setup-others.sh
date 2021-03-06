#!/bin/bash
df -k .
BASEDIR="$PWD" #store our git dir to use our resources later.

wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip -qq platform-tools-latest-linux.zip -d ~
PATH="$(pwd)/platform-tools:$PATH"
mkdir -p ~/bin
mkdir -p ~/android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
PATH="$(pwd)/bin:$PATH"
source ~/.profile
cd ~/android/lineage
repo init --depth=1 -u git://github.com/LineageOS/android.git --quiet -b cm-12.1  <<!
y
y
!

#---Device specific repos---
mkdir -p ~/android/lineage/.repo/local_manifests
cp $BASEDIR/ancora.xml ~/android/lineage/.repo/local_manifests/ancora.xml
#---

repo sync --quiet 

#Patches for ancora
git config --global user.email "you@example.com"
git config --global user.name "mt"
cd ~/android/lineage/bionic
git remote add ancora-bionic git://github.com/RR-msm7x30/android_bionic
git fetch ancora-bionic
git cherry-pick e480e8e 417890d 
cd ~/android/lineage/frameworks/native
git remote add ancora-fwnative git://github.com/sirmordred/android_frameworks_native
git fetch ancora-fwnative
git cherry-pick 10c3798 c3cda27 fd31f18 0c59f3f 
cd ~/android/lineage/frameworks/base
git am $BASEDIR/android_frameworks_base_simple_dialog.patch
cd ~/android/lineage/hardware/qcom/display-caf/msm7x30
git fetch --unshallow msm7x30
git revert 2bfbf21
cd ~/android/lineage/hardware/qcom/audio-caf/msm7x30
git fetch --unshallow msm7x30
git revert bc183a482dee3a54e0415fff64893da6f6bcacb7
cd ~/android/lineage/hardware/qcom/media-caf/msm7x30
git fetch --unshallow msm7x30
git revert 14c090d 
cd ~/android/lineage
sed -i 's/utf16_to_utf8(str,\slen,\s(char\*)\sdata)/utf16_to_utf8(str, len, (char*) data, len + 1)/g' hardware/qcom/media-caf/msm7x30/dashplayer/DashPlayer.cpp   
sed -i 's/#\sCamera/# Camera\'$'\nBOARD_USES_LEGACY_OVERLAY := true/g' device/samsung/ancora/BoardConfig.mk
cp -f $BASEDIR/config.xml device/samsung/ancora/overlay/frameworks/base/core/res/res/values/
#Updating libshims
#rm -R device/samsung/ancora/libshims/8
#svn export --force https://github.com/doadin/android_device_samsung_ancora_tmo/branches/cm-12.1_ion_pmem-libshim/libshims "device/samsung/ancora/libshims" 
#svn export --force https://github.com/doadin/android_device_samsung_ancora_tmo/branches/cm-12.1_ion_pmem-libshim/camera "device/samsung/ancora/camera" 

df -k .

rm -R .repo
rm -R device/generic/
df -k .
cd ~/
apt install pigz
tar cf - -I pigz ~/android | split --bytes=1GB - ~/CM12.1.tar.gz.
for i in CM12.1.tar.gz* ; do command curl --upload-file $i https://transfer.sh/$i ; done
ls -l



