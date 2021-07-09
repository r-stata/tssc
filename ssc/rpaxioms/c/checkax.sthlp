{smcl}
{* *! version 1.00 21february2020}{...}
{viewerjumpto ”Syntax” ”checkax##syntax”}{...}
{viewerjumpto ”Description” ”checkax##description”}{...}
{viewerjumpto ”Options” ”checkax##options”}{...}
{viewerjumpto ”Stored results” ”checkax##results”}{...}
{viewerjumpto ”Authors” ”checkax##authors”}{...}
{title:Title}

{pstd}checkax{hline 2}Testing Axioms of Revealed Preference{p_end}
{p2colreset}{...}

{marker syntax}
{title:Syntax}

{p 8 15 2}
{cmd:checkax}{cmd:,}
{it: price(mname) quantity(mname)} [{it: options}]
{p_end}


{synoptset 26 tabbed}{...}
{synopthdr:options}
{synoptline}

{synopt :{opth ax:iom(checkax##options:axiom)}} axiom for testing data; default is {bf: axiom(eGARP)}.
Axioms that can be tested: eGARP, eWARP, eWGARP, eSARP, eHARP and eCM.{p_end}

{synopt :{opth eff:iciency(checkax##options:efficiency)}} efficiency level for testing data, where 0 < efficiency <= 1; default is {bf:efficiency(1)}.{p_end}

{synopt :{opth suppress:(checkax##options:suppress)}} suppress output table; default is {bf: suppress} {it: not} specified.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt checkax} allows the user to test whether consumer demand data satisfy certain revealed preference axioms at a given efficiency level.

{pstd}
{opt checkax} is the first in a series of three commands for testing axioms of revealed preference.
The other two commands are {opt aei} (which calculates measures of goodness-of-fit when the data violates the axioms) and {opt powerps} (which 
calculates the power against uniform random behavior and predictive success for the axioms at any given efficienecy level).

{pstd}
For further details on the commands, please see {bf: Demetry, Hjertstrand and Polisson (2020) "Testing Axioms of Revealed Preference". IFN Working Paper No. 1342}.

{marker options}{...}
{dlgtab: Options }

{synopt :axiom}  specifies which axiom the user would like to use in testing the data for consistency.
The default is {bf: axiom(eGARP)}. In total, there are six axioms that can be tested: eGARP, eWARP, eWGARP, eSARP, eHARP and eCM.{p_end}

{synopt :efficiency} specifies the efficiency 
level at which the user would like to test the data. The default efficiency level is {bf:efficiency(1)}.
Efficiency must be greater than zero and less than or equal to one.{p_end}

{synopt :suppress} specifies that the user does not want the results displayed in a table. The default is that {bf: suppress} is {it: not} specified.
Whether or not this option is specified, the command results are retrievable from {bf: return list}.{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:checkax} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(PASS)}}indicator for whether data pass the axiom or not{p_end}
{synopt:{cmd:r(NUM_VIO)}}number of violations{p_end}
{synopt:{cmd:r(FRAC_VIO)}}fraction of violations{p_end}
{synopt:{cmd:r(GOODS)}}number of goods in the data{p_end}
{synopt:{cmd:r(OBS)}}number of observations in the data{p_end}
{synopt:{cmd:r(EFF)}}efficiency level at which the axiom is tested{p_end}

{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(AXIOM)}}axiom being tested{p_end}

{marker authors}{...}
{title:Authors}

- Marcos Demetry, Research Assistant at the Research Institute of Industrial Economics, Sweden.
- Per Hjertstrand, Associate Professor and Research Fellow at the Research Institute 
of Industrial Economics, Sweden.
- Matthew Polisson, Senior Lecturer and Researcher at University of Bristol, UK.

