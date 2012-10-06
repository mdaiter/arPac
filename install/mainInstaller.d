module install;
import std.stdio;
import std.file;
import std.regex;
import std.string;

//Main function for installing package.
void installPackage(string[] packageList){
	if (exists("/etc/arPac/ports")){
		for (int i = 1; i < packageList.length; i++){
			bool wasFound = false;
			/*
			Taken from rosettacode. Walks file directory.
			*/
			foreach(string d; dirEntries("/etc/arPac/ports","*.arPak", SpanMode.depth)){
               			writefln("Searching %s for %s", d, packageList[i]);
				if (chomp(packageList[i], "/etc/arPac/ports") == packageList[i]){
					writeln("Found package!");
				}
			}
			if (wasFound == false){
				writeln("Couldn't find the package :-(");
			}
		}
	}
	else{
		writeln("etc/arPac/ports doesn't exist...did you delete it?");
	}
}
void main(string[] args){
	installPackage(args);
}
