*! version 0.2 17april2007
#delim ;

program def gzipsave;
version 9.0;
syntax anything(name=dset) [,remove verbose replace];
/*
 gzipsave "save"s  memory data into a gzipped dataset.
 it plays well with gzipuse. Kit Baum made some very
 nice suggestion about how to write these more stata
 like.
*/;
if `"`verbose'"' == "verbose"{;
 local verbose = `"-v"';
};

local zsuf = `"dgz"';
local mygzip = "/usr/bin/gzip";
local mygzcat = "/usr/bin/gzcat";
local myrm = "/usr/bin/rm";
if c(os) == "MacOSX"{;
 local myrm ="/bin/rm";
};
capture which ashell;
if _rc != 111 {;
 quietly ashell "which rm";
 if regexm(r(o1),"^/") == 1 {;
  local myrm = r(o1);
 };
 else{;
  display as error "Could not find rm in your path.";
  exit;
 };
 quietly ashell "which gzip";
 if regexm(r(o1),"^/") == 1 {;
  local mygzip = r(o1);
 };
  else{;
  display as error "Could not find gzip in your path.";
  exit;
 };
 quietly ashell "which gzcat";
 if regexm(r(o1),"^/") == 1 {;
  local mygzcat = r(o1);
 };
 else{;
  display as error "Could not find gzcat in your path.";
  exit;
 };
};



* Run program *;
if("$S_OS"=="Windows"){;
 display "Sorry we do not do windows yet...";
 exit;
};

else{;
 local adogz = regexm("`dset'","\.`zsuf'$");
 if (`adogz' == 1){;
  local prefix = regexr(`"`dset'"',`"\.`zsuf'"',"");
  local fname = `"`dset'"';
 };
 else{;
  local prefix = `"`dset'"';
  local fname = `"`dset'.`zsuf'"';
 };
 local stamp = `"`prefix'.dta"';
 capture save `"`stamp'"', `replace';
 if _rc ~= 0 {;
    noisily error _rc;
 };
 capture confirm file `"`prefix'.dgz"';
  if _rc == 0 & `"`replace'"' ~= "replace" {;
   display as error "Bailing out .`zsuf' exists and no replace is specified.";
   display as error ".dta has been saved";
   exit;
 };
 shell `mygzip' `verbose' -c `stamp' > `fname';
 if `"`remove'"' == "remove"{;
  shell `myrm' `stamp';
 };
};
end;
