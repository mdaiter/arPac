#!/bin/zsh

dmd main.d initSetup.d fileReader.d install/mainInstaller.d install/buildHowTo.d upload/mainUpload.d install/commonBuildTools.d install/packageStripper.d update/updater.d author/author.d -O -release -ofarpak
