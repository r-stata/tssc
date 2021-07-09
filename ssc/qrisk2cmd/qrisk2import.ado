#delim ;
prog def qrisk2import;
version 13.0;
/*
 Import a qrisk2 input or output dataset.
*!Author: Roger Newson
*!Date: 14 September 2016
*/

syntax using [, CLEAR noKEY ];
/*
 clear specifies that any existing dataset in memory will be cleared.
 nokey specifies that the new dataset will not be keyed by prodcode.
*/

*
 Input dataset into memory
 and drop empty lines
 and comment lines (beginning with "#");
*;
qui {;
  import delimited S_1 `using', `clear' delim(tab) varnames(nonames);
  drop if trim(S_1)=="";
  drop if substr(trim(S_1),1,1)=="#";
};

*
 Save temporary version
*;
qui {;
  tempfile csvf1;
  outfile S_1 using `"`csvf1'"', runtogether replace;
};

*
 Import temporary version
*;
qui import delimited using `"`csvf1'"', varnames(1) clear delim(",");

*
 Value and variable labels
*;
lab def sex 0 "Female" 1 "Male";
lab def ethnicity
  0 "Not recorded"
  1 "British"
  2 "Irish"
  3 "Other White Background"
  4 "White & Black Caribbean"
  5 "White & Black African"
  6 "White & Asian"
  7 "Other mixed"
  8 "Indian"
  9 "Pakistani"
  10 "Bangladeshi"
  11 "Other Asian"
  12 "Caribbean"
  13 "Black African"
  14 "Other Black"
  15 "Chinese"
  16 "Other ethnic group"
  17 "Not stated"
  ;
lab def noyes 0 "No" 1 "Yes";
lab def diabetes_category 0 "None" 1 "Type 1" 2 "Type 2";
lab def smoke_cat
  0 "Non smoker"
  1 "Ex-smoker"
  2 "Light smoker"
  3 "Moderate smoker"
  4 "Heavy smoker"
  ;
cap lab val sex sex;
cap lab val ethnicity ethnicity;
cap lab val diabetes_category "Diabetes category";
cap lab val smoke_cat smoke_cat;
foreach X in rheumatoid_arthritis atrial_fibrillation chronic_renal_disease history_of_cvd family_history_of_chd treated_hypertension {;
  cap lab val `X' noyes;
};
cap lab var row_id "Patient ID";
cap lab var age "Age (years)";
cap lab var sex "Sex";
cap lab var ethnicity "Ethnicity";
cap lab var rheumatoid_arthritis "Rheumatoid arthritis";
cap lab var atrial_fibrillation "Atrial fibrillation";
cap lab var chronic_renal_disease "Chronic renal disease";
cap lab var diabetes_category "Diabetes category";
cap lab var history_of_cvd "History of CVD";
cap lab var smoke_cat "Smoking category";
cap lab var family_history_of_chd "Family history of CVD";
cap lab var townsend_score "Townsend score";
cap lab var postcode "Post code";
cap lab var body_mass_index "Body mass index (kilos/square metre)";
cap lab var cholesterol_hdl_ratio "Cholesterol/HDL ratio";
cap lab var systolic_blood_pressure "Systolic blood pressure (mm Hg)";
cap lab var treated_hypertension "Treated hypertension";
cap lab var patientscore "Patient score";

*
 Key dataset if requested
*;
if "`key'"!="nokey" {;
  keyby row_id;
};

end;
