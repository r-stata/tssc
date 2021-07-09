{smcl}
{* 15apr2017}{...}
{cmd:help rangejoin}
{hline}

{title:Title}

{phang}
{cmd:rangejoin} {hline 2} Form pairwise combinations if a key variable is within range


{title:Syntax}

{p 8 17 2}
{cmd:rangejoin} 
{it:keyvar low high}
{cmd:using} 
{it:{help filename:using_dataset}}
[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opth by(varlist)}}pairwise combinations occur within groups{p_end}
{synopt:{opth k:eepusing(varlist)}}variables to keep from 
the {it:{help filename:using_dataset}}{p_end}
{synopt:{opth p:refix(strings:string)} }a stub used as a prefix when 
renaming variables from the {it:{help filename:using_dataset}}{p_end}
{synopt:{opth s:uffix(strings:string)}}a stub used as a suffix when 
renaming variables from the {it:{help filename:using_dataset}}{p_end}
{synopt:{opt a:ll}}all variables from the {it:{help filename:using_dataset}} will be renamed{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
This version of {cmd:rangejoin} requires version 1.1.0 
of {stata ssc des rangestat:rangestat}. 
Click {stata ssc install rangestat:here to install} {cmd:rangestat}
from SSC.

{pstd}
{cmd:rangejoin} forms pairwise combinations of observations
in memory and observations from the {it:{help filename:using_dataset}} when
the value of {it:keyvar} in the {it:{help filename:using_dataset}}
is within the range specified by {it:low} and {it:high} in the data in memory.

{pstd}
{it:keyvar} is a numeric variable in the {it:{help filename:using_dataset}}.

{pstd}
{it:low} or {it:high} can be specified using a numeric variable in the data 
in memory.
Alternatively, {it:low} or {it:high} can be specified using 
a {it:#} (a number in Stata parlance).
If a {it:#} is used and there is a numeric variable 
with the same name as {it:keyvar} in the data in memory, 
the bound for each observation is computed by adding {it:#} to {it:keyvar}.
If a {it:#} is used and {it:keyvar} does not exist in the data in memory,
the {it:#} is used as the bound.
Finally, you can specify {it:low} or {it:high} using a
{help missing:system missing value}, in which case the bound for
each observation will be missing.

{pstd}
{cmd:rangejoin} applies the same rules as {help inrange()} for missing bounds:
if the lower bound is missing, observations will match up to and including
the value of {it:high}.
If both {it:low} and {it:high} are missing, all observations will match.
Note that the treatment of missing values for {it:low} and {it:high}
differs in this version of {cmd:rangejoin} and
this may require that previous code be adapted.
Without bounds, {cmd:rangejoin} forms the same pairwise combinations
that {help cross} would (or {help joinby} if the {opth by(varlist)} option is used
to restrict the matching by group).

{pstd}
Observations with missing values for {it:keyvar} in the {it:{help filename:using_dataset}}
will never be considered in range and as such will never match.
To prevent unintentional matches, 
if there is a variable of the same name as {it:keyvar}
in the data in memory, no match
will occur if its value is missing for the current observation
(since {it:low} or {it:high} will most likely be computed
relative to the value of {it:keyvar}, which would lead to missing
bounds).

{pstd}
{cmd:rangejoin} will not try to find matches for
observations where {it:low} > {it:high}.

{pstd}
The results will include all variables from the {it:{help filename:using_dataset}}
unless the {opth k:eepusing(varlist)} is specified.
Any variable from the {it:{help filename:using_dataset}} will be renamed 
if it also exists in the data in memory. 
Use the {opt a:ll} option if all variables from the {it:{help filename:using_dataset}}
are to be renamed.
When renaming variables, the 
{opth p:refix(strings:string)} and {opth s:uffix(string)} stubs are both used. 
If neither
is specified, the default is to use {cmd:suffix(_U)}.
Variables specified in {opth by(varlist)} must exist both in the data in memory
and in the {it:{help filename:using_dataset}}.


{title:Example: Finding houses within the client's budget}

{pstd}
In the following example, you have a list of houses on the market
and the current asking price.
You also have clients looking for
a house and their price range.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - house_cross}{...}
	clear
	input house asking
	1 111
	2 222
	3 333
	4 444
	5 555
	6 666
	end
	save "house_asking.dta"
	
	clear
	input str5 name low high
	Peter 300 500
	Paul  400 600
	Mary  600 700
	end

	rangejoin asking low high using "house_asking.dta"
	sort name house
	list, sepby(name)
{* erase "house_asking.dta"}{...}
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangejoin_run house_cross using rangejoin.sthlp:click to run})}

{pstd}
Do this again, this time matching
clients to houses in the same zip code.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - house_joinby}{...}
	clear
	input house asking zip
	1 111 48101
	2 222 48101
	3 333 48101
	4 444 48101
	5 555 48103
	6 666 48103
	end
	save "house_asking.dta"
	
	clear
	input str5 name low high zip
	Peter 300 500 48103
	Paul  400 600 48103
	Mary  600 700 48101
	end

	rangejoin asking low high using "house_asking.dta", by(zip)
	sort name house
	list, sepby(name)
{* erase "house_asking.dta"}{...}
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangejoin_run house_joinby using rangejoin.sthlp:click to run})}

{pstd}
If no house falls within the client's price range, the observation
remains but with missing values for variables from the using dataset.


