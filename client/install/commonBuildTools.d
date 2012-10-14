module buildTools;
import std.stdio;
import std.file;

public int containsBracket(char[] line){
                if (line[0..1] == "//"){
                        return -1;
                }
                 for (int i = 0; i < line.length; i++)
                 {
                         if (line[i] == '}'){
                              return i;
                         }
                }
                return -1;
}

public int containsFrontBracket(char[] line){
	if (line[0..1] == "//"){
		return -1;
	}
	for (int i = 0; i < line.length; i++){
		if (line[i] == '{'){	
			return i;
		}
	}
	return -1;
}
