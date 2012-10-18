module builder;
import std.stdio;
import std.file;
import std.string;
//Only needed for the build template class
import install;
import buildTools;
//Mkae it easy, only one build command
void buildMeta(buildTemplate sampleBuild, string locFileScript, string buildDirectory){
	getBuildScript(sampleBuild, locFileScript, buildDirectory);
	parseBuildScript(sampleBuild);
}

private void getBuildScript(buildTemplate simBuild, string locScript, string buildDirectory){

	//No way to get specific amount of lines in file. using shorts
	/*
		No support for loops or conditions yet...sorry....
		Because I think this isn't really self explanatory, I can explain:
			Go through file
			If file hits bracket, go through again
			Once you're after the bracket, continue doing commands
				Make sure it isn't a comment
			Once you hit a }, quit.
	*/
	short lineCount = 0;
	foreach(line; File(locScript).byLine()){
		if (line.length > 7 && line[0..8] == "build(){"){
			writeln("Got line of build() in builder");
			short lineCountAfter = 0;
			string tempBuildDirs;
			foreach(lineRec; File(locScript).byLine()){
				writeln(strip(lineRec));
				int containsBrack = buildTools.containsBracket(strip(lineRec));
				if (containsBrack == -1 && lineCountAfter > lineCount && strip(lineRec)[0] != '#'){
					tempBuildDirs ~= (strip(cast(string)lineRec)~'\n');
				}
				else{
					if (lineCountAfter > lineCount && containsBrack != -1){
						chdir(buildDirectory);
						simBuild.setBuildCommands(splitLines(tempBuildDirs));
						simBuild.getBuildCommands().writeln();
						break;
					}
				}
				lineCountAfter++;
			}
		        break;
		}
		lineCount++;
	}	
}

//Execute all of the build scripts on a package.
private void parseBuildScript(buildTemplate build){
	string[] tempStrList = build.getBuildCommands();
	for (int i = 0; i < tempStrList.length; i++){
		writefln("Doing process: %s", tempStrList[i]);
		std.process.system(tempStrList[i]);
	}
}
