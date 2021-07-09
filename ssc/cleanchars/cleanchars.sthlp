{smcl}
{* *! version 1.0  2013-10-08}{...}
{cmd:help cleanchars} (vs1.0: 2013-10-08)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:cleanchars} {hline 2} To replace specific characters or strings in variable names and/or variable labels and/or string variable values and/or value label names and levels with stated characters/strings (using 1-1 or m-1 match). 
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt cleanchars} {cmd:,} {opt in}({it:string}) [{opt out}({it:string}) vname vlab vval values lower]


{title:Description}

{pstd}
{cmd:cleanchars} 
is a program that helps out with replacing unwanted/inconvenient characters/strings in the currently active dataset. Entities searched through, and where changes could be applied, are (i) variable names (ii) variable labels 
(iii) string variable values (iv) value label names and corresponding level-labels. Moreover, an option directly putting all variable names into lower case is available. 
Note: Changes related to variable names depend on the user-written command {cmd: renvars} (Weesie & Cox, 2005). {p_end}


{title:Options}

{pstd}
{opt in}({it:string}) Defines the characters/strings to be replaced. Several characters/strings might be stated, where the i:th will then be replaced by the i:th one stated in {bf: out} (if not the number of strings in {bf: out} 
is 1 or 0 where all symbols/strings will be replaced by either the single stated symbol/string or by the empty string, respectively). This option is mandatory.

{pstd}
{opt out}({it:string}) Defines the characters/strings to replace the symbols/strings stated in {bf: in}. Several characters/strings might be stated but the corresponding number must either equal the 
corresponding number in {bf:in}, where the i:th item will replace the i:th one stated in {bf: in}, or 1 or 0 where the single symbol/string and empty string will replace all items in {bf: in}, respectively. 
If the option is omitted, such an empty string is assumed.  

{pstd}
{opt vname} States that variable names should be affected. 

{pstd}
{opt vlab} States that variable labels should be affected. 

{pstd}
{opt vval} States that string variable values should be affected. 

{pstd}
{opt values} States that value label names as well as corresponding level-labels should be affected. 

{pstd}
{opt lower} States that all variable names should be changed, if needed, to solely using lower case characters.

{pstd}
Note! If none of the options {bf:vname}, {bf:vlab}, {bf:vval} and {bf:values} are stated then it is assumed that all of them are of interest (i.e. hence then all the four options are marked and used).


{title:Examples}

    {hline}

{pstd} 1. Replace all occurrences of Danish letter 'æ' with 'ae' in variable names.{p_end}
{phang2}{cmd:. cleanchars , in("æ") out("ae") vname}{p_end}

    {hline}

{pstd} 2. Replace all occurrences of Swedish letter 'ö' with 'oe' in variable labels.{p_end}
{phang2}{cmd:. cleanchars , in("ö") out("oe") vlab}{p_end}

    {hline}

{pstd} 3. Replace all occurrences of Nordic letter 'å' with 'aa' in string variable values.{p_end}
{phang2}{cmd:. cleanchars , in("å") out("aa") vval}{p_end}

    {hline}

{pstd} 4. Replace all occurrences of chars 'å' and 'æ' with 'a' in value label names and in corresponding label-levels.{p_end}
{phang2}{cmd:. cleanchars , in("å æ") out("a") values}{p_end}

    {hline}

{pstd} 5. Replace all occurrences of string '¤#?' with the empty string in all ways possible (in names of variables, labels. etc.).{p_end}
{phang2}{cmd:. cleanchars , in("¤#?") vname vlab vval values}{p_end}

    {hline}

{pstd} 6. Replace all occurrences of characters 'å', 'æ', 'Å', 'Æ', with 'a' in all ways possible (in names of variables, labels. etc.), where also all variable 
names are changed to - if needed - using lower case characters only. Note that leaving out all of the options {bf: vname}, {bf: vlab}, {bf: vval} and {bf: values} 
is equal to stating all of them (working as a default in this way).{p_end} 
{phang2}{cmd:. cleanchars , in("å æ Å Æ") out("a") lower}{p_end}


    {hline}

{title:Requires}

{pstd} Stata 10. Moreover, the command depends on the user written function {cmd: renvars} (Weesie & Cox, 2005).



{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help renvars} (user-written; SSC),  
{p_end}
{psee}
{space 24}                       {help describe}, {help codebook}, {help labelbook}, {help label}, {help lookfor}, {help rename}, {help extended_fcn}.
{p_end}


