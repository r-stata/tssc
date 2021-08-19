{smcl}
{* *! version 1.1 10mar2021}{...}
{viewerjumpto "Syntax" "inlist2##syntax"}{...}
{viewerjumpto "Description" "inlist2##description"}{...}
{viewerjumpto "Options" "inlist2##options"}{...}
{viewerjumpto "Examples" "inlist2##examples"}{...}
{viewerjumpto "Author" "inlist2##author"}{...}
{viewerjumpto "Acknowledgements" "inlist2##acknowledgements"}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:inlist2} {hline 2}}Creates an inlist() dummy, without inlist() limitations {p_end}
{p2colreset}{...}


{marker syntax}{title:Syntax}

{p 8 15 2}
{cmd:inlist2}
{varname} [{cmd:,} {it:options}]


{pstd}
where {it:varname} is the variable values are listed from.
{p_end}

{synoptset 26 tabbed}{...}
{synopthdr :options}
{synoptline}
{syntab :Main}
{synopt :{opth val:ues(a,b,c,...)} all arguments must be reals or all must be strings. If strings, values are space and case sensitive (e.g. "new york"!=" new york"!="New York"). Strings CANNOT have commas as characters}{p_end}

{syntab : Other}
{synopt :{opth name(string)} saves the inlist2 dummy as "string", default is "inlist2"}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt inlist2} generates a dummy equal 1 if {it:varname} is equal to the arguments in {cmd:values()}.{p_end}

{pstd}
{cmd:inlist2} provides a faster way to link multiple "|" operators, similarly to {cmd:inlist}, by creating a dummy variable named inlist2 to be used in successive steps. Inlist2's string values do not require quotation marks (e.g. in case of spaces within the string) so they are faster to write, also, inlist2 does not have a 10 arguments limit for strings or a 250 arguments limit for reals. Inlist2 automatically distinguishes if the variable is a real or a string, but does not allow for commas in strings. Inlist2 does not give error massages if the variable does not have one of the values in the list, but one can check if the replacement is working correctly by looking at the output.
Feedback is greatly appreciated.{p_end}

{marker examples}{...}
{title:Examples of usage}

{pstd}Load data.{p_end}
{phang2}. {stata sysuse auto, clear}{p_end}

{pstd}Want to summarize the price of the first 11 car models, sorted alphabetically. inlist() function only allows 10 strings.{p_end}
{phang2}. {stata inlist2 make, values(AMC Concord,AMC Pacer,AMC Spirit,Audi 5000,Audi Fox,BMW 320i,Buick Century,Buick Electra,Buick LeSabre,Buick Opel,Buick Regal)}{p_end}
{phang2}. {stata sum price if inlist2==1}{p_end}

{pstd}The program overwrites the inlist2 variable every time it is executed, var can be saved with a specific name with the name() option.{p_end}
{phang2}. {stata inlist2 make, values(AMC Concord,AMC Pacer,AMC Spirit,Audi 5000,Audi Fox,BMW 320i,Buick Century,Buick Electra,Buick LeSabre,Buick Opel,Buick Regal) name(first11)}{p_end}
{phang2}. {stata sum price if first11==1}{p_end}

{pstd}Works similarly for reals.{p_end}
{phang2}. {stata inlist2 rep78, values(3,2) name(repair_record23)}{p_end}
{phang2}. {stata sum price if repair_record23==1}{p_end}

{marker author}{...}
{title:Author}

{pstd}Matteo Pinna{p_end}
{pstd}matteo.pinna@gess.ethz.ch{p_end}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd} The author would like to thank Allison Reichel for the input to create the program.{p_end}
