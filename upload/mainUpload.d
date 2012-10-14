module uploader;
import std.stdio;
import std.file;
import std.string;
import std.process;
import buildTools;

void uploadFiles(string[] pakName){
	for (int i = 0; i < pakName.length; i++){
		if (exists(getenv("HOME")~"/.arPac/"~pakName[i])){
			string newPakName = getenv("HOME") ~ "/.arPac/" ~ pakName[i];
			writeln(newPakName);
			bool isAfterBrak = false;
			foreach(cmdLine; File(newPakName).byLine()){
				if (isAfterBrak == true){
					if (buildTools.containsFrontBracket(cast(char[])cmdLine)){
						writeln("Done uploading!");
						break;
					}
					else{
						std.process.system(cast(string)cmdLine);
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
