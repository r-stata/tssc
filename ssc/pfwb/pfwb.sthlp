{smcl}
{* 24may2017}{...}
{hline}
help for {hi:pfwb}
{hline}

{title:Stata module for predicting Financial Well-Being scale scores from CFPB survey instrument.}

{title:Syntax}

{p 6 16 2}
{cmd:pfwb} [{varname}] {ifin} 
[{cmd:,} {cmd:qlist(}{vars}{cmd:)} {cmd:agevar(}{varname}{cmd:)} {cmd:modevar(}{varname}{cmd:)} {cmd:replace} {cmdab:intp:oints(}{it:n}{cmd:)} {cmd:zlimit(}{it:z}{cmd:)} {cmdab:round(}{it:r}{cmd:)} {cmd:missok} {cmd:skipcorr}]
{p_end}

{marker contents}{dlgtab: Table of Contents}
{p 6 16 2}

{p 2}{help pfwb##description:General description}{p_end}
{p 2}{help pfwb##examples:Examples}{p_end}
{p 2}{help pfwb##options:Description of options}{p_end}
{p 2}{help pfwb##macros:Remarks and saved results}{p_end}
{p 2}{help pfwb##refs:References}{p_end}
{p 2}{help pfwb##acknow:Acknowledgements}{p_end}
{p 2}{help pfwb##citation:Citation of {cmd:pfwb}}{p_end}
{p 2}{help pfwb##citation:Author information}{p_end}

{marker description}{dlgtab:Description}

{p}Please consult CFPB (2017) for details on the use of this command, which scores the CFPB Financial Well-Being (FWB) instrument.{p_end}

{dlgtab:Preparing Your Data}

{p}Step 1: Name your variables.{p_end}
{p}This is perhaps the most important of the steps.  Please pay special attention to providing your variables with the proper names.  Variables capturing responses to the 10 
financial well-being items in your data will need to renamed according to Table 9 in CFPB (2017).{p_end}

{p 6 16 2}"I could handle a major unexpected expense" should be named fwb1_exp{p_end}
{p 6 16 2}"I am just getting by financially" should be named fwb2_getby{p_end}
{p 6 16 2}"I am securing my financial future" should be named fwb3_secure{p_end}
{p 6 16 2}"I am concerned that the money I have or will save won't last" should be named fwb4_concern{p_end}
{p 6 16 2}"Because of my money situation, I feel like I will never have the things I want in life" should be named fwb5_never{p_end}
{p 6 16 2}"I can enjoy life because of the way I'm managing my money" should be named fwb6_enjoy{p_end}
{p 6 16 2}"I am behind with my finances" should be named fwb7_behind{p_end}
{p 6 16 2}"My finances control my life" should be named fwb8_control{p_end}
{p 6 16 2}"Giving a gift for a wedding, birthday, or other occasion would put a strain on my finances for the month" should be named fwb9_strain{p_end}
{p 6 16 2}"I have money left over at the end of the month" should be named fwb10_left{p_end}

{hline}

{p}Step 2: Set missing values to missing.{p_end}
{p}While the financial well-being scales do not include "Refused" or "Don't know" responses, you may still encounter missing or non-substantive data.  
If this is the case, you will need to recode the data to indicate that it is missing.  In Stata, this would mean coding those responses to "." to indicate {help missing}.
{p_end}

{hline}

{p}Step 3: Recode responses.{p_end}
{p}Before you can score the data, you must ensure that responses are coded as 0 to 4 where 4 is always the most positive financial well-being response.  For example, with "My finances control my life," a response of "Never" should be coded as 4 and a response of "Always" should be coded as 0.  With "I am securing my financial future," a response of "Completely" should be coded as 4 and a response of "Not at all" should be coded as 0.  Reverse coded items are fwb2_ getby, fwb4_concern, fwb5_never, fwb7_behind, fwb8_control, and fwb9_strain.
The Stata program should exit with an error code if the items are not recoded properly.  To determine whether items are coded properly, the program checks average correlations across negatively and positively worded items to ensure that the correlation is positive on average. This does not guarantee that the scoring has been done correctly, since data can exhibit some pathological correlations, or one variable might be wrong while average correlations are correct, but should prevent the most egregious scoring errors where no survey response have been corrected for reverse coding.  
{p_end}

{hline}

{p}Step 4: Create the indicators for your group codes: mode of administration ("self") and age group ("age18_61").
{p_end}
{p}You will need to create the two indicators used by the program to define the groups:{p_end}
{p 6 16 2}Indicator 1: "age18_61" - set this indicator to 1 if the respondent is ages 18 to 61 and to 0 if the respondent is ages 62 or older.{p_end}
{p 6 16 2}Indicator 2: "self" - set this indicator to 1 if the survey was self-administered and to 0 if the survey was completed in an interview.{p_end}
{p}This is also a crucially important step.  Correct group codes ensure that the proper parameters are applied in estimating your scores.  To determine which parameters to use in scoring each case, the program creates an indicator of the group to which each individual response belongs.  These groups are determined based on age [18 to 61 year versus 62 plus years] and mode of survey administration [self-administered or interview].  Depending on your particular sample and mode of administration, you will have between 1 and 4 groups:  1: 62+, Interview; 2: 62+,, Self-Administered; 3: 18-61, Interview; 4: 18-61, Self-Administered.
{p_end}

{hline}

{p}The five-question version of the scale should include all 10 variables, but have nonmissing entries only for 5 of them:{p_end}

{p 6 16 2}fwb2_getby "I am just getting by financially." (4=Does not describe me at all, 0=Describes me completely){p_end}
{p 6 16 2}fwb4_concern "I am concerned that the money I have or will save won't last." (4=Does not describe me at all, 0=Describes me completely){p_end}
{p 6 16 2}fwb5_never "Because of my money situation, I feel like I will never have the things I want in life." (4=Does not describe me at all, 0=Describes me completely){p_end}
{p 6 16 2}fwb8_control "My finances control my life." (4=Never, 0=Always){p_end}
{p 6 16 2}fwb10_left "I have money left over at the end of the month." (0=Never, 4=Always){p_end}

{marker examples}{dlgtab:Examples}

{p}In each example, you can cut and paste the entire block of code to the Command window, or click on commands one by one to run.{p_end}

{hline}
{p}It is crucially important that your data is set up correctly. 
Assuming your data is set up the right way, you can just type {cmd:pfwb FWB} to save scores in a new variable FWB (capital letters are used in this name to mark it as a latent factor, 
but any name may be specified.{p_end}
{hline}
{p 6 16 2}{stata "pfwb FWB, replace missok": pfwb FWB, replace missok}{p_end}

{hline}
{p}If you start with answers coded 1 to 5 instead of 0 to 4, and missing values coded with numbers greater than 5, use this code to fix them.{p_end}

{p 6 16 2}foreach v in fwb1_exp fwb2_getby fwb3_secure fwb4_concern fwb5_never fwb6_enjoy fwb7_behind fwb8_control fwb9_strain fwb10_left { {p_end}
{p 6 16 2} replace `v'=cond(`v'<6,`v'-1,.){p_end}
{p 6 16 2} }{p_end}

{hline}
{p}To reverse the coding for negatively-oriented questions, use this code.{p_end}

{p 6 16 2}foreach v in fwb2_getby fwb4_concern fwb5_never fwb7_behind fwb8_control fwb9_strain { {p_end}
{p 6 16 2} replace `v'=(4-`v'){p_end}
{p 6 16 2} }{p_end}

{marker options}{dlgtab:Options summary}

{phang}
{cmd:agevar({varname})} specifies the name of the indicator variable measuring whether a respondent is working age (under 62) or not (the default name is {bf:age18_61}).
If a respondent is working age (under 62), the agevar should be 1, and if not (age 18-61), the agevar should be 0.
 {p_end}

{phang}
{cmd:modevar({varname})} specifies the name of the indicator variable measuring whether the items were self-administered or not (the default name is {bf:self}).
If items were self-administered, the modevar should be 1, and if not, the modevar should be 0.
The data must have variables for both age (age18_61=1 for 18 to 61 years old and 
age18_61=0 for 62 and older), and mode (self=1 for self-administered surveys, including online surveys, or self=0 for
interviewer-administered surveys, including in-person surveys), which together define 4 groups: 
1 "62 or older, interview" 2 "62 or older, self" 3 "age 18 to 61, interview" 4 "age 18 to 61, self" (these group numbers are used in internal calculations). That is:
Respondents ages 62 and older who had the scale read to them by an interviewer use the "62 or older, interview" parameters (group 1, self=0 and age18_61=0)
respondents ages 62 and older who self-administered the scale use the "62 or older, self" parameters (group 2, self=1 and age18_61=0)
respondents ages 18-61 who had the scale read to them by an interviewer use the "age 18 to 61, interview" parameters (group 3, self=0 and age18_61=1), 
and respondents ages 18-61 who self-administered the scale use the "age 18 to 61, self" parameters (group 4, self=1 and age18_61=1).{p_end}

{phang}
{cmd:qlist({vars})} specifies the 10 variables holding answers (0 to 4 or missing) to the 10 questions; the default is
"fwb1_exp fwb2_getby fwb3_secure fwb4_concern fwb5_never fwb6_enjoy fwb7_behind fwb8_control fwb9_strain fwb10_left" 
(note that "fwb2_getby fwb4_concern fwb5_never fwb7_behind fwb8_control fwb9_strain" should be 
reverse coded since higher-value answers correspond to lower well-being).{p_end}

{phang}
The {cmd:replace} option specifies that {varname} can be overwritten with new values.{p_end}

{phang}
The {cmdab:intp:oints} option specifies that {it:n} points should be evaluated in each dimension of the grid. The default is 49.
Using (by default) a rectangular grid of {it:n} points from -{it:z} to +{it:z} in 3 dimensions (default 49 points, from -6 to +6), 
{cmd:pfwb} predicts a scale score from a previously estimated {mansection IRT irtgrm:IRT} model
for answer patterns to the 10 questions on the Financial Well-Being (FWB) survey 
developed by the Consumer Financial Protection Bureau (CFPB). 
The underlying model is a graded response model in the Item Response Theory framework, with two latent factors applying
to each question (a bifactor model), which cannot be fit using {mansection IRT irtgrm:grm} but can be fit using 
{mansection SEM gsem:gsem} with an ordered logit or probit link. One latent factor is common to all questions,
and that common factor measures Financial Well-Being (FWB). The model is fit using parameters estimated by Vector Psychometrics, which are different depending on the age of respondent and 
the mode of survey administration. See CFPB (2017) for more detail.
{p_end}

{phang}
The {cmd:ghq} option requests a different numerical integration method, and specifying the {cmd:gsem} option 
estimates a {cmd:gsem} model and predicts using that model. Neither of these options will produce the official CFPB
scores, but will typically be correlated at 0.99 or better, and may offer substantial speed improvements in large datasets.
{p_end}

{phang}
The {cmd:zlimit} option specifies that the grid should stretch from -{it:z} to {it:z} in each dimension. The default is 6.{p_end}

{phang}
The {cmd:round} option specifies EAP scores should be rounded to the nearest {it:r}. The default is 1 (rounding to the nearest integer).{p_end}

{phang}
The {cmd:missok} option specifies that EAP scores can still be calculated if all responses are missing (using priors); the default is that the score is missing in this case.{p_end}

{phang}
The {cmd:skipcorr} option skips a check that correlations across negatively oriented and positively oriented items have the expected average sign.{p_end}

{marker macros}{dlgtab:Saved results}

{p}The command saves the following results in {cmd:r()}:{p_end}

Scalars

{p 3 18 2}{cmd:r(ghq)} 1 if ghq integration method used; 0 otherwise{p_end}

{p 3 18 2}{cmd:r(intpoints)} Number of integration points used in each dimension{p_end}

{p 3 18 2}{cmd:r(zlimit)} Upper (and negative of lower) limit of integration if ghq integration method not used{p_end}

{p 3 18 2}{cmd:r(round)} Rounding for EAP scores{p_end}


{marker refs}{title:References} 

{p}For a description of the CFPB instruments and their development, see documents on the CFPB website e.g. 
{browse "http://www.consumerfinance.gov/data-research/research-reports/financial-well-being-scale/":http://www.consumerfinance.gov/data-research/research-reports/financial-well-being-scale/}{p_end}

{phang}CFPB. 2017. {browse "https://www.consumerfinance.gov/data-research/research-reports/financial-well-being-technical-report/":Financial Well-Being Technical Report}.{p_end}

{p}For more on bifactor GRM models, see e.g.

{phang}Gibbons, Robert D., R. Darrell Bock, Donald Hedeker, David J. Weiss, Eisuke Segawa, Dulal K. Bhaumik, David J. Kupfer, Ellen Frank, Victoria J. Grochocinski, and Angela Stover.
(2007). "Full-information item bifactor analysis of graded response data." Applied Psychological Measurement, 31, 4-19.{p_end}

{phang}Cai, L., Yang, J.S., & Hansen, M. (2011). "Generalized full-information item bifactor analysis." Psychological Methods, 16, 221-247.{p_end}

{phang}Cai, L. (2010). "A Two-Tier Full-Information Item Factor Analysis Model With Applications." Psychometrika, 75(4):581-612.{p_end}

{marker acknow}{title:Acknowledgements}

{p}Jeff Pitblado very kindly added key functionality to {help gsem} and {help irt} to predict out of sample (included in Stata 14.2 as of 
September 6, 2016), enabling out-of-sample comparisons of
the rectangular grid used in this program and the {mansection IRT irthybrid:MVAGHQ method} EB methods used in those programs.
R.J. Wirth of Vector Psychometric Group helpfully described the details of estimation and scoring in flexMIRT.{p_end}

{marker citation}{title:Citation of {cmd:pfwb}}

{p}{cmd:pfwb} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Nichols, Austin. 2017.
pfwb: Stata module for predicting Financial Well-Being scale scores from CFPB survey instrument.
{browse "https://ideas.repec.org/c/boc/bocode/s458353.html":https://ideas.repec.org/c/boc/bocode/s458353.html}{p_end}

{title:Author}

    Austin Nichols
    Abt Associates
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 14}Manual: {mansection SEM section31g:SEM} manual, {hi:especially Example 31g demonstrating a generalized IRT model};
{mansection IRT} manual, especially {mansection IRT irtgrm:grm} sections, and Methods and formulas for {mansection IRT irthybrid:irt hybrid}
discussing adaptive quadrature; 
{help mf__gauss_hermite_nodes: mata quadrature functions}{p_end}


