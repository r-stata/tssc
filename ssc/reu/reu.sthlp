{smcl}
{* *! version 1.0.0  5oct18}{...}
{cmd:help reu} 
{hline}

{title:Title}

{p2colset 5 15 18 2}{...}
{p2col :{hi: reu} {hline 1}} random error unit (REU) in epidemiological studies{p_end}
{p2colreset}{...}

{title:Syntax}


{p 8 17 2}
{cmd:reu}
{it:varlist}
[ {cmd:,} {opt se(value)}  ] 

{title:Description}

{pstd}
{opt reu} is a post-estimation command that displays the number of random error units (REU) for 
continuous and binary predictors of the previously fitted model 
({help regress}, {help glm}, {help logit}, {help logistic}, {help binreg}, {help poisson}, {help stcox}, {help streg}).

{title:Options}

{dlgtab:Options}

{phang}
{opt se(value)} specifies the standard error of the gold-standard study. 

{title:Example}

{phang2}{stata "use http://www.stats4life.se/data/whitehall1s, clear"}{p_end}

{phang2}{bf:// Step 1. Fit the model}

{phang2}{stata "logit all10 smoke sysbp age"}{p_end}

{phang2}{bf:// Step 2. Display Random Error Unit}

{phang2}{stata "reu smoke sysbp"}{p_end}

{title:Reference}

{p 4 4}Eur J Epidemiol. 2011 Dec;26(12):899-902. doi: 10.1007/s10654-011-9605-2. Epub 2011 Jul 30.
A novel approach to quantify random error explicitly in epidemiological studies.
Janszky I, Bjørngaard JH, Romundstad P, Vatten L.{p_end}

{title:Authors}

{p 4 12}{browse "mailto:imre.janszky@ntnu.no?subject=info reu":imre.janszky@ntnu.no}, NTNU{p_end}
{p 4 12}{browse "mailto:nicola.orsini@ki.se?subject=info reu":nicola.orsini@ki.se}, Karolinska Institutet{p_end}
