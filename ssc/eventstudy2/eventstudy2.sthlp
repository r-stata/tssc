{smcl}
{* 31 October 2019}{...}
{hline}
help for {hi:eventstudy2}
{hline}

{title:eventstudy2 - A module to perform event studies with complex test statistics}

EXAMPLES AND DATA ARE AVAILABLE BELOW. IT IS RECOMMENDED TO FRIST GET THESE EXAMPLES RUNNNING AND THEN APPLYING {cmd:eventstudy2} TO ONE'S OWN DATA. 

NEW IN THIS VERSION: GRANK-T test for cumulative average abnormal returns according to Kolari and Pynnönen (2011); Adjusted Patell test (Kolari and Pynnönen (2010) adjustment); Wilcoxon (1945) signed ranks test; further:a substantially improved error output when input data does not match eventstudy2's criteria; the correction of an error in displaying significance levels of buy-and-hold returns; the correction of an error in calculating the bootstrapped skewness-adjusted t-ratio -> Thanks to Ludwig Erl for bringing this error to my attention.

{p 8 16 2}{cmd:eventstudy2}
{it:security_id} {it:date} {cmd:using} {it:security_returns_file}{cmd:,} 
{cmdab:ret:urns:(}{it:security_returns}{cmd:)} [{cmdab:mod:el:(}{it:abnormal_return_model}{cmd:)} {cmdab:marketfile(}{it:file_with_market/factor_returns}{cmd:)}
{cmdab:mar:ketreturns:(}{it:market_returns}{cmd:)} {cmdab:idmar:ket:(}{it:market_id}{cmd:)} {cmdab:factor1(}{it:factor_return1}{cmd:)} {cmdab:factor2(}{it:factor_return2}{cmd:)} {cmdab:factor3(}{it:factor_return3}{cmd:)} 
{cmdab:factor4(}{it:factor_return4}{cmd:)} {cmdab:factor5(}{it:factor_return5}{cmd:)}
{cmdab:factor6(}{it:factor_return6}{cmd:)} {cmdab:factor7(}{it:factor_return7}{cmd:)}
{cmdab:factor8(}{it:factor_return8}{cmd:)} {cmdab:factor9(}{it:factor_return9}{cmd:)}
{cmdab:factor10(}{it:factor_return10}{cmd:)} {cmdab:factor11(}{it:factor_return11}{cmd:)}
{cmdab:factor12(}{it:factor_return12}{cmd:)} 
{cmdab:risk:freerate(}{it:risk_free_rate}{cmd:)} {cmdab:p:rices(}{it:prices}{cmd:)} {cmdab:trading:volume(}{it:trading_volume}{cmd:)}
{cmdab:evwlb(}{it:event_window_lower_boundary}{cmd:)} {cmdab:evwub(}{it:event_window_upper_boundary}{cmd:)} {cmdab:eswlb(}{it:estimation_window_lower_boundary}{cmd:)} {cmdab:eswub(}{it:estimation_window_upper_boundary}{cmd:)}
{cmdab:minevw(}{it:minimum_observations_event_window}{cmd:)} {cmdab:minesw(}{it:minimum_observations_estimation_window}{cmd:)}
{cmdab:aar:file:(}{it:output_average_abn_ret_file}{cmd:)} {cmdab:car:file:(}{it:output_cum_average_abn_ret_file}{cmd:)}  {cmdab:ar:file:(}{it:output_abn_ret_file}{cmd:)} 
{cmdab:cross:file:(}{it:output_cross_sec_file}{cmd:)} {cmdab:diag:nosticsfile:(}{it:output_diag_file}{cmd:)} {cmdab:graph:file:(}{it:output_graph_file}{cmd:)} {cmd:replace}
{cmdab:log:returns} {cmdab:thin(}{it:thin_trading_threshold}{cmd:)} {cmdab:fill} {cmdab:nokol:ari} {cmdab:del:weekend}  {cmdab:dateline:threshold(}{it:dateline_threshold}{cmd:)}
{cmdab:shift(}{it:maximum_event_date_shift}{cmd:)}
{cmdab:garch} {cmdab:archo:ption:(}{it:arch_option}{cmd:)} {cmdab:garcho:ption:(}{it:garch_option}{cmd:)} {cmdab:archi:terate:(}{it:iterations}{cmd:)}
{cmdab:para:llel} {cmdab:pclus:ters:(}{it:clusters}{cmd:)} {cmdab:proc:essors:(}{it:processors_StataMP}{cmd:)} {cmdab:prap:ath:(}{it:path_eventstudy2_parallel}{cmd:)}
{cmdab:arfillev:ent} {cmdab:arfilles:timation}
{cmdab:car1LB(}{it:CAR_window_1_lower_boundary}{cmd:)} {cmdab:car1UB(}{it:CAR_window_1_upper_boundary}{cmd:)} {cmdab:car2LB(}{it:CAR_window_2_lower_boundary}{cmd:)}
{cmdab:car2UB(}{it:CAR_window_2_upper_boundary}{cmd:)} {cmdab:car3LB(}{it:CAR_window_3_lower_boundary}{cmd:)} {cmdab:car3UB(}{it:CAR_window_3_upper_boundary}{cmd:)}
{cmdab:car4LB(}{it:CAR_window_4_lower_boundary}{cmd:)} {cmdab:car4UB(}{it:CAR_window_4_upper_boundary}{cmd:)} {cmdab:car5LB(}{it:CAR_window_5_lower_boundary}{cmd:)}
{cmdab:car5UB(}{it:CAR_window_5_upper_boundary}{cmd:)} {cmdab:car6LB(}{it:CAR_window_6_lower_boundary}{cmd:)} {cmdab:car6UB(}{it:CAR_window_6_upper_boundary}{cmd:)}
{cmdab:car7LB(}{it:CAR_window_7_lower_boundary}{cmd:)} {cmdab:car7UB(}{it:CAR_window_7_upper_boundary}{cmd:)} {cmdab:car8LB(}{it:CAR_window_8_lower_boundary}{cmd:)}
{cmdab:car8UB(}{it:CAR_window_8_upper_boundary}{cmd:)} {cmdab:car9LB(}{it:CAR_window_9_lower_boundary}{cmd:)} {cmdab:car9UB(}{it:CAR_window_9_upper_boundary}{cmd:)}
{cmdab:car10LB(}{it:CAR_window_10_lower_boundary}{cmd:)} {cmdab:car10UB(}{it:CAR_window_10_upper_boundary}{cmd:)}]

