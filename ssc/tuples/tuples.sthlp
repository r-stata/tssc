{smcl}
{* 16may2020}{...}
{cmd:help tuples}
{hline}

{title:Title}

{phang}
{cmd:tuples} {hline 2} Select tuples from a list


{title:Syntax}

{p 8 16 2}
{cmd:tuples} 
{help tuples##list:{it:list}}
[ {cmd:,} {it:options} ]


{marker list}{...}
{p 4 10 2}
where {it:list}, if it is a {varlist}, is {help unab:unabbreviated}. If 
items in {it:list} contain spaces, these items must be enclosed in double 
quotes. 

{synoptset 24 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{syntab:List}
{synopt:{opt asis}}treat {it:list} as is; do not unabbreviate
{p_end}
{synopt:{opt var:list}}treat {it:list} as {it:varlist}; issue an 
error if it is not
{p_end}

{syntab:Selection}
{synopt:{opt max(#)}}specify maximum number of items in a tuple
{p_end}
{synopt:{opt min(#)}}specify minimum number of items in a tuple
{p_end}
{synopt:{opt cond:itionals(string)}}eliminate tuples according 
to specified conditions
{p_end}

{syntab:Reporting}
{synopt:{opt di:splay}}show created tuples
{p_end}

{syntab:Method}
{synopt:{opt ncr}}produce tuples using a variation of algorithm AS 88 
(Gentleman 1975)
{p_end}
{synopt:{opt cvp}}produce tuples using a method based on Mata
{help [M-5] cvpermute():permutation} function; seldom used
{p_end}
{synopt:{opt kronecker}}produce tuples using a method based on 
{help [M-2] op_kronecker:Kronecker} products; seldom used
{p_end}
{synopt:{opt naive}}produce tuples using a "naive" method; seldom 
used
{p_end}
{synopt:{opt nopy:thon}}do not use {help python:Python}; seldom used
{p_end}
{synopt:{opt nom:ata}}do not use {help mata:Mata}; seldom used
{p_end}
{synopt:{opt nos:ort}}do not sort tuples; seldom used
{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:tuples} produces a set of {help macro:local macros}, each containing 
a list of the items defining a tuple selected from a given list. 

{pstd}
By default the set of created macros is complete, other than the tuple 
containing no selections. By default the given list is tried as a variable 
list, but if it is not a variable list any other kind of list is acceptable,
except that no other kind of expansion takes place.

{pstd}
More details are discussed in {help tuples##remarks:Remarks}.


{title:Options} 

{dlgtab:List}

{phang}
{opt asis} specifies that the list supplied should be treated as is, 
and thus not {help unab:unabbreviated} as a {help varlist}. {opt asis} 
may not be combined with {opt varlist}.

{phang}
{opt varlist} specifies that the list supplied should be a {help varlist}, 
so that it is an error if the list is not in fact a varlist. {opt varlist} 
may not be combined with {opt asis}.  

{dlgtab:Selection}

{phang}
{opt max(#)} specifies a maximum value for the number of items in a 
tuple. Default {it:#} is n, i.e., the number of items in the supplied 
list. Also see {help tuples##methods:Methods to produce tuples}.

{phang}{opt min(#)} specifies a minimum value for the number of items 
in a tuple. Default {it:#} is {cmd:1}. Also see 
{help tuples##methods:Methods to produce tuples}.

{phang}
{cmd:conditionals()} specifies conditional statements to eliminate 
possible tuples according to the rule(s) specified. {cmd:conditionals()} 
accepts the logicals {cmd:&} for intersections or "and" statements, 
{cmd:|} for unions or "or" statements, {cmd:()} for binding statements 
and giving statements priority, and {cmd:!} for complements or "not" 
statements.  

{p 8 8 2}
Other than the foregoing logicals, {cmd:conditionals()} only
accepts positional arguments.  That is, to refer to the first element of
the list, use "1"; to refer to the second element, use "2"; and so 
forth.  Inapplicable positional arguments (e.g., referring to "4" in a list
of size 3) will produce an error.  

{p 8 8 2}
Spaces are used to separate conditional statements with
{cmd:conditionals()}.  A single statement must, then, contain no spaces.  

{p 8 8 2}
For an example, see {help tuples##conditionals:Using conditionals()}.

{p 8 8 2}
{cmd:conditionals()} may not be combined with {cmd:nomata} or {opt naive}.

{dlgtab:Reporting}

{phang}
{cmd:display} specifies that tuples should be displayed.

{dlgtab:Method}

{phang}
{opt ncr} produces tuples using a variation of algorithm AS 88 
(Gentleman 1975). {opt ncr} may not be combined with {opt nomata}, 
{opt naive}, {opt cvp}, or {opt kronecker}. See
{help tuples##methods:Methods to produce tuples}.

{phang}
{opt cvp} produces tuples using a method based on permutations (see 
{help [M-5] cvpermute():cvpermute()}). {cmd:cvp} may not be combined 
with {opt nomata}, {opt naive}, {opt kronecker}, or {opt ncr}. See 
{help tuples##methods:Methods to produce tuples}.

{phang}
{opt kronecker} produces tuples using a method based on staggered 
{help [M-2] op_kronecker:Kronecker} products. {cmd:kronecker} may not be 
combined with {opt nomata}, {opt naive}, {opt cvp}, or {opt ncr}. See
{help tuples##methods:Methods to produce tuples}.

{phang}
{opt naive} produces tuples using a "naive" method, selecting one 
tuple at a time. {opt naive} requires that {opt nosort} is also 
specified. {opt naive} may not be combined with {opt conditionals()}, 
{opt nomata}, {opt cvp}, {opt kronecker}, or {opt ncr}. {opt naive} 
is seldom used. 

{phang}
{opt nopython} does not call Python to produce the tuples. This option 
is implied for Stata versions prior to 16 (but greater than 9.2) and for 
users without a {help python:python script}-able version of Python on 
their machine. 

{phang}
{opt nomata} produces tuples outside of the {help mata:Mata} 
environment. This option implements the default for Stata versions prior 
to version 10. {opt nomata} may not be combined with {opt conditionals()}, 
{opt naive}, {opt kronecker}, or {opt cvp}. {opt nomata} is slow and it is 
seldom used. Note that {opt nomata} must be combined with {opt nopython} to 
invoke this behavior for users who have Stata versions 16 or higher and a 
{help python:python script}-able version of Python.

{phang}
{opt nosort} is for use with the default method, {opt nopython}, and {opt naive}, and 
it produces tuples in a different sort order. By default, {cmd:tuples} 
first produces all singletons, then all distinct pairs, and so on. The {opt nosort} 
option produces tuples in a different sort order but it produces them more quickly. 
{opt nosort} may not be used with {opt ncr}, {opt cvp}, or {opt kronecker}. 
In general, {opt nosort} is seldom used. 


{marker remarks}{...}
{title:Remarks} 

{pstd}
Remarks are presented under the following headings

{phang2}{help tuples##intro:Introduction}{p_end}
{phang2}{help tuples##conditionals:Using conditionals()}{p_end}
{phang2}{help tuples##method:Methods to produce tuples}{p_end}

{marker:intro}{...}
{title:Introduction}

{pstd} 
Given a list of n items, {cmd:tuples} by default produces 2^n - 1 macros, 
named {cmd:tuple1} upwards, which are all possible distinct singletons 
(each individual item); all possible distinct pairs; and so forth. Thus 
given {cmd:frog toad newt}, local macros {cmd:tuple1} through {cmd:tuple7} 
contain 

    {cmd:newt}
    {cmd:toad} 
    {cmd:frog} 
    {cmd:toad newt} 
    {cmd:frog newt} 
    {cmd:frog toad} 
    {cmd:frog toad newt} 

{pstd}
Here n = 3, 2^n - 1 = 7 = {cmd:comb(3,1) + comb(3,2) + comb(3,3)}. 

{pstd} 
Note that no tuple is the empty tuple with no selections. Users wishing
to cycle over a set of tuples including the empty tuple can exploit the
fact that the local macro {cmd:tuple0} is undefined, and so empty
(unless the user has previously defined it explicitly), so that
{cmd:tuple0} can be invoked with the correct result. 

{pstd} 
Remember that the number of possible macros will explode with the number
of items supplied. For example, if 10 items are supplied, there will be
1,023 macros. The number of macros created by {cmd:tuples} is returned
in local macro {cmd:ntuples}. 

{pstd}
As of January 2011, {cmd:tuples} is declared to supersede Nicholas
J. Cox's {cmd:selectvars}. 

{marker conditionals}{...}
{title:Using conditionals()}

{pstd}
{cmd:conditionals()} is useful for eliminating potential tuples with 
combinations of the items from the list based on logical statements.

{pstd}
What is most important to remember about the use of {cmd:conditionals()} 
is that the conditional statements apply across {it:all} tuples.  Thus, 
{cmd:conditionals(1)} will force {it:all} tuples to contain the first 
element in the list.

{pstd}
For example, {cmd:conditionals()} can be used to eliminate combinations of 
variables to model in an estimation command that contain products without 
first-order (linear) terms (see {help tuples##example2:Example 2} and
{help tuples##example4:Example 4} below). To do so, consider what is to be 
done.  Imagine 2 variables and their product: {cmd:A}, {cmd:B}, and 
{cmd:A#B} (using {help fvvarlist:factor variable notation}).  Assume they 
are listed as

{pstd}
{cmd: A B A#B}

{pstd}
in the list offered to {cmd:tuples}. You need to make sure that {cmd:A#B} 
never appears without both {cmd:A} and {cmd:B}.  The challenge is then 
translating that language into a logical statement. 

{pstd}
Begin with an easy component: 
"{res}...{cmd:A#B} never appears without both {cmd:A} and {cmd:B}{txt}" 
contains 
"{res}{cmd:A} and {cmd:B}{txt}" 
which can be represented as
"{res}{cmd:A}&{cmd:B}{txt}" 
or {c -} because {cmd:conditionals()} requires a
positional statement {c -} "{res}1&2{txt}".  Thus, you are left with
"{res}...{cmd:A#B} never appears without both 1&2{txt}".

{pstd}
In addition, 
"{res}...{cmd:A#B} never appears without both 1&2{txt}" 
contains the term "{res}both{txt}".  The "{res}both{txt}"
implies that "{res}1&2{txt}" is a unit and, therefore, should be put in
parentheses, leading to 
"{res}...{cmd:A#B} never appears without (1&2){txt}".  
Next, consider the word "{res}without{txt}" which can be
represented as a "{res}and not{txt}" statement.  Including the 
"{res}and not{txt}" statement,  
"{res}...{cmd:A#B} never appears &!(1&2)){txt}".

{pstd}
Finally, the most tricky component: you need to represent the
fact that {cmd:A#B} and not both {cmd:A} and {cmd:B} cannot be allowed.
Hence, the language "{res}appears{txt}" can be translated first into a
statement binding the positional statement for {cmd:A#B} to the existing
logical statement, producing "{res}...never 3&!(1&2){txt}".  The last
component is simpler, as the "{res}never{txt}" is clearly a
"{res}not{txt}" statement.  Because that "{res}never{txt}" refers to the
notion of {cmd:A#B} appearing with {cmd:A} and {cmd:B}, the
statement must be bound in parentheses, then negated.  Incorporating the
last component results in "{res}!(3&!(1&2)){txt}". Note that there are no 
spaces in the statement.

{pstd}
In most cases, eliminating specific sets of combinations will
require the skillful use of the "{res}!{txt}" operator.

{marker methods}{...}
{title:Methods to produce tuples}

{pstd}
As of {cmd:tuples} version 4.0, the default method for computing the tuples 
is to call 
{help python:Python}'s {browse "https://docs.python.org/3/library/itertools.html":itertools} 
module with the {res:combinations()} method using the {res:Stata function interface} 
to import the tuples as local macros. To invoke the Python-based method, the 
user must have Stata version 16 or greater and an installation of Python usable by 
{help python:python script}. The Python-based method tends to require the least memory 
and tends to execute the fastest for long lists. Note that {cmd:tuples} has only been 
tested in Python versions 3.6 through 3.8 and, if Python has not been initalized prior 
to use of {cmd:tuples}, the default method will intitialize the Python environment 
configured in {cmd:python query}.

{pstd}
In the remainder of this section, we describe other methods to produce 
tuples. If you are running Stata 16 and have Python installed, these methods 
are of little interest. We recommend using the Python-based implementation 
whenever possible.

{pstd}
The {cmd:tuples} default Mata-based method creates an n x (2^n-1) indicator matrix to produce the 
tuples. This is the fastest method for short lists but it also requires most memory. For long 
lists, the default method might require more memory than your operating system is willing 
to provide. In these cases, {cmd:tuples} will exit with an error message and return code 
{search r(3900):r(3900);} If you need to use one of the Mata-based/{opt nopython} methods 
and have long lists or run out of memory, switch to one of the other methods described below.

{phang2}
{opt ncr} requires less memory than the default {opt nopython} method and is 
fast(er), especially for long lists and if {opt min()} and/or {opt max()} are 
specified. The only situation in which {cmd:ncr} is slow is when 
{opt conditionals()} is specified.

{phang2}
{opt cvp} requires less memory than the default {opt nopython} method if 
(and only if) {opt min()} and/or {opt max()} are specified. For long lists, 
if the fraction of tuples selected with {opt min()} and/or {opt max()} is 
small (< 0.01), and if there are many items in a tuple, {opt cvp} tends to 
produce tuples more quickly than the default {opt nopython} method. 

{phang2}
{opt kronecker} requires less memory than the default {opt nopython} method 
if (and only if) {opt min()} and/or {opt max()} are specified. For long lists, 
if the fraction of tuples selected with {opt min()} and/or {opt max()} is small 
(< 0.01), and if there are few items in a tuple, {opt kronecker} tends to 
produce tuples more quickly than the default {opt nopython} method.

{pstd}
To summarize, {cmd:tuples} has several methods to produce the tuples but they are slower 
than the default methods in many cases. We recommend the default {help python:Python}-based method 
in all situations where Python is available.  For Stata versions less than 16 or when Python is 
not available, we summarize the recommended "pure Mata" methods in the table below.

{col 13}items{col 38}fraction{col 49}items{col 60}recommended
{col 13}in {it:list}{col 22}{opt conditionals()}{col 38}of tuples{col 49}per tuple{col 60}method
{col 13}{hline 63}
{col 13}few{col 22}yes/no{col 38}any{col 49}any{col 60}{it:default} {opt nopython}
{col 13}many{col 22}no{col 38}any{col 49}any{col 60}{cmd:ncr}
{col 13}many{col 22}yes{col 38}> 0.01{col 49}any{col 60}{it:default} {opt nopython}
{col 13}many{col 22}yes{col 38}< 0.01{col 49}many{col 60}{cmd:cvp}
{col 13}many{col 22}yes{col 38}< 0.01{col 49}few{col 60}{cmd:kronecker}
{col 13}{hline 63}

{pstd}
When you think of few items in a list, think n<17. Use

{phang2}
{cmd:. mata : rowsum(comb(}{it:n}{cmd:, (}{it:min}{cmd:..}{it:max}{cmd:)))/(2^}{it:n}{cmd:-1)}
{p_end}

{pstd}
to determine the fraction of tuples selected.


{title:Examples}

{pstd}
{cmd:Example 1}

{pstd}
Obtain all possible tuples from a list 

{phang2}{cmd:. tuples a b c d, asis}{p_end}

{marker example2}{...}
{pstd}
{cmd:Example 2}

{pstd}
Obtain tuples where two words ("the" and "car") appear in all tuples while 
two synonyms ("big" and "large") are not to appear together in any tuple 

{phang2}{cmd:. tuples the big large red fast car, asis conditionals(1&6 !(2&3))}

{pstd}
{cmd:Example 3}

{pstd}
Use {cmd:tuples} to collect and display {cmd:e(r2)} following 
{cmd:regress}

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. generate rsq = .}{p_end}
{phang2}{cmd:. generate predictors = ""}{p_end}
{phang2}{cmd:. tuples headroom trunk length displacement}{p_end}
{phang2}{cmd:. quietly forvalues i = 1/`ntuples' {c -(}}{p_end}
{phang2}{cmd:. {space 8}regress mpg `tuple`i''}{p_end}
{phang2}{cmd:. {space 8}replace rsq = e(r2) in `i'}{p_end}
{phang2}{cmd:. {space 8}replace predictors = "`tuple`i''" in `i'}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. generate p = wordcount(predictors) if predictors != ""}{p_end}
{phang2}{cmd:. sort p rsq}{p_end}
{phang2}{cmd:. list predictors rsq in 1/`ntuples'}
{p_end}

{marker example4}{...}
{pstd}
{cmd:Example 4}

{pstd}
Extension of Example 3, with AIC and an interaction using
{cmd:conditionals()}

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. generate aic = .}{p_end}
{phang2}{cmd:. generate predictors = ""}{p_end}
{phang2}{cmd:. tuples headroom trunk length displacement c.trunk#c.length, conditionals(!(5&!(2&3)))}{p_end}
{phang2}{cmd:. quietly forvalues i = 1/`ntuples' {c -(}}{p_end}
{phang2}{cmd:. {space 8}regress mpg `tuple`i''}{p_end}
{phang2}{cmd:. {space 8}estat ic}{p_end}
{phang2}{cmd:. {space 8}mata: st_store(`i', "aic",  st_matrix("r(S)")[1,5])}{p_end}
{phang2}{cmd:. {space 8}replace predictors = "`tuple`i''" in `i'}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. generate p = wordcount(predictors) if predictors != ""}{p_end}
{phang2}{cmd:. sort p aic}{p_end}
{phang2}{cmd:. list predictors aic in 1/`ntuples'}{p_end}


{title:Acknowledgments} 

{pstd}
Sebastian Orbe reported a problem which led to a bug fix. Volodymyr 
Vovchack suggested including the {cmd:min()} option. E-mail communication 
with William Buchanan and a discussion with John Mullahy on 
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1526657-using-tuples-to-generate-combinations":Statalist}
led to the addition of the {opt ncr} option; Mike Lacy pointed to 
algorithm AS 88 (Gentleman 1975) and shared code on which the {opt ncr} 
implementation is based. Thanks also to Regina Chua for assistance in testing 
{cmd:tuples} v 4.0. Dejin Xie reported two bugs in.


{title:References}

{pstd}
Gentleman, J. F. 1975. Algorithm AS 88: Generation of All NCR Combinations 
by Simulating Nested Fortran DO Loops. Journal of the Royal Statistical 
Society. Series C (Applied Statistics), 24(3), pp. 374--376.


{title:Authors}

{pstd}
Joseph N. Luchman, Fors Marsh Group LLC{break}
jluchman@forsmarshgroup.com

{pstd}
Daniel Klein, INCHER-Kassel, Universit{c a:}t Kassel{break}
klein.daniel.81@gmail.com

{pstd}
Nicholas J. Cox, Durham University{break} 
n.j.cox@durham.ac.uk


{title:Also see}

{psee}
Online: {helpb foreach}, {helpb mata}, {helpb python}
{p_end}

