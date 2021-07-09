
#!/bin/sh

echo "Starting post-install" > /var/mobile/Media/blackb0x.log

#vers = $(sw_vers | grep ProductVersion | sed -e "s/^ProductVersion: //")
#echo "sysversion: $vers" >> /var/mobile/Media/blackb0x.log

#exit 1

#Update firmware info for Cydia
/bin/sh /usr/libexec/cydia/firmware.sh

#Update apt
echo "Updating apt" >> /var/mobile/Media/blackb0x.log
apt-get update || echo "Update failed" >> /var/mobile/Media/blackb0x.log 
#&& exit 1


#Stashing
if [ ! -d /var/stash ]; then

	if /bin/uname -m | grep "AppleTV2" ; then

		#Patch out sandbox profile from AppleTV binary
		echo "Patching AppleTV entitlements" >> /var/mobile/Media/blackb0x.log
		#----Extract entitlements
		ldid -e /Applications/AppleTV.app/AppleTV > /var/tmp/Entitlements.xml
		#----Remove "seatbelt-profiles" key
		sed '/seatbelt-profiles/{N;N;N;d;}' /var/tmp/Entitlements.xml > /var/tmp/Patched-Entitlements.xml
		#----Inject entitlements
		ldid -S/var/tmp/Patched-Entitlements.xml /Applications/AppleTV.app/AppleTV
	fi

	echo "Stashing directories" >> /var/mobile/Media/blackb0x.log
	mkdir -p /var/stash

	mv /Applications /var/stash/
	mv /usr/include /var/stash/
	#mv /usr/lib/pam /var/stash/
	#mv /usr/libexec /var/stash/
	mv /usr/share /var/stash/

	ln -s /var/stash/Applications /Applications
	ln -s /var/stash/include /usr/include
	#ln -s /var/stash/pam /usr/lib/pam
	#ln -s /var/stash/libexec /usr/libexec
	ln -s /var/stash/share /usr/share

fi


#Debs fixed by JoshTV
echo "Installing debs" >> /var/mobile/Media/blackb0x.log
mv /ldid_1-1.2.1_iphoneos-arm.deb /private/var/cache/apt/archives/ldid_1-1.2.1_iphoneos-arm.deb
mv /rtadvd_307.0.1-2_iphoneos-arm-fixed.deb /private/var/cache/apt/archives/rtadvd_307.0.1-2_iphoneos-arm-fixed.deb
mv /sqlite3-dylib_3.5.9-1_iphoneos-arm-fixed.deb /private/var/cache/apt/archives/sqlite3-dylib_3.5.9-1_iphoneos-arm-fixed.deb
mv /sqlite3-lib_3.5.9-2_iphoneos-arm-fixed.deb /private/var/cache/apt/archives/sqlite3-lib_3.5.9-2_iphoneos-arm-fixed.deb
mv /com.saurik.patcyh_1.2.0_iphoneos-arm-fixed.deb /private/var/cache/apt/archives/com.saurik.patcyh_1.2.0_iphoneos-arm-fixed.deb
mv /uikittools_1.1.12_iphoneos-arm-fixed.deb /private/var/cache/apt/archives/uikittools_1.1.12_iphoneos-arm-fixed.deb
mv /beigelist_2.2.6-30_iphoneos-arm.deb /private/var/cache/apt/archives/beigelist_2.2.6-30_iphoneos-arm.deb
mv /com.nito.updatebegone_0.2-1_iphoneos-arm.deb /private/var/cache/apt/archives/com.nito.updatebegone_0.2-1_iphoneos-arm.deb


/usr/bin/dpkg -i /private/var/cache/apt/archives/ldid_1-1.2.1_iphoneos-arm.deb
/usr/bin/dpkg -i /private/var/cache/apt/archives/rtadvd_307.0.1-2_iphoneos-arm-fixed.deb
/usr/bin/dpkg -i /private/var/cache/apt/archives/sqlite3-dylib_3.5.9-1_iphoneos-arm-fixed.deb
/usr/bin/dpkg -i /private/var/cache/apt/archives/sqlite3-lib_3.5.9-2_iphoneos-arm-fixed.deb
/usr/bin/dpkg -i /private/var/cache/apt/archives/com.saurik.patcyh_1.2.0_iphoneos-arm-fixed.deb
/usr/bin/dpkg -i /private/var/cache/apt/archives/uikittools_1.1.12_iphoneos-arm-fixed.deb

echo "Installing substrate" >> /var/mobile/Media/blackb0x.log
apt-get install -y mobilesubstrate
#apt-get install -f -y

/usr/bin/dpkg -i /private/var/cache/apt/archives/beigelist_2.2.6-30_iphoneos-arm.deb
/usr/bin/dpkg -i /private/var/cache/apt/archives/com.nito.updatebegone_0.2-1_iphoneos-arm.deb

/usr/bin/apt-get upgrade -y || echo "Upgrade failed" >> /var/mobile/Media/blackb0x.log

echo "Adding replacement default repository" >> /var/mobile/Media/blackb0x.log

if [ -f /etc/apt/sources.list.d/awkward.list ]; then
echo "AwkwardTV detected. Replacing..." >> /var/mobile/Media/blackb0x.log
/bin/rm -rf /etc/apt/sources.list.d/awkward.list
mv /joshtv.list /etc/apt/sources.list.d/
/usr/bin/apt-key add /pubkey.key
else
echo "AwkwardTV doesn't exist. Adding replacement..." >> /var/mobile/Media/blackb0x.log
mv /joshtv.list /etc/apt/sources.list.d/
/usr/bin/apt-key add /pubkey.key
fi




#Install Apps (nitoTV, Kodi)
#nitoTV and Kodi icons 1080p (Credit: JoshTV)

if [ ! -d /Applications/AppleTV.app/Appliances/nitoTV.frappliance ]; then
	echo "Installing nitoTV" >> /var/mobile/Media/blackb0x.log
	apt-get -y install com.nito.nitoTV
	/bin/mv /nito.png /private/var/stash/Applications/AppleTV.app/com.nito.frontrow.appliance.nitoTV\@1080.png

fi

if [ ! -d /Applications/Kodi.frappliance ]; then
	echo "Installing Kodi" >> /var/mobile/Media/blackb0x.log
	apt-get -y --force-yes install org.xbmc.kodi-atv2 && 
	/bin/mv /kodi.png /private/var/stash/Applications/AppleTV.app/com.apple.frontrow.appliance.kodi\@1080.png
fi


echo "Install AFC2" >> /var/mobile/Media/blackb0x.log
apt-get -y install com.saurik.afc2d
#apt-get install us.scw.afctwoadd

# WIP - will test and finish later...
#echo "Install Python" >> /var/mobile/Media/blackb0x.log
#apt-get -y install python

#echo "Setting up PlexConnect..." >> /var/mobile/Media/blackb0x.log
#apt-get -y install net.joshtv.plexconnect 
#cd /Applications/PlexConnect/support/aTV_jailbreak/
#/bin/bash ./inst_atv3.sh


#Finish installation
echo "Finished installation" >> /var/mobile/Media/blackb0x.log
echo "" > /private/var/mobile/.blackb0x_installed



killall -9 backboardd

