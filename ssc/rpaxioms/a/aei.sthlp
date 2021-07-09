{smcl}
{* *! version 1.00 27february2020}{...}
{viewerjumpto "Syntax" "aei##syntax"}{...}
{viewerjumpto ”Description” ”aei##description”}{...}
{viewerjumpto ”Options” ”aei##options”}{...}
{viewerjumpto ”Stored results” ”aei##results”}{...}
{viewerjumpto ”Authors” ”aei##authors”}{...}
{title:Title}

{pstd}aei{hline 2}Testing Axioms of Revealed Preference{p_end}
{p2colreset}{...}

{marker syntax}
{title:Syntax}

{p 8 15 2}
{cmd:aei}{cmd:,}
{it: price(mname) quantity(mname)} [{it: options}]
{p_end}


{synoptset 26 tabbed}{...}
{synopthdr:options}
{synoptline}

{synopt :{opth ax:iom(aei##options:axiom)}} axiom for testing data; default is {bf: axiom(eGARP)}.
In total, there are six axioms that can be tested: eGARP, eWARP, eWGARP, eSARP, eHARP and eCM.{p_end}

{synopt :{opth tol:erance(aei##options:tolerance)}} tolerance level in termination criterion 10^-2{it:n}}; default is {bf:tolerance(12)}.{p_end}

{synopt :{opth suppress:(aei##options:suppress)}} suppress output table; default is {bf: suppress} {it: not} specified.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd: aei} calculates measures of goodness-of-fit when the data violates the revealed preference axiom.

{pstd}
{cmd: aei} is the second in a series of three commands for testing axioms of revealed preference.
The other two commands are {cmd: checkax} (which tests whether consumer demand data satisfy certain revealede preference axioms at a given efficiency level) and {cmd: powerps} (which 
calculates the power against uniform random behavior and predictive success for the axioms at any given efficienecy level).

{pstd}
{cmd: aei} is dependent on {cmd: checkax}.

{pstd}
For further details on the commands, please see {bf: Demetry, Hjertstrand and Polisson (2020) "Testing Axioms of Revealed Preference". IFN Working Paper No. 1342}.

{marker options}{...}
{dlgtab: Options }

{synopt :axiom}  specifies which axiom the user would like to use in testing the data for consistency. The default is {bf: axiom(eGARP)}.
In total, there are six axioms that can be tested: eGARP, eWARP, eWGARP, eSARP, eHARP and eCM.{p_end}

{synopt :tolerance} sets the tolerance level in the termination criterion 10^-{it:n} by specifying the integer number {it: n}.
For example, {bf: tolerance(6)} sets the tolerance level in the termination criterion to 10^-6. The default is 
{bf: tolerance(12)}, which gives the default tolerance level 10^-12. The integer {it: n} in the termination criterion 10^-{it:n}
cannot be smaller than 1 or larger than 18.{p_end}

{synopt :suppress} specifies that the user does not want the results displayed in a table.
The default is that {bf: suppress} is {it: not} specified. Whether or not this option is specified, the command results are retrievable from {bf: return list}.{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:aei} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(AEI)}}AEI for the axiom being tested{p_end}
{synopt:{cmd:r(TOL)}}tolerance level for termination criterion{p_end}
{synopt:{cmd:r(GOODS)}}number of goods in the data{p_end}
{synopt:{cmd:r(OBS)}}number of observations in the data{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(AXIOM)}}axiom being tested{p_end}

{marker authors}{...}
{title:Authors}

- Marcos Demetry, Research Assistant at the Research Institute of Industrial Economics, Sweden.
- Per Hjertstrand, Associate Professor and Research Fellow at the Research Institute 
of Industrial Economics, Sweden.
- Matthew Polisson, Senior Lecturer and Researcher at University of Bristol, UK.

