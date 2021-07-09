#delim ;
prog def cprd_patientobs;
version 13.0;
*
 Add patient observation window variables
 to a patient dataset in memory
 using a practice dataset on disk.
*!Author: Roger Newson
*!Date: 23 March 2016
*;

syntax using [ , ACCept ];
/*
 accept specifies that observation window will only be calculated
   for acceptable patients.
*/

*
 Add in practice variables
 and initialise observation window calculabiility
*;
addinby pracid `using', unm(keep) keep(pracid lcd_n uts_n) gene(obscalc) fast;
replace obscalc = obscalc==3;
foreach X of var ebdate_n frd_n crd_n lcd_n uts_n {;
  replace obscalc = obscalc & !missing(`X');
};
if "`accept'"!="" {;
  replace obscalc = obscalc & accept==1;
};
compress obscalc;
lab def obscalc 0 "Uncalculated" 1 "Calculated";
lab val obscalc obscalc;
lab var obscalc "Observation window calculated";
desc obscalc, fu;
lablist obscalc, noun var;

*
 Create start and end dates
 and entry and exit status
*;
gene byte entrystat=0 if obscalc;
gene long entrydate=uts_n if obscalc;
replace entrystat=1 if obscalc & crd_n>=entrydate;
replace entrydate=crd_n if obscalc & crd_n>=entrydate;
replace entrystat=2 if obscalc & ebdate_n>=entrydate;
replace entrydate=ebdate_n if obscalc & ebdate_n>=entrydate;
compress entrystat entrydate;
lab def entrystat 0 "First UTS date" 1 "Patient joined practice" 2 "Patient born";
lab val entrystat entrystat;
lab var entrystat "Entry status to observation by CPRD";
format entrydate %tdCCYY/NN/DD;
lab var entrydate "Date of entry to observation by CPRD";
gene byte exitstat=0 if obscalc;
gene long exitdate=lcd_n if obscalc;
replace exitstat=1 if obscalc & !missing(tod_n) & tod_n<=exitdate;
replace exitdate=tod_n if obscalc & !missing(tod_n) & tod_n<=exitdate;
replace exitstat=2 if obscalc & !missing(deathdate_n) & deathdate_n<=exitdate;
replace exitdate=deathdate_n if obscalc & !missing(deathdate_n) & deathdate_n<=exitdate;
compress exitstat exitdate;
lab def exitstat 0 "Last collection date" 1 "Patient left practice" 2 "Patient died";
lab val exitstat exitstat;
lab var exitstat "Exit status from observation by CPRD";
format exitdate %tdCCYY/NN/DD;
lab var exitdate "Date of exit from observation by CPRD";
desc entrystat exitstat entrydate exitdate, fu;
lablist entrystat exitstat, noun var;

* Drop unwanted practice-specific variables *;
drop lcd_n uts_n;

*
 Create observation status
*;
gene byte observed = obscalc & entrydate<=exitdate;
lab def observed 0 "Unobserved" 1 "Observed";
lab val observed observed;
lab var observed "Patient observed by CPRD";
desc observed, fu;
lablist observed, noun var;

*
 Describe all variables
*;
desc, fu;

end;
