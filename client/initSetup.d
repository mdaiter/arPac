module initSetup;
import std.file;
import std.stream;
//import std.regex;
import std.process;
import core.thread;

//All of this stuff should be concurrent except the first part, so create three threads to make these files
void setupFirstTime(){
	//Shouldn't have to take time out of execution to do this stuff
	Thread t = new Thread(&removePrevTraces);
	t.start();
}
//Set up use flags section (make a bunch of folders and junk)
void setupUSEFlags(){
	//Make a new file
	File useFlagsFile = new File;
	//Create package.use file and add comments.
	useFlagsFile.create("/etc/arPac/package.use");
	useFlagsFile.writeLine("#This is where you can set USE flags");
	useFlagsFile.writeLine("#If you've ever used Gentoo, this is the same, but opposite (there isn't a make.conf file; instead, everything is per package). Everything here DISABLES flags within compiled programs.");
	useFlagsFile.close();
}
//Setup ports tree
void setupPorts(){
	//Just a bunch of folders
	std.file.mkdirRecurse("/etc/arPac/ports");
	std.file.mkdirRecurse(getenv("HOME")~"/.arPac/tmp");
}
//Add a default mirror to the sources.list file
void setupPackageList(){
	File packageList = new File;
	packageList.create("/etc/arPac/sources.list");
	packageList.writeLine("#This is where you can store your mirrors you wish to hold.");
	packageList.writeLine("ftp://lasercat.anonexeter.com");
	packageList.close();
}

//Remove any previous traces of arpak on system
void removePrevTraces(){
	//Clean /etc/arpac
	if (std.file.exists("/etc/arPac")){
		std.file.rmdirRecurse("/etc/arPac");
		std.file.mkdir("/etc/arPac");
	}
	//Clean ~/.arPac
	if (std.file.exists(getenv("HOME")~"/.arPac/")){
		std.file.rmdirRecurse(getenv("HOME")~"/.arPac/");
		std.file.mkdir(getenv("HOME")~"/.arPac/");
	}
	setupPorts();
	//Create threads to make creation faster
	Thread t2 = new Thread(&setupPackageList);
        Thread t3 = new Thread(&setupUSEFlags);
        t2.start();
        t3.start();
}
