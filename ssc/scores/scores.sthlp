{smcl}
{* *! version 2.2.2  20july2018}{...}
{cmd:help scores}
{hline}

{title:Title}

{p 4 14 2}
    {hi:scores} {hline 2} to create scores (row-wise) of a set of variables allowing the
	specification of the number of valid values required and/or to produce various transformations of scores{p_end}


{title:Syntax}

    {cmd:scores} {newvar} = {it:fcn}({varlist}) {ifin} {weight} [, {it:options}]


{pstd}
where the syntax of {it:fcn} is

{p2colset 5 18 26 2}{...}
{p2col :{it:fcn}}Description{p_end}
{p2line}
{p2col:{hi:min}}minima of {it:varlist}{p_end}
{p2col:{hi:max}}maxima of {it:varlist}{p_end}
{p2col:{hi:{cmdab:tot:al}}}total (sum) scores of {it:varlist}{p_end}
{p2col:{hi:sd}}standard deviations of {it:varlist}{p_end}
{p2col:{hi:mean}}mean scores of {it:varlist}{p_end}
{p2col:{hi:{cmdab:med:ian}}}medians of {it:varlist}{p_end}
{p2col:{hi:{cmdab:pct:ile}}}percentiles of {it:varlist}{p_end}

{p 8 15 2}

