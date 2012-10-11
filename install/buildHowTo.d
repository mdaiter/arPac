module builder;
import std.stdio;
import std.file;
import std.string;
//Only needed for the build template class
import install;
import buildTools;

void buildMeta(buildTemplate sampleBuild, string locFileScript){
	getBuildScript(sampleBuild, locFileScript);
	parseBuildScript(sampleBuild);
}

private void getBuildScript(buildTemplate simBuild, string locScript){

	//No way to get specific amount of lines in file. using shorts
	/*
		No support for loops or conditions yet...sorry....
	*/
	short lineCount = 0;
	foreach(line; File(locScript).byLine()){
		if (line.length > 7 && line[0..8] == "build(){"){
			writeln("Got line of build()");
			short lineCountAfter = 0;
			string tempBuildDirs;
			foreach(lineRec; File(locScript).byLine()){
				writeln(strip(lineRec));
				bool containsBrack = buildTools.containsBracket(strip(lineRec));
				if (!containsBrack && lineCountAfter > lineCount && strip(lineRec)[0] != '#'){
					tempBuildDirs ~= (strip(cast(string)lineRec)~'\n');
				}
				else{
					if (lineCountAfter > lineCount && containsBrack){
						
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

private void parseBuildScript(buildTemplate build){
	string[] tempStrList = build.getBuildCommands();
	for (int i = 0; i < tempStrList.length; i++){
		std.process.system(tempStrList[i]);
	}
}


