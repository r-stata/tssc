#delim ;
prog def cprdhes_acp;
version 13.0;
*
 Create dataset with 1 obs per augmented care period (ACP) episode
 and data on ACP attributes.
 Add-on packages required:
 keyby, chardef
*!Author: Roger Newson
*!Date: 29 January 2019
*;

syntax using [ , CLEAR noKEY DELIMiters(passthru) ENCoding(string) ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by patid, spno, epikey and d_order.
 delimiters() is passed through to import delimited.
 encoding() is passed through to import delimited as a charset() option.
*/

*
 Input data
*;
import delimited `using', varnames(1) stringcols(_all) charset(`"`encoding'"') `delimiters' `clear';
desc, fu;

* Label variables *;
cap lab var patid "Patient ID";
cap lab var spno "Spell number";
cap lab var epikey "Episode key";
cap lab var epistart "Date of start of episode";
cap lab var epiend "Date of end of episode";
cap lab var eorder "Order of episode within spell";
cap lab var epidur "Duration of episode in days";
cap lab var numacp "Number of augmented care periods within episode";
cap lab var acpn "Order of an augmented care episode within augmented care period";
cap lab var acpstar "Start date of augmented care period";
cap lab var acpend "End date of augmented care period";
cap lab var acpdur "Duration of augmented care period in days";
cap lab var intdays "Number of days of intensive care in augmented care period";
cap lab var depdays "Number of days of high dependency care in augmented care period";
cap lab var acploc "Location of a patient during augmented care period";
cap lab var acpsour "Location of patient immediately before augmented care period";
cap lab var acpdisp "Destination of discharged patient after augmented care period";
cap lab var acpout "Augmented care period outcome indicator";
cap lab var acpplan "Flag for whether ACP was planned in advance of admission to ACP location";
cap lab var acpspef "Code for main specialty of consultant clinically managing the ACP";
cap lab var orgsup "Number of organ support systems used (up to five) during an ACP";
cap lab var acpdqind "Augmented care period quality Indicator";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno epikey eprder epidur numacp acpn acpdur intdays depdays acploc acpsour acpdisp acpout orgsup {;
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
foreach X in epistart epiend acpstar acpend {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var epistart_n "Episode start date";
cap lab var epiend_n "Episode end date";
cap lab var acpstar_n "Augmented care period start date";
cap lab var acpend_n "Augmented care period end date";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby patid spno epikey acpn, fast miss;
};

*
 Describe dataset
*;
desc, fu;
char list;

end;
