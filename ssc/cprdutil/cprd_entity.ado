#delim ;
prog def cprd_entity;
version 13.0;
*
 Create dataset entity with 1 obs per entity type.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 29 September 2017
*;

syntax using [ , CLEAR ];

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
desc, fu;

* Add variable labels *;
cap lab var enttype "Number identifying the structured data area in Vision where data was entered";
cap lab var description "Description of entity type";
cap lab var filetype "Type of data file (Test or Clinical) that references entity type";
cap lab var category "Broad category for entity type description";
cap lab var data_fields "Number of data fields associated with the entity type";
cap lab var data1 "Description of data in data field 1";
cap lab var data1_desc "Description of data in data field 1";
cap lab var data1_lkup "Lookup file needed to decode values in data field 1";
cap lab var data2 "Description of data in data field 2";
cap lab var data2_desc "Description of data in data field 2";
cap lab var data2_lkup "Lookup file needed to decode values in data field 2";
cap lab var data3 "Description of data in data field 3";
cap lab var data3_desc "Description of data in data field 3";
cap lab var data3_lkup "Lookup file needed to decode values in data field 3";
cap lab var data4 "Description of data in data field 4";
cap lab var data4_desc "Description of data in data field 4";
cap lab var data4_lkup "Lookup file needed to decode values in data field 4";
cap lab var data5 "Description of data in data field 5";
cap lab var data5_desc "Description of data in data field 5";
cap lab var data5_lkup "Lookup file needed to decode values in data field 5";
cap lab var data6 "Description of data in data field 6";
cap lab var data6_desc "Description of data in data field 6";
cap lab var data6_lkup "Lookup file needed to decode values in data field 6";
cap lab var data7 "Description of data in data field 7";
cap lab var data7_desc "Description of data in data field 7";
cap lab var data7_lkup "Lookup file needed to decode values in data field 7";
cap lab var data8 "Description of data in data field 8";
cap lab var data8_desc "Description of data in data field 8";
cap lab var data8_lkup "Lookup file needed to decode values in data field 8";

*
 Convert string variables to numeric if necessary
*;
foreach X in enttype data_fields {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove entities with missing entity type
 (after justifying this)
*;
qui count if missing(enttype);
disp as text "Observations with missing enttype: " as result r(N)
  _n as text "List of observations with missing enttype (to be discarded):";
list if missing(enttype), abbr(32);
drop if missing(enttype);
* enttype should now be non-missing *;

* Key and save dataset *;
keyby enttype, fast;
desc, fu;

end;
