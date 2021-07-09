*! version 0.2 17april2007
#delim ;

program def gzipuse;
version 6.0;
syntax anything(name=dset) [,  clear];
/*
 gzipuse "use"s a gzipped dataset. 
 it plays well with gzipsave. Kit Baum made some very
 nice suggestion about how to write these more stata
 like.
*/;


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
 if regexm(r(o1),"^/") == 1  {;
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
  local fname = `"`dset'"';
 };
 else{;
  local fname = `"`dset'.`zsuf'"';
 };
 capture confirm file `"`fname'"';
  if _rc ~= 0 {;
    noisily error _rc;
  };
  local stamp = string(uniform());
  local stamp = reverse("`stamp'");
  local stamp = regexr("`stamp'","\.",".tmp.dta");
  shell `mygzcat' -S.`zsuf' `dset' >> `stamp';
  capture use `stamp',`clear';
  /* Cleanup and exit with fireworks if un"clear" ;) */;
  if _rc ~= 0 {;
    shell `myrm' `stamp'; 
    noisily error _rc;
  };
  shell `myrm' `stamp';
};
end;
