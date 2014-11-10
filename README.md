# AppSync
_Support iOS 5 through 8.1_  
Copyright (c) 2014 Linus Yang

AppSync is __NOT__ meant for piracy. __Please do not use it to install pirate apps!__

Installation
------
* Add repo http://yangapp.googlecode.com/svn to Cydia, then search and install "AppSync",
* Or manually [download](http://yangapp.googlecode.com/svn/debs/com.linusyang.appsync_0.3_iphoneos-arm.deb) and install by iFile or `dpkg`.
* You can also install "App Installer" to install apps by command `appinst <ipa file>`.

Introduction
------
_AppSync_ is a development tool for eliminating the restriction of installing self-signed `.ipa` packages on iOS devices. It helps developers who haven't enrolled the iOS developers' program to test apps with Xcode.

This AppSync implementation ultilizes the dynamic hooking function `MSHookFunction` of Cydia Substrate by @saurik to bypass the signature check. It does not modify any system files, which is more generic, stable and safe.

Development
------
You can build AppSync __directly on your device__:

1. Use Cydia to add repo `http://yangapp.googlecode.com/svn`.
2. Search and install `git`, `theos` and `Erica Utilities`. (This may take a few minutes.)
3. SSH into your device (or use MobileTerminal) to run the following commands:

```Bash
# Use git to clone repo
git clone https://github.com/linusyang/AppSync.git

# Build AppSync
cd AppSync
make package

# Build App Installer
cd App
make package
```

Reference
------
[com.saurik.iphone.fmil](http://svn.saurik.com/repos/menes/trunk/tweaks/fmil/Tweak.mm) by @saurik

License
------
Licensed under [GPLv3](http://www.gnu.org/copyleft/gpl.html).
