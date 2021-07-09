{smcl}
{* *! version 2.1.2  5August2019}{...}
{viewerjumpto "Syntax" "nscale##syntax"}{...}
{viewerjumpto "Description" "nscale##description"}{...}
{viewerjumpto "Examples" "nscale##examples"}{...}

{title:Title}

{phang}{bf:nscale} {hline 2} Program to recode variables to lie between 0 and 1


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
	{cmd:nscale} {varlist}
	[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt gen:erate(namelist)}}create {it:namelist} so that transformed values of the {it:n}th variable of {it:varlist} are stored in the {it:n}th variable of the {it:namelist}{p_end}
{synopt:{opt pre:fix(name)}}create new variables with prefix {it:name}{p_end}
{synopt:{opt nopost:fix}}replace existing variables{p_end}
{synopt:{opt m:issing(#)}}set observations to missing (.) if their value is equal to {it:#}; can be combined with {opt up} or {opt down}{p_end}
{synopt:{opt up}}set observations to missing (.) if their value is greater than or equal to the number assigned by {opth missing(#)}{p_end}
{synopt:{opt down}}set observations to missing (.) if their value is less than or equal to the number assigned by {opth missing(#)}{p_end}
{synopt:{opt r:everse}}reverse variable coding{p_end}
{synopt:{opt t:ab}}tabulate new variables{p_end}
{synoptline}
{p2colreset}{...}

{p 4 6 2}
If neither {opth generate(varlist)}, {opth prefix(name)} nor {opt nopostfix} is set, {cmd:nscale} creates new variables with postfix {it:_01}.{p_end}
{p 4 6 2}
{opt nopostfix} may not be combined with {opth generate(varlist)} or {opth prefix(name)}.{p_end}
{p 4 6 2}
{opth generate(varlist)} may not be combined with {opth prefix(name)}.{p_end}
{p 4 6 2}
{opt up} may not be combined with {opt down}.{p_end}


{marker description}{...}
{title:Description}

{pstd}
	{cmd:nscale} provides a convenient way to {cmd:recode} variables in {varlist}
	to lie between 0 and 1 via dividing {it:var}-{opt min(var)} by {opt max(var)}-{opt min(var)}.
	{cmd:nscale} can {cmd:recode} many variables at once and has options {opth generate(namelist)} and {opth prefix(name)}
	which work in the similar manner as Stata’s default command {cmd:recode} does.
	It is also possible to store transformed values in existing variables with option {opt nopostfix}.

{pstd}
	{cmd:nscale} can set specific value or interval to missing (.) as well. For example,
	if a survey question q1 coded {it:DK} as {it:98} and {it:miscellaneous} as {it:99}
	and you want to exclude those values from analysis, just type: {cmd:nscale q1} , {opt m(98)} {opt up}.
	Then {cmd:nscale} sets all observations whose value is greater than or equal to {it:98} to missing (.).
	The option {opt down} combined with option {opth missing(#)} works similarly.

{pstd}
	Moreover, {cmd:nscale} does reverse coding with option {opt reverse} and tabulates new variables with option {opt tab}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. nscale var}{p_end}

{phang}{cmd:. nscale var1 var2 , gen(nv1 nv2)}{p_end}

{phang}{cmd:. nscale {varlist} , pre(new_)}{p_end}

{phang}{cmd:. nscale {varlist} , m(9)}{p_end}

{phang}{cmd:. nscale {varlist} , r t}{p_end}

{phang}{cmd:. nscale {varlist} , nopost}{p_end}
