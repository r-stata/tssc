cd "~/Box Sync/PEEQ/Paper #2/Code/Replication/" // Reset to directory
clear
cap log close

/*
This .do file replicates results from 
 von Hippel, Paul T. & Bellows, Laura. (2018).
 "How Much Does Teacher Quality Differ Among Teacher Preparation Programs? Reanalyses from 6 States"
 Economics of Education Review, in press.
 https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2990498
*/ 

// Install _gwtmean and caterpillar from SSC
// Note that caterpillar requires _gwtmean
*ssc install _gwtmean
*ssc install caterpillar

use caterpillar_replication, clear
// The replication dataset includes all states in von Hippel & Bellows (2018), except for MO.

// Graph CIs, Bonferroni-corrected CIs, and null distribution for all NYC teacher preparation programs (TPPs) in math
// Specify graph option to make nice graph 

caterpillar est se tpp if state=="NYC" & subject=="Math" & size=="All", graph center

// Re-graph without the outlier. The Q test becomes non-significant, and the heterogeneity and reliability estimates go to 0.
use caterpillar_replication, clear
caterpillar est se tpp if state=="NYC" & subject=="Math" & size=="All" & est<.4, graph center

// Generate same output (except for graph) for all states, all models, and all SE inflation factors. 
use caterpillar_replication, clear
caterpillar est se tpp, by(state subject size schlfe experienced se_inflation) center saving(tpp_estimates, replace)

save replication_after_caterpillar, replace // The columns added by the caterpillar command will be useful later.

// List output for all TPPs in all states, with FL and LA limited to the most plausible SE inflation factors.
// This replicates Table 2a in von Hippel & Bellows (2018)
use tpp_estimates, clear
list state subject schlfe experienced se_inflation Q df p tau rho if size=="All" ///
 & ( (se_inflation==0 & inlist(state,"NYC","TX","WA")) | (se_inflation==18 & state=="LA") | (se_inflation==100 & state=="FL"))

// Do the same for large TPPs. This replicates Table 3a
list state subject schlfe experienced se_inflation Q df p tau rho if size=="Large" ///
 & ( (se_inflation==0 & inlist(state,"NYC","TX","WA")) | (se_inflation==18 & state=="LA") | (se_inflation==100 & state=="FL"))

/************* This completes our demonstration of the caterpillar command.
               The rest of this file replicates other results in von Hippel & Bellows (2018) using the loneway command,
			    which here compares TPP point estimates in different subjects.
			   */

// First, estimate the heterogeneity and reliability of the estimates for large TPPs in NYC 
use replication_after_caterpillar, clear	
loneway contrast tpp if state=="NYC" & size=="Large" & se_inflation==0
/* The "estimated SD of the TPP effect" is the heterogeneity SD.  */
/* The "intraclass correlation" is the reliability of individual TPP estimates. */

// Now do the same thing for all states, and for both large and small TPPs.
// Use a loop, and get estimates from the r() results.
matrix table2b = J(4,3,.)
matrix table3b = J(4,3,.)

local i = 1
local states TX WA NYC LA
foreach s in `states' {
	foreach t in All Large { 
		qui count if state=="`s'" & size=="`t'" & se_inflation==0 
		if r(N)!=0 {
			loneway contrast tpp if state=="`s'" & size=="`t'" & se_inflation==0
			if "All"=="`t'" {
				matrix table2b[`i',1] = `r(sd_b)'
				matrix table2b[`i',2] = `r(rho)'
				matrix table2b[`i',3] = 2*(1-normal(abs(`r(rho)'/`r(se)')))
			}
			else {
				matrix table3b[`i',1] = `r(sd_b)'
				matrix table3b[`i',2] = `r(rho)'
				matrix table3b[`i',3] = 2*(1-normal(abs(`r(rho)'/`r(se)')))
			}
		}
	}
	local i = `i' + 1
}

foreach y in table2b table3b {
	matrix rownames `y' = `states' 
	matrix colnames `y' = heterogeneity_SD reliability p
}

// Replicate Table 2b in von Hippel & Bellows (2018)
matrix list table2b, format(%9.2f)

// Replicate Table 3b
matrix list table3b, format(%9.2f)


