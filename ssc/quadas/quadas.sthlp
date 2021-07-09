
{smcl}
{* *! version 1.00 06October2010}{...}
{hline}
help for {cmdab:quadas} {right: (Ben Adarkwa Dwamena)}

{hline}

{title:quadas: Graphical depiction of quality assessment in diagnostic accuracy reviews}

{title:Syntax}

{p 8 18 2}
{cmdab:quadas}
{it:varlist} 
[{opt if} {it:exp}]
[{opt in} {it:range}]
[{opt ,} 
{opt options} *] 

{dlgtab:OPTIONS}

{pmore}
{opt sum} creates 
a figure summarizing compliance of individual studies 
with methodologic quality items (varlist) scored yes, unclear, or no    

{pmore}
{opt bar} plots a bar graph of overall frequency of compliance 
with methodologic quality items (varlist) scored yes, unclear, or no

{pmore}
{opt color} bar or summary graph generated in color with yes=green, unclear=yellow and no=red.

{pmore}
may use graph editor or other twoway options to edit default appearance.

{title:Remarks}

{pmore}
Quality assessment of primary studies in systematic reviews assist in identifying potential sources of bias and to limit the effects of these biases on the estimates and the conclusions of the review. Quality appraisal offers
a general impression of the validity of the available evidence. The Cochrane Diagnostic Test Accuracy Working Group recommends the QUADAS (Quality Assessment of Diagnostic Accuracy Studies) checklist
to assess the quality of diagnostic test accuracy studies. QUADAS is a rigorously constructed and validated tool that can be used by investigators undertaking new systematic reviews. The QUADAS tool consists of 14 items that cover patient spectrum, reference standard,
disease progression bias, verification and review bias, clinical review bias, incorporation bias, test execution, study withdrawals, and intermediate results. 

{pmore}
The results may be summarized using:

{pmore}
(1) Methodological quality graph(example appended Quadas1.pdf): review authors' judgments about each methodological quality item for each included study.

{pmore}
(2) Methodological quality summary(example appended Quadas2.pdf): review authors' judgments about each methodological quality item presented as percentages across all included studies

{pmore}
Although not implemented in quadas, 1n the analysis phase of systematic review, the results of the quality appraisal may guide explorations of the sources of heterogeneity. Possible methods to address quality differences are sensitivity analysis, subgroup analysis, or meta-regression analysis, although the number of included studies may often be too small for meaningful investigations. Also, incomplete reporting hampers any evaluation of study quality. 

{title:Examples}

{phang2}
{stata "use http://sitemaker.umich.edu/metadiagnosis/files/quadas.dta": use http://sitemaker.umich.edu/metadiagnosis/files/quadas.dta}

{pmore}
Methodolgical Quality Graph

{phang2}
{stata "quadas spect select ref incorp testdesc refdesc blintest blinref clin indeterm withdraw, bar col": quadas spect select ref incorp testdesc refdesc blintest blinref clin indeterm withdraw, bar col}
{p_end}

{pmore}
Methodolgical Quality Summary

{phang2}
{stata "quadas spect select ref incorp testdesc refdesc blintest blinref clin,  id(studid) sum col ysiz(7) xsiz(4)": quadas spect select ref incorp testdesc refdesc blintest blinref clin, id(studid) sum col ysiz(7) xsiz(4)}
{p_end}


{title:References}

{pmore}
Whiting P, Rutjes AW, Reitsma JB, Bossuyt PM, Kleijnen J. 
The development of QUADAS: a tool for the quality assessment of studies of diagnostic accuracy included in systematic reviews. 
BMC Med Res Methodol 2003;3:25

{pmore}
Leeflang MM, Deeks JJ, Gatsonis C, Bossuyt PM, Cochrane Diagnostic Test Accuracy Working Group.
Systematic reviews of diagnostic test accuracy.
Ann Intern Med. 2008;149(12):889-897

{title:Author}

{pmore}
{browse "http://www.sitemaker.umich.edu/metadiagnosis":Ben A. Dwamena}, Division of Nuclear Medicine, 
Department of Radiology, University of Michigan, USA
Email {browse "mailto:bdwamena@umich.edu":bdwamena@umich.edu} for problems, comments and suggestions

{title:Citation}

{pmore}
{cmd:quadas} is not an official Stata command. It is a free contribution to the research community, like a paper. 
{title:Suggested citation if using {cmd:quadas} in published work:}

{pmore}
{title:Dwamena, Ben A.(2010)}
{hi: quadas: A program for graphical depiction of study quality assessment for diagnostic test accuracy reviews.}
Division of Nuclear Medicine, Department of Radiology, University of Michigan Medical School, Ann Arbor, Michigan.




	
	

