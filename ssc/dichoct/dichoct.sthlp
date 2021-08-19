{smcl}
{* *! version 1.0.0  28November2020  Dirk Enzmann}{...}
{hi:help dichoct}
{hline}

{title:Title}

{pstd}{hi:dichoct} {hline 2} optimally dichotomizes a variable at a specified centile and generates a new variable containing the dichotomized values.

{title:Syntax}

{p 4 15 2}
{cmd:dichoct} {varname} {ifin} {cmd:, {opt g:enerate}({newvar})} [{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt :{opt g:enerate}({newvar})}generate {it:newvar} containing dichotomized variable
  {p_end}
{synopt :{opt c:entile(#)}}dichotomize variable at centile # (default: {cmd:centile(50)})
  {p_end}
{synopt :{opt l:abel}({it:lbname})}label values (0, 1) with the values of the centile
  {p_end}
{synopt :{opth f:ormat(%fmt)}}display format for centile values (default: %6.0g)
  {p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{hi:by} is allowed (see {help by}){p_end}

{title:Description}

{pstd} {cmd:dichoct} dichotomizes {it:varname} at the specified {it:centile} and
generates {it:newvar} containing the dichotomized values (0, 1). Dichotomizing a
variable at a specific centile will not always result in an optimal split (for
example, dichotomizing at values > or >= the centile value will yield different
results -- especially if the value of the centile is frequent and is not
exactly at the boundary of the interval including this value. {cmd:dichoct} chooses
to include or to not include the centile value in the upper interval of the
split (i.e. dichotomizes at values >= or > the centile value) so that an optimal
split is achieved. "Optimal" means that the resulting percentages of the values
of the dichotomized variable are closest to the desired percentages.

{pstd}However, note that dichotomizing quantitative variables (although often
practiced) most often is a bad idea. You will loose information, reduce power, and
introduce measurement error. Using a dichotomized variable instead of the
original variable may introduce bias that is worse than the problem you intend
to solve by dichotomizing. Before you decide to dichotomize your variables you
should make sure that you are aware of the associated problems clearly described
in Cohen (1983), MacCallum et al. (2002), and DeCoster et al. (2009).

{title:Options}

{dlgtab:Main}

{phang}
{opt g:enerate}({newvar}) specifies the name of the variable containing the
dichotomized values (0, 1) by splitting the variable {cmd:{it:varname}} at the
values of the centile specified with {cmd:centile(#)} or at its median if the
option {cmd:centile(#)} is not used. Values outside the range implied
by {bf:{help if}} or {bf:{help in}} are set to missing (.).

{phang}
{opt c:entile(#)} specifies the centile at which to dichotomize the
variable {cmd:{it:varname}}. {cmd:#} can be of type {bf:{help int}} or {bf:{help real}}. If
{cmd:centile(#)} is not specified the variable will be split at its median (= {cmd:centile(50)}).

{phang}
{opt l:abel}({it:lblname}) specifies the name of the value label of {newvar} (it
must not exist already). The labels contain the centile value at which the
variable {cmd:{it:varname}} has been dichotomized, indicating whether the centile
value is included or not in the lower value 0 (<= or <) or in the upper
value 1 (>= or >). Note that the option {cmd:label}({it:lblname}) cannot be used
when dichotomizing a variable separately for each group as specified with the
command prefix {bf:{help by}}.

{phang}
{opth f:ormat(%fmt)} sets the display format for centile values shown in the label
values, see {bf:{help format}}. The default is {cmd:format(%6.0g)}.


{title:Examples}

{pstd} {bf:Example 1} splits the variable "rep78" at its median (centile 50 = default)
and labels the values of the dichotomous variable with the values at which the
data have been split:

    {com}. sysuse auto, clear
    {txt}(1978 Automobile Data)

    {com}. dichoct rep78, label(rep78_d) gen(rep78_d)
    . tab1 rep78 rep78_d

    {res}-> tabulation of rep78  

    {txt}Repair      {c |}
    Record 1978 {c |}      Freq.     Percent        Cum.
    {hline 12}{c +}{hline 35}
              1 {c |}{res}          2        2.90        2.90
    {txt}          2 {c |}{res}          8       11.59       14.49
    {txt}          3 {c |}{res}         30       43.48       57.97
    {txt}          4 {c |}{res}         18       26.09       84.06
    {txt}          5 {c |}{res}         11       15.94      100.00
    {txt}{hline 12}{c +}{hline 35}
          Total {c |}{res}         69      100.00

    -> tabulation of rep78_d  

     {txt}rep78 split at {c |}
         centile 50 {c |}      Freq.     Percent        Cum.
    {hline 16}{c +}{hline 35}
    rep78 <=      3 {c |}{res}         40       57.97       57.97
    {txt}rep78  >      3 {c |}{res}         29       42.03      100.00
    {txt}{hline 16}{c +}{hline 35}
              Total {c |}{res}         69      100.00{txt}


{pstd} {bf:Example 2} demonstrates the use of the command
prefix {bf:{help by}} with {cmd:dichoct} to split the variable "price" at
centile 75 separately for each group of the variable "foreign". Note that the
option {cmd:label}({it:lblname}) cannot be used in combination with {bf:{help by}}:

    {com}. sysuse auto, clear
    {txt}(1978 Automobile Data)

    {com}. bys foreign: dichoct price, c(75) gen(price_d)
    . by foreign: tab price_d

    {txt}{hline}
    -> foreign = Domestic

    price split {c |}
     at centile {c |}
             75 {c |}      Freq.     Percent        Cum.
    {hline 12}{c +}{hline 35}
              0 {c |}{res}         39       75.00       75.00
    {txt}          1 {c |}{res}         13       25.00      100.00
    {txt}{hline 12}{c +}{hline 35}
          Total {c |}{res}         52      100.00

    {txt}{hline}
    -> foreign = Foreign

    price split {c |}
     at centile {c |}
             75 {c |}      Freq.     Percent        Cum.
    {hline 12}{c +}{hline 35}
              0 {c |}{res}         17       77.27       77.27
    {txt}          1 {c |}{res}          5       22.73      100.00
    {txt}{hline 12}{c +}{hline 35}
          Total {c |}{res}         22      100.00{txt}


{title:Returned results}

{pstd} Scalars:

{p2colset 5 20 20 2}{...}
{p2col : {cmd:r(k#)}} level # of group specified with {help by} (# = 1 if no by-variable specified) {p_end}
{p2col : {cmd:r(ct#)}} value of centile of level # of group specified with {help by}{p_end}
{p2col : {cmd:r(centile)}} centile to dichotomize variable {it:varname}{p_end}

{pstd} Macros:

{p2col : {cmd:r(ie#)}} inequality to dichotomize level # of group specified with {help by}{p_end}
{p2col : {cmd:r(by)}} variable(s) specifying groups with {help by}{p_end}
{p2col : {cmd:r(varname)}} name of dichotomized variable{p_end}


{title:References}

{p 4 7 2}Cohen, J. (1983). {browse "https://conservancy.umn.edu/handle/11299/107497":The cost of dichomization}.
{it:Applied Psychological Measurement}, {it:7}, 249-253.{p_end}
{p 4 7 2}DeCoster, J., Iselin, A.-M. R., & Gallucci, M. (2009).
{browse "https://psycnet.apa.org/record/2009-22665-003":A conceptual and empirical examination of justifications for dichotomization}.
{it:Psychological Methods}, {it:14}, 349-366.{p_end}
{p 4 7 2}MacCallum, R. C., Zhang, S., Preacher, K. J. & Rucker, D. D. (2002).
{browse "https://psycnet.apa.org/record/2002-00925-002":On the practice of dichotomization of quantitative variables}.
{it:Psychological Methods}, {it:7}, 19-40.{p_end}

{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de":dirk.enzmann@uni-hamburg.de}{p_end}

{title:Also see:}

{phang}Online: {bf:{help centile}}{p_end}
