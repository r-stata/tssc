{smcl}

{cmd:help imb}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col:{hi:cem} {hline 2}}Measure of (Im)balance for CEM{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 14 2}
{opt imb} {it:varlist} {ifin}  [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{synopt :{opth tr:eatment(varname)}}name of the treatment variable{p_end}
{synopt :{opt breaks(string)}}method used to generate cutpoints{p_end}
{synopt :{opt miname(string)}}filename root of the imputed datasets, if in separate files{p_end}
{synopt :{opt misets(integer)}}number of imputed datasets, if in separate files{p_end}
{synopt :{opt impvar(string)}}name of imputed dataset variable, if in stack/flong format{p_end}
{synopt :{opt use:weights }}should the cem_weights be use?{p_end}

{title:Description}

{pstd} {cmd:imb} returns a number of measures of imbalance in
covariates between treatment and control groups. A multivariate L1
distance, univariate L1 distrances, difference in means and empirical
quatiles difference are reported. The L1 measures are computed by 
coarsening the data according to {cmd:breaks} and comparing across the
multivariate histogram. See Iacus, King and Porro (2008) for more details 
on this measure.
 
{title:Arguments}

{dlgtab:Main}

{phang} 
{it:varlist} is a list of variables to be included as coviarates.  

{dlgtab:Options}

{phang} 
{it:treatment(varname)} sets the treatment variable used for the imbalance
checks. Note that {cmd:imb} will use the highest value of this variable as
the "treated" category. 

{phang} {it:breaks(string)} sets the default automatic coarsening
algorithm. If either {cmd:cem} or {cmd:imb} has been run and there
is a {cmd:r(L1_breaks)} available, this will be the default. Otherwise,
the default for this is "scott". It is not incredibly important which
method is used here as long as it is consistent.

{phang} {it:miname(string)} if the imputed datasets are in separate
files, is the root of the filenames of the imputed dataset. They
should be in the working directory. For example, if {cmd:miname} were
"imputed", then the filenames should be "imputed1.dta","imputed2.dta"
and so on.

{phang} {it:misets(integer)} if the imputed datasets are in separate
files, is the number of imputed datasets being used for matching.

{phang} {it:impvar(string)} if the imputed data is stacked in one
dataset (the Stata default), this is the name of the variable
identifying to which imputation the observation belongs.


{phang} {it:useweights} makes {cmd:imb} use the weights from the output of {cmd:cem}. This is useful for checking balance after running {cmd:cem}.


{title:Saved Results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(L1)}} multivariate imbalance measure{p_end}


{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(imbal)}} matrix of univariate imbalance measures{p_end}


{p2col 5 15 19 2: Strings}{p_end}
{synopt:{cmd:r(L1_breaks)}} break method used for L1 distance{p_end}


{title:References and Distribution}

{pstd}
{cmd:cem} is licensed under GLP2. For more information, see: http://gking.harvard.edu/cem/

{pstd} For a full reference on Coarsened Exact Matching, see:

{phang} Stefano M. Iacus, Gary King, and Giuseppe Porro, "Matching for Causal
Inference Without Balance Checking", copy at
<http://gking.harvard.edu/files/abs/cem-abs.shtml>

{pstd} To report bugs or give comments, please contact Matthew Blackwell
<blackwel@fas.harvard.edu>.

