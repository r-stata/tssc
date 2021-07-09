{smcl}
{* *! version 1.0 2019-03-14}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[PSS] power" "help power"}{...}
{vieweralsosee "[PSS] power, graph" "help power_optgraph"}{...}
{vieweralsosee "[PSS] power, table" "help power_opttable"}{...}
{vieweralsosee "[PSS] power usermethod" "help power usermethod"}{...}
{vieweralsosee "[R] nbreg" "help nbreg"}{...}
{viewerjumpto "Syntax" "power_tworates_zhu##syntax"}{...}
{viewerjumpto "Description" "power_tworates_zhu##description"}{...}
{viewerjumpto "Options" "power_tworates_zhu##options"}{...}
{viewerjumpto "Remarks" "power_tworates_zhu##remarks"}{...}
{viewerjumpto "Examples" "power_tworates_zhu##examples"}{...}
{viewerjumpto "Stored results" "power_tworates_zhu##stored_results"}{...}
{viewerjumpto "References" "power_tworates_zhu##references"}{...}
{viewerjumpto "Author" "power_tworates_zhu##author"}{...}
{title:Title}

{phang}
{bf:power tworates_zhu} {hline 2} Sample Size / Power for a two-sample test of rates (using negative binomial regression)


{marker syntax}{...}
{title:Syntax}

{phang}
Compute sample size

