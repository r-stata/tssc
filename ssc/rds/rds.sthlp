{smcl}
{* *! version 0.1 June 15 2010}{...}
{* *! version 0.2 July 12 2010}{...}
{* *! version 0.3 July 25 2010}{...}
{* *! version 0.4 Mar 7, 2012}{...}
{* *! version 0.5 Mar 20, 2012}{...}
{* *! version 0.6 Sep 25, 2013}{...}
{cmd:help rds}, {cmd:help rds_network}{right: ({browse "http://www.stata-journal.com/article.html?article=st0247":SJ12-1: st0247})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:rds} {hline 2}}Respondent-driven sampling{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:rds} 
{varname} 
{ifin}{cmd:,}
{cmd:id(}{it:varname}{cmd:)}
{cmd:degree(}{it:varname}{cmd:)}
{cmd:recruiter_id(}{it:varname}{cmd:)} 
{cmd:recruiter_var(}{it:varname}{cmd:)}
[{it:{help rds##rds_options:rds_options}}]

{p 8 19 2}
{cmd:rds_network} 
{varname}{cmd:,}
{cmd:id(}{it:varname}{cmd:)}
{cmd:coupon(}{it:str}{cmd:)}
{cmd:ncoupon(}{it:#}{cmd:)}
{cmd:degree(}{it:varname}{cmd:)}
[{it:{help rds##rds_network_options:rds_network_options}}]

{marker rds_options}{...}
{synoptset 25 tabbed}{...}
{synopthdr :rds_options}
{synoptline}
{p2coldent :* {opt id(varname)}} unique coupon code of respondent R {p_end}
{p2coldent :* {opt degree(varname)}} network size{p_end}
{p2coldent :* {opt recruiter_id(varname)}} variable with ID of R's recruiter {p_end}
{p2coldent :* {opt recruiter_var(varname)}} variable with analysis variable of R's recruiter {p_end}
{synopt:{opth wgt(newvar)}} create variable with individualized weight{p_end}
{synopt:{opt wgt_pop(newvar)}} create variable with population weight{p_end}
{synopt:{opt detail}} show detailed convergence output {p_end}
{synopt:{opt convtol(#)}} set convergence tolerance{p_end}
{synopt:{opt net:work_size_method(str)}} set method to compute average group degree{p_end}
{synoptline}
{p 4 6 2}* {cmd:id()}, {cmd:degree()}, {cmd:recruiter_id()}, and
{cmd:recruiter_var()} are required.{p_end}

{marker rds_network_options}{...}
{synoptset 25 tabbed}{...}
{synopthdr :rds_network_options}
{synoptline}
{p2coldent :* {opt id(varname)}} unique coupon code of respondent R {p_end}
{p2coldent :* {opt coupon(str)}} stem of variable names containing R's coupons{p_end}
{p2coldent :* {opt ncoupon(#)}} number of coupons{p_end}
{p2coldent :* {opt degree(varname)}} network size{p_end}
{synopt:{opth anc:estor(newvar)}} create variable with ID of seed from which R was recruited{p_end}
{synopt:{opt depth(newvar)}} create variable with R's referral depth{p_end}
{synopt:{opt recruiter_id(newvar)}} create variable with ID of R's recruiter {p_end}
{synopt:{opt recruiter_var(newvar)}} create variable with analysis variable of R's recruiter {p_end}
{synoptline}
{p 4 6 2}*  {cmd:id()}, {cmd: coupon()}, {cmd:ncoupon()}, and {cmd:degree()} are required.{p_end}


{title:Description}

{pstd}
Respondent-driven sampling is a technique to sample networked
populations.  It shares some similarities with snowball sampling but
also requires estimates of network size (degree) and information about
who recruited whom.  Importantly, Markov chain theory makes it possible
to compute sampling probabilities.

{pstd} {cmd:rds_network} computes information about respondents'
recruiters that is required as input for {cmd:rds}.  {cmd:rds} estimates
population proportions, weights, and other statistics.

{pstd} This program implements Heckathorn's original estimator as well 
as the Volz-Heckathorn estimator.

{pstd} For those familiar with the standalone software "RDS Analysis
Tool" (RDSAT) by Heckathorn and Wejnert
(downloadable from 
{browse "http://www.respondentdrivensampling.org"}), differences include the following:  1)
RDSAT distinguishes between an ID and a coupon for the respondent.
Because coupons should already be unique, {cmd:rds_network} uses only
the coupon of the respondent as the identifying variable.  Because seeds
respondents do not have coupons, they must be given different unique
values.  2) Missing values are coded as ".", as is customary in Stata
(Heckathorn's software typically uses "0").


{title:Options for both commands}

{phang}{opt id(varname)} specifies the coupon code of the respondent.
This variable is also used as a unique respondent identifier.  For
seeds, any (nonmissing) unique value can be used.  Each different seed
must have a different value for {varname}.  This variable must be
numeric -- string ID variables should be converted to numeric variables
first; see {help rds##ex7:example 7}.

{phang}{opt degree(varname)} specifies the variable containing
the respondent's network size.  Values must be greater than zero.  If the data
contain zeros, the recommended procedure is to replace them with
missing values.


{title:Options unique to rds}

{phang}{opt recruiter_id(varname)} specifies a variable containing the ID
of the recruiter and missing values for seeds who do not have a
recruiter, if specified in {cmd:rds_network}.  This variable is needed
as input to {cmd:rds}.  {cmd:recruiter_id()} is required.

{phang}{opt recruiter_var(varname)} specifies a variable containing the
recruiter's analysis variable, if the recruited's analysis variable is
specified in {it:varlist}.  This variable is needed as input to
{cmd:rds}.  {cmd:recruiter_var()} is required.

{phang}{opt wgt(newvar)} creates a variable containing individual
sampling weights.  To the extent that degrees for individuals are missing,
group degree is used.  This option should not be used in conjunction
with bootstrapping because bootstrapping is not possible when a new
variable is created.

{phang}{opt wgt_pop(newvar)} creates a variable containing
population sampling weights.  This option should not be used in
conjunction with bootstrapping because bootstrapping is not possible
when a new variable is created.

{phang}{opt detail} shows detailed output for individual iterations when
computing the number of iterations needed for convergence to the
equilibrium.  Starting with a sample where all members belong to a
single category, the corresponding column of the output matrix displays
the simulated sample distribution after i iterations (waves).  The
sample distribution corresponding to the jth category is shown in the
jth column of the output matrix.

{phang}{opt convtol(#)} specifies the convergence tolerance, a number
between 0 and 1.  The default is {cmd:convtol(0.02)}.  Convergence to the
equilibrium is reached if the difference of two successive simulated
distributions of recruits is less than {cmd:convtol()} for all groups.

{phang}{opt network_size_method(str)} specifies the method as 
{cmd:multiplicity} (the default) or {cmd:average}. 
{cmd:network_size_method(multiplicity)} takes into account that people with
larger networks are more likely to be sampled;
{cmd:network_size_method(average)} computes the average network size of all
respondents.  The default should not be changed without good reason.


{title:Options unique to rds_network}

{phang}{opt coupon(str)} specifies the stem of the variable names for referral
coupons.  Variable names are {it:str}{cmd:1} through
{it:str}{it:#}, where {it:#} is the number of referral coupons.  For example, if coupon equals {cmd:ref} and
there are three referral coupons, the coupons are contained in variables
with the names {cmd:ref1}, {cmd:ref2}, and {cmd:ref3}.  The program
verifies that referral coupons are unique.  Missing values for coupons
are allowed.  Referral coupons must be numeric -- string referral coupons
should be converted to numeric variables first.

{phang}{opt ncoupon(#)} specifies the number of referral coupons.

{phang}{opt ancestor(newvar)} creates a variable containing the ID
of the seed to which a recruit can be traced back.

{phang}{opt depth(newvar)} creates a variable containing the depth
of the referral chain.  Seeds have depth 0, their recruits have depth 1,
and so forth.

{phang}{opt recruiter_id(newvar)} creates a variable containing the ID
of the recruiter and missing values for seeds who do not have a
recruiter, if specified in {cmd:rds_network}.  This variable is needed
as input to {cmd:rds}.

{phang}{opt recruiter_var(newvar)} creates a variable containing the
recruiter's analysis variable, if the recruited's analysis variable is
specified in {it:varlist}.  This variable is needed as input to
{cmd:rds}.


{title:Remarks}

{pstd} RDS methodology requires that continuous variables are broken up
into categories.  Therefore, {varname} should be categorical.
{it:varname} must not contain missing values.  Missing values should be
imputed beforehand.


{title:Examples}

{pstd}Example 1. Create a new variable, {cmd:wgt}, with weights based on the
transition matrix for race.  There are three referral coupons in the
variables {cmd:ref1}, {cmd:ref2}, and {cmd:ref3}.  {cmd:degree()} specifies the
network size of each respondent.

{phang}{cmd:. rds_network race, id(coupon) coupon(ref) ncoupon(3) degree(degree) recruiter_var(r_var) recruiter_id(r_id)}

{phang}{cmd:. rds race, id(coupon) wgt(wgt) degree(degree) recruiter_var(r_var) recruiter_id(r_id)}

{pstd}Example 2. Bootstrap estimated population proportions to
construct bootstrap confidence intervals.  To preserve the network
structure, first create {cmd:recruiter_id()} and {cmd:recruiter_var()}:

{phang}{cmd:. rds_network race, id(id) coupon(ref) ncoupon(3) degree(degree) recruiter_id(p_id) recruiter_var(p_var)}

{pstd} Specifically for bootstrapping, the population proportion P is
also saved in {cmd:_b}.  {cmd:_b} can be bootstrapped as a vector:

{phang}{cmd:. set seed 1}

{phang}{cmd:. bootstrap _b, reps(1000) notable: rds race, id(id) degree(degree) recruiter_id(p_id) recruiter_var(p_var)}

{pstd} Using the {cmd:percentile} option (rather than the normality
assumption) guarantees that the confidence limits are not outside the
interval [0,1]:

{phang}{cmd:. estat bootstrap, percentile}

{pstd}Example 3. Create an analysis variable from unique
combinations of {cmd:race} and {cmd:gender}.

{phang}{cmd:. egen myvar = group(race gender)}

{phang}{cmd:. rds_network myvar, id(coupon) coupon(ref) ncoupon(3) degree(degree) recruiter_id(r_id) recruiter_var(r_var)} 

{phang}{cmd:. rds myvar, id(coupon) wgt(wgt) degree(degree) recruiter_id(r_id) recruiter_var(r_var)}

{pstd}Example 4. Use a continuous variable as an analysis
variable.  First break the continuous variable (for example, {cmd:income}) 
into categories.

{phang}{cmd:. egen myvar = cut(income), group(4)}

{phang}{cmd:. rds_network myvar, id(coupon) coupon(ref) ncoupon(3) degree(degree) recruiter_id(r_id) recruiter_var(r_var)}

{phang}{cmd:. rds myvar, id(coupon) wgt(wgt) degree(degree) recruiter_id(r_id) recruiter_var(r_var)}

{pstd}Example 5. Analyze respondents only from wave 3 onward
(including wave 2 recruiter information):

{phang}{cmd:. rds_network race, id(coupon) coupon(ref) ncoupon(3) degree(degree) recruiter_id(r_id) recruiter_var(r_var) depth(wave)}

{phang}{cmd:. rds race if wave>=3, id(coupon) wgt(wgt) degree(degree) recruiter_id(r_id) recruiter_var(r_var)}

{pstd}Example 6. Using data on psychiatric diagnoses in an RDS
sample of injection drug users, estimate the proportions of
male and female injection drug users with a diagnosis.  Run a 2x2
partition with sex and diagnosis, providing the four proportions.  Get the confidence intervals for the proportion of males with
a positive diagnosis and the proportion of females with a positive
diagnosis -- for example, male_positive/(male_negative + male_positive).

{phang}{cmd:. bootstrap p1=(_b[P2]/(_b[P1]+_b[P2])): rds [...]}

{phang} Note: {cmd:P1} and {cmd:P2} are the column names of the (original) estimator stored in {cmd:e(b)} and correspond to the first two groups.
If using the Volz-Heckathorn estimator instead, substitute {cmd:P1} and {cmd:P2} with {cmd:VH1} and {cmd:VH2}.

{phang} [Example 6 and its solution were contributed by Mary E. Mackesy-Amiti.]

{marker ex7}{...}
{pstd}Example 7.  Referral codes must be numeric.  Conversion to numeric can
accomplished, for example, using Nick Cox's {cmd:multencode} command.  This
command ensures that the encoding scheme used is the same for all variables.

{phang}{cmd:. multencode code friend_code_1 friend_code_2 friend_code_3}
    {cmd:friend_code_4, generate(id ref1 ref2 ref3 ref4)}

{phang}{cmd:. rds_network  myvar, id(id) coupon("ref") ncoupon(4) degree(u2)}


{title:Saved results}

{pstd}{cmd:rds} saves the following in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(n_group)}}number of groups of {it:varname}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}vector of population proportions (for bootstrapping){p_end}
{synopt:{cmd:e(SampleP)}}vector of sample proportions {p_end}
{synopt:{cmd:e(W)}}vector of weights{p_end}
{synopt:{cmd:e(P)}}vector of population proportions{p_end}
{synopt:{cmd:e(VH)}}vector of Volz-Heckathorn estimate of population proportions{p_end}
{synopt:{cmd:e(GROUPSIZE)}}vector of sample sizes{p_end}
{synopt:{cmd:e(DEGREE)}}vector of degree (network size){p_end}
{synopt:{cmd:e(E)}}vector of equilibrium probabilities{p_end}
{synopt:{cmd:e(CATEGORIES)}}vector of categories of {it:varname}{p_end}
{synopt:{cmd:e(H)}}homophily vector{p_end}
{synopt:{cmd:e(obs)}}number of observations in transition matrix {p_end}
{synopt:{cmd:e(T1)}}transition matrix (before smoothing){p_end}
{synopt:{cmd:e(R)}}demographically adjusted matrix {p_end}
{synopt:{cmd:e(smoothR)}}smoothed number of observations in transition matrix{p_end}
{synopt:{cmd:e(T)}}transition matrix{p_end}


{title:Acknowledgment}

{pstd} This program was developed during a sabbatical with the
Socio-Economic Panel at the German Institute for Economic Research (DIW).


{title:Author}

{pstd}Matthias Schonlau{p_end}
{pstd}DIW Berlin (German Institute for Economic Research){p_end}
{pstd}Berlin, Germany{p_end}
{pstd}University of Waterloo{p_end}
{pstd}Waterloo, Canada{p_end}
{pstd}schonlau@uwaterloo.ca{p_end}
{pstd}{browse "http://www.schonlau.net":http://www.schonlau.net}


{title:Also see}

{pstd}{browse "http://www.respondentdrivensampling.org":http://www.respondentdrivensampling.org}

{pstd} To get identical results, set options in the RDSAT software as
follows: Average network size: multiplicity, Algorithm: Data Smoothing,
1-tailed alpha: 0.025.

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 1: {browse "http://www.stata-journal.com/article.html?article=st0247":st0247}{p_end}
