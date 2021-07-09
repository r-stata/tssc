#delim ;
program define adoins;
version 10.0;
*
 Alter ado path to start with the Stata system folders
 UPDATES and BASE, followed by inserted folders,
 followed by PERSONAL, PLUS, SITE,  . and OLDPLACE
 (for independent-minded users who want to insert libraries
 after the official Stata libraries).
*!Author: Roger Newson
*!Date: 10 November 2017
*;

syntax [ anything(name=inflist id="Inserted file list") ] ,;

local Ninf: word count `inflist';

qui{;
  adopath ++ OLDPLACE;
  adopath ++ .;
  adopath ++ SITE;
  adopath ++ PLUS;
  adopath ++ PERSONAL;
  forv i1=`Ninf'(-1)1 {;
    local X: word `i1' of `inflist';
    adopath ++ `"`X'"';
  };
  adopath ++ BASE;
  adopath ++ UPDATES;
};

* Display final adopath *;
adopath;

end;

