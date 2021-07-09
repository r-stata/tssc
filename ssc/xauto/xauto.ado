#delim ;
prog def xauto, rclass;
version 10.0;
/*
 Input an extended version of the auto dataset.
 This program requires the SSC package keyby.
*! Author: Roger Newson
*! Date: 12 May 2020
*/

syntax [ , clear ] ;
* Options are passed to sysuse *;

* Key dataset, add new variables and compress *;
qui {;
  sysuse auto, `clear';
  keyby foreign make, fast;
  gene firm=word(make,1);
  lab var firm "Firm";
  lab def odd 0 "Even" 1 "Odd";
  gene byte odd=mod(_n,2);
  lab val odd odd;
  lab var odd "Even or odd sequence number";
  gene byte us=1-foreign;
  lab def us 0 "Non-US" 1 "US";
  lab val us us;
  lab var us "US or non-US model";
  gene double tons=weight/2000;
  lab var tons "Weight (US tons)";
  gene double npm=256/mpg;
  lab var npm "Fuel consumption (nipperkins/mile)";
  label data "1978 Automobile Data extended by Roger Newson";
  compress;
};

* Describe dataset and save results *;
desc, varlist fu;
return add;

end;
