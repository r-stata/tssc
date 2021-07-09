#delim ;
prog def cprdlink_linkage_coverage;
version 13.0;
*
 Create dataset with 1 obs per linkage data source
 and data on start and end dates for coverage by that data source.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 13 October 2017
*;

syntax using [ , CLEAR noKEY ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid.
*/

*
 Input data
*;
import delimited `using', varnames(1) delim(tab) stringcols(_all) `clear';
desc, fu;

* Add variable labels *;
cap lab var data_source "Linkage data source";
cap lab var start "Start date of collection of data from source";
cap lab var end "End date of collection of data from source";

*
 Add numeric date variables
*;
foreach X in start end {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
lab var start_n "Start date of data collection";
lab var end_n "End date of data collection";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby data_source, fast;
};

*
 Describe dataset
*;
desc, fu;

end;
