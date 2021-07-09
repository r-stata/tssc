{smcl}
{* *! version 17Mar2017}{...}
{hline}
help for {hi:expy}
{hline}

{title:Calculation of the EXPY-index as proposed by Hausmann et {it:al.} (2007)}

{p 8 17 2}
{cmd:expy}
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
{cmd:using} {it:filename} {cmd:, } 
{cmd:{ul:tr}ade(}{it:varname}{cmd:)}
{cmd:id(}{it:varname}{cmd:)}
{cmd:prody(}{it:varlist}{cmd:)}
{cmd:{ul:prod}uct(}{it:varname}{cmd:)}
[
{cmd:label(}{it:string}{cmd:)}
{cmd:{ul:t}ime(}{it:varname}{cmd:)}
{cmd:{ul:name}prody(}{it:string}{cmd:)}
replace
]


{title:Related}

{p 4 4 2}
{help prody:prody} {hline 2} Calculation of factor intensity and sophistication indicators such as the PRODY index by Hausmann et al. (2007).

{title:Description}

{p 4 4 2}
{cmd:expy} calculates the EXPY-index as proposed by Hausmann et {it:al} (2007). Its calculation requires unilateral and disaggregated trade data and PRODY-values.
The result is stored in an external file which is specified by {cmd:using} {it:filename}.


{title:Options}

{p 4 7 2}
{cmd:{ul:tr}ade(}{it:varname}{cmd:)} specifies the variable containing trade flows.

{p 4 7 2}
{cmd:id(}{it:varname}{cmd:)} specifies the variable that identifies countries.

{p 4 7 2}
{cmd:prody(}{it:varlist}{cmd:)} specifies PRODY variables to be used for calculating EXPY.
For every PRODY (provided by {it:varlist}) an EXPY is calculated; the variable name ends with the same suffix as the corresponding PRODY variable.


{p 4 7 2}
{cmd:{ul:prod}uct(}{it:varname}{cmd:)} specifies the variable that classifies trade.

{p 4 7 2}
{cmd:{ul:lab}el(}{it:string}{cmd:)} overrides the default variable labels that correspond with variable labels of respective PRODY variables.

{p 4 7 2}
{cmd:{ul:t}ime(}{it:varname}{cmd:)} if your dataset contains a time variable, it has to be specified.

{p 4 7 2}
{cmd:{ul:name}prody(}{it:string}{cmd:)} specifies the name of PRODY variables.
This option has to be used where more than one EXPY is calculated and if the PRODY variables do not start with "prody" or "PRODY".
For further clarification, please consider the following example:

{p 9 9 2}
Suppose that several versions of capital intensities have been calculated previously, and are called "string_v1", "string_v2", etc. When these intensities are intended to be used for calculating "expy_v1", "expy_v2", etc, it is essential to specify {cmd:nameprody(}{it:string}{cmd:)} in order to enable the program expy to match and parse variable names.

{title:Examples}

{col 3}{inp:{stata "use http://www.uni-regensburg.de/wirtschaftswissenschaften/vwl-moeller/medien/prody/output_prody.dta, clear"}}
*Please note: this are no real data

{col 3}{inp:{stata "merge 1:m year indicator_desc using http://www.uni-regensburg.de/wirtschaftswissenschaften/vwl-moeller/medien/prody/data_prody, keep(match) nogen "}}

{col 3}{inp:{stata "expy using data_expy , trade(value) prody(prody*) id(country_desc) product(indicator_desc) time(year) replace"}}

{col 3}{inp:{stata "use data_expy, clear"}}

{title:References}

{p 5 8 2} 
Stephan Huber (2016): "Factor Intensities and Product Sophistication: Measurement Matters". Downloadable under:
http://dx.doi.org/10.2139/ssrn.2843713 

{p 5 8 2} 
Ricardo Hausmann, Jason Hwang and Rodrik Dani (2007). "What You Export Matters". Journal of Economic Growth 12(1), 1-25

{title:Author}

{col 5} Stephan Huber
{col 5} Email: {browse "mailto:stephan.huber@wiwi.uni-regensburg.de":stephan.huber@wiwi.uni-regensburg.de}