{p 4 4 2}
where

{p 8 16 2}
{it:security_id} is the name of the security or firm identifier variable in the event list that is currently held in memory.

{p 8 16 1}
{it:date} is the name of the of the event date variable in the event list that is currently held in memory.

{p 8 16 1}
{it:security_returns_file} is the name of the file that contains security returns (see option {cmdab:ret:urns(}{it:security_returns}{cmd:)}) that is stored in working directory. {it:security_returns_file} must also contain the variables
{it:security_id} and {it:date}, while here {it:date} refers to the dates for which the returns are observed rather than the event date.

{title:Description}

{p 4 4 2}
{cmd:eventstudy2} performs event studies and allows the user to specify several model specifications that have been established in the finance and related literature, e.g. raw returns, the market model, multi-factor models and buy-and-hold abnormal returns. The length of estimation and event windows can be chosen freely and cumulative (average) abnormal (buy-and-hold) returns can be calculated over up to 10 windows. The output of {cmd:eventstudy2} currently provides the following test statistics, which are all calculated using the Mata programming language:

{p 8 8 2}
The {hi:t-test} assuming cross-sectional independence according to Serra (2002, p. 4).

{p 8 8 2}
The {hi:crude dependence adjustment test} according to Brown and Warner (1980, pp. 223, 253).

{p 8 8 2}
The {hi:Patell test} of standardized residuals (Patell, 1976, pp. 254-258).

{p 8 8 2}
The {hi:Boehmer test} of standardized residuals corrected for event-induced changes in volatility (Boehmer et al., 1991, pp. 258-270).

{p 8 8 2}
The {hi:Kolari test} of standardized residuals corrected for event-induced changes in volatility and cross-correlation (Kolari and Pynnönen, 2010, p. 4003).

{p 8 8 2}
The {hi:Corrado rank test} (Corrado, 1989, pp. 387-388). For cumulative (average) abnormal returns, the aggregation formula in Cowan (1992, p. 346) is applied.

{p 8 8 2}
The {hi:Corrado and Zivney rank test} corrected for event-induced volatility of rankings (Corrado and Zivney, 1992, pp. 345-346). For cumulative (average) abnormal returns, the aggregation formula in Cowan (1992, p. 346) is applied.

