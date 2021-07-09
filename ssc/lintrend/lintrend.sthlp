{smcl}
{* 28apr2003}{...}
{hline}
help for {cmd:lintrend}
{hline}

{title:Assessing linear trends}   

{p 6 21 2} 
{cmdab:lintrend} {it:yvar} {it:xvar} 
   [{cmd:if} {it:exp}] [{cmd:in} {it:range}]{cmd:,}
   [{cmdab:g:roups(}#{cmd:)}
    {cmdab:r:ound(}#{cmd:)}
    {cmdab:i:nt}] 
   [{cmdab:g:raph}
    {cmdab:prop:ortion}    
    {cmdab:nol:ine}
    {it:graph_options}]


{title:Description}

{p 4 8 4}
{cmd:lintrend} examines the "linearity" assumption for an ordinal or interval X
  variable against category means of a continuous outcome or the logodds of a
  binary outcome; default prints means or logodds, and a test for linear trend
  (based on linear or logistic regression); optionally a graph is printed of the
  means (for a continuous Y) or logodds for a binary Y 


{title:Variables and options required}

{p 4}{it:yvar} is the dependent variable

{p 4}{it:xvar} is the independent variable
 

{title:Options required}

{p 4 8 2}
{cmd:groups(}#{cmd:)} -- divides {it:xvar} into # categories of similar
   sample size

{p 4 8 2}{cmd:round(}#{cmd:)} -- rounds {it:xvar} to nearest #

{p 4 8 2}
{cmd:interger} -- {it:xvar} is ordinal or nominal; categories original
   integer values


{title:Options} 

{p 4 8 2} {cmd:graph} -- Graphs result

{p 10 8 2} Means of Y for continuous {it:yvar}

{p 10 8 2} Logodds of Y for binary {it:yvar}

{p 6 8 2} {cmd:proportion} -- Graphs proportions in addition to logodds


{p 4 8 2}   
{cmd:noline} -- doesn't print regression line for mean or logodds plot


{title:Examples}

{p 4 8 2}
{cmd:. lintrend died age, groups(8) graph}

{p 8 8 2}
Calculates the proportions and logodds of dying by age in 8 categories
of similar sample size; graphs logodds of deaths by age category

{p 4 8 2}
{cmd:. lintrend sbp age, groups(10) graph}

{p 8 8 2}
Calculates mean systolic blood pressure for age in 10 categories of
similar sample size; graphs mean systolic blood pressure by age category

{p 4 8 2}
{cmd:. lintrend chd chl, round(20) graph prop}

{p 8 8 2}
Calculates the proportions and logodds of developing coronary heart
disease by cholesterol level in categories rounded to 20 unit increments
of cholesterol; two graphs: 1) proportions and 2) logodds

{p 4 8 2}
{cmd:. lintrend chd ses3cat, integer}

{p 8 8 2}
Calculates the proportion and logodds of developing coronary heart disease
by each of 3 integer categories (1,2,3) of socioeconomic status; no graph