{title:Match domestic cars to similarly priced foreign cars with the same repair record}

{pstd}
Using the iconic Stata auto dataset, we match each domestic
car to similarly priced foreign cars with the same repair record.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - similar_car}{...}
	sysuse auto, clear
	keep if foreign
	save "foreign_cars.dta"
	sort rep78 price
	list make price rep78, sepby(rep78)
	
	sysuse auto, clear
	drop if foreign
	rangejoin price -1000 1000 using "foreign_cars.dta", by(rep78)
	gen pdiff = price - price_U
	sort rep78 make price_U
	list make price rep78 make_U price_U pdiff, sepby(rep78 make)
{* erase "foreign_cars.dta"}{...}
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangejoin_run similar_car using rangejoin.sthlp:click to run})}

{pstd}
Note that if you do this to calculate some statistic using the joined
data and then reduce (collapse) to the original observations, 
you are probably better off using {stata ssc des rangestat:rangestat} directly. 


{title:Certification and efficiency considerations}

{pstd}
{cmd:rangejoin} leverages the power of {cmd:rangestat} to quickly
determine, for each observation in memory,
the set of observations in the {it:{help filename:using_dataset}}
that are in range.
Once this is known, each observation in the data in memory is
expanded by the number of observations it matched in the {it:{help filename:using_dataset}}.
From there, the problem reduces to a m:1 {help merge}.

{pstd}
You can replicate {cmd:rangejoin} results using {help cross}
or {help joinby} but this requires
forming all pairwise combinations (within groups if you are using {help joinby})
and then dropping observations outside the
desired interval bounds.

{pstd}
To demonstrate both approaches,
the following creates a dataset with a 10% ratio of cases to controls
in 5 categories. 
It also saves the controls in a separate dataset.
For added flexibility, the code lets you choose the number
of observations. 
If this is the first time, start with 10,000 observations.
Note that you can't go much higher if you plan to run the
example using {cmd:joinby} as the total number of pairwise 
combinations grows exponentially.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - efficiency_data}{...}
	clear
	set seed 41234
	dis "How many observations? " _request(nobs)
	set obs $nobs
	gen id = _n
	gen case = runiform() < .1
	gen category = int(runiform() * 5) + 1
	gen date = mdy(1,1,2016) + runiform() * 365
	format %td date
	sum, format
	tab case
	save "project_data.dta", replace
	keep if case==0
	drop case
	save "control_data.dta", replace
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangejoin_run efficiency_data using rangejoin.sthlp:click to run})}

{pstd}
Now match each case with controls in the same category if the date of 
the control is within +/- 1 day of the case date. 

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - efficiency_rs}{...}
	use if case using "project_data.dta", clear
	
	rangejoin date -1 1 using "control_data.dta", by(category) suffix(_ctr)
	
	drop if mi(id_ctr)  // drop cases that did not find a match
	sort id id_ctr
	save "rangejoin_results.dta", replace
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangejoin_run efficiency_rs using rangejoin.sthlp:click to run})}

{pstd}
Repeat the same task using {cmd:joinby}. There's more code to write because
you must rename variables to avoid name conflicts when joining the data.

{space 8}{hline 27} {it:example do-file content} {hline 27}
{cmd}{...}
{* example_start - efficiency_joinby}{...}
	use "control_data.dta", clear
	rename id id_ctr
	rename date date_ctr
	tempfile controls
	save "`controls'"
	
	use if case using "project_data.dta"
	
	joinby category using "`controls'"
	keep if inrange(date_ctr, date-1, date+1)
		
	* confirm that we match exactly the same controls as rangejoin
	sort id id_ctr
	cf _all using "rangejoin_results.dta", all
{* example_end}{...}
{txt}{...}
{space 8}{hline 80}
{space 8}{it:({stata rangejoin_run efficiency_joinby using rangejoin.sthlp:click to run})}


{title:References}

{pstd}
Cox, N.J. 2007. {browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0033":Events in intervals.} 
{it:Stata Journal} 7: 440{c -}443. 

{pstd}
Cox, N.J. 2011. 
{browse "http://www.stata-journal.com/sjpdf.html?articlenum=dm0055":Compared with ....} 
{it:Stata Journal} 11: 305{c -}314. 

{pstd}
Cox, N.J. 2014. 
{browse "http://www.stata-journal.com/article.html?article=dm0075":Self and others.} 
{it:Stata Journal} 14: 432{c -}444. 


{title:Acknowledgements}

{pstd} 
Thanks to Clyde Schechter for kindly showing us an example 
where {cmd:rangejoin} would generate an overflow when computing
interval bounds if {it:keyvar + #} could not be stored in a
variable of {it:keyvar}'s data type. 
This was most likely to bite when {it:keyvar} was a byte.
Observations with the overflow would be excluded from the sample.
This report led to a review of {cmd:rangejoin}'s handling of missing
interval bounds and it was decided to follow the
same rules as {help inrange()} and allow missing bounds.


{title:Authors}

{pstd}Robert Picard{p_end}
{pstd}picard@netbox.com{p_end}


{title:Also see}

{psee}
SSC:  
{stata "ssc desc rangestat":rangestat}, 
{stata "ssc desc tsegen":tsegen}
{p_end}

{psee}
Others:  
{stata "search vlookup, all":vlookup}
{p_end}

