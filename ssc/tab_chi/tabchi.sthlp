{smcl}
{* 21jun2020}{...}
{hline}
help for {hi:tabchi}, {hi:tabchii}
{hline}

{title:Two-way tables of frequencies with chi-square and residuals}

{p 8 17 2}
{cmd:tabchi} 
{it:rowvar colvar} 
[{it:weight}] 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}]
[ 
{cmd:,}
{cmdab:r:aw} 
{cmdab:p:earson} 
{cmdab:c:ont}
{cmdab:a:djust} 
{cmd:noo}
{cmd:noe}
{it:tabdisp_options}
]

{p 8 17 2}
{cmd:tabchii} 
{it:#11 #12} [{it:...}] 
{cmd:\} 
{it:#21 #22} [{it:...}] 
[{cmd:\} {it:...}]
[{cmd:,}
{cmd:replace}
{cmdab:r:aw} 
{cmdab:p:earson} 
{cmdab:c:ont}
{cmdab:a:djust} 
{cmd:noo}
{cmd:noe}
{it:tabdisp_options}
]


{title:Description}

{p 4 4 2}{cmd:tabchi} displays information derived from the {it:r} x
{it:c} table of frequencies for categorical variables {it:rowvar} and
{it:colvar}. 

{p 4 4 2}The display contains 

{p 8 8 2}row and column identifiers, 
   
{p 8 8 2}(by default) observed frequencies and expected frequencies on a
null hypothesis of no association between the row and column variables, 
   
{p 4 4 2}and (if desired)

{p 8 8 2}raw residuals, observed - expected, 
    
{p 8 8 2}Pearson residuals, (observed - expected) / sqrt(expected),
    
{p 8 8 2}contributions to chi-square, (observed - expected)^2 / expected
    
{p 8 8 2}and adjusted residuals, Pearson residuals divided by an
estimate of their standard error.

{p 4 4 2}The Pearson and likelihood-ratio chi-square statistics and
their P-values are also given.

{p 4 4 2}{cmd:tabchii} displays the same information derived from the
{it:r} x {it:c} table using the counts or frequencies specified; rows
are separated by the backslash {cmd:\}.


{title:Discussion} 

{p 4 4 2}A chi-squared test for association of the row and column
variables in a two-way table of frequencies is featured in most first
courses in statistics. In Stata, this test is provided by the command
{help tabulate} or the immediate command {help tabi}.  When {cmd:tabchi}
and {cmd:tabchii} were first published, {cmd:tabulate} and {cmd:tabi}
did not support output of expected (fitted, predicted) frequencies, but
that has been added since. As of 2020, neither official command allows
output of residuals.  Most data analysts wish to glance at least briefly
at such results. 

{p 4 4 2}These commands supersede {help tab2i} (Cox 1996), but the
account there remains pertinent.  

{p 4 4 2}The residuals produced by these commands come in two flavours.
First, Pearson residuals (also called standardized or chi-residuals) are
the (appropriately signed) square roots of each cell's contribution to
the Pearson chi-squared statistic.  Under the null hypothesis, the
Pearson residuals approximately follow Gaussian (normal) distributions
with mean 0 and variance less than 1. Consequently, one rough rule of
thumb is to look especially carefully at any residual greater than 2 in
magnitude.  Second, adjusted residuals are Pearson residuals divided by
an estimate of their standard error so that they are distributed more
like Gaussians with mean 0 and variance 1. 

{p 4 4 2}There are several other possible definitions of residuals in
the literature. For more information on this or other points, see a
standard text on categorical data analysis. For example, Gilbert (1993)
and Agresti (2019) assume a modest background in statistics, whereas
Bishop, Fienberg, and Holland (1975) and Agresti (2013) are more
advanced. Haberman (1973) is a key paper introducing adjusted residuals.

{p 4 4 2}For more advanced work with two-way tables, you might use the
more general {help glm} command, which allows many models other than
that of independence to be fitted and tested. On the other hand,
people not familiar with these methods might
find these commands more accessible at an elementary level. 


{title:Options}

{p 4 8 2} {cmd:replace} indicates that the variables listed by the
{cmd:tabchii} command are to be left as the current data in place of
whatever data were there.

{p 4 8 2}{cmd:raw}, {cmd:pearson}, {cmd:cont} and {cmd:adjust} produce
displays of raw residuals, Pearson residuals, contributions to
chi-square and adjusted residuals respectively.

{p 4 8 2}{cmd:noo}, {cmd:noe} suppress display of observed and expected
frequencies.  These options may be useful when the focus is on
residuals. {cmd:noo} and {cmd:noe} without at least one of {cmd:raw},
{cmd:pearson}, {cmd:cont} and {cmd:adjust} suppress the tabular display.

{p 4 8 2}{it:tabdisp_options} are options of {help tabdisp} other than
{cmd:cellvar()}, which may be used to tune the tabular display.


{title:Examples}

{p 4 8 2}{cmd:. sysuse auto, clear}{p_end}
{p 4 8 2}{cmd:. tabchi foreign rep78, adj}{p_end}
{p 4 8 2}{cmd:. tabchi foreign rep78, adj noo noe}

{p 4 4 2}
Jacqueline Tivers (1985, p.173) interviewed 400 women with young
children in the London Borough of Merton in September 1977. In one
analysis, she looked at the cross-tabulation of the age at which women
finished full-time education (below 16, 16, 17-18, 19 or older) and
whether they used a library regularly. The table of frequencies did not
come with a chi-squared statistic or residuals. 

{p 4 8 2}{cmd:. tabchii 124 21 \ 73 30 \ 55 29 \ 27 41}{p_end}
{p 4 8 2}{cmd:. tabchii 124 21 \ 73 30 \ 55 29 \ 27 41, replace} 


{title:Saved results}

{p 4 4 2}{cmd:tabchi} and {cmd:tabchii} leave behind appropriate r-class
results produced by {help tabulate}.


{title:Author}

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
         n.j.cox@durham.ac.uk


{title:Acknowledgments}

{p 4 4 2}William Gould provided much help in the early development of
{cmd:tabchi}. Torbjorn Messner and Eric Zbinden pointed out bugs in
earlier versions of {cmd:tabchi}.  Martyn Sherriff reported a bug in
{cmd:tabchii}. 


{title:References} 

{p 4 8 2}Agresti, A. 2013. {it:Categorical Data Analysis.} Hoboken, NJ: John Wiley.

{p 4 8 2}Agresti, A. 2019. {it:An Introduction to Categorical Data Analysis.} Hoboken, NJ: John Wiley. 

{p 4 8 2}Bishop, Y.M.M., S.E. Fienberg, and P.W. Holland. 1975. {it:Discrete Multivariate Analysis.} Cambridge, MA: MIT Press.

{p 4 8 2}Cox, N.J. 1996. An immediate command for two-way tables. {it:Stata Technical Bulletin} 33: 7{c -}9. 

{p 4 8 2}Gilbert, N. 1993. {it:Analyzing Tabular Data: Loglinear and Logistic Models for Social Researchers.} London: UCL Press.

{p 4 8 2}Haberman, S.J. 1973. The analysis of residuals in cross-classified tables. {it:Biometrics} 29: 205{c -}220.

{p 4 8 2}Tivers, J. 1985. {it:Women Attached: The Daily Lives of Women with Young Children.} Beckenham, UK: Croom Helm. 


{title:Also see}

{p 4 13 2} Manual:  [U] 19 Immediate commands, [R] glm, [R] tabdisp, [R] tabulate{p_end}
{p 4 13 2}On-line:  help for {help immed}, {help tabdisp}, {help tabulate}, 
{help chitest} (if installed){p_end}

