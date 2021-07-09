{smcl}
{* Copyright 2015 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 17July2015}{...}
{cmd:help mict_impute}
{hline}

{title:Title}

{phang}
{hi:mict_impute} {hline 2} Carry out multiple imputations in categorical
time-series data

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:mict_impute} [{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt maxg:ap}}Maximum length of internal gap to impute{p_end}
{synopt:{opt maxit:gap}}Maximum length of initial or terminal gap to impute{p_end}
{synopt:{opt nimp:}}Number of imputations{p_end}
{synopt:{opt off:set}}Offset for imputation sequence number{p_end}

{marker description}{...}
{title:Description}

{pstd} {cmd:mict_impute} creates imputations in categorical cross-sectional time-series
data such as lifecourse histories, as described in Halpin (2012, 2013).
It takes data prepared by {help mict_prep}, and imputes values for
internal, initial and terminal gaps, in a manner that is sensitive to
longitudinal consistency. It imputes a single categorical state variable, which must be
defined previously using the {cmd:mict_prep} command. The options
determine the maximum gap length that will be imputed (internal gaps:
{opt maxg:ap}, default 12; initial and terminal gaps: {opt maxit:gap},
default 6), the number
of imputations ({opt nimp}, default 5), and an offset for the imputation
number ({opt off:set}, default 0) -- e.g., if the offset is 5, the
iterations will be numbered from 6 up (useful for parallel runs). {p_end}

{pstd}The command leaves in place the imputations, in wide format with
their original variable names, with the variable {cmd:_mct_iter} storing
the imputation number. {p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}{cmd:mict_impute} carries out multiple imputation for
cross-sectional time series data with a categorical state variable, in a
manner that is longitudinally consistent. It is difficult to achieve
such longitudinal consistency with conventional approaches such as
{help mi impute chained} or {help ice}.
Under the hood, it uses {help mi impute mlogit} in a monotone imputation sequence.{p_end}

{pstd}It is intended for data with many cases and a moderate duration
(high N, moderate T), where (apart from missingness) T is the same for
all cases. It is best suited for situations where missingness tends to
be autocorrelated, generating gaps rather than isolated missing
observations. The imputation models are also more effective where the
average observed spell length is distinctly greater than one time
unit.{p_end}

{pstd}For each imputation {cmd:mict_impute} uses Stata's {cmd:mi
impute}, but handles the logic of chaining imputations together on its
own, in the manner described in Halpin (2012). In brief, gaps are filled
from their edges using prediction models that include (at a minimum)
information on the nearest observed past and future timepoints. This
permits a monotone sequence of imputations, in contrast to chained
imputation which will utilise (at a minimum) information from the
immediate prior and next states. {p_end}

{title:Imputation models}

{pstd} By default, very simple imputation models are used, with the next
and last (not necessarily adjacent) observed state predicting the
current state (in initial and terminal gaps, respectively only the next
or last observed states are used). These simple models should be over-ridden by more
adequate imputation models by re-defining programs {cmd:mict_model_gap},
{cmd:mict_model_initial} and {cmd:mict_model_terminal}:{p_end}

{phang}{cmd:. capture program drop mict_model_gap}{p_end}
{phang}{cmd:. program define mict_model_gap}{p_end}
{phang}{cmd:. mi impute mlogit _mct_state i._mct_next i._mct_last _mct_before* _mct_after*, add(1) force augment}{p_end}
{phang}{cmd:. end}{p_end}

{phang}{cmd:. capture program drop mict_model_initial}{p_end}
{phang}{cmd:. program define mict_model_initial}{p_end}
{phang}{cmd:. mi impute mlogit _mct_state i._mct_next _mct_after*, add(1) force augment}{p_end}
{phang}{cmd:. end}{p_end}

{phang}{cmd:. capture program drop mict_model_terminal}{p_end}
{phang}{cmd:. program define mict_model_terminal}{p_end}
{phang}{cmd:. mi impute mlogit _mct_state i._mct_last _mct_before*, add(1) force augment}{p_end}
{phang}{cmd:. end}{p_end}

{pstd}These examples differ from the defaults by including the sets of
variables {cmd:_mct_before*} and {cmd:_mct_after*} in the imputation
models. These variables are created by {cmd:mict_prep} and contain the
proportion of observed time spent in each state, respectively before and
after the current time. {p_end}


