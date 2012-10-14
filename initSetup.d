module initSetup;
import std.file;
import std.stream;
//import std.regex;
import fileReader;
void setupFirstTime(){
	removePrevTraces();
	setupPackageList();
	setupUSEFlags();
}

void setupUSEFlags(){
	File useFlagsFile = new File;
	useFlagsFile.create("/etc/arPac/package.use");
	useFlagsFile.writeLine("#This is where you can set USE flags");
	useFlagsFile.writeLine("#If you've ever used Gentoo, this is the same, but opposite (there isn't a make.conf file; instead, everything is per package). Everything here DISABLES flags within compiled programs.");
	useFlagsFile.close();
}
void setupPorts(){
	std.file.mkdir("~/.arPac");
	std.file.mkdir("/etc/arPac/ports");
	std.file.mkdir("~/.arPac/tmp");
}
void setupPackageList(){
	std.file.mkdir("/etc/arPac");
	File packageList = new File;
	packageList.create("/etc/arPac/sources.list");
	packageList.writeLine("#This is where you can store your mirrors you wish to hold.");
	packageList.writeLine("ftp://lasercat.anonexeter.com");
	packageList.close();
}

void removePrevTraces(){
	if (std.file.exists("/etc/arPac")){
		std.file.rmdirRecurse("/etc/arPac");
	}
}
