{smcl}
{* *! version 1.0.0  03April2008}{...}
{cmd:help umbrella}
{hline}

{title:Title}

{p2col:{hi:O'Brien's Umbrella Test}}

{title:Syntax}

{cmdab:umbrella} [{varlist}] {ifin} [{cmd:,} {it:options}]


{synoptset 18 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt:{opt by(groupvar)}}is required.  It specifies the name of the grouping variable.{p_end}
{synopt:{opt highlow(string)}}gives a string of space-delimited letters that are either H or L.  
There must be as many letters as there are dependent variables.  If the k-th such letter is an H 
then higher values of the k-th dependent variable denote a better outcome than lower values; 
if is is an L then the converse is true.  When this option is omitted higher values of all of 
the response variables are assumed to be better than lower values.{p_end}
{synopt:{opt ranktable}}generates a table of the ranks of each dependent variable grouped by groupvar.  
The sum of ranks accross the dependent variables is also given.  By default, this table is omitted.{p_end}
{synopt:{opt id(idvar)}}specifies the data set's identification variable.  If the data set
has a unique identifer and you wish this identifer to appear in the table of ranks then
specify that variable here.  If {opt ranktable} is not specified then this option
has no effect.

{title:Description}

{pstd}
{opt umbrella} performs O'Brien's (1984) Umbrella Test (also known as O'Brien's Multiple Endpoints Test).
It is used to test whether a continuous response vector differs between groups of subjects and may be 
used as a non-parametric alternative to Hotelling's T test. It is particularly useful when each dependent 
variable denotes an outcome in which higher values are better than lower values or vice versa.  
See O'Brien (1984) for more information.


{title:Remarks}

{pstd}
This test reduces to a Kruskal-Wallace one way analysis of variance if there is a single response variable.
  
{pstd}
This program gives results that are identical to those of the S+ program, umbrella.s, that is posted at http://mayoresearch.mayo.edu/mayo/research/biostat/splusfunctions.cfm .  umbrella.s was written by Susan Kunselman.

{pstd}
A related program is obrien, by Richard Goldstein (sg43 from http://www.stata.com/stb/stb28).
obrien provides extensions to the t and ranksum tests described in O'Brien (1988).


{title:Methods}

{pstd}
Rank each dependent variable (ignoring the grouping variable).
For dependent variables where lower values are better than higher values invert the associated ranks.
For each patient, sum these ranks accross all dependent variables.
Perform a one-way analysis of variance on the sums of these ranks.
 
{pstd}
In this program we do this analysis of variance using a Kruskal-Wallace test.


{title:Authors}

    William D. Dupont
    W. Dale Plummer, Jr.
    Department of Biostatistics
    Vanderbilt University School of Medicine

    e-mail: william.dupont@vanderbilt.edu
            dale.plummer@vanderbilt.edu 


{title:Reference}

    O'Brien, P.C. Procedures for comparing samples with multiple endpoints.  
    Biometrics 1984; 40: 1079-1087.
    
    O'Brien, P.C. Comparing two samples: extensions of the t, rank-sum, and
    log-rank tests.  J Am Stat Assoc 1988; 83: 52-61.


{title:Key Words}

    O'Brien, Peter C.
    umbrella
    multiple endpoints
    multivariate analysis of variance
    Hotelling's T test


{title:Example}

{com}. * Test whether the vector of mpg, weight and length differs between 
. * foreign and domestic cars in the auto data set. Low values of mpg and 
. * high values or weight and length are best.
. *

{com}. sysuse auto
{txt}(1978 Automobile Data)

{com}. umbrella mpg weight length, by(foreign) highlow(L H H)

{txt}Number of response variables: {res}3

{txt}{col 5}Variable{col 14}{c |}{col 22}Outcome
{hline 13}{c +}{hline 53}
{ralign 12:mpg}{col 14}{c |}{res}{col 23}lower values are better
{txt}{ralign 12:weight}{col 14}{c |}{res}{col 23}higher values are better
{txt}{ralign 12:length}{col 14}{c |}{res}{col 23}higher values are better

{txt}{hline}
-> foreign = Domestic

    Variable {c |}       Obs        Mean    Std. Dev.       Min        Max
{hline 13}{c +}{hline 56}
         mpg {c |}{res}        52    19.82692    4.743297         12         34
      {txt}weight {c |}{res}        52    3317.115    695.3637       1800       4840
      {txt}length {c |}{res}        52    196.1346    20.04605        147        233

{txt}{hline}
-> foreign = Foreign

    Variable {c |}       Obs        Mean    Std. Dev.       Min        Max
{hline 13}{c +}{hline 56}
         mpg {c |}{res}        22    24.77273    6.611187         14         41
      {txt}weight {c |}{res}        22    2315.909    433.0035       1760       3420
      {txt}length {c |}{res}        22    168.5455    13.68255        142        193


{txt}Missing observations dropped from analysis = {res}0

{txt}O'Brien's Umbrella test is the following Kruskal-Wallis test on the
sum of the ranks across the dependent variables.


Kruskal-Wallis equality-of-populations rank test

  {c TLC}{hline 10}{c TT}{hline 5}{c TT}{hline 10}{c TRC}
  {c |} {res} foreign {txt}{c |} {res}Obs {txt}{c |} {res}Rank Sum {txt}{c |}
  {c LT}{hline 10}{c +}{hline 5}{c +}{hline 10}{c RT}
  {c |} {res}Domestic {txt}{c |} {res} 52 {txt}{c |} {res} 2336.00 {txt}{c |}
  {c |} {res} Foreign {txt}{c |} {res} 22 {txt}{c |} {res}  439.00 {txt}{c |}
  {c BLC}{hline 10}{c BT}{hline 5}{c BT}{hline 10}{c BRC}

chi-squared = {res}   20.839{txt} with {res}1{txt} d.f.
probability = {res}    0.0001

{txt}chi-squared with ties = {res}   20.841{txt} with {res}1{txt} d.f.
probability = {res}    0.0001


