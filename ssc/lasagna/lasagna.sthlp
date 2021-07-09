{smcl}
{* *! version 1.0  10oct2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{title:Title}

{phang}
{bf:lasagna.ado} {hline 2} Produces lasagna plots as described by Swihart, Caffo et al (2010): https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2937254/


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:lasagna}
[{varlist}]
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}

{pstd}
{cmd:lasagna} Creates lasagna plots for the variables in (varlist}, assigning one plot row to each group present in (over()). 


{marker options}{...}
{title:Options}
 
{phang}
{opt over} Creates a single plot row (color bar) for each level of the string variable specified in over().

{phang}
{opt levels} specifies the number of color groups used to display Y values. 

{marker remarks}{...}
{title:Remarks}

{pstd}
Accepts options permitted by -twoway contour-, with the exception of ylabel definitions, which are created by the strings present in the over() variable
and thus not available for manipulation by the user. 

For graphs with >25 over() categories or large labels, ysize() may be used to extend the height of the graph region. 

{marker examples}{...}
{title:Examples}

use http://www.stata-press.com/data/r15/nlswork.dta, clear

keep if inrange(year,82,88) 

bys idcode: gen fips=runiformint(1, 56) if _n==1

bys idcode: replace fips=fips[1]

collapse (mean) ln_wage, by(fips year) 
 
label define state 1 "ALABAMA"  2 "ALASKA"  4 "ARIZONA"  5 "ARKANSAS"  6 "CALIFORNIA"  8 "COLORADO"  9 "CONNECTICUT"  10 "DELAWARE"  ///
 11 "DISTRICT OF COLUMBIA"  12 "FLORIDA"  13 "GEORGIA"  15 "HAWAII"  16 "IDAHO"  17 "ILLINOIS"  18 "INDIANA"  19 "IOWA"  20 "KANSAS" ///
 21 "KENTUCKY"  22 "LOUISIANA"  23 "MAINE"  24 "MARYLAND"  25 "MASSACHUSETTS"  26 "MICHIGAN"  27 "MINNESOTA"  28 "MISSISSIPPI"  29 "MISSOURI" ///
 30 "MONTANA"  31 "NEBRASKA"  32 "NEVADA"  33 "NEW HAMPSHIRE"  34 "NEW JERSEY"  35 "NEW MEXICO"  36 "NEW YORK"  37 "NORTH CAROLINA" ///
 38 "NORTH DAKOTA"  39 "OHIO"  40 "OKLAHOMA"  41 "OREGON"  42 "PENNSYLVANIA"  44 "RHODE ISLAND"  45 "SOUTH CAROLINA"  46 "SOUTH DAKOTA" ///
 47 "TENNESSEE"  48 "TEXAS"  49 "UTAH"  50 "VERMONT"  51 "VIRGINIA"  53 "WASHINGTON"  54 "WEST VIRGINIA"  55 "WISCONSIN"  56 "WYOMING"  

label values fips state
 
decode fips, gen(name) 

lasagna ln_wage year, over(name) ylabel(,labsize(tiny)) ysize(10) levels(3) 
 
