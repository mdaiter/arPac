module remover;
import std.stdio;
import std.file;
import std.process;
//One method to remove packages. Deletes the folder _ custom stuff done to Arduino
void removePackages(string[] packageList){
	//Go through package list
	for (int i = 0; i < packageList.length; i++){
		//nail it onto end if you actually installed the package
		if (exists(getenv("HOME")~"/.arPac/"~packageList[i])){
			//Remove the package and all folders relating
			std.file.rmdirRecurse(getenv("HOME")~"/.arPac/"~packageList[i]);
		}
		//Don't remove it. Yo udidn't install it (idiot.)
		else{
			writeln("Are you sure that you installed this?");
		}
	}
}
