{smcl}
{* version 1.1.0}{...}
{cmd:help tfv}
{hline}

{title:Title}

{p 5}
{cmd:tfv} {hline 2} Transformations of variables


{title:Syntax}

{p 8}
{cmd:tfv} [{cmd:,} {it:options} {cmd::}] {it:{help tfv##cmd:command}}

{p 8}
{cmd:tfv} [{cmd:,} {it:options} {cmd::}] 
{it:{help tfv##tfterms:tfvterm}} 
[{it:{help tfv##tfvterms:tfvterm}} {it:...}]


{marker cmd}{...}
{p 5}
where {it:command} is a Stata command including 
{it:{help tfv##tfterms:tfvterms}}

{marker tfvterms}{...}
{p 5}
a {it:tfvterm} is one of

{col 12}{it:tfvterm}{col 32}corresponding generate command
{col 10}{hline 58}
{col 12}{cmd:t({it:fcn}).varname}{...}
{col 32}{cmd:generate {it:fcn}_{it:varname} = {it:fcn}({it:varname})}
{col 12}{cmd:t.({it:exp})}{...}
{col 32}{cmd:generate {it:exp} = {it:exp}}
{col 10}{hline 58}
{col 10}in new variable names all characters in {cmd:{it:fcn}} {...}
and {cmd:{it:exp}} not 
{col 10}allowed in names are changed to underscore


{col 10}{cmd:{it:fcn}} is typically the name of a {...}
{help math functions:math function} or
{col 12}{help string functions:string function} taking {...}
one argument and typed without 
{col 12}parentheses

{col 10}{cmd:{it:exp}} is an {it:{help exp:expression}} or {...}
{help functions:function} that typically contains 
{col 12}the name of the variable to be transformed


{title:Description}

{pstd}
{cmd:tfv} creates transformations of variables and executes a 
specified command with the transformed variables. If no command is 
specified {cmd:tfv} creates transformations of variables and adds 
them to the current dataset.

{pstd}
Variables previously created by {cmd:tfv} are replaced if specified 
repeatedly, but see option {help tfv##protect:noreplace}.

{pstd}
Any {it:command} not containing {it:tfvterms} and specified without a 
{it:{help prefix}}, {varlist}, {helpb if} and {helpb in} qualifiers 
{it:{help weights}} and {it:{help options}} (e.g. {help describe}) 
applies to all variables previously created by {cmd:tfv}.


{title:Options}

{phang}
{opt g:enerate(namelist)} specifies variable names for the 
corresponding {it:tfvterms}. Default names are used for additional 
{it:tvfterms}, while additional {it:names} are ignored.

{phang}
{opt stub(stub)} creates new variables {cmd:{it:stub}1}, 
{cmd:{it:stub}2}, {it:...}, {cmd:{it:stub}k}.

{marker protect}{...}
{phang}
{opt nor:eplace} does not replace variables perviously created by 
{cmd:tfv}.

{phang}
{cmd:{ul:t}ype(}{it:{help data types:type}}{cmd:)} specifies storage 
type for created variables. 

{phang}
{opt drop} {help drop}s all variables previously created by {cmd:tfv}.


{title:tfv and factor variable notation}

{pstd}
{cmd:tfv} may be used together with Stata's 
{help fvvarlist:factor variable notation}. Factor variable operators 
are specified before the {cmd:t.} operator.


{title:Examples}

{phang2}{cmd:. sysuse auto}{p_end}

{phang2}{cmd:. tfv summarize price t(ln).price}{p_end}
{phang2}{cmd:. tfv ,generate(lnprice) : summarize price t(ln).price}{p_end}
{phang2}{cmd:. tfv tabulate t(strlower).make in 1/10}{p_end}

{phang2}{cmd:. tfv regress t(ln).price c.t.(mpg/100)##c.t.(mpg/100)}{p_end}
{phang2}{cmd:. tfv regress t(ln).price c.t.(mpg/100)##c.mpg_100}{p_end}

{phang2}{cmd:. tfv summarize i.t.(rep78 > 3 if !mi(rep78))}{p_end}

{phang2}{cmd:. tfv describe}{p_end}


{title:Saved results}

{pstd}
{cmd:tfv} saves the following in {cmd:s()}:

{synoptset 21 tabbed}{...}
{synopt:{cmd:s(tfvvarlist)}}variables created by the last {cmd:tfv} call{p_end}


{pstd}
{cmd:tfv} also saves the following characteristics
{p_end}

{synoptset 21 tabbed}{...}
{synopt:{cmd:_dta[_tfv_varlist]}}variables created by {cmd:tfv}{p_end}
{synopt:{cmd:{it:varname}[_istfv]}}{cmd:true} if {it:varname} has been 
created by {cmd:tfv}{p_end}


{title:Acknowledgments}

{pstd}
{cmd:tfv} is inspired by a discussion on 
{browse "http://www.stata.com/statalist/archive/2014-02/msg00697.html":Statalist} 
as well as official Stata's {help fvvarlist:factor variables} 
and their predecessor {help xi}.


{title:Author}

{pstd}Daniel Klein, University of Kassel, klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help fvvarlist}, {help xi}
{p_end}
