{smcl}
{hline}
help for {cmd:lincomest} {right:(Roger Newson)}
{hline}


{title:Linear combinations of estimators saved as estimation results}

{p 8 15}{cmd:lincomest} [{it:{help exp}}] [ {cmd:,}
 {cmdab:l:evel}{cmd:(}{it:#}{cmd:)} {cmdab:ef:orm}{cmd:(}{it:string}{cmd:)}
 {cmdab:ho:ldname}{cmd:(}{it:holdname}{cmd:)} ]

{pstd}
where {it:holdname} is a name under which any pre-existing estimation results will be held,
and {it:{help exp}} is any linear combination of coefficients that is valid syntax for {helpb test}.
Note, however, that {it:{help exp}} must not contain any additive constants or equal signs.


{title:Description}

{pstd}
{cmd:lincomest} is an extension to {helpb lincom}, which calculates confidence intervals and
{it:P}-values for linear combinations of model coefficients.
{cmd:lincomest} saves the estimate and variance
of the linear combination as {help estimates:estimation results},
with the option of saving the existing estimation results to be recalled by {helpb _estimates:_estimates unhold}
or by {helpb estimates:estimates restore}.
The advantage of doing this is that the linear combination can be output by {helpb estimates:estimates table},
or input to {helpb parmest} to create an output dataset (or resultsset)
with one observation containing a confidence interval and {it:P}-value for the linear combination.
This dataset can be concatenated with other {helpb parmest} output datasets using {helpb dsconcat},
and the confidence intervals and/or {it:P}-values can then be plotted and/or tabulated.


{title:Options}

{p 0 4}{cmd:level(}{it:#}{cmd:)} specifies the confidence level, in percent, for confidence intervals;
see help for {helpb level}.

{p 0 4}{cmd:eform(}{it:string}{cmd:)} specifies that the linear combination and its confidence
limits must be reported in exponentiated form, as {hi:exp(b)} rather than {hi:b}, and labelled by the {it:string}.
If {cmd:eform()} is not specified, then the linear combination is reported in
unexponentiated form, unless the last estimation command was {helpb logistic}, in which case
the linear combination is reported in exponentiated form, with the {cmd:eform()} option set to {hi:"Odds ratio"}.
Whether or not {cmd:eform()} is specified, {cmd:lincomest} always stores
the unexponentiated estimates in the {helpb estimates:estimation results}.

{p 0 4}{cmd:holdname(}{it:holdname}{cmd:)} specifies that the existing estimation results are to
be stored under the name of {it:holdname}.
They can then be restored by {helpb _estimates:_estimates unhold}.
The {cmd:holdname()} option was inherited from the Stata 7 version of {cmd:lincomest},
and is retained mainly so that old do-files will still work.
Under Stata version 8 or above,
the preferred way of storing the old estimation results is {helpb estimates:estimates store},
and the preferred way of restoring them is {helpb estimates:estimates restore}.


{title:Remarks}

{pstd}
{cmd:lincomest} is intended to be used with {helpb parmest}, which saves the current
estimation results as an output dataset (or resultsset)
with one observation per parameter of the most recently fitted model.
This new dataset is used to create tables and/or plots of confidence intervals and/or {it:P}-values.
Other programs that are very useful with {helpb parmest} are {helpb dsconcat},
{helpb descsave}, {helpb factext} and {helpb sencode}.
The latest versions of all these programs can be installed from {help ssc:SSC}, using the {helpb ssc} command.
For more information about the use of {helpb parmest} resultssets,
see Newson (2003), Newson (2004) and Newson (2006).


{title:Examples}

{pstd}
The following example will work with the {hi:auto} data if {helpb parmest} and {helpb dsconcat} are installed.
It will create a dataset of confidence intervals of the parameters corresponding to values of the factor {hi:rep78}.

{p 16 20}{inp:. tempfile tf1 tf2}{p_end}
{p 16 20}{inp:. xi:regress mpg i.rep78}{p_end}
{p 16 20}{inp:. parmest,label saving(`tf1',replace)}{p_end}
{p 16 20}{inp:. lincomest (_Irep78_2+_Irep78_3+_Irep78_4+_Irep78_5)/4}{p_end}
{p 16 20}{inp:. parmest,label saving(`tf2',replace)}{p_end}
{p 16 20}{inp:. dsconcat `tf1' `tf2'}{p_end}
{p 16 20}{inp:. list parm label estimate min95 max95 p}{p_end}

{pstd}
The following example demonstrates the use of {cmd:lincomest} with {helpb parmest}
and the {helpb estimates} utility.
It will save estimates, confidence limits and {it:P}-values for a ratio of odds ratios,
and then restore the original estimation results to be printed again.

{p 16 20}{inp:. logit foreign length weight}{p_end}
{p 16 20}{inp:. estimates store oldest}{p_end}
{p 16 20}{inp:. lincomest 30*length-1000*weight,eform(OR)}{p_end}
{p 16 20}{inp:. parmest,label saving(lincom1.dta,replace) eform}{p_end}
{p 16 20}{inp:. estimates restore oldest}{p_end}
{p 16 20}{inp:. logit,or}{p_end}


{title:Saved results}

{pstd}
{cmd:lincomest} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(N_strata)}}number of strata{p_end}
{synopt:{cmd:e(N_psu)}}number of sampled PSUs{p_end}
{synopt:{cmd:e(deff)}}DEFF result{p_end}
{synopt:{cmd:e(deft)}}DEFT result{p_end}
{synopt:{cmd:e(meft)}}MEFT result{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:lincomest}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable(s){p_end}
{synopt:{cmd:e(predict)}}program called by {cmd:predict} ({cmd:lincomest_p}){p_end}
{synopt:{cmd:e(formula)}}linear combination expression{p_end}
{synopt:{cmd:e(holdname)}}{cmd:holdname()} option{p_end}
{synopt:{cmd:e(properties)}}{hi:b V}{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}

{pstd}
The scalar results {cmd:e(N_strata)}, {cmd:e(N_psu)}, {cmd:e(deff)}, {cmd:e(deft)} and {cmd:e(meft)}
are only returned if the previous estimation command was a {help svy:survey command},
and are equal to the scalar results of the same names
returned in {cmd:r()} by {helpb lincom} after {help svy:survey commands}.
The program {cmd:lincomest_p}, called by {helpb predict} after {cmd:lincomest},
tells the user that {helpb predict} should not be used after {cmd:lincomest}.

{pstd}
All of these estimation results
can be stored as variables in a {helpb parmest} output dataset (or resultsset) if the user specifies the
{cmd:emac()}, {cmd:escal()}, {cmd:evec()}, {cmd:erows()} and/or {cmd:ecols()} options of {helpb parmest}.
They can also be tabulated using {helpb estimates:estimates table}.


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{phang}
Newson, R.  2003.
Confidence intervals and {it:p}-values for delivery to the end user.
{it:The Stata Journal} 3(3): 245-269}.
Download from
{browse "http://www.stata-journal.com/article.html?article=st0043":The Stata Journal website}.

{phang}
Newson, R.  2004.
From datasets to resultssets in Stata.
Presented at
{browse "https://ideas.repec.org/p/boc/usug04/16.html":the 10th United Kingdom Stata Users' Group Meeting, London, 29 June, 2004}.

{phang}
Newson, R.  2006.
Resultssets, resultsspreadsheets, and resultsplots in Stata.
Presented at
{browse "https://ideas.repec.org/p/boc/dsug06/01.html":the 4th German Stata User Meeting, Mannheim, 31 March, 2006}.


{title:Also see}

{p 0 10}
{bind: }Manual:   {hi:[R] lincom}, {hi:[R] xi}, {hi:[P] estimates}, {hi:[U] 20 Estimation and post-estimation commands}
{p_end}
{p 0 10}
On-line:   help for {helpb lincom}, {helpb estimates}, {helpb _estimates}, {helpb xi}
 {break} help for {helpb descsave}, {helpb dsconcat}, {helpb factext}, {helpb metaparm}, {helpb parmest}, {helpb sencode}
if installed
{p_end}