{p 8 8 2}
The {hi:generalized sign test} according to Cowan (1992, pp. 345-346).

{p 8 8 2}
The {hi:GRANK test} for average cumulative returns according to Kolari and Pynnönen (2011), including the Kolari and Pynnönen (2010) for cross-correlation (see Fn. 6 in Kolari and Pynnönen (2011)).

{p 8 8 2}
The {hi:Wilcoxon signed-ranks test} according to Wilcoxon (1945).

{p 8 8 2}
The {hi:skewness-adjusted bootstrapped t-ratio test} for buy-and-hold abnormal returns according to Lyon et al. (1999, pp. 173-175).

{p 4 4 2}
By default, thin trading is accounted for on a trade-to-trade basisa s suggested in Maynes and Rumsey (1993, pp. 148-149). {hi:eventstudy2} performs an
extensive meta-analysis on data availability. For instance, securities/firms that have insufficient oberservations in the estimation and/or event period are reported in the _Diagnostic file. 
{hi: eventstudy2} also provides a graph that displays cumulative average abormal (buy-and-hold) return over the event window.

{title:Citation}

{p 4 8 2}{cmd:eventstudy2} is not an official Stata command.
It is a free contribution to the research community.
Please cite it as such: {p_end}
{p 8 8 2}Kaspereit, T. 2019. eventstudy2 - A program to perform event studies with complex test statistics in Stata (Version 3.0).{p_end}


{title:Options}

{p 4 8 2}{cmdab:ret:urns(}{it:security_returns}{cmd:)} specifies the name of the variable in {it:security_returns_file} that represents the security returns of the event firms.

{p 4 8 2}{cmdab:mod:el(}{it:abnormal_return_model}{cmd:)} specifies the model to calculate abnormal returns. In the current version of {hi:eventstudy2}, 
the models RAW (raw returns), COMEAN (constant mean model), MA (market adjusted returns), FM (factor models, e.g. the market model and Fama and French (1992, 1993) factor models), 
BHAR (buy-and-hold abnormal returns against a market index or factor) and BHAR_raw (raw buy-and-hold returns). If one the models MA, FM or BHAR is selected, 
it is mandatory to specify the options {cmd:marketfile} and {cmdab:mar:ketreturns}. In models BHAR and BHAR_raw, missing returns are set to zero (see option {cmdab:fill})
while in all other models missing returns are dealt with on a trade-to-trade basis in accordance with  Maynes and Rumsey (1993, pp. 148-149).

{p 4 8 2}{cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)} specifies the file in which market returns are stored on disk. Market returns,
whose denomination is specific by the option {cmdab:mar:ketreturns(}{it:market_returns}{cmd:)}, serve as benchmarks in the models MA, FM and BHAR (see option {cmdab:mod:el}),
against which abnormal returns are calculated. {it:file_with_market/factor_returns} also might contain additional factors (see options {cmd:factor1}
to {cmd:factor5}) and the risk free rate (see option {cmdab:risk:freerate}).
{it:file_with_market/factor_returns} must contain the variable {it:date}, which has to have the same denomination
as in the event date variable of the dataset held in memory.

{p 4 8 2}{cmdab:mar:ketreturns(}{it:market_returns}{cmd:)} specifies the variable denomination of the market returns in the file {it:file_with_market/factor_returns} (see option {cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)}).

{p 4 8 2}{cmdab:idmar:ket(}{it:market_id}{cmd:)} specifies the identifier of market and/or factor returns in both the event list held in memory (or alternatively the security returns file) and the market return file on disk
(see option {cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)}).
It is possible that certain events have different benchmarks, for instance in an international event study setting, security returns of U.S. firms are benchmarked against the S&P 500 index while UK firms are benchmarket against the FTSE100.
The variable {it:market_id} allows to assign different benchmarks to different events, though the event study and the calculation of the test statistics are performed on an aggregated basis.

{p 4 8 2}{cmd:factor1(}{it:factor_return1}{cmd:)} to {cmd:factor12(}{it:factor_return12}{cmd:)}, very similar to the option {cmdab:mar:ketreturns(}{it:market_returns}{cmd:)},
specifies the variable names for up to 5 factors used in multiple factor benchmark models (FM). {hi:eventstudy2} automatically adjusted test statistics for lower degrees
of freedom when more factors are used in the calculation of abnormal returns.

{p 4 8 2}{cmdab:risk:freerate(}{it:risk_free_rate}{cmd:)} specifies the variable denomination of the risk free rate in the file {it:file_with_market/factor_returns} (see option {cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)}).

