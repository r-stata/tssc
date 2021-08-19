/***

Title
-----

{phang}{cmd:calc4persuasio} {hline 2} Calculate the effect of persuasion when 
information on Pr(y=1|z) and optimally Pr(t=1|z) for each z=0,1 is available

Syntax
------

> {cmd:calc4persuasio} _y1_ _y0_ _e1_ _e0_

Description
-----------

__calc4persuasio__ calculates the effect of persuasion when 
information on Pr(y=1|z) and optimally Pr(t=1|z) for each z=0,1 is available.
The inputs to this command are _y1_, _y0_, _e1_ and _e0_. They are all scalars
and refer to the estimates of Pr({it:y}=1|{it:z}=1), Pr({it:y}=1|{it:z}=0),
Pr({it:t}=1|{it:z}=1), and Pr({it:t}=1|{it:z}=0), where ({it:y}, {it:t}, {it:z})
are binary outcomes, binary treatments, and binary instruments, respectively.  

The outputs of this command are the lower and upper bounds on the average persuasion rate (APR) 
as well as the lower and upper bounds on the local persuasion rate (LPR).   


There are two cases: (i) all four inputs are given and (ii) only _y1_ and _y0_ are given.

In case (i), __calc4persuasio__ provides the following bounds.

- The lower bound on the APR is defined by 

{p 8 8 2} (_y1_ - _y0_)/(1 - _y0_).

- The upper bound on the APR is defined by 

{p 8 8 2} {min(1, _y1_ + 1 - _e1_) - max(0, _y0_ - _e0_)}/{1 - max(0, _y0_ - _e0_)}.	
	
- The lower bound on the LPR is defined by 

{p 8 8 2} max{(_y1_ - _y0_)/(1 - _y0_), (_y1_ - _y0_)/(_e1_ - _e0_)}.

- The upper bound on the LPR is simply 1.

In case (ii), __calc4persuasio__ provides the following bounds.	

- The lower bound on both the APR and LPR is defined by 

{p 8 8 2} (_y1_ - _y0_)/(1 - _y0_).
		
- The upper bound on both the APR and LPR is simply 1.		
		
Remarks
-------

The purpose of __calc4persuasio__ is to provide bound estimates of both average and local persuasion rates
when summary statistics on Pr(y=1|z) and/or Pr(t=1|z) for each z=0,1 are available.   

Examples 
--------

We first call the dataset included in the package.

		. use GKB, clear

We now compute summary statistics.

{p 6} . foreach var in voteddem_all readsome {  {p_end}
{p 10}			foreach treat in 0 1 {          {p_end}
{p 12}				sum `var' if post == `treat'     {p_end}
{p 12}				scalar `var'_`treat' = r(mean)   {p_end}
{p 10}				} {p_end}
{p 8}		  } {p_end}

Then, we calculate the bound estimates on the APR and LPR.

		. calc4persuasio voteddem_all_1 voteddem_all_0 readsome_1 readsome_0
		
Finally, we compare this with the following.		

		. calc4persuasio voteddem_all_1 voteddem_all_0

Stored results
--------------

### Scalars

> __r(apr_lb)__: estimate of the lower bound on the average persuasion rate 

> __r(apr_ub)__: estimate of the upper bound on the average persuasion rate

> __r(lpr_lb)__: estimate of the lower bound on the local persuasion rate 

> __r(lpr_ub)__: estimate of the upper bound on the local persuasion rate

Authors
-------

Sung Jae Jun, Penn State University, <sjun@psu.edu> 

Sokbae Lee, Columbia University, <sl3841@columbia.edu>

License
-------

GPL-3

References
----------

Sung Jae Jun and Sokbae Lee (2019), 
Identifying the Effect of Persuasion, 
[arXiv:1812.02276 [econ.EM]](https://arxiv.org/abs/1812.02276) 

Version
-------

0.1.0 30 January 2021

***/
capture program drop calc4persuasio
program calc4persuasio, rclass

	version 14.2
    args y1 y0 e1 e0
		
	* Displaying results
	display " "
    display as text "{hline 62}"
    display "{bf:calc4persuasio:} Calculate the effect of persuasion when info."
		display "   on Pr(y=1|z) and/or Pr(t=1|z) for each z=0,1 is available"
		display " "
		

	tempname lb ub ub_term1 ub_term0 ub_num ub_den late llb

	* if both e1 and e0 are non-missing
	if "`e1'" != "" & "`e0'" != "" {
	
		scalar `lb' = (`y1'-`y0')/(1-`y0')

		scalar `ub_term1' = `y1' + 1 - `e1'
		scalar `ub_term0' = `y0' - `e0'
		scalar `ub_num' = min(1,`ub_term1') - max(0,`ub_term0')
		scalar `ub_den' = 1 - max(0,`ub_term0')
		scalar `ub' = `ub_num'/`ub_den'
	
		scalar `late' = (`y1'-`y0')/(`e1'-`e0')
		scalar `llb' = max(`lb',`late')
	
		return scalar apr_lb = `lb'
		return scalar apr_ub = `ub'
		return scalar lpr_lb = `llb'
		return scalar lpr_ub = 1
		
		display as text "{hline 25}{c TT}{hline 37}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(26) " Lower Bound " /*
		*/ _col(45) " Upper Bound " 
        display as text "{hline 25}{c +}{hline 37}"
	    
		display as text %24s "Average Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(28) %8.0g `lb' " " /*
		*/ _col(47) %8.0g `ub' " " 
		    
		display as text %24s "Local Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(28) %8.0g `llb' " " /*
		*/ _col(47) %8.0g 1 " " 
		
		display as text "{hline 25}{c BT}{hline 37}"
		display ""
	}
	
	* if both e1 and e0 are non-missing
	if "`e1'" == "" | "`e0'" == "" {
	
		scalar `lb' = (`y1'-`y0')/(1-`y0')
	
		return scalar apr_lb = `lb'
		return scalar apr_ub = 1
		
		display as text "{hline 25}{c TT}{hline 37}"

		display as text %24s  "Parameter" " {c |}" /*
		*/ _col(26) " Lower Bound " /*
		*/ _col(45) " Upper Bound " 
        display as text "{hline 25}{c +}{hline 37}"
	    
		display as text %24s "Average Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(28) %8.0g `lb' " " /*
		*/ _col(47) %8.0g 1 " " 
		
		display as text %24s "Local Persuasion Rate" " {c |}" /*
		*/ as result /*
		*/ _col(28) %8.0g `lb' " " /*
		*/ _col(47) %8.0g 1 " " 
		   		
		display as text "{hline 25}{c BT}{hline 37}"

		display " "
		display "Note: Exposure rates, Pr(t=1|z) for z=0,1, are missing."
		display " "
		
	}
	
end	