{pstd}This strategy can also be used to fall back on a simpler model if
the complex model will not converge in some cases:{p_end}

{phang}{cmd:. capture program drop mict_model_gap}{p_end}
{phang}{cmd:. program define mict_model_gap}{p_end}
{phang}{cmd:. di "Attempt first gap model"}{p_end}
{phang}{cmd:. capture mi impute mlogit _mct_state i._mct_next##c._mct_t i._mct_last##c._mct_t, add(1) force augment iterate(100)}{p_end}
{phang}{cmd:. if (_rc==430) {c -(}}{p_end}
{phang}{cmd:.   di as error "NO CONVERGENCE, fitting simplest gap model"}{p_end}
{phang}{cmd:.   mi impute mlogit _mct_state i._mct_next i._mct_last, add(1) force augment}{p_end}
{phang}{cmd:. }{c )-}{p_end}
{phang}{cmd:. else if _rc {c -(}}{p_end}
{phang}{cmd:.   exit _rc}{p_end}
{phang}{cmd:. }{c )-}{p_end}
{phang}{cmd:. end}{p_end}

{pstd}In this example, we first try to fit a model that suggests the
manner in which prior and subsequent state affects current state changes
over time. If this fails to converge in 100 iterations, a simpler model
is fitted. If this fails, or if the first model fails for a reason other
than non-convergence, an error is signalled. This is a very useful
facility because occasionally imputations can fail to converge,
depending on values imputed in earlier iterations.{p_end}

{pstd}For longitudinal consistency, the models must contain at a minimum
the variables {cmd:_mct_next} and {cmd:_mct_last} (as appropriate). The
built-in variables {cmd:_mct_before*} and {cmd:_mct_after*} are also
available, as is {cmd:_mct_t}, the time-index. Other predictors that can
be used include fixed (e.g., gender) or time-varying variables (state in
another domain, e.g., using fully-observed parenthood status to predict
incompletely-observed labour-market status).{p_end}

{pstd}The {help mi impute} options, {cmd:add(1)}, {cmd:force} and
{cmd:augment} are required. Respectively, they cause {help mi impute} to
carry out one imputation, to proceed even where some predictors are
missing, and to use augmented multinomial logistic regression if perfect
prediction is detected.{p_end}

{title:Author}

{pstd}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{pstd}These examples use {cmd:mvadmar.dta}, a version of {cmd:mvad.dta}
with runs of missing values imposed at random. These datasets are
provided as ancillary files. The {cmd:mvad.dta} data is from McVicar and
Anyadike Danes (2002).{p_end}

{phang}{cmd:. use mvadmar}{p_end}
{phang}{cmd:. mict_prep state, id(id)}{p_end}
{phang}{cmd:. program define mict_model_gap}{p_end}
{phang}{cmd:. mi impute mlogit _mct_state i._mct_next i._mct_last _mct_before* _mct_after*, add(1) force augment}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. program define mict_model_initial}{p_end}
{phang}{cmd:. mi impute mlogit _mct_state i._mct_next _mct_after*, add(1) force augment}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. program define mict_model_terminal}{p_end}
{phang}{cmd:. mi impute mlogit _mct_state i._mct_last _mct_before*, add(1) force augment}{p_end}
{phang}{cmd:. end}{p_end}
{phang}{cmd:. mict_impute, nimp(10)}{p_end}

{pstd}See also ancillary files {cmd:mict_example1.do} and {cmd:mict_example2.do}.{p_end}

{marker references}{...}
{title:References}

{phang}Halpin, B, (2012) `Multiple Imputation for Life-Course Sequence
  Data', Dept of Sociology working paper WP2012-01, University of
  Limerick. {browse "http://www.ul.ie/sociology/pubs/wp2012-01.pdf"} {p_end}

{phang}Halpin, B, (2013) `Imputing Sequence Data: extensions to initial and
  terminal gaps', Dept of Sociology working paper WP2013-01, University
  of Limerick. {browse "http://www.ul.ie/sociology/pubs/wp2013-01.pdf"}{p_end}

{phang}McVicar, D, and Anyadike-Danes, M, (2002) `Predicting Successful
  and Unsuccessful Transitions from School to Work Using Sequence
  Methods', Journal of the Royal Statistical Society (Series A), 165,
  pp317-334{p_end}
