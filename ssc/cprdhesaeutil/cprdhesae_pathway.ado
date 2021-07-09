#delim ;
prog def cprdhesae_pathway;
version 13.0;
*
 Create dataset with 1 obs per HES A&E patient pathway.
 Add-on packages required:
 keyby, chardef.
*!Author: Roger Newson
*!Date: 29 January 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
 delimiters() is passed through to import delimited.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `delimiters' `clear';
desc, fu;

*
 Label variables
*;
cap lab var patid "Patient ID";
cap lab var aekey "A&E attendance record key";
cap lab var rttperstart "Start date for RTT period";
cap lab var rttperend "End date for RTT period";
cap lab var ethnos "Ethnic category recorded at attendance";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid aekey {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Add numeric date variables computed from string dates
*;
foreach X in rttperstart rttperend {;
  cap conf string var `X';
  if !_rc {;
    local Xlab: var lab `X';
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
    lab var `X'_n `"`Xlab'"';
  };
};

*
 Key dataset if required
*;
if "`key'"!="nokey" {;
  keyby patid aekey, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
