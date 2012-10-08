import std.stdio;
import std.string;
import initSetup;
import updater;
import install;

void main(string[] args){
	//If file doesn't exist, actually initiate package manager
	if (!std.file.exists("/etc/arPac")){
		initSetup.setupFirstTime();
	}
	else{
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
					break;
				case "update":
					updater.updatePorts();
					break;
				case "upgrade":
					break;
				default:
					throw new Exception("unknown option");
					break;
			}
		}
	}
}
