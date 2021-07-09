{smcl}
{* 06Mar2012}{...}
{hline}
help  {cmd:mltrsq} {right: {browse "mailto:moehring@wiso.uni-koeln.de": Katja Moehring} and {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt}}
{hline}

{title:Calculating R-squared after two-level mixed models (beta version)}

{p 4}Syntax

{p 8 14}{cmd:mltrsq} 
[ {cmd:,} ]
[ {cmd:full} ]



{p 4 4} {cmd:mltrsq} is part of the {helpb mlt:mlt} (multilevel tools) package. 


{title:Description}

{p 4 4} {cmd:mltrsq} is an postestimation command for xtmixed (Stata Version 12 or above). It works after mixed models with two levels. 
{cmd:mltrsq} gives two different R-squared values for each level: 

{p 8 8} (1.) R-squared as proposed by Snijders and Bosker (1994: 350-354), also see Snijders and Bosker (1999, 99-105); and  

{p 8 8} (2.) R-squared proposed by Bryk and Raudenbush (1992: 68).  

{p 4 4} {cmd:mltrsq} will use the same Likelihood-function that has been specified for xtmixed.
Note that in Stata 12 the default Likelihood-function is Maximum Likelihood (mle).

{p 4 4} {cmd:mltrsq} provides different statistics as scalars. These results can be used with {helpb estimates table: estimates table}
 or {helpb estout: estout} (if installed). We provide the following statistics:
 
{dlgtab 8 0: scalars}
 
{space 6} {cmd: e(N_l2)} {col 25} {lalign 25: number of level-2 units}

{space 6} {cmd: e(sb_rsq_l1)} {col 25} {lalign 25: level-1 Snijders/Bosker R-squared}

{space 6} {cmd: e(sb_rsq_l2)}  {col 25} {lalign 25: level-2 Snijders/Bosker R-squared}

{space 6} {cmd: e(br_rsq_l1)}  {col 25} {lalign 25: level-1 Bryk/Raudenbush R-squared}

{space 6} {cmd: e(br_rsq_l2)}  {col 25} {lalign 25: level-2 Bryk/Raudenbush R-squared} 

 
{title:Options}

{p 4 8} {cmd:full} lists additionally the Harmonic mean of the level-2 group sizes, which is used for the calculation of the R-squared according to Snijders and Bosker, 
and the Random-effects parameters of the specified model and the null-model.  {cmd:mltrsq} will also report the variance components of the null model and the last 
model estimated by the user. 

{title:Example}

{p 4 8} Load data set (ISSP 2006){p_end}
{p 4 8} {cmd:. net get mlt}{p_end}
{p 4 8} {cmd:. use redistribution.dta}{p_end}

{p 4 8} Multilevel regression of "Support for income redistribution"{p_end}
{p 4 8} {cmd:. xtmixed gr_incdiff sex age incperc rgdppc gini || Country: , mle var }{p_end}

{p 4 8} Calculate R-sqaured{p_end}
{p 4 8} {cmd:. mltrsq}{p_end}

{p 4 8} Use statistics in estimation table{p_end}
{p 4 8} {cmd:. est store m1}{p_end}
{p 4 8} {cmd:. esttab m1, stats(N_l2 sb_rsq_l1 sb_rsq_l2)}{p_end}




{title:References}

{p 4 8} ISSP (2006): International Social Survey Programme - Role of Government IV, GESIS StudyNo: ZA4700, Edition 1.0, doi:10.4232/1.4700.

{p 4 8} Tom A.B. Snijders, and Roel J. Bosker (1994): “Modeled Variance in Two-Level Models.” {it:Sociological Methods & Research} 22 (3), 342-363. 

{p 4 8} Tom A.B. Snijders and Roel J. Bosker (1999): Multilevel Analysis. An Introduction to Basic and Advanced Multilevel Modeling. London: Sage.

{p 4 8} A.S. Bryk  and S.W. Raudenbush (1992): Hierarchical Linear Models in Social and Behavioral Research: Applications and Data Analysis Methods. Newbury Park, CA: Sage Publications. 


{title:Authors}

{p 4 6} Katja Moehring, GK SOLCIFE, University of Cologne, {browse "mailto:moehring@wiso.uni-koeln.de":moehring@wiso.uni-koeln.de}, {browse "www.katjamoehring.de":www.katjamoehring.de}.

{p 4 6} Alexander Schmidt, GK SOCLIFE and Chair for Empirical Economic and Social Research, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alex@alexanderwschmidt.de}, 
{browse "www.alexanderwschmidt.de":www.alexanderwschmidt.de}.


{title:Also see}

{p 4 8}   {helpb mlt: mlt}, {helpb mltcooksd: mltcooksd}, {helpb mltshowm: mltshowm}, {helpb mltl2scatter: mltl2scatter}, {helpb mlt2stage: mlt2stage}
