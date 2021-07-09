{smcl}

{title:Title}

speccheck - specification checker

{title:Requirements}

Speccheck requires tuples, available from ssc.

{title:Contact Information}

Please direct any questions for this software to ncook@uottawa.ca

{title:Syntax}

{cmdab:speccheck} depvar indepvars [if] [{cmd:,}{it:options}]


{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt vce}} standard errors, robust or clustered {p_end}
{synopt:{opt method}} reg, areg, xtreg. Defaults to reg {p_end}
{synopt:{opt absorb}} absorb variable. For use with areg {p_end}
{synopt:{opt xt}} fe,re or be. For use with xtreg. Defaults to re. {p_end}
{synopt:{opt nocon}} if Yes, only regressions with at least one control {p_end}
{synopt:{opt always}} may be blank, 1 or 2. Default to blank. If 1, the second independent variable will always be included in the regressions. If 2, the second and third. {p_end}
{synoptline}

{p2colreset}{...}
{p 4 6 2}
  {it:indepvars} may contain factor variables; see {help fvvarlist}.
  {p_end}


{title:Description}


{p}
{opt speccheck} generates a standardized graphical output from a regression specification. The command will individually regress depvar against all possible indepvars combinations. The command will generate a figure with four subfigures. The effect curve is a histogram of the regression coefficients estimated for the first indepvar. The t-curve is a histogram of the absolute value of the t-statistics of the first indepvar.

{p}
	
{title: Examples}


Example: reg with if

	bcuse wagepan, clear

	speccheck lwage educ union married black exper expersq if south==1

Example: reg with robust standard errors

	bcuse wagepan, clear

	speccheck lwage educ union married black exper expersq , vce(robust)

Example: reg with clustered standard errors

	bcuse wagepan, clear

	speccheck lwage educ union married black exper expersq , vce(cluster nr)

Example: reg without the specification with no controls

	bcuse wagepan, clear

	speccheck lwage educ union married black exper expersq , nocon(Yes)

Example: areg

	bcuse wagepan, clear

	speccheck lwage educ union married black exper expersq , method(areg) absorb(nr) 

Example: xtreg

	bcuse wagepan, clear

	xtset nr year

	speccheck lwage educ union married black exper expersq , method(xtreg) xt(fe) 
