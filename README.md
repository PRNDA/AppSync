# AppSync for iOS 8
_Support iOS 5 through 8.1_

Copyright (c) 2014 Linus Yang

## Things you need to know first
* __AppSync__ is __NOT__ for piracy. 
* __AppSync__ is __for__ _freedom of iOS development with official SDK_.
* __Jailbreak__ is __NOT__ for  piracy. 
* __Jailbreak__ is __for__ _freedom of your iOS device_.
* __NO__ Debian package of AppSync will be provided here.

Install
------
* Add repo http://yangapp.googlecode.com/svn to Cydia, then search and install "AppSync",
* Or manually download at the [Release Tab](https://github.com/linusyang/AppSync/releases) and install by iFile or dpkg.

Introduction
------
_AppSync_ is a tool to synchronize your IPA Package freely, especially useful for iOS developers who are not enrolled in the iOS developers' program to test their apps on devices.

This AppSync implementation ultilizes the dynamic hooking function `MSHookFunction` of Cydia Substrate by @saurik to bypass the signature check, which does not modify any system files and is more generic, stable and safe.

AppSync is __NOT__ meant to support piracy. __Please do not pirate apps and support developers!__

Build
------
```Bash
git clone --recursive https://github.com/linusyang/AppSync.git
cd AppSync
make
make package # If you have dpkg-deb utilities
```

Reference
------
[com.saurik.iphone.fmil by @saurik](http://svn.saurik.com/repos/menes/trunk/tweaks/fmil/Tweak.mm)

License
------
Licensed under [GPLv3](http://www.gnu.org/copyleft/gpl.html).
