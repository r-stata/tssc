{smcl}
{* *! 20oct2017}{...}
{cmd:help xtgcause}
{hline}


{title:Title}

{p 4 18 2}
{hi:xtgcause} {hline 2} Testing for Granger causality in panel data
{p_end}


{title:Syntax}

{p 4 12 2}
{cmd:xtgcause} {it:depvar} {it:indepvar}
{ifin}{cmd:,} 
[{cmdab:l:ags(}{it:lags_spec}{cmd:)}
{cmdab:reg:ress}
{cmdab:boot:strap}
{cmdab:br:eps(}{it:#}{cmd:)}
{cmdab:blev:el(}{it:#}{cmd:)}
{cmdab:blen:gth(}{it:#}{cmd:)}
{cmd:seed(}{it:#}{cmd:)}
{cmd: nodots}]



{title:Description}

{pstd}
{cmd:xtgcause} allows to test for Granger non-causality from {it:indepvar} to {it:depvar} 
in heterogeneous panels using the procedure proposed by Dumitrescu & Hurlin (2012).


{title:Options}

{phang}{cmd:lags(}{it:lags_spec}{cmd:)} specifies the lag structure to use for the 
regressions performed in computing the test statistic. 

{pmore}
{it:lag_spec} is either a positive integer or one of aic, bic, or hqic possibly 
followed by a positive integer. 
By default, {cmd:lags(}{it:lags_spec}{cmd:)} is set to {cmd:lags(}1{cmd:)}.

{pmore}
Specifying {cmd:lags(}{it:#}{cmd:)} requests that {it:#} lag(s) of the series 
be used in the regressions. The maximum authorized number of lags is such 
that {it:T > 5+3#}.

{pmore}
Specifying {cmd:lags(}{it:aic|bic|hqic [#]}{cmd:)} requests that the number of lags of the 
series be chosen such that the average Akaike/Bayesian/Hannan-Quinn information criterion (AIC/BIC/HQIC) 
for the set of regressions is minimized. Regressions with 1 to {it:#} lags will be conducted, 
restricting the number of observations to {it:T-#} for all estimations to make the models nested 
and therefore comparable. Displayed statistics come from the set of regressions for which 
the average AIC/BIC/HQIC is minimized (re-estimated using the total number of observations available). 
If {it:#} is not specified in {cmd:lags(}{it:aic|bic|hqic [#]}{cmd:)}, then it is set to the maximum 
number of lags authorized.

{phang}{cmd:regress} can be used to display the results of the {it:N} individual regressions 
on which the test is based. This option is useful to have a look at the coefficients of 
individual regressions. When the number of individuals in the panel is large, this option 
will result in a very long output.

{phang}{cmd:bootstrap} requests p-values and critical values to be computed
using a bootstrap procedure proposed in section 6.2 of Dumitrescu & Hurlin (2012).
Boostrap is useful in presence of cross-sectional dependence.

{pmore}
{cmd:breps(}{it:#}{cmd:)} indicates the number of bootstrap replications
to perform. By default, it is set to 1000.

{pmore}
{cmd:blevel(}{it:#}{cmd:)} indicates the number of significance level (in %)
for computing the bootstrapped critical values. By default, it is set to 95%.

{pmore}
{cmd:blength(}{it:#}{cmd:)} indicates the size of the block length to 
be used in the bootstrap. By default, each time period is sampled
independently with replacement ({cmd:blength(}1{cmd:)}). 
{cmd:blength(}{it:#}{cmd:)} allows to implement the bootstrap by dividing the 
sample into block of {it:#} time periods and sampling the blocks independently 
with replacement. Using blocks of more than one time periods is useful if 
autocorrelation is suspected.

{pmore}
{cmd:seed(}{it:#}{cmd:)} can be used to set the random-number seed.
By default, the seed is not set. 

{pmore}
{cmd:nodots} suppresses replication dots. By default, a dot is printed
for each replication to provide an indication of the evolution of the
bootstrap.

{pmore}
{cmd:breps}, {cmd:blevel}, {cmd:blength}, {cmd:seed}, and {cmd:nodots}
are {cmd:bootstrap} suboptions. They can only be used if {cmd:bootstrap} is 
also specified.


{title:Saved results}

{pstd}{cmd:xtgcause} saves the following results in {cmd:r()}:
{synoptset 20 tabbed}{...}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(wbar)}}average Wald statistic{p_end}
{synopt:{cmd:r(lags)}}number of lags used for the test{p_end}
{synopt:{cmd:r(zbar)}}Z-bar statistic{p_end}
{synopt:{cmd:r(zbar_pv)}}p-value of the Z-bar statistic{p_end}
{synopt:{cmd:r(zbart)}}Z-bar tilde statistic{p_end}
{synopt:{cmd:r(zbart_pv)}}p-value of the Z-bar tilde statistic{p_end}

{p2col 5 20 24 2: Additional scalars if bootstrap is used}{p_end}
{synopt:{cmd:r(zbarb_cv)}}critical value for the Z-bar statistic{p_end}
{synopt:{cmd:r(zbartb_cv)}}critical value for the Z-bar tilde statistic{p_end}
{synopt:{cmd:r(breps)}}number of bootstrap replications{p_end}
{synopt:{cmd:r(blevel)}}significance level for bootstrap critical values{p_end}
{synopt:{cmd:r(blength)}}size of the block length{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(Wi)}}individual Wald statistics{p_end}
{synopt:{cmd:r(PVi)}}p-values of the individual Wald statistics{p_end}

{p2col 5 20 24 2: Additional matrices if bootstrap is used}{p_end}
{synopt:{cmd:r(ZBARb)}}Z-bar statistics from bootstrap procedure{p_end}
{synopt:{cmd:r(ZBARTb)}}Z-bar tilde statistics from bootstrap procedure{p_end}


{title:Example}

{phang} The dataset Data_demo.xls used in this example is provided by
Dumitrescu and Hurlin at {browse "http://www.runmycode.org/companion/view/42"},
along with a few results.

{phang2}{cmd:. import excel using Data_demo.xls, clear}{p_end}
{phang2}{cmd:. ren (A-J) x#, addnumber}{p_end}
{phang2}{cmd:. ren (K-T) y#, addnumber}{p_end}
{phang2}{cmd:. gen t = _n}{p_end}
{phang2}{cmd:. reshape long x y, i(t) j(id)}{p_end}
{phang2}{cmd:. xtset id t}{p_end}
{phang2}{cmd:. xtgcause y x, lag(1)}{p_end}


{title:References}

{pstd}
Dumitrescu E-I & Hurlin C (2012): "Testing for Granger non-causality in heterogeneous panels", 
{it:Economic Modelling}, {bf:29}: 1450-1460.

{pstd}
Lopez L & Weber S (2017): "Testing for Granger causality in panel data", 
{it:IRENE Working Paper 17-03}, Institute of Economic Research, 
University of Neuchâtel, {browse "https://ideas.repec.org/p/irn/wpaper/17-03.html"}.


{title:Authors}

{pstd}
Luciano Lopez{break}
University of Neuchâtel{break}
Institute of Economic Research{break}
Neuchâtel, Switzerland{break}
{browse "mailto:luciano.lopez@unine.ch?subject=Question/remark about -xtgcause-&cc=sylvain.weber@unine.ch":luciano.lopez@unine.ch}

{pstd}
Sylvain Weber{break}
University of Neuchâtel{break}
Institute of Economic Research{break}
Neuchâtel, Switzerland{break}
{browse "mailto:sylvain.weber@unine.ch?subject=Question/remark about -xtgcause-&cc=luciano.lopez@unine.ch":sylvain.weber@unine.ch}


{title:Acknowledgement}

{pstd}
We are indebted to David Ardia (University of Neuchâtel) for his valuable advice 
on the bootstrap procedure. We also thank Gareth Thomas (IHS Markit EViews) for 
his comments regarding the procedure to determine the optimal lag order 
based on information criteria.
