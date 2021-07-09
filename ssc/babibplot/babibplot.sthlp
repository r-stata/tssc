{smcl}
{* 2017-06-27 Lutz Bornmann}{...}
{title:Title}
{p2colset 5 14 23 2}{...}

{p2col:{cmd:babibplot} {hline 2} Plots two graph types combining journal and paper percentiles}

{p2colreset}{...}
{title:General syntax}

{p 4 18 10}
{cmdab:babibplot}
[{opt in}]
[{opt if}]
{opt , plot(scatter|average)}

{marker overview}
{title:Overview}

{pstd}
{cmd:babibplot} plots paper and journal percentiles as two graph types. The graphs can be used in research evaluation to visualize the publication performance of single researchers. The graphs show whether a researcher is able to publish in high-impact journals or to publish high-impact papers. The graph types have been introduced by Bornmann and Haunschild (2017) who explain them in detail.{p_end}

{pstd}
The paper percentile of a focal paper is an impact value below which a certain share of papers falls. The papers for comparison have been published in the same subject category and publication year as the focal paper. The journal percentile refers to the journal, in which a single paper appeared. It is an impact value below which a certain share of journals falls. The journals for comparison are from the same subject category and publication year as the focal journal.
{p_end}

{pstd}
The graphs are plotted only for those papers in the publication set without any missing values in paper and journal percentiles. The command {cmd:babibplot} runs properly if the variable including the journal percentiles is defined as the first variable and the variable including the paper percentiles as the second variable. The calculated average values are medians.
{p_end}

{marker options}
{title:Options}
{p2colset 5 12 13 0}
{synopt:{opt plot(scatter|average)}} specifies which graph type is visualized. The option {it: scatter} leads to a scatter plot of journal and paper percentiles. The horizontal and vertical red lines indicate the world averages; the red dashed lines the average values of paper and journal percentiles in the data set. The diagonal red line is the bisecting line. Points below the bisecting line indicate that the corresponding paper has a higher paper impact than journal impact and vice versa. Each row (nr) and column (nc) as well as quadrant (nq) of the scatter plot is labelled with the number and percentage of data points in the corresponding section. The values of nc1 correspond to the number and proportion of papers belonging to the 50% most frequently cited papers in the corresponding subject categories and publication years. The red squares show the average value of all data points in each quadrant. {break}
The option {it:average} leads to a scatter plot of the following two quantities: (1) difference between paper and journal impact and (2) average of paper and journal impact. The plot features two dashed red lines which indicate (1) whether there is a general tendency of the researcher to publish in journals with higher impact or to publish papers with higher impact (see the y-line). (2) They also show whether the researcher is generally able or not to publish papers in good journals which receive high impact later on (see the x-line). Papers which belong to the 10% most frequently cited papers in the corresponding subject categories and publication years are visualized as unfilled data points.

{marker examples}
{title:Examples}

{pstd}
{cmd: . babibplot journalperc paperperc, plot(average)}
{p_end}
{pstd}
<output omitted>
{p_end}
{pstd}
{cmd: . babibplot journalperc paperperc if doctyp=="review", plot(scatter)}
{p_end}
{pstd}
<output omitted>
{p_end}


{title:Literature}

{phang}Bornmann, L., & Haunschild, R. (2017). Plots for visualizing paper impact and journal impact of single researchers in a single graph, see {browse "https://arxiv.org/abs/1707.04050"}


{title:Author}

{phang}Lutz Bornmann, Max Planck Society, Munich{break}
bornmann@gv.mpg.de{p_end}