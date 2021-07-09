{smcl}
{* 2017-06-27 Lutz Bornmann}{...}
{title:Title}
{p2colset 5 14 15 2}{...}

{p2col:{cmd:bibrep} {hline 2} Produces a bibliometric report on a single senior researcher (working in the natural or life sciences) using especially journal and paper percentiles as data sources. The report is saved as Word file (.docx)}

{p2colreset}{...}
{title:General syntax}

{p 4 21 10}
{cmdab:bibrep} {it:varlist} {cmd:, } {cmd:ename({it:string}}{cmd:)} {cmd:vname({it:string}}{cmd:)} {cmd:aname({it:string}}{cmd:)} {cmd:fold({it:string}}{cmd:)} {cmd:pyear({it:integer}}{cmd:)} {cmd:cyear({it:integer}}{cmd:)}

{title:Requirements}

{p 4 4 2} The Stata commands/packages {cmd:babibplot} (Bornmann & Haunschild, 2017), {cmd:beamplot} (Bornmann & Marx, 2014), {cmd:nwcommands} (see {browse "https://nwcommands.wordpress.com"}),  and {cmd:tabplot} must be installed. They can be found in the SSC Archive. {cmd:bibrep} needs Stata 15.

{title:Options} 

{p 4 10 2}{cmd:ename} specifies the full name of the author producing the report. 

{p 4 10 2}{cmd:vname} specifies the full name of the assessed researcher. 

{p 4 10 2}{cmd:aname} specifies the initials of the first and last names of the assessed researcher. 

{p 4 10 2}{cmd:fold} specifies the folder in which the produced files are saved. 

{p 4 10 2}{cmd:pyear} specifies the most recent publication year for the citation analysis. 

{p 4 10 2}{cmd:cyear} specifies the year to which the citation window ends. 

{title:Overview}

{pstd}
{cmd:bibrep} produces a bibliometric report (saved as Word file in the .docx format) on the performance of a single researcher. The following 14 variables including data on the paper level are necessary in the specified order: (1) Publication year of the paper; (2) Document type of the paper. The string variable contains only three types coded as "article", "review", or "other"; (3) Name of the first author (e.g. "Bornmann, L."); (4) Number of co-authors; (5) Journal title; (6) Title of the paper; (7) Volume; (8) Issue; (9) First page; (10) Country codes of the authors (without duplicates). For example, if two authors are from Germany and three from the USA, the country codes for the paper are: "de,us"; (11) Number of countries with which the authors are affiliated (counted without duplicates). For the example above, the number of countries is 2; (12) Citation counts; (13) Paper percentile; and (14) Journal percentile. The percentiles are between 0 and 100 whereby small values denote more citation impact than high values (Bornmann, Leydesdorff, and Mutz, 2013). The data should be derived from Web of Science (Clarivate Analytics, {browse "https://clarivate.com"})
{p_end}

{pstd}
The report contains results on the output and citation impact of the researcher. It is necessary that the researcher is a senior researcher - working in the natural or life sciences - who has published at least 30 articles and/or reviews. At least two-thirds of the papers should have appeared more than three years ago. The results (and the used indicators and methods) of the bibliometric analyses are explained (contextualized) in the report. It is important that the user of {cmd:bibrep} checks the results and revises them accordingly.
{p_end}

{pstd}
To facilitate the check of the reported results, the results are also displayed in Stata. When the report was saved as Word file, the user can revise this file further on. For example, detailed interpretations of the results can be added. The command can be tested with an example dataset (containing the publication set of the command's author). This dataset can be downloaded at {browse "https://figshare.com/articles/Example_dataset_for_bibrep_ado/5414755"}.
{p_end}

{title:Example}

{pstd}
. bibrep pub_year doc_type first_author num_author journal_title paper_title volume issue first_page country_codes num_country times_cited paper_percentile journal_percentile, ename(Lutz Bornmann) vname(Lutz Bornmann) aname(LB) fold(C:\SkyDrive\Arbeit\putdocx) pyear(2014) cyear(2016)

{title:References}

{phang}Bornmann, L., Leydesdorff, L., & Mutz, R. (2013). The use of percentiles and percentile rank classes in the analysis of bibliometric data: opportunities and limits. Journal of Informetrics, 7(1), 158-165.{p_end}
{phang}Bornmann, L., & Haunschild, R. (2017). Plots for visualizing paper impact and journal impact of single researchers in a single graph, see {browse "https://arxiv.org/abs/1707.04050"}.{p_end}
{phang}Bornmann, L., & Marx, W. (2014). How to evaluate individual researchers working in the natural and life sciences meaningfully? A proposal of methods based on percentiles of citations. Scientometrics, 98(1), 487-509.{p_end}

{title:Author}

{phang}Lutz Bornmann, Max Planck Society, Munich{break}
bornmann@gv.mpg.de{p_end}