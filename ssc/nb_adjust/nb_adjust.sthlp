{smcl}
{* *! version 2.02; July 29 2015, Dirk Enzmann}{...}
{hi:help nb_adjust}
{hline}

{title:Title}

{pstd}{hi:nb_adjust} {hline 2} adjust or remove outliers of a variable assumed
to have a negative binomial distribution

{title:Syntax}

{p 8 15 2}
{cmd:nb_adjust} {varname} {ifin} [{cmd:,} {it:options} ]

{synoptset 20 tabbed}{...}
{synopthdr:options}
{synoptline}
{synopt :{opth g:enerate(newvar)}}generate {cmd:{it:newvar}} with outliers
adjusted or removed
  {p_end}
{synopt :{opt sm:all(#)}}smallest value to define outliers (default: 0)
  {p_end}
{synopt :{opt la:rge(#)}}value assumed to be large and no outlier (default: 0)
  {p_end}
{synopt :{opt th:reshold(#)}}fix threshold to define outliers (default: not
fixed)
  {p_end}
{synopt :{opt li:mit(#)}}values beyond {cmd:limit} are extremes and will be
removed (default: none)
  {p_end}
{synopt :{opt seed(#)}}initial value of random-number {help seed} (default: not
set)
  {p_end}
{synopt :{opt rep:licates(#)}}number of replicates of random numbers (default: 250)
  {p_end}
{synopt :{opt cen:sor}}censor outliers instead of adjustment (default: adjust)
  {p_end}
{synopt :{opt rem:ove}}remove outliers instead of adjustment (default: adjust)
  {p_end}
{synopt :{opt nod:etail}}suppress details (default: show details)
  {p_end}
{synopt :{opt replace}}replace contents of {cmd:{it:newvar}} if {cmd:{it:newvar}}
exists already
  {p_end}
{synoptline}
{pstd}
{hi:by} is allowed (see {help by})


{title:Description}

{pstd} {cmd:nb_adjust} identifies and adjusts (or removes) outliers
of {cmd:{it:varname}} assuming that the values of {cmd:{it:varname}} have a
negative binomial distribution. Per default a value is defined as an outlier
if its expected frequency is less than 0.5 (rule-based outlier definition).

{pstd} {cmd: nb_ajdust} calculates the threshold to define an outlier by
estimating the mean and overdispersion parameter of {cmd:{it:varname}} and by
using the parameters {cmd:mu} = exp(_b[_cons]) and {cmd:size} = mu/e(delta)
obtained by -{help nbreg} {cmd:{it:varname}}, dispersion(constant)- as follows:

{pmore} {cmd:threshold} = max({cmd:counts}) of {cmd:counts} such that

{pmore} {help round}({cmd:n} * {help nbinomialp}({cmd:size},{cmd:counts},{cmd:prob})) > 0

{pstd} with {cmd:counts} = 0..max({cmd:{it:varname}}), {cmd:n} = sample size,
and {cmd:prob} = {cmd:size}/({cmd:size} + {cmd:mu}).

{pstd} Alternatively, the user can fix the threshold defining an outlier by
using the option {opt th:reshold(#)}.

{pstd} Per default outliers are values greater 0 which are greater than the
rule-based or user-fixed threshold. When using the rule-based definition of
outliers it is possible that values will be defined as outliers which the user
nevertheless wants to treat as "normal". By using the option {opt sm:all(#)}
(default: 0) the user can restrict the value to define outliers to a
minimum: When using this option, only values greater than the maximum of
({cmd:small}, {cmd:threshold}) are defined as outliers.

{pstd} {cmd:nb_adjust} adjusts outliers by replacing its values by random draws
from a negative binomial distribution with parameters {cmd:mu} and {cmd:size} as
estimated using the original values of {cmd:{it:varname}}. Replacement values
are ordered by size such as to preserve the rank order of outlying cases. To
make sure that the randomly drawn values have a minimal size, the user can apply
the option {opt la:rge(#)} (default: 0): Using this option, the lower bound of
replacement values is the minimum of ({cmd:large}, {cmd:threshold}) (i.e. in
cases of {cmd:threshold} < {cmd:large} the minimum of replacement values is
{cmd:threshold} instead of {cmd:large}). Note, however, that the absolute
minimum of replacement values is always {cmd:small}. The upper bound of
replacement values is the original value.

{pstd} The adjustment of outliers and the rule-based definition of the threshold
defining outliers are based on the observed values of {cmd:{it:varname}}. Using
the option {opt li:mit(#)}, extreme values greater than {cmd:limit} can be
eliminated from the observed values before estimating the mean and overdispersion
parameter of {cmd:{it:varname}}. Excluding extremes by using the option
{opt li:mit(#)}, only the remaining values are used to define the rule-based
outlier threshold and to define the negative binomial distribution from which to
draw replacement values of outliers. If the option {opth g:enerate(newvar)} is
used, values of {cmd:{it:varname}} > {cmd:limit} will be set to the extended
{help missing} value .r in variable {cmd:{it:newvar}}.

{pstd} To allow a replication of the random draws, the user can set the initial
value of the random-number {help seed} to any number between between 0
and 2^31-1 (2,147,483,647) by using the option {opt seed(#)}.

{pstd} Per default the random draws for the adjustment of outliers will be
replicated 250 times and averages over the replications rounded to the next
integer will be used as replacement values. The option {opt rep:licates(#)} allows
to specify the number of replicates (minimum 0 = no replicates).

{pstd} Instead of adjusting outlying values, outliers can be censored (i.e. set
to the outlier threshold) using the option {opt cen:sor} or removed (i.e. set to
the extended {help missing} value .o in variable {cmd:{it:newvar}}) by using the
option {opt rem:ove}. In this case, the option {opt la:rge(#)} will have no
effect. Note, however, that values to be censored or removed must always
be > {cmd:small}.


{title:Options}

{dlgtab:Main}

{phang}
{opth g:enerate(newvar)} specifies the name {cmd:{it:newvar}} of the variable
with outliers of {cmd:{it:varname}} adjusted or removed.

{phang}
{opt sm:all(#)} restricts the value to define outliers to a minimum
(default: 0). If the rule-based outlier threshold is less than {cmd:small}, only
values > {cmd:small} will be treated as outliers. Note that the user-fixed
outlier threshold must not be less than {cmd:small}.

{phang}
{opt la:rge(#)} makes sure that the randomly drawn values to replace outliers
have a minimal size. Using this option the lower bound of replacement values is
the minimum of ({cmd:large}, {cmd:threshold}). In cases of {cmd:threshold} <
{cmd:large} the minimal size of replacement values is {cmd:threshold} instead of
{cmd:large}.

{phang}
{opt th:reshold(#)} sets the threshold of outliers to a user-fixed value (default:
rule-based threshold). Using this option overrides the default of {cmd:nb_adjust}
which determines the threshold of outliers such that the expected frequency of an
outlying value is less than 0.5. Note that the user-fixed value of {cmd:threshold}
must not be smaller than the value specified with the option {opt sm:all(#)}.

{phang}
{opt li:mit(#)} serves to exclude extreme values > {cmd:limit} when determining
the mean and overdispersion parameter of {cmd:{it:varname}}. Values > {cmd:limit}
will temporarily be set to missing and will be set to the extended {help missing}
value .r when generating {cmd:{it:newvar}}. This option can be used to eliminate
the influence of extreme values on the rule-based definition of outliers and
their randomly drawn replacement values.

{phang}
{opt seed(#)} specifies the initial value of the random-number {help seed} (default: not
set). To enable a replication of the random numbers drawn when adjusting outliers,
{cmd:seed} can be set to any number between between 0 and 2^31-1 (2,147,483,647).

{phang}
{opt rep:licates(#)} specifies the number of replicates for the adjustment of
outliers (default: 250). Replacement values are the averages over the replications
rounded to the next integer. The minium value of {opt rep:licates(#)} is
0 (no replicates).

{phang}
{opt cen:sor} sets all outliers to the constant value of the outlier threshold instead
of adjusting outlying values by random draws from a negative binomial distribution. Note
that only values greater than the maximum of ({cmd:threshold}, {cmd:small}) (see option
{opt sm:all(#)}) will be censored.

{phang}
{opt rem:ove} sets outliers to the extended {help missing} value .o instead of
adjusting outlying values by random draws from a negative binomial distribution. Note
that only values greater than the maximum of ({cmd:threshold}, {cmd:small}) (see option
{opt sm:all(#)}) will be removed by setting them to missing.

{phang}
{opt nod:etail} allows to reduce details of the output.

{phang}
{opt replace} replaces the variable specified by {opth g:enerate(newvar)} if
{cmd:{it:newvar}} exists already.


{title:Example}

{pstd} Using an open response question, 12 year old students were asked to
indicate the number of times their family had moved to a different place. The
frequency distribution of the count variable "moves" shows at least one case
with a rather implausible value of 32.

{pstd} To replicate the example, copy and paste the 26 lines between -clear- and
-tab moves, missing- into Stata's command window:

    {cmd:clear}
    {cmd:input moves freq}
      0 486
      1 763
      2 315
      3 281
      4 163
      5  88
      6  40
      7  27
      8   9
      9   5
     10   2
     11   2
     12   1
     13   2
     15   2
     17   1
     18   2
     24   1
     25   1
     32   1
      .  12
    {cmd:end}
    {cmd:expand freq}
    {cmd:tab moves, missing}

{pstd}{cmd:nb_adjust} is used to create two new variabels ("moves_adj" and
"moves_rem") with outlying values adjusted and removed, resp. Before using the
default rule of {cmd:nb_adjust} to determine the threshold of outliers and to
randomly draw replacement values, extremely implausible values > 30 will be
removed. A number of three moves are assumed to be "normal", thus the option
{opt sm:all(3)} will be used to restrict outliers to values > 3. Fifteen moves
are assumed to be "large", therefore replacement values of outliers are
constrained to be at least 15.

{pstd}Thus, three options specifiying small values, large values, and the limit
to extreme values will be used for adjusting outliers (large values need not be
specified when removing outliers). The option {opt seed(#)} will be set to the
arbitrary value of 4 to enable a replication of the random draws of replacement
values:

    {stata nb_adjust moves, g(moves_adj) sm(3) la(15) li(30) seed(4)}
    {stata nb_adjust moves, g(moves_rem) sm(3) li(30) rem}

{pstd}The default rule of {cmd:nb_adjust} determined 12 to be the rule-based
threshold of outliers (overall, 9 values or 0.4% of sample are > 12 and thus
defined as outliers). Because 12 is greater than the minimal size of values
defined as "normal" by using option {opt sm:all(3)}, all 9 cases will have their
values adjusted by random draws from a negative binomial distribution or will be
removed by setting them to the extended missing value .o.

{pstd}Because the outlier threshold of 12 is smaller than the minimal size of
adjusted values specified by the option {opt la:rge(15)}, the lower bound
of adjusted values was reduced to the outlier threshold of 12. The commands
-{cmd:fre}- (if necessary, -{net "describe fre, from(http://fmwww.bc.edu/RePEc/bocode/f)":fre}-
will be installed by the first call to {cmd:nb_adjust}) and -{help summarize:sum}- show
the effect of adjusting and removing the 9 outliers:

    {stata fre moves* }
    {stata sum moves* }


{title:Saved Results}

{pstd} {cmd:nb_adjust} saves the following in {cmd:r()}: {p_end}

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: Scalars}{p_end}
{synopt:{cmd:r(small)}}minimum value to define outliers{p_end}
{synopt:{cmd:r(large)}}specified minimal size of replacement values{p_end}
{synopt:{cmd:r(limit)}}limit to define extreme values (0 = not used){p_end}
{synopt:{cmd:r(seed)}}initial value of the random number seed (-1 = not used){p_end}
{synopt:{cmd:r(repl)}}number of replicates of the random draws{p_end}
{synopt:{cmd:r(N)}}number of valid cases (cases not greater than {cmd:limit}) of
{cmd:{it:varname}}{p_end}
{synopt:{cmd:r(mu)}}mean of {cmd:{it:varname}}{p_end}
{synopt:{cmd:r(size)}}mu/delta of {cmd:{it:varname}} as determined by
-{help nbreg} {cmd:{it:varname}}, dispersion(constant)-{p_end}
{synopt:{cmd:r(threshold)}}threshold defining values as outliers{p_end}
{synopt:{cmd:r(nout)}}number of outliers of {cmd:{it:varname}}{p_end}
{synopt:{cmd:r(percout)}}percentage of outliers of {cmd:{it:varname}}{p_end}
{synopt:{cmd:r(low)}}lower bound used for adjustment values{p_end}
{synopt:{cmd:r(nadj)}}number of outliers adjusted (or removed){p_end}

{synoptset 14 tabbed}{...}
{p2col 5 14 18 2: Macros}{p_end}
{synopt:{cmd:r(varname)}}name of variable used{p_end}
{synopt:{cmd:r(newvar)}}name of new variable with values adjusted or removed{p_end}
{synopt:{cmd:r(adj)}}handling of outliers (adjusted, censored, or removed){p_end}
{synopt:{cmd:r(method)}}method to define outliers (rule-based or fixed){p_end}


{title:Requires}

{pstd} {cmd:nb_adjust} requires the SSC package {hi:moremata} ({net "describe moremata, from(http://fmwww.bc.edu/RePEc/bocode/m)":click here}).


{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}{p_end}
