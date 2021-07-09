{smcl}
{* *! version v0.0.0.9000 25jun2018}{...}
{title:Title}

{phang}
{bf:postbfm} {hline 2} Postestimation tools for {help bfmcorr:{bf:bfmcorr}}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:postbfm} {it:subcommand} [, {it:options}]

{title:Available subcommands}

{synoptset 30 tabbed}{...}
{synopthdr:commands}
{synoptline}
{synopt:{cmd:postbfm biasplot}}display the plot of the shape of the bias and the merging point; see {help postbfm##biasplot:biasplot} for details{p_end}
{synopt:{cmd:postbfm lorenz}}display the Lorenz curves before and after the correction; see {help postbfm##lorenz:lorenz} for details{p_end}
{synopt:{cmd:postbfm summarize}}generate summary statistics of the distribution before and after the adjustment; see {help postbfm##summarize:summarize} for details{p_end}
{synopt:{cmd:postbfm factors}}generate summary statistics on the calibration factors; see {help postbfm##factors:factors} for details{p_end}
{synoptline}

{marker biasplot}{...}
{title:Subcommand postbfm biasplot}

{pstd}
The subcommand {cmd:biasplot} displays a plot with the shape of the bias and the corresponding choice of merging point.
By default, four curves are displayed on the same graph. You can hide any of them with the following options:

{phang}
{opt nosm:alltheta} do not display the estimated theta (ratio of survey to tax data probability distribution function (PDF)) for each tax data bracket

{phang}
{opt nobig:theta} do not display the ratio of the survey cumulative distribution function (CDF) to the tax data CDF

{phang}
{opt noanti:theta} do not display the antitonic estimate of theta which is used to determine the merging point

{phang}
{opt noma:theta} do not display the moving average estimate of theta;
this moving average is not used in the correction, but provides a less noisy estimate of theta without any constraints
on its shape, making easier to spot potential irregularities

{pstd}
The moving average estimate of theta can be adjusted with the option {opt win:dow(real)}, which controls the number of points
to be used in the average on each side of the current bracket. The default is 4, meaning that the command computes an average
over 9 values (current bracket plus 4 brackets on each side). Larger values give more smoothing, lower values give less smoothing.

{marker lorenz}{...}
{title:Subcommand postbfm lorenz}

{pstd}
The subcommand {cmd:lorenz} displays the Lorenz curves of the raw and the adjusted survey on the same graph.

{marker summarize}{...}
{title:Subcommand postbfm summarize}

{pstd}
The subcommand {cmd:summarize} displays a set of summary statistics on the distribution before and after correction.
By default, the results are simply displayed in the Stata output. You can specify the option {opt replace} to
save the results in memory (thus erasing the current data). You can specify the option {opth ex:port(filename)} to
export the results as an Excel file.

{marker factors}{...}
{title:Subcommand postbfm factors}

{pstd}
The subcommand {cmd:factors} displays summary statistics on the calibration factors, i.e. the ratio of calibrated
weights to original weights.

{marker reference}{...}
{title:Reference}

{pstd}
Blanchet, T., Flores, I. and Morgan, M. (2018). {browse "https://wid.world/document/the-weight-of-the-rich-improving-surveys-using-tax-data-wid-world-working-paper-2018-12/": The Weight of the Rich: Improving Surveys Using Tax Data}. WID.world Working Paper Series No. 2018/12.


{title:Contact}

{pstd}
If you have comments, suggestions, or experience any problem with this command, please contact
Thomas Blanchet ({browse "mailto:thomas.blanchet@wid.world?cc=i.floresbeale@gmail.com&cc=marc.morgan@psemail.eu":thomas.blanchet@wid.world}),
Ignacio Flores ({browse "mailto:thomas.blanchet@wid.world?cc=i.floresbeale@gmail.com&cc=marc.morgan@psemail.eu":i.floresbeale@gmail.com}) and
Marc Morgan ({browse "mailto:thomas.blanchet@wid.world?cc=i.floresbeale@gmail.com&cc=marc.morgan@psemail.eu":marc.morgan@psemail.eu}).

