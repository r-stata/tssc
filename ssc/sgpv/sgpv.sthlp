{smcl}
{* *! version 1.03  16 May 2020}{...}
{viewerdialog sgpv "dialog sgpv"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "SGPV Value Calculations" "help sgpvalue"}{...}
{vieweralsosee "SGPV Power Calculations" "help sgpower"}{...}
{vieweralsosee "SGPV False Confirmation/Discovery Risk" "help fdrisk"}{...}
{vieweralsosee "SGPV Plot Interval Estimates" "help plotsgpv"}{...}
{viewerjumpto "Syntax" "sgpv##syntax"}{...}
{viewerjumpto "Description" "sgpv##description"}{...}
{viewerjumpto "Options" "sgpv##options"}{...}
{* viewerjumpto "Remarks" "sgpv##remarks"}{...}
{viewerjumpto "Examples" "sgpv##examples"}{...}
{title:Title}
{phang}
{bf:sgpv} {hline 2} A wrapper command for calculating the Second-Generation P-Value(s) (SGPV) and their associated diagnosis.  

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:sgpv}
[{help sgpv##subcmd:subcmd}]
[{cmd:,}
{it:options}] [{cmd::} {help sgpv##estimation_command:{it:estimation_command}}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent :* {opt e:stimate(name)}}  takes the name of a previously stored estimation.
{p_end}
{p2coldent :* {opt m:atrix(name)}}  takes the name of matrix as input for the calculation.
{p_end}
{synopt:{opt c:oefficient(string)}}  the coefficients for which the SGPVs and other statistics are calculated.
{p_end}
{* syntab:Null hypothesis}
{synopt:{opt nulllo(#)}}  change the upper limit of the null-hypothesis interval.
{p_end}
{synopt:{opt nullhi(#)}}  change the lower limit of the null-hypothesis interval.
{p_end}

{syntab:Display}
{synopt:{opt q:uietly}}  suppress the output of the estimation command.
{p_end}
{synopt:{opt matl:istopt(string asis)}}  change the options of the displayed matrix. 
{p_end}
{synopt:{opt b:onus(string)}}   display and calculate bonus statistics like delta gaps and fdr. 
{p_end}
{synopt:{opth for:mat(%fmt)}} display format of the results.
{p_end}
{synopt:{opt nonull:warnings}} disable warning messages when the default point 0 null-hypothesis is used for calculating the SGPVs.
{p_end}
{syntab:Fdrisk}
{synopt:{opt altw:eights(string)}}  probability distribution for the alternative parameter space.
{p_end}
{synopt:{opt alts:pace(string)}}  support for the alternative probability distribution.
{p_end}
{synopt:{opt nulls:pace(string)}}  support of the null probability distribution.
{p_end}
{synopt:{opt nullw:eights(string)}}  probability distribution for the null parameter space.
{p_end}
{synopt:{opt intl:evel(string)}}  level of interval estimate.
{p_end}
{synopt:{opt intt:ype(string)}}  class of interval estimate used.
{p_end}
{synopt:{opt p:i0(#)}}  prior probability of the null hypothesis.
{p_end}

{syntab:menu}
{synopt:{opt perm:ament}} install permanently the dialog boxes into the User menubar.
{p_end}
{synoptline}
{p2colreset}{...}
{marker estimation_command}{...}
{p 4 6 2}
{it:estimation_command} can be any of Stata's or user-provided estimation commands which return their results in a matrix named {it:r(table)}.
This should be true so long the estimation command runs {help ereturn display:ereturn display} at some point.
If you want to calculate SGPVs for an estimation command or any other command which does not follow this convention, then you can use the {it: matrix(matrixname)} option. The matrix must be pre-processed to meet the expectations of {cmd:sgpv}.
 See the description {help sgpv##matrix_opt:here} for more information.{p_end}
 {p 4 6 2}
 * ONLY one thing can be used to calculate the SGPVs: an estimation command, a stored estimation result, a matrix with the necessary information or the previous estimation results.

{marker description}{...}
{title:Description}
{pstd}
{cmd:sgpv} allows the calculation of the Second-Generation P-Values (SGPV) developed by Blume et.al.(2018,2019) for and after commonly used estimation commands. 
The false discovery risk (fdr) can be also reported. 
The SGPVs are reported alongside the usually reported p-values. {p_end}

{pstd}
An ordinary user should use this command and not other commands of this package on which {cmd:sgpv} is based upon. 
{cmd:sgpv} uses sensible default values for calculating the SGPVs, the delta-gaps and the accompaning false discovery risks (fdr), which can be changed.  
This wrapper command runs commands which are based on the original R-code from the {browse "https://github.com/weltybiostat/sgpv":sgpv-package}. 
This package comes also with the example leukemia dataset from {browse "https://github.com/ramhiser/datamicroarray/wiki/Golub-(1999)"}.{break}
Dialog boxes for each command (including {dialog sgpv:this one}) are also provided to make the usage of the commands easier.
The dialog boxes can be installed into the User menubar. 
See {help sgpv##menuInstall:this example} for how to do it.{p_end}

{pstd}
{cmd:sgpv} typed without any options calculates the SGPVs for the last estimation command with the default settings. All options except for {it:estimate()} and {it:matrix()} can be used. {p_end}

{pstd}
For more information about how to interpret the SGPVs and other common questions, 
see {browse "https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0188299.s002&type=supplementary":Frequently Asked Questions} by Blume et al. (2018).
An example of how to interpret the result from {cmd:sgpv} can be found in the {help sgpv##interpretation_example:examples section} of this help file.{p_end}

{pstd}
The formulas for the Second-Generation P-Values can be found {help sgpv##formulas:here}.{p_end}


    The sgpv-package consists of: sgpv       - a wrapper around the other commands, {help sgpvalue} and {help fdrisk}, to be used after estimations commands
    				  {help sgpvalue}   - calculate the SGPVs
    				  {help sgpower}    - power functions for the SGPVs
    				  {help fdrisk}     - false confirmation/discovery risks for the SGPVs
    				  {help plotsgpv}   - plot the SGPVs

{marker subcmd}{...}
{title:Subcommands}
    It is possible to call the other commands of the sgpv-package with the {cmd:sgpv}-command. 
    This is mostly a convience feature so that the help-files for the individual commands should be consulted for the options of these commands.
    Supported subcommands are: {help sgpvalue:value}, {help sgpower:power}, {help fdrisk}, {help plotsgpv:plot} and {help sgpv##menuInstall:menu}.
    Two examples how to use the subcommands are given {help sgpv##subcmds_example:here}.

{marker options}{...}
{title:Options}
{dlgtab:Main}
{phang}
{opt replay} the default behaviour if no estimation command, matrix or stored estimate is set. 
The replay-option is only available in the {dialog sgpv:dialog box}.
{cmd:sgpv} behaves like any other estimation command (e.g. {helpb regress}) which replays the previous results when run without a varlist.
At the moment, the results from previous runs of {cmd:sgpv} are {bf:not} used to display the results. 
Instead, the results are calculated fresh on every run of {cmd:sgpv}.{break}
To see the results from a previous run of {cmd:sgpv} without recalculation, you can run something like {stata matlist r(comparison)}.
This works only if no other commands did run after {cmd:sgpv}.

{phang} ONLY one thing can be used to calculate the SGPVs: an estimation command, the results from the previous estimation command, a stored estimation result or a matrix with the necessary information.

{phang}
{opt e:stimate(name)}     takes the name of a previously stored estimation.

{phang}
{marker matrix_opt}
{opt m:atrix(name)}  takes the name of matrix as input for the calculation. 
The matrix must follow the structure of the r(table) matrix returned after commonly used estimation commands due to the hardcoded row numbers used for identifiying the necessary numbers. 
Meaning that the parameter estimate has to be in the 1st row, the standard errors need to be in the 2nd row, the p-values in 4th row, the lower bound in the 5th and the upper bound in the 6th row.
As additional check, the row names of the supplied matrix need to match the rownames of the r(table) matrix.
The rownames are: b se t pvalue ll ul{break}
To the set rownames run: mat rownames <your matrix> =  b se t pvalue ll ul {break}
Example code is located in the file {cmd:sgpv-leukemia-example.do} which can be viewed {stata viewsource sgpv-leukemia-example.do:here}, if installed.
To run the example code, go to the respective {help sgpv##leukemia-example:example section}.

{phang}
{opt c:oefficient(string)}  allows the selection of the coefficients for which the SGPVs and other statistics are calculated. 
The selected coefficients need to have the same names as displayed in the estimation output. If you did not use {help fvvarlist:factor-variable notation}, then the names are identical to the variable names. 
Otherwise, you have to use {help fvvarlist:the factor-variable notation} e.g. 1.foreign if you estimated  {cmd:reg price mpg i.foreign}.
Multiple coefficients must be separated with a space.
You can also select only an equation by using "eq:" or select a specific equation and variable "eq:var". See {help sgpv##multiple-equations-example: the multiple equations example} for an example.



{phang}
{opt nulllo(#)}  change the upper limit of the null-hypothesis interval. The default is 0 (the same limit as for the usually reported p-values). Missing values are not allowed. 
The default value 0 is just meant to be used for an easier beginning when starting to use SGPVs. 
Please change this value to something more reasonable. What is reasonable lower bound of no scientifically interesting effect(s), depends on your dataset and your research question.
Using this default value will always result in having SGPVs of value 0 or 0.5!

{phang}
{opt nullhi(#)}  change the lower limit of the null-hypothesis interval. The default is 0 (the same limit as for the usually reported p-values). Missing values are not allowed. 
The default value 0 is just meant to be used for an easier beginning when starting to use SGPVs. 
Please change this value to something more reasonable. What is reasonable upper bound of no scientifically interesting effect(s), depends on your dataset and your research question.
Using this default value will always result in having SGPVs of value 0 or 0.5!

{dlgtab:Display}
{phang}
{opt q:uietly}     suppress the output of the estimation command.

{phang}
{opt matl:istopt(string asis)}     change the options of the displayed matrix. The same options as for {helpb matlist} can be used.

{phang}
{opt b:onus(string)}    display and calculate bonus statistics like delta gaps and fdrs. Possible values are "deltagap", "fdrisk", "all" to activate only the display and calculations of the delta-gaps or the fdrs or both.

{phang}
{opth for:mat(%fmt)} specifies the format for displaying the individual elements of the result matrix.  The default is format(%5.4f). 
This option is {bf:NOT} identical to the same named option of {cmd:matlist}, but works independently of it. 
Setting the format option via {cmd:matlistopt()} overrides the setting here and also changes the format of the column names.

{phang}
{opt nonull:warnings} disable warning messages when the default point 0 null-hypothesis is used for calculating the SGPVs. You should disable these warning messages only when you are certain that using the default point 0 null-hypothesis is what you want to use and understand the consequences of doing so.

{dlgtab:Fdrisk}
{pstd}These options are only needed for the calculations of the False Discovery Risk (fdr). The default values should give sensible results in most situations.{p_end}

{phang}
{opt altw:eights(string)}  probability distribution for the alternative parameter space. Options are "Uniform", and "TruncNormal". The default is "Uniform".

{phang}
{opt alts:pace(string)}  support for the alternative probability distribution.  
If "altweights" is "Uniform" or "TruncNormal", then "altspace" contains two numbers separated by a space. 
These numbers can be also formulas which must be enclosed in " ".

{phang}
{opt nulls:pace(string)}  support of the null probability distribution. 
If "nullweights" is "Point", then "nullspace" is a single number. 
If "nullweights" is "Uniform" or "TruncNormal", then "nullspace" contains two numbers separated by a space. 
These numbers can be also formulas which must be  enclosed in " ".

{phang}
{opt nullw:eights(string)}  probability distribution for the null parameter space. Options are "Point", "Uniform", and "TruncNormal". 
The default is "Point" if both options {cmd:nulllo()} and {cmd:nullhi()} are set to the same value. 
If the options {cmd:nulllo()} and {cmd:nullhi()} are set to different values, then {cmd:nullweights()} is by default set to "Uniform".

{phang}
{opt intl:evel(string)}  level of interval estimate. If inttype is "confidence", the level is α. 
If "inttype" is "likelihood", the level is 1/k (not k). 
The default value is 0.05 for the confidence interval which gives the fdr/fcr for the typically reported 95% confidence interval. 

{phang}
{opt intt:ype(string)}  class of interval estimate used. This determines the functional form of the power function. 
Options are "confidence" for a (1-α)100% confidence interval and "likelihood" for a 1/k likelihood support interval. 
The default is "confidence".

{phang}
{opt p:i0(#)}     prior probability of the null hypothesis. Default is 0.5. This value can be only between 0 and 1 (exclusive). 
A prior probability outside of this interval is not sensible. 
The default value assumes that both hypotheses are equally likely.

{dlgtab:menu}
{phang}
{opt perm:ament} install permanently the dialog boxes into the User menubar. 
The necessary commands are added to the user's profile.do. 
If no profile.do exists or can be found then a new profile.do is created in the current directory. 
At the moment, a {cmd:profile.do} will be only be found in the current directory and in the Stata installation base folder.
Other possible places like the user's home folder are not accessed yet. 
See {help profile} to get more information about how to setup the {cmd:profile.do}.
Without this option, the dialog boxes will only available from the menubar until the next restart of Stata. 
The dialog boxes can be accessed as usual by for example {stata db sgpv}.

{marker examples}{...}
{title:Examples}

    Contents
    	{help sgpv##prefix:Basic Usage}
	{help sgpv##interpretation_example:How to interpret results}
	{help sgpv##exporting_results:Exporting results}
    	{help sgpv##stored_estimations:Using stored estimations}
    	{help sgpv##alternative_null-hypothesis:Setting a different null-hypothesis}
    	{help sgpv##multiple-null-hypotheses-example:Setting an individual null-hypotheses for each coefficient}
    	{help sgpv##multiple-equations-example:Selecting coefficients}
	{help sgpv##leukemia-example:Calculating SGPVs for a large dataset of estimation or t-test results}
    	{help sgpv##subcmds_example:Using subcommands} 
				
{* dlgtab:Basic Usage}
  {title:Usage of {cmd:sgpv} as a prefix-command:}
{marker prefix}
  {stata . sysuse auto, clear}
  {stata ". sgpv, bonus(all): regress price mpg weight foreign"} 
  
  Example Output:
  		
  	  Source |       SS           df       MS      Number of obs   =        74
    -------------+----------------------------------   F(3, 70)        =     23.29
  	   Model |   317252881         3   105750960   Prob > F        =    0.0000
  	Residual |   317812515        70  4540178.78   R-squared       =    0.4996
    -------------+----------------------------------   Adj R-squared   =    0.4781
  	   Total |   635065396        73  8699525.97   Root MSE        =    2130.8
  
      ------------------------------------------------------------------------------
  	   price |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
      -----------+------------------------------------------------------------------
  	     mpg |    21.8536   74.22114     0.29   0.769    -126.1758     169.883
  	  weight |   3.464706    .630749     5.49   0.000     2.206717    4.722695
  	 foreign |    3673.06   683.9783     5.37   0.000     2308.909    5037.212
  	   _cons |  -5853.696   3376.987    -1.73   0.087    -12588.88    881.4934
      ------------------------------------------------------------------------------
  
  
  Comparison of ordinary P-Values and Second Generation P-Values for a point Null-Hypothesis of 0
  

       Variables |   P-Value       SGPV  Delta-Gap        Fdr 
    -------------+--------------------------------------------
             mpg |     .7693         .5          .          . 
          weight |         0          0     2.2067      .0479 
         foreign |         0          0       2300       .048 
           _cons |     .0874         .5          .          . 

   
  {title:Interpretation example:}
  {marker interpretation_example}  
  There is inconclusive evidence for an effect of mpg on price, while there is no evidence for the null-hypothesis of no effect for weight and foreign. 
  Remember that the null-hypothesis is an interval of length 0 with both lower and upper bounds being also 0.
  This is the standard null-hypothesis of no effect.	
  You will usually have a more relastic interval which is larger than 0 due to measurement errors, scientific relevance, etc. 
  The delta-gap can be used to compare two different studies for the same model/estimation when both report second-generation p-values of zero (p_δ = 0).
  So for this example, the delta-gap is not needed, but still provides information about the distance between either the upper or the lower bound of the confidence interval and 0.
  Finally, the False Discovery Risk (Fdr) tells you there is a roughly a 5% chance that the null-hypothesis is true although you calculated a second-generation p-value of zero (p_δ = 0).
  Whether 5% is much, is for you to decide.
  
  {bf:NB}: Note that the given interpretations are based on my understanding of Blume et.al (2018,2019).
  I cannot guarantee that my understanding is correct.
  These interpretations are just meant as examples how to make sense out of the calculated numbers, but not meant as a definitive answer.	
  
  {title:Exporting results}
  {marker exporting_results}
  You can export the results with the help of Ben Jann's {help estout}-command. If you have not installed it yet, then you can do so by clicking {stata scc install estout,replace:here}.
  {stata . postrtoe} //transfer the matrix r(comparison) to e(comparison) to make repeat usage of estout easier
  {stata . estout e(comparison)} //display the results
  {stata . estout e(comparison) using sgpv-results.tex, style(tex) replace} //export results for later use in a LaTeX-document
  
  {title:Using stored estimations}
  {marker stored_estimations} 
  Save estimation for later usage 
	{stata . estimate store pricereg} 

  The same result but this time after the last estimation.
	{stata . sgpv} 
	
  Now run a quantile regression instead	
	{stata . qreg price mpg weight foreign} 
	{stata . estimates store priceqreg}

  Calculate sgpvs for the stored estimation and only the foreign coefficient 
	{stata . sgpv, estimate(pricereg) coefficient("foreign")} 
	{stata . sgpv, estimate(priceqreg) coefficient("foreign")}
  
  {title:Setting a different null-hypothesis}
  {marker alternative_null-hypothesis}
  Set an alternative null-hypothesis: 1% of the mean value of the price variable (-62, 62)  
	{stata ". sgpv, bonus(all) nulllo(-62) nullhi(62) quietly: regress price mpg weight foreign"}
	
    Comparison of ordinary P-Values and Second Generation P-Values for an interval Null-Hypothesis of {-62,62}
    
       Variables |   P-Value       SGPV  Delta-Gap        Fdr 
    -------------+--------------------------------------------
             mpg |     .7693         .5          .          . 
          weight |         0          1          .          . 
         foreign |         0          0    36.2405      .0394 
           _cons |     .0874         .5          .          . 

	The SGPV for the weight-coefficient has changed from 0 to 1 while the P-Value remained the same compared to the default point 0 null-hypothesis.
	The example illustrates the need to set a scientifically reasonable null-hypothesis. For the weight-coefficient, the null-hypothesis of {-62,62} is probably too wide.
	
    {title:Setting an individual null-hypotheses for each coefficient}
	{marker multiple-null-hypotheses-example}
    To set a separate/different null-hypothesis for each coefficient, you need to iterate through the list of coefficients.
    Direct support for multiple null-hypotheses is planned for a later version of this command.
    See the code below as example how to do that.
	
	{com}regress price mpg weight foreign
	{com}local coeflist mpg weight foreign // Put here the coefficients for which you want to calculate the SGPVs
	{com}local nulllb 20 2 3000 // lower bounds of null-hypotheses
	{com}local nullub 40 4 6000 // upper bounds of null-hypotheses
	{com}local i 1
	{com}foreach coef of local coeflist{
		 {com}sgpv ,coefficient(`coef') nulllo(`=word("`nulllb'",`i')') nullhi(`=word("`nullub'",`i')') quietly
		 {com}mat res = r(comparison) // collect the results in matrix for further processing
		 {com}mat results =(nullmat(results) \ res ) 
		 {com}local ++i
	{com}}
	{com}matlist results, title("Collection of results") rowtitle(Coefficients)
	{stata do sgpv-multiple-null-hypotheses-example.do:(click to run)}
	
  {title:Selecting coefficients}	
  {marker multiple-equations-example}{...}
  Calculate sgpvs for a multiple equation estimation command and select coefficients
	{stata . sqreg price mpg rep78 foreign weight, q(10 25 50 75 90)}
	Select only the foreign coefficient for sgpv calculation
	{stata . sgpv, coefficient(foreign) }
        Select only the 50% quantile equation for sgpv calculation
	  sgpv, coefficient(q50:)  
        Select only the 50% quantile equation and foreign coefficient for sgpv calculation
	  sgpv, coefficient(q50:foreign) 


  {title:Calculating SGPVs for a large dataset of estimation or t-test results}
  {marker leukemia-example}
  The example leukemia dataset can be used to show how the SGPVs can be calculated for a large dataset which contains the information usually returned in the {cmd:{it:r(table)}} matrix.
  The leukemia dataset contains from 7218 gene specific t-tests for a difference in mean expression.
  More information about the dataset are in the dataset itself: Use {stata sysuse leukstats,clear} and {stata notes} to access this information.
  The example file below will calculate the SGPVs and bonus statistics for the leukemia dataset. 
  You can view the {view sgpv-leukemia-example.do:code} if installed. 
  If not, you can install it {net "get sgpv.pkg, replace":by clicking here} together with the other ancillary files:
	{stata . do sgpv-leukemia-example.do}
	
  This example code is rather slow on my machine and demonstrates some ways around the current limitations of the program code.
  Should your {help matsize:maximum matrix size}  be higher than the number of observations in the dataset (7128), then the example code should run faster. 
  You can run {stata display c(matsize)} to see your current setting.

  {title:Subcommands examples} 
  {marker subcmds_example}
  The subcommands can be used in case you want to use only one command instead remembering the names of the other commands of this package
	{stata . sgpv value, estlo(log(1.3)) esthi(.) nulllo(.) nullhi(log(1.1)) }
	{stata . sgpv power,true(2) nulllo(-1) nullhi(1) stderr(1) inttype("confidence") intlevel(0.05)}
 
{marker menuInstall}{...}
  Install the dialog boxes permanently in the User menubar: User -> Statistics 
	{stata . sgpv menu, perm}  

{title:Stored results}
Besides its own calculations, {cmd:sgpv} also preserves the returned results from the estimation command including everything returned in r().
{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:r(comparison)}}  a matrix containing the displayed results {p_end}

{marker formulas}{...}
{title:Formulas & Interpretation}
{pstd}
The formulas below are taking from the help-files of {helpb sgpvalue} and {helpb fdrisk}.
An example about how to interpret the results is given in the {help sgpv##interpretation_example:example section}.
{p_end}

 {col 10} The SGPV is defined as : 	p_δ  = |I ∩ H_0|/|I|*max{|I|/(2|H_0|), 1} 
{col 10}				    = |I ∩ H_0|/|I| 		when |I|<=2|H_0| 
	{col 10}				    = 1/2*|I ∩ H_0|/|I| 	when |I|> 2|H_0| 
		{col 10}		      with I = {θ_l,θ_u} and |I|= θ_u - θ_l.  
								 
{pstd}								 
θ_u and θ_l are typically the upper and lower bound of a (1-α)100% confidence interval but any other interval estimate is also possible. {break}
H_0 is the null hypothesis and |H_0| its length. {break}
The null hypothesis should be an interval which contains all effects that are not scientifically relevant. {break}
The p-values reported by most of Stata's estimation commands are based on the null hypothesis of a parameter being exactly 0. {break}
Point null-hypothesis are supported by SGPVs, but they are discouraged. 
See answer 11 in the {browse "https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0188299.s002&type=supplementary":Frequently asked questions} to Blume et al. (2018).
You could set a small null-hypothesis interval which includes effects of less than 1% or 0.1%. The exact numbers depend on what you deem a priori as not scientifically relevant.

{pstd}
p_δ lies between 0 and 1. {break}
A p_δ of 0 indicates that 0% of the null hypotheses are compatible with the data.  {break} 
A p_δ of 1 indicates that 100% of the null hypotheses are compatible with the data. {break}
A p_δ between 0 and 1 indicates inconclusive evidence. {break}
A p_δ of 1/2 indicates strictly inconclusive evidence.  {break} 

{pstd}
For more information about how to interpret the SGPVs and other common questions, 
see {browse "https://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0188299.s002&type=supplementary":Frequently Asked Questions} by Blume et al. (2018).

{pstd}
The delta-gap is have a way of ranking two studies that both have second-generation p-values of zero (p_δ = 0). It is defined as the distance between the intervals in δ units with δ being the half-width of the interval null hypothesis.{p_end}

		The delta-gap is calculated as: gap   	  = max(θ_l, H_0l) - min(H_0u, θ_u) 
						delta 	  = |H_0|/2 
						delta.gap = gap/delta 
								
    For the standard case of a point 0 null hypothesis and a 95% confidence interval, delta is set to be equal to 1. 
    Then the delta-gap is just the distance between either the upper or the lower bound of the confidence interval and 0. 
    If both θ_u and θ_l are negative then, the delta-gap is just θ_u, the upper bound of the confidence interval. 
    If both bounds of the confidence interval are positive, then the delta-gap is equal to the lower bound of the confidence interval.
		
    The false discovery risk is defined as: 	P(H_0|p_δ=0) = (1 + P(p_δ = 0| H_1)/P(p_δ=0|H_0) * r)^(-1)
    The false confirmation risk is defined as: 	P(H_1|p_δ=1) = (1 + P(p_δ = 1| H_0)/P(p_δ=1|H_1) * 1/r )^(-1)
    with r = P(H_1)/P(H_0) being the prior probability.	
    See equation(4) in Blume et.al.(2018)

{pstd}

{title:References}
{pstd}
 Blume JD, D’Agostino McGowan L, Dupont WD, Greevy RA Jr. (2018). Second-generation {it:p}-values: Improved rigor, reproducibility, & transparency in statistical analyses. {it:PLoS ONE} 13(3): e0188299. 
{browse "https://doi.org/10.1371/journal.pone.0188299"}

{pstd}
Blume JD, Greevy RA Jr., Welty VF, Smith JR, Dupont WD (2019). An Introduction to Second-generation {it:p}-values. {it:The American Statistician}. In press. {browse "https://doi.org/10.1080/00031305.2018.1537893"} 


{title:Author}
{p}
Sven-Kristjan Bormann, School of Economics and Business Administration, University of Tartu.

{title:Bug Reporting}
{psee}
Please submit bugs, comments and suggestions via email to:	{browse "mailto:sven-kristjan@gmx.de":sven-kristjan@gmx.de}{p_end}
{psee}
Further Stata programs and development versions can be found under {browse "https://github.com/skbormann/stata-tools":https://github.com/skbormann/stata-tools} {p_end}


{title:See Also}
Related commands:
 {help plotsgpv}, {help sgpvalue}, {help sgpower}, {help fdrisk}  

