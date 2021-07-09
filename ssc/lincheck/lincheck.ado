*! version 2.0 <25Feb2005>
*! implements Hosmer & Lemeshow's method of quartile design variables to check linearity in the link function of a continuous covariate
*! author: Alex Gamma, Zurich (gamma@bli.unizh.ch)


#delimit ;
version 8;
capture program drop lincheck;

program define lincheck;

tempvar med b q;
capture clonevar `q'=quartile; /* should a var named "quartile" already exist in the data set, temporarily save it*/
capture drop quartile;

local cmd "`0'";		/*extract the user's estimation command*/
if "`cmd'"=="" {;
	display as error "no argument given; {cmd:lincheck} must be followed by an estimation command";
	exit;
}; 

if substr("`cmd'",1,2)=="xi" {;
	local xi "";
	gettoken dump vl : cmd, parse(":");
	gettoken dump vl : vl, parse(":");
	gettoken dump vl : vl; 			/* "xi...:" and command-name are now stripped off of user input */
};
else if word("`cmd'",1)=="by" | word("`cmd'",1)=="bysort" {;
	display as error "by and bysort not allowed";
	exit;
};
else {;
	local xi "xi:";
	gettoken dump vl : cmd; 			/* "xi...:" and command-name are now stripped off of user input */
};

quietly `cmd';

capture local preds: colnames e(V); 						/*get names of predictors of previous regression from variance-covariance matrix */
if _rc > 0 {;
	display as error "matrix e(V) not found: the estimation command you typed after {cmd:lincheck} is not suitable for {cmd:lincheck}";
	exit;
};
local contvar = word("`preds'",1);		/*extracting from e(V) the continuous predictor that is to be tested for linearity */

if word("`vl'",1)=="`e(depvar)'" {;
	local contvar2=word("`vl'",2); 		/* contvar2 contains the first predictor variable from the user input */
};
else {;
	local contvar2=word("`vl'",1);		/* contvar2 contains the first predictor variable from the user input */
};

/* check if first predictor form e(V) matches first predictor as extracted from user input. if not, the predictor has been dropped from the model */
if "`contvar'"!="`contvar2'" display as error "Error: either {cmd:lincheck} does not work with the specified estimation command, or the continous predictor `contvar2' has been dropped
 from the model, in which case {cmd:lincheck} will proceed using the next available variable (`contvar'), although this is most likely not what you wanted.";

quietly xtile quartile =`contvar',nq(4);
quietly sum `contvar',d;
quietly bysort quartile: egen `med'=median(`contvar'); 			/* median of quartiles */

local newcmd = subinword("`cmd'","`contvar'","i.quartile",1);		/* replacing the continuous predictor with the quartile dummies */
display as input "`xi' `newcmd'"; 
`xi' `newcmd'; 												/* estimating model with quartile dummies replacing continuous predictor */


/* regression coefficients for quartile */
quietly {;
		gen `b'=0 if quartile ==1;
		capture replace `b'=_b[_Iquartile_2] if quartile ==2;
		capture replace `b'=_b[_Iquartile_3] if quartile ==3;			/* if any of the quartile dummies is dropped, don't plot it */
		capture replace `b'=_b[_Iquartile_4] if quartile ==4;
};

twoway (connected `b' `med', sort),ytitle("coefficient") xtitle("`contvar'"); 		/* plot coefs vs. quartile medians */

capture drop _Iquartile*;
drop quartile;
capture clonevar quartile=`q'; /* in case the var "quartile" already existed, restore it*/

end;


