{smcl}
{* *! version 1.0 14 Apr 2021}{...}

{title:Title}
{phang}
{bf: xtglsr} {hline 2} User written {bf: post estimation } command {bf: xtglsr}, mnemonic for {bf: xtglsr[obust]}: 
Calculates robust, or cluster-robust variance post 
{bf:[XT] xtgls -- Fit panel-data models by using GLS}.   
Requires Stata 11. Written by Gueorgui I. Kolev in April 2021. 

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab: xtglsr}
[{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Optional}
{synopt:{opt cluster(varname)}}  Allows the cluster variable to be manually specified. By default the command {bf: xtglsr} calculates heteroskedasticity robust 
variance if in the {bf: xtgls} you have specified panel structure to be {bf: panels(iid)} or {bf: panels(heteroskedastic)}. If {bf: panels(correlated)} has been specified in the {bf: xtgls} estimation, the default is to calculate cluster-robust 
variance clustered by the time variable set at the {bf: xtset} stage. 
{p_end}
{synopt:{opt minus(#)}} Controls the degrees of freedom adjustment factor in the robust, or cluster-robust variance calculation. 
Default value is {bf: minus(0)}, which is equivalent to no degrees of freedom adjustment. 
This option is inherited from {bf: [P] _robust} and detailed instructions of how to apply the degrees of freedom adjustment through the option {bf: minus(#)} are given in the manual entry for {bf: [P] _robust}.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}
Stata's {bf:[XT] xtgls -- Fit panel-data models by using GLS} estimates panel data models by generalised least squares. 
However {bf:[XT] xtgls} cannot estimate robust or cluster-robust variance matrix and standard errors for the parameter estimates. 
Gueorgui I. Kolev (2014) "Robust variance estimation in panel data generalized least squares regression" shows the relevant formulae for robust and
cluster-robust variance and standard errors, and these formulae are automatically implemented by the post estimation  command {bf: xtglsr}. 
{bf: Important note 1):} all that {bf: xtglsr} does is replace the estimated non-robust variance with robust or cluster-robust variance.
{bf: xtglsr} returns the robust or cluster-robust variance in the proper format, so that further post estimation commands 
after {bf: xtglsr} proceed as usual, e.g., {bf:[R] test}, {bf:[R] lincom}, {bf:[R] nlcom}, etc., proceed after {bf: xtglsr} as usual, and work as usual. 
{bf: Important note 2):} {bf: xtglsr} can handle {it: panelvar} identifier which contains (not necessarily equally spaced) non-negative integers, 
e.g., it is fine if your {it: panelvar} takes the values 0, 29, 5003, 200000, etc. If your {it: panelvar} takes more exotic values 
(negative values, or non-integer values) such as say {it: panelvar} takes the values -56, -.29, .5003, 200.536, etc., {bf: xtglsr} will generate an error.  
If you have negative and/or non-integer values in {it: panelvar}, then please use firstly

egen newpanelvar = group(panelvar)

to create a new nicely spaced panel identifier, see {bf: [D] egen, group()} before you 
 
 {bf: xtset} {it: newpanelvar} {it: timevar}
 
 your data, and before you fit the {bf: xtgls} . 
{pstd}

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt cluster(varname)}    {p_end}
{phang}
{opt minus(#)}    {p_end}


{marker examples}{...}
{title:Examples}


 webuse invest2, clear
* The panel variable is Company, values 1,2,3,4,5. Time is the time variable.
* -xtglsr- will of course work with such nicely spaced Company values, but I will make them a bit more awkward:

replace company = round(log(company)*10000)

. tab company

    company |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |         20       20.00       20.00
       6931 |         20       20.00       40.00
      10986 |         20       20.00       60.00
      13863 |         20       20.00       80.00
      16094 |         20       20.00      100.00
------------+-----------------------------------
      Total |        100      100.00

* With such unequally spaced non-negative integers, -xtgls- still works.

xtset company time


* Typical use of -xtglsr- follows: we quietly fit -xtgls- and then we noisily robustify the variance:

quietly  xtgls invest market stock	// If we want to compare non-robust with robust variance we can fit -xtgls- noisily as well. 
 
xtglsr	// Because -xtgls- model fit was "Panels: homoskedastic" (the defailt) the variance is robust only.
 
quietly  xtgls invest market stock, panels(correlated)

xtglsr, minus(1) // Because the -xtgls- model fit was with arbitrary correlation pattern within the panel, 
				// the default variance computed by -xtglsr- is cluster-robust, clustered on the time variable. 
			// I also applied the degrees of freedom adjustment, which is common in Stata for 
			// clustered variance: (# clusters)/(# clusters - 1). 
			
* If the user wants to manually control the clustering, the user can specify the cluster variable.
* In such a case, it becomes responsibility of the user to make sure that clustering makes sense.
* For example, if I am fitting -xtgls- with panels(correlated), I have admitted that my companies in the same year are correlated.
* Therefore it would not make sense to cluster by anything which is a sub-group of time. Clustering by a super-group of time would make sense.

* I generate 5 super-groups of time, each consecutive 4 years are put together in a group

gen clustervar = ceil(5*time/20) // time = 1,2,3,4 is first group, time = 5,6,7,8 is the second group, etc.

quietly  xtgls invest market stock, panels(correlated)

xtglsr, cluster(clustervar)

* Finally I show that -xtglsr- cannot handle panel identifiers like these

 replace company = (company-10986)/10000
 
 . tab company

    company |      Freq.     Percent        Cum.
------------+-----------------------------------
    -1.0986 |         20       20.00       20.00
     -.4055 |         20       20.00       40.00
          0 |         20       20.00       60.00
      .2877 |         20       20.00       80.00
      .5108 |         20       20.00      100.00
------------+-----------------------------------
      Total |        100      100.00


xtset company time

quietly xtgls invest market stock, panels(hetero)

. xtglsr
__000000.5108000040054321 invalid variable name
r(198);

* In this case, we need to make the company values take easier to handle values.

egen newcompany = group(company)

. tab newcompany

group(compa |
        ny) |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         20       20.00       20.00
          2 |         20       20.00       40.00
          3 |         20       20.00       60.00
          4 |         20       20.00       80.00
          5 |         20       20.00      100.00
------------+-----------------------------------
      Total |        100      100.00

xtset newcompany time

quietly xtgls invest market stock, panels(hetero)
 
xtglsr // It works fine now. 

* In this and all previous examples, post estimation after -xtglsr- works as usual

test market

nlcom _b[market]/_b[stock]

{pstd}


{title:Author}
version 1:  10  April 2021, Gueorgui I. Kolev
email: joro.kolev@gmail.com
{p}



