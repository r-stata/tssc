#delim ;
prog def cprdhes_maternity;
version 13.0;
*
 Create dataset with 1 obs per critical care event
 and data on critical care event attributes.
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
cap lab var numbaby "Number of babies (live or stillborn) delivered";
cap lab var numtailb "Number of baby tails";
cap lab var matordr "Order of birth";
cap lab var neocare "Neonatal level of care";
cap lab var wellbaby "Well baby check flag";
cap lab var anasdate "First antenatal assessment date";
cap lab var birordr "The position in the sequence of births";
cap lab var birstat "Baby born alive or dead (still birth)";
cap lab var biresus "Resuscitation method used to get the baby breathing";
cap lab var sexbaby "Sex of baby";
cap lab var birweit "Weight of the baby in grams immediately after birth";
cap lab var delmeth "Method used to deliver a baby that is a registrable birth";
cap lab var delonset "Method used to induce (initiate) labour";
cap lab var delinten "Intended type of delivery place";
cap lab var delplac "Actual type of delivery place";
cap lab var delchang "Reason for changing the delivery place type";
cap lab var delprean "Anaesthetic or analgesic administered before and during labour and delivery";
cap lab var delposan "Anaesthetic or analgesic administered after delivery";
cap lab var delstat "Status of the person conducting the delivery";
cap lab var anagest "Gestation period in weeks at the date of the first antenatal assessment";
cap lab var gestat "Length of gestation - number of completed weeks of gestation";
cap lab var numpreg "Number of previous pregnancies that resulted in a registered birth";
cap lab var matage "Mother's age at delivery";
cap lab var neodur "Baby's age in days";
cap lab var antedur "Antenatal days of stay";
cap lab var postdur "Postnatal days of stay";

*
 Convert string variables to numeric if necessary
*;
foreach X in patid spno epikey eorder epidur numtailb matordr neocare
  birstat biresus birweit
  delonset delinten delplac delchang delprean delposan delstat anagest gestat
  numpreg matage neodur antedur postdur {;
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
foreach X in epistart epiend anasdate {;
  cap conf string var `X';
  if !_rc {;
    gene long `X'_n=date(`X',"DMY");
    compress `X'_n;
    format `X'_n %tdCCYY/NN/DD;
  };
};
cap lab var epistart_n "Episode start date";
cap lab var epiend_n "Episode end date";
cap lab var anasdate_n "First antenatal assessment date";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby patid spno epikey matordr, fast;
};

*
 Describe dataset
*;
desc, fu;
char list;

end;
