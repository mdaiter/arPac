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
	//Make sure ports exists
	if (exists("/etc/arPac/ports")){
		//Install every package in list
		for (int i = 0; i < packageList.length; i++){
			bool wasFound = false;
			/*
			Taken from rosettacode. Walks file directory.
			*/
			foreach(string d; dirEntries("/etc/arPac/ports","*.arPak", SpanMode.depth)){
				//Inform user of actions
               			writefln("Searching %s for %s", chompPrefix(d,"/etc/arPac/ports/"), packageList[i]);
				//Compare stripped (no whitespace) version of string to stripped imput
				if (strip(chompPrefix(d, "/etc/arPac/ports/")) == strip(packageList[i])){
					writeln("Found package!");
					wasFound = true;
					//Start install
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

private byte instantiateInstall(string packageName){
	buildTemplate buildFile = new buildTemplate();
	//Screen package for name + version + use flags + make direction
	foreach(line; File(packageName).byLine()){
		/*
		Couldn't get regular expressions to work, so I kind of needed to do it this way...
		*/
		if (line.length > 7 && (line[0..8] == "PKGNAME=")){
			writefln("Starting the build of %s", line[8..line.length]);
		}
		//Download source file (must be tar.gz)
		if (line.length > 6 && line[0..7] == "SOURCE="){
			writeln(line[7..line.length]~"is the dpin");
			//Download and unzip
			string dirOfUnzip = downloadAndUnzip(line[7..line.length], packageName);
			//Mkae sure you actually downloaded the file
			if (dirOfUnzip != "none"){
				//If the file is a pde (Arduino build file), then strip it of use flags
				foreach(d; dirEntries(dirOfUnzip, SpanMode.depth)){
					if (d.name()[d.name().length-4..d.name().length] == ".pde"){
						packageStripper.stripFile(buildFile,d.name());
					}
				}
			}
			else{
				writefln("Exiting now: couldn't install package %s", packageName);
				return 1;
			}
		}
		//Get use flags that are possible
		if (line.length > 3 && line[0..4] == "USE="){
			writefln("Got past first %s", line[4..line.length]);
			string tempLine = cast(string)line[4..line.length];
			generateUSE(buildFile, tempLine, packageName);
		}
		//Get build script
		if (line.length > 7 && line[0..8] == "build(){"){
			builder.buildMeta(buildFile, packageName, getBuildDir(packageName));
		}
	}
	return 0;
}

private void generateUSE(buildTemplate sampleBuildFile, string lineOfUseFlags, string pacName){
	//Set use flags
	sampleBuildFile.setUseFlags(tok(lineOfUseFlags));
	writefln("Got past second %s", sampleBuildFile.allUseFlags[0]);
	bool packageUseDefined = false;
	//We're going to be using this string anyway, might as well have it in temp memory
	string easierPacName = chompPrefix(pacName,"/etc/arPac/ports/");
	//Get file in by line
	foreach(line; File("/etc/arPac/package.use").byLine()){
		//Check if the line is for the package
		if (line.length > easierPacName.length && line[0..easierPacName.length] == easierPacName){
			sampleBuildFile.setUserWantedFlags(tok(cast(string)line[easierPacName.length+1..line.length]));
			break;
		}
	}
}
//Converts pkgName to the appropriate build directory
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
//Download and unzip file for pkgName
private string downloadAndUnzip(char[] downloadFile, string pkgName){
	string fileToCreateStr = getBuildDir(pkgName);
	//Try to curl a file; if fails, then give up
	try{
		//(Curl)
		download(downloadFile, "/tmp/packageDownloadFile.tar.gz");
		/*Directory to make +
		to remove*/
		if (exists(fileToCreateStr)){
			std.file.rmdirRecurse(fileToCreateStr);
		}
		//Make a directory for the file
		std.file.mkdirRecurse(fileToCreateStr);
		//Unzip file
		std.process.system("tar -xvf /tmp/packageDownloadFile.tar.gz -C " ~ fileToCreateStr);
		//Clean up tracks
		std.file.remove("/tmp/packageDownloadFile.tar.gz");
	}
	//Triggers if download failed
	catch(CurlException e){
		writeln("Couldn't download file from source specified...");
		return "none";
	}
	//For if it can't open a tar file in the appropriate place
	catch (std.stream.OpenException e){
		writeln("Couldn't make a tar file; are you sudo?");
		return "none";
	}
		return fileToCreateStr;

}

//Use this for splitting up stuff in string seperated by spaces into string[]
string[] tok(string a){
	a.split(" ").join("\n").splitLines.writeln();
	return(splitLines(a.split(" ").join("\n")));
}
