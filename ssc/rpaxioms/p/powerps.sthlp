{smcl}
{* *! version 1.00 27february2020}{...}
{viewerjumpto "Syntax" "powerps##syntax"}{...}
{viewerjumpto ”Description” ”powerps##description”}{...}
{viewerjumpto ”Options” ”powerps##options”}{...}
{viewerjumpto ”Stored results” ”powerps##results”}{...}
{viewerjumpto ”Authors” ”powerps##authors”}{...}
{title:Title}

{pstd}powerps{hline 2}Testing Axioms of Revealed Preference{p_end}
{p2colreset}{...}

{marker syntax}
{title:Syntax}

{p 8 15 2}
{cmd:powerps}{cmd:,}
{it: price(mname) quantity(mname)} [{it: options}]
{p_end}


{synoptset 26 tabbed}{...}
{synopthdr:options}
{synoptline}

{synopt :{opth ax:iom(powerps##options:axiom)}} axiom for testing data; default is {bf: axiom(eGARP)}.
In total, there are six axioms that can be tested: eGARP, eWARP, eWGARP, eSARP, eHARP and eCM. To test all axioms at once, specify {bf: axiom(all)}.{p_end}

{synopt :{opth eff:iciency(powerps##options:efficiency)}} efficiency level for testing data, where 0 < efficiency =< 1; default is {bf:efficiency(1)}.{p_end}

{synopt :{opth sim:ulations(powerps##options:simulations)}} number of repititions of the simulated uniformly random data; default is {bf:simulations(1000)}.{p_end}

{synopt :{opth seed:(powerps##options:seed)}} seed in generation of Dirichlet random numbers; default is {bf:seed(12345)}.{p_end}

{synopt :{opth aei:(powerps##options:aei)}} compute AEI for each simulated uniformly random data set and every specified axiom; default is {bf:aei} {it:not} specifiede.{p_end}

{synopt :{opth tol:erance(powerps##options:tolerance)}} tolerance level in termination criterion 10^-{it:n}; default is {bf:tolerance(12)}.{p_end}

{synopt :{opth progress:bar(powerps##options:progress)}} displays number of repititions that have been executed; default is {bf: progressbar} {it: not} specified.{p_end}

{synopt :{opth suppress:(powerps##options:suppress)}} suppress output table; default is {bf: suppress} {it: not} specified.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd: powerps} calculates the power against uniform random behavior and predictive success for the axioms at any given efficiency level.

{pstd}
{cmd: powerps} is the third in a series of three commands for testing axioms of revealed preference.
The other two commands are {cmd: checkax} (which tests whether consumer demand data satisfy certain revealede preference axioms at a given efficiency level) and 
{opt aei} (which calculates measures of goodness-of-fit wheen the data violates the axioms).

{pstd}
{cmd: powerps} is dependent on {cmd: checkax} and {cmd: aei}.

{pstd}
For further details on the commands, please see {bf: Demetry, Hjertstrand and Polisson (2020) "Testing Axioms of Revealed Preference". IFN Working Paper No. 1342}.

{marker options}{...}
{dlgtab: Options }

{synopt :axiom}  specifies which axiom the user would like to use in testing the data for consistency. The default is {bf: axiom(eGARP)}.
In total, there are six axioms that can be tested: eGARP, eWARP, eWGARP, eSARP, eHARP and eCM. To test all axioms at once, specify {bf: axiom(all)}.{p_end}

{synopt :efficiency} specifies the efficiency 
level at which the user would like to test the data. The default efficiency level is {bf:efficiency(1)}.
Efficiency must be greater than zero and less than or equal to one.{p_end}

{synopt :simulations} specifies the number of repititions of the simulated uniformly random data; default is {bf:simulations(1000)}.{p_end}

{synopt :seed} specifies the random seed in generation of Dirichlet random numbers; default is {bf:seed(12345)}.{p_end}

{synopt :aei} specifies whether the user wants to compute the AEI for each simulated uniformly random data set and every specified axiom;
    default is {bf:aei} {it:not} specified.{p_end}

{synopt :tolerance} sets the tolerance level in the termination criterion 10^-{it:n} by specifying the integer number {it: n}.
    For example, {bf: tolerance(6)} sets the tolerance level in the termination criterion to 10^-6. The default is 
    {bf: tolerance(12)}, which gives the default tolerance level 10^-12. The integer {it: n} in the termination criterion 10^-{it:n}
    cannot be smaller than 1 or larger than 18.{p_end}

{synopt :progressbar} displays number of repititions that have been executed. The default is {bf: progressbar} {it: not} specified.{p_end}

{synopt :suppress} specifies that the user does not want the results displayed in a table. The default is that {bf: suppress} is {it: not} specified.
Whether or not this option is specified, the command results are retrievable from {bf: return list}.{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:powerps} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 19 2: Scalars}{p_end}
{synopt:{cmd:r(POWER_{it:axiom})}}computed power for each axiom{p_end}
{synopt:{cmd:r(PS_{it:axiom})}}computed predictive success for each axiom{p_end}
{synopt:{cmd:r(PASS_{it:axiom})}}indicator for whether data pass the axiom or not{p_end}
{synopt:{cmd:r(AEI_{it:axiom})}}AEI for the axiom being tested{p_end}
{synopt:{cmd:r(SIM_{it:axiom})}}number of repeitions in the simulatede uniformly random data{p_end}
{synopt:{cmd:r(TOL_{it:axiom})}}tolerance level for termination criterion, if option {opt aei} is specified{p_end}
{synopt:{cmd:r(EFF_{it:axiom})}}efficiency level at which the axiom is tested{p_end}
{synopt:{cmd:r(GOODS_{it:axiom})}}number of goods in the data{p_end}
{synopt:{cmd:r(OBS_{it:axiom})}}number of observations in the data{p_end}

{p2col 5 20 19 2: Macros}{p_end}
{synopt:{cmd:r(AXIOM_{it:axiom})}}axiom being tested{p_end}

{p2col 5 20 19 2: Matrices}{p_end}
{synopt:{cmd:r(SUMSTATS_{it:axiom})}}summary statistics for random data: Num_vio, Frac_Vio (and {opt aei} if specified).{p_end}
{synopt:{cmd:r(SIMRESULTS_{it:axiom})}}Num_vio, Frac_Vio (and {opt aei} if specified) for every simulated uniformly random data set.{p_end}

{marker authors}{...}
{title:Authors}

- Marcos Demetry, Research Assistant at the Research Institute of Industrial Economics, Sweden.
- Per Hjertstrand, Associate Professor and Research Fellow at the Research Institute 
of Industrial Economics, Sweden.
- Matthew Polisson, Senior Lecturer and Researcher at University of Bristol, UK.

