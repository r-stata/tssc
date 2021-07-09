{smcl}
{* 27aug2002}{...}
{hline}
help for {hi:survwgt}
{hline}

{title:Survey sampling weights: adjustment and replicate weight creation}

{p 4 25}{cmd:survwgt} {cmdab:cr:eate}{space 7}{it:weight_type} {cmd:,}
		{cmdab:str:ata(}{it:varname}{cmd:)} {cmdab:psu(}{it:varname}{cmd:)}
		{cmdab:w:eight(}{it:varname}{cmd:)} {cmdab:stem(}{it:stem}{cmd:)}
		[ {cmd:fay(}{it:#}{cmd:)} {cmd:dof(}{it:#}{cmd:)}
		{cmdab:hadm:at(}{it:matname}{cmd:)} {cmdab:hadf:ile(}{it:matrix_file_name}{cmd:)}
		{cmdab:nod:ots} ]

{p 25 25}{it:weight_type} is one of

{p 25 30}{cmd:brr} - balanced repeated replication weights{p_end}
{p 25 30}{cmd:jk1} - unstratified delete-one jackknife weights{p_end}
{p 25 30}{cmd:jk2} - two per stratum delete-one jackknife weights{p_end}
{p 25 30}{cmd:jkn} - delete-n jackknife weights{p_end}

{p 4 25}{cmd:survwgt} {cmdab:post:stratify}{space 1}{it:varspec} {cmd:,}
		{cmdab:by(}{it:varlist}{cmd:)} {cmdab:t:otvar(}{it:varname}{cmd:)}
		{ {cmdab:g:enerate(}{it:varlist}{cmd:)} | {cmdab:stem(}{it:stem}{cmd:)} |
		{cmdab:pre:fix(}{it:prefix}{cmd:)} | {cmd:replace} | {cmd:modify} }

{p 4 25}{cmd:survwgt} {cmdab:rake}{space 9}{it:varspec} {cmd:,}
		{cmdab:by(}{it:varlist}{cmd:)} {cmdab:t:otvars(}{it:varlist}{cmd:)}
		{ {cmdab:g:enerate(}{it:varlist}{cmd:)} | {cmdab:stem(}{it:stem}{cmd:)} |
		{cmdab:pre:fix(}{it:prefix}{cmd:)} | {cmd:replace} | {cmd:modify} }

{p 4 25}{cmd:survwgt} {cmdab:nonr:esponse}{space 2}{it:varspec} {cmd:,}
		{cmdab:by(}{it:varlist}{cmd:)} {cmdab:r:espvar(}{it:varname}{cmd:)}
		{ {cmdab:g:enerate(}{it:varlist}{cmd:)} | {cmdab:stem(}{it:stem}{cmd:)} |
		{cmdab:pre:fix(}{it:prefix}{cmd:)} | {cmd:replace} }

{p 25 25}{it:varspec} is one of

{p 25 30}{it:varlist} - a Stata variable list{p_end}
{p 25 30}{cmd:[pw]}   - indicates the full sample weight{p_end}
{p 25 30}{cmd:[rw]}   - indicates the set of replicate weights{p_end}
{p 25 30}{cmd:[all]}  - indicates both {cmd:[pw]} and {cmd:[rw]}{p_end}


{title:Description}

{p}{cmd:survwgt} creates sets of weights for replication-based variance estimation
techniques for survey data.  These include balanced repeated replication (BRR) and several
version of the survey jackknife (JK*).  These replication methods are alternates to the
Taylor series linearization methods used by
Stata's {help svy:svy-based} commands.

{p}In addition, {cmd:survwgt} performs poststratification,
raking, and non-response adjustments to survey weights.

{p 0}{cmd:survwgt create} creates a set of replicate weights for a dataset.  {cmd:survwgt} can
create four types of replicate weights, depending on the nature of the complex
sample design and user preferences.  In each method, multiple weight variables are created.  Each
set of replicate weights is calcuated by setting the sampling weights for observations
in one or more PSUs to zero, and adjusting the sampling weights for the remaining observations
to reproduce the full-sample
totals.  The {help svr} set of commands use these weights to calculate (co)variances
estimates of parameters by repeatedly estimating statistics of interest with each set of
replicate weights.  See Wolter (1985) for details.

{p 4 8}{cmd:brr} (balanced repeated replication) is appropriate for designs with
exactly two PSUs per stratum.  Technically, (CHECK) PSUs must have been selected
without replacement; any subsequent subsampling within PSUs is acceptable.
In BRR, {it:n} weights are created, in which {it:n} is the smallest multiple of four
greater than or equal to the number of strata.  In each set of weights,
one PSU from each stratum is included and the other excluded, in a
pattern defined by a Hadamard matrix.  Specifications for Hadamard matrices up to
dimension 512 are included with {cmd:survwgt}, which allows for designs with up to 512 strata.
Larger Hadamard matrices may be provided by the user, up to the limits of {help matsize}.{p_end}

{p 4 8}{cmd:jk1} (unstratified delete-one jackknife) is appropriate for non-stratified,
clustered sampling designs.  In JK1, one PSU is deleted from each set of replicate weights, so
the number of replicate weights equals the number of PSUs. {p_end}

{p 4 8}{cmd:jk2} (two per stratum delete-one jackknife) is appropriate for the same
designs as the balanced repeated replication method: two PSUs per stratum, selected with
replacement, with any subsampling scheme within PSU.  In the {cmd:jk2} method, one PSU is
deleted from each replicate (as opposed to one PSU {it:per stratum} in the {cmd:brr} method).{p_end}

{p 4 8}{cmd:jkn} (delete-n jackknife) is appropriate for sampling designs with two
or more PSUs per stratum.  [Insert description here!]{p_end}

{p 0}{cmd:survwgt poststratify} computes post-stratification adjustments to survey sampling
weights.  The sampling weights in each stratum are adjusted by a multiplicative factor such
that the sum of the weights equals the control total for each stratum, as specified
in the {cmd:totvar()} option.  When more than one sampling weight variable is specified,
the command post-stratifies each in turn.  This allows for the adjustment of the main
sampling weight and a full set of replicate weights in one easy step.

{p 0}{cmd:survwgt rake} computes raking adjustments to survey sampling
weights.  Raking is used when there are multiple stratification dimension, when control
totals known for the marginal distribution of each dimension but not for the individual
cell totals.  (When population cell totals are known, post-stratification should
be used.)  In raking, the sampling weights for each stratum are iteratively adjusted
by a multiplicative factor such
that the sum of the weights equals the control total for marginal dimension, in turn, until
convergence is achieved.  As with post-stratification, multiple sets of analysis and replicate
weights can be raked with one call to {cmd:survwgt}.

{p 0}{cmd:survwgt nonresponse} computes non-response adjustments to survey sampling
weights.  Nonresponse adjustment requires a dataset that includes the full sample--
responders and non-responders.  Separately within each response stratum, the base survey
sampling weight for each responder in the
sample is adjusted such that the total weight for responders alone equals the total weight
for the sample.  The weight for non-responders is set to zero.  As with the other
weight adjustment routines, multiple variables can be subjected to non-response adjustment in
one easy call to {cmd:survwgt}.


{title:Options for {cmd:survwgt create}}

{p 0 4}{cmdab:strata(}{it:varname}{cmd:)} specifies the variable that identifies stratum membership.
This must be a single variable; if the strata are defined by multiple variables, a single
variable can be created with {help egen}'s group() option.  The {cmd:strata()}
option is required for all
weight types except JK1, for which it is not allowed.

{p 0 4}{cmdab:psu(}{it:varname}{cmd:)} specifies the variable that identifies the primary sampling
units within strata.  It is required for all types of replicate weight creation.

{p 0 4}{cmdab:weight(}{it:varname}{cmd:)} specifies the base sampling weights.  It is required.

{p 0 4}{cmdab:stem)}{it:stem}{cmd:)} specifies a stem to be used as the basis for the replicate weight
variable names.  The repliciate weight variables are named stem1, stem2, ... stem{it:n}.  If
{cmd:stem()} is not specified, a stem based on the type of weights is used (brr_, jk1_, jk2_, or jkn_)

