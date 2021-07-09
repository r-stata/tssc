{smcl}

{cmd:help cem}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col:{hi:cem} {hline 2}}Coarsened Exact Matching{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 14 2}
{opt cem} {it:varname1} [{it:(cutpoints1)}] [{it:varname2} [{it:(cutpoints2)}]]{it: ...} {ifin} [{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{synopt :{opth tr:eatment(varname)}}name of the treatment variable{p_end}
{synopt :{opt sh:owbreaks}}display the cutpoints used for each variable{p_end}
{synopt :{opt auto:cuts(string)}}method used to automatically generate cutpoints{p_end}
{synopt :{opt k2k}}force {cmd:cem} to return a k2k solution{p_end}
{synopt :{opt imbbreaks(string)}}method used to automatically generate cutpoints for imbalance checks{p_end}
{synopt :{opt miname(string)}}filename root of the imputed datasets, if in separate files{p_end}
{synopt :{opt misets(integer)}}number of imputed datasets, if in separate files{p_end}
{synopt :{opt impvar(string)}}name of imputed dataset variable, if in stack/flong format{p_end}
{synopt :{opt noimb:al}}do not evaluate the imbalance in the matched solution.{p_end}

{title:Description}

{pstd} {cmd:cem} implements the Coarsened Exact Matching method
described in Iacus, King, and Porro (2008). The main input for
{cmd:cem} are the variables to use and the cutpoints that define the
coarsening. Users can either specify cutpoints for a variable or allow
{cmd:cem} to automatically coarsen the data based on a binning
algorithm, chosen by the user.  To specify a set of cutpoints for a
variable, place a numlist in parentheses after the variable's name. To
specify an automatic coarsening, place a string indicating the binning
algorithm to use in parentheses after the variable's name. To create a
certain number of equally spaced cutpoints, say
10, place "{cmd:#10}" in the parentheses (this will include the
extreme values of the variable). Omitting the parenthetical
statement after the variable name tells {cmd:cem} to use the default
binning algorithm, itself set by {cmd:autocuts}. For example,

{phang} {cmd:. cem age (10 20 30 40 50) education (scott) re74, treatment(treated)}

{pstd} will coarsen the first variable, {cmd:age} into bins of (0-10), (10-20),
(20-30), (30-40), (40-50) and (50+). The Scott algoritm will be used on the
second variable, {cmd:education} and the third variable, {cmd:re74}, will use
the default binning algorithm, Sturge's rule. We could also use

{phang} {cmd:. cem age (#6) education (scott) re74, treatment(treated)}

{pstd} to coarsen age using 6 equally spaced cutpoints. Using #0 will force
{cmd:cem} into not coarsening the variable at all. The option {cmd:autocuts} can
be used to reset the default binning algorithm. For example,

{phang} {cmd:. cem age education re74, treatment(treated) autocuts(fd)}

{pstd} will coarsen all of variables using the Freedman-Diaconis rule.

{pstd} {cmd:cem} can handle missing data in two ways. If you feed
{cmd:cem} data with missing values, {cmd:cem} will simply treat the
missing value as an additional category to match on. If you have
multiply imputed data, you can specify one of two pieces of
information, depending how the imputations are stored. First, if the
imputations are stored in stacked or {cmd:flong} format (the Stata
default using the {cmd:mi} commands), then you can simply pass the
name of the imputation variable to the {cmd:impvar} option. If the
imputaed datasets are in different files, you can specify the root of
the imputed filenames ("imputed" if the datasets are named
"imputed1.dta", "imputed2.dta", etc) in the option {cmd:miname} and
the number of imputations in the option {cmd:misets}. For example:

{phang} {cmd:. cem age education re74, treatment(treated) miname(imputed) misets(5)}

{pstd} In either format, {cmd:cem} will includes all imputations in
the matching process. For observations with imputed values, {cmd:cem}
assigns strata by finding the strata most often assigned to that
observation over the imputations (this is like a plurality voting rule
with ties broken randomly). Distances for the imbalance measure are
calculated using the mean of imputations. Under either format,
{cmd:cem} will result in a stacked or {cmd:flong} dataset, which can
be directly used with Stata's {cmd:mi} commands.

{pstd} The {cmd:k2k} will force the algorithm to create strata with equal
numbers of treated and control units. This removes the need to use weights, but
at a loss of information.  It is recommended that you simply use the output
{cmd:cem_weights} (see the {cmd:cem} documentation for more information).

{pstd} Note that string variables are ignored by {cmd:cem} and that the ordering
of value labels is used by {cmd:cem}. If you have an unordered variable, you may
want to create dummy variables to use them in the matching process.

{pstd}

{title:Arguments}

{dlgtab:Main}

{phang} 
{it:varname#} is a variable to be included as a coviarate.  

{phang} {it:cutpoints#} is either a {cmd:numlist} for cutpoints, a string
referring to the automatic coarsening rule to use, or a pound/hash sign
({cmd:#}) followed by a number specifying the number of equally sized bins to
use. See Description for more information and examples. The binning algorithms
available are "{cmd:sturges}" for Sturge's rule, "{cmd:fd}" for the
Freedman-Diaconis rule, "{cmd:scott}" for Scott's rule and "{cmd:ss}" for
Shimazaki-Shinomoto's rule. Note that cutpoints# only affects varname#.

{dlgtab:Options}

{phang} 
{it:treatment(varname)} sets the treatment variable used for matching. This is
optional and if omitted, {cmd:cem} will simply sort the observations into 
strata based on the coarsening and not return any output related to matching.
Note that {cmd:cem} will use the highest value of this variable as the "treated"
category. 

{phang}
{it:showcutpoints} will have {cmd:cem} display the cutpoints used for each variable
on the screen.

{phang}
{it:autocuts(string)} sets the default automatic coarsening algorithm. The default for this is "sturges". Any variable without a {it:cutpoints#} command after its name will use the autocuts argument.

{phang}
{it:k2k} will have {cmd:cem} produce a matching result that has the same number of 
treated and control in each matched strata by randomly dropping observations.

{phang} {it:imbbreaks(string)} sets the coarsening method for the
imbalance checks printed after {cmd:cem} runs. This should match whichever
method is used for imbalance checks elsewhere.If either {cmd:cem} or
{cmd:imb} has been run and there is a {cmd:r(L1_breaks)} available,
this will be the default.

{phang} {it:miname(string)} is the root of the filenames of the imputed
dataset. They should be in the working directory. For example, if {cmd:miname}
were "imputed", then the filenames should be "imputed1.dta","imputed2.dta" and
so on.

{phang} {it:misets(integer)} is the number of imputed datasets being used for
matching.

{title:Output}

{pstd} The following are added as variables to the main Stata dataset. If you
are using miname() for multiple imputation, {cmd:cem} will save each of these to
each of the .dta files.

{synoptset 15 tabbed}{...}
{synopt:{cmd:cem_strata}} the stratum that {cmd:cem} assigned each observation{p_end}
{synopt:{cmd:cem_weights}} the weight assigned to the observation's stratum. Equals 0 if the observation is unmatched and 1 if the observation is treated.{p_end}
{synopt:{cmd:cem_matched}} indicator if the observation was matched.{p_end}
{synopt:{cmd:cem_treat}} when using the multiple imputation features, {cmd:cem} outputs this variable, which is the treatment vector used for matching. {cmd:cem} applies the same combination rule to treatment as to strata.{p_end}


{title:Saved Results}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(n_strata)}} number of strata{p_end}
{synopt:{cmd:r(n_groups)}} number of levels of the treatment variable{p_end}
{synopt:{cmd:r(n_mstrata)}} number of strata with matches{p_end}
{synopt:{cmd:r(n_matched)}} number of matched observations{p_end}
{synopt:{cmd:r(L1)}} multivariate imbalance measure{p_end}


{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(match_table)}} cross tabulation of treatment and matched status{p_end}
{synopt:{cmd:r(groups)}} tabulation of treatment variable{p_end}
{synopt:{cmd:r(imbal)}} matrix of univariate imbalance measures{p_end}

{p2col 5 15 19 2: Strings}{p_end}
{synopt:{cmd:r(varlist)}} list of covariate variables used{p_end}
{synopt:{cmd:r(treatment)}} treatment variable used for matching{p_end}
{synopt:{cmd:r(cem_call)}} call to cem {p_end}
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

