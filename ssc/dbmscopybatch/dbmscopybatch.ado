*!Amadou B. DIALLO
*!AFTPM, The World Bank, and CERDI, Univ. of Auvergne (France).
*!September 1, 2005
*!Data Conversion Utility. This program creates a log (batch) file to be used later by DBMS Copy.

#d;
prog dbmscopybatch;
version 8;
se mo 1;
syntax anything, Path(string) Dpath(string) In(string) Out(string) OS(string) [Log(string) 
Version(real 7) Call OPtions(string)];

// Preparing the log file to be used later by DBMS Copy;

cap file close myfile ;
qui file open myfile using "`path'\`log'.prg", write replace;
qui file close myfile;

tokenize `"`options'"';
local myop "`options'";
local ju: subinstr local options ";" "", all count(local num); 
di "`num'";
local num = `num' + 1;
tokenize "`options'", parse(";");                              
local i = 1;
while "``i''"!="" {;
     if "``i''"!=";" {;
       local l`i' "``i''";
       local max = `i';
     };
     local ++i;
};

token `anything';
while "`1'" ~= "" {;
 qui file open myfile using "`path'\`log'.prg", write append;
 file write myfile "compute;" _n;
 file write myfile "in='`path'\`1'.`in''" _n;
 file write myfile " out='`path'\`1'.`out'';" _n;
 if "`options'"~="" {;                  // if DBMS is requested to do additional tasks;
       forv i = 1/`max' {;
            if "`l`i''"!="" {;
              file write myfile "`l`i'';" _n;
            };
       };
 };
 file write myfile "run;" _n;
 qui file close myfile;
 mac shift;
};

// Now calling dbms copy;
if "`call'"~= "" {;
  if("$S_OS"=="Windows"){;
    shell "`dpath'\dbmswin`version'";
  };
  else if("$S_OS"~="Windows"){;
   di in re "This is not a Windows Operating System. Execute the created batch file under DBMS Copy." _n;
  };
};
end;