{p 8 43 2}
{opt power} {opt tworates_zhu}{cmd:,} {opth r1(numlist)} {opth irr(numlist)} 
 [{opth p:ower(numlist)} 
{it:{help power_tworates_zhu##synoptions:options}}] 


{phang}
Compute power 

{p 8 43 2}
{opt power} {opt tworates_zhu}{cmd:,} {opth r1(numlist)} {opth irr(numlist)} 
{opth n(numlist)}
[{it:{help power_tworates_zhu##synoptions:options}}]


{phang}
where {bf:r1} is the rate (per unit of time) in the control (reference) group and {bf: irr} is the
incidence rate ratio, i.e. {bf:r2}/{bf:r1}. 
{bf:r1} and {bf:irr} may each be
specified either as one number or as a list of values (see {help numlist}).{p_end}


{synoptset 30 tabbed}{...}
{marker synoptions}{...}
{synopthdr:options}
{synoptline}
{syntab:Main}
{p2coldent:* {opth a:lpha(numlist)}}two-sided significance level; default is
   {cmd:alpha(0.05)}{p_end}
{p2coldent:* {opth p:ower(numlist)}}power; default is {cmd:power(0.8)}{p_end}
{p2coldent:* {opth b:eta(numlist)}}probability of type II error; default is
   {cmd:beta(0.2)}{p_end}
{p2coldent:* {opth n(numlist)}}sample size; n or n1 or n2 required to compute power{p_end}
{p2coldent:* {opth n1(numlist)}}sample size of the control group{p_end}
{p2coldent:* {opth n2(numlist)}}sample size of the experimental group{p_end}
{p2coldent:* {opth nrat:io(numlist)}}ratio of sample sizes, {cmd:N2/N1}; default is
{cmd:nratio(1)}, meaning equal group sizes{p_end}
{p2coldent:* {opth disp:ersion(numlist)}}negative binomial dispersion parameter (>0 for overdispersion); default is {cmd:dispersion(0)}{p_end}
{p2coldent:* {opth dur:ation(numlist)}}average follow-up or exposure duration (in units of time); default is {cmd:duration(1)}{p_end}
{p2coldent:* {opth varm:ethod(numlist)}}method 2 or 3 for variance under null hypothesis in Zhu and Lakkis (2014); 
default is {cmd:varmethod(3)}{p_end}
{synopt: {opt par:allel}}treat number lists in starred options or in command
arguments as parallel when multiple values per option or argument are
specified (do not enumerate all possible combinations of values)
{p_end}

{syntab:Table}
{synopt :{cmdab:tab:le}[{cmd:(}{it:{help power_tworates_zhu##tablespec:tablespec}}{cmd:)}]}options to display results as a table; see
{manhelp power_opttable PSS:power, table}{p_end}

INCLUDE help pss_graphopts.ihlp

{synoptline}
{p2colreset}{...}
{p 4 6 2}* Specifying a list of values in at least two starred options
results in computations for all possible combinations of the values; see
{help numlist}.  Also see the {cmd:parallel} option.{p_end}

{marker tablespec}{...}
{pstd}
where {it:tablespec} is

{p 16 16 2}
{it:{help power_tworates_zhu##column:column}}[{cmd::}{it:label}]
[{it:column}[{cmd::}{it:label}] [...]] [{cmd:,} {it:{help power_opttable##tableopts:tableopts}}]

{pstd}
{it:column} is one of the columns defined below,
and {it:label} is a column label (may contain quotes and compound quotes).

{synoptset 28}{...}
{marker column}{...}
{synopthdr :column}
{synoptline}
{synopt :{opt alpha}}two-sided significance level{p_end}
{synopt :{opt power}}power{p_end}
{synopt :{opt beta}}type II error probability{p_end}
{synopt :{opt N}}total number of subjects{p_end}
{synopt :{opt N1}}number of subjects in the control group{p_end}
{synopt :{opt N2}}number of subjects in the experimental group{p_end}
{synopt :{opt nratio}}ratio of sample sizes, experimental to control{p_end}
{synopt :{opt delta}}effect size, i.e. IRR{p_end}
{synopt :{opt IRR}}Incidence Rate Ratio (IRR){p_end}
{synopt :{opt r1}}control-group rate{p_end}
{synopt :{opt r2}}experimental-group rate{p_end}
{synopt :{opt dispersion}}negative binomial dispersion parameter{p_end}
{synopt :{opt duration}}average follow-up duration{p_end}
{synopt :{opt varmethod}}method for variance under null hypothesis in Zhu and Lakkis (2014){p_end}
{synopt :{opt _all}}display all supported columns{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}Column {cmd:beta} is NOT shown in the default table in place of column
{cmd:power} if specified.{p_end}
{p 4 6 2}Columns {cmd:nratio}, {cmd:varmethod} and {cmd:delta}
are shown in the default table if specified.


{marker description}{...}
{title:Description}

{pstd}
{cmd:power tworates_zhu} computes sample size or power
 for a two-sample test of rates (using negative binomial regression) 
using the equations in Zhu and Lakkis (2014). 

{pstd} 
By default, it computes sample size for the
given power and the values of the control-group rate and the ratio of the experimental-group rate 
and the control-group rate (i.e. Incidence Rate Ratio or IRR).

{pstd}
Alternatively, it can compute power for given sample size and values of the
control-group rate and IRR. 

{pstd}
To search for what effect size (IRR) can be detected for a given sample size with e.g. 80% power,
try doing a power calculation putting a list of values in {opth irr(numlist)} and 
seeing what the power is for each value. See 4th Computing power example below.

{pstd}
Also see {manhelp power PSS} for a general introduction to the {cmd:power}
command using hypothesis tests. {cmd:power tworates_zhu} is a user-defined method.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{cmd:alpha()}, {cmd:power()}, {cmd:beta()}, {cmd:n()}, {cmd:n1()},
{cmd:n2()}, {cmd:nratio()}; 
see {manhelp power##mainopts PSS: power}.

{phang}
{opth dispersion(numlist)} specifies the negative binomial dispersion parameter 
(k in Zhu and Lakkis (2014), but alpha in {manhelp nbreg R: nbreg}). 
For a group where there is equal follow-up or exposure per subject, 
#Events has Variance = Mean_#Events*(1 + Mean_#Events*k)
The default is k=0, corresponding to the Poisson distribution. 
Keene et al. (2007) estimated k=0.46 from raw data, while Zhu estimated k=0.8 from a different study's summary data.

{phang}
{opth duration(numlist)} specifies the average follow-up duration or exposure (mu_t} in Zhu and Lakkis (2014). 
The default is 1. To calculate the expected number of events per subject, multiply r1 (or r2 = r1*IRR) by duration.

{phang}
{opth varmethod(numlist)} specifies the method for variance under null hypothesis in Zhu and Lakkis (2014).  
The default is method 3. Method 2 is also available and will likely give very similar answers to method 3. 
Method 1 is not available, as it appeared to be less accurate than the other methods. 
Method 2 for calculating sample size corresponds to the method of Keene et al. (2007) when N1=N2.

{phang}
{cmd:parallel}; see {manhelp power##mainopts PSS: power}.

{dlgtab:Table}

{phang}
{cmd:table}, {opt table()}; see 
{manhelp power_opttable PSS: power, table}.

INCLUDE help pss_graphoptsdes.ihlp
Also see the {mansection PSS powertwomeansSyntaxcolumn:column} table in
{bf:[PSS] power twomean} for a list of symbols used by the graphs.


{marker remarks}{...}
{title:Remarks}

{pstd}
By default, all computations assume a balanced- or equal-allocation design; see
{manlink PSS unbalanced designs} for a description of how
to specify an unbalanced design.

{pstd}
Instead of specifying the total sample size {cmd:n()}, you can specify individual group
sizes in {cmd:n1()} and {cmd:n2()}, or specify one of the group sizes and optionally
{cmd:nratio()} when computing power.  Also see
{mansection PSS unbalanceddesignsRemarksandexamplesTwosamples:{it:Two samples}}
in {bf:[PSS] unbalanced designs} for more details.

{pstd}
For ideas on what value of dispersion to assume, (i) use {manhelp nbreg R: nbreg} on raw data, (ii) read the references.

{pstd}
"Because these methods are developed on the basis of the
asymptotic normality of the maximum likelihood estimate of the model parameters, they are better to
be used for maximum-likelihood-based tests such as Wald or likelihood ratio tests. When sample size is
small (e.g., less than 50 [per group]), these tests may not be appropriate for confirmatory trials, and more appropriate
tests should be considered. The uniformly most powerful unbiased test proposed by Wang et al. [15] is
an example, and it seems to maintain type I error rate better for small sample size under the assumption
that the common dispersion parameter k is known. Before a sample size formula for such a test becomes
available, the sample size methods in this paper can be used to obtain a rough estimate of the sample
size, but simulation methods should be considered for obtaining more accurate sample size." Zhu and Lakkis (2014)


{marker examples}{...}
{title:Examples}

    {title:Examples: Computing sample size}

{pstd}
    Compute the sample size required to detect an IRR of 0.7 given a control-group rate of 3 per subject per year,  
    average follow-up of 1 year, a (two-sided) test with 
    5% significance level, 80% power, N1=N2, and zero overdispersion (i.e. Poisson variation) 
	(the defaults){p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(3) irr(0.7)"}

{pstd}
    Extending the above, by varying the amount of dispersion{p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(3) irr(0.7) dispersion(0 (0.4) 1.2)"}
        
{pstd}
    Compute the sample size required to detect an IRR of 0.85 given a control-group rate of 0.8 per subject per year,  
    average follow-up of 0.75 years for scenario 1 (and 1.5 years for scenario 2), 
    5% significance level, 80% power, N1=N2, and dispersion k=0.4 {p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(0.8) irr(0.85) duration(0.75 1.5) dispersion(0.4)"}

{pstd}
    Compute sample sizes for a range of IRRs and powers, graphing the results{p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(0.8) irr(0.5 (0.05) 0.85) duration(0.75) dispersion(0.4) power(0.8 0.9) graph(y(N) x(IRR)) table"}

{pstd}
    Reproduce Zhu and Lakkis (2014) Table I (Methods 2 & 3). 
	(Note: sort order is different, but Ns are the same){p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(0.8 1.0 1.2 1.4) irr(0.85 1.15) duration(0.75) dispersion(0.4 0.7 1.0 1.5) power(0.8) varmethod(2 3) table(dispersion IRR r1 N1 varmethod)"}



    {title:Examples: Computing power}

{pstd}
    Compute the power to detect an IRR of 0.7 given a control-group rate of 3 per subject per year, N1=N2=49,   
    average follow-up of 1 year, a two-sided test with 
    5% significance level and zero overdispersion (i.e. Poisson variation) 
	(the defaults){p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(3) irr(0.7) n1(49)"}

{pstd}
    Extending the above, by varying the amount of dispersion{p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(3) irr(0.7) n1(49) dispersion(0 (0.4) 1.2)"}
        
{pstd}
    Compute the power required to detect an IRR of 0.85 given a control-group rate of 0.8 per subject per year,  
    average follow-up of 0.75 years for scenario 1 (and 1.5 years for scenario 2), 
    5% significance level, N1=N2=1311, and dispersion k=0.4 {p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(0.8) irr(0.85) n1(1311) duration(0.75 1.5) dispersion(0.4)"}

{pstd}
    Compute power for a range of IRRs, graphing and tabling the results{p_end}
{phang2}{sf:. }{stata "power tworates_zhu, r1(0.8) irr(0.75 (0.05) 0.9) n1(1311) duration(0.75) dispersion(0.4) graph(y(power) x(IRR) ylab(0 (0.1) 1)) table"}



{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:power tworates_zhu} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd: r(alpha)}}significance level{p_end}
{synopt:{cmd: r(power)}}power{p_end}
{synopt:{cmd: r(beta)}}probability of a type II error{p_end}
{synopt:{cmd: r(delta)}}effect size, i.e. IRR{p_end}
{synopt:{cmd: r(N)}}total sample size{p_end}
{synopt:{cmd: r(N1)}}sample size of the control group{p_end}
{synopt:{cmd: r(N2)}}sample size of the experimental group{p_end}
{synopt:{cmd: r(nratio)}}ratio of sample sizes, {cmd:N2/N1}{p_end}
{synopt:{cmd: r(r1)}}control-group rate, i.e. Mean_#events per unit of time{p_end}
{synopt:{cmd: r(r2)}}experimental-group rate, i.e. Mean_#events per unit of time{p_end}
{synopt:{cmd: r(IRR)}}Incidence Rate Ratio{p_end}
{synopt:{cmd: r(duration)}}average follow-up or exposure duration (i.e. how many units of time){p_end}
{synopt:{cmd: r(dispersion)}}negative binomial dispersion parameter{p_end}
{synopt:{cmd: r(varmethod)}}method for variance under null hypothesis in Zhu and Lakkis (2014){p_end}
{synopt:{cmd: r(nfractional)}}0{p_end}
{synopt:{cmd: r(onesided)}}0{p_end}

{pstd}
[{cmd:power_cmd_tworates_zhu} stores most of the above also]


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(type)}}{cmd:test}{p_end}
{synopt:{cmd:r(method)}}{cmd:tworates_zhu}{p_end}
INCLUDE help pss_rrestab_mac.ihlp

{synoptset 20 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
INCLUDE help pss_rrestab_mat.ihlp


{marker references}{...}
{title:References}

{phang}Zhu, H. and Lakkis, H. 2014. Sample Size Calculation for Comparing Two Negative Binomial Rates. Statistics in Medicine, Volume 33, Pages 376-387. https://onlinelibrary.wiley.com/doi/full/10.1002/sim.5947{p_end} 
{phang}Keene ON, Jones MRK, Lane PW, Anderson J. Analysis of exacerbation rates in asthma and chronic obstructive pulmonary disease: example from the TRISTAN study. Pharmaceutical Statistics 2007; 6:89–97.{p_end}

{phang}PASS Sample Size Software, Chapter 438. https://ncss-wpengine.netdna-ssl.com/wp-content/themes/ncss/pdf/Procedures/PASS/Tests_for_the_Ratio_of_Two_Negative_Binomial_Rates.pdf {p_end}


{marker author}{...}
{title:Author}

{p 4 4 2}
Mark Chatfield, University of Queensland, Australia.{break}
m.chatfield@uq.edu.au{break}
