{smcl}
{* 08NOV20124}{...}
{hline}
help for {hi:logitrank}
{hline}

{title:Compute the logitrank based on a scale position}

{p 4}Syntax

{p 8 14}{cmd:logitrank} {it:depvar} 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{it:weight}]
{cmd:, [}
{cmd:gen(}{it:string}{cmd:)} {cmd: ] }


{title:Description}

{p} {cmd:logitrank} computes the logit-rank based on the {it:depvar} variable (income or wealth values for instance). It is particularly useful for the {cmd:abg}  method.
The reference WP is stored here: 

{hline}

http://www.lisdatacenter.org/wps/liswps/609.pdf  

{hline}


{title:Options}


{p 0 4} {cmd:gen(}{it:new_var}{cmd:)} must be precised by the user.


{title:example}




{p} {cmd:use http://www.louischauvel.org/psid9707.dta , clear}

{p} {cmd:logitrank eq [fw= wgt] if ye==1997, gen(lr97)}

{p}


{title:References}

{p 0 4} Louis Chauvel, forthcoming, The Intensity and Shape of Inequality: The ABG Method of Distributional Analysis, Review of Income and Wealth. 

{p 0 4} see http://www.lisdatacenter.org/wps/liswps/609.pdf .

{title:Author}

Louis Chauvel PrDr
University of Luxembourg
During the completion of the v1.0
chauvel@louischauvel.org

