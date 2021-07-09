#delim ;
prog def cprd_product;
version 13.0;
*
 Create dataset product with 1 obs per product code.
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
cap lab var prodcode "Product Code";
cap lab var gemscriptcode "Gemscript product code for the corresponding product name";
cap lab var productname "Product name as entered at the practice";
cap lab var drugsubstance "Drug substance";
cap lab var strength "Strength of the product";
cap lab var formulation "Form of the product e.g. tablets, capsules etc";
cap lab var route "Route of administration of the product";
cap lab var bnfcode "British National Formulary (BNF) code";
cap lab var bnfchapter "British National Formulary (BNF) chapter";

*
 Convert string variables to numeric if necessary
*;
foreach X in prodcode {;
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
* prodcode should now be non-missing *;

* Key and save dataset *;
keyby prodcode, fast;
desc, fu;

end;
