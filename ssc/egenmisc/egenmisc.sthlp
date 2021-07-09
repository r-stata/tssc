{smcl}
{* *! version 1.2.14  02feb2013}{...}
{viewerdialog egenmisc "dialog misc"}{...}
{vieweralsosee "[D] egen" "help egen"}{...}
{vieweralsosee "[D] egenmore" "help egenmore"}{...}
{viewerjumpto "Syntax" "misc##syntax"}{...}
{viewerjumpto "References" "misc##references"}{...}
{viewerjumpto "Contact" "misc##contact"}{...}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{manlink D egenmisc} {hline 2}} Misc egen functions.
{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:egen} {dtype} {newvar} {cmd:=} {it:fcn}({it:arguments})   {ifin}
[{cmd:,} {it:options}]

{phang}
where depending on the {it:fcn}, {it:arguments} refers to an expression,
{it:varlist}, or {it:numlist}, and the {it:options} are also {it:fcn}
dependent.


{phang2}
{opth fastwpctile(varname)} [{cmd:,} {cmdab:p:ercentiles(}{it:numlist}{cmd:)} {cmdab:w:eights(}{it:varname}{cmd:)} {cmdab:alt:def} {cmd:by(}{it:byvarlist}{cmd:)}]
{p_end}
{pmore2}
like {help egenmore##:pctile} but faster.

{phang2}
{opth fastxtile(varname)}[{cmd:,} {cmdab:p:ercentiles(}{it:numlist}{cmd:)} {cmdab:n:quantiles(}{it:#}{cmd:)} {cmdab:w:eights(}{it:varname}{cmd:)} {cmdab:alt:def} {cmd:by(}{it:byvarlist}{cmd:)}] {p_end}
{pmore2}
like {help egenmore##:xtile} but faster.


{phang2}
{opth nacorr(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample correlation of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth nacov(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample covariance of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth namean(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample mean of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth nasd(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample standard deviation of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth nasum(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sum of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{opth navar(varlist)} [{cmd:,} {opt by}{cmd:(}{it:byvarlist}{cmd:)} {opt min}{cmd:(}{it:num}{cmd:)}]{p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the sample variance of {it:varlist}. 
The option min sets the new variable to "." when there are less than {it:num} observations such that both variables in {it:varlist} are non missing.

{phang2}
{cmd: pick(expr)} {cmd:,} {opt when}{cmd:(}{it:condition}{cmd:)} {cmd:by(}{it:byvarlist}{cmd:)} {p_end}
{pmore2}
creates a constant (within {it:byvarlist}) containing the value of expr for the row satisfying  {it:condition}. 


{marker references}{...}
{title:References}
The function {cmd:fastxtile} and {cmd:fastpctile} borrow heavily from equivalent commands in {cmd:egenmore}.


{marker contact}{...}
{title:Author}

{phang}
Matthieu Gomez

{phang}
Department of Economics, Princeton University

{phang}
Please report issues on Github
{browse "https://github.com/matthieugomez/stata-egenmisc":https://github.com/matthieugomez/stata-egenmisc}
{p_end}

