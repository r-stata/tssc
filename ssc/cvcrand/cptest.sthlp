{smcl}
{* *! version 2.0 23Mar2020}
{cmd:help cptest}
{hline}

{title:Title}

{p2colset 5 15 15 2}{...}
{p2col :{hi:cptest} {hline 2}}Perform clustered permutation test for a cluster randomized trial designed using covariate constrained randomization.
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}


{p 8 17 2}
{cmd:cptest} {it:{help varlist}}{cmd:, }{cmd:clustername(}{it:{help varname}}) {cmd:directory(}{it:string}) {cmd:outcometype(}{it:integer}) [{cmd:cspacedatname(}{it:string})}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Required}
{synopt :{cmd:clustername(}{it:{help varname}})}variable specifying cluster name{p_end}
{synopt :{cmd:directory(}{it:string})}directory where the constrained randomization space (saved by program {help cvcrand}) Stata dataset is stored{p_end}
{synopt :{cmd:cspacedatname(}{it:string})}name of Stata dataset containing the saved constrained randomization space{p_end}
{synopt :{cmd:outcometype(}{it:string})}specifies the type of regression to run, either "continuous" for linear regression with identity link, "binary" for logistic regression with logit link, or 
"count" for Poisson regression without count outcomes{p_end}
{synoptline}
{p2colreset}{...}

{it:{help varlist}} is passed to a regression function, and thus should contain an outcome (dependent variable) followed by independent variables

{marker description}{...}
{title:Description}

{pstd}
{cmd:cptest} performs clustered permutation tests for a cluster randomized trial (CRT) designed using covariate constrained randomization.  Important note: Ordering of clusters in the analysis dataset
must match the ordering in the dataset used to constrain the randomization.

{pstd}
After performing covariate constrained randomization to balance cluster-level characteristics in the design of a CRT, an appropriate analysis technique should be selected to analyze the data collected 
during the implementation phase of the CRT.

