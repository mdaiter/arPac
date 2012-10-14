module initSetup;
import std.file;
import std.stream;
//import std.regex;
import std.process;
import fileReader;
import core.thread;

//All of this stuff should be concurrent except the first part, so create three threads to make these files
void setupFirstTime(){
	Thread t = new Thread(&removePrevTraces);
	t.start();
}

void setupUSEFlags(){
	File useFlagsFile = new File;
	useFlagsFile.create("/etc/arPac/package.use");
	useFlagsFile.writeLine("#This is where you can set USE flags");
	useFlagsFile.writeLine("#If you've ever used Gentoo, this is the same, but opposite (there isn't a make.conf file; instead, everything is per package). Everything here DISABLES flags within compiled programs.");
	useFlagsFile.close();
}
void setupPorts(){
	std.file.mkdirRecurse("/etc/arPac/ports");
	std.file.mkdirRecurse(getenv("HOME")~"/.arPac/tmp");
}
void setupPackageList(){
	File packageList = new File;
	packageList.create("/etc/arPac/sources.list");
	packageList.writeLine("#This is where you can store your mirrors you wish to hold.");
	packageList.writeLine("ftp://lasercat.anonexeter.com");
	packageList.close();
}

void removePrevTraces(){
	if (std.file.exists("/etc/arPac")){
		std.file.rmdirRecurse("/etc/arPac");
		std.file.mkdir("/etc/arPac");
	}
	if (std.file.exists(getenv("HOME")~"/.arPac/")){
		std.file.rmdirRecurse(getenv("HOME")~"/.arPac/");
		std.file.mkdir(getenv("HOME")~"/.arPac/");
	}
	setupPorts();
	Thread t2 = new Thread(&setupPackageList);
        Thread t3 = new Thread(&setupUSEFlags);
        t2.start();
        t3.start();
}
