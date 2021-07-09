#delim ;
prog def qrisk2export;
version 13.0;
/*
 Export a qrisk2 input or output dataset.
*!Author: Roger Newson
*!Date: 14 September 2016
*/

syntax using [if] [in] [, REPLACE ];
/*
 replace specifies that any existing file of the same name will be replaced.
*/

*
 Export dataset
*;
export delimited row_id age sex ethnicity rheumatoid_arthritis atrial_fibrillation chronic_renal_disease diabetes_category history_of_cvd smoke_cat family_history_of_chd
  townsend_score postcode
  body_mass_index cholesterol_hdl_ratio systolic_blood_pressure treated_hypertension
 `using' `if' `in', delim(",") nolabel `replace';

end;
