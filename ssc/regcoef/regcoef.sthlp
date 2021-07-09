{smcl}
{* *! version 1.0 10Dec2014}
{cmd:help regcoef}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :{hi:regcoef }{hline 1}}coefficients for quantifying relative importance of predictors{p_end}
{p2colreset}{...}


{title:Description}

regcoef computes the following five different coefficients first three of which are commonly
used to determine the relative importance of predictors of a regression model. The last two
coefficients are comparably less familiar. The formula for the computation of these coefficients
as well as related references are provided below. 


1) Unstandardised regression coefficient (b) 

   
2) Fully standardised regression coefficient (beta)


3) Squared semipartial correlation (sr2)


4) Level importance coefficient (lc)      
   
   lc = b*X-bar                             (see Achen, pp. 71-73)
   
   
5) Structure coefficient (sc)
   
   sc = corr(predictor,outcome)/R           (see Meyers et al., 2006, p. 163) 

   
   
KW: predictor
KW: regression
KW: relative importance


{title:Example}
 
{phang}{stata "sysuse auto, clear": . sysuse auto, clear}{p_end}
{phang}{stata "reg price mpg headroom trunk turn foreign ": . reg price mpg headroom trunk turn foreign}{p_end}
{phang}{stata "regcoef": . regcoef}{p_end} 

{phang}{stata "webuse reading, clear": . webuse reading, clear}{p_end}
{phang}{stata "reg score i.class i.skill ": . reg score i.class i.skill}{p_end}
{phang}{stata "regcoef": . regcoef}{p_end}  

{title:Author}
Mehmet Mehmetoglu
Department of Psychology
Norwegian University of Science and Technology
mehmetm@svt.ntnu.no


{title:References}
Achen, C. H. (1982). Interpreting and Using Regression. London: Sage.
Meyers, L. S., Gamst, G., & Guarino, A. J. (2006). Applied Multivariate Research - Design and Interpretation. London: Sage.



  