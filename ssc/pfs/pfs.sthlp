{smcl}
{* 17apr2017}{...}
{hline}
help for {hi:pfs}
{hline}

{title:Stata module for predicting Financial Skill scale scores from CFPB survey instrument.}

{title:Syntax}

{p 6 16 2}
{cmd:pfs} [{varname}] {ifin} 
[{cmd:,} {cmd:qlist(}{vars}{cmd:)} {cmd:agevar(}{varname}{cmd:)} {cmd:modevar(}{varname}{cmd:)} {cmd:replace} {cmdab:intp:oints(}{it:n}{cmd:)} {cmd:zlimit(}{it:z}{cmd:)} {cmd:ghq} ]
{p_end}

{marker contents}{dlgtab: Table of Contents}
{p 6 16 2}

{p 2}{help pfs##description:General description}{p_end}
{p 2}{help pfs##examples:Examples}{p_end}
{p 2}{help pfs##options:Description of options}{p_end}
{p 2}{help pfs##macros:Remarks and saved results}{p_end}
{p 2}{help pfs##refs:References}{p_end}
{p 2}{help pfs##acknow:Acknowledgements}{p_end}
{p 2}{help pfs##citation:Citation of {cmd:pfs}}{p_end}
{p 2}{help pfs##citation:Author information}{p_end}

{marker description}{dlgtab:Description}


{p}Please consult CFPB (2017) for details on the use of this command, which scores the CFPB Financial Skill (FS) instrument.{p_end}

{dlgtab:Preparing Your Data}

{p}Step 1: Name your variables.{p_end}
{p}This is perhaps the most important of the steps.  Please pay special attention to providing your variables with the proper names.  Variables capturing responses to the 10 
financial well-being items in your data will need to renamed according to Table 9 in CFPB (2017).{p_end}

{p 6 16 2}"I know how to make complex decisions." should be named fs1_complexdecision{p_end}
{p 6 16 2}"I am able to make good financial decisions that are new to me." should be named fs2_goodnewdecision{p_end}
{p 6 16 2}"I know how to get myself to follow through on my financial intentions." should be named fs3_followthrough{p_end}
{p 6 16 2}"I am able to recognize a good financial investment." should be named fs4_recognizegoodinvestment{p_end}
{p 6 16 2}"I know how to keep myself from spending too much." should be named fs5_keepfromspending{p_end}
{p 6 16 2}"I know how to make myself save." should be named fs6_howtosave{p_end}
{p 6 16 2}I know where to find the advice I need to make decisions involving money." should be named fs7_findadvice{p_end}
{p 6 16 2}"I know when I do not have enough information to make a good decision involving my money" should be named fs8_notenoughinfo{p_end}
{p 6 16 2}"I know when I need advice about my money." should be named fs9_whenadvice{p_end}
{p 6 16 2}"I struggle to understand financial information." should be named fs10_struggleunderstand{p_end}

{hline}

{p}Step 2: Set missing values to missing.{p_end}
{p}While the FS scales do not include "Refused" or "Don't know" responses, you may still encounter missing or non-substantive data.  
If this is the case, you will need to recode the data to indicate that it is missing.  In Stata, this would mean coding those responses to "." to indicate {help missing}.
{p_end}

{hline}

{p}Step 3: Recode responses.{p_end}
{p}Before you can score the data, you must ensure that responses are coded as 0 to 4 where 4 is always the most positive financial skill response.  
For example, with "I struggle to understand financial information," a response of "Never" should be coded as 4 and a response of "Always" should be coded as 0.  
With "I am able to recognize a good financial investment," a response of "Completely" should be coded as 4 and a response of "Not at all" should be coded as 0.  
The only reverse coded items is fs10_struggleunderstand.
The Stata program should exit with an error code if the items are not recoded properly.  
To determine whether items are coded properly, the program checks average correlations across negatively and positively worded items to ensure that the correlation is positive on average. This does not guarantee that the scoring has been done correctly, since data can exhibit some pathological correlations, or one variable might be wrong while average correlations are correct, but should prevent the most egregious scoring errors where no survey response have been corrected for reverse coding.  
{p_end}

{hline}

{p}Step 4: Create the indicators for your group codes: mode of administration ("self") and age group ("age18_61").
{p_end}
{p}You will need to create the two indicators used by the program to define the groups:{p_end}
{p 6 16 2}Indicator 1: "age18_61" - set this indicator to 1 if the respondent is ages 18 to 61 and to 0 if the respondent is ages 62 or older.{p_end}
{p 6 16 2}Indicator 2: "self" - set this indicator to 1 if the survey was self-administered and to 0 if the survey was completed in an interview.{p_end}
{p}This is also a crucially important step.  Correct group codes ensure that the proper parameters are applied in estimating your scores.  To determine which parameters to use in scoring each case, the program creates an indicator of the group to which each individual response belongs.  These groups are determined based on age [18 to 61 year versus 62 plus years] and mode of survey administration [self-administered or interview].  Depending on your particular sample and mode of administration, you will have between 1 and 4 groups:  1: 62+, Interview; 2: 62+,, Self-Administered; 3: 18-61, Interview; 4: 18-61, Self-Administered.
{p_end}


{p}At the end of preparing the data, the 10 responses should be coded 0 to 4 and items must correspond to the following:

{p 6 16 2}fs1_complexdecision           I know how to make complex decisions. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}  
{p 6 16 2}fs2_goodnewdecision           I am able to make good financial decisions that are new to me. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs3_followthrough             I know how to get myself to follow through on my financial intentions. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs4_recognizegoodinvestment   I am able to recognize a good financial investment. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs5_keepfromspending          I know how to keep myself from spending too much. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs6_howtosave                 I know how to make myself save. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs7_findadvice                I know where to find the advice I need to make decisions involving money. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little,4=Describes me completely){p_end}
{p 6 16 2}fs8_notenoughinfo             I know when I do not have enough information to make a good decision involving my money. (0=Never, 1=Often, 2=Sometimes, 3=Rarely, 4=Always){p_end}
{p 6 16 2}fs9_whenadvice                I know when I need advice about my money. (0=Never, 1=Often, 2=Sometimes, 3=Rarely, 4=Always){p_end}
{p 6 16 2}fs10_struggleunderstand       I struggle to understand financial information. (4=Never, 3=Rarely, 2=Sometimes, 1=Often, 0=Always){p_end}

{p}Note that the first 7 items are statements that a respondent rates as to 
"How well does this statement describe you or your situation?" and the next 3 as to
"How often does this statement apply to you?"  
and the final question employs "reverse coding" (which may required recoding as described below in the Examples). 
Items not asked, or "Don't know" or "Refused" answers, should be coded {help missing}.{p_end}

{p}The five-question version of the scale should include all 10 variables above, but have nonmissing entries only for:

{p 6 16 2}fs1_complexdecision     I know how to make complex decisions. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs3_followthrough       I know how to get myself to follow through on my financial intentions. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs6_howtosave           I know how to make myself save. (0=Does not describe me at all, 1=Describes me very well, 2=Describes me somewhat, 3=Describes me very little, 4=Describes me completely){p_end}
{p 6 16 2}fs8_notenoughinfo       I know when I do not have enough information to make a good decision involving my money. (0=Never, 1=Often, 2=Sometimes, 3=Rarely, 4=Always){p_end}
{p 6 16 2}fs10_struggleunderstand I struggle to understand financial information. (4=Never, 3=Rarely, 2=Sometimes, 1=Often, 0=Always){p_end}

{hline}
{p}Please consult CFPB (2017) for further details on the use of this command.
Using (by default) a rectangular grid of {it:n} points from -{it:z} to +{it:z} in 5 dimensions (default 31 points, from -4 to +4), 
{cmd:pfs} predicts a scale score from a previously estimated {mansection IRT irtgrm:IRT} model
for answer patterns to the 10 questions on the Financial Skill (FS) survey 
developed by the Consumer Financial Protection Bureau (CFPB).{p_end}

{p}The underlying model is a graded response model in the Item Response Theory framework, with two latent factors applying
to each question (a bifactor model), which cannot be fit using {mansection IRT irtgrm:grm} but can be fit using 
{mansection SEM gsem:gsem} with an ordered logit or probit link. One latent factor is common to all questions,
and that common factor measures Financial Skill (FS).{p_end}

{marker examples}{dlgtab:Examples}

{p}In each example, you can cut and paste the entire block of code to the Command window, or click on commands one by one to run.{p_end}

{hline}
{p}Assuming your data is set up the right way, just type {cmd:pfs F} to save scores in a new variable F.{p_end}
{hline}
{p 6 16 2}{stata "pfs FS, replace": pfs FS, replace }{p_end}

{hline}
{p}If you start with answers coded 1 to 5 instead of 0 to 4, and missing values coded with numbers greater than 5, use this code to fix them.

{p 6 16 2}foreach v in fs1_complexdecision fs2_goodnewdecision fs3_followthrough fs4_recognizegoodinvestment fs5_keepfromspending fs6_howtosave fs7_findadvice fs8_notenoughinfo fs9_whenadvice fs10_struggleunderstand { {p_end}
{p 6 16 2} replace `v'=cond(`v'<6,`v'-1,.){p_end}
{p 6 16 2} }{p_end}

{hline}
{p}To reverse the coding for negatively-oriented questions, use this code.

{p 6 16 2}foreach v in fs10_struggleunderstand { {p_end}
{p 6 16 2} replace `v'=(4-`v'){p_end}
{p 6 16 2} }{p_end}

{marker options}{dlgtab:Options summary}

{phang}
{cmd:agevar({varname})} specifies the name of the indicator variable measuring whether a respondent is working age (under 62) or not (the default name is {bf:age18_61}).
If a respondent is working age (under 62), the agevar should be 1, and if not (age 18-61), the agevar should be 0.{p_end}

{phang}
{cmd:modevar({varname})} specifies the name of the indicator variable measuring whether the items were self-administered or not (the default name is {bf:self}).
If items were self-administered, the modevar should be 1, and if not, the modevar should be 0.{p_end}

{phang}
{cmd:qlist({vars})} specifies the 10 variables holding answers (0 to 4 or missing) to the 10 questions; the default is
"fs1_complexdecision fs2_goodnewdecision fs3_followthrough fs4_recognizegoodinvestment fs5_keepfromspending 
fs6_howtosave fs7_findadvice fs8_notenoughinfo fs9_whenadvice fs10_struggleunderstand" (note that "fs10_struggleunderstand" should be 
reverse coded since higher-value answers correspond to lower Financial Skill).

{phang}
The {cmd:replace} option specifies that {varname} can be overwritten with new values.

{phang}
The {cmdab:intp:oints} option specifies that {it:n} points should be evaluated in each dimension of the grid. The default is 31.

{phang}
The {cmd:zlimit} option specifies that the grid should stretch from -{it:z} to {it:z} in each dimension. The default is 4.

{phang}
The {cmd:round} option specifies EAP scores should be rounded to the nearest {it:r}. The default is 1 (rounding to the nearest integer).{p_end}

{phang}
The {cmd:missok} option specifies that EAP scores can still be calculated if all responses are missing (using priors); the default is that the score is missing in this case.{p_end}

{phang}
The {cmd:skipcorr} option skips a check that correlations across negatively oriented and positively oriented items have the expected average sign.{p_end}


{marker macros}{dlgtab:Saved results}

{p}The command saves the following results in {cmd:r()}:{p_end}

Scalars

{p 3 18 2}{cmd:r(intpoints)} Number of integration points used in each dimension{p_end}

{p 3 18 2}{cmd:r(zlimit)} Upper (and negative of lower) limit of integration if ghq integration method not used{p_end}

{p 3 18 2}{cmd:r(round)} Rounding for EAP scores{p_end}

{marker refs}{title:References}

{p}For a description of the CFPB instruments and their development, see documents on the CFPB website e.g. 
{browse "http://www.consumerfinance.gov/data-research/research-reports/financial-well-being-scale/":http://www.consumerfinance.gov/data-research/research-reports/financial-well-being-scale/}{p_end}

{phang}CFPB. 2017. Scoring Financial Well-Being and Financial Skill Instruments Using IRT.

{p}For more on bifactor GRM models, see e.g.

{phang}Gibbons, Robert D., R. Darrell Bock, Donald Hedeker, David J. Weiss, Eisuke Segawa, Dulal K. Bhaumik, David J. Kupfer, Ellen Frank, Victoria J. Grochocinski, and Angela Stover.
(2007). "Full-information item bifactor analysis of graded response data." Applied Psychological Measurement, 31, 4-19.{p_end}

{phang}Cai, L., Yang, J.S., & Hansen, M. (2011). "Generalized full-information item bifactor analysis." Psychological Methods, 16:221-247.{p_end}

{phang}Cai, L. (2010). "A Two-Tier Full-Information Item Factor Analysis Model With Applications." Psychometrika, 75(4):581-612.

{marker acknow}{title:Acknowledgements}

{p}Jeff Pitblado very kindly added key functionality to {help gsem} and {help irt} to predict out of sample (included in Stata 14.2 as of 
September 6, 2016), enabling out-of-sample comparisons of
the rectangular grid used in this program and the {mansection IRT irthybrid:MVAGHQ method} EB methods used in those programs.
R.J. Wirth of Vector Psychometric Group helpfully described the details of estimation and scoring in flexMIRT.{p_end}

{marker citation}{title:Citation of {cmd:pfs}}

{p}{cmd:pfs} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Nichols, Austin. 2016.
pfs: Stata module for predicting Financial Skill scale scores from CFPB survey instrument.
{browse "http://ideas.repec.org/c/boc/bocode/s458479.html":http://ideas.repec.org/c/boc/bocode/s458479.html}{p_end}

{title:Author}

    Austin Nichols
    Abt Associates
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 14}Manual: {mansection SEM section31g:SEM} manual, {hi:especially Example 31g demonstrating a generalized IRT model};
{mansection IRT} manual, especially {mansection IRT irtgrm:grm} sections, and Methods and formulas for {mansection IRT irthybrid:irt hybrid}
discussing adaptive quadrature; {help gsem_predict} on prediction of latent variables from generalized IRT models, 
{help mf__gauss_hermite_nodes: mata quadrature functions} on GHQ methods.{p_end}


