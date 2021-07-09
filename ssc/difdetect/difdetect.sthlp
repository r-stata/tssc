{smcl}
{hline}
help for {cmd:difdetect} {right:April 30, 2015)}
{hline}

{title:Description}

{p 0 4 2}
{cmd:Detection of and adjustment for differential item functioning (DIF):}{break} 
Identifies differential item functioning, creates dummy/virtual items to be used to adjust ability (trait) estimates, 
and calculates the ability estimates and standard errors.


{p 4 12 2}
{cmd:difdetect } {it: varlist} {cmd:,} 
{cmdab:RUnname}{cmd:}{it:(str)}{cmd:} 
{cmd:ABility}{it:(var)} {cmd:GRoup}{it:(var)}
[{cmdab:NUL}{cmd:}{it:(#)}{cmd:}		{cmdab:NUW}{cmd:}{it:(#)}{cmd:} 		
{cmdab:NUPValue}{cmd:}{it:(#)}{cmd:}	{cmdab:UBeta}{cmd:}{it:(#)}{cmd:}		
{cmdab:UBCH}{cmd:}{it:(#)}{cmd:}		{cmdab:UL}{cmd:}{it:(#)}{cmd:}  		
{cmdab:ULPValue}{cmd:}{it:(#)}{cmd:}	{cmd:MULtinomial}{it:(var)}			
{cmdab:minsize}{cmd:}{it:(#)}{cmd:}		{cmd:CYcles}{it:(#)}{hi:} 	{cmd:NQpt}{it:(#)}{hi:} 

{p 4 12 2}
where:

{p 8 12 2}
{it:varlist} is the list of variables (items, blocks) to be tested for DIF

{p 8 12 2}
{it:runname} is the name used in the resulting variables and files (see {cmd:Remarks}). 

{p 8 12 2}
{it:ability} is an ability or trait variable.

{p 8 12 2}
{it:group} is a {it:binary} grouping variable.

{title:Options}

{p 8 12 2}
{cmdab:multinomial} is a multinomial grouping variable.

{p 8 12 2}
{cmdab:nul} indicates whether the log-likelihood test will be used as a criterion for non-uniform DIF.  Default is yes (1).  Nul(0) will omit this criterion.

{p 8 12 2}
{cmdab:nupvalue} is the p-value for testing non-uniform DIF.  Default is 0.05.

{p 8 12 2}
{cmdab:ubeta} indicates whether the change in the ability coefficient will be used as a criterion for uniform DIF.  Default is no (0).  UB(1) will include this criterion

{p 8 12 2}
{cmdab:ubch} is percent change in the ability coefficient for determining uniform DIF.  Default is .10. A positive change indicates an increase in the relationship between ability and the outcome with a higher value of the grouping variable.

{p 8 12 2}
{cmdab:ul} indicates whether the log-likelihood test will be used as a criterion for uniform DIF.  Default is yes (1).  UL(0) will omit this criterion.

{p 8 12 2}
{cmdab:ulpvalue} is the p-value for testing uniform DIF with the log-likelhood method.  Default is 0.05.

{p 8 12 2}
{cmdab:minsize} is the minimum number of observations/category (default is 20)

{p 8 12 2}
{cmd:nqpt} - changes the number of quadrature points from a default of 20.

{p 8 12 2}
{cmd:cycles} - changes the maximun number of iterations in the ability estimation.



{title:Remarks}

{p 8 12 2}
Sends DIF results to DIFd{it:runname}.log.  

{p 8 12 2}
Generates an output data set, DIFdetect_{it:runname}.dta, which includes individual model results, with Brant test p-values for ordinal items and Hosmer-Lemeshow p-values for binary items.  [The relevance of the fit statistics has not been established for DIF.]

{p 8 12 2}
Creates two variables, theta_{it:runname}, the revised ability estimate that accounts for DIF, and its standard error, se_{it:runname}

{p 8 12 2}
Creates dummy/virtual items to be used to adjust ability scores for DIF.  These items will be of the form {it:item}group{it:x}, where {it:x} = 1 represents the lower value of {it:group}, and {it:x} = 2 the higher.
For example, if item {it:item1} had DIF by {it:ethnic}, the virtual items will be {it:item1ethnic1} and {it:item1ethnic2}.  

{p 8 12 2}
Displays warning messages when models do not converge, collinearity problems are observed, models are completely determined, standard errors are large, Brant tests are not possible, or items have > 15 levels (PARSCALE will reject).

{p 8 12 2}
Collapses categories on variables for which the number of observations is below a specified threshold (default is minszie(20)).  If you do not want any categories combined, specify minsize(1). 

{p 8 12 2}
Drops any variable that does not have enough observations for at least 2 categories, and displays a warning message.

{p 8 12 2}
Allows missing values.

{p 8 12 2}
Note that to fully account for DIF you should run the program again with theta_{it:runname} as the new ability score and a new {it:runname}.  Repeat until the same items are identified with DIF.

{p 8 12 2}
Please make sure that Stata's current working directory is the same as your data's directory (help cd).

{p 8 12 2}
If you will be adjusting for DIF on multiple categories (groups), subdividing can lead to dummy/virtual item names longer than the 32 character limit.  
Our tip is to generate a new grouping variable with a really short name.  For example, .gen g=gender

{p 12 12 2}
Otherwise you may get an error message about a variable already being defined or being too long, and end up having to rename long variables within Stata.

{p 8 12 2}
Written for Stata 13.0.  


{title:Examples}

{p 4 8 2}
difdetect item1-item13, ru(gender0) ab(theta0) gr(g) 

{p 4 8 2}
difdetect apple - item11, ru(ethnic0) ab(itemtot) gr(eth) nupv(0.01) ul(1) ulpv(.01) minsize(35) 


{title:Authors}

{p 4 4 2}
Laura Gibbons, Paul Crane, Lance Jolley, and Gerald van Belle.  {break}
University of Washington, Copyright 2014.{break}
Email: {browse mailto: gibbonsl@u.washington.edu}

{p 4 4 2}
We appreciate the assistance of Tom Koepsell and Rich Jones. 

