use pedronidata.dta
xtset country time
xtpedroni logexrate logratio, notest lags(5) mlags(5) b(1) notdum
xtpedroni logexrate logratio, full notest lags(4) mlags(4) b(1) notdum
xtpedroni logexrate logratio, nopdols
