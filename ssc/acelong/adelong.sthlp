{smcl}
{* *! version 1.4 13mar2019}{...}
{vieweralsosee "[SEM] gsem" "mansection SEM gsem"}{...}
{vieweralsosee "[SEM] gsem postestimation" "mansection SEM gsempostestimation"}{...}
{vieweralsosee "[MME] meglm" "mansection MME meglm"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "gsem" "help gsem_command"}{...}
{vieweralsosee "gsem postestimation" "help gsem_postestimation"}{...}
{vieweralsosee "meglm" "help meglm"}{...}
{viewerjumpto "Syntax" "acelong##syntax"}{...}
{viewerjumpto "Description" "acelong##description"}{...}
{viewerjumpto "Options" "acelong##options"}{...}
{viewerjumpto "Stored results" "acelong##stored"}{...}
{viewerjumpto "Remarks" "acelong##remarks"}{...}
{viewerjumpto "References" "acelong##references"}{...}

{title:Title}

{phang}{bf:acelong} {hline 2} Multilevel mixed-effects ACE, AE and ADE variance decomposition models for "long" - one person per data row - formatted twin data (wrapper for {cmd:gsem})

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:acelong}
{depvar}
{varname:1}
{varname:2}
{varname:3}
[{indepvars}]
{ifin}
{weight}
[{cmd:,}{it: options}]

{p 8 17 2}
{cmd:aelong}
{depvar}
{varname:1}
{varname:2}
{varname:3}
[{indepvars}]
{ifin}
{weight}
[{cmd:,}{it: options}]