{p 0 4}{cmd:fay(}{it:#}{cmd:)} specifies the value of the constant to be used in generating weights
according to Fay's variant of balanced repeated replication.  In this method, observations in
the selected PSUs are assigned weight of (2-fay), and those in the non-selected PSUs are assigned
a weight of (fay), rather than 2 and 0, respectively.  By default, the Fay constant is 0, which
implies "regular" BRR.  This option is valid only for the brr method.

{p 0 4}{cmd:dof(}{it:#}{cmd:)} specifies the appropriate degrees of freedom for variance estimates.
By default, degrees of freedom is set to the number of strata for the BRR and JK2 methods, to one less
than the the number of PSUs for JK1, and to the total number of PSUs minus the total number of strata, for the
JKn method.

{p 0 4}{cmdab:hadmat(}{it:matname}{cmd:)} specifies a Stata system matrix that contains the Hadamard matrix
to create the replicates.  The program comes with a binary file with Hadamard matrices up to
dimension 512, so this option should be little-used.  No checking is done that the matrix is
in fact a Hadamard matrix -- be careful!

{p 0 4}{cmdab:hadfile(}{it:matrix_file_name}{cmd:)} specifies the system file that contains Hadamard
matrices.  This should only be necessary when the system file is located off the Stata search path,
or named something other than the default.

{p 0 4}{cmdab:nodots} specifies that a dot should not be displayed for each set of weights that
is created.  With large datasets, the dots can reassure you that the program has not died.


{title:Options for {cmd:survwgt poststratify}, {cmd:rake}, and {cmd:nonresponse}}

{p 0 4}{it:varspec} specifies the base weight(s) to adjusted (i.e., post-stratified, raked, or adjusted for
non-response).  This can be specified as a Stata {help varlist}.  More usefully, this can be specified as
{cmd:[pw]}, which indicates the currently specified main analysis weight, and/or {cmd:[rw]} which indicates
the set of replicate weights.  {cmd:[all]} is a synonym for {cmd:[pw] [rw]}.  If this automated
variable specification is used, then the svr settings for the dataset are updated to specify the
new weights, unless the {cmd:noupdate} option is specified.  See {help svrset}.

{p 0 4}{cmdab:noup:date} specifies that the svr settings for the dataset should not be updated to reflect
the adjusted weights.  This only has an effect when the variables to be adjusted are specified with
the "automatic" syntax discussed above.

{p 0 4}{cmdab:by(}{it:varlist}{cmd:)} specifies variable(s) identifying the strata.  For post-stratification,
the base weights are adjusted to sum to the control totals for the {it:cells} defined by the strata; for
raking, the base weights are adjusted to sum to the control totals for the {it:marginals} of the strata.
For non-response adjustment, the base weights for respondents are adjusted to sum to the total of the full
sample weights for the cells defined by the strata.

{p 0 4}{cmdab:totvar}[{cmd:s}]{cmd:(}{it:varname}[{it:s}]{cmd:)} specifies the variable[s] containing
control totals for post-stratification or raking.  For post-stratification, {cmd:totvar()}
must be a single variable, constant within the cells defined by the
{cmd:by(}{it:varlist}{cmd:)}, of control totals.  For raking, {cmd:totvars()} must contain
variables (one per variable specified {cmd:by()}), which specify the marginal control total for each
value of the corresponding stratum variable.  This option is not valid for non-response
adjustment.

{p 0 4}{cmdab:respvar(}{it:varname}{cmd:)} specifies the variable that contains response information
for members of the sample.  This variable must take on values of 0 (indicating non-response),
1 (indicating response), or missing (out of sample).  The base weights are adjusted such that,
within each response stratum, the adjusted weight for respondents sums to the total of the
base weight for all sample members.  Non-respondent cases are assigned an adjusted weight of zero, and
out of sample cases are excluded from the calculations and assigned missing for the adjusted weight.

{p 4 4}If there are no respondents in a stratum, all weights for that stratum are set to zero and a warning is
displayed.  If there are no sample members in a stratum, all weights are set to missing and a warning
is displayed.  This option is only valid for non-response adjustment.

{p 0 4}{cmdab:generate(}{it:varlist}{cmd:)} specifies the explicitly the names for the
adjusted weight variable(s)
to be created. There must be one name per base sampling weight specified in {it:varlist}.

{p 0 4}{cmdab:stem}{it:stem}{cmd:)} specifies a stem to be used to create names for the
adjusted weight variable(s).  New variables are numbered from 1, unless the "pw" or "all" are
indicated for the {it:varspec}, in which case they are numbered from 0.

{p 0 4}{cmdab:prefix}{it:prefix}{cmd:)} specifies a prefix to be prepended to the existing
variable names used to create the adjusted weight variable(s).

{p 0 4}{cmd:replace} specifies that the adjusted variables should replace the existing variables.
This option should be used with caution.

{p 0 4}{cmd:modify} specifies that the adjusted variables should replace the existing variables, 
{it:but only for observations specified by the if or in condition(s)}.  Without if() or in()
conditions, {cmd:modify} and {cmd:replace} have the same effect.  With an {cmd:if} and/or {cmd:in}
restriction, {cmd:replace} will replace all other observations as missing, while {cmd:modify} will 
leave them as-is.
This option should be used with extreme caution.


{title:Examples}



{title:Methods and formulae for weight calculation}

{p}{cmd:survwgt create} only works for survey designs that exactly match the specificatons
for the type of weights requested (two PSUs per stratum for BRR, etc.)  Any collapsing of strata or
PSUs, splitting of certainty PSUs, or other adjustments to approximate the appropriate
design must be done outside of the program.

{p}The program creates k sets of replicate weights, where k is defined as discussed above for
the replication method.

{p}For the {cmd:BRR} method, the
the program selects one of the PSUs from each stratum, according to a Hadamard matrix
of the relevant dimension. For replicate {it:j}, the weights for each observation {it: i} are
calculated as follows:


     W    = W   * (2-k)         for observations in the PSU
      {it:ij}     {it:i}F                 selected into the replicate


          = W   * (k)           for observations in the other PSU
             {it:i}F

where

     W     is the full-sample weight for observation {it:i}, and
           {it:i}F

     k     is the constant for Fay's method.  For standard BRR, k=0.


{p}The program comes with an auxiliary binary file, survwgt_hadamardmatrixfile.ado,
which contains Hadamard matrices up to dimension 512.  These matrices are stored in a compressed binary format
to save disk space; the available matrix sizes can be obtained by typing
{cmd:survwgt create brr sizes}.  (Note: the binary file is named with an "ado" file
extension in order that it be installed in the correct directory by Stata's {help net:net install} and
{help ssc:ssc install} commands.  The file is not, in fact, a Stata program, and will issue
an appropriate error message if it is attempted to be run.)

{p}For the {cmd:JK1} method, the program creates one replicate per PSU.  In replicate {it:j}, the weights
for each observation {it:i} are calculated as follows:


     W    = 0                   for observations in PSU
      {it:ij}                                               {it:j}


          = W   * ( N/(N-1) )   for observations in other PSUs
             {it:i}F

where N is the number of PSUs, and W is defined as above.

{p}For the {cmd:JK2} method, the program creates one replicate per stratum.  In each replicate, the weights in the
selected stratum are doubled in the first PSU, and set to zero in the second PSU.  Weights in other strata
are not changed.

{p}For the {cmd:JKn} method, the program creates one replicate for PSU.  In each
replicate, the weights for each observation {it:i} are calculated as follows:

     W    = 0                   for observations in PSU  (from stratum {it:k})
      {it:ij}                                               {it:j}


          = W   * (N /(N -1))   for observations from other PSUs
             {it:i}F     {it:k}   {it:k}       in stratum {it:k}


          = W                   for observations in other strata
             {it:i}F

where

     N     is the number of PSUs in stratum {it:k}
      {it:k}



{title:Methods and formulae for variance estimation}

{p}The {cmd:svr} set of commands make use of the replication weights produced by {cmd:survwgt create}
to estimate (co)variances for parameters and other estimated quantities.  See {help svr} for a
list of these commands.  In general, the parameter
estimates are calculated by standard statistical commands using {help weight:aweights}, which
yields the same point estimates as Stata's linearization-based {help svy} commands for survey
data.  The (co)variances are calculated by repeatedly re-estimating the same parameters with
each of the set of replicate weights.  From these replicated estimates, the (co)variances are
calcuated as follows:


                 R
     V(b) = F * Sum( f *(b -b)(b -b)' )
                r=1   {it:r}   {it:r}     {it:r}

where

     R     is the number of replicates,

     b     is the vector of full sample point estimate(s),

     b     is the vector of estimates derived from replicate {it:r},
      {it:r}

     F     is a constant factor depending on the replication method, and

     f     is a replicate-specific factor.
      {it:r}


The values for F and f are:

     {cmd:method}      {cmd:F}           {cmd:f}

       BRR                 1/R          1

       Fay's variant  1/(R*(1-k)^2)     1
       of BRR

       JK1               (R-1)/R        1

       JK2                  1           1

       JKn                  1       (N -1)/N
                                      {it:k}     {it:k}



{title:Saved Results}

{p}The command saves no results, but it does set data {help char:characteristics} to
identify the full sample and replicate weight variables, degrees of freedom, fay constant for
BRR method, and replication method (BRR, JK1, JK2, or JKn).  The {help svrset} command
can be used to set, clear, or display these characteristics.


{title:References}

{p}Judkins, D. 1990.  Fay's Method for Variance Estimation.  Journal of Official
Statistics 16:25-45.

{p}Wolter, K. M. 1985. Introduction to Variance Estimation. New York: Springer-Verlag.


{title:Acknowledgements}

{p}I would like to thank Bobby Gutierrez at StataCorp for advice on implementation of BRR, and
the technical group at StataCorp for feedback on an early version of the BRR programs.  The code
for raking is partly based upon Nick Cox's program {help mstdize}.


{title:Author}

	Nicholas J. G. Winter
	University of Virginia
	nwinter@virginia.edu
