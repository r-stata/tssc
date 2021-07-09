#delim ;
prog def cprd_nonxyzlookup;
version 13.0;
/*
 Create non-XYZ lookup datasets,
 one for each non-3-character-code lookup table,
 with 1 observation per table entry
 and data on codes and text descriptions.
 Add-on packages used:
 keyby
*!Author: Roger Newson
*!Date: 08 August 2017
*/

syntax, TXTDirspec(string) [ DTADirspec(string) REPLACE ];
/*
 txtdirspec() specifies the input directory in which the .txt files will be found.
 dtadirspec() specifies the output directory in which the .dta files will be created.
 replace specifies that any existing .dta files of the same names will be replaced.
*/

*
 Set defaults
*;
if `"`dtadirspec'"'=="" {;
   local dtadirspec ".";
};
*
 Create datasets
*;
preserve;
local dslist "batchnumber bnfcodes common_dosages entity medical packtype product scoremethod";
local tflist: dir `"`txtdirspec'"' file "*.txt";
local tflist: list sort tflist;
local newdslist "";
foreach TF in `tflist' {;
  local ds=subinstr(lower(`"`TF'"'),".txt","",1);
  local dspres: list ds in dslist;
  if `dspres' {;
    cprd_`ds' using `"`txtdirspec'/`TF'"', clear;
    save `"`dtadirspec'/`ds'.dta"', `replace';
    local newdslist "`newdslist' `ds'";
  };
};
restore;
local newdslist: list sort newdslist;
local absdslist: list dslist - newdslist;
local Nnewds: word count `newdslist';
local Nabsds: word count `absdslist';
if `Nnewds'>0 disp _n as text "The following lookup datasets have been created:"
  _n as result "`newdslist'";
if `Nabsds'>0 disp _n as text "No text data were found for the following lookup datasets:"
  _n as result "`absdslist'";

end;
