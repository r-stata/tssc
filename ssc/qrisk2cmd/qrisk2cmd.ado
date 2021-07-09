#delim ;
prog def qrisk2cmd;
version 13.0;
/*
 Run the qrisk2 command
 with input and output files supplied by the user.
*!Author: Roger Newson
*!Date: 14 September 2016
*/

local qrisk2lib `"$qrisk2_lib"';
if `"`qrisk2lib'"'=="" {;
  if c(os)=="Windows" {;
    local qrisk2lib `".\\"';
  };
  else {;
    local qrisk2lib `"./"';
  };
};
local qrisk2jar `"$qrisk2_jar"';
if `"`qrisk2jar'"'=="" {;
  local qrisk2jar `"QRISK2-2016-batchProcessor.jar"';
};
local qrisk2libjar="`qrisk2lib'"+"`qrisk2jar'";

local qrisk2command `"java -Dderby.system.home=`qrisk2lib' -jar "`qrisk2libjar'" `0'"';
disp as text "qrisk2 command submitted:" _n as result `"`qrisk2command'"';
shell `qrisk2command' ;

end;
