{smcl}
{5 January 2018}
{hline}
help for {hi:how_many_imputations} 
{hline}

{title:Title}

{pstd}After {cmd:mi estimate}, run {cmd:how_many_imputations} to get the number of imputations needed to ensure that standard errors estimates would not change too much if the data were imputed again. 

{pstd}After {cmd:how_many_imputations}, run {cmd:mi estimate} again with the recommended number of imputations. Or don't if the recommended number of imputations is less than you used the first time.

{pstd}This two-stage approach to choosing the number of imputations was developed by {browse "https://arxiv.org/abs/1608.05406":von Hippel (2018)}.

{title:Syntax}

{pstd}{cmd:how_many_imputations} [, cv_se(.05) CONFidence(.95)]

{synoptset 25 tabbed}{...}

{marker opt}{synopthdr:options}
{synoptline}
{synopt :{opt cv_se}} Proportion by which you would accept the standard error changing if the data were imputed again. Default is .05. 
{p_end}

{synopt :{opt confidence}} Confidence that the replicability of the standard errror will be at least as good as specified by {cmd:cv_se}. Default is .95. 
{p_end}

{title:Description}

{pstd}When using multiple imputation, you may wonder how many imputations you need. 
The old advice is that 2 to 10 imputations usually suffice, but that only addresses the replicability of point estimates. 
You may need more imputations if you also want replicable standard error (SE) estimates -- i.e., SE estimates that would not change much if you imputed the data again.

{pstd}{cmd:how_many_imputations} helps to implement a two-stage approach which ensures the replicability of SE estimates (von Hippel, 2018).

{pstd}The first stage is a pilot analysis. Impute the data using {cmd: mi impute} with a convenient number of imputations. Analyze the imputed data using {cmd: mi estimate}. 

{pstd}Now run {cmd:how_many_imputations}. You can optionally set how much would you would accept the SE estimates' changing if the data were imputed again ({it:cv_se}). You can optionally set how much {it:confidence} you want that the SEs would typically change by about that much.

{pstd}{cmd:how_many_imputations} outputs an estimate of how many imputations you need to make the SE estimate as replicable as you asked. The output compares the number of imputations that you need to the number of imputations in your pilot analysis, and it tells you how many imputations you need to add.

{pstd}If the output suggests you don't need to add any imputations, you can stop. Otherwise, add the suggested number of imputations using {cmd:mi impute} and analyze the imputed data again using {cmd:mi estimate}. 

{pstd}{cmd:how_many_imputations} also outputs a confidence interval for the largest fraction of missing information (FMI).

{title:Details} 

{pstd}{cmd:how_many_imputations} should be run immediately after {cmd:mi estimate}. If you want to run {cmd:how_many_imputations} again, you should run {cmd:mi estimate} again as well. 

{pstd}{it:cv_se} can be defined more precisely than it was above. It is the coefficient of variation of the SE estimate from one set of imputed datasets to another.

{pstd}The number of imputations to use in the pilot step is up to you. 20 is a reasonable default, but you can use more if you want to, or fewer if the imputations or analysis run slowly. 
Be aware that the fewer imputations you use in the pilot, the more are usually recommended for the final stage (von Hippel, 2018).

{pstd}The number of imputations that you need in the final stage depends on both {it:cv_se} and the FMI. The formula for the number of imputations needed is 

{p 6 4 2}{it:M=1+(1/2)*(fmi_ucl/cv_se)^2}

{pstd}where {it:fmi_ucl} is the upper bound of a pilot confidence interval for FMI. For the derivation and other information, see von Hippel (2018).

{title:Example}

{pstd}//Load the heart attack data and impute it 10 times. The only variable with missing values is {it:bmi}.{p_end}
{p 6 4 2}{cmd:webuse mheart1s0, clear}{p_end}
{p 6 4 2}{cmd:mi impute regress bmi attack smokes age female hsgrad, replace add(10)}{p_end}

{pstd}//Predict heart attack risk using logistic regression.{p_end}
{p 6 4 2}{cmd:mi estimate: logit attack bmi smokes age female hsgrad}

{pstd}//How many imputations would it take to ensure that the least replicable SE in the output would change by only 5% if the data were imputed again?{p_end}
{p 6 4 2}{cmd:how_many_imputations}

{pstd}//The output shows the number of imputations you need to add. That number is also saved in the return value {it:r(add_M)}.{p_end}
{pstd}//If it's zero, you can stop. If it's greater than zero, you can use the return value to add imputations.{p_end}
{p 6 4 2}{cmd:mi impute regress bmi attack smokes age female hsgrad, add(`r(add_M)')}

{pstd}//Now run the logistic regression again.{p_end}
{p 6 4 2}{cmd:mi estimate: logit attack bmi smokes age female hsgrad}

{pstd}//The claim is that the SE estimates would typically change by less than 5% if the data were imputed again with the same number of imputations. Is that true?{p_end}
{pstd}//We can check by re-imputing the data and running the logistic regression again.{p_end}
{p 6 4 2}{cmd:mi impute regress bmi attack smokes age female hsgrad, replace}{p_end}
{p 6 4 2}{cmd:mi estimate: logit attack bmi smokes age female hsgrad}

{pstd}//Are the SEs within about 5% of what they were last time?

{title:Saved Results}
 {pstd}{cmd:r(pilot_M)}: {it:Pilot imputations}. Number of imputations in the pilot analysis. {p_end}
 {pstd}{cmd:r(target_M)}: {it:Target imputations}. Number of imputations you need to achieve a replicable SE estimate.{p_end}
 {pstd}{cmd:r(add_M)}: {it:Additional imputations}. Number of imputations you must add to the pilot imputations to reach the target imputations. {p_end}
 {pstd}{cmd:r(fmi)}: Point estimate for the fraction of missing information (FMI). This pertains to the fraction of information missing about {it:parameter}.{p_end}
 {pstd}{cmd:r(fmi_lcl)}, {cmd:r(fmi_ucl)}: Lower and upper confidence limits for the fraction of missing information.{p_end}
 {pstd}{cmd:r(se)}: Estimated standard error of the parameter estimated in the pilot analysis.{p_end}
 {pstd}{cmd:r(cv_se)}, {cmd:r(confidence)}: Echo the command options {it:cv_se} and {it:confidence}.{p_end}

{title:Author} 

{pstd}Paul von Hippel, University of Texas at Austin, USA{break}
paulvonhippel.utaustin@gmail.com

{title:References}

{pstd}von Hippel, Paul T. (2018). "How many imputations do you need? A two-stage calculation using a quadratic rule." Sociological Methods and Research, in press. 
Also available as an arXiv e-print, {browse "https://arxiv.org/abs/1608.05406"}.