{pstd}
In a permutation test, the data are first analyzed using an appropriate regression method.  This regression may either be unadjusted or adjusted (usually for cluster-level characteristics that were
constrained on in the randomization), though the regression should not include the variable indicating intervention assignment.  From this regression, the average cluster-level residuals are saved. 
Using these residuals, we calculate the null distribution test statistic by multiplying this vector of residuals by the vector of the selected scheme with -1 substituted for 0. Next, 
we calculate the permutational distribution by computing 
the value of the test statistic under all possible other allocation schemes in the randomization space.  Under simple randomization, this space consists of all [N choose x] allocation schemes; 
under constrained randomization, the space includes only those allocation schemes where the balance score was below the cutoff (i.e., the space from which the final allocation scheme was chosen).  
The observed (null) test statistic is referenced against  this permutational distribution to obtain a p-value for the intervention effect that accounts for both the clustered design of the CRT 
and the constrained randomization used in selecting the allocation.  For an adjusted permutation test, we simply add as adjustors in the regression model the relevant cluster-level and individual-level 
covariates to obtain an adjusted test statistic.  {help cptest##G1996:Gail et al. (1996)} show that if the number of clusters randomized to intervention is not the same as the number randomized to control, 
the test may be anti-conservative. See {help cptest##G1996:Gail et al. (1996)} for more technical details. See also {help cptest##G2017:Gallis et al. (2018)}.


{marker options}{...}
{title:Options}

{dlgtab:Required}

{phang}
{cmd:clustername(}{it:varname}) specifies the name of the variable that is the identification variable of the cluster.

{phang}
{cmd:directory(}{it:string}) specifies the directory where the constrained randomization space (saved by 
program {help cvcrand}) Stata data set is saved.

{phang}
{cmd:cpsacedat(}{it:string}) gives the name of the dataset containing the saved randomization space.  
This dataset contains the permutation matrix, as well as a variable indicating which row of the permutation matrix was saved as the final scheme.

{phang}
{cmd:outcometype(}{it:string}) specifies the type of regression model that should be run.  
Options are "continuous" for linear regression fit by Stata's {help regress} command 
(suitable for continuous outcomes), "binary" for logistic regression fit by 
Stata's  {help logit} command (suitable for binary outcomes), and "count" for Poisson
regression fit by Stata's {help poisson} command (suitable for count outcomes).


{marker example}{...}
{title:Example}
 
{pstd}The example comes from data published in {help cptest##D2015:Dickinson et al. (2015)}.
The researchers wished to randomize 16 counties in Colorado to two different reminder/recall methods (population vs
practice-based) with the goal of increasing up-to-date immunization rates in children.
We performed constrained randomization on a subset of the data.  After performing constrained randomization (see the first example
in the {help cvcrand} help file), we simulated up-to-date immunization outcome data at the individual level for analysis. This is a binary
variable equal to 1 if the child is up-to-date on their immunizations and 0 otherwise. For more details on the simulation procedure,
see {help cptest##G2017:Gallis et al. (2018)} or {help cptest##G2017conf:Gallis et al. (2017)}. The data can be downloaded from SSC.

	{hline}
	Open simulated outcome data
{phang2}{cmd:. ssc describe cvcrand}{p_end}
{phang2}{cmd:. net install cvcrand}{p_end}
{phang2}{cmd:. net get cvcrand}{p_end}
{phang2}{cmd:. use Dickinson_Data_corr_outcome.dta}

	Run cptest
{phang2}{cmd:. encode location, gen(location2)}{p_end}
{phang2}{cmd:. cptest outcome inciis uptodate hispanic i.location2 i.incomecat, clustername(county) directory(C:\) cspacedatname(dickinson_constrained) outcometype(Binary)}{p_end}



{marker reference}{...}
{title:References}

{marker G1996}{...}
{phang}
Gail, M. H., Mark, S. D., Carroll, R. J., Green, S. B., & Pee, D. (1996).
On design considerations and randomization-based inference for community intervention trials.
{it:Statistics in Medicine}, 15(11), 1069-1092.
{p_end}

{marker L2015}{...}
{phang}
Li, F., Lokhnygina, Y., Murray, D. M., Heagerty, P. J., & DeLong, E. R. (2015). 
An evaluation of constrained randomization for the design and analysis of group-randomized trials.
{it:Statistics in Medicine}, 35(10), 1565-1579.
{p_end}

{marker L2017}{...}
{phang}
Li, F., Turner, E. L., Heagerty, P. J., Murray, D. M., Vollmer, W. M., & DeLong, E. R. (2017). 
An evaluation of constrained randomization for the design and analysis of group-randomized trials with binary outcomes.
{it:Statistics in Medicine}, 36(24), 3791-3806.
{p_end}

{marker G2017}{...}
{phang}
Gallis, J. A., Li, F., Yu, H., Turner, E. L. (2018). 
cvcrand and cptest: Commands for efficient design and analysis of cluster randomized trials using constrained randomization and permutation tests
{it:Stata Journal}, 18(2), 357-378.
{p_end}

{marker G2017conf}{...}
{phang}
Gallis, J. A., Li, F., Yu, H., Turner, E. L. (2017).
cvcrand and cptest: Efficient design and analysis of cluster randomized trials.
{it:Stata Conference}.
https://www.stata.com/meeting/baltimore17/slides/Baltimore17_Gallis.pdf.
{p_end}

{marker D2015}{...}
{phang}
Dickinson, L. M., Beaty, B., Fox, C., Pace, W., Dickinson, W. P., Emsermann, C., Kempe, A. (2015). 
Pragmatic Cluster Randomized Trials Using Covariate Constrained Randomization: A Method for Practice-based Research Networks (PBRNs).
{it:The Journal of the American Board of Family Medicine}, 28(5), 663-672.
{p_end}

{marker author}{...}
{title:Authors}
 John A. Gallis
 Duke University Department of Biostatistics and Bioinformatics
 Duke Global Health Institute
 Durham, NC
 john.gallis@duke.edu
  
 Fan Li
 Yale School of Public Health Department of Biostatistics
 New Haven, CT
 fan.f.li@yale.edu
 
 Hengshi Yu
 University of Michigan Department of Biostatistics
 Ann Arbor, MI
 hengshi@umich.edu

 Elizabeth L. Turner
 Duke University Department of Biostatistics and Bioinformatics
 Duke Global Health Institute
 Durham, NC
 liz.turner@duke.edu
