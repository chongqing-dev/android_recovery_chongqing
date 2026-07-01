# OrangeFox Recovery Project - Realme 11 (chongqing) - Android 15

```
      ▒█████   ██▀███   ▄▄▄       ███▄    █   ▄████ ▓█████   █████▒▒█████  ▒██   ██▒
     ▒██▒  ██▒▓██ ▒ ██▒▒████▄     ██ ▀█   █  ██▒ ▀█▒▓█   ▀ ▓██   ▒▒██▒  ██▒▒▒ █ █ ▒░
     ▒██░  ██▒▓██ ░▄█ ▒▒██  ▀█▄  ▓██  ▀█ ██▒▒██░▄▄▄░▒███   ▒████ ░▒██░  ██▒░░  █   ░
     ▒██   ██░▒██▀▀█▄  ░██▄▄▄▄██ ▓██▒  ▐▌██▒░▓█  ██▓▒▓█  ▄ ░▓█▒  ░▒██   ██░ ░ █ █ ▒
     ░ ████▓▒░░██▓ ▒██▒ ▓█   ▓██▒▒██░   ▓██░░▒▓███▀▒░▒████▒░▒█░   ░ ████▓▒░▒██▒ ▒██▒
```

This repository contains the OrangeFox Recovery Project device tree for the **Realme 11 (RMX3780)**.

---

## Device Information
- **Device**: Realme 11 5G
- **Tested Version**: RMX378X_15.0.0.1800(EX01)
- **Codename**: chongqing (formerly RE5C6CL1)
- **Model**: RMX3780 / RMX3781 / RMX3782 / RMX3783 / RMX3785
- **SoC**: MediaTek Dimensity 6100+ (MT6835)
- **Android**: 15 (SDK 35)
- **Kernel**: 5.15.180-android13-8
- **Build Date**: June 2026

---

## Key Features & Fixes in this Device Tree

### 1. Security HAL & Decryption
* Packs **`android.hardware.security.keymint@2.0`** and the necessary Trustonic/Mobicore binaries under `/odm/vendor/app/mcRegistry` to support FBE v2 decryption on Android 15 ROMs. Redundant duplicate firmware directories (like `/odm/firmware`) were removed to avoid AOSP symlink collisions.

### 2. Display Performance & Hardware Limitations
* Relies on the default `fbdev` software rasterizer for OrangeFox UI rendering. (Hardware OpenGL acceleration via `BOARD_USES_MINUI_GL` is deliberately disabled as the Mali GPU driver is not loaded in recovery, which would otherwise trigger an extremely slow `llvmpipe` software fallback and break the Fastbootd menu).
* The stock Realme recovery kernel omits the `cpufreq` driver, locking the CPU to a low bootloader frequency (~800MHz). UI animations may drop frames (feel like 30Hz), but flashing and decryption speed are unaffected.

### 3. Touchscreen Refresh & Touch Lag Fix
* Configured the Oplus touchpanel report rate switch `/proc/touchpanel/game_switch_enable` to `1` on boot to enable high touch panel reporting rate (120Hz/240Hz).
* The stock vibrator AIDL HAL service (`vendor.oplus.vibrator-default`) fails on recovery kernels, causing touchscreen lag. This tree overrides it to a dummy instant-exit service mapping to `/system/bin/toybox` to force recovery to use standard sysfs vibration pathways, resolving touch lag.

### 4. Timezone Sync
* Default timezone offset is configured to `GMT0` (with property `GMT` in `system.prop`). This reads the hardware clock directly without double-shifting the time after decryption, keeping both recovery and Android clocks perfectly synced.

### 5. CPU Temperature Scaling
* Solves the power-down temp scaling issue by running a background loop script `/system/bin/cpu_temp.sh`. It reads the battery PMIC temperature and scales it to `/tmp/cpu_temp` where it displays correctly on the recovery interface.

---

