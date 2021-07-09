{smcl}
{* *! version 1.0  30may2017}{...}
{cmd:help FGT_CI}{right:dialog:  {dialog FGT_CI}}
{hline}

{title:Title}

{pstd}
{bf:FGT_CI} {hline 2} calculates and decomposes Foster–Greer–Thorbecke (and standard) concentration indices


{title:Syntax}

{p 8 14 2}
{cmd:FGT_CI} {it:depvar} [{it:indepvars}] [if] [in] [{it:weight}], rankvar(varname) [{it:options}]

{pstd}
where {it:depvar} is the variable to calculate the Foster-Greer-Thorbecke (FGT) concentration index (CI) for with the observations ranked according to {it:rankvar}.
The FGT-CI can be decomposed according to {it:indepvars} and {it:options} can set the FGT transformation to apply, regressions to use for the decomposition, and complex survey bootstrap.
User-written commands {cmd: twopm}, {cmd: concindc}, and {cmd:bsweights} must be installed to use command {cmd: FGT_CI}. 


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt method(string)}}sets the type of CI to compute and decompose{p_end}
{synopt:{opt cutoff(real)}}sets the threshold or ceiling value for the FGT transformation{p_end}
{synopt:{opt power(real)}}indicates which FGT power to use{p_end}
{synopt:{opt modpart1(string)}}specifies the model used in the first part of the decomposition model{p_end}
{synopt:{opt modpart2(string)}}specifies the model used in the second part of the decomposition model{p_end}
{syntab:Complex survey bootstrap}
{synopt:{opt boot_reps(integer)}}indicates the number of bootstrap repetitions{p_end}
{synopt:{opt boot_seed(integer)}}sets the seed number for the bootstrap{p_end}
{synopt:{opt strata(varname)}}indicates the strata variable{p_end}
{synopt:{opt psu(varname)}}indicates the primary sampling unit{p_end}
{synopt:{opt bsw_average(integer)}}pecifies the number of replications for the mean bootstrap{p_end}
{synopt:{opt nosvy}}performs a simple bootstrap instead of a complex survey bootstrap{p_end}
{syntab:Display}
{synopt:{opt noresults}}suppresses the estimation results{p_end}
{synopt:{opt table(string)}}displays and saves an aggregate result table{p_end}
{synopt:{opt table_opt(string)}}sets options for option {opt table}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{title:Description}

{phang}
This command combines two of the most widely used measures in the inequality and poverty literatures: the concentration index (CI) and the Foster–Greer–Thorbecke (FGT) metric.
It does so by applying the FGT transformation to a variable of interest ({it:depvar}) and by calculating the CI of the transformed variable after ranking the observations according to a socioeconomic status variable {it:rankvar}. 
The command also decomposes the resulting FGT-CI by means of a two-part model (TPM) to determine how the factors listed in {it:indepvars} are associated with overall socioeconomic inequality.
The command further decomposes the contribution of each factor to the overall socioeconomic inequality into the association of each factor with the dependent variable (obtained from the TPM regression) and its distribution according to socioeconomic status (computed with factor-specific CIs).
Also note that the command can be applied to calculate and decompose the standard CI as it is a special case of the FGT_CI when no threshold or ceiling apply.
The command saves its results in {cmd:e()}.
User-written commands {cmd: twopm} and {cmd: concindc} must be installed to use command {cmd: FGT_CI}. 

{title:Options}

{dlgtab:Main}

{phang}
{opt method(string)} sets the type of CI to compute and decompose.
Value "standard" refers to CI of the untransformed dependent variable.
Value "threshold" refers to the FGT transformation defined above a cutoff value (e.g. body mass index above 30).
Value "ceiling" refers to the FGT transformation defined below a cutoff value (e.g. body mass index below 18.5).
Default value is "standard".

{phang}
{opt cutoff(real)} is the threshold or ceiling value for the FGT transformation.
Default value is 0.
This option is inactive when the method is "standard".

{phang}
{opt power(real)} indicates which FGT power to use.
Default value is 0 and negative values are not allowed.
This option is inactive when the method is "standard".

{phang}
{opt modpart1(string)} specifies the model used in the first part of the decomposition model.
The syntax of user-written command {cmd:twopm} must be followed.
This is the model that applies when {opt power} equals 0.
Default is logit without any option.

{phang}
{opt modpart2(string)} specifies the model used in the second part of the decomposition model.
The syntax of user-written command {cmd:twopm} must be followed.
This is the model that applies when {opt method} is "standard".
Default is reg without any option.

{dlgtab:Complex survey bootstrap}

{phang}
{opt boot_reps(integer)} indicates the number of bootstrap repetitions.
Default value is 250.

{phang}
{opt boot_seed(integer)} sets the seed number for the bootstrap. 
Default value is 852015.

{phang}
{opt strata(varname)} indicates the strata variable.

{phang}
{opt psu(varname)} indicates the primary sampling unit.

{phang}
{opt bsw_average(integer)} specifies the number of replications for the mean bootstrap.
Default value is 10.


{dlgtab:Display}

{phang}
{opt noresults} asks the command no to display the estimation results.

{phang}
{opt table(string)} displays an aggregate result table and saves it under the name imputed as a string.
If string is "", the table is neither displayed or saved.
If string is "nosave" the option only displays the table without saving it.
This option is only used when {it:indepvars} have been specified.
Default value is "".
User-written command {cmd: esttab} must be installed to use this option.

{phang}
{opt table_opt(string)} adds options to option {opt table}.
The syntax of user-written {cmd: esttab} must be followed. 


{title:Stored results}

{pstd}
{cmd:FGT_CI} saves the following results in {cmd:e(b)} and their corresponding bootstrapped variance-covariance matrix in {cmd:e(V)}:

{synoptset 22 tabbed}{...}
{synopt:{cmd:CIk}}gives the CI of each variable specified in {it:indepvars} with the observations ranked according to {it:rankvar}{p_end}
{synopt:{cmd:eyex}}gives the elasticity of {it:depvar} according to each variable specified in {it:indepvars}{p_end}
{synopt:{cmd:CIy}}gives the contribution of each variable specified in {it:indepvars} to the total FGT-CI, the residual CI unexplained by these variables, and total FGT-CI{p_end}
{synopt:{cmd:CIy_fact}}gives the total contribution of each factor variable specified in {it:indepvars} to the total FGT-CI{p_end}

																
{title:Reference}

{phang}
Bilger M., E.J. Kruger, and E.A. Finkelstein, 2016.
Measuring Socioeconomic Inequality in Obesity: Looking Beyond the Obesity Threshold.
Health Economics 24(1), 75-85.


{title:Author}

{pstd}
{browse "http://www.duke-nus.edu.sg/content/bilger-marcel":Marcel Bilger}, Laboratory of Health Econometrics, Signature Program in Health Services and Systems Research, Duke-NUS Medical School, Singapore.
Email {browse "mailto:marcel.bilger@duke-nus.edu.sg":marcel.bilger@duke-nus.edu.sg} with "overfit.ado" as subject if you have any question, comment or suggestion regarding this stata user-written command.

	


