*! comfirmdir Version 1.1 dan_blanchette@unc.edu 22Jan2009
*! the carolina population center, unc-ch
* Center of Entrepreneurship and Innovation Duke University's Fuqua School of Business
* confirmdir Version 1.1 dan_blanchette@unc.edu  17Jan2008
* research computing, unc-ch
*  - made it handle long directory names
** confirmdir Version 1.0 dan_blanchette@unc.edu  05Oct2003
** the carolina population center, unc-ch

program define confirmdir, rclass
 version 8
 
 local cwd `"`c(pwd)'"'
 quietly capture cd `"`1'"'
 local confirmdir=_rc 
 quietly cd `"`cwd'"'
 return local confirmdir `"`confirmdir'"'
 
end 
