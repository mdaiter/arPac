import std.stdio;
import std.string;
import std.process;
import initSetup;
import updater;
import install;
import authorTool;
import uploader;
import remover;

void main(string[] args){
	//If file doesn't exist, actually initiate package manager
	if (!std.file.exists("/etc/arPac") || !std.file.exists(getenv("HOME")~"/.arPac/")){
		initSetup.setupFirstTime();
	}
	writeln("Welcome");
	if (args.length < 2){
		writeln("Nothing specified!");
	}
	else{
		switch (strip(args[1])){
			case "install":
				if (args.length > 2){
					install.installPackages(args[2..args.length]);
				}	
				else{
					//Alert user of no packages installed
					writeln("You didn't give anything to install...\n");
				}
				break;
			case "remove":
				remover.removePackages(args[2..args.length]);
				break;
			case "upload":
				uploader.uploadFiles(args[2..args.length]);
				break;
			case "author":
				authorTool.lookupAuthors(args[2..args.length]);
				break;
			case "license":
				authorTool.lookupLicense(args[2..args.length]);
				break;
			case "update":
				updater.updatePorts();
				break;
			default:
				throw new Exception("unknown option");
				break;
		}
	}
}
