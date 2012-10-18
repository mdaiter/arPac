module uploader;
import std.stdio;
import std.file;
import std.string;
import std.process;
import buildTools;
//Reads in build script and executes
void uploadFiles(string[] pakName){
	//Go through every package
	for (int i = 0; i < pakName.length; i++){
		//Make sure package is actually installed
		if (exists(getenv("HOME")~"/.arPac/"~pakName[i])){
			//Abridge home + dir to pakName
			string newPakName = getenv("HOME") ~ "/.arPac/" ~ pakName[i];
			bool isAfterBrak = false;
			//Go through, find build section. If it is build section, start processing commands. Once you hit another bracket, end it.
			foreach(cmdLine; File(newPakName).byLine()){
				if (isAfterBrak == true){
					if (buildTools.containsFrontBracket(cast(char[])cmdLine)){
						writeln("Done uploading!");
						break;
					}
					else{
						//Make sure there isn't white space
						std.process.system(strip(cast(string)cmdLine));
					}
				}
				if (cmdLine.length >8  && cmdLine[0..9] == "upload(){"){
					isAfterBrak = true;
				}
			}
		}
		else{
			writefln("%s isn't installed...", getenv("HOME")~"/.arPac/"~pakName[i]~"/"~pakName[i]~".arPak");
		}
	}
}
