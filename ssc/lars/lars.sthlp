{smcl}
{*  12 Feb 2014}{...}
{cmd:help lars}
{hline}

{title:Title}

    {hi:Least Angle Regression, Forward Stagewise Regression, Lasso estimation}

{title:Syntax}

{p 8 17 2}
{cmdab:lars}
[varlist]
[{help if}]
[{help in}]
[
{cmd:,} {it:options} {help twoway_options }]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt a:lgorithm(string)}} specifies the algorithm to be used in estimation, default is lars.{p_end}
{synopt:{opt e:ps(#)}}is the small number taken as the "machine zero", the default is 0.000001.{p_end}
{synopt:{opt g:raph}} specifies whether a graph of the entire model sequence is plotted.{p_end}
{synopt:{opt gopt(string)}} specifies options to be included in the graph.{p_end}
{synopt:{opt nooutput}} do not display any output.{p_end}
{synopt:{help twoway_options } } --- any twoway options are allowed.{p_end}

{syntab:Prediction}
{synopt:{opt t:ype(string)}} specifies that coefficients are produced from a single realisation of the algorithm.{p_end}
{synopt:{opt m:ode(string)}} specifies the mode of the prediction, the default is step.{p_end}
{synopt:{opt s(#)}} specifies the value at which the prediction is made, the default is 0.5 that means halfway between steps 0
and 1.{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
Least Angle Regression is a model-building algorithm that considers parsimony as well as prediction accuracy.
This method is covered in detail by the paper Efron, Hastie, Johnstone and Tibshirani (2004), published in The Annals of Statistics.
Their motivation for this method was a computationally simpler algorithm for the {hi:Lasso} and {hi:Forward Stagewise} regression.

{pstd}
There are many criticisms of stepwise regression, one of which is that it is a "greedy" algorithm and that the regression
coefficients are too large. Ridge regression is one method of model-building that shrinks the coefficients by making the sum of 
the squared coefficients less than some constant. The {hi:Lasso} is similar but the constaint is that the sum of the "mod" 
coefficients is less than a constant. One implication of this will be that the solution will contain coefficients that are
exactly 0 and hence have the property of parsimony i.e. a simpler model.

{pstd}
The method implemented here is {hi: Least Angle Regression} but the same algorithm can be used to get the {hi:Lasso}
solution or the {hi:Forward Stagewise} solution. It is nearly a complete port of the LARS package written by Hastie and Efron
but I have not translated everything so if anyone spots anything needed or a bug just email me.

{title:Options}

{dlgtab:Main}

{phang}
{opt a:lgorithm(string)} specifies the algorithm to be used in estimation. There are three choices: Least angle regression;
Lasso and; Forward Stagewise. The connection between these is discussed in the Efron paper.

{phang}
{opt e:ps(#)} is the small number taken as the "machine zero", the default is 0.000001.

{phang}
{opt t:ype(string)} specified that coefficients are produced from a single realisation of the algorithm. The default string must be
"coefficients". The original code also produced fitted values, this will be implemented in the future.

{phang}
{opt m:ode(string)} specifies the mode of the prediction, the default is step.

{phang}
{opt s(#)} specifies the value at which the prediction is made, the default is 4.1 that means .1 between steps 4
and 5.

{phang}
{opt g:raph} specifies whether a graph of the entire model sequence is plotted. The default graph and only one implemented at this 
moment contains the coefficients on the y-axis and steps on the x-axis.

{phang}
{opt gopt(string)} specifies options to be included in the automatic graph.

{phang}
{opt nooutput}  do not display any output. The estimation still occurs and the usual output is placed in the saved results.

{title:Examples}

{pstd}
The command can be demonstrated by clicking the text below

{pstd}
{stata sysuse auto,replace} <---- click to load up dataset *the old dataset is lost*!

{pstd}
Use {hi:lars} to find the least angle regression solution. The coefficients are displayed for
the model with the lowest Cp statistic.{p_end}

{phang}
{stata lars price weight length mpg turn rep78 headroom trunk displacement gear_ratio foreign}

{pstd}
Now the Lasso estimation, in this case gives the same answer as least angle regression but using the
{hi:g()} option plots the model sequqnce. {p_end}

{phang}
{stata lars price weight length mpg turn rep78 headroom trunk displacement gear_ratio foreign, a(lasso) g}

{pstd}
Again forward stagewise gives the same solution so this example demonstrates the use of extra options for the graph. {p_end}

{phang}
{stata lars price weight length mpg turn rep78 headroom trunk displacement gear_ratio foreign, a(stagewise) g gopt(title(stagewise))}


{title:Saved Results}

    {bf:r(RSS)}  {col 17}the residual sums of squares for each step 
    {bf:r(R2)}   {col 17}the r-squared values
    {bf:r(newbetas)} {col 17}the coefficients from the prediction part
    {bf:r(cp)} {col 17}the Cp statistic for each step
    {bf:r(normx)} {col 17}the sum of squares for the covariates, i.e. the normalising constants.
    {bf:r(beta)} {col 17}the beta coefficients for each step
    {bf:r(sbeta)} {col 17}the beta coefficients multiplied by the normx matrix

{title:Author}

{pstd} 
Adrian Mander, MRC Biostatistics Unit, Cambridge, UK.  

{pstd} 
Email {browse   "mailto:adrian.mander@mrc-bsu.cam.ac.uk":adrian.mander@mrc-bsu.cam.ac.uk} 


{title:See Also} 

{pstd}
Related commands:
{pstd}
{help sw}