## Directory Structure
```
device/realme/chongqing/
├── Android.mk                
├── AndroidProducts.mk        
├── BoardConfig.mk            ← Configured for OrangeFox aspect ratio, notch offset, and keymaster fallback
├── device.mk                 
├── system.prop               
├── twrp_chongqing.mk         
├── recovery.fstab            
├── prebuilt/
│   └── dtb.img               ← A15 stock prebuilt DTB
├── bootctrl/                 
├── mtk_plpath_utils/         
└── recovery/
    └── root/
        ├── init.recovery.mt6835.rc   
        ├── tee.rc                     
        ├── trustonic.rc               
        ├── ueventd.mt6835.rc
        ├── init.recovery.usb.rc
        ├── first_stage_ramdisk/
        │   ├── fstab.mt6835           
        │   └── fstab.emmc             
        ├── system/
        │   └── bin/
        │       └── cpu_temp.sh        
        │   └── etc/
        │       └── twrp.flags         
        ├── lib/modules/               
        └── vendor/
            ├── bin/
            │   ├── mcDriverDaemon     
            │   └── hw/
            │       ├── android.hardware.security.keymint@2.0-service.trustonic
            │       └── android.hardware.gatekeeper@1.0-service
            ├── etc/
            │   ├── oplus_avb.pubkey   
            │   ├── ueventd.rc
            │   └── vintf/
            └── app/mcRegistry/        
```

---

## Syncing OrangeFox over a TWRP Source Tree

If you already have a working TWRP 12.1 AOSP minimal manifest synced on your build environment, you can quickly convert it to build OrangeFox without re-downloading the entire 45GB manifest:

```bash
# 1. Clone the OrangeFox sync repo (used for build patches)
git clone https://gitlab.com/OrangeFox/sync.git ~/OrangeFox_sync

# 2. Go to your TWRP directory
cd ~/android

# 3. Replace TWRP recovery sources with OrangeFox recovery sources
mv ~/android/bootable/recovery /tmp/twrp_recovery_backup
git clone https://gitlab.com/OrangeFox/bootable/Recovery.git -b fox_12.1 ~/android/bootable/recovery

# 4. Add the OrangeFox vendor tree
git clone https://gitlab.com/OrangeFox/vendor/recovery.git -b fox_12.1 ~/android/vendor/recovery

# 5. Apply manifest patches
cd ~/android/build && patch -p1 < ~/OrangeFox_sync/patches/patch-manifest-fox_12.1.diff
cd ~/android/system/update_engine && patch -p1 < ~/OrangeFox_sync/patches/patch-update-engine-fox_12.1.diff

# 6. Patch TWRP Soong vars for OrangeFox integration
cd ~/android
sed -i "/SOONG_CONFIG_NAMESPACES += twrpVarsPlugin/i include bootable/recovery/orangefox_soong.mk" vendor/twrp/config/BoardConfigSoong.mk
```

---

## Building

1. Place this device tree folder in `device/realme/chongqing`.
2. Clear the old output directories to prevent symlink conflicts, and compile:

```bash
# 1. Staging files
rm -rf ~/android/device/realme/chongqing/*
cp -r /mnt/d/recoveries\ dt/orangefox-dt-working/* ~/android/device/realme/chongqing/

# 2. Clear old output directory conflicts
rm -rf ~/android/out/target/product/chongqing/recovery
rm -rf ~/android/out/target/product/chongqing/root

# 3. Compile
cd ~/android
make installclean
source build/envsetup.sh
export FOX_BUILD_DEVICE=chongqing ALLOW_MISSING_DEPENDENCIES=true LC_ALL="C"
lunch twrp_chongqing-eng && mka adbd vendorbootimage 2>&1 | tee build.log
```

---

## Flashing

### Flash the Image via Fastboot
Reboot your phone to bootloader and flash the output image directly to `vendor_boot`:
```bash
fastboot flash vendor_boot out/target/product/chongqing/OrangeFox-R12.0-Unofficial-chongqing.img
fastboot reboot recovery
```

### Flash the ZIP installer via Recovery
Alternatively, push the generated ZIP installer directly to your device and flash it inside custom recovery:
```bash
adb push out/target/product/chongqing/OrangeFox-R12.0-Unofficial-chongqing.zip /sdcard/
```
*(This installer will automatically replace the stock recovery ramdisk on both slots and set up the settings framework under `/sdcard/Fox`)*

---

## Credits
* **The OrangeFox Team** — for the recovery source code
* **The TeamWin (TWRP) Team** — for the base recovery framework
* **Ayan** — Device Tree Maintainer
