module remover;
import std.stdio;
import std.file;
import std.process;

void removePackages(string[] packageList){
	for (int i = 0; i < packageList.length; i++){
		if (exists(getenv("HOME")~"/.arPac/"~packageList[i])){
			std.file.rmdirRecurse(getenv("HOME")~"/.arPac/"~packageList[i]);
		}
		else{
			writeln("Are you sure that you installed this?");
		}
	}
}
