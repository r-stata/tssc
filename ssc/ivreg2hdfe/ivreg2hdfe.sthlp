{smcl}
{.-}
help for {cmd:ivreg2hdfe} {right:()}
{.-}
 
{title:Title}

ivreg2hdfe - Estimates an Instrumental Variable Linear Regression Model with two High Dimensional Fixed Effects.

{title:Syntax}

{p 8 15}
{cmd:ivreg2hdfe} [{help if}],  DEpvar({help depvar}) ENdog({help varlist}) iv({help varlist}) [EXog({help varlist})] id1({help varname}) id2({help varname}) [cluster({help varname})] [gmm2s]

{p}

{title:Description}

{p} This command builds on the command {help reg2hdfe} and {help ivreg2} for estimation
of a linear instrumental variables regression model with two high dimensional fixed effects. 
The command is particulary useful when an instrumental variable approach is required in particularly
large datasets, because it removes the high dimensional fixed effects from the data in the first step. 
Then it runs the IV model with the transformed variables after the proper demeaning.

{cmd: ivreg2hdfe} requires reg2hdfe, ivreg2 and tmpdir; which can be installed from ssc by typing in the command prompt:
{input:. ssc install reg2hdfe}
{input:. ssc install ivreg2}
{input:. ssc install tmpdir}

{title:Syntax}

{bf:DEpvar({help depvar})}: Dependent Variable

{bf:ENdog({help varlist})}: List of endogenous variables (to be instrumented)

{bf:iv({help varlist})}: List of Instrumental Variables (number of IVs should be at least the 
number of endogenous variables)

{bf:id1({help varname}) id2({help varname})}: Identification of the two high dimensional fixed effects variables 


{title:Options}

{bf:EXog({help varlist})}: List of other exogenous variables 

{bf:cluster({help varname})}: One-way or two-way clustered standard errors

{bf:gmm2s}: Use the Generalized Methods of Moments to estimate the IV regression


{title:Examples}

Estimates a model with two high dimensional fixed effects

{input:. ivreg2hdfe if temp_ext, depvar(newproductRCA_d) en(lnmigrants_M_o lnmigrants_rev_M_o) ex(lnexp_d growthexp_d_lagged expzero_d_lagged) iv(comlang2_B_M_o comlang2_B_rev_M_o)  id1(countryid) id2(productyearid) cluster(countryid) gmm2s}

{title:Author}

{p}
Dany Bahar, Harvard University

{p}
Email: {browse "mailto:dbaharc@gmail.com":dbaharc@gmail.com}

Comments welcome!

{title:Acknowledgements}
This program makes use of {help reg2hdfe} and {help ivreg2} commands.
{p}

{title:Also see}

{p 0 21}
{help reg2hdfe} (if installed), {help ivreg2} (if installed)
{p_end}
