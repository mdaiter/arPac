module install;
import std.stdio;
import std.file;
import std.string;
import std.process;
import std.net.curl;
import builder;
import packageStripper;
/*Because structs didn't work in passing into a function... :-(*/
class buildTemplate{
	private string[] allUseFlags;
	private string[] userWantedFlags;
	private string[] buildCommands;

	
	public void setUseFlags(string[] alluseFlags){
		allUseFlags.length = alluseFlags.length;
		allUseFlags = alluseFlags[];
	}

	public void setUserWantedFlags(string[] uWF){
		userWantedFlags.length = uWF.length;
		userWantedFlags = uWF[];
	}

	public void setBuildCommands(string[] bC){
		buildCommands.length = bC.length;
		buildCommands = bC[];
	}
	
	public string[] getAllUseFlags(){
		return allUseFlags;
	}

	public string[] getUserWantedFlags(){
		return userWantedFlags;
	}

	public string[] getBuildCommands(){
		return buildCommands;
	}
		
	~this(){
		delete allUseFlags;
		delete userWantedFlags;
		delete buildCommands;
	}
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
	buildTemplate buildFile = new buildTemplate();
	//Screen package for name + version + use flags + make direction
	foreach(line; File(packageName).byLine()){
		/*
		Couldn't get regular expressions to work, so I kind of needed to do it this way...
		*/
		if (line.length > 7 && (line[0..8] == "PKGNAME=")){
			writefln("Starting the build of %s", line[8..line.length]);
		}
		if (line.length > 6 && line[0..7] == "SOURCE="){
			writeln(line[7..line.length]~"is the dpin");
			string dirOfUnzip = downloadAndUnzip(line[7..line.length], packageName);
			foreach(d; dirEntries(dirOfUnzip, SpanMode.depth)){
				if (d.name()[d.name().length-4..d.name().length] == ".pde"){
					packageStripper.stripFile(buildFile,d.name());
				}
			}
		}
		if (line.length > 3 && line[0..4] == "USE="){
			writefln("Got past first %s", line[4..line.length]);
			string tempLine = cast(string)line[4..line.length];
			generateUSE(buildFile, tempLine, packageName);
		}
		if (line.length > 7 && line[0..8] == "build(){"){
			writeln("Hit build()!");
			builder.buildMeta(buildFile, packageName, getBuildDir(packageName));
		}
	}
}

private void generateUSE(buildTemplate sampleBuildFile, string lineOfUseFlags, string pacName){
	sampleBuildFile.setUseFlags(tok(lineOfUseFlags));
	writefln("Got past second %s", sampleBuildFile.allUseFlags[0]);
	bool packageUseDefined = false;
	string easierPacName = chompPrefix(pacName,"/etc/arPac/ports/");
	foreach(line; File("/etc/arPac/package.use").byLine()){
		//Check if the line is for the package
		if (line.length > easierPacName.length && line[0..easierPacName.length] == easierPacName){
			sampleBuildFile.setUserWantedFlags(tok(cast(string)line[easierPacName.length+1..line.length]));
			break;
		}
	}
}

public string getBuildDir(string pkgName){
	string fileToCreateStr;
	string[] fileToCreateArr = chompPrefix(pkgName, "/etc/arPac/ports/").split("/");
        string endFile = cast(string)fileToCreateArr[fileToCreateArr.length - 1];
        //Need to make the bound so that we don't get a .arPak at the end
        endFile = cast(string)endFile[0..endFile.length - 6];
        fileToCreateArr = cast(string[])fileToCreateArr[0..fileToCreateArr.length - 1];
        for (int i = 0; i < fileToCreateArr.length; i++){
                fileToCreateStr ~= fileToCreateArr[i] ~ "/";
        }
        fileToCreateStr ~= endFile;
        fileToCreateStr = getenv("HOME") ~ "/.arPac/" ~ fileToCreateStr;
	return fileToCreateStr;
}

private string downloadAndUnzip(char[] downloadFile, string pkgName){
	string fileToCreateStr = getBuildDir(pkgName);
	try{
		download(downloadFile, "/tmp/packageDownloadFile.tar.gz");
		/*Directory to make +
		to remove*/
		if (exists(fileToCreateStr)){
			std.file.rmdirRecurse(fileToCreateStr);
		}
		std.file.mkdirRecurse(fileToCreateStr);
		std.process.system("tar -xvf /tmp/packageDownloadFile.tar.gz -C " ~ fileToCreateStr);
		std.file.remove("/tmp/packageDownloadFile.tar.gz");
	}
	catch(CurlException e){
		writeln("Couldn't download file from source specified...");
	}
		return fileToCreateStr;

}

//Use this for splitting up stuff in string seperated by spaces into string[]
string[] tok(string a){
	a.split(" ").join("\n").splitLines.writeln();
	return(splitLines(a.split(" ").join("\n")));
}
