{smcl}
{.-}
help for {cmd:gpreg} {right:(Johannes F. Schmieder)}
{.-}
 
{title:Title}

gpreg - Estimates regressions with two dimensional fixed effects.

{title:Syntax}

{p 8 15}
{cmd:gpreg} {it:varlist} [{help if}] [{help in}] , {cmdab:i:var(}{it:varname}{cmd:)} {cmdab:j:var(}{it:varname}{cmd:)}
	{break}
  [ {cmd:ife(}{it:new varname}{cmd:)} {cmd:jfe(}{it:varname}{cmd:)}
  {cmd:maxiter}{cmd:(}{it:integer}{cmd:)}
  {break}
	{cmdab:t:olerance}{cmd:(}{it:float}{cmd:)}
  {cmd:nodots} {cmdab:A:lgorithm}{cmd:(}{it:integer}{cmd:)}
  ]

{p}

{title:Description}

{p} Estimation of regressions with two dimensions of fixed effects, e.g. worker 
and firm fixed effects, student and teacher, or patient and doctor fixed 
effects. This program uses the Guimaraes & Portugal algorithm which has the 
advantage of being very memory efficient. It also calculates the correct 
standard errors under the assumption that the error term is homoskedastic 
and independently distributed. The indicators for the fixed effects dimensions 
are given as {cmdab:i:var(}{it:varname}{cmd:)} and {cmdab:j:var(}{it:varname}{cmd:)}. 

{title:Options}

{p 0 4} {cmd:ife(}{it:new varname}{cmd:)} {cmd:jfe(}{it:varname}{cmd:)}:
Specify two new variable names to generate the fixed effects associated with 
I and J variables.

{p 0 4}{cmd:nodots}:
Suppress dots indicating the progress of the iteration algorithm.

{p 0 4}{cmdab:A:lgorithm}{cmd:(}{it:integer}{cmd:)}:
Where {it:integer} is either 1, 2, 3 or 4. Choose between different implemenations of the algorithm:

{p 4 4} 1: The default. Mata implemenation, transforming all variables simultaneously.

{p 4 4} 2: Mata implementation. Transforming variables one by one. Slower but needs less memory.

{p 4 4} 3: Stata implementation. Similar to 2 but implemented in Stata, generally faster than 2.

{p 4 4} 4: Stata implementation. Similar to 2 but includes an algorithm to speed up convergence provided by Paulo Guimaraes.

{p 0 4}{cmdab:t:olerance}{cmd:(}{it:float}{cmd:)}
Specify the convergence criterion for the iteration method.

{p 0 4}{cmd:maxiter}{cmd:(}{it:integer}{cmd:)}
Specify a maximum number of iterations for the iteration method.

{title:Examples}

{p 8 16}{inp:. sysuse nlsw88}{p_end}

{p 8 16}{inp:. gpreg wage union, ivar(grade) jvar(industry)  }{p_end}

{p 8 16}{inp:. gpreg wage union, ivar(grade) jvar(industry) maxiter(500) dots minmem a(2) }
{p_end}

{title:Author}

{p}
Johannes F. Schmieder, Columbia University, USA

{p}
Email: {browse "mailto:johannesschmieder@gmail.com":johannesschmieder@gmail.com}

Comments welcome!

{title:Acknowledgements}

{p}

The algorithm is based on the paper by Paulo Guimaraes and Pedro Portugal (see reference below). 
The program makes use of Amine Quazad's {help a2group} algorithm to compute the connected groups.
Paulo Guimaraes made many helpful suggestions during development and assisted in testing the program. 
Remaining errors are my own (however: use this program at your own risk).

{title:Reference}

If you use this program in your research please cite this program and the paper 
Paulo Guimaraes, Pedro Portugal. "A Simple Feasible Alternative Procedure to Estimate Models with High-Dimensional Fixed Effects",
IZA DP No. 3935, 2009.

{title:Also see}

{p 0 21}
{help a2reg} (if installed), {help a2group} (if installed), {help felsdvreg} (if installed). 
{p_end}
