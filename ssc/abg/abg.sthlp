{smcl}
{* 08NOV20124}{...}
{hline}
help for {hi:abg}
{hline}

{title:The Alpha-Beta-Gamma Method of Distributional Analysis: Intensity and Shape of Inequality}

{p 4}Syntax

{p 8 14}{cmd:abg} {it:depvar} [{it:indepvars}]
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{it:weight}]
{cmd:, [}
{cmd:gen(}{it:string}{cmd:)} {cmd: ] }


{title:Description}

{p} {cmd:abg} estimates Alpha-Beta-Gamma  coefficients and standard-errors  
of Distributional Analysis (see these coefficients with {cmd:return list} ) 
of a  {it:depvar} variable (income or wealth values for instance). 
The reference WP is stored here: 

{hline}

http://www.lisdatacenter.org/wps/liswps/609.pdf  

{hline}

The command {cmd:abg} proposes the computation of the empirical ISO values 
for the 19 vingtiles of the distribution stored in 19 scalars, and the estimated values
stored in 19 ISA scalars.
In a generated variable, it stores the ISO values for each individual. 

{cmd:abg} comes along with a {cmd:logitrank} command that computes for each individual her logit-rank position.  



{title:Options}


{p 0 4} {cmd:gen(}{it:new_var}{cmd:)} must be precised by the user.


{title:example}




{p} {cmd:use http://www.louischauvel.org/psid9707.dta , clear}

{p} {cmd:logitrank eq [fw= wgt] if ye==1997, gen(lr97)}

{p} {cmd:abg eq [fw= wgt] if ye==1997, gen(iso97)}

{p} {cmd:return list}

{p} {cmd:logitrank eq [fw= wgt] if ye==2007, gen(lr07)}

{p} {cmd:abg eq [fw= wgt] if ye==2007, gen(iso07)}

{p} {cmd:return list}

{p} {cmd:sort lr97}

{p} {cmd:two (sca iso07 lr07 if abs(lr07)<5 ) (li iso97 lr97 if abs(lr97)<5 ) , legend(off)}


{p}


{title:References}

{p 0 4} Louis Chauvel, forthcoming, The Intensity and Shape of Inequality: The ABG Method of Distributional Analysis, Review of Income and Wealth. 

{p 0 4} see http://www.lisdatacenter.org/wps/liswps/609.pdf .

{title:Author}

Louis Chauvel PrDr
University of Luxembourg
During the completion of the v1.0
chauvel@louischauvel.org

