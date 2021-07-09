#delim ;
prog def textpad;
version 10.0;
/*
 Call TextPad in current working folder
 from current Stata session under Windows
 to edit a specified file.
 Usage:
 textpad <command_line_parameters filename
*!Author: Roger Newson
*!Date: 21 June 2017
*/

local TextPad_path `"$TextPad_path"';
if `"`TextPad_path'"'=="" {;
  local TextPad_path `"c:\Program Files\TextPad 8\TextPad.exe"';
};
winexec "`TextPad_path'" `*';

end;
