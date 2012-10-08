module install;
import std.stdio;
import std.file;
import std.regex;
import std.string;
import std.process;
import std.net.curl;

struct buildTemplate{
	string[] allUseFlags;
	string[] userWantedFlags;
	string[] buildCommands;
};

//Main function for installing package.
void installPackages(string[] packageList){
	if (exists("/etc/arPac/ports")){
		for (int i = 0; i < packageList.length; i++){
			bool wasFound = false;
			/*
			Taken from rosettacode. Walks file directory.
			*/
			foreach(string d; dirEntries("/etc/arPac/ports","*.arPak", SpanMode.depth)){
               			writefln("Searching %s for %s", chompPrefix(d,"/etc/arPac/ports/"), packageList[i]);
				//auto ctr = regex("/*/");
				if (strip(chompPrefix(d, "/etc/arPac/ports/")) == strip(packageList[i])){
					writeln("Found package!");
					wasFound = true;
					instantiateInstall(d);
					break;
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

private void instantiateInstall(string packageName){
	buildTemplate buildFile;
	//Screen package for name + version + use flags + make direction
	foreach(line; File(packageName).byLine()){
		/*
		Couldn't get regular expressions to work, so I kind of needed to do it this way...
		*/
		if (line.length > 7 && (line[0..8] == "PKGNAME=")){
			writefln("Starting the build of %s", line[8..line.length]);
		}
		if (line.length > 6 && line[0..7] == "SOURCE="){
			downloadAndUnzip(line[8..line.length]);
		}
		if (line.length > 3 && line[0..4] == "USE="){
			writefln("Got past first %s", line[4..line.length]);
			generateUSE(buildFile, line[4..line.length], packageName);
		}
		if (line.length > 7 && line[0..8] == "build(){"){
			writeln("Hit build()!");
		}
	}
}

private void generateUSE(buildTemplate sampleBuildFile, char[] lineOfUseFlags, string pacName){
	char[] space;
	space[0] = ' ';
	try{
		sampleBuildFile.allUseFlags =  tok(lineOfUseFlags, ' ');
	}
	catch (RangeError e){
		writeln("Couldn't do it...");
	}
	writeln("Got past second");
	bool packageUseDefined = false;
	string easierPacName = chompPrefix(pacName,"/etc/arPac/ports/");
	foreach(line; File("/etc/arPac/package.use").byLine()){
		//Check if the line is for the package
		if (line.length > easierPacName.length && line[0..easierPacName.length] == easierPacName){
			sampleBuildFile.userWantedFlags = tok(line[easierPacName.length..line.length], space[0]);
			break;
		}
	}
	if (packageUseDefined == false){
		sampleBuildFile.userWantedFlags = sampleBuildFile.allUseFlags;
	}
}

private void downloadAndUnzip(char[] downloadFile){
	try{
		download(downloadFile, "/tmp/tmpDownloadFile.tar.gz");
		std.process.system("tar -xvf /tmp/packageDownloadFile.tar.gz -C ~/.arPac/tmp/");
		std.file.remove("/tmp/packageDownloadFile.tar.gz");
	}
	catch(CurlException e){
		writeln("Couldn't download file from source specified...");
	}

}

string[] tok(char[] input, char tokens){
	writeln("Started tok");
	string[] output;
	int newEnd = 0;
	for(int i = 0; i < input.length; i++){
		writeln("Got in the for loop");
		if (input[i] == tokens){
			output[output.length] = cast(string)input[newEnd..i];
			writeln("%s", output[output.length - 1]);
			newEnd = i + 1;
		}
	}
	return output;
}