{p 4 8 2}{cmdab:p:rices(}{it:prices}{cmd:)} specifies the variable denomination of security prices in the file
{it:file_with_market/factor_returns} (see option {cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)}).
The variable {it:prices}, if specified, is used to indentify return observations that suffer from thin trading. A return observation suffers from thin trading if
for the same trading day or the trading day before no prices are available. 
It is also classified as suffering from thin trading if {it:prices} multiplied by {it:trading_volume} (see option {cmdab:trading:volume(}{it:trading_volume}{cmd:)})
is below the threshold specified by the option {cmdab:thin(}{it:thin_trading_threshold}{cmd:)}.

{p 4 8 2}{cmdab:trading:volume(}{it:trading_volume}{cmd:)} specifies the variable denomination of trading volume (number of shares per day) in the file
{it:file_with_market/factor_returns} (see option {cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)}).
The variable {it:trading_volume}, if specified, is used to indentify return observations that suffer from thin trading.
A return observation suffers from thin trading if {it:prices} (see option {cmdab:p:rices(}{it:prices}{cmd:)}) multiplied by
{it:trading_volume} is below the threshold specified by the option {cmdab:thin(}{it:thin_trading_threshold}{cmd:)}.

{p 4 8 2}{cmdab:evwlb(}{it:event_window_lower_boundary}{cmd:)} specifies the lower boundary of the event window, measured in trading days relative to the event date. The default value is -20.

{p 4 8 2}{cmdab:evwub(}{it:event_window_upper_boundary}{cmd:)} specifies the upper boundary of the event window, measured in trading days relative to the event date. The default value is 20.

{p 4 8 2}{cmdab:eswlb(}{it:estimation_window_lower_boundary}{cmd:)} specifies the lower boundary of the estimation window, measured in trading days relative to the event date. The default value is -270.

{p 4 8 2}{cmdab:eswub(}{it:estimation_window_upper_boundary}{cmd:)} specifies the upper boundary of the estimation window, measured in trading days relative to the event date. The default value is -20.

{p 4 8 2}{cmdab:minevw(}{it:minimum_observations_event_window}{cmd:)} specifies the minimum number of valid, i.e. non-thinly traded, returns observations in the event window.
If less than minimum_observations_event_window valid return observations are available, the event is excluded from the analysis and reported on the {it:_Diagnostics} file. The default value is 1.

{p 4 8 2}{cmdab:minesw(}{it:minimum_observations_estimation_window}{cmd:)} specifies the minimum number of valid, i.e. non-thinly traded, returns observations in the estimation window.
If less than minimum_observations_estimation_window valid return observations are available, the event is excluded from the analysis and reported on the {it:_Diagnostics} file. The default value is 30.

{p 4 8 2}{cmdab:aar:file:(}{it:output_average_abn_ret_file}{cmd:)} specifies the file name under which the dta-file that contains average abnormal returns will be saved. If not specified, the file name will be {it:aarfile} or
the module will abort if a file with the same denomination is already present and the {cmd:replace} option has not been called.

{p 4 8 2}{cmdab:car:file:(}{it:output_cum_average_abn_ret_file}{cmd:)} specifies the file name under which the dta-file that contains cumulative average abnormal returns will be saved.
If not specified, the file name will be {it:carfile} or
the module will abort if a file with the same denomination is already present and the {cmd:replace} option has not been called.

{p 4 8 2}{cmdab:ar:file:(}{it:output_abn_ret_file}{cmd:)} specifies the file name under which the dta-file that contains abnormal abnormal returns will be saved.
If not specified, the file name will be {it:arfile} or
the module will abort if a file with the same denomination is already present and the {cmd:replace} option has not been called.

{p 4 8 2} {cmdab:cross:file:(}{it:output_cross_sec_file}{cmd:)} specifies the file name under which the dta-file that contains cumulative abnormal returns for the cross-sectional analysis will be saved. If not specified, the file name will be {it:crossfile} or
the module will abort if a file with the same denomination is already present and the {cmd:replace} option has not been called.

{p 4 8 2} {cmdab:diag:nosticsfile:(}{it:output_diag_file}{cmd:)} specifies the file name under which the dta-file and the smcl-file that contain diagnostic sample statistics will be saved.
If not specified, the file names will be {it:diagnosticsfile.dta} and {it:diagnosticsfile.smcl} or
the module will abort if files with the same denominations are already present and the {cmd:replace} option has not been called.

