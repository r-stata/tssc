{smcl}
{* 11jun2017}{...}
{hline}
help for {hi:fcstats}
{hline}

{title:Time series forecast accuracy statistics}

{p 8 14}{cmd:fcstats} {it:actual forecast1} [{it:forecast2}] 
[{cmd:if} {it:exp}] [{cmd:in} {it:range}] [{cmd:graph)} * ]

{p}{cmd:fcstats} is for use with time-series data.  You must {cmd:tsset} your
data before using {cmd:fcstats}; see help {help tsset}. {cmd:fcstats} may be applied to
one unit of a panel.

{p} {it:actual, forecast1, forecast2} may contain time-series operators; see help {help varlist}.


{title:Description}

{p}{cmd:fcstats} calculates several measures of forecast accuracy for one or two forecast
series. The measures include root mean squared error (RMSE), mean absolute error (MAE), 
mean absolute percent error (MAPE) and Theil's U. 

{p}Theil's U statistic (1966), sometimes termed U2, is based on the concept of information entropy.
It can be considered as the RMSE of the forecast divided by the RMSE of the naive model, 
y(t+1)=y(t). Theil's U takes on a value
of 1 if the forecasting method is no more accurate than a naive forecast.
If it is less than 1, the forecasting method is more accurate than a naive forecast, and
vice versa.

{p}

{title:Options}

{p 0 4}{cmd:graph} specifies that a {cmd:tsline} plot of the actual and forecast series
is to be produced.

{p 0 4}{cmd:*} allows the specification of any options available in {cmd:tsline} to modify
the graph. 

{title:Returned items}

{p 0 4}All calculated statistics are returned as scalars, as is the number of observations
used in the calculations. The names of the series are also returned as local macros.

{title:Examples}

{p 8 12}{stata "use http://fmwww.bc.edu/ec-p/data/macro/barclaymonthly.dta,clear":. use http://fmwww.bc.edu/ec-p/data/macro/barclaymonthly.dta,clear}

{p 8 12}{stata "fcstats bbjpysp L.bbjpy1f ":. fcstats bbjpysp bbjpy1f }

{p 8 12}{stata "fcstats bbjpysp L.bbjpy1f L2.bbjpy2f, graph":. fcstats bbjpysp L.bbjpy1f L2.bbjpy2f, graph}

{p 8 12}{stata "fcstats bbjpysp L.bbjpy1f L2.bbjpy2f, graph ylab(,angle(0) labs(small)) scheme(s2mono)":. fcstats bbjpysp L.bbjpy1f L2.bbjpy2f, graph ylab(,angle(0) labs(small)) scheme(s2mono)}

{title:References}

Theil, H. (1966), Applied Economic Forecasting. Chicago: Rand McNally.

{title:Author}

Christopher F Baum, Boston College, USA, baum@bc.edu

{title:Acknowledgements}
Development of this routine was stimulated by an engagement at the Asian Development Bank.

{title:Also see}

{p 0 19}On-line:  help for {help predict}
{help dmariano}  (if installed), {help giacross}  (if installed),{help rosssekh} (if installed)
 {p_end}

