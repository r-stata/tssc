{smcl}
{* 03Oct2014}{...}
{hline}
help for {hi:mibmi}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{hi:mibmi} {hline 2}} Cleaning and multiple imputation algorighm for body mass index (BMI), or other variable with very low individual-level variability, in longitudinal datasets {p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 8 2}
{cmd:mibmi}
{it:var1}
{it:var2}
{it:var3}
[{it:var4}]
[{cmd:,} {it:{help mibmi##options:options}}]

{p 4 4 2}
where

{p 6 6 2}
{it:var1} the individual identifier (unique within time).

{p 6 6 2}
{it:var2} the linear time variable.

{p 6 6 2}
{it:var3} the variable of interest, BMI or other.

{p 6 6 2}
{it:var4} age in years variable (optional).


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :cleaning}
{synopt :{opt weight(varname)}}Weight in kilograms (only relevant for BMI)
{p_end}
{synopt :{opt height(varname)}}Height in metres (only relevant for BMI)
{p_end}
{synopt :{opt clean}}Set unrealistic values to missing for variable of interest (BMI or other)
{p_end}
{synopt :{opt xclean}}Regression cleaning, setting unrealistic changes within each individual to missing
{p_end}
{synopt :{opt xclnp(#)}}Threshold for regression cleaning (default is abs(residual)/observation>=50%)
{p_end}
{synopt :{opt xnomi}}No multiple imputations i.e. cleaning only
{p_end}
{synopt :{opt xsimp}}Simple imputation
{p_end}
{synoptline}
{syntab :multiple imputation}
{synopt :{opt minum(#)}}Number of multiple imputations (default is five)
{p_end}
{synopt :{opt ixtr:apolate}}Request extrapolation (in addition to interpolation), using ipolate
{p_end}
{synopt :{opt rxtr:apolate}}Request extrapolation (in addition to interpolation), using regress
{p_end}
{synopt :{opt imnar(#)}}MNAR assumption for interpolated values
{p_end}
{synopt :{opt xmnar(#)}}MNAR assumption for extrapolated values
{p_end}
{synopt :{opt pmnar}}MNAR assumption involved percentage rather than absolute effect
{p_end}
{synopt :{opt milng}}Convert dataset to mlong rather than wide multiple imputation format
{p_end}
{synoptline}
{syntab :other}
{synopt :{opt lolim(#)}}Lower value threshold (default is 8)
{p_end}
{synopt :{opt uplim(#)}}Upper value limit (default is 210)
{p_end}
{synopt :{opt seed(#)}}Set seed number (default is 7)
{p_end}
{synopt :{opt nodi}}Do not display process
{p_end}
{synopt :{opt force}}Force execution by dropping {it:_var3} if it exists
{p_end}


{title:Description}

{p 4 4 2}
{cmd:mibmi} is a multiple imputation and cleaning command for body mass index (BMI) or other variable with very low individual-level variability, compatible with {cmd:mi} commands. Cleaning includes standard cleaning that limits values to a logical range and regression based cleaning
for each subject. If weight and height have been provided the algorithm with these and BMI observations at each time point to correct BMI and/or height/weight values (only relevant when the variable of interest in BMI).
The command will also impute measurements for the variable of interest for individuals with at least 2 observations over the time period. Residuals are used to quantify interpolation prediction errors, for all possible
time-window lengths, and these are used to introduce uncertainty in the interpolation estimates, in a multiple imputations setting. Imputed values are drawn from normal distributions, the means
for which are provided by the ipolate command and the standard deviations are the standard errors for the predictions for the respective time-window length.
A similar process is used for extrapolations, if requested (see below). Missing not at random assumptions in the imputation process are allowed, for interpolated or extrapolated cases.
The command can take a long time to run, especially when both interpolations and extrapolations are requested. Please note that the data needs to be in long rather than wide format (in relation to time).
Finally, a backup variable of the original variable of interest is created, named {it:_var3}.

{marker options}{...}
{title:Options}

{dlgtab:Cleaning}

{phang}
{opt weight(varname)} Weight in kilograms. If provided along with height, variables will be used to correct BMI and/or height & weight observations.

{phang}
{opt height(varname)} Height in metres. If provided along with weight, variables will be used to correct BMI and/or height & weight observations.

{phang}
{opt clean} Standard cleaning option requested to set unrealistic values to missing (>210 or <8). If weight and height have been provided, and assuming BMI is the variable of interest,
they are also cleaned at this stage, taking age into account if it has been provided.

{phang}
{opt xclean} More advanced cleaning option that uses regression modelling to identify unrealistic changes in the variable of interest, which are very likely input errors, and set them to missing. If BMI is the
variable of interest, provided weight and height values will be taken into account: first, weight, height and BMI values are investigated longitudinally to try to verify the subject's height
(accounting for age, if provided). Then, using this 'most likely' height value, BMI values are corrected if needed. The second stage, which is the only stage if the variable of interest
is not BMI, involves running a regression model for each subject to identify unrealistic changes in BMI and set them to missing. The threshold over which the observations are set to missing
is set with the {opt xclnp(#)} option.

{phang}
{opt xclnp(#)} Threshold for regression cleaning, defined as absolute residual value (i.e. observed minus prediction) over observed value. The default value is 0.5 (i.e. 50%) but the option accepts values in the (0,10] range.

{phang}
{opt xnomi} By default the command is a multiple imputation command. This option suppresses the multiple imputations and hence allows the command to be used solely for cleaning.

{phang}
{opt xsimp} By default the command is a multiple imputation command. This option suppresses the multiple imputations and allows simple imputation, with no standard errors calculated
and implemented in either intrapolations or extrapolations. It can be issued with the {opt ixtr:apolate} or {opt rxtr:apolate} options.

{dlgtab:Multiple imputation}

{phang}
{opt minum(#)} Number of multiple imputations. The default is five.

{phang}
{opt ixtr:apolate} Requests extrapolation (in addition to interpolation), using the ipolate command. Standard errors for ipolate predictions are calculated (for various time-windows), by removing observed values
and calculating model performance for them. The ipolate command (with the extrapolation option) is then used to sequentially impute extrapolated values: starting from the time points closest to the observed values
and moving further away. At each stage, values are drawn from a normal distribution the mean for which is provided by the ipolate command and its standard deviation is the standard error for the predictions for the
respective time-window.

{phang}
{opt rxtr:apolate} Requests extrapolation (in addition to interpolation), using the regress command. Standard errors for regression predictions are calculated (for various time-windows), by removing observed values
and calculating model performance for them. The regress command is then used to sequentially impute extrapolated values: starting from the time points closest to the observed values and moving further away.
At each stage, values are drawn from a normal distribution the mean for which is provided by the regress command and its standard deviation is the standard error for the predictions for a time-window of 1.

{phang}
{opt imnar(#)} Missing not at random (MNAR) assumption for interpolated values. Increases or decreases the predictions by the value specified, in the [-50,+50] range but within the logical range for the variable of interest.

{phang}
{opt xmnar(#)} Missing not at random (MNAR) assumption for extrapolated values. Increases or decreases the predictions by the value specified, in the [-50,+50] range but within the logical range for the variable of interest.

{phang}
{opt pmnar} Indicates that a percentage change, rather than an absolute value increase/decrease, is to be used for the MNAR mechanism(s). If this option is specified, options {opt imnar(#)} and {opt xmnar(#)}
will accept values in the [-0.9,+0.9] range, indicating a percentage change between -90% and 90%. Users should be aware that increases and decreases are not symmetrical under this option.

{phang}
{opt milng} Requests the multiple imputations dataset in {opt mlong} format instead of {opt wide}, the default.

{dlgtab:Other}

{phang}
{opt lolim(#)} Lower value threshold below which observations are dropped when using {opt clean} and imputations are constrained. The default value, for adult BMI, is set to 8.

{phang}
{opt uplim(#)} Upper value threshold above which observations are dropped when using {opt clean} and imputations are constrained. The default value, for adult BMI, is set to 210.

{phang}
{opt seed(#)} Set initial value of random-number seed, for the simulations. The default is 7. See {help set seed}.

{phang}
{opt nodi} Do not display progress. Not recommended since imputation can take a very long time for large databases.

{phang}
{opt force} Force execution by dropping backup variable {it:_var3}, if it exists.

{title:Remarks}

{p 4 4 2}
If imputations are requested, the generated variables will follow the {opt wide} or {opt mlong} (if requested) {cmd:mi} setup. For example, if three imputations
are requested for variable {it:bmi_mean}, variables {it:_1_bmi_mean}, {it:_2_bmi_mean}, {it:_3_bmi_mean} with the imputed variables and {it:_mi_miss} with
missingness information will be generated in the {opt wide} format. Alternatively, in the {opt mlong} format, {it:_mi_miss} {it:_mi_m} and {it:_mi_id}
will be generated with information on missigness, the imputation number and the imputation id respectively. In either format, additional variables will be
generated with information on whether observations are imputed as an interpolation ({it:_mi_ipat}) or extrapolation ({it:_mi_xpat}). In the {opt wide}
format only, additional variables are available that provide information on imputed values that were outside logical ranges and had to be corrected
(a few iterations are perfomed until a logical value is obtained and if that is not possible the top or bottom of the allowed range is set). For interpolations,
corrected values should be and are extremely rare (variables {it:_1_iinfo}, {it:_2_iinfo} etc). For extrapolations, corrections are more likely but should still
be rare (variables {it:_1_xinfo}, {it:_2_xinfo} etc).

{title:Examples}

{p 4 4 2}
Standard and advanced cleaning.

{phang2}{cmd:. mibmi patid year bmi_mean age, weight(weight_mean) height(height_mean) clean xclean xnomi}{p_end}

{p 4 4 2}
Standard and advanced cleaning with multiple imputations (3), including ipolate-based extrapolations.

{phang2}{cmd:. mibmi patid year bmi_mean age, weight(weight_mean) height(height_mean) clean xclean ixtr minum(3)}{p_end}

{p 4 4 2}
As before but additionally with MNAR assumption for interpolated imputations: estimates are set to 5 units higher.

{phang2}{cmd:. mibmi patid year bmi_mean age, weight(weight_mean) height(height_mean) clean xclean ixtr minum(3) imnar(5)}{p_end}

{p 4 4 2}
MNAR assumptions for both interpolations and extrapolations, using percentage change: 20% higher for interpolations, 50% higher for extrapolations.

{phang2}{cmd:. mibmi patid year bmi_mean age, weight(weight_mean) height(height_mean) clean xclean ixtr minum(3) imnar(0.2) xmnar(0.5) pmnar}{p_end}


{title:Author}

{p 4 4 2}
Evangelos Kontopantelis, Centre for Health Informatics, Institute of Population Health

{p 29 4 2}
University of Manchester, e.kontopantelis@manchester.ac.uk


{title:Please cite as}

{p 4 4 2}
Kontopantelis E, Parisi R, Reeves D and Springate D. Longitudinal multiple imputation approaches for Body Mass Index: the mibmi command. Some Journal, 20xx Oct; xx(x): xxx-xxx.
Under review. Working paper available {browse "https://www.researchgate.net/publication/272480719_Longitudinal_multiple_imputation_approaches_for_Body_Mass_Index_the_mibmi_command":here}.


{title:Also see}

{p 4 4 2}
help for {help twofold}

