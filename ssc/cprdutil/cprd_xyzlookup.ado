#delim ;
prog def cprd_xyzlookup;
version 13.0;
/*
 Create datasets with names of form xyz.dta,
 one for each 3-character-code lookup table,
 with 1 observation per table entry
 and data on codes and text descriptions,
 and/or a do-file,
 to create a set of value labels
 for each 3-character-code lookup,
 to be used when value labels are needed
 in the extraction datasets.
 Add-on packages used:
 keyby, tfconcat
*!Author: Roger Newson
*!Date: 11 October 2017
*/

syntax, TXTDirspec(string) [ DTADirspec(string) REPLACE DOfile(string asis) ];
/*
 txtdirspec() specifies the input directory in which the .txt files will be found.
 dtadirspec() specifies the output directory in which the .dta files will be created.
 replace specifies that any existing .dta files of the same names will be replaced.
 dofile() specifies the do-file to be created, creating the xyz lookup value labels.
*/

preserve;

*
 Create lookup datasets with names of form xyz.dta
 and lookup label specifications in temporary do-files
*;
local tfnames: dir `"`txtdirspec'"' files `"*.txt"';
local dflist "";
local Nxyzlookup: word count `tfnames';
forv i1=1(1)`Nxyzlookup' {;
  local lookuplab: word `i1' of `tfnames';
  local txtname `"`txtdirspec'/`lookuplab'"';
  local lookuplab=lower(subinstr(`"`lookuplab'"',".txt","",1));
  if(length(`"`lookuplab'"'))!=3 {;
    continue;
  };
  local dtaname=`"`lookuplab'"'+".dta";
  clear;
  disp _n as text "Inputting lookup dataset: " as result "`lookuplab'";
  import delimited using `"`txtname'"', varnames(1) numericcols(1) stringcols(2);
  desc, fu;
  unab vlist: *;
  local vcount: word count `vlist';
  cap assert `vcount'>=2;
  if _rc {;
    disp as error "XYZ lookup dataset has `vcount' variables. There should be at least 2.";
    continue;
  };
  local codevar: word 1 of `vlist';
  local labvar: word 2 of `vlist';
  local labvarlab: var lab `labvar';
  cap assert "`codevar'"=="code";
  if _rc {;
    disp as error "First variable in XYZ lookup dataset is named `codevar'. It should be named code.";
    continue;
  };
  label data `"`labvarlab'"';
  *
   Remove entities with missing code
   (after justifying this)
  *;
  qui count if missing(code);
  disp as text "Observations with missing code: " as result r(N)
    _n as text "List of observations with missing code (to be discarded):";
  list if missing(code), abbr(32);
  drop if missing(code);
  * code should now be non-missing *;
  keyby code;
  desc, fu;
  char list;
  list, abbr(32);
  if `"`dtadirspec'"'!="" {;
    save `"`dtadirspec'/`dtaname'"', `replace';
  };
  * Create and save variable label *;
  gene long codeseq=_n;
  compress codeseq;
  levelsof code, lo(codes);
  foreach C of num `codes' {;
    summ codeseq if code==`C', meanonly;
    local codeseqcur=r(min);
    local codelabcur=`labvar'[`codeseqcur'];
    lab def `lookuplab' `C' `"`codelabcur'"', add;
  };
  if `"`dofile'"'!="" {;
    tempfile dfcur;
    lab save `lookuplab' using `"`dfcur'"', replace;
    local dflist `"`dflist' `dfcur'"';
  };
};

*
 Concatenate do-files
*;
if `"`dofile'"'!="" {;
  clear;
  dosave `dflist' using `dofile';
};

restore;

end;

prog def dosave;
version 13.0;
*
 Save the do-file using anything as input file list
*;
syntax [anything] using/ [, REPLACE ];

tfconcat `anything', gene(cmdline) tfid(dofile) obsseq(cmdseq) length(`=c(maxstrvarlen)');
keyby dofile cmdseq;
outfile cmdline1 using `"`using'"', runtogether `replace';
disp _n as text `"Do-file saved: "' as result `"`using'"';

end;
