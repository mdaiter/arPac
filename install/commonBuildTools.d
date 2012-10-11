module buildTools;
import std.stdio;
import std.file;

public bool containsBracket(char[] line){
                if (line[0] == '#'){
                        return false;
                }
                 for (int i = 0; i < line.length; i++)
                 {
                         if (line[i] == '}'){
                              return true;
                         }
                }
                return false;
}
