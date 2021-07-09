{smcl}
{* *! version 1.1 05apr2017}{...}
{title:Title}

{pstd}strkeep {hline 2} Clean string variables by keeping only whitelisted ASCII characters{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:strkeep}
{varlist}
{ifin} {cmd:,} {it:{help strkeep##options:options}}

{marker options}{...}
{synoptset 25 tabbed}{...}
{synopthdr:strkeep options}
{synoptline}
{marker optgen}
{syntab:Generate Options (must specify exactly one)}
{synopt:{opt gen:erate(varname|stub)}}generate and store results in {it:varname} or in {it:stub1}, {it:stub2}, etc.{p_end}
{synopt:{opt replace}}replace {it:varlist} with cleaned results{p_end}

{marker optwhite}
{syntab:Whitelist Options (must specify at least one)}
{synopt:{opt a:lpha}}keep all letters of the alphabet, both lowercase and uppercase{p_end}
{synopt:{opt lower:case}}keep lowercase letters of the alphabet{p_end}
{synopt:{opt upper:case}}keep uppercase letters of the alphabet{p_end}
{synopt:{opt n:umeric}}keep Arabic numerals{p_end}
{synopt:{opt keep(string)}}keep characters in {it:string}, which is interpreted as individual characters{p_end}

{marker optstrlu}
{syntab:strlower()/strupper() Options (optional)}
{synopt:{opt strl:ower}}results returned in lowercase format{p_end}
{synopt:{opt stru:pper}}results returned in uppercase format{p_end}

{marker optsub}
{syntab:Substitution Option (optional)}
{synopt:{opt s:ub(string)}}replace any deleted character with {it:string}, which must be 1 character in length; 
any character used in sub() will be automatically added to the whitelist{p_end}
{synoptline}

{marker description}{...}
{title:Description}

{pstd}
{opt strkeep} cleans a string variable or varlist by keeping only certain ASCII characters. 
In essence, this command is a "whitelist" command, while a function like 
{opt subinstr()} is a "blacklist" command.  Instead of finding characters that you want
to remove, {opt strkeep} finds characters that you want to keep and removes all other characters.

{pstd}
When using {opt strkeep}, you must specify one and only one of the 
{help strkeep##optgen:generate options} and at least one of the 
{help strkeep##optwhite:whitelist options}. The {help strkeep##optsub:substitution option}
is optional.

{pstd}
At least one whitelist option must be specified, but more than one can be specified at a time.
If multiple whitelist options are specified, then all of the corresponding characters are 
whitelisted and are kept in the strings. Users can define specific characters to be kept by 
using the {opt keep()} option.  N.B., {opt keep("a b")} will keep the characters "a",
"b", and " ", as a single space is a character.

{pstd}
The strlower/strupper options will perform the corresponding functions on the final 
results of {opt strkeep}. The options are mutually exclusive and are performed at the 
end of the function. If the option {opt uppercase} is specified along with {opt strlower}, then only 
uppercase letters will be kept, but the result will show those uppercase letters 
converted to lowercase letters. For example, in "ABcdEFG", "ABEFG" will be kept, 
but the resulting string will be "abefg" as {opt strkeep} will then perform {opt strlower()}
on the results.

{pstd}
The substitution option is completely optional, and of limited use.  If {opt sub()} is not specified, 
{opt strkeep} simply deletes any character that is not whitelisted. {opt sub()} can
only accept one single character and will reject strings with multiple characters.
Keep in mind that any character used as the substitution character will be added to
the whitelist.

{pstd}
If a varlist is passed to {opt strkeep} and {opt generate(stub)} is specified, the command
will create multiple new variables. Specifically, the command will create new variables
named {it:stub1}, {it:stub2}, etc., corresponding to the number and order of the variables
in the varlist. {it:stub} has a character limit below 32 characters (the variable name
limit in Stata) and dependent on the total number of variables in varlist. 
If 100 variables are passed in varlist, then {it:stub} can only be 29 characters long, to
allow for {it:stub100} as a variable name.

{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto.dta}{p_end}

{pstd}Clean the string variable {it:make} to keep only lowercase and uppercase letters,
and generate a new variable{p_end}
{phang2}{cmd:. strkeep make, generate(make_alpha) alpha}{p_end}
{pstd}The above is identical to the below{p_end}
{phang2}{cmd:. strkeep make, generate(make_alpha) lowercase uppercase}{p_end}
{pstd}The above is identical to the below{p_end}
{phang2}{cmd:. strkeep make, generate(make_alpha) keep("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")}{p_end}

	{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto.dta}{p_end}

{pstd}Clean the string variable {it:make} to keep only lowercase letters and numbers{p_end}
{phang2}{cmd:. strkeep make, generate(make_clean) lowercase numeric}{p_end}

	{hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto.dta}{p_end}

{pstd}Clean the string variable {it:make} to keep all letters, numbers, and underscores, and 
replace everything else with an underscore{p_end}
{phang2}{cmd:. strkeep make, generate(make_clean) alpha numeric sub("_")}{p_end}

{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}Thank you to Lenny Wainstein for help in checking the code of strkeep.{p_end}

{marker author}{...}
{title:Author}

{pstd}Roger Chu, Research for Action, rchu@researchforaction.org{p_end}

{marker version}{...}
{title:Version History}
{pstd}1.1 - April 5, 2017 - added strlower and strupper options{p_end}
{pstd}1.0 - November 3, 2016{p_end}

