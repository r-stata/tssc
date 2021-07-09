*! PPML (Panel) Structural Gravity Estimation, by Tom Zylkin
*! Department of Economics, National University of Singapore
*! Example do file, April, 2017
*!
*! Suggested citation: Larch, Wanner, Yotov, & Zylkin (2017): 
*! "The Currency Union Effect: A PPML Re-assessment with High-dimensional Fixed Effects"
*! Drexel University School of Economics Working Paper 2017-07

clear all
global this_dir   "D:\Tom (local)\PPML experiment"

cd "$this_dir"

cap set matsize 800
cap set matsize 11000
cap set maxvar 32000


use EXAMPLE_TRADE_FTA_DATA, clear
// Trade between 35 countries for the years 1986 - 2004, every four years.
// Broken out by manufacturing, non-manufacturing, as well as total trade.

// Sources:
//  - Trade: UN COMTRADE
// 	- FTAs:  NSF-Kellogg (Baier & Bergstrand) database
//  - "gravity" variables: CEPII (Head & Mayer) gravity data

// I use a small sample (35 countries) so that verifying the result using glm 
// can be done in a reasonable amount of time (here, ~5-10 minutes.)


// solve for the average partial effect of an FTA on total trade
ppml_panel_sg trade fta if category == "TOTAL", ex(isoexp) im(isoimp) y(year)

// The equivalent estimation code using glm is:
cap egen exp_time = group(isoexp year)
cap egen imp_time = group(isoimp year)
cap egen pair     = group(isoexp isoimp)

xi i.exp_time i.imp_time i.pair

qui glm trade _Iexp_time* _Iimp_time* _Ipair* fta if category == "TOTAL", family(poisson) diff iter(25) cluster(pair)
est save GLM_RESULT, replace

est use GLM_RESULT
esttab, keep(fta) se stats(ll N)


/* or, if "ppml" is installed:
xi: ppml trade i.exp_time i.imp_time i.pair fta if category == "TOTAL", diff iter(25) cluster(pair)
est tab, keep(fta) se ll
*/

// some options:

// use symmetric pair fixed effects
ppml_panel_sg trade fta if category == "TOTAL", ex(isoexp) im(isoimp) y(year) sym

// add time trends
ppml_panel_sg trade fta if category == "TOTAL", ex(isoexp) im(isoimp) y(year) trend

// multi-way clustering (1): exporter, importer, year
ppml_panel_sg trade fta if category == "TOTAL", ex(isoexp) im(isoimp) y(year) multi

// multi-way clustering (2): user-specified
cap egen pair     = group(isoexp isoimp)
ppml_panel_sg trade fta if category == "TOTAL", ex(isoexp) im(isoimp) y(year) cluster(pair year)

// manufacturing trade only
ppml_panel_sg trade fta if category == "MANUF", ex(isoexp) im(isoimp) y(year)

// non-manufacturing trade only
ppml_panel_sg trade fta if category == "NONMANUF", ex(isoexp) im(isoimp) y(year)

// Test if FTAs have had a larger effect on non-manufacturing trade vs manufacturing trade 
// (requires including an "industry" code)
gen fta_NONMANUF = fta * (category == "NONMANUF")
ppml_panel_sg trade fta* if category != "TOTAL", ex(isoexp) im(isoimp) ind(category) y(year)


// Estimating more traditional gravity variables (using nopair), year 2000 only:
ppml_panel_sg trade ln_dist colony contig comlang_off comleg fta if category == "TOTAL" & year == 2000, ex(isoexp) im(isoimp) y(year) nopair 

// The equivalent estimation code using glm is:
cap egen exp_time = group(isoexp year)
cap egen imp_time = group(isoimp year)
cap egen pair     = group(isoexp isoimp)
xi: glm trade i.exp_time i.imp_time ln_dist colony contig comlang_off comleg fta if category == "TOTAL" & year == 2000, diff iter(25) family(poisson) ro

// for one year only, "multiway" defaults to clustering on <exporter importer>
ppml_panel_sg trade ln_dist colony contig comlang_off comleg fta if category == "TOTAL" & year == 2000, ex(isoexp) im(isoimp) y(year) nopair multi



// Notes on some common issues:

** 1. Collinearity.  

*Consider the following regression:
ppml_panel_sg trade fta ln_distw if category == "TOTAL", ex(isoexp) im(isoimp) y(year)

* Note that ln_distw is a pairwise variable that does not vary over time. Thus, it is collinear
* with the implied "pair" fixed effects. If you want to estimate the effects of time-invariant bilateral
* regressors such as ln_distw, use the -nopair- option.


** 2a. Non-existence.

* Instead of ln_dist, consider now the following variable

gen test = ln_distw * (trade > 0) + uniform() * (trade == 0)

* which is a variation of ln_dist that will no longer be invariant over time within pairs.
* However, it will still be collinear with the implied set of pair fixed effects over the subsample where trade>0.
* Santos Silva & Tenreyro (2010) refer to this as a "non-existence" issue: while it is not technically a "collinearity" problem, 
* it is still possible that estimates from this regression will not actually exist. 

* Thus, ppml_panel_sg checks and excludes cases like this as well:

ppml_panel_sg trade fta test if category == "TOTAL", ex(isoexp) im(isoimp) y(year)


** 2b. Dropping observations that are perfectly predicted by exluded regressors

* by default, ppml_panel_sg drops all y=0 observations that are perfectly predicted by
* excluded regressors. (This is the same default behavior as in -ppml-.)

* Example: a dummy which is 1 for y=0, 0 otherwise

gen test2 = (trade == 0)
ppml_panel_sg trade fta test2 if category == "TOTAL", ex(isoexp) im(isoimp) y(year)

* To prevent these observations from being dropped, use the "keep" option

ppml_panel_sg trade fta test2 if category == "TOTAL", ex(isoexp) im(isoimp) y(year) keep


** 3. Multiple trade flows for the same pair in a given year.

* Note that there are 3 industry category in the current data ("MANUF", "NONMANUF", and "TOTAL").

* Suppose I forgot that the data is structured this way and went ahead with the following:

ppml_panel_sg trade fta, ex(isoexp) im(isoimp) y(year)			// (note: I have forgotten the "ind" option here and have not used an "if" statement)

* This will produce an error saying that the ID vars provided do not uniquely describe the data.
* The error will also remind you that, if this really is the specification you intended, ie,
* without exploiting industry-level variation, you can usually collapse the data to get the same result.

* To see this, compare
cap egen exp_time = group(isoexp year)
cap egen imp_time = group(isoimp year)
cap egen pair     = group(isoexp isoimp)
xi: glm trade i.exp_time i.imp_time ln_dist colony contig comlang_off comleg fta if year == 2000, diff iter(25) family(poisson) cluster(pair)

* with the original results from lines 81 and 88, which only used the "TOTAL" category.





