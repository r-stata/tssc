{smcl}
{* *! version 2  DEC2013}{...}
{cmd:help pisadeco} {right:also see:  {help pisastats} {help pisareg} {help pisacmd} {help pisaqreg} {help pisaoaxaca} {help pv}}
{hline}

{title:Title}

{p2colset 5 19 20 2}{...}
{p2col :{hi: pisadeco} {hline 2}} Convenience command to run decomposition analysis with PISA data {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{cmd:pisadeco}
	{depvar} [{indepvars}] {ifin}
   [{cmd:,} {it:options}]
   
{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main options}

{synopt :{opt group(numeric)}} Specifies groups to compare. It has to be 0/1 dummy variable. {p_end}

{synopt :{opt cnt(string)}}  Specifies a list of countries for which results will be calculated.
If OECD is specified, then results are provided for all OECD countries participating in this cycle. 
Similarly, specifying PARTNERS will produce results for all partner countries and economies participating in this cycle.
Specifying PISA will produce similar results for all countries participating in this cycle. 
If ALL is specified, then results are provided for all countries currently in your dataset. 
Results can be provided for distinct groups of countries by specifying a list with three letter ISO codes. 
For example, option cnt("AUS DEU POL") will produce results for Australia, Germany and Poland. 
The OECD average is calculated only when OECD or PISA is specified.
Otherwise simple average is calculated.
If you don't specify this option, the results will be produced for all values of the variable cnt. {p_end}

{synopt :{help prefix_saving_option:{bf:{ul:save}(}{it:filename}{bf:, ...)}}}save
	results to {it:filename}. You have to specify this option {p_end}
	
{syntab: Optional}

{synopt :{opt over(var)}} Specifies a categorical variable for which you want to obtain statistics by each category. 
The variable must be numerical with a sequence of integers denoting each category. {p_end}

{synopt :{opt round(int)}} Specifies how many decimal places you want to see in results tables. Default is 2. {p_end}

{synopt :{opt cycle(int)}} Specifies which PISA cycle you analyze.
This affects the list of countries recognized as OECD, PISA or PARTNERS in option cnt() 
as well as which names of plausible values will be recognized when given as dependent variable. 
Default is 2012. {p_end}

{synopt :{opt fast}} Specifying this option dramatically speeds up calculations but only point estimates will be reported. {p_end}

{synopt :{opt weight(string)}} This option allows you to specify survey and BRR weights that are different from original PISA weights.
weight() specifies a prefix for the main weight and 80 replicate weights.
The main weight has to end with 0 while replicate weights have to end with numbers from 1 to 80. {p_end}

{synoptline}


{title:Description}

{pstd}
You can use {cmd:pisadeco} to run several user-written decomposition commands with PISA data. 
You can specify cmd("oaxaca") to run Blinder-Oaxaca decomposition command written by Ben Jann (type -ssc install oaxaca- to install it).
You can also specify cmd("counterfactual"), cmd("cdeco") or cmd("cdeco_jmp") 
to run commands written by Victor Chernozhukov, Ivan Fernandez-Val and Blaise Melly (2008, Inference on cdeco Distributions.
MIT Department of Economics Working Paper No. 08-16). You can install these commands by typing:
net install counterfactual, from("http://www.econ.brown.edu/fac/Blaise_Melly/").
You also need to install moremata package to use these commands. Type -ssc install moremata-.

{pstd}
First variable listed after {cmd:pisadeco} is the dependent variable.
You can use any plausible value as the dependent variable but just specify last letters after pv*.
Thus, for pv*read just type read.
For any dataset you can type read, math, scie in which case the decomposition will be run 5 times on plausible values in reading, mathematics or science, respectively.
For any dataset you can also use proflevel which will run decomposition 5 times on dummy indicator (or any other variable) that is based on any plausible value.
You can also use any plausible value existing in PISA dataset.
For PISA 2000 you can type: math, scie, read, read1, read2, read3, math1, math2, proflevel.
For PISA 2003 you can type: math, scie, read, math1, math2, math3, math4, prob, proflevel.
For PISA 2006 you can type: math, scie, read, intr, supp, eps, isi, use, proflevel.
For PISA 2009 you can type: math, scie, read, era, read1, read2, read3, read4, read5, proflevel.
For PISA 2012 you can type: math, scie, read, macc, macq, macs, macu, mape, mapf, mapi, proflevel.
The final result will be calculated as a mean of these five decompositions.
You can also specify other variables as dependent variables.
In this case the command will perform a standard decomposition with one dependent variable.
Standard errors are obtained by the BRR method unless fast option is specified.
With fast option standard errors are not reported but point estimates are correct.
The command uses survey information provided in the original publicly available PISA datasets.
You need to keep variables like cnt or w_fstuwt and w_fstr* unless you specify your own weight prefix.

{title:Examples}

{pstd}

{phang2}{cmd:. pisadeco scie intscie, cmd("cdeco") group(gender) cnt(POL) save(example1) round(3)} {p_end}

{phang2}{cmd:. pisadeco read escs gender, cmd("oaxaca") group(wave) cnt(AUS) save(example2) } {p_end}

{phang2}{cmd:. pisadeco scieeff escs, cmd("counterfactual") group(gender) cnt(AUS POL GBR) save(example3) round(6)}  {p_end}
