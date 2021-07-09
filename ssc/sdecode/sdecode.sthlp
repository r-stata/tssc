{smcl}
{hline}
help for {cmd:sdecode} and {cmd:msdecode} {right:(Roger Newson)}
{hline}


{title:Decode string variable into numeric using formats for unlabelled values}

{p 8 21 2}
{cmd:sdecode} {varname} {ifin} ,
 [ {cmdab:g:enerate}{cmd:(}{it:{help newvar}}{cmd:)} | {cmd:replace} ]
 [ {cmdab:maxl:ength}{cmd:(}{it:#}{cmd:)} {cmdab:fo:rmat}{cmd:(}{it:{help format:format_spec}}{cmd:)}
   {cmdab:labo:nly} {cmdab:m:issing}
   {cmdab:ftr:im} {cmdab:xmls:ub} {cmdab:es:ub(}{it:esubstitution_rule} [, {cmdab:elz:ero}]{cmd:)}
   {cmdab:pr:efix}{cmd:(}{it:string}{cmd:)} {cmdab:su:ffix}{cmd:(}{it:string}{cmd:)}
  ]

{p 8 21 2}
{cmd:msdecode} {varlist} {ifin} , {cmdab:g:enerate}{cmd:(}{it:{help newvar}}{cmd:)}
 [ {cmd:replace} {cmdab:d:elimiters}{cmd:(}{it:string_list}{cmd:)}
   {cmdab:maxl:ength}{cmd:(}{it:#}{cmd:)} {cmdab:fo:rmat}{cmd:(}{it:{help format:format_spec}}{cmd:)}
   {cmdab:labo:nly} {cmdab:m:issing}
   {cmdab:ftr:im} {cmdab:xmls:ub} {cmdab:es:ub(}{it:esubstitution_rule} [, {cmdab:elz:ero}]{cmd:)}
   {cmdab:pr:efix}{cmd:(}{it:string}{cmd:)} {cmdab:su:ffix}{cmd:(}{it:string}{cmd:)}
 ]

{pstd}
where {it:format_spec} is either a format or a string variable name,
and {it:esubstitution_rule} is any one of

{p 8 21 2}
{cmd:none} | {cmd:x10} | {cmd:rtfsuper} | {cmd:texsuper} | {cmd:htmlsuper} | {cmd:smclsuper}


{title:Description}

{pstd}
{cmd:sdecode} ("super {helpb decode}") creates an output string variable with values from
the input numeric variable {varname}, using {help label:labels} if present and {help format:formats} otherwise.
The output string variable may either replace the input numeric variable or be generated
as a new variable named {it:{help newvar}}.
Unlike {helpb decode}, {cmd:sdecode} creates an output string
variable containing the values of the input variable as output by the {helpb tabulate} command
and other Stata output, instead of decoding all unlabelled input values to missing.
{cmd:sdecode} is especially useful if a numeric variable has value labels for some values
but not for others.
{cmd:msdecode} is a multivariate version of {cmd:sdecode},
which inputs a list of numeric or string variables and (optionally) a list of delimiters,
and creates a single string variable,
containing the concatenated values of all the input variables,
decoded if necessary and separated by the delimiters if provided.

{title:Options}

{phang}
For {cmd:sdecode}, either {cmd:generate()} or {cmd:replace} must be specified,
but both options may not be specified at the same time.
For {cmd:msdecode}, {cmd:generate} must be specified, but {cmd:replace} is optional.

{phang}
{cmd:generate(}{it:{help newvar}}{cmd:)} specifies the name of a new output string variable to be
created.

{phang}
{cmd:replace}, with {cmd:sdecode}, specifies that the output string variable will replace the input
numeric variable, and have the same name, the same {help order:position in the data set},
and the same {help label:variable label} and {help char:characteristics} if present.
With {cmd:msdecode},
{cmd:replace} specifies that any existing variable with the same name as the {cmd:generate()} variable will be replaced.

{phang}
{cmd:delimiters(}{it:string_list}{cmd:)} ({cmd:msdecode} only) specifies a list of delimiters,
to be inserted between the decoded values of successive variables in the input {varlist}
when the output variable is generated.
If the number of elements provided is less than the number of input variables minus 1,
then the last element is repeated as often as necessary.
If the {cmd:delimiters()} option is not provided,
then the empty string {cmd:""} is assumed, and repeated as often as necessary.

{phang}
{cmd:maxlength(}{it:#}{cmd:)} is optional.
It specifies how many characters of the {help label:value label} to retain.
{it:#} must be an integer between 1 and the {help limits:maximum string variable length},
which is stored in the {help creturn:system parameter} {hi:c(maxstrvarlen)}.
If unset, then {cmd:maxlength()} is set to the {help limits:maximum string variable length}.

{phang}
{cmd:format(}{it:{help format:format_spec}}{cmd:)} is optional.
It specifies the {help format:format} (or formats) used for decoding unlabelled values of the input numeric variable.
It may be either a {help format} (to be used for all unlabelled values), or the name of a string format variable
(in which case each observation with an unlabelled value is decoded using the format stored in the
string format variable for that observation).
If {cmd:format()} is not specified, then {cmd:sdecode} and {cmd:msdecode}
use the format associated with the input numeric variable.

{phang}
{cmd:labonly} is optional.
It specifies that only labelled values for the input numeric variable
will be decoded to nonmissing string values in the output string variable, and that unlabelled values
will be decoded to a missing string value, as with {helpb decode}.
If {cmd:labonly} is not specified,
then all nonmissing values of the input numeric variable will be decoded to nonmissing string values,
except for values in observations excluded by the {helpb if} and {helpb in} qualifiers,
which are decoded to a missing string value.

{phang}
{cmd:missing} is optional.
It specifies that {help missing:missing values} in the input numeric variable
will be decoded (using formats) to non-missing formatted string values (such as {hi:"."}).
If {cmd:missing} is absent, then missing values in the input numeric variable are decoded
to missing string values.

{phang}
{cmd:ftrim} is optional.
It specifies that values of the output string variable produced using a {help format}
will be trimmed to remove spaces on the left and on the right.

{phang}
{cmd:xmlsub} is optional.
It specifies that, in the decoded string output variable,
the substrings {cmd:"&"}, {cmd:"<"} and {cmd:">"} will be replaced throughout with the XML entity references
{cmd:"&amp;"}, {cmd:"&lt;"} and {cmd:"&gt;"}, respectively.
This is useful if the decoded string output variable is intended for output
to a table in a document in XHTML, or in other XML-based languages.
This substitution, if specified, is performed before any substitution specified by the {cmd:esub()} option.

{phang}
{cmd:esub(}{it:esubstitution_rule} [, {cmd:elzero}]{cmd:)} is optional.
It specifies a rule for substitution of exponents
in decoded values produced using the {help format} specified by the {cmd:format()} option,
to make them more suitable for output to TeX, HTML, RTF, or other word processor documents.
The presence of exponents is normally indicated, in Stata formatted values,
by the presence of substrings {cmd:"e-"} or {cmd:"e+"}.
These substrings may indicate that the substring to the left is a mantissa,
and that the substring to the right is the absolute value of an exponent,
conventionally presented in documents as a superscript.
The possible values of the {it:esubstitution_rule} are
{cmd:none}, {cmd:x10}, {cmd:rtfsuper}, {cmd:texsuper}, {cmd:htmlsuper} and {cmd:smclsuper}.
These rules are documented below under
{helpb sdecode##esub_rules:{title:Substitution rules for the esub() option}}.
The suboption {cmd:elzero}, if present, indicates that, if the exponent contains leading zeros,
then those leading zeros will be retained in the final formatted value.
If the {cmd:esub()} option is specified without the {cmd:elzero} suboption,
then such leading zeros are removed.

{phang}
{cmd:prefix(}{it:string}{cmd:)} is optional.
It specifies a prefix string, to be added to the left of the generated string variable.

{phang}
{cmd:suffix(}{it:string}{cmd:)} is optional.
It specifies a suffix string, to be added to the right of the generated string variable.


{marker esub_rules}{...}
{title:Substitution rules for the {cmd:esub()} option}

{pstd}
If the user specifies an {cmd:esub()} option,
then {cmd:sdecode} and {cmd:msdecode} perform exponent substitution
on those values of the output string variable which were produced using the {help format} specified
by the {cmd:format()} option.
This is done after any trimming specified by the {cmd:ftrim} option
and/or any XML entity substitution specified by the {cmd:xmlsub} option,
and before any addition of prefixes and suffixes specified by the {cmd:prefix()} and {cmd:suffix()} options.

{pstd}
The first step is to locate the first appearance, in the output string value,
of the substring {cmd:"e-"} or the substring {cmd:"e+"},
whichever appears first.
This substring (if it exists) is known as the {it:<esign>}.
The substring to the left is known as the {it:<mantissa>},
and the substring to the right is known as the {it:<exponent>}.
An output string value therefore has the syntax

{pstd}
{it:<mantissa>} | {it:<mantissa><esign><exponent>}

{pstd}
where <mantissa> is a string without any embedded {cmd:"e-"} or {cmd:"e+"} substrings.
If {cmd:elzero} is not specified, 
then the next step is to attempt to remove any leading zeros from the {it:<exponent>},
using a method that works if the {it:<exponent>} is an unsigned integer.

{pstd}
If an {it:<esign>} is present, then the next step is to replace the {it:<esign>}
with an infix string {it:<eminfix>} if the {it:<esign>} is {cmd:"e-"},
or with an infix string {it:<epinfix>} if the {it:<esign>} is {cmd:"e+"},
and to append a string {it:<esuffix>} to the end of the {it:<exponent>}.
The {it:esubstitution_rule} is defined by the values of the {it:<eminfix>}, {it:<epinfix>} and {it:<esuffix>} strings.
The revised output string should then have the syntax

{pstd}
{it:<mantissa>} | {it:<mantissa><eminfix><exponent><esuffix>} | {it:<mantissa><epinfix><exponent><esuffix>}

{pstd}
The values for the different {it:esubstitution_rule}s are as follows:

{hline}
{it:esubstitution_rule}  {it:<eminfix>}       {it:<epinfix>}      {it:<esuffix>}  {it:Description}
{cmd:none}                {cmd:"e-"}            {cmd:"e+"}           {cmd:""}         No substitition
{cmd:x10}                 {cmd:"x10-"}          {cmd:"x10"}          {cmd:""}         To be superscripted manually
{cmd:rtfsuper}            {cmd:"x10{c -(}\super -"}  {cmd:"x10{c -(}\super "}  {cmd:"{c )-}"}        RTF superscript
{cmd:texsuper}            {cmd:"\times 10^{c -(}-"}  {cmd:"\times 10^{c -(}"}  {cmd:"{c )-}"}        TeX superscript
{cmd:htmlsuper}           {cmd:"x10<sup>-"}     {cmd:"x10<sup>"}     {cmd:"</sup>"}   HTML superscript
{cmd:smclsuper}           {cmd:"x10{c -(}sup:-"}     {cmd:"x10{c -(}sup:"}     {cmd:"{c )-}"}        SMCL superscript
{hline}

{pstd}
Note that, if the user specifies {cmd:esub(none,elzero)},
then the result is equivalent to specifying no {cmd:esub()} option.
SMCL superscripts are documented in the online help for {help graph_text:Stata graphics text}.


{title:Remarks}

{pstd}
{cmd:sdecode} is a separate package from {helpb sencode} ("super {helpb encode}"),
which is also downloadable from {help ssc:SSC}.
However, the two packages both have the alternative
{cmd:generate()} and {cmd:replace} options.
They are complementary to the {helpb destring}
command and the {helpb tostring} command,
which are part of official Stata.
{helpb tostring} and {helpb destring}
convert numeric values to and from their formatted string values, respectively, but
they do not use {help label:value labels}, and they do contain precautionary features to prevent the loss of information.
{cmd:sdecode} and {helpb sencode}, on the other hand, do use {help label:value labels}, and
allow the possibility that the mapping from numeric values to string values can be many-to-one.

{pstd}
More about the use of {cmd:sdecode} with {helpb sencode} and other conversion packages
can be found in
{help sdecode##newson_2013:Newson (2013)}.
For more about the use of {cmd:sdecode} with {helpb listtab} and other {help ssc:SSC} packages to create tables,
see {help sdecode##newson_2012:Newson (2012)}.


{title:Examples}

{p 8 12 2}{cmd:. sdecode price, replace}{p_end}

{p 8 12 2}{cmd:. sdecode foreign, replace labonly}{p_end}

{p 8 12 2}{cmd:. sdecode foreign, gene(origin)}{p_end}

{p 8 12 2}{cmd:. sdecode foreign, gene(origin) maxlen(3)}{p_end}

{p 8 12 2}{cmd:. replace foreign=_n/_N if mod(_n,2)}{p_end}
{p 8 12 2}{cmd:. sdecode foreign, gene(origin1)}{p_end}
{p 8 12 2}{cmd:. sdecode foreign, gene(origin2) format(%8.4f)}{p_end}

{p 8 12 2}{cmd:. sdecode rep78, gene(srep78) missing}{p_end}

{p 8 12 2}{cmd:. sdecode price, gene(sprice) prefix($)}{p_end}

{p 8 12 2}{cmd:. sdecode weight, gene(sweight) suffix(" lb")}{p_end}

{p 8 12 2}{cmd:. sdecode weight, gene(esweight) format(%8.1e) esub(htmlsuper)}{p_end}

{p 8 12 2}{cmd:. msdecode foreign weight price, gene(fwp) delim(", " "lb for $")}{p_end}

{p 8 12 2}{cmd:. msdecode foreign weight price, gene(fwp) replace delim(" car weighing " " lb and costing ") suffix(" dollars")}{p_end}


{title:Author}

{pstd}
Roger Newson, Imperial College London, UK.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}


{title:References}

{marker newson_2013}{...}
{phang}
Newson, R. B.
2013.
Creating factor variables in resultssets and other datasets.
Presented at {browse "http://ideas.repec.org/p/boc/usug13/01.html":the 19th United Kingdom Stata Users' Group Meeting, 12–13 September, 2013}.

{marker newson_2012}{...}
{phang}
Newson, R. B.  2012.
From resultssets to resultstables in Stata.
{it:The Stata Journal} 12(2): 191-213.
Download from {browse "http://www.stata-journal.com/article.html?article=st0254":{it:The Stata Journal} website}.


{title:Also see}


{psee}
Manual:  {manlink D compress}, {manlink D destring}, {manlink D encode}, {manlink D format}, {manlink D functions}, {manlink D generate}, {manlink D label}
{p_end}

{psee}
{space 2}Help:  {manhelp compress D}, {manhelp destring D}, {manhelp encode D}, {manhelp decode D}, {manhelp format D}, {manhelp functions D}, {manhelp generate D}, {manhelp label D}
{break}{helpb sencode}, {helpb listtab} if installed
{p_end}
