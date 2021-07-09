{smcl}
{* *! version 1.4 Aug 07 2015}{...}
{vieweralsosee "surveybias" "help surveybias"}{...}
{vieweralsosee "surveybiasi" "help surveybiasi"}{...}
{viewerjumpto "Syntax" "surveybiasseries##syntax"}{...}
{viewerjumpto "Description" "surveybiasseries##description"}{...}
{viewerjumpto "Options" "surveybiasseries##options"}{...}
{viewerjumpto "Remarks" "surveybiasseries##remarks"}{...}
{viewerjumpto "Examples" "surveybiasseries##examples"}{...}
{title:Title}

{phang}
{bf:surveybiasseries} {hline 2} Calculates measures of bias in a series of surveys

{phang}Command for raw data (single survey): {help surveybias}

{phang}Immediate command: {help surveybiasi}



{marker syntax}{...}
{title:Syntax}

{phang} {cmdab:surveybiasseries} {ifin} {cmd:} [{opt POPVAR:iables()}]
{opt SAMPLE:variables()}  {opt N:var()} , {opt GEN:erate()} [{opt DESC:riptivenames}]
[{opt MISS:asnull}] [{opt POPVAL:ues()}] [{opt prop}]

{phang} {opt popvariables(v1, v2, ..., vk)} k variables holding information
on true distribution of some categorical variable in the population

{phang} {opt samplevariables(p1, p2, ..., pk)} k variables holding
information on observed distribution of some categorical variable in a
series of samples

{phang} {opt nvar(variable)} Variable holding information on number of
observations in each sample

{phang} {opt generate(newvarstub)} Stub for new variables that will hold
the A's, B, B_w, and other statistics

{phang}
{opt DESC:riptivenames} from the names of the sample variables, generate descriptive names for variables that will hold the A's and Bs 

{phang}
{opt prop} Switch to estimation via {cmd:proportion}. Chiefly used for testing.



{marker description}{...}
{title:Description}


{pstd} {cmd:surveybiasseries} facilitates the calculation of various
measures of bias (A', B, B_w) for a series of surveys via {help
surveybias}. Each observation in the dataset represents an aggregated
survey. For each survey, the observed distribution of some categorical
variable (say voting intention) is given by a series of variables p1, p2,
..., pk. The distribution can be expressed in terms of simple frequencies,
relative frequencies, or percentages. Information on the true distribution
(say actual electoral returns) can be specified either directly via the
{opt popvalues} option, or as an argument to {opt popvariables}. Either
{opt popvariables} or {opt popvalues} must be specified, but not both. The
command leaves behind a series of variables whose names are derived from
the stub submitted via {opt generate}: one A' for each category that
represents category-specific bias, B as an overall measure of bias, B_w as
a weighted version of B, standard errors for each of these, the classical
(Pearson) Chi-square, a likelihood-based Chi-square, and the accompanying p
values.


{marker options}{...}
{title:Options}

{phang} {opt missasnull} Irreversibly recodes missing values in
sample/population variables to zero

{phang} {opt popvalues(numlist with k elements)} Directly specify
distribution of the categorical in the population


{marker remarks}{...}
{title:Remarks}

{pstd} For detailed information the rationale behind the calculation of these
measures, see
{it: Arzheimer, Kai and Jocelyn Evans, A New Multinomial Accuracy Measure}
{it: for Polling Bias, Political Analysis 2014 (22), 31-44.}
{browse "http://dx.doi.org/10.1093/pan/mpt012"}

{marker examples}{...}
{title:Examples}

{phang}{cmd: . use fivefrenchsurveys, replace }{p_end}
{phang}{cmd: . surveybiasseries in 1/3 , popvar(*true) samplev(fh-other) nvar(N) gen(frenchsurveys) }{p_end}
{phang}{cmd: . use german-pre-election-polls, replace}{p_end}
{phang}{cmd: . parallel , : surveybiasseries, samplevariables(cducsu spd linke gruene fdp other) nvar(n) popvalues(41.5 25.7 8.6 8.4 4.8 10.9) generate(gpes) }{p_end}



{title:Also see}

{psee} surveybias (calculation of B and friends from raw data in memory) {help
surveybias}

{psee} surveybiasi (immediate calculation of B and friends) {help surveybiasi}

{psee} Online:  {helpb parallel}
