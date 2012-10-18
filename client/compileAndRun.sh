#!/bin/zsh

dmd main.d initSetup.d install/mainInstaller.d install/buildHowTo.d upload/mainUpload.d remove/remove.d install/commonBuildTools.d install/packageStripper.d update/updater.d author/author.d -O -release -ofarpak
cp arpak /usr/local/bin/
