{smcl}
{* 2017-07-19 Lutz Bornmann}{...}
{title:Title}
{p2colset 5 14 23 2}{...}

{p2col:{cmd:plotrpys} {hline 2} uses CSV export from CRExplorer ({browse "http://www.crexplorer.net/"}) and plots a spectrogram}

{p2colreset}{...}
{title:General syntax}

{p 4 18 10}
{cmdab:plotrpys}
{opt , color(col|mono) curve(both|median|sample}
[{startyr(year) incre(numeric) endyr(year)}]


{marker overview}
{title:Overview}

{pstd}
{cmd:plotrpys} uses CSV export from CRExplorer ({browse "http://www.crexplorer.net/"}) and plots a spectrogram. After import of the CSV file in Stata, the command needs three variables in this order: (1) cited references year, (2) cited references counts, and (3) deviation from the median. The command demands the specifications whether coloured or monochrome spectrograms are required as well as which curves should be plotted. The command requires the module "blindschemes" and the graph scheme "plottig" (Bischof, 2017).{p_end}
{pstd}
If only median deviations are plotted, two dotted lines are included. These lines going back to Turkey's fences are intended to support the identification of the most important peaks in the spectrogram. Tukey (1977) proposed a method for detecting outliers, which can be used to flag important peaks based on the interquartile range of the median deviations (with positive values). If Q1 and Q3 define this range with lower and upper quartiles, the following formula can be used to detect "outlier" peaks above this range: [Q3 + k (Q3 – Q1)]. According to Tukey (1977), k = 1.5 indicates "outliers" and k = 3 cases, which are "far out".{p_end}
{pstd}
CRExplorer draws samples from imported cited references data. If sample data are plotted, the sample option can be selected to visualize cited references counts with 95% confidence intervals (CIs). Lower and upper bounds are shown instead of the cited references counts. The CIs are estimations of the range of an annual cited references count in the population (the cited references data of which the sample has been drawn). The CIs are calculated by using the invchi2 function in Stata: invchi2(2 * x, 0.025)/2 (lower bounds), invchi2(2 * (x + 1), 0.975)/2 (upper bounds), whereby x is the annual cited references count.
{p_end}

{marker options}
{title:Options}
{p2colset 5 12 13 0}
{synopt:{opt color(col|mono)}} specifies whether the plot is colored or monochrome.

{synopt:{opt curve(both|median|sample)}} specifies whether both cited references counts and deviations from median,  only deviations from median, or CIs of cited references counts are plotted.

{synopt:{opt startyr(year)}} specifies the first year on the x-axis.

{synopt:{opt endyr(year)}} specifies the last year on the x-axis.

{synopt:{opt incre(numeric)}} specifies the increments in years on the x-axis.

{marker examples}
{title:Examples}

{pstd}
{cmd: . plotrpys year ncr median5, color(col) curve(both)}
{p_end}

{pstd}
{cmd: . plotrpys year ncr median5, color(mono) curve(median) startyr(1600) incre(50) endyr(1980)}
{p_end}

{title:Literature}

{phang}Bischof, D. (2017). New graphic schemes for Stata: plotplain and plottig. Stata Journal, 17(3), 748-759.
{phang}Tukey, J. W. (1977). Exploratory Data Analysis: Addison-Wesley Publishing Company

{title:Author}

{phang}Lutz Bornmann, Max Planck Society, Munich{break}
bornmann@gv.mpg.de{p_end}