{synoptset 17 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}{p2colset 7 24 24 2}
{p2col:{opt mi{ul on}nv{ul off}alid(#)}}minimum number of variables with valid values;
         default is {cmd:(1)}{p_end}
{p2col:{opt sc:ore(argument)}}transformation of mean scores according to {it:argument}{p_end}
{p2col:{opt min:val(#)}}theoretically lowest value of scale items - use with transformation argument {it:pomp}, {it:prop}, or {it:sprop};
         default is {cmd:(0)}{p_end}
{p2col:{opt max:val(#)}}theoretically highest value of scale items - use with transformation argument {it:pomp}, {it:prop}, or {it:sprop};
         default is {cmd:(0)}{p_end}
{p2col:{opt end:shift(#)}}value added to lower end (0) and subtracted from upper end (1) of scores transformed to proportions - use with transformation argument {it:prop};
         default is {cmd:(0)} (= no shift of ends){p_end}
{p2col:{opt c:enter(#)}}value around which shrunken scores transformed to proportions are centered - use with transformation argument {it:sprop};
         default is {cmd:(0.5)}{p_end}
{p2col:{opt p(#)}}the #th percentiles of variables with valid values  - use with function {it:pctile};
         default is {cmd:(50)} (= medians){p_end}
{p2col:{opt a:uto}}determine range of values of scale items automatically - use with transformation argument {it:pomp}, {it:prop}, or {it:sprop}{p_end}
{p2col:{opt replace}}replace existing variable by {it:newvar}{p_end}

{syntab:Sub (arguments of {hi:score()})}
{synopt:{opt z}}z-score transformation of mean scores{p_end}
{synopt:{opt z_2}}z/2-score transformation of mean scores{p_end}
{synopt:{opt c:entered}}centering of mean scores at the overall (group) mean{p_end}
{synopt:{opt sd2}}dividing the mean scores by 2 standard deviations{p_end}
{synopt:{opt po:mp}}transformation of mean scores to POMP scores (interval [0,100]){p_end}
{synopt:{hi: {ul on}p{ul off}ro{ul on}p{ul off}}}transformation of mean scores to proportion of maximum possible scores (interval [0,1]){p_end}
{synopt:{opt sp:rop}}transformation of mean scores to shrunken proportion of maximum possible scores (open interval ]0,1[){p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{hi:by} is allowed (see {help by});{p_end}
{pstd}
{opt aweight}s, {opt fweight}s, and {opt iweight}s are allowed (see {help weight}).{p_end}


{title:Description}

{pstd}
Using row functions of {manhelp egen D}, {cmd:-scores-} calculates scores according to {hi:{it:fcn}}
using variables listed in {hi:{it:varlist}} and assigns them to the new variable {hi:{it:newvar}}. If
the number of valid values of {hi:{it:varlist}} is less than {hi:minvalid({it:#})}, the resulting
score will be set to missing.

{pstd}
If {hi:{it:fcn}} is {hi:mean}, the option {hi:score({it:argument})} can be used to request
a transformation of the scores to{p_end}
{p 4 6 2}
- z-scores,{p_end}
{p 4 6 2}
- z/2-scores, i.e. z-scores divided by 2 (see: Gelman, A. (2008) {browse "https://onlinelibrary.wiley.com/doi/abs/10.1002/sim.3107":Scaling regression inputs by dividing by two standard deviations}. {it:Statistics in Medicine}, {it:27}, 
2865-2873),{p_end}
{p 4 6 2}
- scores centered at the overall (group) mean,{p_end}{p 4 6 2}
- scores divided by 2 standard deviations (see: Gelman, A. (2008) {browse "https://onlinelibrary.wiley.com/doi/abs/10.1002/sim.3107":Scaling regression inputs by dividing by two standard deviations}. {it:Statistics in Medicine}, {it:27},
 2865-2873),{p_end}{p 4 6 2}
- POMP (= {hi:p}ercent {hi:o}f {hi:m}aximum {hi:p}ossible) scores with 0 and 100 as minimum
and maximum possible values (see: Cohen, P., Cohen, J., Aiken, L.S., &
West, S.G. (1999). {browse "http://www.informaworld.com/smpp/content~content=a785043286~db=all~order=page":The problem of units and the circumstance for POMP}. {it:Multivariate Behavioral Research}, {it:34}, 315-346),{p_end}
{p 4 6 2}
- the proportion of maximum possible scores with 0 and 1 as minimum and maximum possible scores, or{p_end}
{p 4 6 2}
- the shrunken proportion of maximum possible scores with values in the open interval ]0,1[ (see: Smithson, M. &
Verkuilen, J. (2006). {browse "http://psycnet.apa.org/journals/met/11/1/54/":A better lemon squeezer? Maximum-likelihood regression with beta-distributed dependent variables}. {it:Psychological Methods}, {it:11}, 54-71).{p_end}

{p 4 4 2}
The transformation arguments {it:pomp}, {it:prop}, and {it:sprop} require to specify the minimum and
maximum values possible of the items listed in {hi:{it:varlist}} by using the
options {hi:minval({it:#})} and {hi:maxval({it:#})}. Alternatively, if all items listed
in {hi:{it:varlist}} have value labels defining the same range of values, the minimum and maximum possible values
can be determined automatically by using the option {hi:auto}.

{pstd}
POMP scores are calculated by POMP = 100*(raw - min)/(max - min) with raw = original mean score of variables (items) with
valid values, min = minimum possible value, and max = maximum possible value (min and max need not exist in the
actual data) (see Cohen et al. 1999). The proportion of maximum possible scores is equal to POMP/100. When using
as an independent variable in nonlinear models such as logistic regression models, the proportion of maximum possible
scores is preferable to POMP scores to facilitate the interpretation of the exponentiated coefficient such as the odds
ratio. Following the suggestion of Gelman (2008) {it:z}-scores divided by 2 provide an even better interpretation of 
coefficients of nonlinear models because they are better comparable to coefficients of binary predictor variables. 

{pstd}
When using as a dependent variable in beta regression
models (see {browse "http://maartenbuis.nl/software/betafit.html":betafit} and the SSC package {hi:-betafit-} ({net "describe betafit, from(http://fmwww.bc.edu/RePEc/bocode/b)":click here})), 0
and 1 can't be used because their logits are
undefined. There are two remedies: (a) Add a small value such as .001 to 0 and subtract it from 1 by using the
option {hi:endshift(#)}, or (b) shrink the range of values centered around a certain value (usually 0.5) by transforming
the proportion of maximum possible scores according to sprop = (prop*(n-1) + c)/n with prop = original proportion of maximum possible
scores, n = number of valid cases, and c = center (see Smithson & Verkuilen 2006, p. 54f). A different value for c can be
specified by using the option {hi:center(#)} (default: 0.5).

{pstd}
Note that {hi:scores} can also be used to simply transform scores, for example into {it:z}-scores - or any
other score that can be created by the option {hi:score()}. In this case, you specify only the variable you
want to transform using the function {hi:mean()}, followed by the respective {hi:score()}-option. Here you
are allowed to specify the original variable both as {hi:{it:newvar}} (i.e. to overwrite it) {it:and} in {hi:mean()} if
using the option {hi:replace}.

{pstd}
{hi:by} is allowed (see {help by}). However, {hi:by} only makes a difference when using the {hi:score()} option
arguments {hi:z}, {hi:z_2}, {hi:centered}, {hi:sd2}, or {hi:sprop} for obtaining {it:z}-scores, {it:z}/2-scores, mean-centered
scores, scores divided by 2 standard deviations, or shrunken proportions
of maximum possible scores, respectively. The same is true for weighting (see {help weight}): Using weights only
makes a difference to {it:z}-scores, {it:z}/2-scores, mean-centered scores, scores divided by 2 standard
deviations, or shrunken proportions.

{pstd}
If {hi:{it:newvar}} exists already, you can use the option {hi:replace} to replace it by the new
variable generated.


{title:Options}

{dlgtab:Main}

{phang}
{opt mi{ul on}nv{ul off}alid(#)} specifies how many variables must have valid values for calculating a score. If
the number of valid values is less than {it:#} the resulting score will be set to missing.

{phang}
{opt sc:ore(argument)} requests a transformation of the scores. This will only work if mean
scores have been requested by {hi:mean({it:varlist})}. Five transformations are possible
according to {hi:{it:argument}} (see below).

{phang}
{opt min:val(#)} specifies the theoretical minimum value of the items ({it:#} =
lowest value possible) (only useful if percents or (shrunken) proportions of maximum possible scores
have been requested by {hi:score(pomp)}, {hi:score(prop)}, or {hi:score(sprop)}).

{phang}
{opt max:val(#)} specifies the theoretical maximum value of the items ({it:#} =
highest value possible) (only useful if percents or (shrunken) proportions of maximum possible scores
have been requested by {hi:score(pomp)}, {hi:score(prop)}, or {hi:score(sprop)}).

{phang}
{opt end:shift(#)} specifies the value to be added to 0 (lower end) and to be subtracted from
1 (upper end) (only useful if the proportions of maximum possible scores have been requested
by {hi:score(prop)}).

{phang}
{opt c:enter(#)} specifies the value around which proportions of maximum possible scores
are to be shrunken (default: 0.5) (only useful if the shrunken proportions of possible scores
have been requested by {hi:score(sprop)}).

{phang}
{opt p(#)} specifies the #th percentile scores to be calculated (default: 50) (only useful if
percentiles have been requested by {hi:pctile({it:varlist})}).

{phang}
{opt a:uto} requests to determine the range of values of the items (lowest and highest possible values)
automatically. {hi:auto} requires that all items listed in {hi:{it:varlist}} have value labels defining
the same range of values. This option overrides values specified using {hi:minval({it:#})} and
{hi:maxval({it:#})} (only useful if percents or (shrunken) proportions of maximum possible scores
have been requested by {hi:score(pomp)}, {hi:score(prop)}, or {hi:score(sprop)}).

{phang}
{opt replace} requests that {hi:{it:newvar}} will replace an already existing
variable (if it exists).

{dlgtab:Sub (option score)}

{phang}
{opt sc:ore}{hi:(z)} requests a transformation of the mean scores to z-scores (resulting
mean = 0, sd = 1 (per group))

{phang}
{opt sc:ore}{hi:(z_2)} requests a transformation of the mean scores to z/2-scores (resulting
mean = 0, sd = 0.5 (per group))

{phang}
{opt sc:ore}{hi:({ul on}c{ul off}entered)} requests to center the mean scores at the overall (group) mean
(resulting mean = 0 (per group))

{phang}
{opt sc:ore}{hi:(sd2)} requests to divide the mean scores by two standard deviations (resulting sd = 0.5 (per group))

{phang}
{opt sc:ore}{hi:({ul on}po{ul off}mp)} requests to transform the mean scores to
POMP ({hi:p}ercent {hi:o}f {hi:m}aximum {hi:p}ossible) scores with 0 and 100 as minimum and maximum
possible values. Note that {hi:score(pomp)} requires specifying the minimum and maximum
possible values of the items listed in {hi:{it:varlist}} by using the options
{hi:minval({it:#})} and {hi:maxval({it:#})}, as well.

{phang}
{opt sc:ore}{hi:({ul on}p{ul off}ro{ul on}p{ul off})} requests to transform the mean scores to the
proportion of maximum possible scores with 0 and 1 as minimum and maximum
possible values (0 and 1 can be shifted to a larger and smaller value by using the
option {hi:{ul on}end{ul off}shift(#)}). Note that {hi:score(prop)} requires specifying the
minimum and maximum possible values of the items listed in {hi:{it:varlist}} by using the
options {hi:minval({it:#})} and {hi:maxval({it:#})}, as well.

{phang}
{opt sc:ore}{hi:({ul on}sp{ul off}rop)} requests to transform the mean scores to the
shrunken proportion of maximum possible scores in the open interval ]0,1[ (the proportion can
be shifted around a certain value by using the option {hi:{ul on}c{ul off}enter(#)} - the
default value is 0.5). Note that {hi:score(sprop)} requires specifying the
minimum and maximum possible values of the items listed in {hi:{it:varlist}} by using the
options {hi:minval({it:#})} and {hi:maxval({it:#})}, as well.


{title:Examples}

{pstd}
Transformation of price into a {it:z}-score divided by 2 (see Gelman 2008) for each level of rep78:

{com}. sysuse auto, clear
{com}. bys rep78: scores price_z2 = mean(price), sc(z_2)
{com}. tabstat price_z2, by(rep78) s(mean sd min max count) f(%4.3f)

{txt}Summary for variables: price_z2
{col 6}by categories of: rep78 (Repair Record 1978)

{ralign 8:rep78} {...}
{c |}      mean        sd       min       max         N
{hline 9}{c +}{hline 50}
{ralign 8:1} {...}
{c |}{...}
     {res}0.000     0.500    -0.354     0.354     2.000
{txt}{ralign 8:2} {...}
{c |}{...}
     {res}0.000     0.500    -0.321     1.192     8.000
{txt}{ralign 8:3} {...}
{c |}{...}
     {res}0.000     0.500    -0.445     1.344    30.000
{txt}{ralign 8:4} {...}
{c |}{...}
     {res}0.000     0.500    -0.656     1.071    18.000
{txt}{ralign 8:5} {...}
{c |}{...}
     {res}0.000     0.500    -0.414     1.163    11.000
{txt}{hline 9}{c +}{hline 50}
{ralign 8:Total} {...}
{c |}{...}
     {res}0.000     0.485    -0.656     1.344    69.000
{txt}{hline 9}{c BT}{hline 50}


{pstd}
The following data set allows to show how {hi:-scores-} creates scores depending
on the number of missing values as specified by the user:

{cmd:. clear all}
{cmd:. input v1-v5}

     {txt}       v1         v2         v3         v4         v5
  1.{cmd: 1 2 3 4 5}
{txt}  2.{cmd: 1 2 3 4 .}
{txt}  3.{cmd: 1 2 3 . .}
{txt}  4.{cmd: 1 . 3 4 .}
{txt}  5.{cmd: 1 2 . . .}
{txt}  6.{cmd: 1 . . . .}
{txt}  7.{cmd: . . . . .}
{txt}  8.{cmd: 1 1 1 1 1}
{txt}  9.{cmd: 5 5 5 5 5}
{txt} 10.{cmd: end}


{pstd}
Generate variable {it:test} containing the {hi:minima} of the four variables v1, v3, v4, and v5
(per default the value of {it:test} is valid if at least one variable of {it:varlist}
has a valid value):

{com}. scores test=min(v1 v3-v5)
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5   test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c RT}
  1. {c |} {res} 1    2    3    4    5      1 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .      1 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .      1 {txt}{c |}
  4. {c |} {res} 1    .    3    4    .      1 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .      1 {txt}{c |}
  6. {c |} {res} 1    .    .    .    .      1 {txt}{c |}
  7. {c |} {res} .    .    .    .    .      . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1      1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5      5 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c BRC}


{pstd}
Replace variable test by {it:test} containing the minima of variables v1, v3,
v4, and v5. Specify {hi:minvalid(3)} so that {it:test} has valid values only
if at least three values of the four variables of {it:varlist} are valid (or equivalently: at most
4-3=1 value may be missing):

{com}. scores test=min(v1 v3-v5), nv(3) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5   test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c RT}
  1. {c |} {res} 1    2    3    4    5      1 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .      1 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .      . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .      1 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .      . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .      . {txt}{c |}
  7. {c |} {res} .    .    .    .    .      . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1      1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5      5 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c BRC}


{pstd}
Same as above but using the {hi:maxima} instead of the minima:

{com}. scores test=max(v1 v3-v5), nv(3) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5   test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c RT}
  1. {c |} {res} 1    2    3    4    5      5 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .      4 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .      . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .      4 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .      . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .      . {txt}{c |}
  7. {c |} {res} .    .    .    .    .      . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1      1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5      5 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c BRC}


{pstd}
Same as above but creating the {hi:total} (sum) scores instead of the maxima:

{com}. scores test=total(v1 v3-v5), nv(3) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5   test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c RT}
  1. {c |} {res} 1    2    3    4    5     13 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .      8 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .      . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .      8 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .      . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .      . {txt}{c |}
  7. {c |} {res} .    .    .    .    .      . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1      4 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5     20 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c BRC}


{pstd}
Same as above but creating the standard deviations ({hi:sd}) instead of total scores:

{com}. scores test=sd(v1 v3-v5), nv(3) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5        test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c RT}
  1. {c |} {res} 1    2    3    4    5   1.7078251 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   1.5275252 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .           . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   1.5275252 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .           . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .           . {txt}{c |}
  7. {c |} {res} .    .    .    .    .           . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1           0 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5           0 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c BRC}


{pstd}
Same as above but creating {hi:median} scores instead of the standard deviations:

{com}. scores test=median(v1 v3-v5), nv(3) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5   test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c RT}
  1. {c |} {res} 1    2    3    4    5    3.5 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .      3 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .      . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .      3 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .      . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .      . {txt}{c |}
  7. {c |} {res} .    .    .    .    .      . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1      1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5      5 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c BRC}


{pstd}
Same as above but creating {hi:1st quartiles} instead of the medians:

{com}. scores test=pctile(v1 v3-v5), nv(3) p(25) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5   test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c RT}
  1. {c |} {res} 1    2    3    4    5      2 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .      1 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .      . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .      1 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .      . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .      . {txt}{c |}
  7. {c |} {res} .    .    .    .    .      . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1      1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5      5 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 6}{c BRC}


{pstd}
Same as above but creating {hi:mean} scores instead of the 1st quartiles:

{com}. scores test=mean(v1 v3-v5), nv(3) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5        test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c RT}
  1. {c |} {res} 1    2    3    4    5        3.25 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   2.6666667 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .           . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   2.6666667 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .           . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .           . {txt}{c |}
  7. {c |} {res} .    .    .    .    .           . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1           1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5           5 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c BRC}


{pstd}
Same as above but creating mean scores {hi:centered} at the overall mean:

{com}. scores test=mean(v1 v3-v5), nv(3) sc(c) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 12}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5         test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 12}{c RT}
  1. {c |} {res} 1    2    3    4    5    .33333333 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .         -.25 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .            . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .         -.25 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .            . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .            . {txt}{c |}
  7. {c |} {res} .    .    .    .    .            . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1   -1.9166667 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5    2.0833333 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 12}{c BRC}


{pstd}
Same as above but creating {hi:z-scores} instead of centered mean scores:

{com}. scores test=mean(v1 v3-v5), nv(3) sc(z) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 12}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5         test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 12}{c RT}
  1. {c |} {res} 1    2    3    4    5    .23210354 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   -.17407766 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .            . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   -.17407766 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .            . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .            . {txt}{c |}
  7. {c |} {res} .    .    .    .    .            . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1   -1.3345954 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5    1.4506471 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 12}{c BRC}


{pstd}
Same as above but instead of transforming the mean scores to z-scores, transforming them to {hi:POMP scores} assuming Likert
scale items with anchors ranging from 1 (minimum possible value) to 5 (maximum possible value):

{com}. scores test=mean(v1 v3-v5), nv(3) sc(po) min(1) max(5) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5        test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c RT}
  1. {c |} {res} 1    2    3    4    5       56.25 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   41.666667 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .           . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   41.666667 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .           . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .           . {txt}{c |}
  7. {c |} {res} .    .    .    .    .           . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1           0 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5         100 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c BRC}


{pstd}
Same as above but instead of POMP scores transforming the mean scores to the {hi: proportions} of maximum possible
scores assuming Likert scale items with anchors ranging from 1 (minimum possible value) to 5 (maximum possible value):

{com}. scores test=mean(v1 v3-v5), nv(3) sc(pp) min(1) max(5) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5        test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c RT}
  1. {c |} {res} 1    2    3    4    5       .5625 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   .41666667 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .           . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   .41666667 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .           . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .           . {txt}{c |}
  7. {c |} {res} .    .    .    .    .           . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1           0 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5           1 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c BRC}


{pstd}
Same as above but {hi:shifting the end points by} adding and subtracting {hi:.01} from 0 and 1:

{com}. scores test=mean(v1 v3-v5), nv(3) sc(pp) min(1) max(5) end(.01) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5        test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c RT}
  1. {c |} {res} 1    2    3    4    5       .5625 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   .41666667 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .           . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   .41666667 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .           . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .           . {txt}{c |}
  7. {c |} {res} .    .    .    .    .           . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1         .01 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5         .99 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 11}{c BRC}


{pstd}
Same as above but {hi:shrinking the proportions} to the center of 0.5:

{com}. scores test=mean(v1 v3-v5), nv(3) sc(sp) min(1) max(5) replace
{com}. list, sep(0)
{txt}
     {c TLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 10}{c TRC}
     {c |} {res}v1   v2   v3   v4   v5       test {txt}{c |}
     {c LT}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 10}{c RT}
  1. {c |} {res} 1    2    3    4    5        .55 {txt}{c |}
  2. {c |} {res} 1    2    3    4    .   .4333333 {txt}{c |}
  3. {c |} {res} 1    2    3    .    .          . {txt}{c |}
  4. {c |} {res} 1    .    3    4    .   .4333333 {txt}{c |}
  5. {c |} {res} 1    2    .    .    .          . {txt}{c |}
  6. {c |} {res} 1    .    .    .    .          . {txt}{c |}
  7. {c |} {res} .    .    .    .    .          . {txt}{c |}
  8. {c |} {res} 1    1    1    1    1         .1 {txt}{c |}
  9. {c |} {res} 5    5    5    5    5         .9 {txt}{c |}
     {c BLC}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 4}{c -}{hline 10}{c BRC}


{title:References}

{p 4 7 2}Cohen, P., Cohen, J., Aiken, L.S., & West, S.G. (1999). The problem of units and the circumstance for
POMP. {it:Multivariate Behavioral Research}, {it:34}, 315-346.{p_end}

{p 4 7 2}Gelman, A. (2008). Scaling regression inputs by dividing by two standard
deviations. {it:Statistics in Medicine}, {it:27}, 2865-2873.{p_end}

{p 4 7 2}Smithson, M. & Verkuilen, J. (2006). A better lemon squeezer? Maximum-likelihood regression with
beta-distributed dependent variables. {it:Psychological Methods}, {it:11}, 54-71.{p_end}

{title:Also see}

{psee}
SSC package {hi:betafit} ({net "describe betafit, from(http://fmwww.bc.edu/RePEc/bocode/b)":click here})
{p_end}

{title:Acknowledgements}

{pstd}
Thanks to Kit Baum for helpful advice and to Alan Acock for suggesting to calculate the (shrunken) proportions of maximum possible scores.

{title:Author}

    Dirk Enzmann
    {browse "http://www.jura.uni-hamburg.de/die-fakultaet/personenverzeichnis/enzmann-dirk.html"}
    dirk.enzmann@uni-hamburg.de
