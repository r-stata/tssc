{smcl}
{* 28Apr2012}{...}
{hline}
help  {cmd:mltl2scatter} {right: {browse "mailto:moehring@wiso.uni-koeln.de": Katja Moehring} and {browse "mailto:alex@alexanderwschmidt.de": Alexander Schmidt}}
{hline}

{title:Bivariate scatter plots for higher-level units (beta version)}

{p 4}Syntax

{p 8 14}{cmd:mltl2scatter yvar xvar [if] [weight]} 
 {cmd:, l2id(varname)} 
[ {cmd:keepvars labels lfit qfit} ]



{p 4 4} {cmd:mltl2scatter} is part of the {helpb mlt:mlt} (multilevel tools) package. 


{title:Description}

{p 4 4} {cmd:mltl2scatter} is an easy way to produce scatter plots for higher-level units. 
It calculates the mean of the specified variables ({cmd:yvar} and {cmd:xvar})
at the level specified with the {cmd:l2id(varname)} option. The options allow some formatting of the scatter plot.  
However, if you want to customize the graph, 
it is useful to specify the {cmd:keepvars} option.
{cmd:mltl2scatter} will keep the calculated variables and you can use them to produce any graph.   

{p 4 4} {cmd:mltl2scatter} can be used together with {helpb mlt2stage:mlt2stage} to produce two-stage plots of the estimated single country regression coefficients  
of a lower-level variable over a higher-level variable. See Mood (2010) for the comparison of logit models based on different samples.

{p 4 4} {cmd:mltl2scatter} allows to specify a weight for the units at the lower level.
 {cmd:aweights}, {cmd:fweights} and {cmd:iweights} are allowed. See the help for
{helpb summarize: summarize} to read how these weights are treated.
 


{title:Options}

{p 4 8} {cmd:keepvars} can be specified to keep the variables produced by {cmd:mltl2scatter}. This option is useful in order to customize the graph in your own style.

{p 4 8} {cmd:labels} includes the value labels of the variable specified in the {cmd:l2id(varname)} option as marker labels in the scatter plot.

{p 4 8} {cmd:lfit} includes a linear regression line in the scatter plot.

{p 4 8} {cmd:qfit} includes a non-linear regression line in the scatter plot.


{title:Examples}

{p 4 8} Load data set (ISSP 2006){p_end}
{p 4 8} {cmd:. net get mlt}{p_end}
{p 4 8} {cmd:. use redistribution.dta}{p_end}

{p 4 8} Bivariate scatter plot of data aggregated to the country-level{p_end}
{p 4 8} {cmd:. mltl2scatter gr_incdiff gini, l2id(Country) labels lfit}{p_end}

{p 4 8} Also see the examples for {helpb mlt2stage:mlt2stage}.{p_end}



{title:References}

{p 4 8} ISSP (2006): International Social Survey Programme - Role of Government IV, GESIS StudyNo: ZA4700, Edition 1.0, doi:10.4232/1.4700.

{p 4 8} Carina Mood (2010): “Logistic Regression: Why We Cannot Do What We Think We Can Do, and What We Can Do About It.” {it:European Sociological Review} 26 (1): 67-82. 


{title:Author}

{p 4 6} Katja Moehring, GK SOLCIFE, University of Cologne, {browse "mailto:moehring@wiso.uni-koeln.de":moehring@wiso.uni-koeln.de}, {browse "www.katjamoehring.de":www.katjamoehring.de}.

{p 4 6} Alexander Schmidt, GK SOCLIFE and Chair for Empirical Economic and Social Research, University of Cologne, {browse "mailto:alex@alexanderwschmidt.de":alex@alexanderwschmidt.de}, 
{browse "www.alexanderwschmidt.de":www.alexanderwschmidt.de}.


{title:Also see}

{p 4 8}   {helpb mlt: mlt}, {helpb mltrsq: mltrsq}, {helpb mltcooksd: mltcooksd}, {helpb mltshowm: mltshowm}, {helpb mlt2stage: mlt2stage}
