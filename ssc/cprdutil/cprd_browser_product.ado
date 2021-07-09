#delim ;
prog def cprd_browser_product;
version 13.0;
*
 Create dataset product with 1 obs per product code.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 12 October 2017
*;

syntax using [ , CLEAR noKEY ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by prodcode.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) `clear';
cap lab var prodcode "Product Code";
* Old-format names *;
cap lab var therapyevents "Therapy Events";
cap lab var gemscriptcode "Gemscript Code";
cap lab var productname "Product Name";
cap lab var drugsubstancename "Drug Substance Name";
cap lab var substancestrength "Substance Strength";
cap lab var formulation "Formulation";
cap lab var routeofadministration "Route of Administration";
cap lab var bnfcode "BNF Code";
cap lab var bnfheader "BNF Header";
cap lab var databasebuild "Database Build";
* New-format names *;
cap lab var gemscript "Gemscript Code";
cap lab var therapy_events "Therapy Events";
cap lab var product_name "Product Name";
cap lab var drug_substance_name "Drug Substance Name";
cap lab var substance_strength "Substance Strength";
cap lab var formulation "Formulation";
cap lab var route_of_administration "Route of Administration";
cap lab var bnf_code "BNF Code";
cap lab var bnf_reader "BNF Header";
cap lab var database_build "Database Build";
* Describe dataset *;
desc, fu;

*
 Convert string variables to numeric if necessary
*;
foreach X in prodcode therapyevents therapy_events {;
  cap conf string var `X';
  if !_rc {;
    destring `X', replace force;
    charundef `X';
  };
};
charundef _dta *;

*
 Remove entities with missing product code
 (after justifying this)
*;
qui count if missing(prodcode);
disp as text "Observations with missing prodcode: " as result r(N)
  _n as text "List of observations with missing prodcode (to be discarded):";
list if missing(prodcode), abbr(32);
drop if missing(prodcode);

*
 Add numeric database build variable
*;
foreach X in databasebuild database_build {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=monthly(`X',"MY",2099);
    compress `X'_n;
    format `X'_n %tmCCYY/NN;
    lab var `X'_n "Database build (monthly date)";
  };
};

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby prodcode;
};

*
 Describe dataset
*;
desc, fu;
char list;

end;
