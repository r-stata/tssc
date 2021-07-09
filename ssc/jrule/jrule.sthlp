{smcl}
{* *! version 1.0, 04May2018}
{title:Title}

{bf:jrule} - Stata module to detect model misspecifications in SEM

{title:Syntax}

{p 8 14 2}{cmd:jrule} [, {it:options}]

{synoptset 12 tabbed}{...}
{synopthdr}
{synoptline}
{synopt : {ul:d}elta(#)}Standardized size of misspecification to detect; default (.10){p_end}
{synopt : {ul:p}ower(#)}Threshold for 'high' power values; default (.80){p_end}
{synopt : {ul:min}chi(#)}Minimum MI displayed; default is only significant MI (3.841){p_end}
{synopt : {ul:ca}lpha(#)}Critical alpha level for power calculation; default (.05){p_end}
{synopt : {ul:df}test(#)}Changing d.f. for power calculation; default (1){p_end}
{p2colreset}{...}

{title:Description}

{bf:jrule} is a postestimation tool for the {bf:sem} command, using stored results from 
{bf:estat mindices}. It provides judgement rules for potential misspecifications based 
on the power of the Modification Index (MI) or score test in combination with the 
Expected Parameter Change (EPC). {bf:jrule} makes use of the recommendations and formulae 
provided by Saris et al. (2009) and Van der Veld et al. (2008). The {bf:jrule} command 
prints decision rules on possible misspecifications following their scheme.

Several judgement rules can be set in the {bf:jrule} command: {it:delta} specifies the minimum 
size of the misspecification that one would like to detect by the test with a certain 
{it:power} and critical alpha-level ({it:calpha}) of the test. As the default, only significant 
MI values ({it:minchi}) are shown.

The default size for detecting misspecifications (Delta) is .10, whereas Van der Veld 
et al. (2008) further suggest:
misspecifications >=.10 for correlations/(causal) effects
misspecifications >=.40 for factor loadings
misspecifications >=.05 for means/intercepts. 

Because the unstandardized EPC is dependent upon the scaling of the variables in the 
model (Chou & Bentler, 1993), {bf:jrule} uses an unstandardized Delta (dw) for all the
computations, identical to the LISREL add-on JRule (Van der Veld et al., 2008). In 
fact, the size of a misspecification thus refers to the standardized EPC (StdYX_EPC). 
A ratio of |EPC|/dw => 1 would then suggest a relevant misspecification, whereas in 
case of a small ratio (< 1) there is likely no serious misspecification.

{title:Notes}

The parameters are computed as follows:
dw is the original Delta times EPC scaling weight (StdYX_EPC/EPC; Chou & Bentler, 1993): 
dw = (Delta*EPC)/StdYX_EPC; where Delta = .10 as default
The noncentrality parameter: ncp = (MI/EPC^2)*dw^2
Power = nchi2tail(d.f., ncp, chi2-critical); where d.f. = 1 and chi2 = 3.841 as default

{title:Authors}

Julian Aichholzer, University of Vienna (julian.aichholzer@univie.ac.at)

Recommended citation:
Aichholzer, J. (2018). JRULE: Stata module to detect model misspecifications in SEM (v1.0).
Boston College Department of Economics: Statistical Software Components (SSC) Archive.

{title:References}

Chou, C. P., & Bentler, P. M. (1993). 
Invariant standardized estimated parameter change for model modification in covariance structure analysis. 
{it:Multivariate Behavioral Research}, 28(1), 97-110.

Saris, W. E., Satorra, A., & Van der Veld, W. M. (2009). 
Testing structural equation models or detection of misspecifications?
{it:Structural Equation Modeling}, 16(4), 561-582.

Van der Veld, W. M., Saris, W. E., & Satorra, A. (2008). 
JRule 3.0: User's Guide.
