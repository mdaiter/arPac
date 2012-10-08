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
	useFlagsFile.writeLine("#If you've ever used Gentoo, this is the same (there isn't a make.conf file; instead, everything is per package).");
	useFlagsFile.close();
}
void setupPorts(){
	std.file.mkdir("~/.arPac");
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
		std.file.remove(r"/etc/arPac/sources.list");
		std.file.remove("/etc/arPac/package.use");
		std.file.rmdir("/etc/arPac");
	}
}
