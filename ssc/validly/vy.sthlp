{smcl}
{* *! version 3.2.1  13Aug2013}{...}
{viewerjumpto "Index" "validly##index"}{...}
{viewerjumpto "  Syntax" "validly##syntax"}{...}
{viewerjumpto "  Description" "validly##description"}{...}
{viewerjumpto "  Options" "validly##options"}{...}
{viewerjumpto ">Discussion <<<" "validly##discussion"}{...}
{viewerjumpto "  Examples" "validly##examples"}{...}
{viewerjumpto "  Method" "validly##method"}{...}
{viewerjumpto "  Functions" "validly##function"}{...}
{viewerjumpto " _ Utilities" "validly##utility"}{...}
{viewerjumpto " _ Restrictions" "validly##restrictions"}{...}
{viewerjumpto " _ Error messages" "validly##errors"}{...}
{viewerjumpto " _ Saved results" "validly##saved"}{...}
{viewerjumpto " _ Contact" "validly##contact"}{...}
{cmd:help vy {space 2}{txt}{sf} (the short form of '{bf}validly{sf}' {hline 2} see {help validly:help validly})}
{hline}

{title:Title}
{phang}{hi:vy}{space 2}{hline 2}{txt}{sf} as {help validly:validly}:{p_end}
{pmore}generate or replace a variable, or run conditional commands, 
{help validly##description:correctly handling} missing values in logical/relational expressions{p_end}


{marker index}{phang}{bf}{ul:Corrects Stata's mishandling of logical/relational missing values}{sf}{p_end}
{pmore}
Why this is necessary is explained in the {help validly##description:Description} and, more fully, in the
 {help validly##discussion:Discussion section}.


{title:Index} (clickable links to the relevant sections of {help validly:help validly})
        {help validly##syntax:Syntax}
        {help validly##description:Description}
        {help validly##options:Options}

     {c 134}{c 134} {help validly##discussion:Discussion} - [{c 134}{c 134} explains why it matters]

        {help validly##examples:Examples} 
        {help validly##method:Method}
        {help validly##function:Functions}

           {help validly##utility:Utilities}
           {help validly##restrictions:Restrictions} 
           {help validly##errors:Error messages} 
           {help validly##saved:Saved results} 
           {help validly##reference:Reference} 
           {help validly##contact:Contact} 


{pstd}
As {help generate##syntax:generate} or {help generate##syntax:replace}, but, in contrast to unmodified Stata,
 using {help validly##description:valid functional forms} for any logical or relational expression: {p_end}

{p 8 17 2}
{cmd:vy} {help generate##syntax:{ul:g}enerate} [{help data_types##remarks:type}]  
{help newvar##description:newvar} [:{help labels:lblname}]
{cmd:= }{help exp##remarks:exp}
{ifin}
[{cmd:,}{it:options}]{p_end}
{p 8 17 2}
{cmd:vy} {help generate##syntax:{ul:rep}lace} 
{help varname##description:varname} 
{cmd:= }{help exp##remarks:exp}
{ifin}
[{cmd:,}{it:options}]{p_end}

{pstd}There is also an {ul:extension} of substantive syntax,
 to handle "{it}condition False{sf}" and "{it}condition indeterminate{sf}",
 in addition to the standard "{it}condition True{sf}" states; restricted, if desired, to a subset of observations:{p_end}

{p 8 17 2}
{cmd:vy  {ul:}generate|{ul:rep}lace }
{help varname##description:var} 
{cmd:= }{help exp##remarks:exp}
{ifin}
[{cmd:, }{help validly##ifnot:ifnot(expN)} {help validly##else:else(expE)} {help validly##when:when(expW)}{it: options}]

{marker simplification}{pstd}{ul:Simplifications}:
{space 2}{bf}replace{sf} can be abbreviated to {bf}rep{sf};
{space 2}and {bf}generate/replace{sf} can be completely omitted and are then imputed from
 the existential status of {help varname:var}.


{pstd}
Also as {help assert}, but using {ul:valid} functional forms for any logical or relational expression:{p_end}
{p 8 17 2}
{cmdab:vy  assert }
{help exp##remarks:exp}
{ifin}
[{cmd:,}{it:options}]


{marker wrap}{pstd}
For other {bf}non-assignment{sf} {help if:conditional commands}, {bf}vy{sf} can act as a modifier or  'wrapper':{p_end}
{p 8 17 2}
{cmdab:vy}{space 2}
{it:conditional_command [, its options]}{space 2}
 [{cmd:,,}{it: validly's_options}]{p_end}
{pstd}
{bf}vy{sf} locates the conditional expression, replaces it
 by a valid functional form, and executes the `wrapped'  command (see {help validly##e1wrap:example}).{p_end}
{p 8 9 2}
 (Slightly {help validly##errorW:inelegantly}, but of necessity, {bf}vy{sf}'s
 options appear after {ul:double commas}, to differentiate them from the {it:command}'s options){p_end}


{marker global}{pstd}
The functional macros, used implicitly in the valid commands,
 can also be explicitly requested, in one of two forms:{p_end}
{p 8 17 2}
{cmdab:vy  global}{space 2}
{it:mname}{space 2}
{help exp}{space 3}
[{cmd:,} {it:options}]{p_end}
{p 8 17 2}
{cmdab:vy  global}{space 2}
{it:mname }{space 2}{help if:if exp} 
[{cmd:,} {it:options}]{p_end}
{pstd}
Both return global {help macro} {bf}$mname{sf}. The first form returns a version of {it}exp{sf} evaluating validly to {bf}T{sf}, {bf}F{sf} or {it}{ul:missing}{sf}, 
The second form treats {it}{ul:missing}{sf} values (from a validly evaluated {it}exp{sf}) as {ul:False}, and returns "if {it}exp{sf}", so defined, to constrain Stata 
to select {ul:only} when the condition is in fact true. (Click through
 for examples of {help validly##useglobal:first form}  and {help validly##ewrap:second form} use.)

{space 4}{help validly##index:{c TLC}{hline}}
{space 4}{help validly##index:{c |}{right: goto {bf}Index{sf}{space 2}}}
{space 4}{help validly##index:{c BLC}{hline}}

