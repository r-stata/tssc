{smcl}

{* *! version 0.1 10may2021}{...}

{viewerdialog leedtwoway "dialog leedtwoway"}{...}

{viewerjumpto "Syntax" "leedtwoway##syntax"}{...}

{viewerjumpto "Description" "leedtwoway##description"}{...}

{viewerjumpto "Authors" "leedtwoway##authors"}{...}

{viewerjumpto "Dependencies" "leedtwoway##dependencies"}{...}

{viewerjumpto "Options" "leedtwoway##options"}{...}

{viewerjumpto "Examples" "leedtwoway##examples"}{...}



{p2col:{bf:leedtwoway}}Two way models for labor



{marker syntax}{...}

{title:Syntax}

{p}

{cmd:leedtwoway} {namelist}{cmd:,} {opt config(string)} [{opt env(string)}]



{marker description}{...}

{title:Description}

{pstd}

{cmd:leedtwoway} runs two way estimators for labor. The package provides implementations for a series of estimators for models with two sided heterogeneity:

1. two way fixed effect estimator as proposed by Abowd Kramarz and Margolis
2. homoskedastic bias correction as in Andrews et al
3. heteroskedastic correction as in KSS
4. a group fixed estimator as in BLM
5. a group correlated random effect as presented in BHLMMS

This package requires the Python package PyTwoWay.

Estimators are specified in the namelist. Options include specifying a configuration file (required) and Conda environment (optional).

Note that a temporary file leedtwoway_temp_data.dta is created prior to running the Python script. It is deleted after the script finishes.



{marker authors}{...}
{title:Authors}

{p 4}Thibaut Lamadon{p_end}
{p 4}University of Chicago{p_end}
{p 4}lamadon@uchicago.edu{p_end}

{p 4}Adam A. Oppenheimer{p_end}
{p 4}University of Chicago{p_end}
{p 4}oppenheimer@uchicago.edu{p_end}



{marker dependencies}{...}

{title:Dependencies}

{pstd}

{cmd:leedtwoway} depends on {cmd:libjson} and {cmd:insheetjson}. It also requires the Python package PyTwoWay.



{marker options}{...}

{title:Options}

{phang}{opt config(string)} is required. It specifies the configuration file.



{phang}{opt env(string)} is optional. It specifies the Conda environment where PyTwoWay is installed.



{marker examples}{...}

{title:Examples}

{hline}

{pstd}Run FE


{phang2}{cmd:. sysuse leedtwoway_sample_data}



{phang2}{cmd:. leedtwoway fe, config("config.txt") env("stata-env")}


{pstd}Run CRE


{phang2}{cmd:. sysuse leedtwoway_sample_data}


{phang2}{cmd:. leedtwoway cre, config("config.txt") env("stata-env")}


{pstd}Run FE and CRE


{phang2}{cmd:. sysuse leedtwoway_sample_data}



{phang2}{cmd:. leedtwoway fe cre, config("config.txt") env("stata-env")}



{hline}