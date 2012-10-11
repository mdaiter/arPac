module packageStripper;
import std.stdio;
import std.file;
import install;
import buildTools;

public void stripFile(buildTemplate sampBuild, string pkgname){
	stripUseFlags(sampBuild);
	stripAllFlags(sampBuild);
}

private void stripAllFlags(buildTemplate sampBuild){
	stripFileFlags(sampBuild.getAllUseFlags());
}

private void stripUseFlags(buildTemplate sampBuild){
	stripFileFlags(sampBuild.getUserWantedFlags());
}

private bool containsFlag(string flag, string line){
	for (int i = 0; i < line.length - flag.length; i++){
		//Avoid comments...
		if (strip(line)[i..i+flag.length-1] == flag && strip(line)[0..1] != "//"){
			return true;
		}
	}
	return false;
}

/*
Yes, I realize that this seems REALLY copied over from the other class. It's for time's sake...
Also, this code only handles '//'. No /* in your code.
*/
private void stripFileFlags(string[] flags, string pkgname){
	short lineCount = 0;
	for (int i = 0; i < flags.length; i++){
        	foreach(line; File(pkgname).byLine()){
                	if (line.length > flags[i].length && containsFlag(flags[i], line)){
                	        short lineCountAfter = 0;
				short brakCount = 1;
                	        foreach(lineRec; File(pkgname).byLine()){
                	                writeln(strip(lineRec));
                	                bool containsBrack = buildTools.containsBracket(strip(lineRec));
                	                if (!containsBrack && lineCountAfter > lineCount && strip(lineRec)[0..1] != "//"){
                	                	//Add one to the amount of brackets you can have
						brakCount++;
						//Delete line
					}
                	                else{
                	                        if (lineCountAfter > lineCount && containsBrack){
							
	                                        }
	                                }
	                                lineCountAfter++;
	                        }
	                }
	                lineCount++;
		}
	}
}

//Little method to "delete lines". Got it from Rosetta Code. Heavily modified. Really D? No method for deleting lines? You suck.
private void deleteLines(string name, int start, int num)
    start--;
 
    auto lines = readText(name).splitLines();
 
    auto f = File(name, name[0..name.length-4]~"tmp.pde");
    foreach (int i, line; lines) {
        	if (start > i || i >= start + num){
           		f.writeln(line);
		}
	}
}
