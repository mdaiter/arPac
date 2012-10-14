module packageStripper;
import std.stdio;
import std.file;
import std.string;
import install;
import std.algorithm;
import buildTools;

public void stripFile(buildTemplate sampBuild, string pkgname){
	stripUseFlags(sampBuild, pkgname);
	stripAllFlags(sampBuild, pkgname);
}

private void stripAllFlags(buildTemplate sampBuild, string pkgname){
	strFileFlags(sampBuild.getAllUseFlags(), pkgname, true);
}

private void stripUseFlags(buildTemplate sampBuild, string pkgname){
	writeln(sampBuild.getAllUseFlags());
	strFileFlags(sampBuild.getUserWantedFlags(), pkgname, false);
}

private int containsFlag(string flag, string line){
	if (line.length > flag.length){
		for (int i = 0; i < line.length - flag.length; i++){
			//Avoid comments...
			if (strip(line)[i..i+flag.length] == flag && strip(line)[0..1] != "//"){
				return i;
			}
		}
	}
	return -1;
}

/*
Yes, I realize that this seems REALLY copied over from the other class. It's for time's sake...
Also, this code only handles '//'. No /* in your code.
*/
/*private void stripFileFlags(string[] flags, string pkgname){
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
							brakCount--;
							if (brakCount == 0){
								break;
							}
	                                        }
	                                }
	                                lineCountAfter++;
	                        }
	                }
	                lineCount++;
		}
	}
}*/

private string[] strFileFlags(string[] flags, string pkgname, bool isAll){
	string[] linesInFile = readText(pkgname).splitLines();
	for (int j = 0; j < flags.length; j++){
		writeln("Use flag for this iteration is: " ~ flags[j]);
		short lineNumOfUSE = 0;
		bool firstBrak = true;
		bool inUSE = false;
		short countBraks = 0;
		for (int i = 0; i < linesInFile.length; i++){
			writeln("Line in file is: " ~ linesInFile[i]);
			//If line contains flag and isn't commented out, then the new code block is equal to i
			int valIfFlagExists = containsFlag(flags[j], linesInFile[i]);
			if (strip(linesInFile[i]).length > flags[j].length && valIfFlagExists != -1 && strip(linesInFile[i][0..1]) != "//" && inUSE == false){
				writeln("Line contains flag!");
				lineNumOfUSE = cast(short)i;
				inUSE = true;
				string tempModString = linesInFile[i];
				tempModString = cast(string)tempModString[0..valIfFlagExists]~tempModString[valIfFlagExists+flags[j].length..tempModString.length];
				linesInFile[i] = tempModString;
				writeln("USE Flag start is equal to: " ~ linesInFile[i]);
			}
			//If line contains brak after use was found, then start the counting game...
			if (inUSE == true){
				writeln("inUSE == true");
				if (buildTools.containsBracket(cast(char[])strip(linesInFile[i])) != -1){
					countBraks--;
					//If we hit here, then we need to stop (also need to catch errors people make in code)
					if (countBraks < 1){
						int posBrakLine = buildTools.containsBracket(cast(char[])strip(linesInFile[i]));
						//Modify line to only include junk after last bracket
						linesInFile[i] = cast(string)linesInFile[posBrakLine..(linesInFile[i].length-1)];
						//Reset everything
						inUSE = false;
						firstBrak = true;
						if (linesInFile[i] == ""){
							
						}
					}
					else if (isAll == false){
						linesInFile = linesInFile.remove(i);
						i--;
					}
				}
				else if (buildTools.containsFrontBracket(cast(char[])strip(linesInFile[i])) != -1){
					writeln("Contained front bracket!");
					countBraks++;
					if (firstBrak == true){
						firstBrak = false;
						int posBrakLine = buildTools.containsFrontBracket(cast(char[])strip(linesInFile[i]));
						writefln("%d is the place of the starting {", posBrakLine);
						string tempStr = linesInFile[i];
						tempStr = tempStr[posBrakLine+1..tempStr.length];
						linesInFile[i] = tempStr;
						writeln("New line is " ~ linesInFile[i]);
						if (linesInFile[i] == ""){
							linesInFile = linesInFile.remove(i);
							i--;
						}
						continue;
					}
					else if (isAll == false){
						linesInFile = linesInFile.remove(i);
						i--;
					}
				}
				else{
					//If it's removing use flags, then remove a line
					linesInFile = linesInFile.remove(i);
					i--;
				}
				writefln("Countbraks is: %d", countBraks);
			}
		}
	}
	writeChangesToFile(pkgname, linesInFile);
	return linesInFile;
}

private void writeChangesToFile(string pkgname, string[] linesInFile){
	 std.file.remove(pkgname);
        /*Create new file after deleting old one.
        */
        std.file.write(pkgname, linesInFile[0]);
        for (int i = 1; i < linesInFile.length; i++){
                try{
                        std.file.append(pkgname, linesInFile[i] ~ "\n");
                }
                //Don't really care...for now.
                catch (std.utf.UTFException e){
                }
        }
}
