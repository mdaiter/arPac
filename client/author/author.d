module authorTool;
import std.stdio;
import std.file;

void lookupAuthors(string[] pkgName){
	for (int i = 0; i < pkgName.length;i++){
		if (exists("/etc/arPac/ports")){
			pkgName[i] = "/etc/arPac/ports/" ~ pkgName[i];
			foreach(line; File(pkgName[i]).byLine()){
				if (line.length > 7 && line[0..7] == "AUTHOR="){
					writefln("The author(s) is (are): %s", line[7..line.length-1]);
					break;
				}
			}
		}
		else{
			writeln("Can't find ports...did you delete it?");
		}
	}
}

void lookupLicense(string[] pkgName){
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