{p 4 8 2} {cmdab:graph:file:(}{it:output_graph_file}{cmd:)} specifies the file name under which the gph-file that displays cumulative average abnormal returns will be saved. If not specified, the file name will be {it:graphfile} or
the module will abort if a file with the same denomination is already present and the {cmd:replace} option has not been called.

{p 4 8 2} {cmd:replace} allows output files to be overwritten (see options {cmdab:aar:file:(}{it:output_average_abn_ret_file}{cmd:)}, {cmdab:car:file:(}{it:output_cum_average_abn_ret_file}{cmd:)},
{cmdab:cross:file:(}{it:output_cross_sec_file}{cmd:)}, {cmdab:diag:nosticsfile:(}{it:output_diag_file}{cmd:)} and {cmdab:graph:file:(}{it:output_graph_file}{cmd:)}).

{p 4 8 2}{cmdab:log:returns} specifies whether returns in the {it:security_returns_file} (see option {cmdab:ret:urns(}{it:security_returns}{cmd:)}) and {it:file_with_market/factor_returns}
(see option {cmd:marketfile(}{it:file_with_market/factor_returns}{cmd:)}) are continuously compounded returns. By default, {hi:eventstudy2} assumes that input returns are discrete, i.e.
calculated by the formula [(p_t+1-p_t)/p_t], where p is the dividend and stock splits adjusted share price, and transforms those returns to continuously compounded returns, i.e. [ln(p_t+1)-ln(p_t)] if {it:abnormal_return_model} is RAW, MA or FM. If {it:abnormal_return_model} is BHAR or BHAR_raw, returns are kept as discrete returns, or are transformed to discrete returns if option {cmdab:log:returns} is specified.
   
{p 4 8 2}{cmdab:thin(}{it:thin_trading_threshold}{cmd:)} specifies the threshold for classifying security return observations as arising from thin trading. A security return observation is
classified as arising from thin trading if the trading volume, i.e. {it:prices} (see option {cmdab:p:rices(}{it:prices}{cmd:)}) multiplied by {it:trading_volume} (see option
{cmdab:trading:volume(}{it:trading_volume}{cmd:)}) is lower than {it:thin_trading_threshold}.
All return observations that are classified as arising from thin trading are handled on a trade-to-trade basis as suggested in Maynes and Rumsey (1993, pp. 148-149).

{p 4 8 2}{cmd:fill} specifies whether missing security and market returns are set to zero if missing. Nevertheless, missing returns are never set to zero if they are before the
first or after the last valid return observation in the file {it:security_returns_file}. It is strongly recommend to not use this option, except for models BHAR and BHAR_raw where is option is always activated.
{hi:eventstudy2} handles missing returns or returns that arise from thin trading is a very efficient way with a minimum loss in observations. Further, all test statistics account  for such missing returns on a daily basis.

{p 4 8 2}{cmdab:nokol:ari} If this option is called, the Kolari and Pynnönen (2010, p. 4003) adjustment of the Boehmer et al. (1991, pp. 258-270) test is not calculated but set to 1. In this case
the Boehmer test equals the Kolari test. Calling this option might increase the calculation of test statistics dramatically since resource requirements to calculate the Kolari and Pynnönen adjustment increase quadratically in the number of events.

{p 4 8 2}{cmdab:del:weekend} If this option is called, return observations at Saturdays and Sundays are never considered valid observations and are deleted from the analysis.

{p 4 8 2}{cmdab:dateline:threshold(}{it:dateline_threshold}{cmd:)} This option specifies a minimum threshold of return observation that should exit to include a particular trading day into the analysis.
It is useful to identify (international) holidays where only a few amount of securities are traded. 
First, {hi:eventstudy2} calculated the number of return observation in the file {it:security_returns_file} by date. Then, all dates are deleted for which the number of return observations is lower than
{it:dateline_threshold} multiplied by the mean number of observations per day. A value of 0.2 for {it:dateline_threshold} has proven a good choice in previous studies.
If this option is not specified, any date on which there is at least one return observation from any security is considered a trading date on the date line.

{p 4 8 2}{cmdab:shift(}{it:maximum_event_date_shift}{cmd:)} {hi:eventstudy2} derives the set of valid dates (date line) from the file {it:security_returns_file}. If an event date does not coincide with any of those
dates, it is shifted to the next date on the date line. maximum_event_date_shift specifies the maximum number of calendar days an event date is shifted forward. The default value is 3.

