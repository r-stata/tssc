
{smcl}
{* *! version 1.0.0 May2014}{...}
{cmd:help xtcips}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{pstd}{cmd:xtcips} {hline 2} Pesaran Panel Unit Root Test in the Presence of Cross-section Dependence
{p2colreset}{...}


{title:Syntax}

{pstd}{cmd:xtcips} {varname} {ifin} {cmd:,} {cmdab:maxl:ags(#)} {cmdab:bgl:ags(}{it:numlist}{cmd:)} [ {cmd:q}  {cmdab:t:rend}  {cmdab:n:oc} ]



{p}{cmd:xtcips} is for use with balanced panel data.  You must {cmd:tsset} your
data before using {cmd:xtcips}, using the panel form of {cmd:tsset}; see help {help tsset}.

{p} {it:varname} may contain time-series operators; see help {help varlist}.


{title:Description}

 {p}{cmd:xtcips} estimates the CIPS test for unit roots in heterogeneous panels developed by Pesaran (2007; Section 4, p. 275-279).

 - There are three specifications of the deterministics:
      Case I: models without intercepts or trends (see {cmdab:n:oc} option)
      Case II: models with individual-specific intercepts ({bf:default})
      Case III: models with incidental linear trends (see {cmdab:t:rend} option)

 - It allows for individual dynamics specifications in each regression based in two alternative criterion (see {cmdab:maxl:ags(#)}): 
      i) Wald test of composite linear hypothesis about the parameters of the model ({bf:default})
      ii) Portmanteau (Q) test for white noise (see {cmd:q} option).

 - It reports the p-value of the serial correlation Breusch–Godfrey Lagrange multiplier test of each individual regression (see {cmdab:bgl:ags(}{it:numlist}{cmd:)} option)
  
The null hypothesis is (homogeneous non-stationary):

H0: bi = 0 for all i

against the possibly heterogeneous alternatives:

H1: bi < 0, i = 1, 2, . . . , N1 
    bi = 0, i = N1 + 1,N1 + 2, ... ,N

in the following cross-sectionally augmented DF (CADF) regression:

    D_yit = ai + bi * yi,t-1 + ci * MEAN_yt-1 + di * MEAN_D_yt + eit

{title:Options}

{p 0 4}{cmdab:maxl:ags(#)} positive integer. Sets individual dynamic specification. Indicates the maximum number of lags to be included in the model 
to be estimated for each cross-section. Then, {cmd:xtcips} determines the number of lags to include in each individual regression 
with an iterative process from 0 to {bf:maxlags}, based on the test's significance level set to select dynamics 
-reject H0 (at 5% or below) in the Wald test or do not reject (at 95% or above) H0 in the Portmanteau (Q)- or {bf:maxlags}, whichever comes first.

{p 0 4}{cmdab:bgl:ags(}{it:numlist}{cmd:)} sets the serial correlation order to be tasted with the 
Breusch–Godfrey Lagrange multiplier test in each individual regression. If a single
value is provided (positive integer), that order is used for all individuals. If a list of orders is 
provided, its length must match the number of individuals in the panel.

{p 0 4}{cmdab:t:rend} includes a time trend in the estimated equation (Case III).

{p 0 4}{cmd:q} sets Portmanteau (Q) test for white noise as the dynamics specification criterion.

{p 0 4}{cmdab:n:oc} suppress constant term (Case I).

{title:Saved results}

{pstd}
{cmd:xtcips} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(cips)}}CIPS statistic{p_end}

{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(cv)}}Critical values of average of individual cross-sectionally augmented Dickeyâ€“Fuller distribution{p_end}
{synopt:{cmd:r(W)}}Individual regression diagnostics{p_end}
{p2colreset}{...}

{title:References}

Pesaran, M. H. (2007). "A Simple Panel Unit Root Test In The Presence Of Cross-section Dependence."
Journal Of Applied Econometrics 22: 265–312


{title:Acknowledgements}

{p 0 0 2}This routine was made with the helpful advice of Tamara Burdisso. Any errors are my own.
I acknowledge useful comments made by Dr. Predrag Petrović from Institute of Social Sciences in Belgrade.

{title:Author}

Maximo Sangiacomo
{hi:Email:  {browse "mailto:msangia@hotmail.com":msangia@hotmail.com}}
