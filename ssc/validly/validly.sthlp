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
{cmd:help validly}
{hline}

{title:Title}

    {phang}{hi:validly} {hline 2} generate or replace a variable, or run conditional commands, 
{help validly##description:correctly handling} missing values in logical/relational expressions


{marker index}{phang}{bf}{ul:Corrects Stata's mishandling of logical/relational missing values}{sf}{p_end}
{pmore}
Why this is necessary is explained in the {help validly##description:Description} and, more fully, in the
 {help validly##discussion:Discussion section} below.


{title:Index} (clickable links, use back-arrow button on Viewer to return)
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

{marker syntax}{title:Syntax}

{pstd}
As {help generate##syntax:generate} or {help generate##syntax:replace}, but, in contrast to unmodified Stata,
 using {help validly##description:valid functional forms} for any logical or relational expression: {p_end}

{p 8 17 2}
{cmd:validly} {help generate##syntax:{ul:g}enerate} [{help data_types##remarks:type}]  
{help newvar##description:newvar} [:{help labels:lblname}]
{cmd:= }{help exp##remarks:exp}
{ifin}
[{cmd:,}{it:options}]{p_end}
{p 8 17 2}
{cmd:validly} {help generate##syntax:{ul:rep}lace} 
{help varname##description:varname} 
{cmd:= }{help exp##remarks:exp}
{ifin}
[{cmd:,}{it:options}]{p_end}

{pstd}There is also an {ul:extension} of substantive syntax,
 to handle "{it}condition False{sf}" and "{it}condition indeterminate{sf}",
 in addition to the standard "{it}condition True{sf}" states; restricted, if desired, to a subset of observations:{p_end}

{p 8 17 2}
{cmd:validly  {ul:}generate|{ul:rep}lace }
{help varname##description:var} 
{cmd:= }{help exp##remarks:exp}
{ifin}
[{cmd:, }{help validly##ifnot:ifnot(expN)} {help validly##else:else(expE)} {help validly##when:when(expW)}{it: options}]

{marker simplification}{pstd}{ul:Simplifications}:{space 2}{bf}{ul:v}alidl{ul:y}{sf} can be abbreviated to {bf}vy{sf};
{space 2}{bf}replace{sf} can be abbreviated to {bf}rep{sf};
{space 2}and {bf}generate/replace{sf} can be completely omitted and are then imputed from
 the existential status of {help varname:var}.


{pstd}
Also as {help assert}, but using {ul:valid} functional forms for any logical or relational expression:{p_end}
{p 8 17 2}
{cmdab:validly  assert }
{help exp##remarks:exp}
{ifin}
[{cmd:,}{it:options}]


{marker wrap}{pstd}
For other {bf}non-assignment{sf} {help if:conditional commands}, {bf}validly{sf} can act as a modifier or  'wrapper':{p_end}
{p 8 17 2}
{cmdab:validly}{space 2}
{it:conditional_command [, its options]}{space 2}
 [{cmd:,,}{it: validly's_options}]{p_end}
{pstd}
{bf}validly{sf} locates the conditional expression, replaces it
 by a valid functional form, and executes the `wrapped'  command (see {help validly##e1wrap:example}).{p_end}
{p 8 9 2}
 (Slightly {help validly##errorW:inelegantly}, but of necessity, {bf}validly{sf}'s
 options appear after {ul:double commas}, to differentiate them from the {it:command}'s options){p_end}


{marker global}{pstd}
The functional macros, used implicitly in the valid commands,
 can also be explicitly requested, in one of two forms:{p_end}
{p 8 17 2}
{cmdab:validly  global}{space 2}
{it:mname}{space 2}
{help exp}{space 3}
[{cmd:,} {it:options}]{p_end}
{p 8 17 2}
{cmdab:validly  global}{space 2}
{it:mname }{space 2}{help if:if exp} 
[{cmd:,} {it:options}]{p_end}
{pstd}
Both return global {help macro} {bf}$mname{sf}. The first form returns a version of {it}exp{sf} evaluating validly to {bf}T{sf}, {bf}F{sf} or {it}{ul:missing}{sf}, 
The second form treats {it}{ul:missing}{sf} values (from a validly evaluated {it}exp{sf}) as {ul:False}, and returns "if {it}exp{sf}", so defined, to constrain Stata 
to select {ul:only} when the condition is in fact true. (See 
below for examples of {help validly##useglobal:first form}  and {help validly##ewrap:second form} use.)


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt d:etail}}displays intermediate and variously helpful information;{p_end}
{synopt:{opt else(expE)}}returns {it}expE{sf} if not otherwise determined by condition;{p_end}
{synopt:{opt e:xtended}}preserves extended-missing values in logical/relational operations;{p_end}
{synopt:{opt ifn:ot(expN)}}"if condition is not true" return {it}expN{sf};{p_end}
{synopt:{opt nop:romote}}see {help generate##options:replace, options}{p_end}
{synopt:{opt s:ource}}identifies the variable sources for missing values{p_end}
{synopt:{opt when(expW)}}restricts to those cases where expW (validly interpreted) is True;{p_end}
{synopt:{opt w:idely}}treats indeterminate (validly evaluated) conditionals as true.{p_end}
{syntab:assert}
{synopt:{opt d:etail}}displays intermediate and variously helpful information;{p_end}
{synopt:{opt f:ast}}see {help assert};{p_end}
{synopt:{opt n:ull}}see {help assert};{p_end}
{synopt:{opt p:ossible}}asserting that expressions which might-{it}possibly{sf}-be-true ({it}i.e.{sf} indeterminate) are acceptable;{p_end}
{synopt:{opt r:c0}}see {help assert};{p_end}
{synopt:{opt w:idely}}treats indeterminate (validly evaluated) conditionals as true.{p_end}
{syntab:global}
{synopt:{opt d:etail}}displays intermediate and variously helpful information;{p_end}
{synopt:{opt e:xtended}}preserve extended-missing values in logical/relational operations;{p_end}
{synopt:{opt w:idely}}treats indeterminate (validly evaluated) conditionals as true.{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
{cmd:by} is allowed with {bf}validly generate/gen/replace/assert{sf}, and when using {bf}validly{sf} as a 'wrapper'  (but not with {bf}global{sf}); see {manhelp by D}.{p_end}

{space 4}{help validly##index:{c TLC}{hline}}
{space 4}{help validly##index:{c |}{right: goto {bf}Index{sf}{space 2}}}
{space 4}{help validly##index:{c BLC}{hline}}

{marker description}{title:Description}

{pstd}Think of "{bf}validly{sf}" as a modifier which corrects errors in certain commands.{p_end}

{pstd}
Stata handles missing values intelligently within {ul:algebraic} operations (so the sum of, say, 4 and an unknown number, is correctly deemed to be unknown).  This intelligence does not 
extend to {ul:logical} and {ul:relational} operations.  The conjunction of two unknown values is, for example, deemed
 by Stata to be a known true statement. There are workarounds (which have to be more complex 
than they are usually presented as being) but they make life unnecessarily difficult when analysing real data.{p_end}
{pstd}
To remedy this,  {cmd:validly generate} has the functionality of {bf}generate{sf}, but,
 in contrast to Stata's {bf}generate{sf}, behaves appropriately
 when missing values are encountered within logical or relational expressions.{p_end}
{pstd}Likewise {bf}validly replace {c 133}{sf}{p_end}
{pstd}Likewise {bf}validly assert {c 133}{sf} {p_end}
{pstd}Likewise {bf}validly global {c 133}{sf} {p_end}
{pstd}Likewise {bf}validly{sf} reg {bf}{c 133}{c 133} if {c 133}{space 2}{sf}(works for any other conditional command).{p_end}

{pstd}
Consider a {it}very{sf} simple example:{p_end}
{phang2}.generate pvq = p|q {txt}  {p_end}
{pstd}this reports 'p or q' as {err}True{txt} when both {bf}p{sf} and {bf}q{sf} are {ul:unknown}.  It should instead, obviously, report 'unknown'. 
A simple "test for missing" does not resolve the issue:{p_end}
{phang2}{err}.generate pvq = p|q if !mi(p,q){txt}  {p_end}
{pstd}will report 'p or q' as '{err}{it}unknown{sf}{txt}' when {bf}p{sf} is True and {bf}q{sf} is unknown; it should report {bf}True{sf} (given a True-{bf}p{sf}, the disjunction is 
{ul:known}-True {it}whatever{sf} the value of {bf}q{sf}). The invocation of {bf}validly{sf} allows the user to get the correct answer, 
without having to craft more elaborate tests for missing, and without using multiple commands:{p_end}
{phang2}{bf}.validly generate pVq = p|q{sf}{txt}  {p_end}
{pstd}
The case for {bf}validly{sf} becomes more persuasive as the logical/relational expressions become more complex.  There is a {help validly##discussion:fuller exploration below in the {ul:Discussion} section}.{p_end}

{phang}{help validly##reminder:Note}: Since {bf}validly{sf} handles appropriate "tests for missing values"
 (within logical and relational expressions)
 it is important {ul:not} to combine the use of
 {bf}validly{sf} with additional conditional tests for missing-values; the expressions should by typed as they are intended to be understood.{p_end}

{pstd}
{help validly##wrap:{bf}validly {it}conditional_command{sf}} executes the specified {it}conditional_command{sf}, 
but,  in contrast to Stata's execution of the 'unwrapped' command, gives the correct result
 when missing values are encountered within relational or logical expressions in the condition.{p_end}

{pstd}
The generated valid functions, implicitly accessed by the above commands, can be generated and stored in global macros by {help validly##global:{bf}validly global{sf}}.
 An example {help validly##ewrap:below} gives an illustration where this might be useful.{p_end}

{pstd}Though the primary focus of {bf}validly{sf} is on correcting Stata's treatment of logical and relational expressions, as a by-product it allows {ul:extension} of the substantive generate/recode syntax. Thus:{p_end}
{pmore}{bf}.validly gen v = a if b, {help validly##ifnot:ifnot(c)} {help validly##else:else(d)}{sf}{p_end}
{pstd}will set variable {bf}v{sf} to '{bf}a{sf}' when the condition '{bf}b{sf}' is known-True; to '{bf}c{sf}' when the condition is known-False;
 to '{bf}d{sf}' when condition '{bf}b{sf}' is indeterminate. See {help validly##sequential:an example of its use, below}.
 There is also a further syntactical extension:{p_end}
{pmore}{bf}.validly gen v = a if b, ifnot(c) else(d) {help validly##when:when(e)}{sf}{p_end}
{pstd}which evaluates across observations for which condition '{bf}e{sf}' is known-True.{p_end}

{pmore}

{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker options}{title:Options}

{dlgtab:Main}

{marker detail}{phang}
{opt d:etail} is a comforting reporting option (standard
 report is on a purely 'need to know' basis),
 which displays detailed information on the decisions being taken by {bf}validly{sf} {hline 2} specifically (see {help validly##method:{ul:Method}} below) it
 reports the {help validly##RPN:{bf}RPN{sf}} versions of
 the expressions and the nested {help cond} functions into which they are compiled (for handling missing values correctly).{p_end}
{p 12 13 2}[Inspection of the {bf}RPN{sf} code can help reassure that {it}validly{sf} is doing what you intend; 
{space 2}even if {bf}{ul:d}etail{sf} is not set, this code is returned in {help validly##saved:{bf}r(RPN){sf}},
 and can be inspected by {help validly##dispsave:the simple command {bf}vy{sf}} (with no arguments.]{p_end}
{pmore}
{opt d:etail} also increases informative reporting with other options (such as {opt e:xtended} or {opt w:idely}).{p_end}
{pmore}Detailed reporting can be set as the default by {help validly##dutility:set_detail}.{p_end}

{marker else}{phang}
{opt else(expE)} after an {help if:{bf}if{sf}}, can be read as an option, or as an {ul:extension} of the substantive recode syntax.
 As its name suggests, it assigns expE (validly interpreted) to the result variable when the condition is not otherwise specified.
 Often used in conjunction with {help validly##ifnot:ifnot}.  Thus:{p_end}
{pmore2}{bf}.validly gen v = a if b, ifnot(c) else(d){sf}{p_end}
{pmore}will set variable {bf}v{sf} to '{bf}a{sf}' when the condition '{bf}b{sf}' is known-True; to '{bf}c{sf}' when the condition is known-False;
 to '{bf}d{sf}' when condition '{bf}b{sf}' is indeterminate.
 When option   {help validly##ifnot:ifnot} is omitted, {help validly##else:else} mops up all observations where condition is not known-True. Thus:{p_end}
{pmore2}{bf}.validly gen v = a if b,  else(d){sf}{p_end}
{pmore}will set variable {bf}v{sf} to '{bf}a{sf}' when the condition '{bf}b{sf}' is known-True, and to '{bf}d{sf}' otherwise (where the condition is false, {ul:or} indeterminate).
  Can be used with option {help validly##when:when}; also with option
 {help validly##extended:{ul:e}xtended} to track extended-missing values through the expressions;  it is obviously NOT compatible with {help validly##widely:{ul:w}idely}.{p_end}

{marker extended}{phang}
{opt e:xtended} retains as much information as possible about {help missing:{ul:extended}-missing} values in relational/logical operations.
 (By default {bf}validly{sf} treats {ul:extended}-missing values as simply missing, {help missing##overview:{it}sysmiss{sf}};
 this is what plain Stata does in algebraic expressions, see {help validly##extendedn2:Note 2}.){p_end}

{pmore}
Consider a logical/relational operator which, on an observation, is due to return a missing value, since one operand is valid but the other carries a specific {ul:extended}-missing value.  
If preserving information, we would then expect the extended-missing value (the "reason" for the indeterminacy) to be carried forward to the result. 
(Indeed, should both operands be indeterminate, but with identical extended-missing value, that value should be carried through to the result.)
 This {bf}{ul:e}xtended{sf} does.

{marker extended1}{pmore2}
{ul:Note 1}: {opt e:xtended} is an {it}option{sf}, not the default (but see {help validly##eutility:set_extended}, below), since it is computationally expensive.
 With {help validly##extended:{ul:e}xtended} set, the necessary {bf}cond{sf}
 interpretation of expressions becomes markedly more complex, so the resulting code
 is slower to execute {hline 2} see the discussion of {help validly##function:{ul:functions}} {hline 2} and in rare cases may {help validly##toolong:exceed} Stata's capacity.{p_end}

{marker extendedn2}{pmore2}
{ul:Note 2}: Whilst Stata is good at preserving {ul:missing} values in {ul:arithmetic} operations, it is not good at preserving the detail of {ul:extended}-missing values.  
These, as the Stata {help missing##overview:help file} says, "can be used to specify different reasons that a value is unknown". But consider: {p_end}
{pmore3}
{bf}.a + 4 {sf}{p_end}
{pmore2}
where clearly that sum
 should be regarded as unknown for the "reason" coded by '{bf}.a{sf}'; but Stata smoothes the result to {help missing##overview:{it}sysmiss{sf}}, willfully discarding information.  
Thus the effect of the {opt e:xtended} option (which {ul:does}, for example, see {bind:'{bf}.a & T{sf}'} as yielding '{bf}.a{sf}') may be vitiated by Stata's "smoothing" to {it}sysmiss{sf} within any {ul:arithmetic} operations involved.
 A reminder of this is given if relevant operators occur.
 Though functions (such as {bf}cond{sf}) can preserve extended-missing values, mostly they do not, so they also attract a reminder.{p_end}
{pmore3}We note {help validly##functionn7:below} how {hline 2} expensively {hline 2} {ul:extended}-missing values can be helped to survive arithmetic.

{marker string}{pmore2}
{ul:Note 3} Strings. If the operands for a relation are of type string, the algorithm given above for {help validly##extended:{ul:e}xtended} makes no sense (string variables have only one possible
 missing value, the {help strings:null string}, and cannot return that value to a numeric variable).
 So {bf}validly{sf} checks for such operands, and for these substitutes an {help validly##relation:alternate encoding} of the relation, which returns the extended-missing value {bf}.s{sf}
 when the {bf}s{sf}tring-relation is indeterminate
 (users {help validly##stringemv:can override} that choice).{p_end}

{marker extended4}{pmore2}
{ul:Note 4} {opt e:xtended} always applies to the assigned expressions (the one immediately after the '=' sign, and the expressions within {help validly##ifnot:ifnot} and {help validly##else:else});{p_end}
{pmore2}but the {opt e:xtended} interpretation of an inclusion condition (the expression following an "{bf}if{sf}")
 would be substantively well-defined only for {bf}generate{sf}
 (without option {bf}{ul:w}idely{sf}). Consider,
 as an example of where it is well defined: {p_end}
{pmore3}
{bf}.validly generate v = exp if expC, e {sf}{p_end}
{pmore2}
for an observation for which {bf}expC{sf} evaluates to a specific extended-missing value (say {bf}.x{sf}). Then variable {bf}v{sf} for that observation is assigned value
  {bf}.x{sf}
 if {bf}exp{sf}, for that observation, is determinate (or would itself also return value {bf}.x{sf})
 {hline 2} it would then be appropriately seen as indeterminate for "reason" {bf}.x{sf} (otherwise it,
 as usual, remains plain {help missing##overview:{it}sysmiss{sf}}.{p_end}
{pmore3}The {help validly##impextif:implementation} is discussed below.
 Within {bf}replace{sf} (or for {bf}generate{sf} with option {help validly##widely:{ul:w}idely}),
 extended-missing values in '{bf}expC{sf}' are smoothed to {it}sysmiss{sf}.{p_end}

{marker edefault}{pmore2}
{ul:Note 5} In {ul:default} mode (without option {help validly##extended:{ul:e}xtended}) {bf}validly{sf}
 smoothes extended-missing values around all operators (arithmetic, relational, logical) to {help missing##overview:{it}sysmiss{sf}};
 but if simple variables are assigned  (as in {bind:'{bf}.vy v =p if r&s, ifn(q){sf}')} their extended-missing values are (where appropriate) passed-through to the result.{p_end}

{marker ifnot}{phang}
{opt ifn:ot(expN)} after an {help if:{bf}if{sf}}, can be read as an option, or as an {ul:extension} of the substantive recode syntax.
 As its name suggests, it assigns {bf}expN{sf} (validly interpreted) to the result variable when the condition is Not-true.  Thus:{p_end}
{pmore2}{bf}.validly gen v = a if b, ifnot(c){sf}{p_end}
{pmore}will set variable {bf}v{sf} to '{bf}a{sf}' when the condition '{bf}b{sf}' is known-True, to '{bf}c{sf}' when the condition is known-False;
 for other observations the variable is left 'as is' (here {help missing##overview:{it}sysmiss{sf}}. Since '{bf}a{sf}' or '{bf}c{sf}' may return missing, variable {bf}v{sf} may also contain other missing values. 
  Can be used with option {help validly##else:else}; also with option {help validly##when:when};
  and {help validly##extended:{ul:e}xtended} may be specified to track extended-missing values;  it is compatible with {help validly##widely:{ul:w}idely}.
 See also the {help validly##sequential:example below} of its sequential use.{p_end}

{phang}{opt nop:romote} {hline 2} see {help generate##options:replace, options} (this is an option retained from standard Stata).{p_end}

{marker source}{phang}
{opt s:ource} aims to identify the sources (in terms of variables) of missing values in the result.
 Each numeric variable, having missing values, appearing as the operand (in a logical or relational expression) is treated {ul:as if}
 all its missing-values were some variable-specific extended-missing value.
 (These values, from {bf}.a{sf} upwards, are assigned in the order in which the variables are first encountered.)
 Then, following the logic of {help validly##extended:{ul:e}xtended}, these notional values are propagated through the logical and relational expressions.
 If a variable appears within an {ul:algebraic} expression, this information, as {help validly##extendedn2:discussed above}, is lost;
 further, {bf}source{sf} does not track individual string variables.
 Selecting {help validly##detail:{ul:d}etail} will yield summary table.{p_end}

{marker sourcer}{phang2}
{opt s:ource(r)} as {bf}source{sf}, but now conflicts of source are {bf}r{sf}andomly resolved.  Thus, for an observation for which we have {bind:'{bf}.a & .b{sf}'}, source(r) randomly returns {bf}.a{sf} or {bf}.b{sf}
 (with equal probability); plain {bf}source{sf} would
 there return {it}sysmiss{sf}.  See below for {help validly##exsource:example and discussion}.{p_end}

{marker sourcev}{phang2}
{opt s:ource(.x)} and {opt s:ource(.x,r)} are variant forms that allow choice of the starting value {bf}.x{sf}
 for the source-code assignment,
 which otherwise defaults to {bf}.a{sf};
 thus {bf}source(.a){sf} is equivalent to plain {help validly##source:{ul:s}ource},
 whilst {bf}source(.a,r){sf} is equivalent to {help validly##sourcer:{ul:s}ource(r)};
 for use of the variant form {help validly##varsource:see example below}.{p_end}

{pmore2}{ul:Note 1} {bf}{ul:s}ource{sf} may be most intelligible when issued with {bf}generate{sf} (or a 'complete' {bf}replace{sf} {it}i.e.{sf}
 one that is unconditional, or conditional with option {help validly##else:{ul:e}lse});
 in other modes the result variable can obviously contain 'original' as well as 'source' missing-value codes.{p_end}

{pmore2}{ul:Note 2} {bf}{ul:s}ource{sf}, logically, affects the interpretation of any {help validly##emvexp:{ul:explicit} extended-missing references}{p_end}

{marker when}{phang}
{opt when(expW)} can be read as an option, or as an {ul:extension} of the substantive recode syntax.
 It restricts the application of {bf}generate/ replace{sf} to those observations when {bf}expW{sf} (validly interpreted)
 is True. It is
 intended for use in conjunction with {help validly##ifnot:{ul:ifn}ot} and/or {help validly##else:else}, where we might wish to apply these to a subset of the data.
  Obviously, logically:{p_end}
{phang3}{bf}.validly v = a if p, when(expW){p_end}
{phang3}.validly v = a, when(p & expW){p_end}
{phang3}.validly v = a if p & expW{sf}{p_end}
{pmore}would all be identical in effect. 
 In contrast:{p_end}
{phang3}{bf}.validly v = a if p & expW, ifnot(b) else(c){p_end}
{phang3}.validly v = a if p, ifnot(b) else(c) when(expW){sf}{p_end}
{pmore}are not identical in effect.  Both assign '{bf}a{sf}' when {bind:'{bf}p & expW{sf}'} (validly interpreted) is True.
 But they diverge on the assignment of '{bf}b{sf}'.  The first assigns '{bf}b{sf}' when {bind:'{bf}p & expW{sf}'} (validly interpreted) is false;
 the second assigns '{bf}b{sf}' only to observations for which {bf}p{sf} is false whilst {bf}expW{sf} is true.
 Also on '{bf}c{sf}'.  The first assigns '{bf}c{sf}' when {bind:'{bf}p & expW{sf}'}
 (validly interpreted) is indeterminate; the second assigns '{bf}c{sf}' only to observations for which {bf}p{sf} is indeterminate
 whilst {bf}expW{sf}
 is true.{p_end}

{pmore2}{ul:Note 1} In the presence of {help validly##else:else}, {bf}replace{sf} with option {help validly##when:when(expw)}
 redefines {ul:all} {hline 1} and only {hline 1} those observations for which {bf}expW{sf} is true.
  See below for {help validly##exwhen:example and further discussion}.{p_end}

{pmore2}{ul:Note 2} {bf}when{sf} always selects-for-True, and so is unaffected by option {help validly##widely:{ul:w}idely}. Thus:{p_end}
{pmore3}{bf}.validly v = a if p, when(expW) w{p_end}
{pmore3}{bf}.validly v = a if p & expW, w{sf}{p_end}
{pmore2}are {ul:not} be identical in effect
 (the first assigns '{bf}a{sf}'when '{bf}p{sf}' is True-or-indeterminate and '{bf}expW{sf}' is True; the second assigns when '{bf}p & expW{sf}'
 is True-or-indeterminate).{p_end}

{marker widely}{phang}
{opt w:idely}  sets a 'wide' inclusion policy when applying a conditional {hline 2} the 'if' expression is validly
 evaluated, but then (in contrast to {bf}validly{sf}'s standard practice),
 both true {ul:and indeterminate} observations are selected.

{pmore2}
{ul:Note}: As with {help validly##possible:{ul:p}ossible}, though "include if missing" looks equivalent to the unvarnished Stata rule, the overall effect is not equivalent to unvarnished Stata; that is:{p_end}
{pmore3}{bf}.gen y = 4 if p|!q{sf}{p_end}
{pmore2}is NOT the same as:{p_end}
{pmore3}{bf}.validly gen y = 4 if p|!q, widely{sf}{p_end}
{pmore2}because {bf}validly{sf} first evaluates {bf}p|!q{sf} correctly.

{dlgtab:Assert}

{phang}
{opt d:etail} {hline 2} as {help validly##detail:above}{p_end}{phang}
{opt f:ast} {hline 2} see {help assert}{p_end}{phang}
{opt n:ull} {hline 2} see {help assert}

{marker possible}{phang}
{opt p:ossible} treats observations where the asserted expression is possible (that is, it evaluates to indeterminate) as not
 contradicting the assertion.  Think of the command as saying: 
"The assertion is true {ul:or possible}".
 Contrast this to {bf}validly{sf}'s standard mode,  where it is considered unacceptable to assert something as {ul:true} if its value is 
sometimes indeterminate. This is discussed further using an example, {help validly##epos:below}.
{p_end}

{pmore2}
{ul:Note}: As with {help validly##widely:{ul:w}idely}, though {opt p:ossible} looks equivalent to the unvarnished Stata rule, the overall effect is not equivalent to unvarnished Stata; that is:{p_end}
{pmore3}{bf}.assert p|!q{sf}{p_end}
{pmore2}is NOT the same as:{p_end}
{pmore3}{bf}.validly assert p|!q, possible{sf}{p_end}
{pmore2}because {bf}validly{sf} first evaluates {bf}p|!q{sf} correctly.

{phang}
{opt r:c0} {hline 2} see {help assert}{p_end}
{phang}{opt w:idely} {hline 2} as {help validly##widely:above} 

{dlgtab:Global}

{phang}
{opt d:etail} {hline 2} as {help validly##detail:above}{p_end}
{phang}{opt e:xtended} {hline 2} as {help validly##extended:above}, but {ul:not} for "validly global mname {ul:if} {it}exp{sf}"{p_end}
{phang}
{opt w:idely} {hline 2} as {help validly##widely:above}, but {ul:only} for "validly global mname {ul:if} {it}exp{sf}"

{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker discussion}{title:Discussion}

{pstd}
As noted {help validly##description:above}, Stata handles missing values intelligently within {ul:algebraic} operations (so, for Stata, the sum of, say, 4 and an unknown 
number, is correctly deemed to be unknown).  This intelligence does not 
extend to {ul:logical} and {ul:relational} operations.  
In logical and relational expressions, Stata treats {bf}missing values{sf} not as {it}missing{sf} but as being {it}very-large-numbers{sf}
 {hline 2} see {help missing} and {help missing##operators:relational operators} and {help missing##expressions:if exp}.  
{marker second}It also treats all non-zero values as 'true'. That second rule is, by itself, innocuous. 
But the {it}combination{sf} of these two rules  generates some bizarre consequences.

{pstd}
The table below shows how Stata's {ul:raw} {bf}generate{sf} interprets logical operators: {bf}!p{sf} (variable {err}np{txt}),
 {bf}p&q{sf} (variable {err}paq{txt}),  {bf}p|q{sf} (variable {err}pvq{txt}); and an exemplar equality relation {bf}p>=q{sf} (variable {err}pgeq{txt}) {hline 2} for the
 nine possible combinations of values of indicator variables {bf}p{sf}, {bf}q{sf}.  

{pstd}
For example: for Stata, if both {bf}p{sf} and {bf}q{sf} are {it}unknown{sf} (row nine), '{bf}p{sf} and {bf}q{sf}' is nevertheless deemed to be {err}true{txt}.  
Asserting combined unknowns to be true is the stuff of fantasy novels, not data analysis.
 The other {err}red{txt} values in the table list other Stata {err}errors{txt}.
 (Notice, for example, that for Stata, where {bf}p{sf} is an indicator variable,
 {bf}!!p{sf} is {ul:not} the same as {bf}p{sf}.)

{pstd}
In contrast, the variables {bf}Np, pAq, pVq{sf} and {bf}pGEq{sf} have been constructed using {bf}validly 
generate{sf}. As can be seen, they preserve the correct formal (and intuitive) behaviour
 of logical and relational operators in the presence of missing values.

{marker table}{txt}       {bf}           !p         p&q         p|q         p>=q   {sf}     
     {c TLC}{hline 3}{c -}{hline 3}{c -}{c TT}{hline 4}{c -}{hline 4}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 6}{c -}{hline 6}{c TRC}
     {c |} {bf}p   q{sf}  {c |} {err}np{txt}   {bf}Np{sf}   {err}paq{txt}   {bf}pAq{sf}   {err}pvq{txt}   {bf}pVq{sf}   {err}pgeq{txt}   {bf}pGEq{sf} {c |}
     {c LT}{hline 3}{c -}{hline 3}{c -}{char +}{hline 4}{c -}{hline 4}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 6}{c -}{hline 6}{c RT}
  1. {c |} {bf}1   1{sf}  {c |}  0    {bf}0{sf}     1     {bf}1{sf}     1     {bf}1{sf}      1      {bf}1{sf} {c |}
  2. {c |} {bf}1   0{sf}  {c |}  0    {bf}0{sf}     0     {bf}0{sf}     1     {bf}1{sf}      1      {bf}1{sf} {c |}
  3. {c |} {bf}1   .{sf}  {c |}  0    {bf}0{sf}     {err}{bf}1{sf}{txt}     {bf}.{sf}     1     {bf}1{sf}      {err}{bf}0{sf}{txt}      {bf}.{sf} {c |}
     {c LT}{hline 3}{c -}{hline 3}{c -}{char +}{hline 4}{c -}{hline 4}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 6}{c -}{hline 6}{c RT}
  4. {c |} {bf}0   1{sf}  {c |}  1    {bf}1{sf}     0     {bf}0{sf}     1     {bf}1{sf}      0      {bf}0{sf} {c |}
  5. {c |} {bf}0   0{sf}  {c |}  1    {bf}1{sf}     0     {bf}0{sf}     0     {bf}0{sf}      1      {bf}1{sf} {c |}
  6. {c |} {bf}0   .{sf}  {c |}  1    {bf}1{sf}     0     {bf}0{sf}     {err}{bf}1{sf}{txt}     {bf}.{sf}      {err}{bf}0{sf}{txt}      {bf}.{sf} {c |}
     {c LT}{hline 3}{c -}{hline 3}{c -}{char +}{hline 4}{c -}{hline 4}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 6}{c -}{hline 6}{c RT}
  7. {c |} {bf}.   1{sf}  {c |}  {err}{bf}0{sf}{txt}    {bf}.{sf}     {err}{bf}1{sf}{txt}     {bf}.{sf}     1     {bf}1{sf}      {err}{bf}1{sf}{txt}      {bf}.{sf} {c |}
  8. {c |} {bf}.   0{sf}  {c |}  {err}{bf}0{sf}{txt}    {bf}.{sf}     0     {bf}0{sf}     {err}{bf}1{sf}{txt}     {bf}.{sf}      {err}{bf}1{sf}{txt}      {bf}.{sf} {c |}
  9. {c |} {bf}.   .{sf}  {c |}  {err}{bf}0{sf}{txt}    {bf}.{sf}     {err}{bf}1{sf}{txt}     {bf}.{sf}     {err}{bf}1{sf}{txt}     {bf}.{sf}      {err}{bf}1{sf}{txt}      {bf}.{sf} {c |}
     {c BLC}{hline 3}{c -}{hline 3}{c -}{c BT}{hline 4}{c -}{hline 4}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 5}{c -}{hline 6}{c -}{hline 6}{c BRC}
               [{it}Variables with uppercase code valid operators, 
                lowercase are plain Stata{sf}] 

{marker check}{pstd}
Stata's plain commands can of course  be persuaded to "check for missing values", but the simple rule scales-up much less intuitively 
than standard presentations might indicate.  {p_end}
{pstd}
For example:  the Stata intention "{it}generate v {sf}= {it}p{sf}|{it}q{sf}" cannot be handled simply by "adding a check for missing values". The command:{p_end}
{phang2}{err}.generate pvq = p|q {bf}if !mi(p,q){sf}{txt}  {p_end}
{pstd}
does {ul:not} work.  For example, it assesses '({bf}T{sf}|{bf}.{sf})' as {err}{it}sysmiss{sf}{txt}, when the correct value is {bf}T{sf}. 
In unvarnished Stata, we have to check for missing values 
{ul:within} each arm of the disjunction.
  Then, within unvarnished Stata, we have a choice of strategies.
 We could use  
{it}separate{sf} commands for {it}false{sf} and {it}true{sf}, thus: {p_end}
{phang2}{cmd:.generate pVq = 0 if !(p|q)}{p_end}
{phang2}{cmd:.replace{space 2}pVq = 1 if (p&!mi(p)) | (q&!mi(q))}{p_end}
{pstd}
Or we could wrap it all into one expression:{p_end}
{phang2}{cmd:.generate pVq = p|q  if !mi(p,q) | (p&!mi(p)) | (q&!mi(q))}{p_end}
{pstd}These are the {it}simplest{sf} workarounds available in standard Stata.
 Neither is intuitive to write; neither is remotely easy to read.
In contrast {bf}validly{sf} just "writes it as it is".
 This makes it much easier to understand, and so to check, what is being intended. That matters 
when you come to review your own analyses;
 your future self also will be grateful. 
We can give the clear, one-line, command:{p_end}
{phang2}{cmd:.validly generate pVq = p|q }{p_end}
{pstd} 
and the point holds more strongly for more complex initial expressions.

{pstd}
{it}Logical{sf} operators within {bf}validly{sf} are interpreted as in the valid (black, uppercase) columns of the {help validly##table:table}.
 Both logical and relational operators return {bf}1{sf} for {bf}True{sf} and {bf}0{sf} for {bf}False{sf}. Thus:{p_end}
{p 9 12 2}
 {bf} !p{sf}  is interpreted as in {bf}Np{sf}{p_end}
{phang2}
{bf}p&q{sf} is interpreted as in  {bf}pAq{sf}{p_end}
{phang2}
{bf}p|q{sf} is interpreted as  in {bf}pVq{sf}{p_end}
{phang}
{it}Relational{sf} operators within {bf}validly{sf} all share the missing values pattern of {bf}pGEq{sf}{p_end}
{p 8 9 2}
[with the one
 exception that when the relational operand explicitly references a {ul:specific} {help missing:{ul:extended}-missing} code ({it}e.g.{sf}
 {bind:'{bf}p > .b{sf}')} the relation evaluates {it}only{sf} to {bf}T{sf} or {bf}F{sf}.
 Though here the equality relation is treated slightly differently {hline 2} see the {help validly##emvexp:example discussed below}.
 Also heed the caution {help validly##reminder:below} on the use of such explicit forms.]{p_end}

{pstd}
For {ul:relational} operators it might seem that Stata's conventions (treating missing values as alphabetically ordered large numbers) are a lesser problem {hline 2} so, if considering {bf}p>q{sf}
 the mid-range user might suppose we just have to add: {bind:{bf}if !mi(p,q){sf} ??}
 But even here the room for error is subtle and easily misread.  For example:{p_end}
{pmore}{bf}.validly replace y = p>q if r==0{sf}{p_end}
{pstd}would do exactly what it says
 on the tin ("For observations for which {bf}r{sf} is zero, replace {bf}y{sf} by the value of {bf}p>q{sf} {hline 2} whether that be {bf}T{sf}, {bf}F{sf} or {ul:indeterminate}").  In contrast, the single
 unvarnished Stata line:{p_end}
{pmore}{bf}.replace y = p>q if r==0 & !mi(p,q) {sf}{p_end}
{pstd}would not suffice; we would have had to have {ul:preceded} that by the additional command:{p_end}
{pmore}{bf}.replace y = . if r==0 & mi(p,q) {sf}{p_end}
{pstd}Not all users would have done this.  Which, again, is why Stata's default conventions are dangerous.{p_end}

{marker vext}{pstd}{ul:Extensions}: Since, to perform its corrections on unvarnished Stata, {bf}validly{sf} has to disaggregate the expressions within {bf}generate/replace{sf},
 it can extend the "functionality" (horrid word) of these commands.
 The extensions are implemented using standard Stata conventions for a command's options; you can view the device as "options", or as extensions of the {bf}generate/replace{sf} syntax.  Thus:{p_end}
{pmore}{bf}.validly [generate|replace] v = a if b, {help validly##ifnot:ifnot(c)} {help validly##else:else(d)}{sf}{p_end}
{pstd}will set variable {bf}v{sf} to '{bf}a{sf}' when the condition '{bf}b{sf}' is known-True; to '{bf}c{sf}' when the condition is known-False;
 to '{bf}d{sf}' when condition '{bf}b{sf}' is indeterminate.{p_end}
{pstd}There is also a further 'syntactical' extension:{p_end}
{pmore}{bf}.validly [generate|replace] v = a if b, ifnot(c) else(d) {help validly##when:when(e)}{sf}{p_end}
{pstd}That evaluates the {bf}generate/replace{sf} across observations for which condition '{bf}e{sf}' is known-True.{p_end}
{pstd}See {help validly##sequential:the example below}, using all three options.{p_end}

{pstd}A further {ul:extension} is that {bf}validly{sf} can track the data's {help validly##extended:{ul:extended}-missing values} through logical/relational expressions, or
 identify the {help validly##source:variable sources} of indeterminacy.{p_end}


{pstd}
For an explication of the mechanics behind {bf}validly{sf}'s simplification see the sections {help validly##method:on method} and {help validly##function:on functions};
 for deployment see {help validly##examples:examples of use} in the next section;
 and for a more extended discussion of the underlying issues, refer to the article {help validly##reference:cited below}.{p_end}

{pstd}Note that related, less serious, issues affect functions {help min} and {help max} {hline 2} see {help validly##max:example below}.{p_end}

{marker reminder}{phang}Reminder: Since {bf}validly{sf} handles correctly "tests for missing values" it is important {ul:not} to combine the use of
 {bf}validly{sf} with additional conditional checks-for-missing
 aiming at the same goal
 {hline 2} such as calls to {bf}mi(){sf} or 
 other explicit missing-values tests within the conditional {hline 2} referencing the operands of the logical and relational expressions.
 Leave {bf}validly{sf} to do that work. Thus:{p_end}
{pmore2}{err}.validly gen y = p&q if !mi(p){txt}{p_end}
{pmore}would yield a nonsense (seeing '{bf}.|T{sf}' as {err}sysmiss{txt} rather than {bf}T{sf}).  But deployed judiciously, and with care,
 explicit conditional tests for missing can be useful
 (which is why, on encounter, {bf}validly{sf} issues a warning but not an error
 message).  For example:{p_end}
{pmore2}{bf}.validly gen y = p&q if !mi(r){sf}{txt}{p_end}
{pmore}would be fine, giving us valid {bf}p&q{sf} for observations on which {bf}r{sf} was defined.
 A more extended instance of an appropriate deployment of
 a conditional test for missing appears in the {help validly##sequential:example below}{p_end}


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker examples}{title:Examples}{p2colset 7 39 39 2}
{p2col:{c |}a{c |} {help validly##exstraight:Straightforward}}{c |}h{c |} {help validly##exsource:use of source}{p_end}
{p2col:{c |}b{c |} {help validly##eximpute:impute command}}{c |}i{c |} {help validly##varsource:on source(.x)}{p_end}
{p2col:{c |}c{c |} {help validly##emvexp:explicit extended-missing}}{c |}j{c |} {help validly##useglobal:global}{p_end}
{p2col:{c |}d{c |} {help validly##e1wrap:conditional commands}}{c |}k{c |} {help validly##epos:assert}{p_end}
{p2col:{c |}e{c |} {help validly##ewrap:repeated condition}}{c |}l{c |} {help validly##exqglobal:global, syntax}{p_end}
{p2col:{c |}f{c |} {help validly##sequential:sequences (ifn, else, when)}}{c |}m{c |} {help validly##extype:[type] and value-label}{p_end}
{p2col:{c |}g{c |} {help validly##exwhen:more on ifn, else, when}}{c |}n{c |} {help validly##max:on max and min}{p_end}

{p 7 7 9}{it}You can think of {bf}validly{it} (or, shortened, {bf}vy{it}) as a command modifier which corrects errors in certain commands.{sf}{p_end}

{marker exstraight}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}a{sf}{c |} Examples of {it}validly generate{sf} or {it}validly replace{sf}, used where {it}generate{sf} or {it}replace{sf} would ({help validly##table:incorrectly} if the relational/logical operators encounter missing values)
 normally be found:{p_end}

{phang}{cmd:.validly gen pAq = p&q, detail}

{phang}{cmd:.validly generate v = !((p&q)|(p|q))&(r|!s)&t }

{phang}{cmd:.{help validly##simplification:{bf}vy{sf}} replace v = sqrt(inc) if  !( class!=3 | class!=6 ), d}

{phang}{cmd:.{help validly##simplification:{bf}vy{sf}} gen lagnp = !p[_n-1]}

{marker eximpute}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}b{sf}{c |} As a minor typing reduction, {bf}validly{sf} can impute whether {bf}generate{sf} or {bf}replace{sf} is intended. Consider: {p_end}

{phang}{cmd:.vy fresh = (assets/(incm - expend)>100) & (AgeF==AgeM), d}{p_end}

{pstd}If variable {bf}fresh{sf} does not exist this is equivalent to {bf}validly generate{sf}; if it does exist, this is equivalent to {bf}validly replace{sf}.
 If '{bf}replace{sf}' is imputed this is clearly reported
 (should you want the convenience of imputing {bf}generate{sf} without the perceived risk of imputing {bf}replace{sf}
 {help validly##rutility:there is a utility} to so restrict).{p_end}

{marker emvexp}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}c{sf}{c |} Explicit {ul:extended}-missing references.  Where these appear, as in:{p_end}

{phang}{cmd:.vy defaulter1 = debt>.b & male}{p_end}

{pstd}{bf}validly{sf}'s standard approach to a relation ("it is indeterminate if either operand is indeterminate") is obviously inappropriate.
 Such relations are therefore treated {ul:literally}
 (it is assumed that would be the user's intention);
 thus '{bf}debt>.b{sf}' is true for those whose debt is unknown for reasons {bf}.c,,d,{c 133}{sf} and false otherwise.{p_end}

{pstd}For equality ('==') the reasoning is
 slightly different. Consider:{p_end}

{phang}{cmd:.validly gen defaulter2 = (debt==.a|debt==.b) & age>55}{p_end}

{pstd}The thinking here is as follows: The expression '{bf}debt==.a{sf}' can be read as saying "debt is unknown for
 reason {bf}.a{sf}". So obviously False if debt is known, or unknown for reason {bf}.b{sf}.  But, on this reading, a coding
 of '{help missing##overview:{it}sysmiss{sf}}' for {bf}debt{sf} would reflect "an unknown unknown"
 {hline 2} debt is unknown, perhaps for reason {bf}.a{sf}, perhaps for
 reason {bf}.b{sf}.  So it is proper, for an observation
 with the value of {it}sysmiss{sf},  to regard the assertion "debt is unknown for reason
 {bf}.a{sf}" as indeterminate. So, for this {it}explicit{sf} equality test against {ul:extended}-missing values, {bf}validly{sf} returns {bf}T{sf}
 or {bf}F{sf} unless {it}sysmiss{sf} is encountered (when {it}sysmiss{sf} is returned).{p_end}
{pmore}Implementation is {help validly##emvfn:described here}. Should you nevertheless wish the bare explicit function (returning {ul:only} T or F)
 use plain Stata to generate the corresponding variable {bind:({bf}.gen debta = debt==.a{sf})} and deploy that within validly.{p_end}
{pmore}{err}Note{txt} that if option {help validly##source:{ul:s}ource} is present,
 explicit extended-missing references {help validly##sourceimp:may {ul:not} deliver as intended}.{p_end} 

{marker e1wrap}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}d{sf}{c |} Suppose we are concerned to run the following regression
 (where {it}incm{sf} may equal {it}expend{sf}, and any variable may contain missing values):{p_end}

{phang}{err}.reg assets incm{space 2}if  (assets/(incm-expend)>100) & (AgeF==AgeM), b{txt}{p_end}

{pstd}
That Stata expression will not extract the expected subset (for example, it may include observations where {it}both{sf}
male and female ages are {it}unknown{sf}). {bf}validly{sf}'s ability to "wrap" a Stata command allows 
us to carry out the above regression with one single command:

{phang}{cmd:.vy{space 2}reg assets incm{space 2}if (assets/(incm - expend)>100) & (AgeF==AgeM), b }{p_end}

{pstd}The same ploy can helpfully get other commands correct; for example:{p_end}

{phang}{cmd:.validly list{space 2}a b c{space 2}if p|!q}{p_end}

{pstd}Four footnotes:{p_end}
{p 4 6 2}1 The {it}beta{sf} option for {bf}reg{sf}, above, appears after one comma; were we to deploy validly's options (such as {opt d:etail}) these would appear after {ul:two} commas (a pair not-separated by spaces),
 though if habitually you invoke {opt d:etail} it might be simpler to invoke {help validly##minor:{bind:.vy set_detail}} once.{p_end}
{p 4 6 2}2 {marker wrapnote}The valid condition from the last used 'wrapped' command is always returned in the macro {help validly##saved:r(ifcond)},
 so, for example, after the above command, we could display further similarly selected lists,
 or run a regression on the same subset,
 without re-invoking {bf}validly{sf}, thus:{p_end}
{pmore2}{bf}.global cond `r(ifcond)'{sf}{p_end}
{pmore2}{bf}.list{space 2}d e{space 3}$cond{sf}{p_end}
{pmore2}{bf}.reg{space 2}a b c{space 2}$cond{sf}{p_end}
{p 4 6 2}3 'wrapped' commands return their {ul:own} {help r():{bf}r(){sf}} and {help e():{bf}e(){sf}} saved
 results exactly as when issued normally. Should the command be an estimation command, then the command-line used by {bf}validly{sf}
 can be inspected by:{p_end}
{pmore}{help validly##saved:{bf}.di{space 2}"`e(cmdline)'"{sf}}{p_end}
{p 4 6 2}4 For 'wrapped' commands, any {help by:'by' option} is written preceding {bf}validly{sf}, thus:{p_end}
{pmore}{cmd:.by country: validly reg {c 133} if {c 133}}{p_end}

{marker ewrap}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}e{sf}{c |} Where a clutch of commands, all qualified by the same conditional, is being run, it may well be convenient to
 define (and then repeatedly re-use) a 
valid macro containing the conditional.  Reverting to the regression example above, we could, for example, do:{p_end}

{phang}{cmd:.validly global subset{space 2}if (assets/(incm - expend)>100) & (AgeF==AgeM) }{p_end}
{phang}{cmd:.reg assets incm{space 2}$subset, b}{p_end}
{phang}{cmd:.reg assets incm age{space 2}$subset, b}{p_end}
{phang}{cmd:.reg {c 133}{c 133}}{p_end}

{pstd}
This strategy avoids risk of retyping errors;
 and gives the one 'point of change' (that definition of global {bf}$subset{sf})
 should you subsequently decide to change your inclusion criterion, and rerun your analyses.{p_end}

{marker ewrapn}{pmore}Note: since, as {help validly##detail:{ul:d}etail} will reveal,
 the condition macro, in the absence of {help validly##widely:{ul:w}idely},
 is coded in "missing->False" form, it is not suitable for re-use {ul:within} {bf}validly{sf}.{p_end}

{marker sequential}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}f{sf}{c |} {ul:Handling sequential conditionals}:  [This is an example of the utility of {bf}validly{sf}'s {help validly##vext:extensions} to
 standard {bf}generate/ replace{sf} syntax.]
{space 2}Suppose we wished to capture an intention which might be informally expressed:{p_end}

{phang2}" if test1-OK, assign1;{space 2} elseif test2-OK, assign2;{space 2} else assign3 "{p_end}

{pstd}In the presence of missing-values this would {ul:not} be well captured by use of the standard {bf}generate/ replace{sf} syntax:{p_end}

{phang2}{err}.validly generate v = .z{p_end}
{phang2}{err}.validly replace{space 2}v = assign1 if test1{p_end}
{phang2}{err}.validly  replace{space 2}v = assign2 if test2 & v==.z{p_end}
{phang2}{err}.validly  replace{space 2}v = assign3 if v==.z{txt}{p_end}

{pstd}because observations for which {bf}test1{sf} computed as indeterminate could be assigned values depending upon {bf}test2{sf} or{bf} test3{sf};
 not our intention.  Reverting to unvarnished generate/replace will obviously not solve this problem.  But the following
 sequence, using the {bf}validly{sf} extensions, does capture our intention:{p_end}

{phang2}{bf}.validly generate vt = assign1 if test1, {help validly##ifnot:ifnot(.z)}{p_end}
{phang2}{bf}.validly  replace{space 2}vt = assign2 if test2 & (vt==.z), ifnot(vt) {help validly##else:else(.)}{p_end}
{phang2}{bf}.validly  replace{space 2}vt = assign3 if vt==z.{sf}{p_end}

{pstd}This correctly  runs {bf}test2{sf} on those known to fail {bf}test1{sf}, and returns {bf}assign3{sf} only for those known to fail both.
  Those who score indeterminate on the first test remain at {help missing##overview:{it}sysmiss{sf}}; those who, when tested, score indeterminate on test2 are set to {it}sysmiss{sf}.
  This pattern of missing values is an optimum solution, declining to pronounce on those for whom we cannot pronounce.
 The solution 'scales-up' straightforwardly to longer 'elseif' chains, by reproducing the structure of the second line.{p_end}

{marker seqwhen}{pstd}Suppose however we wished to use option {help validly##extended:{ul:e}xtended},
 to trace extended-missing values, the above solution no longer works
 (the {bf}else{sf} in the second line smoothes to {it}sysmiss{sf}, and replacing its argument by {bf}test2{sf} does not do what is required).
 We should now do:{p_end}

{phang2}{bf}.vy gen ve = assign1 if test1, ifn(.z) e{p_end}
{phang2}{bf}.vy rep ve = assign2 if test2, ifn(.z) else(test2) {help validly##when:when(ve==.z)} e{p_end}
{phang2}{bf}.vy rep ve = assign3 if v==z. , e{sf}{p_end}

{pstd}The substantive results are as before, but now extended-missing values, interpreted as "reasons for indeterminacy" are,
 as far as possible, retained.
 As before the solution 'scales-up' straightforwardly to longer 'elseif' chains, simply by reproducing the structure of the second line.{p_end}

{pstd}Four footnotes:{p_end}
{p 4 6 2}1 If {help validly##extended:{ul:e}xtended} is enabled, choose, for {bf}ifnot(.z){sf}, an extended-missing value not naturally present in the data.{p_end}
{p 4 6 2}2 Since {bf}validly{sf} has some of the characteristics of a concerned, but not always percipient, minder it frets
 about tests-for-missing within conditionals (since, as {help validly##reminder:noted above}, they can generate nonsense)
 so the first solution will result in a 'warning', which can be disregarded.{p_end}
{p 4 6 2}3 The {bf}else{sf} in the second line of the first solution
 retains restricted scope, without encountering the problems {help validly##when:when} aims to address,
 because, in that particular instance, {bind:'{bf}test2 & v==.z{sf}'} can return indeterminate {ul:only} within the proper remit of the test (when {bf}v==.z{sf} is True)
 since {bind:'sysmiss & O'} correctly returns False within {bf}validly{sf}.{p_end}
{p 4 6 2}4 Within a command, the {ul:sequence} of options{space 2}{bf}ifnot, else, when{sf}{space 2}is immaterial; for human readers they are probably most
 intelligible written in their 'natural' sequence,
 as above.{p_end}

{marker exwhen}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}g{sf}{c |} Option {help validly##when:when(expW)} can be useful in controlling the range of {help validly##ifnot:ifnot} and {help validly##else:else}; it also controls the range of the initial {help if:if condition}.
  We saw it deployed in the {help validly##seqwhen:last example}.  A further example:
 Suppose, let us pretend, we have a devised a happiness scale which is computed differently for the married and unmarried,
 and within that differently for men and women.  If we were to do something like:{p_end}
{phang2}{bf}.validly happ = scaleMW if married & female{sf}{p_end}
{pstd}that would be fine, but handles only one eventuality; and if we added an {bf}ifnot(x){sf} option,{bf} x{sf} would be applied
 both to all the unmarried and to all males, which fails to capture our intention.  But we could do:{p_end}

{phang2}{bf}.validly gen hap = scMW if married, ifnot(scNW) else ((scMW+scNW)/2) when(female){sf}{p_end}

{pstd}which calculates {bf}scaleMW {sf}only for {bf}m{sf}arried {bf}w{sf}omen,  {bf}scaleNW{sf} only for {bf}n{sf}on-married {bf}w{sf}omen, 
and sets the average of the two scales for women of indeterminate marital status.  Similarly for males:{p_end}

{phang2}{bf}.validly happ = scMM if married, ifnot(scNM) else ((scMM+scNM)/2) when(!female){sf}{p_end}

{pstd}The sequence sets those of indeterminate gender to {it}sysmiss{sf} for variable {bf}happ{sf}.{p_end}
{pstd}This option when used as in this example, is a convenience merely, but it does much simplify coding.  
 Since {help validly##when:when} focuses on explicit treatment of conditions, its use  is deemed incompatible with option {help validly##widely:{ul:w}idely}.{p_end}

{marker exsource}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}h{sf}{c |} On the relation between {help validly##source:{ul:s}ource} and {help validly##sourcer:{ul:s}ource({bf}r{sf})}. Consider:{p_end}

{phang2}{bf}.validly v =(p & q)|t, source{sf}{p_end}

{pstd} applied to a dataset with the following characteristics:{p_end}
{pmore}There are substantial missing-values in {bf}p{sf} and {bf}q{sf} and {bf}t{sf}. But {bf}t{sf} is missing almost exclusively when
  {bf}p&q{sf} is true (so, given the definition of disjunction,
 its missing values do not affect the result). Further, {bf}p{sf} has noticeably more missing values than {bf}q{sf}, and almost all of {bf}q{sf}'s missing-values
 occur when {bf}p{sf} is also missing.{p_end}
{pstd} THEN the above command, with {help validly##detail:{ul:d}etail}, for such data,
 would report:{p_end}
{pmore}a noticeable number of {bf}.a{sf} extended-missing values (from source {bf}p{sf}),
 a few {bf}.b{sf} (from {bf}q{sf}), a few {bf}.c{sf} (from {bf}t{sf}), and a sizeable chunk of {help missing##overview:{it}sysmiss{sf}}.
 (These {it}sysmiss{sf} coming from {bf}p&q{sf} when both variables are indeterminate.){p_end}
{pstd}The pattern of {bf}.a{sf} extended-missing values in result {bf}v{sf} correctly directs us to
 those observations in {bf}p{sf} which, if we could upgrade only one variable,
 would have  most impact on our result.{p_end}

{pstd} But this may (by declining to adjudicate when two 'sources' of missing are
 present as operands to the same operator) mislead on the relevance of the variables.
  On the above report, variables {bf}q{sf} and {bf}t{sf} look similar; but in the data as described {bf}t{sf}, even if corrected, would have little relevance;
 whereas {bf}p{sf} and {bf}q{sf}, if {ul:both} corrected, would have significant impact. 
 This may be better seen by an alternative formulation:{p_end}

{phang2}{bf}.vy y =(p & q)|t, s(r){sf}{p_end}

{pstd}which {ul:randomly} assigns one or other 'source' code when both operands are missing but from different sources. The aim of {bf}source(r{sf})  is not to assign "reasons for missing"
 but to get some sense of relevant (to the expression) "sources of missing".{p_end}
{pmore}For the data as here imagined, most of the random allocation will occur between {bf}p{sf} and {bf}q{sf},
 so the report would probably give more {bf}.a{sf} than {bf}.b{sf}, but a sizeable number of each; with few {bf}.c{sf}, and no {it}sysmiss{sf}.{p_end}
{pstd}For some research purposes this (correctly indicating that missing-values in {bf}t{sf} are here irrelevant,
 though numerous in the data) can be more useful than the first report.{p_end}

{marker sourceimp}{pmore}The implementation details
 of {bf}{ul:s}ource{sf} are {help validly##sourcecode:described below}, and make clear that the missing-values codes for the originating variables
 are purely '{it}as if{sf}'; the source variables are not modified in any way.
 The notional codes override any extended-missing codes within the data; all missing values within the data are treated
 {ul:as if} they carried the associated notional code of their variable.{p_end}
{pmore}In particular, this entails that any
 {help validly##emvexp:{ul:explicit} extended-missing references}
 are interpreted as referring to these notional codes,
 {err}{bf}not{sf}{txt} to any extended-missing codes recorded in the data ({bf}validly{sf} prints a {err}warning{txt}
 in those cases, but not an error, since a careful use might, just possibly, have been intended).{p_end}
{pmore2}Note that {help validly##source:source} differs from Stata's useful {help misstable} in that it explores missing values
 in relation to their effect on a {ul:specific} generate/replace command.{p_end}

{marker varsource}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}i{sf}{c |} On the utility of the variant forms {help validly##sourcev:{ul:s}ource{bf}(.x){sf}} and {help validly##sourcev:{ul:s}ource({bf}.x,r{sf})}.
 Standard {bf}source{sf} is most interpretable when used with {bf}generate{sf}.
 {help validly##source:As mentioned}, care has to be taken when combining {bf}source{sf} with {bf}replace{sf}, since the result variable may already
 contain extended-missing values not derived from {bf}source{sf}.
 Consider:{p_end}

{phang2}{bf}.vy gen v = (p & q), source(r){sf}{p_end}
{phang2}{err}.vy rep v = (r|s) if u, source(r){txt}{p_end}

{pstd}The first command will use codes {bf}.a{sf} and {bf}.b{sf}  to flag indeterminacy originating with {bf}p{sf} and {bf}q{sf} respectively.
 But the second command will use these same codes to refer to sources {bf}r{sf} and {bf}s{sf}.
 Which would render the pattern of extended-missing values in {bf}v{sf} impossible to interpret.
 So here we do:{p_end}

{phang2}{bf}.vy gen v = (p & q),  s(r){sf}{p_end}
{phang2}{bf}.vy rep v = r|s if u, s(.f,r){sf}{p_end}

{pstd}which ensures that the fresh variables have their sourced missing values identified by a sequence beginning with {bf}.f{sf}
 (the problem, and hence this solution, can arise even with a {bf}replace{sf} accessing the same variables,
 since the values are assigned in the order in which variables are encountered, which may vary).{p_end}

{marker useglobal}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}j{sf}{c |} This is a {help validly##ewrap:further} example of the use of {bf}validly global{sf}.
 Suppose that, for some esoteric but defensible analytic purpose, we wished to define a function (to pass to some command other than {bf}generate/replace{sf}) which took the value {bf}p&q{sf}
 when {bf}r{sf} was true, and {bf}p|q{sf} when {bf}r{sf} was false.  One strategy would, obviously, be to construct a corresponding  variable, using: {p_end}
{pmore}{bf}.validly gen fn = p&q if r, ifnot(p|q) {sf}{p_end}
{pstd}and deploy that as appropriate.  Another strategy, keeping with the function requirement, would be to consider using the branching function: {p_end}
{pmore2}{err}cond(r, p&q, p|q, .){txt} {p_end}
{pstd}In that straightforward form the device would not work, because we would fall foul of Stata's mishandling
 of relations.  But instead we could do: {p_end}

{pmore}{bf}.validly global paq{space 2}p&q{sf}{p_end}
{pmore}{bf}.validly global pvq{space 2}p|q{sf}{p_end}

{pstd}and then use, correctly, the function:{p_end}

{pmore2}{bf}cond(r, $paq, $pvq, .) {sf}{p_end}

{pstd}wherever it is required.   The strategy of "define macro and deploy" extends readily to any embedded logical and relational expression anywhere within Stata, to yield valid answers. {p_end}

{marker epos}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}k{sf}{c |} {bf}validly assert{sf} is correct (as against unvarnished Stata) in its valuation of logical and relational expressions.
  But beyond that, there is no "correct" specification of which of the options {opt w:idely} or {opt p:ossible} should be deployed.{p_end}

{pstd}For example: We rightly expect "age" to exceed "years of education".  If we wished to test whether our sample contained any persons for whom their recorded years of education in fact 
exceeded or equalled their recorded age, we could do::

{phang}{cmd:.validly assert age > ed_years, possible}{p_end}

{pstd}
On this setting, if the relation is evaluated and deemed to be indeterminate we do not report a 
contradiction (for that observation the relation might possibly,
 were the true values known, be true).  Only if it is {ul:known} 
for some observation that {bf}ed_years>=Age{sf} would this call report a contradiction. 
Contrast: 

{phang}{cmd:.validly assert  age > ed_years} 

{pstd}
which asserts that the 
relation is {ul:known} to be true (so sees any observations for which
 the relation is indeterminate as contradicting that 
claim to {ul:knowledge}).  {p_end}

{pstd}
This particular example could readily be handled within standard Stata by use of {bf}mi(){sf}; in more complex conditional assertions
 {bf}validly assert{sf} is more coherent, and clearer, than unvarnished {bf}assert{sf}, but whether it is better with or without 
{opt p:ossible} or {opt w:idely}, depends on your substantive concerns.{p_end}

{pstd}For some assertions a {ul:combination} of {bf}validly{sf} and unvarnished Stata may be best.
  For example, suppose we wish to test whether '{bf}p|q{sf}' and '{bf}r|s{sf}' have identical patterns of {bf}T{sf}, {bf}F{sf} and {it}missing{sf} values.
  Neither of:{p_end}
{pmore}{err}.assert (p|q)==(r|s){p_end}
{pmore}.validly assert (p|q)==(r|s){txt}{p_end}
{pstd}do what is required (and adding {help validly##pssible:{ul:p}ossible} does not help).
 We should here do (using the strategy of the previous example):{p_end}
{pmore}{bf}.vy global pvq{space 2}p|q{p_end}
{pmore}.vy global rvs{space 2}r|s{sf}{space 3}// to get the logic right{p_end}
{pmore}{bf}.assert $pvq == $rvs{sf}{space 2}// to get literal equivalence right{p_end}

{marker exqglobal}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}l{sf}{c |} Though {bf}validly global{sf} uses the quotation-less version of {help global} syntax (so no compound {help quotes}), it is nevertheless happy with embedded string variables.  For example:

{phang}{cmd:.validly global both{space 2}(att1=="agree" | att2 =="agree")}{p_end}

{pmore}
Note: whereas plain {bf}global{sf} swallows anything, {bf}validly global{sf} is designed to handle
 only {ul:expressions}, so must reference a legitimate one, in the form {help exp} or {help if:if exp}.

{marker extype}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}m{sf}{c |} For explicit invocations of {bf}generate{sf} the standard Stata modifiers are available; for example:{p_end}

{phang}{cmd:.label define tf 1 True 0 False}{p_end}
{phang}{cmd:.vy gen {help generate:{bf}byte{sf}} pVq{help generate:{bf}{c 58}tf{sf}} = p|q}{p_end}

{pstd}would validly generate {bf}pVq{sf} as {help data_types##remarks:type byte}, attaching to it the {help labels:value labels} just defined in {bf}tf{sf}.
 The ability to attach value-labels on-the-fly is useful.
 Had we not pre-{ul:defined} {bf}tf{sf}, {bf}validly{sf} would have printed a {err}warning{txt} (lest we had misspecified) but would accept the request,
 allowing subsequent definition.{p_end}

{pstd}However, although {bf}[{sf}{help data_types:type}{bf}]{sf} is a standard option for Stata's {bf}generate{sf} it is {ul:dangerous};
 Stata gives {ul:no} warning should there be any entailed truncation.
 If storage is a concern, better to leave defaults in place and periodically invoke {help compress}; as the Stata help-file observes:
 "compress never makes a mistake, results in loss of precision, or hacks off strings".{p_end}

{pstd}Explicit {bf}vy replace{sf}, again following Stata,
 allows option {help generate##options:{ul:nop}romote}; although of esoteric utility,
 this option is less dangerous than {bf}type{sf} since it reports any entailed truncation.{p_end}

{marker max}{c TLC}{hline 1}{c TT}{hline}
{p 0 4 2}{c |}{it}n{sf}{c |} This is NOT a {bf}validly{sf} example, but a footnote on a related issue in the functions {help max} and {help min},
 which {bf}validly{sf} does not address.  For Stata, both {help max} and {help min}
 return determinate values {ul:unless} {ul:all} the arguments are indeterminate.
 This (though well defined) may not always be appropriate.
 Suppose (let us pretend) that for our analytic purposes it would make sense to modify the resource variable, for
 our dataset on couples, to record for outright homeowners the higher of the individual incomes,
 or missing if that were undefined,
 and thought to do:{p_end}

{phang2}{err}.replace resource  = max(incF,incM) if own==1{txt}{p_end}

{pstd}For women whose spouses (perhaps bashful tycoons or shamefaced paupers) refused to answer, this returns the income of the woman as the purportedly {ul:known} higher individual income.
 Here better use the assistance of {help cond} to do::{p_end}

{phang2}{cmd:.replace resource = cond(mi(incF,incM), ., max(incF,incM)) if own==1}{p_end}
{pstd}or, more ingeniously, but less transparently:{p_end}
{phang2}{cmd:.replace resource = cond(incF>incM, incF, incM) if own==1}{p_end}

{pstd}Either appropriately sets {cmd:resource} as {ul:unknown} for couples where we lack the relevant information.
 The second, ingenious, strategy is lifted from {help validly##reference:Kantor and Cox (2005)}
 (but note that,
 if differing extended-missing values are present on the two variables,
 it always chooses to passthru the alphabetically 'higher').{p_end}
{pmore}Note that placing an explicit {cmd:!mi(incF,incM)} test in the conditional would not here
 give the same result. Note further that {bf}validly{sf}, if presented with {help min} or {help max},
 does {ul:not} intervene to help, but does print a reminder of the issues.{p_end}


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}


{marker method}{title:Method}
{p 0 1 20}[{it}This Section (with the {help validly##function:{it}next}) provides a description of the backstage mechanics underlying the results.
 Those wishing simply to {ul:use} the utility might perhaps skim these sections, but should have no immediate need for careful perusal.
 The next useful-for-use section is {help validly##utility:{it}Utilities}, below{sf}]{p_end}

{pstd}
For unvarnished Stata, {help validly##discussion:as discussed}, {ul:no} combination of logical or relational operators returns {ul:missing} values whatever 
the status of their operands. This presents problems, requiring non-transparent, multi-statement, workarounds {hline 2}
 so that missing values are painted by the non-filled-in observations.{p_end}
{pstd}
A solution would be to create valid functions (but Stata allows users to invent programs, not functions, other than for {help egen:egen}).  
Stata's {help cond} function can be made to serve, but rapidly becomes {help validly##cox:too complex} for hand coding.{p_end}

{pstd}
{bf}validly{sf} takes logical or relational expressions, converts them to {help validly##RPN:RPN}, and generates,
 and then executes, the {help validly##function:nested {bf}cond{sf} functions}
(to a serious degree of complexity) to deliver the result which the expression requires.{p_end}

{marker RPN}{pstd}
{bf}RPN{sf}: Whereas standard mathematical notation writes operators between operands, invoking  {help operator##syntax:precedence rules} to determine sequence,
 and additionally using brackets to delimit scope,
{ul:R}eversed {ul:P}olish {ul:N}otation (RPN) places operators after operands, and requires no brackets or precedence rules.
 The additional charm of RPN is that, once we have re-formed the expression, we have a formulation which when 
read left-to-right is effectively being read in the correct evaluation sequence, so mechanical evaluation becomes straightforward to implement.  Thus, for example, consider: {p_end}
{pmore}
{bf}.generate y = (p&q)|!r{sf}{p_end}
{pstd}
The assigned expression becomes, in RPN:{p_end}
{pmore}
{bf}p   q   &   r   ! |{sf}{p_end}
{pstd}
Add one further conceptual element: an imagined "push-down/ pop-up" stack (think, {it}pace{sf} NRA, "rifle magazine"). 
 Then we can read along the RPN expression: placing operands, as we encounter them, into this push-down stack; applying operators, 
as we encounter them, to the top two cells of the stack (or the top cell, for unary operators), allowing the stack to pop-up.  
Add a last contribution: 
{help validly##function:valid functions} coding these operators. We define them {help validly##function:below}, but for the moment suppose the valid function for conjunction 
were "{bf}and({sf}p{bf},{sf}q{bf}){sf}", for negation were 
"{bf}not({sf}p{bf}){sf}", for disjunction were "{bf}or({sf}p{bf},{sf}q{bf}){sf}". Coding of {bf}(p&q)|!r{sf} into a valid function can now be done, entirely "mechanically"{p_end}

{pstd}
So, taking our example expression {hline 2} in RPN form: {bind:{bf}p   q   &   r   ! |{sf}} {hline 2} we put {bf}p{sf}, and then {bf}q{sf}, in the push-down stack, giving:
{p_end}
{pmore}
{c |}{space 2}{bf}q{sf}{space 2}{c |}{p_end}
{pmore}
{c |}{space 2}{bf}p{sf}{space 2}{c |}{p_end}
{pmore}
{c BLC}{hline 5}{c BRC}{p_end}
{pstd}
We then encounter the conjunction operator {bf}&{sf}, apply its valid function to the top two cells, and combine them, 
so the stack now contains only '{bf}and(p,q){sf}', in its top cell. 
We next, as we scan our RPN, encounter operand {bf}r{sf}, so add it to the push-down stack, giving:{p_end}
{pmore}
{c |}{space 4}{bf}r{sf}{space 5}{c |}{p_end}
{pmore}
{c |} {bf}and(p,q){sf} {c |}{p_end}
{pmore}
{c BLC}{hline 10}{c BRC}{p_end}
{pstd}
Next we encounter the negation operator {bf}!{sf}, so we apply it, modifying the top cell:
{p_end}
{pmore}
{c |}{space 2}{bf}not(r){sf}{space 2}{c |}{p_end}
{pmore}
{c |} {bf}and(p,q){sf} {c |}{p_end}
{pmore}
{c BLC}{hline 10}{c BRC}{p_end}
{pstd}
The final item is the disjunction operator.  Applying its valid function to the top two cells of the
 stack we would get {bind:'{bf}or({sf}cell2{bf},{sf} cell1{bf}){sf}',}
to be filled in by the cell values above. The two cells 
are now combined (by this function) into the one cell.
So we have exhausted our RPN expression, we have a one-cell stack, the top cell of which, filled-out, now reads:
{p_end}
{pmore}
{c |} {bf}or( and(p,q), not(r) ){sf} {c |}{p_end}
{pmore}
{c BLC}{hline 24}{c BRC}{p_end}
{pstd}
Using this, we have:{p_end}
{pmore}
{bf}.generate y = or(and(p,q),not(r)){sf}{p_end}
{pstd} and that nested function would give the right answer
 returning {bf}T{sf}, {bf}F{sf} or {ul:missing} as appropriate.{p_end}

{pstd}This was a very simple example, but the procedure can obviously be extended to expressions of any degree of complexity. 
Provided the individual functions code validly for {bf}T{sf}, {bf}F{sf} or {ul:missing} the composite nested result will code validly for {bf}T{sf}, {bf}F{sf} or {ul:missing}.
 It would just be a mite tedious (and error prone) to do this by hand.{p_end}

{pstd}
{bf}validly{sf} handles the translation from standard notation to RPN, and the generation of the resulting nested {bf}cond{sf} expressions {hline 2}
 as described in the next section.{p_end}
{pmore}
As use of the {help validly##detail:{ul:d}etail} option will reveal, the final executable code is rebarbative {hline 2} 
and computationally expensive for large data sets.  ({it}A Stata redefinition of Stata operators 
would make sense, and render 'validly' redundant {hline 2} 
see the {help validly##reference:article} cited below.{sf})

{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}


{marker function}{title:Functions}
{p 0 1 20}[{it}This Section (with the {help validly##method:{it}previous one}) provides a description of the backstage mechanics underlying the results.
 Those wishing simply to {ul:use} the utility might perhaps skim these sections, but should have no immediate need for careful perusal.
 The next useful-for-use section is {help validly##utility:{it}Utilities}, below{sf}]{p_end}

{pstd}
To code logical and relational operators we use the Stata function {help cond}, which tests an expression and returns one of three values depending 
upon whether the expression is {bf}T{sf}, {bf}F{sf} or {ul:missing}. 
The coding of these logical/relational operators through {bf}cond{sf} is the 'original' portion of {bf}validly{sf}.  The generation of the {help validly##RPN:RPN}, the precursor to applying this coding, is finicky in places,
but has been done many times before.{p_end}

{pstd}
Note that logical operators are completely subsumed by {bf}cond{sf}; relational operators appear embedded in calls to {bf}cond{sf}. 
The valid functional forms deployed in place of the given logical and relational operators are:{p_end}

{p 4 5 2}[In what follows, {bf}p{sf} and {bf}q{sf} may be variables, or algebraic expressions, or previously coded logical or relational expressions.]{p_end}

{marker negation}{phang}
{ul:Negation}:  {bf}!p{sf} is coded:{p_end}
{pmore}
{bf}cond(p,0,1,.){sf} {p_end}
{pmore2}
When option {help validly##extended:{ul:e}xtended} is set, the function becomes:{p_end}
{pmore2}
{bf}cond(p,0,1,p){sf}{p_end}
{pmore}{ul:Exception}: if this is the last-evaluated operator in a condition
 which is scheduled to be read as "missing->False" (see {help validly##condition:below}), THEN both codings simplify to:{p_end}
{pmore}{bf}cond(p,0,1){sf}{p_end}

{marker conjunction}{phang}
{ul:Conjunction}:  {bf}p&q{sf} is coded:{p_end}
{pmore}
{bf}cond(p,cond(q,1,0,.),0,cond(q,.,0))
{sf} {p_end}
{pmore2}
When option {help validly##extended:{ul:e}xtended} is set, the function becomes:{p_end}
{pmore2}
{bf}cond(p,cond(q,1,0,q),0,cond(q,p,0,cond(p==q,p,.))){sf}
{p_end}
{pmore}{ul:Exception}: if this is the last-evaluated operator in a condition
 which is scheduled to be read as "missing->False" (see {help validly##condition:below}), THEN both codings simplify to:{p_end}
{pmore}{bf}cond(p,cond(q,1,0,0),0,0){sf}{p_end}


{phang}
{ul:Disjunction}:  {bf}p|q{sf} is coded:{p_end}
{pmore}
{bf}cond(p,1,cond(q,1,0,.),cond(q,1,.,.)) {sf} {p_end}
{pmore2}
When option {help validly##extended:{ul:e}xtended} is set, the function becomes:{p_end}
{pmore2}
{bf}cond(p,1,cond(q,1,0,q),cond(q,1,p,cond(p==q,p,.))){sf}{p_end}
{pmore}{ul:Exception}: if this is the last-evaluated operator in a condition
 which is scheduled to be read as "missing->False" (see {help validly##condition:below}), THEN both codings simplify to:{p_end}
{pmore}{bf}cond(p,1,cond(q,1,0,0),cond(q,1,0,0)) {sf}{p_end}


{marker relation}{phang}
{ul:Relation}:  {bf}pRq{sf} (where {bf}R{sf} is one of: {bf}== != > >= < <={sf}) is coded:{p_end}
{pmore}
{bf} cond(p<.&q<.,pRq,.){sf} {p_end}
{pmore}
or, if the operands are of type string:{p_end}
{pmore}{bf} cond(p!=""&q!="",pRq,.){sf} {p_end}
{pmore2}
When option {help validly##extended:{ul:e}xtended} is set, the function becomes:{p_end}
{pmore2}{bf}cond(p<.,cond(q<.,pRq,q),cond(p==q|q<.,p,.)){sf}{p_end}
{pmore2}or, if the operands are of type string:{p_end}
{pmore2}{bf} cond(p!=""&q!="",pRq,{help validly##stringemv:.s}){sf} {p_end}
{pmore3}{bf}Note1{sf}: Though it would be more elegant to use {help f_missing:{bf}mi(){sf}}, in place of the explicit segregated missing-value checks, this is not viable, since in certain circumstances (such as relations of relations) 
that would generate {ul:nested} calls to {bf}mi(){sf}, which Stata disallows.{p_end}
{pmore3}{bf}Note2{sf}: {help validly##emvfn:Special provision} is made if an operand is an {ul:explicit} missing-value.{p_end}
{pmore}{ul:Exception}: if this is the last-evaluated operator in a condition
 which is scheduled to be read as "missing->False" (see {help validly##condition:below}), THEN these codings become:{p_end}
{pmore}{bf} cond(p<.&q<.,pRq,0){sf} {p_end}
{pmore}
or, if the operands are of type string:{p_end}
{pmore}{bf} cond(p!=""&q!="",pRq,0){sf} {p_end}


{pstd}
CONSIDER:{p_end}
{phang}{bf}.validly generate v =  exp{space 2}if expC{sf}{p_end}
{pstd}
which takes exp, and by recursive calls to the above functions as required, generates a valid functional form, in local macro {bf}`fn'{sf}, which can return {bf}T{sf} or {bf}F{sf}
 or {it}indeterminate{sf}.  It then does the same for {bf}expC{sf} into function {bf}`fnC'{sf}.
 Next it considers the condition: {p_end}

{marker condition}{phang}
{ul:Condition}: condition "{bf}if `fnC' {sf}" is, in terms of logic, coded, to set missing to False:{p_end}
{pmore}
{bf}if cond(`fnC',1,0,0){sf} {space 3}(expressed as{space 2}"{bf}if `f2_mF' {sf}" ){p_end}
{pmore}
to coerce Stata to include only when {ul:known}-true.{p_end}
{pmore}(The {it}actual{sf} coding may differ from the above since {bf}validly{sf}
 will, for compactness, modify the coding of any top-level
 relation incorporated in that condition, to achieve the exact same effect; these codings are detailed under {ul:Exception}, {help validly##negation:above}.){p_end}
{pmore2}
When option {help validly##widely:{ul:w}idely} is set, the expression remains:{p_end}
{pmore2}
{bf}if `fnC'{sf}{p_end}

{pstd}EXECUTION{p_end}
{pstd}{bf}validly{sf} executes the Stata command:{p_end}
{phang2}{bf}.generate v = `fn' if `fnC_mF'{sf}{p_end}
{pstd}The exact same logic applies to {bf}validly replace{sf}{p_end}
{pstd}When {help validly##widely:{ul:w}idely} is set, the command becomes:{p_end}
{phang2}{bf}.generate v = `fn' if `fnC'{sf}{p_end}

{pstd}IFNOT, ELSE, WHEN{p_end}
{pstd}If any of {help validly##ifnot:ifnot(expN)},
 {help validly##else:else(expE)}, {help validly##when:when(expW)}
 are specified the logic remains the same, though the computational mechanics are slightly different.
 The program takes the expressions {hline 2} {bf}expN, expE, expW{sf}  {hline 2} and turns them into valid functions {hline 2}
 {bf}`fnN', `fnE'{sf} {hline 2}  using the coding strategies  above.  Since {bf}expW{sf} is specifying a condition it is coded into {bf}`fnW_mF'{sf} (as above) in "missing->False" form
 (to ensure correct interpretation by Stata).  Function {bf}`fnC'{sf},  and function {bf}`fnW_mF'{sf} if needed, are then formed into workspace variables:{p_end}
{pmore}{bf}.generate zvarC = `fnC'{sf}{p_end}
{pmore}{bf}.generate zvarW = `fnW_mF'{sf}{space 2}// if needed{p_end}
{pstd}The workspace variables are introduced to avoid repeated calculation of CPU-intensive functions.   The program then, for an {bf}ifnot…else{sf} expression,  issues the raw Stata commands: {p_end}
{pmore}{bf}.generate v = `fn'{space 2}if zvarC==1 {sf}{p_end}
{pmore}{bf}.replace{space 2}v = `fnN' if zvarC==0{sf}{p_end}
{pmore}{bf}.replace{space 2}v = `fnE' if zvarC>=.{sf}{p_end}

{pstd}If the constraint {help validly##when:when(expW)} has been specified, each condition above is modified by a test for '{bf}expW True{sf}': {p_end}
{pmore}{bf}.replace{space 2}v = `fn'{space 2}if zvarC==1 & zvarW{sf}{p_end}
{pmore}{bf}.replace{space 2}v = `fnN' if zvarC==0 & zvarW{sf}{p_end}
{pmore}{bf}.replace{space 2}v = `fnE' if zvarC>=. & zvarW{sf}{p_end}
{pmore}(Had we stored `fnW' in zvarW these conditions would have been, for example: {p_end}
{pmore2}.replace  v = `fn'  if zvarC==1 & zvarW==1{p_end}
{p 9 9 2} but storing `fnW_mf' yields more compact code.){p_end}

{pmore2}A logically equivalent strategy for interpreting {bf}… if … ifnot … else{sf}, would be:{p_end}{pmore3}{bf}.replace|generate v = cond(`fnC',`fn',`fnN',`fnE') {sf}{p_end}
{pmore2}whilst {bf}if…ifnot{sf} in the absence of {bf}else{sf} would be{p_end}
{pmore3}{bf}.replace v = cond(`fnC',`fn',`fnN',v) {sf}{p_end}
{pmore2}and in the absence of both would be:{p_end}
{pmore3}{bf}.replace v = cond(`fnC',`fn',v,v) {sf}{p_end}
{pmore2}for {bf}generate{sf}, these embedded references to {bf}v{sf} would be replaced by
{it}sysmiss{sf}.{p_end}

{pmore2}This logically equivalent strategy, though conceptually neater (using the conditional strength of cond), does not make practical sense – the resulting single {bf}cond{sf}
 invoking four major functions would have a higher chance of tripping Stata's {help validly##toolong:size and complexity} constraints than
 would the adopted 'construct workspace variables' implementation. {p_end}


{pstd}
{ul:Notes}{p_end}

{marker sourcecode}{p 4 6 2}1 The hypothetical extended-missing values invoked by {help validly##source:source} are handled thusly:
 Option {help validly##extended:extended} is switched on (but, because of the next step, all extended-missing values currently in the data will nevertheless be overridden).
 Next, suppose {bf}p{sf} is the first-encountered variable,
 having missing values,
 in the {help validly##RPN:RPN} expansions; in the functions above it is logically as if it were replaced by {bf}cond(p,p,0,.a){sf}
 {hline 2} so ignoring its own extended-missing codes (if any) and treating all its missing values '{it}as if{sf}' having the {bf}.a{sf} code.
 Suppose {bf}r{sf} is the next-encountered variable with missing values; it is replaced by {bf}cond(r,r,0,.b){sf}, and so on
 (the code already allocated to {help validly##string:indeterminacy in string variables} is preserved).
 The functions are then executed as before.{p_end}
{marker rscode}{p 6 6 2}Under {help validly##source:source({bf}r{sf})}, the
 random splitting of {it}sysmiss{sf}
 (which otherwise flags a conflict of extended-missing values)
 is handled
 by replacing the last {help missing##overview:{it}sysmiss{sf}} symbol (the last argument) in
 the {help validly##conjunction:extended definitions} of conjunction, disjunction and relation (above) by:{p_end}
{pmore}{bf}cond(int(2*runiform()),p,q){sf}{p_end}
{p 6 6 2}which returns p-missing-value or q-missing value, each with .5 probability.{p_end}
{p 6 6 2}The text reads "logically as if it were replaced", since technically {bf}validly{sf} keeps track of the component parts of the 'sourced' variable,
 allowing various simplifications in the coding; for example, where {bf}p{sf} and {bf}q{sf} are variables, '{bf}p&q{sf}' under {bf}s(r){sf} yields:{p_end}
{pmore}{bf}cond(p,cond(q,1,0,.b),0,cond(q,.a,0,cond(int(2*runiform()),.a ,.b))){sf}{p_end}
{p 6 6 2}which, though certainly not short, is much shorter than straight substitution would yield.{p_end}

{marker impextif}{p 4 6 2}2 As {help validly##extended4:discussed},{space 2}{bf}validly generate … if … , extended{sf}{space 2}will retain
 extended "reasons" for missing values attributable
 to the indeterminacy of the conditional, thusly:
 The "workspace" strategy is invoked, {bf}`fn'{sf} is stored in {bf}zvar{sf}, and, after the first {bf}.generate{sf}, we have the  further command:{p_end}
{pmore}{bf}.replace  v = zvarC if zvarC>. & (zvar<. | zvar==zvarC){sf}{p_end}
{p 6 6 2}The complex condition is needed to ensure that "two different 'reasons' for missing" is recorded as {it}sysmiss{sf}
 and not arbitrarily assigned to one 'reason'. 
 (Under {help validly##source:source({bf}r{sf})} that {it}sysmiss{sf} is randomly split.) {p_end}

{marker emvfn}{p 4 6 2}3 {ul:Explicit} missing values in relations.  {help validly##emvexp:As discussed}, these are coded literally; with the exception of an equality ('{bf}=={sf}')
 involving an explicit {ul:extended}-missing value (e.g. '{bf}p==.x{sf}').
 That is coded:{p_end}
{pmore}{bf}cond(p==. ,. ,p==.x ){sf}{p_end}
{p 6 6 2}to capture a valid indeterminacy (though in 'missing->False' form we revert to literal '{bf}p==.x{sf}').{p_end}

{p 4 6 2}4 {ul:Efficiency}: In the conjunction and disjunction coding above, when {bf}q{sf} is known to have values 1,0,{it}sysmiss{sf} only, the argument 'cond(q,1,0,.)'
 in the second or third position, simplifies to 'q'.{p_end}
{p 6 6 2}When option {help validly##extended:{ul:e}xtended} is set, and {bf}q{sf} is
 known to have values 1,0 or {it}generic{sf} missing, the argument 'cond(q,1,0,q)' in conjunction and disjunction simplifies to 'q'.{p_end}
{p 6 6 2}The program examines incoming variables, and keeps track of expressions, to allow such substitutions.{p_end}

{marker globwarn}{p 4 6 2}5 Further on efficiency: if neither operand contains missing values,
 the functions reduce to their plain Stata forms.
 If one operand has no missing values, other simplifications are possible.
 For example, in {ul:Conjunction} above, if {bf}p{sf} has no missing values,
 the code can be simplified to {bf}cond(p,cond(q,1,0,.),0){sf}{p_end}
{p 6 6 2}The program examines incoming variables, and keeps track of expressions, to allow such substitutions.{p_end}
{p 6 6 2}{err}But note, in relation to {bf}validly global{sf}{txt},
 that the resulting macros optimised are only useable if the pattern of no-missing is retained;
 if applied to data with fresh missing values the macros will yield {bf}invalid{sf} results;
 {bf}validly{sf} issues a reminder (the optimisation {help validly##nutility:can be disabled}).  

{marker compact}{p 4 6 2}6 Yet more on efficiency: since {bf}&{sf} and {bf}|{sf} are commutative, and {bf}pR1q{sf} can be readily rewritten as {bf}qR2p{sf},
 at each particular coding there is a choice of whether to code for, say, {bf}p&q{sf} or {bf}q&p{sf}, depending on the current contents of '{bf}p{sf}' and '{bf}q{sf}'.
 The program chooses, to minimise the number of calls to {bf}cond{sf}, and, if two formulations are equivalent, minimises bracket depth
 (and reports any move from the default sequence by talking of "valid {ul:optimised} function" when {help validly##detail:{ul:d}etail} is set).
 (Should you wish more readily to "see" the RPN->cond coding this optimisation {help validly##cutility:can be switched off}.){p_end}

{p 4 6 2}7 And a final note on efficiency: The above functions (particularly the more complex) can be hard coded in a variety of different ways.
  For example, we could also code {ul:Relation}/extended {help validly##relation:above},  as, variously:{p_end}
{p 6 6 2}{bf}cond(p>=.|q>=.,cond(p>=.&q>=.,cond(p==q,p,.),cond(p,q,q,p)),pRq){sf}{space 2}{ul:or}{p_end}
{p 6 6 2}{bf}cond(p<.,cond(q<.,pRq,q),cond(q<.,p,cond(p==q,p,.))){sf}{p_end}
{p 6 6 2}In deciding which to deploy, since these are for machine generation, 'concise' has been rated above 'transparent'.{p_end}

{p 4 6 2}8 {help validly##detail:{ul:d}etail} as an option, will display the {bf}RPN{sf} and the
 nested {bf}cond{sf} functions, and provide helpful commentary on what is being done. {p_end}

{p 4 6 2}9 The commands {bf}validly generate/replace/assert{sf} 
also, whatever the option, return the RPN code in macro {help validly##saved:r(RPN)}; the variant {bf}validly {it}conditional_command{sf} always returns the full constructed condition in {help validly##saved:r(ifcond)}. {p_end}

{marker functionn7}{p 4 6 2}10 {ul:Extended}-missing within {ul:algebra} (see earlier {help validly##extendedn2:comment}):
 this is a footnote, not about {bf}validly{sf}, but about a related topic.{p_end}
{p 6 6 2}You could hand-code any individual dyadic {ul:algebraic}
  operator to retain extended-missing values by using the {ul:Relation}/extended coding {help validly##relation:above},
 but now replacing relation {bf}R{sf} by the appropriate {ul:algebraic} operator.{p_end}
{p 10 10 2}Further, a single variable function, {bf}fn(p){sf}, could be handled by
 {bf}cond(p<.,fn(p),p){sf} or equivalently {bf}cond(mi(p),p,fn(p)){sf} (note that the test is here on 'p', not 'fn(p)',
 since we seek to isolate "undefined because argument-undefined" in contrast to, say, "undefined because log-of-negative").
 Unary minus could be seen as a unary function, giving {bf}cond(p<.,-p,p){sf},
 or alternatively  {bf}cond(p,-p,0,p){sf}.{p_end}
{p 6 6 2}The only feasible way to apply this to
 even moderately complex algebra would be to sequentially construct temporary variables for each individual operation.{p_end}
{p 6 6 2}So, for example, {bind:'.gen v = {bf}(p+q)^r{sf}'} becomes:{p_end}
{pmore2}{bf}.gen pq =  cond( p<.,cond(q<., p+q,q),cond( p==q|q<., p,.)){p_end}
{pmore2}.gen{space 2}v =  cond(pq<.,cond(r<.,pq^r,r),cond(pq==r|r<.,pq,.)){sf}{p_end}
{p 6 6 2}The more complex, the more tedious.{p_end}
{p 6 6 2}If much of this were desired, there would be merit,
 for binary operators, in splitting that function into two macros, thus:{p_end}
{pmore2}{bf}.local m1{space 2}cond(\`v1'<.,cond(\`v2'<.,\`v1'{p_end}
{pmore2}.local m2{space 2}\`v2',\`v2'),cond(\`v1'==\`v2'|\`v2'<.,\`v1',.)){sf}{p_end}
{p 6 6 2}(where the backslash inhibits expansion, at point of definition, of the embedded macros)
 and then filling-in and invoking the two main macros repeatedly. Thus the above would become:{p_end}
{pmore2}{bf}.local v1 p{sf}{space 2}// set embedded vars{p_end}
{pmore2}{bf}.local v2 q{p_end}
{pmore2}.gen pq = `m1' + `m2'{sf}{space 2}// macros with algebraic binary operator{p_end}
{pmore2}{bf}.local v1 pq{sf}{space 2}// set embedded vars{p_end}
{pmore2}{bf}.local v2 r{p_end}
{pmore2}.gen{space 2}v = `m1' ^ `m2'{sf}{space 2}// macros with algebraic binary operator{p_end}
{p 6 6 2}Still tedious, but can be repeated (stepwise, from binary operators, to build complex expressions) with less chance of error.{p_end}


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker utility}{title:Utility to generate test variables}

{pstd}
To allow ready exploration of the implementation of logical and relational expressions, there is a utility:{p_end}

         {cmd:.validly gen_test_vars  {help newvarlist:newvarlist} [, {opt e:xtended} {opt n:onind} ]}

{pstd}
which generates between two and {bf}ten{sf} fresh indicator variables, forming, for these variables, all possible patterns involving the three values: {bf}1{sf}, {bf}0{sf} and {help missing##overview:{it}sysmiss{sf}} {hline 3}
 so there are{space 2}{bf}var^3{sf}{space 2}patterns. 
Whence, rather than checking your coding by searching across your dataset for patterns of values, you could generate a compact 
bespoke dataset, with similar variable names, embodying all possible patterns, and check coding on that.{p_end}

{pstd}If {opt e:xtended} is requested, the patterns extend across five values: {bf}1{sf}, {bf}0{sf}, {it}sysmiss{sf}, {bf}.a{sf} and {bf}.b{sf} (to allow exploration of transmission of extended-missing values).
 But note that there are now{space 2}{bf}var^5{sf}{space 2}patterns, so number of variables is restricted to {bf}six{sf}.
 (This command does not attend to whether {help validly##eutility:set_extended} is on, only to its own explicit {opt e:xtended} option.){p_end}

{pstd}If {opt n:onind} is requested, the variables constructed are {ul:not} indicator variables; observations
 which on the default setting would have value '{bf}1{sf}' on a variable, now carry random integers in the range 1-100.
 Given the way Stata {help validly##second:interprets non-zero as True}, this gives the exact-same pattern of True, False,
 missing as the default setting. It is included to allow checking that {bf}validly{sf} and/or your coding works correctly on
 non-indicator, as well as indicator, variables.{p_end}

{pstd}A trivial example:{p_end}
         {cmd:.vy gen_test_vars  p q}
{pstd}would give the nine possible patterns for {bf}p{sf} and {bf}q{sf} displayed in the first two columns of the expository table {help validly##table:above}.{p_end}

{pstd}This utility is also used to generate the test data, containing all possible combinations of values, on which the program's {help validly##validation:validation file} runs.{p_end}

{marker minor}{title:Minor Utilities}

{marker macrotoggle}{pstd}Teetering on the edge of Stata programming propriety, {bf}validly{sf} uses the global macro {bf}$validlyDefault{sf}
 to store the following default settings.
 They are thus retained, across calls to {bf}validly{sf}, within the one Stata {ul:session}.{p_end}
{p 8 9 2}(Checks are
 made that this specific global has not, implausibly, been used by some other process; if it has, user is given choice of action.){p_end}

{marker eutility}{phang}{bf}validly set_extended [on|off]{sf}{space 2}explicitly
 sets {help validly##extended:extended} switch to {bf}on{sf} or {bf}off{sf}. Default is {bf}off{sf};
 bear in mind the {help validly##extended1:costs} of setting this to ON.
 When the default is {bf}on{sf}, commands (such as the generation of a string variable) for which the
 {help validly##extended:extended} option would be inappropriate will nevertheless continue to work
 (the setting is suspended for the duration of the command).{p_end}

{marker dutility}{phang}{bf}validly set_detail [on|off]{sf}{space 4}explicitly sets
 {help validly##detail:detail} to {bf}on{sf} or {bf}off{sf} (default is {bf}off{sf}).
 If your preferred mode is detailed reporting, it makes sense to set
 this to 'on' at the start a Stata session, rather than repeatedly specifying option {help validly##detail:{ul:d}etail}.{p_end}

{marker remutility}{phang}{bf}validly set_reminder [on|off]{sf}{space 2}controls the switch for reminders
 when {help validly##precedence:unfamiliar operator precedence} in unbracketed
 expressions overrides an 'intuitive' left-to-right reading
(default is {bf}on{sf}).{p_end}

{marker cutility}{phang}{bf}validly set_compact [on|off]{sf}{space 3}sets
 {help validly##compact:one optimisation strategy}
 to {bf}on{sf} or {bf}off{sf} (default is {bf}on{sf}).{p_end}

{marker nutility}{phang}{bf}validly set_nomiss [on|off]{sf}{space 3}sets
 {help validly##globwarn:optimisation for variables with no missing values}
 to {bf}on{sf} or {bf}off{sf} (default is {bf}on{sf}).{p_end}

{marker rutility}{phang}{bf}validly set_impute [on|off]{sf}{space 4}explicitly
 sets {help validly##eximpute:the ability to impute replace} to {bf}on{sf} or {bf}off{sf} (default is
 {bf}on{sf}).
 The risk of confusion is small; but some may feel more secure with this turned off.{p_end}

{marker stringemv}{phang}{bf}validly set_nullstring{space 2}.x{sf}{space 4}
where {bf}.x{sf} is a specific extended-missing value,
 overrides the default {bf}.s{sf} value used when, with extended set, a {help validly##string:null-string is encountered} in a relation.
 (Note that {bf}validly{sf} ensures that whatever value you choose does not interfere with the {help validly##sourcecode:coding of option source}.){p_end}

{marker setdef}{phang}{bf}validly set_defaults{sf}{space 11}returns all of the above
 switches to their default settings.{p_end}

{marker validation}{title:Validation File}

{pstd}The program has been extensively tested in use, but a more formal test file:{p_end}
{pmore2}{bf}validate_validly.do{sf}{p_end}
{pstd}accompanies this package.  If loaded and run, this {bf}.do{sf} file will, with commentary, exercise {bf}validly{sf},
 on a data set built by {help validly##utility:gen_test_vars}.
 The data contains all possible patterns of values across a group of variables, so constructs can be exhaustively tested.
 For example, each logical or relational operator is first validated in a bivariate setting.
 These verified bivariate relations can then be used, via intermediate variables, to construct verified complex expressions.
 The displayed commentary as the file is run is reasonably informative on the tests being performed,
 but since the commands (being many, looping) are run in {help quietly:quiet} mode,
 for detailed specification the content of the {bf}.do{sf} file should be directly inspected.
 The file is supplied to give some indication of the extent of testing, and so reassurance of robustness.{p_end}    


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker restrictions}{title:Two restrictions}

{phang}
{it}no arithmetic allowed on the {ul:results} of logical/relational expressions{sf}{p_end} 
{pmore}Because of the 
method it uses for parsing (on logical and relational operators), {bf}validly{sf}
 refuses to handle expressions which 
attempt arithmetic upon the results of logical and relational expressions.  So, for example, {bf}(p>q)+4{sf} fails (with advice).  {p_end}
{pmore}
      These would be substantively odd expressions (though admittedly definable, it is a mite odd
 to do arithmetic on things which are True or False), so in real life this restriction is unlikely to constitute
 a substantial impediment to progress.  If however you have an
 ineluctable need, the strategy is to {bf}validly generate{sf} variables corresponding
 to the logical or relational expressions, and then carry out arithmetic on these constructed variables. Alternatively, 
for {ul:logical} expressions, use {bf}validly 
global{sf} to encode into valid functions, embed the macro(s) appropriately 
and reissue the command (the macro route does not work for {ul:relational} expressions 
because of the next restriction).
  {p_end}

{marker restrict2}{phang}
{it}logical/relational expressions {ul:within} functions are not parsed{sf}{p_end}

{pmore}This, for which it is also difficult to think of plausible instances, is again a consequence of the approach that {bf}validly{sf}
 takes to parsing; thus '{bf}max(p&q,r&s)==1{sf}' will be rejected (with advice).{p_end}
{pmore}
The workaround is to {bf}validly generate{sf} variables corresponding
 to the logical or relational expressions, and reissue the command with these variables, in place of the expressions, within functions.  Alternatively, 
for {ul:logical} expressions, use {bf}validly 
global{sf} to encode into valid functions, embed the macro(s) appropriately 
and reissue the command (the macro route does not work for relational expressions 
since their coding, see {help validly##relation:above}, itself involves relational expressions).{p_end}
{pmore2}Example, consider a rejected:{p_end}
{pmore3}.validly y = max(p&q,r) if s|!r{p_end}
{pmore2}Instead we could do:{p_end}
{pmore3}.validly gen y1 = p&q{p_end}
{pmore3}.validly y = max(y1,r) if s|!r{p_end}
{pmore2}or, equivalently, we could do:{p_end}
{pmore3}.validly global y1  p&q{p_end}
{pmore3}.validly y = max($y1,r) if s|!r{p_end}
{pmore2}BUT note that {bf}max{sf} itself has further problems with missing-values - see the footnote {help validly##max:above}.{p_end}


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker errors}{title:Error messages}

{pstd}
{err}{bf}invalid syntax{sf}{txt} {hline 2} and related error messages {hline 2} probably does point to some error you have made, though you should check for misspellings, invalid variables, 
invalid options, as well as "invalid {ul:syntax}", more conventionally understood
 {hline 3} as with any syntax checker, 
the message may not always point to the precipitating error.{p_end}
{pmore}Suggestion if the error continues to
 elude you: sometimes Stata's syntax checker if fed the plain command (stripped of "validly", and of course validly's options) 
may be more explicit.{p_end}

{marker errorW}{pmore}Note: {bf}validly{sf} first looks for {bf}generate/replace/assert/global{sf},
 next it looks for a syntactically correct {help validly##eximpute:imputed generate/replace},
 and a {help validly##wrap:wrapped} command is assumed when these are not found. 
 This, in particular, means that an intended imputed {bf}generate/replace{sf} which is syntactically misspecified
 can lead to an error report appearing to mutter about an invalid {err}perceived wrapped{txt} command.

{pstd} No syntax checker can itself check that what you have written 
(especially where {help exp} is at all complex) matches your intent.  So. It is always good practice after any moderately complex 
 construction to {bf}list{sf} the constructing 
variables and the result variable across an appropriate small sample of observations (using {bf}in{sf}, or perhaps {bf}if{sf}) 
and check that your intent has been instantiated.
 The included utility to {help validly##utility:generate test variables} may simplify the task of checking across all-possible patterns of values.
{p_end}

{marker precedence}{pmore}
Be alert to the ways in which operator precedence may interpret an expression as you did not intend.  Stata follows
 {help operator##syntax:standard precedence rules} 
amongst arithmetic, relational and logical operators;{bf} validly{sf} does the same.  Whilst most of us "naturally" ({it}i.e.{sf} through early habituation) read   {bf}4+2*3{sf}
 as {bf}4+(2*3){sf}, our intuition that {bind:'{bf}p|q & r{sf}'} is properly read as {bind:'{bf}p | (q&r){sf}'} may well be weaker.
 Or, consider:{p_end}
{pmore2}{bf}p&q == r&s{sf}{p_end}
{pmore}Stata, and {bf}validly{sf} also, again following standard precedence rules, will interpret this as: {p_end}
{pmore2}{bf}p & (q==r) & s{sf}{p_end}
{pmore}which may well {ul:not} match the writer's intention. So, when dealing with logical and relational operators,
 the advice is "{bf}use brackets to clarify intention{sf}"; explicit brackets always 
dominate implicit precedence rules.  Excess of brackets does not do  harm; absence may.{p_end}
{marker crutch}{pmore2}As a minor crutch, {bf}validly{sf} issues a reminder
 if either of the less-familiar precedence rules ("relations take precedence over logical operators",
{space 2}"conjunction takes precedence over disjunction") has, in the absence of brackets, overridden an
 'intuitive' left{bf}->{sf}right reading of an expression.  Thus, the expression 
 '{bf}p|q&r{sf}' attracts comment but the equivalent '{bf}q&r|p{sf}' does not,
 and nor does '{bf}p|(q&r){sf}'.
 The {help validly##RPN:RPN} versions (revealed through use of
 {help validly##detail:{ul:d}etail}, or {help validly##saved:by typing plain {bf}vy{sf}})
 show unambiguously how your expressions have been understood.
 It should be stressed that {bf}validly{sf}'s parsing is here identical to plain Stata (or indeed any mathematical program); it just adds some monitoring.
 If you find such nannying annoying it can be {help validly##remutility:suppressed} for the duration of a session{p_end}

{pstd}The most insidious errors are those where a program merrily, without complaining, executes a command, but the effect of that command is not what was intended.  
This is why (as the {help validly##discussion:discussion} partly explains) Stata's default conventions are unsatisfactory.  The untutored user may mistakenly write:{p_end}
{phang2}.generate pvq = p|q{p_end}
{pstd}But, more worryingly, the mid-range user, alerted to the need to "attend to missing values", may write:{p_end}
{phang2}.generate pvq = p|q if !mi(p,q){p_end}
{pstd}but be equally {help validly##check:mistaken} – and, more dangerously, nothing will alert such a user to the error. Which is the case for writing, accurately and, importantly, transparently:{p_end}
{phang2}{bf}.validly generate pvq = p|q{sf}  {p_end}

{marker toolong}{pstd}{err}{bf}expression too long{sf}{txt} or, more rarely, {err}{bf}too many macros{sf}{txt}
 may be encountered when {help validly##extended:{ul:e}xtended} is set and the raw expressions are very complex; it indicates that the generating functions
 are too complex or nested for Stata.  The solution is
 {bf}EITHER{sf} to decide that keeping track of extended-missing values was not so important after all and drop the  {help validly##extended:{ul:e}xtended} option
 {bf}OR{sf} to use {bf}validly{sf} to generate variables corresponding to subexpressions.  For example: {p_end}
{pmore}{bf}.validly generate v = !((p&q)|(p|q))&(r|!s)&t , extended{sf}{p_end}
{pstd}will be rejected.  But we can do (remembering to use the {bf}e{sf} option):{p_end}
{pmore}{bf}.validly generate paq = p&q, e{sf}{p_end}
{pmore}{bf}.validly generate pvq = p|q, e{sf}{p_end}
{pstd}at which point:{p_end}
{pmore}{bf}.validly generate v = !((paq)|(pvq))&(r|!s)&t , e{sf}{p_end}
{pstd}will execute quite happily. The problem arises only for unusually complex expressions where you are trying to preserve {ul:extended}-missing values
 (remember that {help validly##source:{ul:s}ource} also invokes this mode, though more parsimonious in its coding).{p_end}

{marker colour}{pstd}
{err}error coloured text{txt} sometimes is used (not extensively) in the output from {bf}validly{sf} to flag, not errors, but
 things-you-{err}should{txt} notice (this because that colour is the one most likely to be consistently noticeable across varying colour-schemes).
 An example being text noting when the {help validly##syntax:implied} action is set to {err}replace{txt}.
 The output from {bf}validly{sf} may also contain some {help validly##colour:text coloured as links} {hline 2} these are indeed links to portions of this help file.
 (Parenthetically, this help file is most legible if you {ul:avoid} the one standard  colour scheme {hline 2} edit/preferences/ viewer_colours/{bf}{ul:studio}{sf} {hline 2} which {ul:underlines} links.){p_end}


{marker validation}{phang}
{err}Error messages{txt} should all be ascribable to your syntax errors 
(widely understood). Should they appear not to be, contact the {help validly##contact:author} with some urgency (please!);
 the program has been extensively tested {hline 2} and
 a {help validly##validation:validation file} accompanies this package.{p_end} 


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{marker saved}{title:Saved results}
{p2colset 8 22 22 0}
{pstd}The local macros discussed in {help validly##detail:detail} reporting mode (such as `fnC') are of course internal to {bf}validly{sf}.
 But all invocations of {bf}validly{sf} return the following macros:{p_end}

{p2col:{bf}r(RPN){sf}}which contains the generated {help validly##RPN:RPN}.{p_end} 
{p2col:{bf}r(precedence){sf}}which contains flags, for each expression, reporting whether {help validly##crutch:precedence has been invoked}.{p_end}

{marker dispsave}{p2col:[{it}{ul:to display}{sf}: }The information in both these macros can be displayed by reissuing the command {bf}.vy{sf} with no arguments. Thus suppose we had issued:{p_end}
{p 26 26 2}{bf}.vy v = p&q == r&s{sf}{p_end}
{p 21 21 2}which would yield a reminder about '==' taking precedence over '&'. Suppose we were puzzled. The command:{p_end}
{p 26 26 2}{bf}.vy{sf}{p_end}
{p 21 21 2}would display the RPN, confirming that, correctly, this has been read as '(p&q)==(r&s)'.
  Targeted use of argument-free {bf}.vy{sf} may give most of the utility of {help validly##detail:{ul:d}etail} with less chatter.{p_end}

{marker savecond}{pstd}Additionally, {help validly##wrap:wrapped commands} return the following macro:{p_end}

{p2col:{bf}r(ifcond){sf}}which carries the condition deployed in validly running the wrapped command, and so gives,
 in executable '{bf}cond{sf}' form,
 the generated valid conditional function;
 this can be extracted and retained by, say:{p_end}
{p 26 26 2}{bf}.global filter{space 2}`r(ifcond)'{sf}{p_end}
{p 21 21 2}and this global macro, {bf}$filter{sf}, could then be used to repeat the condition
 (though {err}not {ul:within}{txt} a fresh call to {bf}validly{sf}).
 (If the condition has been specifically optimised to match the absence of missing data in some variables, then, to avoid future error, {bf}r(ifcond){sf} is WITHELD.)
 {help validly##wrapnote:Click here} for an example of correct macro use.{p_end}

{pstd}These wrapped commands also, if appropriate, return their own stored:{p_end}

{p2col:{help r():{bf}r(){sf}} or {help e():{bf}e(){sf}}}these saved
 results are defined exactly as they would be were the wrapped command issued 'raw'.
 Should the wrapped command be an estimation command, then the command line issued by {bf}validly{sf}
 will be stored in {bf}e(cmdline){sf}{p_end}

{pstd}{ul:Displaying} saved results:  For {bf}r(RPN){sf} the best strategy (as described above) is to type {bf}vy{sf} (or {bf}validly{sf})
 with no arguments {hline 2} this displays the stored information elegantly.
 Other arguments can be displayed directly. So, for example:{p_end}
{pmore}{bf}.di{space 2}e(cmdline){sf}{p_end}
{pstd}gives the command line issued by validly for a wrapped command.{p_end}
{pmore}Should {bf}e(cmdline){sf} happen to be too long to display simply, the "quoted-macro" form:{p_end}
{pmore2}{bf}.di{space 2}`"`e(cmdline)'"'{sf}{p_end}
{pmore}will always work. If the command itself contains no  quotation marks, the {help quotes:compound double quotes}
 {bf}`"xxx"'{sf} can be replaced by the simple, {bf}"xxx"{sf}, form.{p_end}

{pstd}Users should {ul:ignore} the global macro {help validly##macrotoggle:$validlyDefault} which is retained by {bf}validly{sf} as a 'memory' for settings between calls,
 within one Stata session.{p_end}


{marker reference}{title:References}

{psee}
Article:  {it:Missing values in relational and logical expressions in Stata; a problem and two solutions.}{p_end}

{marker cox}{psee}Kantor, D & Cox, N J (2005) Depending on conditions: a tutorial on the
cond() function.  {browse "http://www.stata-journal.com/sjpdf.html?articlenum=pr0016":{it}The Stata Journal{sf}, {bf}5{sf}, p413-420}

{marker contact}{title:Author's email:}
{pstd}
Comment, suggestions, welcomed; an error report would be {help validly##validation:unwelcome} {hline 2} but shall be attended to.

{pmore}
{bf}kenneth.macdonald  @ nuffield.ox.ac.uk{sf}

{title:Also see}

{psee}
Online:  {manhelp generate D}  {manhelp operators U}  {manhelp missing U}
{p_end}


{help validly##index:{space 4}{c TLC}{hline}}
{help validly##index:{space 4}{c |}{right: goto {bf}Index{sf}{space 2}}}
{help validly##index:{space 4}{c BLC}{hline}}

{right: help {it}for{sf} {bf}validly{sf} v3.2.1 13/8/13}