{p 8 17 2}
{cmd:adelong}
{depvar}
{varname:1}
{varname:2}
{varname:3}
[{indepvars}]
{ifin}
{weight}
[{cmd:,}{it: options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt rsg}}estimate ACE, AE or ADE variance decomposition using the {help acelong##RE2008:Rabe-Hesketh, Skrondal and Gjessing (2008)}-model (the default){p_end}
{synopt:{opt mp}}estimate ACE, AE or ADE variance decomposition using the {help acelong##MP2005:McArdle and Prescott (2005)}-model{p_end}
{synopt:{opt gw}}estimate ACE, AE or ADE variance decomposition using the {help acelong##GW2002:Guo and Wang (2002)}-model{p_end}
{synopt:{opt dzc(#)}}specifies the genetic within twin pair-correlation for dizygotic twin pairs; applicable with {opt rsg} or {opt mp}{p_end}
{synopt:{opt mzc(#)}}specifies the genetic within twin pair-correlation for monozygotic twin pairs; applicable with {opt rsg} or {opt mp}{p_end}
{synopt:{opt iwc}}first estimate a model without parameter constraints to initialize the behavioral genetic variance decomposition; applicable with {opt rsg} or {opt mp}{p_end}
{synopt:{opt tcr}}observed (Pearson) correlations of outcome for monozygotic (MZ) and dizygotic (DZ) twins; applicable with an uncensored linear model: {opt family(gaussian)} {opt link(identity)}{p_end}
{synopt:{opt total}}use observed total variance as denominator for %-variance decomposition; applicable with an uncensored linear model: {opt family(gaussian)} {opt link(identity)}; applicable without weights {p_end}
{synoptline}
{p2colreset}{...}
{p 4 4 2}Only one of options {opt rsg}, {opt mp} or {opt gw} is allowed.{p_end}
{p 4 4 2}For {cmd:acelong} and {cmd:aelong} {opt dzc(#)} has to be a real number > 0 and < 1 (the default is 0.5).{p_end}
{p 4 4 2}For {cmd:adelong} {opt dzc(#)} has to be a real number > 0.5 and < 1 (the default is 0.75).{p_end}
{p 4 4 2}{opt mzc(#)} has to be a real number > {opt dzc(#)} and <= 1 (the default is 1).{p_end}
{p 4 4 2}In addition, the options of {cmd:gsem} (see {help gsem_command}) except {opt noheader} and {opt notable} are allowed.{p_end}
{p 4 4 2}The {cmd:gsem} option {opt from()} is not allowed if the option {opt iwc} is specified.{p_end}
{p 4 4 2}Currently, the following combinations of {cmd:gsem} options {opt family()} and {opt link()} are supported by {cmd:acelong}, {cmd:aelong} and {cmd:adelong}:{p_end}
{p 8 8 2}{opt family(gaussian)} {opt link(identity)}: a linear behavioral genetic variance decomposition model (the default){p_end}
{p 8 8 2}{bf:family(}{it:gaussian}{bf:,} [{opt lcensored()}] [{opt rcensored()}]{bf:)} {opt link(identity)}: a linear behavioral genetic variance decomposition model with left-censored and/or right-censored observations{p_end}
{p 8 8 2}{opt family(bernoulli)} {opt link(probit)}: a (binary) probit behavioral genetic variance decomposition model{p_end}
{p 8 8 2}{opt family(bernoulli)} {opt link(logit)}: a (binary) logit behavioral genetic variance decomposition model{p_end}
{p 8 8 2}{opt family(ordinal)} {opt link(probit)}: an ordinal probit behavioral genetic variance decomposition model{p_end}
{p 8 8 2}{opt family(ordinal)} {opt link(logit)}: an ordinal logit behavioral genetic variance decomposition model{p_end}

{marker description}{...}
{title:Description}

{pstd}{cmd:acelong} estimates multilevel mixed-effects ACE variance decomposition models based on twin data formatted one twin per data row ("long" twin data format). An ACE variance
decomposition is a behavioral genetic analysis method which partitions the variance of an observed outcome (called phenotype) that varies within twin pairs into three latent components:{p_end}
{p 8 8 2}1) A component caused by additive genetic effects (A),{p_end}
{p 8 8 2}2) a component caused by environmental effects shared by both twins of a twin pair (C) and{p_end}
{p 8 8 2}3) a component caused by environmental effects which are unique to each twin (E).{p_end}
{pstd}{cmd:aelong} estimates multilevel mixed-effects AE variance decomposition models, i.e., a behavioral genetic variance decompositions without component 2) (C).{p_end}
{pstd}{cmd:adelong} estimates multilevel mixed-effects ADE variance decomposition models, i.e., a behavioral genetic variance decompositions with a component caused by dominant genetic effects (D).{p_end}

{pstd}CAUTION: Please verify that C is approximately 0 (using {cmd:acelong}) before estimating {cmd:aelong} or {cmd:adelong}!{p_end}

{pstd}The input data for {cmd:acelong} has to be a sample of monozygotic (MZ) and dizygotic (DZ) twin pairs formatted one twin (person) per data row ("long" twin data format).{p_end}

{pstd}{depvar}
{space 5}is the outcome variable.{p_end}
{pstd}{varname:1}
{space 3}is a variable containing the zygosity information of the twins. It has to be coded 1 for MZ twins and 2 for DZ twins.{p_end}
{pstd}{varname:2}
{space 3}is a variable identifying the twin pairs. It has to be unique for each twin pair, i.e., it has to vary on the twin pair-level.{p_end}
{p 4 16 2}{varname:3}
{space 3}is a variable identifying the twins within each twin pair. It has to be unique to each twin, i.e., it has to vary on the twin-level.{p_end}
{pstd}[{indepvars}]
is an optional set of variables on which the mean of the outcome is conditioned or regressed on.{p_end}

{pstd}The ACE, ADE and AE variance decomposition methods use knowledge and assumptions about the structure of genetic correlations between twins to identify the latent variance components. A
pair of MZ twins is genetically identical, i.e., its genetic correlation is 1. First, ACE and AE variance decompositions assume that genetic effects are additive which implies that there is
no epistasis, i.e., there are no interactions between genetic influences on the phenotype analysed. In consequence, the rules of Mendelian inheritance lead to the conclusion that the genetic
correlation within a pair of DZ twins is 0.5. In contrast, ADE variance decompositions presume that there are interactions between genetic influences inducing non-additive - dominant - genetic
effects. Here, the assumed genetic correlation within a pair of DZ twins is 0.75 with an additive genetic correlation of 0.5 and a dominant genetic correlation of 0.25. Second, it is presumed
that there is no assortative (i.e., no non-random) mating of the twins parents based on the phenotype considered. Third, it is assumed that environments effect MZ and DZ twin pairs equally with
respect to the development of the phenotype (also called "equal environment(s) assumption" and abbreviated EEA). Moreover, the AE and ADE variance decomposition methods assume that there are
no environmental effects shared by both twins of a twin pair (no C). For further details on the behavioral genetic foundations of the ACE, AE and ADE variance decomposition methods see
{help acelong##N2009:Neale (2009)}.
      
{pstd}Usually, ACE, AE and ADE variance decompositions are estimated using structural equation models (see {help acelong##FE2012:Franić et al. 2012}) based on twin data formatted one twin pair
per data row ("wide" twin data format). Outside the field of behavioral genetics using this "wide" data format is rather uncommon. In the last decade three different multilevel mixed-effects
models implementing ACE, AE and ADE variance decompositions based on twin data formatted one twin (person) per data row ("long" twin data format) have been developed (see
{help acelong##GW2002:Guo and Wang 2002}: {opt gw}, {help acelong##MP2005:McArdle and Prescott 2005}: {opt mp}, {help acelong##2008: Rabe-Hesketh et al. 2008}: {opt rsg}). {opt rsg} and {opt mp}
identify A and D, respectively, using random effects with equality constrains on their variances and fixed loadings mapping the assumed genetic correlation structures between twins. In Stata
these fixed loadings are implemented using weighting variables which are interacted with the respective random effects. Additionally, {opt rsg} and {opt mp} identify C using a random intercept
on the twin-pair level. In contrast, {opt gw} estimates a three-level random intercept model from which A, C and D, respectively, are derived using linear transformations. For all specifications
E is the residual variance of the model and all random effects are uncorrelated. 

{pstd}{opt rsg} uses 3 random effects for ACE, 2 random effects for AE and 4 random effects for ADE variance decompositions while {opt mp} uses 4 random effects for ADE, 3 random effects 
for AE and 6 random effects for ADE variance decompositions. In contrast, {opt gw} uses 2 random effects for all specifications. Hence, {opt gw} is almost always the computationally most
efficient model. Moreover, {opt gw} does not place the constraint that C in ACE variance decompositions - or A and D in ADE variance decompositions - have to be > 0. In principle, this
is a disadvantage since it allows the estimation of negative, i.e., implausible variance components. But this deficiency can be used to check which behavioral genetic variance decomposition is
appropriate for the data analyzed: A negative estimate for C or an estimate of C close to zero in ACE decompositions indicates that one should try an ADE decomposition. If the estimates
for A and D in this ADE decomposition are positive this is the appropriate model. Otherwise an AE decomposition should be used instead. Furthermore, an estimate of A close to zero in ACE
decompositions indicates that a "CE variance decomposition" - a standard (two-level) random intercept model - should be used. In consequence, it is advisable to estimate an ACE and an ADE variance
decomposition using {opt gw} as a first step of an analysis in order to find the adequate behavioral genetic variance decomposition. {opt rsg} is used as the default for {cmd:acelong}, {cmd:aelong}
and {cmd:adelong} since it is the computationally most efficient model placing the constraint that A, C and D, respectively, have to be > 0. Moreover, calling {cmd:gsem} with {opt rsg} and
{opt mp} stores the estimates of A, C and D, respectively, in {opt e()}. Therefore, the estimated variance components are accessible with {cmd:gsem postestimation} (see {help gsem_postestimation})
after using {opt rsg} or {opt mp}.

{pstd}{cmd:acelong}, {cmd:aelong} and {cmd:adelong} are wrappers for {cmd:gsem} facilitating the estimation of all three types of multilevel mixed-effects behavioral genetic variance decomposition
models in Stata. Furthermore, the commands calculate variance percentages of A, C, D and E, respectively, - %-variance decompositions - and enable the estimation of behavioral genetic variance
decompositions for censored continuous, binary and ordinal outcomes. {cmd:acelong}, {cmd:aelong} and {cmd:adelong} use {cmd:gsem} instead of {cmd:meglm} to estimate the multilevel mixed-effects
models because {cmd:gsem} supports a more flexible specification of random effects and related constraints. In principle, the {help acelong##GW2002:Guo and Wang (2002)}-model and the
{help acelong##MP2005:McArdle and Prescott (2005)}-model can also be estimated using {cmd:meglm}. For further details on {cmd:acelong}, {cmd:aelong} and {cmd:adelong} and the different
multilevel mixed-effects behavioral genetic variance decomposition models see {help acelong##L2017:Lang (2017)}. 
 
{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt rsg} Estimate ACE, AE or ADE variance decomposition using the {help acelong##RE2008:Rabe-Hesketh et al. (2008)}-model (the default). {opt rsg} uses two random effects with variances
constraint to be equal to identify A. One of these two random effects varies on the twin pair-level and is weighted with 1 for MZ twins and with sqrt(0.5) for DZ twins. The other one varies
on the twin-level and is weighted with 0 for MZ twins and with sqrt(0.5) for DZ twins. In consequence, {opt rsg} decomposes A into a random effect varying between twin pairs and a random
effect varying within DZ twin pairs. For {cmd:acelong} {opt rsg} uses a random intercept on the twin pair-level to identify C. For {cmd:adelong} {opt rsg} uses two further random effects
with variances constrained to be equal to identify D. One of these additional random effects varies on the twin pair-level and is weighted with 1 for MZ twins and with sqrt(0.25) for DZ
twins. The other one varies on the twin-level and is weighted with 0 for MZ twins and with sqrt(0.75) for DZ twins. Hence, {opt rsg} also decomposes D into a random effect varying between
twin pairs and a random effect varying within DZ twin pairs.{p_end}

{phang}
{opt mp} Estimate ACE, AE or ADE variance decomposition using the {help acelong##MP2005:McArdle and Prescott (2005)}-model. {opt mp} uses three random effects with variances constraint to be
equal to identify A. All three random effects vary on the twin pair-level. The first of these three random effects is weighted with 1 for MZ twins and with sqrt(0.5) for DZ twins. The second
is weighted with sqrt(0.5) for the first twin in a DZ twin pair and with 0 for MZ twins and the second twin in a DZ twin pair. The third is weighted with sqrt(0.5) for the second twin in a DZ
twin pair and with 0 for MZ twins and the first twin in a DZ twin pair. For {cmd:acelong} {opt mp} uses a random intercept on the twin pair-level to identify C. For {cmd:adelong} {opt mp}
uses three further random effects with variances constraint to be equal to identify D. These three random effects also vary on the twin pair-level. The first of these three random effects is
weighted with 1 for MZ twins and with sqrt(0.25) for DZ twins. The second is weighted with sqrt(0.75) for the first twin in a DZ twin pair and with 0 for MZ twins and the second twin in a DZ
twin pair. The third is weighted with sqrt(0.75) for the second twin in a DZ twin pair and with 0 for MZ twins and the first twin in a DZ twin pair.{p_end}

{phang}
{opt gw} Estimate ACE, AE or ADE variance decomposition using the {help acelong##GW2002:Guo and Wang (2002)}-model. For {opt gw} a three level data structure is created before the
estimation. Specifically, a level varying between twin pairs for MZ twins and within twin pairs for DZ twins (called "mixture-level") is defined in addition to the twin pair-level and the
twin-level. Next, a multilevel mixed-effects model with a random intercept on the twin pair-level {it:r1} and a random intercept on the "mixture-level" {it:r2} is estimated. Afterwards, A, C and
D are calculated as linear transformations of {it:r1} and {it:r2}. For {cmd:acelong} A is given by 2*{it:r2} and C by {it:r1} - {it:r2}. For {cmd:aelong} the variances of {it:r1} and {it:r2} are
constraint to be equal and in consequence, A is given by {it:r1} + {it:r2} or 2*{it:r1} or 2*{it:r2}. For {cmd:adelong} A is given by 3*{it:r1} - {it:r2} and D by 2*({it:r2} - {it:r1}).{p_end}

{phang}
{opt dzc(#)} replaces the default genetic within twin pair-correlation for DZ twins with the number specified in the option. For {cmd:acelong} and {cmd:aelong} this default correlation
is 0.5 and for {cmd:adelong} it is 0.75. Specifically, for {cmd:acelong} and {cmd:aelong} {opt dzc(#)} replaces the additive genetic within twin pair-correlation for DZ twins with the 
specified number. For {cmd:adelong} {opt dzc(#)} replaces the dominant genetic within twin pair-correlation for DZ twins with the specified number minus 0.5 while the additive genetic 
correlation of 0.5 remains unchanged. {opt dzc(#)} can be used to asses the sensitivity of behavioral genetic variance decompositions with respect to "minor" deviations from the assumed genetic
within twin pair-correlations for DZ twins. E.g., such deviations can be due to selective sampling of twin pairs with respect to their genotype. Technically, {opt dzc(#)} can be a real
number > 0 and < 1 for {cmd:acelong} and {cmd:aelong} and a real number > 0.5 and < 1 for {cmd:adelong}. But substantially, {opt dzc(#)} should only be used for sensitivity analyses in a much
smaller range of values (e.g., 0.4 to 0.6 for {cmd:acelong} and {cmd:aelong} and 0.65 to 0.85 for {cmd:adelong}). A typical application for {opt dzc(#)} is to assess the effect of assortative
mating of parents on the behavioral genetic variance decomposition ({help acelong##LE2009:Loehlin et al. (2009)}). Here, {opt dzc(#)} is set to 0.5 + 0.5*h^2*r with h^2
the heritability (i.e., share of variance for A) estimated given the assumption of no assortative mating (i.e., given the default genetic within twin pair-correlation for DZ twins) and r the
correlation of parents on the phenotype analyzed. r needs to be observed in the sample analyzed, taken from secondary data sources or assumed. If the genetic within twin pair-correlation for
DZ twins differs substantially from the default values assumed the respective behavioral genetic variance decomposition is not appropriate for the data analyzed. A sensitivity analysis
based on such an inappropriate method will give no informative results. If the genetic within twin pair-correlation for DZ twins is expected to be much larger than 0.5 due to
non-additive genetic effects an ADE variance decomposition should be used. Since {opt dzc(#)} modifies the weighting variables interacted with the random effects for A and D it is only
applicable with options {opt rsg} or {opt mp} which use these weighting variables.{p_end}

{phang}
{opt mzc(#)} replaces the default genetic within twin pair-correlation for MZ twins of 1 with the number specified in the option. {opt mzc(#)} can be used like {opt dzc(#)} and has to be a
real number which is larger than the assumed genetic within twin pair-corrlation of DZ twins (> {opt dzc(#)}) as well as not larger than 1. An application are analyses in which sex-differences
within twin pairs are used as a proxy for zygosity. In such a case, it is know that opposite-sex twin pairs are dizygotic and under the assumption that same-sex and opposite-sex dizygotic
twin births are equally likely, the number of monozygotic twin pairs among same-sex twin pairs is given by the number of same-sex twin pairs (ss) minus the number of opposite-sex twins pairs
(os). This information can be just to adjust the assumed genetic within twin pair-correlation for MZ twins ({help acelong##FE2017:Figlio et al. (2017)}) which is than given by: (ss − os)/ss + dzc*(os/ss)
with dzc the assumed genetic within twin pair-correlation for DZ twins which is typically 0.5. Since {opt mzc(#)} modifies the weighting variables interacted with
the random effects for A and D it is only applicable with options {opt rsg} or {opt mp} which use these weighting variables.{p_end}

{phang}
{opt iwc} Informs {cmd:acelong}, {cmd:aelong} or {cmd:adelong} to first estimate a model without equality constraints on the variance parameters to initialize the behavioral genetic variance
decomposition. {opt iwc} is only applicable with options {opt rsg} or {opt mp} which always use equality constraints on the variances of A and D. {opt iwc} can not be combined with the {cmd:gsem}
option {opt from()}.{p_end}

{phang}
{opt tcr} If {opt tcr} is specified {cmd:acelong}, {cmd:aelong} or {cmd:adelong} additionally calculate the observed (Pearson) correlations of the outcome for MZ and DZ twins. These
correlations can be used to derive A, C and E based on Falconer's formula ({help acelong##FM1996:Falconer and McKay 1996}) and linear transformations instead of the structural equation or
multilevel mixed-effect models typically used nowadays. Specifically, the correlation of the outcome for MZ twins (MZr) = A + C and the correlation of the outcome for DZ twins (DZr) = .5*A + C
if .5 is the assumed genetic correlation between DZ twins. In consequence, A = 2(MZr - DZr), C = MZr - A and E = 1 - MZr. Therefore, MZr and DZr can be used to assess if an ACE-model is suitable
for the data analysed: If MZr > 2*DZr it follows that C < 0. In this case an AE- or ADE-model should be used instead. Since MZr and DZr have to be observed {opt tcr} is only available for
uncensored linear models ({opt family(gaussian)} {opt link(identity)}). If {opt tcr} is specified MZr and DZr as well as the respective standard errors and confidence intervals are stored in
{cmd:r(b)}, {cmd:r(se)} and {cmd:r(ci)}.{p_end}

{phang}
{opt total} Instructs {cmd:acelong}, {cmd:aelong} or {cmd:adelong} to calculate the %-variance decomposition using the observed total variance as denominator. By default the sum of A, C, D and E,
respectively, is used as denominator for the %-variance decomposition. {opt total} is only allowed with uncensored linear models ({opt family(gaussian)} {opt link(identity)}) without weights since
this is the only type of model for which the total variance is observed, i.e., defined independent of the model specified. If no {indepvars} are specified the total variance equals the sum of A, C,
D and E, respectively. If {indepvars} are specified the total variance minus the sum of A, C, D and E, respectively, equals the variance explained by the {indepvars}. For the %-variance decomposition
this is the R2 of the model in %.{p_end}

{marker stored}{...}
{title:Stored results}

{pstd}
{cmd:acelong}, {cmd:aelong} and {cmd:adelong} store the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(gmzc)}}the assumed genetic correlation for MZ twins{p_end}
{synopt:{cmd:r(gdzc)}}the assumed genetic correlation for DZ twins{p_end}
{synopt:{cmd:r(level)}}the confidence level for the confidence intervals of the variance decomposition{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(b)}}the coefficient vector of the variance decomposition{p_end}
{synopt:{cmd:r(se)}}the standard error vector of the variance decomposition{p_end}
{synopt:{cmd:r(ci)}}the matrix containing the confidence intervals of the variance decomposition{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:In addition, all results {cmd:gsem} stores in {cmd:e()} after being called by {cmd:acelong}, {cmd:aelong} or {cmd:adelong} are available.}{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}For feedback and questions regarding {cmd:acelong}, {cmd:aelong} or {cmd:adelong} please contact:{p_end}

{p 8 8 2}Volker Lang, Bielefeld University: {it:volker.lang@uni-bielefeld.de}{p_end}

{pstd}If you use {cmd:acelong}, {cmd:aelong} or {cmd:adelong} for your research please cite it as follows:{p_end}

{p 8 8 2}Lang, V. 2017. {it:ACELONG: Stata module to fit multilevel mixed-effects ACE, AE and ADE variance decomposition models}. Statistical Software Components S458402, Boston College Department of
Economics. {browse "https://ideas.repec.org/c/boc/bocode/s458402.html"}{p_end}

{marker references}{...}
{title:References}

{marker FM1996}{...}
{phang}
Falconer, D. S., T. F. C. McKay. 1996. {it:Introduction to Quantitative Genetics}. 4th Edition. Essex: Pearson Education. ISBN: 9780582243026{p_end}

{marker FE2017}{...}
{phang}
Figlio, D.N., J. Freese, K. Karbownik, and J. Roth. 2017. {it:Socioeconomic status and genetic influences on cognitive development}. Proceedings of the National Academy of Sciences of the United
States of America 114/51, pp 13441-13446. doi: {browse "http://dx.doi.org/10.1073/pnas.1708491114"}{p_end}

{marker FE2012}{...}
{phang}
Franić, S., C. V. Dolan, D. Borsboom, and D. I. Boomsma. 2012. {it:Structural equation modeling in genetics}. In: R. H. Hoyle. Handbook of Structural Equation Modeling. New York: Guilford Press, pp 617-635. ISBN: 9781606230770{p_end}

{marker GW2002}{...}
{phang}
Guo, G., and J. Wang. 2002. {it:The mixed or multilevel model for behavior genetic analysis}. Behavior Genetics 32/1, pp 37-49. doi: {browse "http://dx.doi.org/10.1023/A:1014455812027"}{p_end}

{marker L2017}{...}
{phang}
Lang, V. 2017. {it:ACELONG: Stata module to fit multilevel mixed-effects ACE, AE and ADE variance decomposition models}. Statistical Software Components S458402, Boston College Department of
Economics. {browse "https://ideas.repec.org/c/boc/bocode/s458402.html"}{p_end}

{marker LE2009}{...}
{phang}
Loehlin, J.C., Harden, K.P., and Turkheimer, E. 2009. {it:The effect of assumptions about parental assortative mating and genotype–income correlation on estimates of genotype–environment interaction in the National Merit
Twin Study}. Behavior Genetics 39/2, pp 165-169. doi: {browse "http://dx.doi.org/10.1007/s10519-008-9253-9"}{p_end}

{marker MP2005}{...}
{phang}
McArdle, J. J. and C. A. Prescott. 2005. {it:Mixed-effects variance components models for biometric family analyses}. Behavior Genetics 35/5, pp 631–652. doi: {browse "http://dx.doi.org/10.1007/s10519-005-2868-1"}{p_end}

{marker N2009}{...}
{phang}
Neale, M. C. 2009. {it:Biometrical models in behavioral genetics}. In: Y.-K. Kim. Handbook of Behavior Genetics. New York: Springer, pp 15-33. doi: {browse "http://dx.doi.org/10.1007/978-0-387-76727-7_2"}{p_end}

{marker RE2008}{...}
{phang}
Rabe-Hesketh, S., A. Skrondal, and H. K. Gjessing. 2008. {it:Biometrical modeling of twin and family data using standard mixed model software}. Biometrics 64/1, pp 280–288. doi: {browse "http://dx.doi.org/10.1111/j.1541-0420.2007.00803.x"}
