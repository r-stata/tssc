{smcl}
{cmd:help elabel}
{hline}

{title:Title}

{p 4 12 2}
{cmd:elabel} {hline 2} Extensions to the {helpb label} commands


{title:Syntax}

{p 8 12 2}
{cmd:elabel} {it:{help elabel##cmds:subcommand}} 
[ {it:{help elabel##elblnamelist:elblnamelist}} ] 
[ {it:{help elabel##mappings:mappings}} ]
[ {help elabel##iffeexp:{bf:iff}} {help elabel##elabel_eexp:{it:eexp}} ]
[ {cmd:,} {it:options} ]


{p 4 8 2}
where {it:subcommands} are listed {help elabel##cmds:below}.

{marker elblnamelist}{...}
{p 4 8 2}
{it:elblnamelist} is a list of {help label:value label} names. 

{p 8 8 2}
Value label names in {it:elblnamelist} may contain the wildcard characters 
{cmd:*}, {cmd:~}, and {cmd:?}; these characters have the same meaning as 
they have in {it:{help varlist:varlists}}.

{p 8 8 2}
Names in {it:elblnamelist} may refer to value label names indirectly; 
{cmd:(}{varname}{cmd:)} refers to the value label name, if any, that is 
attached to {it:varname} in the current {help label language} (also 
see: extended macro function {help extended_fcn:label}). More than one 
variable name may be specified; {cmd:(}{varlist}{cmd:)} evaluates to the 
value label names that are attached to the variables in {it:varlist}.

{marker varvaluelabel}{...}
{p 8 8 2}
Depending on {it:subcommand}, an {it:elblname} may be preceded by a variable 
name and a colon; {varname}{cmd::}{it:elblname} attaches {it:elblname} to 
{it:varname} (in the current {help label language}) after {it:subcommd} has 
successfully concluded (also see: {help generate}). Use parentheses to specify 
more than one variable name; {cmd:(}{varlist}{cmd:):}{it:elblname} attaches 
{it:elblname} to the variables in {it:varlist}.

{marker mappings}{...}
{p 4 8 2}
{it:mappings} are {it:subcommand}-specific, typically one of 

{p 16 16 2}
{{it:#}|{varname}} {cmd:"}{it:label}{cmd:"} 
[ {{it:#}|{varname}} {cmd:"}{it:label}{cmd:"} {it:...} ]
{p_end}
{p 8 12 2}or{p_end}
{p 16 16 2}
{cmd:(}{it:{help elabel##enumlist:numlist}} | 
{cmd:=}{it:{help elabel##elabel_eexp:eexp}} | {varlist}{cmd:)} 
{cmd:("}{it:label}{cmd:"} [ {it:...} ] | 
{cmd:=}{it:{help elabel##elabel_eexp:eexp}}{cmd:)}
{p_end}

{p 8 12 2}
where parentheses must be typed. {it:mappings} are explained in detail in 
the {it:subcommand} specific help files. {it:{help elabel##elabel_eexp:eexp}} 
is explained below.

{marker iffeexp}{...}
{p 4 8 2}
The {cmd:iff} qualifier is similar to Stata's standard {helpb if} 
qualifier; {it:{help elabel##elabel_eexp:eexp}} is explained below.

{marker elabel_eexp}{...}
{p 4 8 2}
An {it:eexp} is a Stata {it:{help exp:expression}}; {it:eexp}, however, does 
not typically refer to observations in the dataset and does not typically 
contain variable names. If {it:eexp} contains variable names, they are 
interpreted as {it:varname}[1], i.e., the value in the first observation.

{p 8 8 2}
{it:eexp} typically contains the wildcard characters {cmd:#} and 
{cmd:@}. The {cmd:#} character acts as a placeholder for (integer) 
values, while the {cmd:@} character represents text, typically in 
value labels or variable labels. 

{p 8 8 2}
Following the {cmd:iff} qualifier, {it:eexp} must evaluate to true (!=0) or 
false (==0), and it selects a subset of integer to text mappings from value 
labels. For example, {cmd:iff (# < .)} selects all non-missing integers and 
associated text from a value label. Likewise, {cmd:iff (@ == "Foreign")} 
selects only the text "Foreign" and the associated integer value from a value 
label. Note that the {cmd:@} character must not be enclosed in double quotes.

{p 8 8 2}
If {it:eexp} follows the equals sign in {it:mappings}, {cmd:#} is replaced 
with the integer values in a value label; likewise, {cmd:@} is replaced with 
the corresponding text. Both wildcard characters may be combined but the 
evaluated {it:eexp} must either be of type numeric or string.


{title:Description}

{pstd}
{cmd:elabel} manipulates variable labels and value labels. For detailed 
descriptions of the respective commands, follow the links 
{help elabel##cmds:below}.


{marker cmds}{...}
{dlgtab:Subcommands}
{synoptset 24 tabbed}{...}

{...}
{synopt:{helpb elabel_variables:elabel variable}}
Label variables{p_end}

{...}
{synopt:{helpb elabel_define:elabel define}}
Define and modify value labels{p_end}

{...}
{synopt:{helpb elabel_values:elabel values}}
Attach value label to variables{p_end}

{...}
{synopt:{helpb elabel_dir:elabel dir}}
List names of value labels{p_end}

{...}
{synopt:{helpb elabel_list:elabel list}}
List names and contents of value labels{p_end}

{...}
{synopt:{helpb elabel_copy:elabel copy}}
Copy value label{p_end}

{...}
{synopt:{helpb elabel_drop:elabel drop}}
Drop value labels{p_end}

{...}
{synopt:{helpb elabel_save:elabel save}}
Save value labels in do-file{p_end}

{dlgtab:More subcommands}
{synoptset 24 tabbed}{...}

{...}
{synopt:{helpb elabel_compare:elabel compare}}
Compare value labels{p_end}

{...}
{synopt:{helpb elabel_duplicates:elabel duplicates}}
Report or remove duplicate value labels{p_end}

{...}
{synopt:{helpb elabel_keep:elabel keep}}
Keep value labels{p_end}

{...}
{synopt:{helpb elabel_load:elabel load}}
Define value labels from file{p_end}

{...}
{synopt:{helpb elabel_recode:elabel recode}}
Recode value labels{p_end}

{...}
{synopt:{helpb elabel_remove:elabel remove}}
Remove value labels from variables and memory{p_end}

{...}
{synopt:{helpb elabel_rename:elabel rename}}
Rename value labels{p_end}

{dlgtab:Programming}

{synopt:{help elabel_programming:elabel programming}}{p_end}
{synoptline}


{title:Acknowledgments}

{pstd}
{cmd:elabel} is strongly inspired by the work of 
Nick Cox ({stata findit labutil:labutil}), 
Ben Jann ({stata findit labelsof:labelsof}), 
Jeroen Weesie 
({browse "https://www.stata-journal.com/sjpdf.html?articlenum=dm0012":2005a}, 
{browse "https://www.stata-journal.com/sjpdf.html?articlenum=dm0013":2005b}), 
and many others; numerous contributions to 
{browse "https://www.statalist.org/":Statalist} further stimulated 
the development of {cmd:elabel}.


{title:References}

{pstd}
Weesie, J. 2005a. Value label utilities: labeldup and 
labelrename. The Stata Journal, 5(2):154-161.

{pstd}
Weesie, J. 2005b. Multilingual datasets. The Stata Journal, 5(2):162-187.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {help label}{p_end}

{psee}
if installed: {help labcd}, {help labcopy}, {help labdel}, 
{help lablog}, {help labdtch}, {help labmap}, {help labnoeq}, 
{help labvarch}, {help labvalch}, {help labmask}, {help labvalclone}, 
{help labvalcombine}, {help labelsof}, 
{help mlanguage}, {help labeldup}, {help labelrename},
{help varlabdef}, {help vallabdef}{p_end}
