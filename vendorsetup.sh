#
#	This file is part of the OrangeFox Recovery Project
# 	Copyright (C) 2026 The OrangeFox Recovery Project
#
#	OrangeFox is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	OrangeFox is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
# 	This software is released under GPL version 3 or any later version.
#	See <http://www.gnu.org/licenses/>.
#
# 	Please maintain this if you use this script or any part of it
#
FDEVICE="chongqing"

fox_get_target_device() {
	if echo "$BASH_SOURCE" | grep -q "/$FDEVICE/"; then
		FOX_BUILD_DEVICE="$FDEVICE";
	elif set | grep BASH_ARGV | grep -w \"$FDEVICE\"; then
		FOX_BUILD_DEVICE="$FDEVICE";
	elif echo "${BASH_SOURCE[0]}" | grep -q "/$FDEVICE/"; then
		FOX_BUILD_DEVICE="$FDEVICE";
	elif echo "$0" | grep -q "$FDEVICE"; then
		FOX_BUILD_DEVICE="$FDEVICE";
	fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
	fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then

	# ===== Device Type =====
	# Virtual A/B device (auto-enables FOX_AB_DEVICE and FOX_VANILLA_BUILD)
	export FOX_VIRTUAL_AB_DEVICE=1
	export FOX_AB_DEVICE=1

	# vendor_boot-as-recovery (boot header v4, no dedicated recovery partition)
	export FOX_VENDOR_BOOT_RECOVERY=1

	# Non-Xiaomi device — skip MIUI-specific features
	export FOX_VANILLA_BUILD=1

	# ===== Kernel =====
	# Using prebuilt kernel — avoid "NO KERNEL CONFIG" error
	export OF_FORCE_PREBUILT_KERNEL=1

	# ===== Decryption =====
	# Keymaster 4.1 (device uses KeyMint V2 in A15 stock)
	export OF_DEFAULT_KEYMASTER_VERSION=4.1

	# ===== Display / Notch =====
	# Screen: 1080x2400 → aspect ratio 20:9 → 20×120 = 2400
	export OF_SCREEN_H=2400
	# Notch/cutout height (matches TWRP's TW_Y_OFFSET=105)
	export OF_STATUS_H=105
	# Allow hiding the notch from OrangeFox settings
	export OF_HIDE_NOTCH=1
	# Left and right clock positions only (avoid center — notch)
	export OF_CLOCK_POS=1
	# Rounded corners padding
	export OF_STATUS_INDENT_LEFT=48
	export OF_STATUS_INDENT_RIGHT=48
	# User can't hide on-screen navbar (no hardware nav buttons)
	export OF_ALLOW_DISABLE_NAVBAR=0

	# ===== Partitions / Mounting =====
	# Dynamic partitions — system and vendor are on /dev/block/mapper
	export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/mapper/system"
	export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/mapper/vendor"

	# ===== Shell & Utilities =====
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_LZ4_BINARY=1
	export FOX_USE_ZSTD_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_USE_DATE_BINARY=1
	export FOX_USE_BUSYBOX_BINARY=1
	export FOX_USE_SED_BINARY=1

	# ===== OrangeFox Features =====
	export FOX_DELETE_AROMAFM=1
	export FOX_ENABLE_APP_MANAGER=1
	export FOX_REPLACE_TOOLBOX_GETPROP=1

	# ===== Realme / OPLUS Specific =====
	# Set to 1 if you need Realme oZip decryption (also need TW_OZIP_DECRYPT_KEY)
	# export OF_SUPPORT_OZIP_DECRYPTION=1

	# ===== Timezone =====
	export OF_DEFAULT_TIMEZONE="IST-5:30"

	# ===== Maintainer =====
	export OF_MAINTAINER="Ayan"
	# Optional: Add a patch version number (eg, "1" → version becomes "R12.0_1")
	# export FOX_MAINTAINER_PATCH_VERSION="1"

	# ===== Storage Paths =====
	export FOX_SETTINGS_ROOT_DIRECTORY=/data/recovery
	export FOX_MISCELLANEOUS_ROOT_DIRECTORY=/sdcard

	# ===== Build Optimizations =====
	# Use LZMA compression if recovery image is too big
	# export OF_USE_LZMA_COMPRESSION=1

else
	if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
		echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
	fi
fi
#
