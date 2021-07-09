#delim ;
program define adofac;
version 10.0;
*
 Alter ado path to start with the Stata system folders
 UPDATES, BASE, SITE, ., PERSONAL, PLUS and OLDPLACE
 (which were the factory settings in Stata 10
 when I last checked them).
*!Author: Roger Newson
*!Date: 10 November 2017
*;

qui{;
  adopath ++ OLDPLACE;
  adopath ++ PLUS;
  adopath ++ PERSONAL;
  adopath ++ .;
  adopath ++ SITE;
  adopath ++ BASE;
  adopath ++ UPDATES;
};

* Display final adopath *;
adopath;

end;

