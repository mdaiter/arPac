import std.stdio;
import std.file;
import std.net.curl;
import std.string;
import std.regex;

//Update ports
void updatePorts(){
	if (exists("/etc/arPac/sources.list")){
		//Look through sources.list
		foreach(char[] line; File("/etc/arPac/sources.list").byLine()){
        	        char[] strippedLine = strip(line);
			writeln(strippedLine);
			auto httpSettings = HTTP();
			//Make sure a source isn't a comment
			if (strippedLine[0] != '#'){
				try{
					//Download file and unpack (if you are running a server, you MUST tar you r ports tree in a file called packageList.tar.gz)
					strippedLine ~= "/packageList.tar.gz";
					writefln("%s is the file we're trying to download...", strippedLine);
					download(strippedLine, "/tmp/packageList.tar.gz");
					unpackData();
					break;
				}
				catch(CurlException e){
					writeln("Couldn't download file from source specified...");
				}
				/*catch (std.stream.OpenException e){
					writeln("Couldn't open file...");
				}*/
			}
			else{
				//writeln("You have no mirrors (we can't download stuff from this....)!!!!");
			}
        	}
	}
	else{
		writeln("/etc/arPac/sources.list doesn't exist...did you delete it (DERP)?");
	}
}

//Basically rewrites ports from ground up with new data (rolling release system)
void unpackData(){
	if (exists("/etc/arPac/ports")){
		//Goes through and deletes files
		foreach(string d; dirEntries("/etc/arPac/ports", SpanMode.depth)){
			if (d.isDir()){
				std.file.rmdir(d);
			}
			else{
				std.file.remove(d);
			}
		}
	}
	//Unpacks new system
	std.process.system("tar -xvf /tmp/packageList.tar.gz -C /etc/arPac/ports/");
	std.file.remove("/tmp/packageList.tar.gz");
}
