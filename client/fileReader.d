module fileReader;

import std.stdio;

void readFileLine(string file){
	writeln("Hit here!");
	foreach(line; File(file).byLine()){
		writeln(line);
	}
}
