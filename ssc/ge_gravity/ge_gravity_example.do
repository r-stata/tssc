*! Simple program for solving a GE gravity model, by Tom Zylkin
*! Department of Economics, University of Richmond
*! Example .do file, March 2019
*!
*! Suggested citation: Baier, Yotov, and Zylkin (2019): 
*! "On the Widely Differing Effects of Free Trade Agreements: Lessons from Twenty Years of Trade Integration"
*! Journal of International Economics, 116, 206-226.

clear all
*global this_dir = "C:\Users\ztom\Google Drive\TOM LOCAL\PPML experiment\GE_gravity"
global this_dir = "E:\Google drive\TOM LOCAL\PPML experiment\GE_gravity"

cd "$this_dir"

cap set matsize 800
cap set matsize 11000
cap set maxvar 32000


use GE_gravity_example_data, clear
* - Aggregate trade between 44 countries observed over 2000-2014, using years 2000, 2005, 2010, and 2014.
* - Trade and domestic sales data aggregated from the WIOD database (see the "illustrated user guide" published by Timmer, Dietzenbacher, Los, Stehrer, and de Vries, Review of International Economics, 2015.)
* - Information on FTAs is taken from the NSF-Kellogg database maintained by Scott Baier and Jeff Bergstrand.


** 1. Obtain "partial" estimates of the effects of EU enlargements on trade using a three-way gravity specification
ppmlhdfe trade eu_enlargement other_fta if exporter != importer, a(expcode#year impcode#year expcode#impcode) cluster(expcode#impcode) 

// NOTE: Yotov, Piermartini, Monteiro, and Larch (2016) describe some applications in which including the "exporter==importer" term in this step might be appealing.


** 2. Obtain GE estimates of the effects of the effects of EU enlargements on trade flows and welfare (as of 2000), using a simple Armington-CES gravity model
sort exporter importer year
by exporter importer: gen new_eu_pair = (eu_enlargement[_N]-eu_enlargement[1])                    // captures the new EU pairs created during the period
by exporter importer: gen eu_effect = _b[eu_enlargement] * new_eu_pair                            // equals _b[eu_enlargement] for new EU pairs, 0 otherwise.
ge_gravity exporter importer trade eu_effect if year==2000, theta(4) gen_w(w_eu) gen_X(X_eu)

// NOTE: The new variable "w_eu" now gives the _exporting_ country's change in welfare. 


** The "multiplicative" option varies how trade imbalances are treated.
ge_gravity exporter importer trade eu_effect if year==2000, theta(4) gen_w(w_mult) gen_X(X_mult) mult


** Some sample code for bootstrap GE confidence intervals (initial estimates bootstrapped by randonly drawing pairs with replacement)

// generate bootstrapped gravity estimates (saved as bootpartials.dta)
set seed 1234
egen pair = group(expcode impcode)
bootstrap, reps(200) cluster(pair) saving(bootpartials, replace): ppmlhdfe trade eu_enlargement other_fta if exporter != importer, a(expcode#year impcode#year expcode#impcode) 

// create a matrix with gravity estimates
append using bootpartials
mkmat _b*, matrix(bootpartials) nomissing
drop _b*
drop if missing(expcode)

// obtained bootstrapped GE results based on bootstrapped betas
gen beta = 1
forvalues b = 1(1)200{
	replace beta = bootpartials[`b',1] * new_eu_pair  // <- Note that _b[eu_enlargement] is saved in the first column of "bootpartials".
	ge_gravity exporter importer trade eu_effect if year==2000, theta(4) gen_w(w_boot`b') gen_X(X_boot`b')
}


// NOTE: the above procedure follows how most researchers would likely implement a bootstrap in this situation.

// However, there are some conceptual issues with this approach that are discussed here: 
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1479492-gravity-analysis-using-ppml_panel_sg-and-bootstrap-se?p=1479547#post1479547




