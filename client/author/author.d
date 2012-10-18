module authorTool;
import std.stdio;
import std.file;
//Look author
void lookupAuthors(string[] pkgName){
	//Go through each package
	for (int i = 0; i < pkgName.length;i++){
		//MAKE SURE PORTS EXISTS
		if (exists("/etc/arPac/ports")){
			//Abridge ports to the name for easier lookup
			pkgName[i] = "/etc/arPac/ports/" ~ pkgName[i];
			foreach(line; File(pkgName[i]).byLine()){
				if (line.length > 7 && line[0..7] == "AUTHOR="){
					//Inform
					writefln("The author(s) for package %s is (are): %s", pkgName[i], line[7..line.length-1]);
					break;
				}
			}
		}
		else{
			writeln("Can't find ports...did you delete it?");
		}
	}
}
//Lookup licenses
void lookupLicense(string[] pkgName){
	//Same as above, just replace author with license
        for (int i = 0; i < pkgName.length;i++){
                if (exists("/etc/arPac/ports")){
                        pkgName[i] = "/etc/arPac/ports/" ~ pkgName[i];
                        foreach(line; File(pkgName[i]).byLine()){
                                if (line.length > 8 && line[0..8] == "LICENSE="){
                                        writefln("The licenses(s) is (are): %s", line[8..line.length-1]);
                                        break;
                                }
                        }
                }
                else{
                        writeln("Can't find ports...did you delete it?");
                }
        }
}

