{smcl}
{* *! version 1.0.1 28May2015 Malte Kaukal}{...}
{vieweralsosee "[R] help" "help help "}
{vieweralsosee "[R] help" "help help "}{...}
{viewerjumpto "Syntax" "findsysmis##syntax"}{...}
{viewerjumpto "Description" "findsysmis##description"}{...}
{viewerjumpto "Returned Results" "findsysmis##results"}{...}
{title:Title}

{phang}
{bf:findsysmis} {hline 2} Finding system missing values in a list of variables

{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmd:findsysmis} {varlist} {ifin}  [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt str:include}} includes string variables {p_end}
{synopt:{opt l:ist}} lists variables instead of creating tables {p_end}
{synopt:{opt qui:etly}} suppresses variables in output {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}

{marker description}{...}
{title:Description}

{pstd}
{cmd:findsysmis} crawls through a list of variables named in varlist and checks every variable for system and extended missing values. By default it is limited to {ul:numeric} variables only. String variables
can be included by using the option {opt strinclude}. Variables with any kind of missing values are presented in the output and stored in macros. Accordingly, variables can be used in further operations.

{pstd}
Missing values have to be system/extended missing values like {input:. , .a, .b} etc. or {input:""} in string variables.

{pstd}
{opt list} and {opt quitely} can be used to create an output suiting best users' needs.

{marker results}{...}
{title:Returned results}

{pstd} Macros:

{p2col 5 20 20 4 :{cmd:r(var)}} list of numeric and string variables with missing values {p_end}
{p2col 5 20 20 4 :{cmd:r(numvar)}} list of numeric variables with missing values {p_end}
{p2col 5 20 20 4 :{cmd:r(strvar)}} list of string variables with missing values {p_end}


{title:Author}
{pstd}
Malte Kaukal, Hessen State Statistical Office {p_end}
{pstd}
malte.kaukal@gmx.de

{title:Acknowledgments}
{pstd}
I would like to acknowledge the support of my colleagues at GESIS which lead to the creation of findsysmis. 
