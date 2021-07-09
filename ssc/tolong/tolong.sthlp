{smcl}
{* *! version 1.0.0  31mar2020}{...}
{vieweralsosee "reshape" "reshape"}{...}
{viewerjumpto "Syntax" "tolong##syntax"}{...}
{viewerjumpto "Description" "tolong##description"}{...}
{viewerjumpto "Options" "tolong##options"}{...}
{viewerjumpto "Remarks" "tolong##remarks"}{...}
{viewerjumpto "Examples" "tolong##examples"}{...}
{viewerjumpto "Stored results" "tolong##results"}{...}
{p2colset 1 11 13 2}{...}
{p2col:{bf:tolong} {hline 2}}Faster {bf:reshape long}{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 12 2}
{cmd:tolong} {it:stubnames} [{cmd:,}
{cmd:i(}{varlist}{cmd:)}
{cmd:j(}{newvar}{cmd:)}]

{pstd}
where {it:stubnames} are stubs of variable names that may contain
{bf:@}, {bf:#}, or {bf:*} denoting where {it:j} appears in the name.

{pstd}
{bf:#} matches numeric {it:j} in {it:stubname},
{bf:@} matches string {it:j} in {it:stubname}, and
{bf:*} matches both string and numeric {it:j} in {it:stubname}.

{pstd}
{bf:tolong} {it: stubname} is equivalent to {bf:tolong} {it: stubname}{bf:*}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:tolong} converts data from wide to long form as follows:

                                            {it:long}
           {it:wide}                           {c TLC}{hline 12}{c TRC}
        {c TLC}{hline 16}{c TRC}                {c |} {it:i  j}  {it:stub} {c |}
        {c |} {it:i}  {it:stub}{bf:1} {it:stub}{bf:2} {c |}                {c |}{hline 12}{c |}
        {c |}{hline 16}{c |}     tolong     {c |} 1  {bf:1}   4.1 {c |}
        {c |} 1    4.1   4.5 {c |}   <{hline 8}>   {c |} 1  {bf:2}   4.5 {c |}
        {c |} 2    3.3   3.0 {c |}                {c |} 2  {bf:1}   3.3 {c |}
        {c BLC}{hline 16}{c BRC}                {c |} 2  {bf:2}   3.0 {c |}
                                          {c BLC}{hline 12}{c BRC}


{marker options}{...}
{title:Options}

{phang}
{opth i(varlist)}
    specifies the variables whose unique values denote a logical observation.
    If you omit this option, the {bf:i} variable will be named {bf:_i}.

{phang}
{cmd:j(}{newvar}{cmd:)}
    specifies the variable that will hold {it:j} values from the variable
    names that match {it:stubnames}.
    If you omit this option, the {bf:j} variable will be named {bf:_j}.


{marker remarks}{...}
{title:Remarks}

{pstd}
Major differences bewtween {bf:tolong} and {bf:reshape long} are as follows:

{phang2}
  1.  {bf:tolong} does not require or assert that observations are unique
      on {bf:i()}.

{phang2}
  2.  {bf:tolong} does not sort the data on {bf:i()} after it finishes.
      Reshaped data is kept in the original order of {bf:i()}.

{phang2}
  3.  {bf:tolong} allows reshaping on numeric, string, or both numeric and
      string {bf:j()} values. {bf:reshape long} allows reshaping on numeric
      or both numeric and string {bf:j()} values.


{marker examples}{...}
{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. clear}{p_end}
{phang2}{cmd:. set obs 2}{p_end}
{phang2}{cmd:. gen id = _n}{p_end}
{phang2}{cmd:. gen x1 = rnormal()}{p_end}
{phang2}{cmd:. gen x2 = rnormal()}{p_end}
{phang2}{cmd:. gen xm = rnormal()}{p_end}
{phang2}{cmd:. gen xf = rnormal()}{p_end}
{phang2}{cmd:. save jj, replace}{p_end}
{phang2}{cmd:. list}{p_end}

{pstd}Convert data to long form; {bf:x#} matches {bf:x1} and {bf:x2}{p_end}
{phang2}{cmd:. use jj, clear}{p_end}
{phang2}{cmd:. tolong x#, i(id)}{p_end}
{phang2}{cmd:. list, sepby(id)}{p_end}

{pstd}Convert data to long form; {bf:x@} matches {bf:xm} and {bf:xf}{p_end}
{phang2}{cmd:. use jj, clear}{p_end}
{phang2}{cmd:. tolong x@, i(id)}{p_end}
{phang2}{cmd:. list, sepby(id)}{p_end}

{pstd}Convert data to long form; {bf:x*} matches {bf:x1}, {bf:x2}, {bf:xm}, and {bf:xf}{p_end}
{phang2}{cmd:. use jj, clear}{p_end}
{phang2}{cmd:. tolong x*, i(id)}{p_end}
{phang2}{cmd:. list, sepby(id)}{p_end}


{marker authors}{...}
{title:Authors}

{pstd}Rafal Raciborski{p_end}
{pstd}rraciborski@gmail.com{p_end}