{p 4 8 2}{cmdab:garch} invokes the estimation of a (G)ARCH model if the benchmark model is a (multi)factor model (FM). The options {cmdab:archo:ption:(}{it:arch_option}{cmd:)}, {cmdab:garcho:ption:(}{it:garch_option}{cmd:)}
and {cmdab:archi:terate:(}{it:iterations}{cmd:)}
determine the exakt specification of the (G)ARCH model.

{p 4 8 2}{cmdab:archo:ption:(}{it:arch_option}{cmd:)} specifies the ARCH terms. Specify archo(1) to include first-order terms, archo(1/2) to specify first- and second-order terms, archo(1/3) to specify first-, second-, and third-order terms, etc. 

{p 4 8 2}{cmdab:garcho:ption:(}{it:garch_option}{cmd:)} specifies the GARCH terms. Specify garcho(1) to include first-order terms, garcho(1/2) to specify first- and second-order terms, garcho(1/3) to specify first-, second-, and third-order terms, etc. 

{p 4 8 2}{cmdab:archi:terate:(}{it:iterations}{cmd:)} specifies the maximum number of iterations in a (G)ARCH estimation.

{p 4 8 2}{cmdab:para:llel} invokes parallel computing capabilities using the user-written command "parallel" by George Vega Yon and Brian Quistoff (https://ideas.repec.org/c/boc/bocode/s457527.html).
This option requires the presense of "eventstudy2_parallel.do" in the path specified by {cmdab:prap:ath:(}{it:path_eventstudy2_parallel}{cmd:)}.

{p 4 8 2}{cmdab:pclus:ters:(}{it:clusters}{cmd:)} specifies the number of clusters if {cmdab:para:llel} is selected. This number should not be higher than the number of CPUs. The default value is 2.

{p 4 8 2}{cmdab:proc:essors:(}{it:processors_StataMP}{cmd:)} {cmdab:prap:ath:(}{it:path_eventstudy2_parallel}{cmd:)} specifies the number of CPUs that StataMP is suppossed to use in each cluster.

{p 4 8 2}{cmdab:prap:ath:(}{it:path_eventstudy2_parallel}{cmd:)} specifies the path to file eventstudy2_parallel.do, which is neccessary to use the parallel computing capabilities of eventstudy2.

{p 4 8 2}{cmdab:arfillev:ent} forces eventstudy2 to fill any missing abnormal returns in the event window with zeros.

{p 4 8 2}{cmdab:arfilles:timation} forces eventstudy2 to fill any missing abnormal returns in the estimation window with zeros before calculating test statistics. Nevertheless, the benchmark model 
will still be estimated based on trade-to-trade returns. 

{p 4 8 2}{cmdab:car1LB(}{it:CAR_window_1_lower_boundary}{cmd:)} to {cmdab:car10LB(}{it:CAR_window_10_lower_boundary}{cmd:)} specifies the lower boundary of the window over which cumulative (average) abnormal
returns are to be calcuated. It is possible to specifiy up to 10 different windows. The default value is -20. The lower boundaries and upper boundaries (see option {cmdab:car1UB(}{it:CAR_window_1_upper_boundary}{cmd:)} to
{cmdab:car10UB(}{it:CAR_window_10_upper_boundary}{cmd:)}) build pairs. For instance, specifying car1LB(-5) and car1UB(3) makes {hi:eventstudy2} calculating and reporting cumulative (average) abnormal returns or buy-and hold abnormal returns
for the window [-5;3] relative to the event date.

{p 4 8 2}{cmdab:car1UB(}{it:CAR_window_1_upper_boundary}{cmd:)} to {cmdab:car10UB(}{it:CAR_window_10_upper_boundary}{cmd:)} specifies the upper boundary of the window over which cumulative (average)
abnormal returns are to be calculated. It is possible to specifiy up to 10 different windows. The default value is 20.

{title:Examples}

{p 4 8 2} Change your current working directory to a path were you can save sample files.

{p 4 8 2} Needs to be run first to set the right download location of sample files:

{p 4 8 2} {stata ssc describe eventstudy2}

{p 4 8 2} Download sample files:

{p 4 8 2}{stata net get eventstudy2}

{p 4 8 2}{stata use Earnings_surprises.dta}{p_end}

{p 4 8 2} Basic sample event study using raw returns and default parameters:

{p 4 8 2}{stata "eventstudy2 Security_id Date using Security_returns if Earnings_surprise > 0.05, returns(Return)"}{p_end}

{p 4 8 2} Sample event study using buy-and-hold abnormal returns:

{p 4 8 2}{stata "eventstudy2 Security_id Date using Security_returns if Ea > 0.05, ret(Return) car1LB(-1) car1UB(1) car2LB(-5) car2UB(-3) mod(BHAR) marketfile(Factor_returns) mar(MKT) idmar(Market_reference)"}{p_end}

{p 4 8 2} Sample event study using the Fama-French multi-factor model:

{p 4 8 2}{stata "eventstudy2 Security_id Date using Security_returns if Ea > 0.05, ret(Return) car1LB(-1) car1UB(1) mod(FM) marketfile(Factor_returns) mar(MKT) idmar(Market_reference) factor1(SMB) factor2(HML) risk(risk_free_rate)"}{p_end}

{p 4 8 2} Sample event study using the Fama-French multi-factor model with (G)ARCH terms and parallel computing capabilities:
  
{p 4 8 2}{stata "eventstudy2 Security_id Date using Security_returns if Ea > 0.05, ret(Return) mod(FM) marketfile(Factor_returns) mar(MKT) idmar(Market_reference) factor1(SMB) factor2(HML) parallel pclus(2) proc(1) replace garch archo(1) garcho(1) archi(30)"}{p_end}

 
{title:References}

{p 4 8 2}Boehmer, E., Musumeci, J, Poulsen, A. B. 1991.
Event-study methodology under conditions of event-induced variance. {it:Journal of Financial Economics} 30(2), 253-272. {p_end}
{p 4 8 2}Brown, S. J., Warner, J. B. 1980.
Measuring security price performance. {it:Journal of Financial Economics} 8(3), 205-258. {p_end}
{p 4 8 2}Corrado, C. J. 1989.
A nonparametric test for abnormal secuity-price performance in event studies. {it:Journal of Financial Economics} 23(2), 385-395. {p_end}
{p 4 8 2}Corrado, C. J., Zivney, T. L. 1992.
The specification and power of of the sign test in event study hypothesis tests using daily stock returns. {it:Journal of Financial & Quantitative Analysis} 27(3), 465-478. {p_end}
{p 4 8 2}Cowan, A. R. 1992.
Nonparametric event study tests. {it:Review of Quantitative Finance and Accounting} 2(4), 343-358. {p_end}
{p 4 8 2}Fama, E. F., French, K. R. 1992.
The Cross-Section of Expected Stock Returns. {it:Journal of Finance} 47(2), 427-465. {p_end}
{p 4 8 2}Fama, E. F., French, K. R. 1993.
Common risk factors in the returns on stocks and bonds. {it:Journal of Financial Economics} 33(1), 3-36. {p_end}
{p 4 8 2}Kolari, J. W., Pynnönen, S. 2010.
Event study testing with cross-sectional correlation of abnormal returns. {it:Review of Financial Studies} 23(11), 3996-4025. {p_end}
{p 4 8 2}Kolari, J. W., Pynnönen, S. 2011.
Nonparametric rank tests for event studies. {it:Journal of Empirical Finance} 18(5), 953-971. {p_end}
{p 4 8 2}Lyon, J.. D., Barber, B. M., Tsai, C.-L. 1999.
Improved methods for tests of long-run abnormal stock returns. {it:Journal of Finance} 54(1), 165-201. {p_end}
{p 4 8 2}Maynes, E., Rumsey, J. 1993.
Conducting event studies with thinly traded stocks. {it:Journal of Banking and Finance} 17(1), 145-157. {p_end}
{p 4 8 2}Patell, J. M. 1976.
Corporate forecasts of earnings per share and stock price behavior: Empirical tests. {it:Journal of Accounting Research} 14(2), 246-276. {p_end}
{p 4 8 2}Serra, A. P. 2002.
Event study tests: A brief survey. {it:Working paper}. http://www.fep.up.pt/investigacao/workingpapers/wp117.pdf. {p_end}
{p 4 8 2}Wilcoxon,F. 1945.
Individual comparisons by ranking methods. {it:Biometrics Bulletin} 1(6), 80-83. {p_end}

{title:Author}

{p 4}Thomas Kaspereit{p_end}
{p 4}thomas.kaspereit@uni.lu{p_end}
