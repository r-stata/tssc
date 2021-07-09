{smcl}

{title:mgf_unbal}

{p 4 4 2}
Computes the average marginal effect (AME) of an explanatory variable after {helpb xtprobitunbal}.


{title:Syntax}

{p 8 8 2} {bf:mgf_unbal} {ifin}, dydx({it:marginvar}) [val0(#) val1(#)]

{p 4 4 2}
where {it:marginvar} should fit to one of the following cases: {bf:lag}, {bf:d.{varname}} or  {bf:c.{varname}}.


{col 5}{it:marginvar} case{col 25}{it:Description}
{space 4}{hline 72}
{col 5}{bf:lag}{col 25}to compute the effect of a discrete change (from 0
{col 5}{bf: }{col 25}{bf: }  to 1) of the lagged dependent variable.
{col 5}{bf:d.varname}{col 25}to compute the effect of a discrete change of the
{col 5}{bf: }{col 25}{bf: } variable varname.
{col 5}{bf:c.varname}{col 25}to compute the marginal effect of an infinitesimal
{col 5}{bf: }{col 25}{bf: } change of the continuous variable varname.
{space 4}{hline 72}

{p 4 4 2}
When {bf:d.varname} is specified, the user can use the options {bf:val0(#)} and {bf:val1(#)}. 
The command will compute the marginal effect of a discrete change in the variable {it:varname} when it changes from the value set in {it:val0} to the value set in {it:val1}. Defaults values are {bf:val0(0)} and {bf:val1(1)}.



{title:Examples}

{p 4 4 2}
	Setup: the examples bellow require the package to be installed with ancillary files

{p 4 4 2}
		{bf:. ssc install xtprobitunbal, all replace}

{p 4 4 2}
	Load the data

{p 4 4 2}
		{bf:. sysuse exportunbal}

    Estimate the model (see {helpb xtprobitunbal} for further details)

{p 4 4 2}
		{bf:. xtprobitunbal export size trend med_skill age, meansvars(size med_skill)}

{p 4 4 2}
	Marginal effect of the lagged dependent variable    {break}

{p 4 4 2}
		{bf:. mgf_unbal, dydx(lag)}

{p 4 4 2}
	Marginal effect of a continuous change in an exogenous variable

{p 4 4 2}
		{bf:. mgf_unbal, dydx(c.med_skill)}

{p 4 4 2}
	Marginal effect of a discrete change in an exogenous variable

{p 4 4 2}
		{bf:. mgf_unbal, dydx(d.age)}

{p 4 4 2}
	Marginal effect of a discrete change, from 2 to 3, in an exogenous variable

{p 4 4 2}
		{bf:. mgf_unbal, dydx(d.age) val0(2) val1(3)}



{title:Stored results}

{p 4 4 2}
{bf:mgf_unbal} stores the following in {bf:r()}:


{p 4 4 2}{bf:Macros:}

{p 8 8 2} {bf: r(nobsAME)} : total number of observations used in computing the AME

{p 8 8 2} {bf: r(ngr_AME)} : number of groups (individuals) used in computing the AME

{p 8 8 2} {bf:     r(AME)} : average marginal effect (AME)

{p 8 8 2} {bf:   r(seAME)} : standard error of AME

{p 8 8 2} {bf: r(zst_AME)} : test statistic

{p 8 8 2} {bf:r(pval_AME)} : p-value



{title:Authors}

{p 4 4 2}
Pedro Albarran    {break}
Universidad de Alicante    {break}
{it:albarran@ua.es}    {break}


{p 4 4 2}
Raquel Carrasco    {break}
Universidad Carlos III de Madrid     {break}
{it:rcarras@eco.uc3m.es}


{p 4 4 2}
Jesus M. Carro    {break}
Universidad Carlos III de Madrid    {break}
{it:jcarro@eco.uc3m.es}    {break}



{title:License}

{p 4 4 2}
This code is licensed under GPLv3


{title:References}

{p 4 4 2}
Albarran, P., R. Carrasco and J. Carro. 2019.  {browse "https://onlinelibrary.wiley.com/doi/abs/10.1111/obes.12308":Estimation of Dynamic Nonlinear Random Effects Models with Unbalanced Panels}. {it:Oxford Bulletin of Economics and Statistics}, 81(6), 1424-1441.



