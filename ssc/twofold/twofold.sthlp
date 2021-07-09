{smcl}
{* 03apr2007}{...}
{hi:help twofold}
{hline}

{title:Title}

{p2colset 5 16 14 2}{...}
{p2col:{hi:twofold} {hline 2}}Multiple imputation by the two-fold fully conditional specification (FCS) algorithm{p_end}
{p2colreset}{...}


{title:Syntax}

{phang2}
{cmd:twofold}
{cmd:,}
{opt timein(varname)}
{opt timeout(varname)}
[{opt table}
{opt clear}
{cmd: saving(}{it:filename} [{opt , replace}]{cmd:)}
{opt base(varname)}
{opt indmis(varlist)}
{opt depmis(string)}
{opt indobs(varlist)}
{opt depobs(string)}
{opt outcome(varlist)}
{opt cat(varlist)}
{opt m(#)}
{opt ba(#)}
{opt bw(#)}
{opt width(#)}
{opt conditionon(varlist)}
{opt condvar(varlist)}
{opt condval(string)}
{opt im}
{opt keepoutside}
{cmd: trace(}{it:filename} [{opt , string}]{cmd:) ] }

{title:Description}

{pstd}
{cmd:twofold} implements the two-fold fully conditional specification
(FCS) algorithm, proposed by Nevalainen (2009), to impute missing values in longitudinal
data. 

{pstd}
{cmd:twofold} imputes missing values at each time point conditional on observed
measurements within a small time window using FCS (or chained equations). Missing values
at time point {it:t} are imputed by cycling around the specified imputation models, 
performing 'within-time iterations'. Once these are complete, the variables at time
point {it:t+1} are imputed. Each time point is chronologically updated. Once missing values
at the last time point are imputed, the first 'among-time iteration' is complete.
Further 'among-time iterations' are performed, each one starting from the first time point.
At each step of the procedure, the most recent imputations of missing values are carried
forward to the next step. When the pre-specified among-time iterations are complete,
the current imputations of missing values, together with the
originally observed values, form the first imputed dataset. The whole process is repeated
to create as many imputed datasets as desired, using the previous imputed dataset as
starting values.  


{title:Options}

{phang}
{opt timein(varname)} specifies a variable {it:varname} indicating the
time point each individual entered the study. Missing values are only imputed for time
points between and including an individual's {opt timein} and {opt timeout} (see {opt timeout}).

{phang}
{opt timeout(varname)} specifies a variable {it:varname} indicating the
time point each individual exited the study. Missing values are only imputed for time
points between and including a individual's {opt timein} and {opt timeout} (see {opt timein})

{phang}
{opt table} produces a table showing the percentage of missing values for the time-independent
variables with missing values and the time-dependent variables with missing values at each 
time point for all individuals, regardless of when they enter and exit the study.

{phang}
{opt clear} specifies that the original memory is cleared and the combined datasets
are loaded into the memory. The dataset must be saved manually.

{phang}
{cmd: saving(}{it:filename} [{opt , replace}]{cmd:)} specifies that the original dataset and
the imputed datasets will be saved to {it:filename}. {opt replace} allows {it:filename}
to be overwritten with the new data. {opt saving} and/or {opt clear} must be specified.

{phang}
{opt base(varname)} specifies the variable containing the 'baseline' time
point for each individual. The time-independent variables with missing data are imputed
conditional on other time-independent variables and time-dependent variables recorded
at 'baseline'. The 'baseline' time point must be within the individuals follow up time,
specified by {opt timein} and {opt timeout}.

{phang}
{opt indmis(varlist)} specifies time-independent variables with missing values,
imputed at the beginning of each among-time iteration.

{phang}
{opt depmis(string)} specifies the variable name stems of the time-dependent
variables with missing values. The variable names for the same measurements will have a
stem and a number to represent the time point. For example, with weight measurements at each
time point, with time beginning at 1, the dataset contains the variables {it:weight1},
{it:weight2} etc, the stem {it:weight} are passed using the {opt depmis} option.
If one variable is passed to {it:depmis}, {opt twofold} will only perform 1 within-time iteration.

{phang}
{opt indobs(varlist)} specifies fully observed time-independent variables, included as
explanatory variables in imputation models. 

{phang}
{opt depobs(string)} specifies the stem of any time-dependent variables 
fully observed at all time points within the follow-up time specified by {opt timein} and
{opt timeout}. When time-independent variables are imputed, the values of the {it:depobs}
variables at the time point specified using {opt baseline} are included as explanatory
variables in the imputation model. Similarly, when time-dependent variables are imputed at
time {it:t}, the values of the variables in {\tt depobs} at time point {it:t} are included as
explanatory variables in the imputation model. Only the stem is specified using {it:string}. 

{phang}
{opt outcome(varlist)} specifies the fully observed outcome variable(s), included as
explanatory variables in imputation models. For survival models both outcome indicator and
survival time variables are specified using {it:varlist}.

{phang}
{opt cat(varlist)} specifies the categorical variables with two or more categories.
These variables with missing values are imputed assuming a multinomial logistic model.
If they are complete, they will be a categorical auxiliary variable. If a binary variable
coded as 0/1 and specified as a categorical variable, {cmd:twofold} will recognise the variable is binary
and assume a logistic distribution. If it is a time-dependent categorical variable, only
the stem is specified using {it:varlist}.

{phang}
{opt m(#)} specifies the number of imputations to be created. The default is 5.

{phang}
{opt ba(#)} specifies the number of among-time iterations. The default is 10.

{phang}
{opt bw(#)} specifies the number of within-time iterations. The default is 5.

{phang}
{opt width(#)} specifies the width of the time window. When imputing time-dependent
variables at time {it:t}, the values of other time-dependent variables within {opt width}
time units are included as explanatory variables. The default value of {opt width} is 1,
so measurements recorded at time {it:t-1} and {it:t+1} are included in the imputation model to
inform imputation of missing values at time {it:t}. If the window width is 2, measurements
recorded at time {it:t-2}, {it:t-1}, {it:t+1} and {it:t+2} are included in the imputation model.

{phang}
{opt conditionon(varlist)} the variable {opt condvar} conditions on.

{phang}
{opt condval(string)} the value {opt condvar} conditions on.

{phang}
{opt condvar(varlist)} specifies that the variables passed to {it:condvar} are only imputed
for individuals if the variable specified by {opt conditionon} is equal to the value {opt condval}.
{opt conditionon} can be specified as the stem for time-dependent variables, one of the
time-dependent variables at a specific time point or a time-independent variable, i.e. {it:weight},
{it:weight2001} or {it:gender}. If the stem is specified, measurements at all time points
are imputed if the variable specified by {opt conditionon} is equal to {opt condval}. If
measurements at a single time point are specified, only the measurements at this time point is
imputed if the variable specified by {opt conditionon} is equal to {opt condval}.

{pmore}
For example, suppose a variable {it:smoker}=1 if an individual is a smoker and {it:smoker}=0 otherwise.
Another variable {it:nocigs} indicates the report number of cigarettes smoking individuals smoke.
Ordinarily, we would not want to impute number of cigarettes for non-smokers. This is achieved by
specifying: {opt conditionon(smoker)} {opt condval(1)} {opt condvar(nocigs)}. 

{phang}
{opt im} displays the {cmd:mi impute} commands. To avoid duplication, the {cmd:mi impute}
commands are only shown for each among-time iteration of the first imputation. For the first 
among-time iteration, each command imputes missing values at more than one time point 
because there are missing values at each time point. For subsequent among-time 
iterations, only missing values at each time point in tern are imputed because the missing values at
other time points are replaced with previously imputed values.

{phang}
{opt keepoutside}  retains  imputed values in the imputed datasets before the individual
enters the study and after the individual exits the study. 
{cmd:twofold} replaces values imputed  with missing values if this option is not specified.

{phang}
{cmd: savetrace(}{it:filename} [{ , traceopts}]{cmd:)} specifies to save the means and 
standard deviations of imputed values from each iteration to a Stata dataset called
filename.dta.  If the file already exists, the replace suboption specifies to overwrite the 
existing file.  {cmd:savetrace()} is useful for monitoring convergence of the chained algorithm.  
This option cannot be combined with {cmd:by()}.

        traceopts are {cmd:replace}, {cmd:double}, and {cmd:detail}.

            {cmd:replace} indicates that filename.dta be overwritten if it exists.

            {cmd:double} specifies that the variables be stored as doubles, meaning 8-byte reals.  By default, they are stored as floats, meaning 4-byte reals.

            {cmd:detail} specifies that additional summaries of imputed values including the smallest and the largest values and the 25th, 50th, and 75th
                percentiles are saved in filename.dta.
				
{phang}
{opt rseed(#)} sets the random-number seed.  This option can be used to reproduce results.  {cmd:rseed(#)} is equivalent to typing set seed # prior to calling {cmd:mi impute}.

{phang}
{opt dryrun} specifies to show the conditional specifications that would be used to impute each variable without actually imputing data.  This option is
        recommended for checking specifications of conditional models prior to imputation.

{phang}
{opt force} specifies to proceed with imputation even when missing imputed values are encountered.  By default, mi impute terminates with error if missing
        imputed values are encountered.



{title:Remarks}

{pstd}
The {cmd:twofold} command uses Stata's {cmd:mi impute chained}. 

{pstd}
The implementation of the two-fold FCS MI algorithm in the {cmd:twofold} command assumes the
data are in {it:wide} form, so each individual has one observation in the dataset and separate
variables for measurements at each time point. For example, if weight was measured at each
time point beginning at time point 1, the dataset contains variables {it:weight1}, 
{it:weight2} etc. All time points must be positive integer values with 1 unit increments. 
{cmd:twofold} does not support {it:if} or {it:in} and can only impute all individuals in the dataset.

{pstd}
It is important to consider how appropriate it is to use the {opt keepoutside} option. 
For example, it may not be appropriate 
to keep imputed values after individuals die because {cmd:twofold} treats these individuals as if 
they survived, because the individuals imputations are based on did survive to this time, and 
the imputed values are estimates of the measurements they would have had if they had survived.

{pstd}
If a time-dependent variable with missing values is completely observed or completely missing 
at a single time point, {cmd:twofold} will skip this time point. If the time block is completely observed, 
the other conditional models will still condition on it, but not if it is completely missing.


{title:Examples}

{phang}
Model of interest: {cmd:regress y x1 x2 x31 x41}{break}
{it:x1} and {it:x2} are fully observed time-independent variables ({it:x1} categorical, {it:x2} continuous).
{it:x3} is fully observed time-dependent variable.
{it:x4} is time-dependent variable with missing values.
Measurements of {it:x3} and {it:x4} at time point 1, {it:x31} and {it:x41} are included in the model of interest.
Follow-up is defined from variable {it:first} to variable {it:last} 

{pmore}
{cmd:twofold, timein(first) timeout(last) clear depmis(x4) indobs(x1 x2) outcome(y) depobs(x3) cat(x1) m(5) ba(10) bw(5) width(1) table}

{phang}
Model of interest: {cmd:regress y x1 x2 x31 x41 x5}{break}
Where {it:x5} is time-independent variable with missing values.
{it:first} is specified using the option {opt base} as the baseline time point for each individual
because measurements at time point 1 are included in the model of interest.

{pmore}
{cmd:twofold, timein(first) timeout(last) clear depmis(x4) indmis(x5) indobs(x1 x2) outcome(y) depobs(x3) cat(x1) m(5) ba(10) bw(5) width(1) table base(first)}

{phang}
Model of interest: {cmd:poisson y x1 x2 x31 x41 x5, e(time)}{break}
If a time-to-event model is used, both outcome variables are included in the imputation model.

{pmore}
{cmd:twofold, timein(first) timeout(last) clear depmis(x4) indmis(x5) indobs(x1 x2) outcome(y time) depobs(x3) cat(x1 y) m(5) ba(10) bw(5) width(1) table base(first)}


{title:Acknowledgments}

{pstd}
The {cmd:twofold} command was developed as a part the project entitled “Missing data imputation in clinical databases: development of a longitudinal model for cardiovascular risk factors” 
funded by the UK Medical Research Council. We would like to thank Ian White, Louise Marston and Sarah Hardoon for testing the command and their suggested improvements to the code and this manuscript. 


{title:References}

{phang}
Nevalainen, J., M. G. Kenward, and S. M. Virtanen. 2009.
Missing values in longitudinal dietary data: a multiple imputation 
approach based on a fully conditional specification.
{it:Statistics in Medicine} 28(29): 3657-3669.


{phang}
Carlin, J. B., J. C. Galati, and P. Royston. 2008.
A new framework for managing and analyzing multiply imputed data in Stata.
{it:Stata Journal} 8(1): 49-67


{title:Author}

{pstd}Catherine Welch{p_end}
{pstd}University College London{p_end}
{pstd}London, UK{p_end}
{pstd}catherine.welch@ucl.ac.uk{p_end}


{title:Also see}

{psee}
Online:  {helpb mi impute}
{p_end} 
