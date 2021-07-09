{smcl}
{* *! version 0.3, January 18, 2012 @ 19:10:00 DE}{...}
{cmd:help dta2sav}
{hline}

{title:Title}

{pstd}
{cmd:dta2sav} - Create SPSS syntax to convert Stata data into SPSS data
{p_end}

{title:Syntax}
{phang}

    {cmd:dta2sav} [{varlist}] {ifin} [, {it:options}]

{p2colset 5 17 17 2}{...}
{p2col:{it:option}}description{p_end}
{p2line}
{p2col:{hi:NODots}}supress dots showing progress{p_end}
{p2col:{hi:Verbose}}show MISSING VALUES commands of SPSS syntax in listing{p_end}
{p2col:{hi:name({it:name})}}specify (path and) name of .dts and .sps files{p_end}
{p2col:{hi:replace}}replace existing .dts (Stata data) and .sps (SPSS syntax) files{p_end}

{title:Description}

{pstd} {cmd:dta2sav} creates SPSS syntax and a Stata data file to convert Stata data into
SPSS data. Extended missing values (see: {help missing}) which are labeled will be encoded
into "numeric" values which will be defined as missing by using SPSS syntax commands
created by {cmd:dta2sav}. This allows to preserve labels of missing values as defined in
Stata for subsequent use in SPSS. {cmd:dta2sav} saves data in memory into a file in Stata
9/Stata 10 format with the extension .dts. The respective SPSS commands will be saved into
an SPSS syntax file with the extension .sps. {varlist} and {ifin} can be used to restrict
data to be imported by SPSS.

{pstd} The rule to encode the extended missing values into "numeric" values is easier to
understand by an example than by an abstract description: Imagine that the maximum valid
value is a one digit integer, say 1, and there are two extended missing values .a and .b
which are labeled. In this case .a will be encoded into 9, the maximum possible one-digit
integer. .b will be encoded into a next smaller integer, in this case 8. If, however, the
maximum valid value is 998 and there are three extended missing values .a, .b, and .d
which are labeled (e.g. "not known", "not applicable", and "> 998"), there are not enough
three-digits integers greater than 998. Therefore, .a will be encoded into 9999, .b into
9998, and .d into 9997 and SPSS syntax will be created that defines the values 9999, 9998,
and 9997 as missing (after the task {cmd:dta2sav} is completed, the original data will be
restored in memory).

{pstd} In general, {cmd:dta2sav} will determine the number of digits D of the maximum valid
integer and, if possible, will encode the first extended missing value (normally .a) (if
it is labeled) into the maximum integer which can be displayed using D digits. Subsequent
extended missing values corresponding to the remaining extended missings will be (if
labeled) encoded into consecutively descending integers. If D is too small to encode all
extended missings that way, the digits D to display the encoded "numeric" missings
will be increased by one.

{pstd} If no path and filename is specified by using the option {cmd:name({it:name})}, the
name of the Stata data file in memory will be used for the filenames of the Stata data file
with the extension .dts and the SPSS syntax file with the extension .sps. If not specified,
the path will be extracted from the path of the Stata data file in memory.

{title:Example}

{phang}{cmd:. sysuse auto}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. recode rep78 (.=.a), gen(rep78m)}  // note: no label of .a{p_end}
{phang}{cmd:. recode price (10000/max = .a ">= 10,000"), gen(pricem)}{p_end}
{phang}{cmd:. label define origin .a "n.k." .b "n.a." .d "ambiguous", modify}{p_end}
{phang}{cmd:. }{p_end}
{phang}{cmd:. dta2sav, nod v name(`"`c(pwd)'/foo"')} // use working directory{p_end}

{pstd} Depending on the paths actually used, the result window will show the following
listing of SPSS commands saved into the file foo.sps:

{res}SPSS syntax:
{txt}  {c TLC}{hline 74}{c TRC}
  {c |} {res}/* ------------------------------------------------------------------ */ {txt}{c |}
  {c |} {res}/* 1978 Automobile Data */                                               {txt}{c |}
  {c |} {res}/* Filename: 'C:\Program Files (x86)\Stata12\ado\base/a/auto.dta' */     {txt}{c |}
  {c |} {res}/* File changed since 13 Apr 2011 17:45 */                               {txt}{c |}
  {c |} {res}/* Cases: 74 (exported 74), variables: 14 (exported 14) */               {txt}{c |}
  {c |} {res}/* Exported from Stata: 18 Jan 2012 19:07:28 */                          {txt}{c |}
  {c |} {res}/* ------------------------------------------------------------------ */ {txt}{c |}
  {c |} {res}                                                                         {txt}{c |}
  {c |} {res}GET STATA FILE='d:\Statist\Stata\Data/foo.dts'.                          {txt}{c |}
  {c |} {res}FILE LABEL 1978 Automobile Data.                                         {txt}{c |}
  {c |} {res}                                                                         {txt}{c |}
  {c |} {res}MISSING VALUES foreign (7 THRU 9).                                       {txt}{c |}
  {c |} {res}MISSING VALUES pricem (9999).                                            {txt}{c |}
  {c |} {res}                                                                         {txt}{c |}
  {c |} {res}SAVE OUTFILE = 'd:\Statist\Stata\Data/foo.sav'.                          {txt}{c |}
  {c BLC}{hline 74}{c BRC}

{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}{p_end}
