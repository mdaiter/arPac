module buildTools;
import std.stdio;
import std.file;
//Check through line to see if there's a }
public int containsBracket(char[] line){
		//Make sure there isn't a comment
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

//Check through a line to see if there's a {
public int containsFrontBracket(char[] line){
	//Make sure there isn't a comment
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
