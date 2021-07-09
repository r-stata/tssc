{smcl}
{* *! version 1.1 27may2015}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Main network help page" "network"}{...}
{vieweralsosee "mvmeta (if installed)" "mvmeta"}{...}
{viewerjumpto "Syntax" "network_meta##syntax"}{...}
{viewerjumpto "Description" "network_meta##description"}{...}
{viewerjumpto "Difficulties" "network_meta##Difficulties"}{...}
{viewerjumpto "Examples" "network_meta##examples"}{...}
{title:Title}

{phang}
{bf:network meta} {hline 2} Perform network meta-analysis under consistency or inconsistency model


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:network meta} [{opt c:onsistency}|{opt i:nconsistency}] {ifin}
[{cmd:,}
{it:mvmeta_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt reg:ress(varlist)}}Specify covariates for network meta-regression. 
Every treatment contrast is allowed to depend on the covariate(s) listed.
This option is currently only allowed in augmented format.{p_end}
{synopt:{opt eq:uations(suboptions)}}Equations option for {help mvmeta}: 
can be used to perform network meta-regression. 
If variables _y_* hold the treatment effects then {cmd:eq(_y_*:x)} is equivalent to {cmd:regress(x)}.
This option is only sensible in augmented format.{p_end}
{synopt:{opt lua:des}[{it:(treatment_list)}]}For the inconsistency model, 
this option gives the model of {help network##LuAdes06:Lu and Ades (2006)} 
as formalised by {help network##Higgins++12:Higgins et al (2012)}.
With only two-arm studies, this is the same as the design-by-treatment interaction model 
of {help network##Higgins++12:Higgins et al (2012)}.
With multi-arm studies, the Lu-Ades model is smaller than the design-by-treatment interaction model
and depends on the treatment ordering. 
The optional argument specifies an ordering of the treatments; 
the reference treatment should not be included in this argument as it is always placed first. 
(The reference treatment can be changed by {help network convert}).
This option is only available in augmented format.{p_end}
{synopt:{opt force}}Force model fitting when {cmd:network meta} detects one of the difficulties described {help network_meta##Difficulties:below}.{p_end}
{synopt:{opt nowar:nings}}Suppress warning messages (not recommended).{p_end}
{synopt:{it:mvmeta_options}}Other options for {help mvmeta}: 
for example, {cmd:bscov(uns)} could be used to over-ride the standard "common heterogeneity" model.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}


{marker description}{...}
{title:Description}

{pstd}
{cmd:network meta} defines a model to be fitted:
either the consistency model or the 
{help network##Higgins++12:design-by-treatment interaction inconsistency model}.
It can handle data in any of the three network formats:
if data are in the {cmd:augmented} or {cmd:standard} formats
then the models are fitted using {help mvmeta};
if data are in the {cmd:pairs} formats
then the models are fitted using {help metareg}.
{help mvmeta} or {help metareg} must have been installed.

{pstd}
{cmd:network meta} fits the chosen model. It then stores the fitted values in a matrix 
(by default called _network_consistency or _network_inconsistency)
for use in {help network_forest:network forest}.
If the inconsistency model is fitted, then a Wald test for inconsistency is also defined and performed.
The {cmd:mvmeta} or {cmd:metareg} command used 
can be recalled by pressing F9.
The command to test for inconsistency, if used, can be recalled by pressing F8.

{pstd}By default, {cmd:network meta} uses a structured between-studies covariance matrix which 
assumes that all treatment contrasts have the same heterogeneity variance. 

{pstd}If neither consistency nor inconsistency is specified then the previous {cmd:mvmeta} model is rerun.


{title:Which network format is best? }

{pstd}You should be able to get identical results using the {cmd:standard} and {cmd:augmented} formats. 
You should be able to match these results using the {cmd:pairs} format 
provided you have only two-arm trials, 
but if you have multi-arm trials then the results using the {cmd:pairs} format will be wrong.
If you want to estimate the best treatment (see {help network rank}),
then you will need to fit the models using the {cmd:augmented} format. 


{marker Difficulties}{...}
{title:Difficulties}

{pstd}{cmd:network meta} attempts to spot various difficulties that may make particular 
network meta-analysis models unsuitable for your data. 
The diagnostics are computed by {help network setup}.
If instead you used {help network import} you will get a warning that the diagnostics cannot be done.

{p 4 7 2}1. A {ul:disconnected network} arises when the treatments can be divided into 
two or more groups in such a way that no studies make comparisons between groups.
In this case, {cmd:network meta} is unable to fit models and you should fit models separately by component - e.g. {cmd:network meta c if _component==1}.

{p 4 7 2}2. A network has {ul:no degrees of freedom for inconsistency} when it is tree-shaped
(that is, when there are no loops in the network). 
In this case, {cmd:network meta} will be able to fit consistency models but will refuse to fit inconsistency models.

{p 4 7 2}3. A network has {ul:no degrees of freedom for heterogeneity} when no design is represented by multiple studies. 
In this case, {cmd:network meta} will refuse to fit random-effects models. 
If there are degrees of freedom for inconsistency then you will be able to fit random-effects consistency models, since these treat inconsistency as heterogeneity: 
you will need to override {cmd:network meta}'s default with the {cmd:force} option.


{marker examples}{...}
{title:Examples}

{pstd}Fit the consistency model:

{pin}. {stata network meta consistency}{txt}
        
{pstd}Fit the consistency model with a general between-studies covariance structure:

{pin}. {stata network meta consistency, bscov(unstructured)}{txt}
        
{pstd}Fit the consistency model with all treatment effects depending on covariate x:

{pin}. {stata "network meta consistency, eq(_y*:x)"}{txt}
        
{pstd}Short way to do the same:

{pin}. {stata "network meta consistency, regress(x)"}{txt}
        
{pstd}Fit the inconsistency model:

{pin}. {stata network meta inconsistency}{txt}



{p}{helpb network: Return to main help page for network}

