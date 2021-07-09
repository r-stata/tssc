program def bibrep, rclass
*! bibrep v1.0.0 LutzBornmann September2018
version 15

syntax varlist(min=14 max=14), ename(string `ename') vname(string `vname') aname(string `aname') fold(string `fold') pyear(integer `pyear') cyear(integer `cyear')
local ITEM_PY: word 1 of `varlist'
local dt: word 2 of `varlist'
local First_author: word 3 of `varlist'
local ITEM_ITAU_N: word 4 of `varlist'
local Journal: word 5 of `varlist'
local Title: word 6 of `varlist'
local Volume: word 7 of `varlist'
local Issue: word 8 of `varlist'
local Page: word 9 of `varlist'
local ITEM_ITCO_CODES: word 10 of `varlist'
local ITEM_ITCO_N: word 11 of `varlist'
local ITEM_ITXC_N: word 12 of `varlist'
local ITEM_IPERCBO1_AVG: word 13 of `varlist'
local jif_perc: word 14 of `varlist'


local verz : display "`fold'"
local zyear : display "`cyear'"

*ename = Full name of the bibliometrician
*vname = Full name of the researcher
*aname = Abbreviated name of the researcher
*fold = Which folder should be used for the output files of the program?
*pyear = Which publication year is the most recent year for the citation analysis?
*cyear = Which year is the most recent year in which citations are counted?

set dp period
save `verz'\initial_dataset, replace

putdocx begin, font(Arial, 12) pagesize(A4)

putdocx paragraph
putdocx text ("Bibliometric evaluation of `vname'"), bold
putdocx paragraph
putdocx paragraph
putdocx text ("created by `ename'"), bold
putdocx paragraph
putdocx paragraph
putdocx paragraph
putdocx paragraph
putdocx paragraph
putdocx paragraph
putdocx paragraph
putdocx text ("Introduction"), bold
putdocx paragraph
putdocx text ("The bibliometric evaluation of `vname' (`aname') uses methods presented in Bornmann and Marx (2014). The data basis underlying the evaluations is Clarivate Analytics' (previously Thomson Reuters') Web of Science (WoS). This report is mainly based on normalized indicators, which have been calculated on the basis of WoS data. The normalized indicators are impact scores, which are standardized according to the impact of publications with the same subject categories and publication years (Bornmann & Marx, 2015).")
putdocx paragraph
putdocx paragraph
putdocx text ("Results"), bold
putdocx paragraph
display " "
display "---------------------------------------"
display "Number of all papers of the researcher"
count
local sum : display `r(N)'
putdocx text ("In total, `sum' papers could be identified in the WoS, where `aname' was named as an author (taking into account the institutions where `aname' worked). These papers relate to the period ")
display " "
display "---------------------------------------"
display "First and last publication year of the researcher"
sum `ITEM_PY'
putdocx text ("from `r(min)' to `r(max)'. Since it is common in bibliometrics to include only articles and reviews (i.e. substantial and citable papers) in the evaluation, the study includes ")
qui keep if `dt'=="article" | `dt'=="review"
display " "
display "---------------------------------------"
display "Number of articles and reviews of the researcher considered in the study"
tab `dt'
qui count
local sum_t : display `r(N)'
qui count if `dt'=="article"
local sum_a : display `r(N)'
qui count if `dt'=="review"
local sum_r : display `r(N)'
putdocx text ("`sum_t' papers (`sum_a' ")
if `sum_a' == 1 {
 putdocx text ("article")
 } 
 else {
 putdocx text ("articles")
 }
putdocx text (" and `sum_r' ")
if `sum_r' == 1 {
 putdocx text ("review). ")
 } 
 else {
 putdocx text ("reviews). ")
 }
display " "
display "---------------------------------------"
display "Number of articles and reviews with one author"
count if  `ITEM_ITAU_N'==1
putdocx text ("Of these papers, `aname' published `r(N)' ")
if `r(N)' == 1 {
 putdocx text ("paper")
 } 
 else {
 putdocx text ("papers")
 }
putdocx text (" as single author and ")
display " "
display "---------------------------------------"
display "Number of articles and reviews with more than one authors"
count if  `ITEM_ITAU_N'>1
putdocx text ("`r(N)' ")
if `r(N)' == 1 {
 putdocx text ("paper")
 } 
 else {
 putdocx text ("papers")
 }
putdocx text (" together with co-authors. ")
display " "
display "---------------------------------------"
display "Mean number of authors for articles and reviews"
sum `ITEM_ITAU_N'
qui sum `ITEM_ITAU_N'
local aunum : display %4.2f `r(mean)'
putdocx text ("`aname''s publications have `aunum' co-authors on average.")
putdocx paragraph
putdocx text ("Figure 1 shows the distribution of the articles and reviews across publication years.")

putdocx paragraph
putdocx pagebreak
qui tabplot `ITEM_PY', showval(offset(0.2) mlabcolor(black))  /*
*/ bcolor(ltblue) subtitle(" ") ytitle("Publication year") xtitle(" ")/*
*/ ysize(12) scale(1.4) horizontal
qui graph export `verz'\publ.png, replace
putdocx paragraph, halign(center)
putdocx image `verz'\publ.png
putdocx paragraph
putdocx text ("Figure 1. Distribution of articles and reviews across publication years")
putdocx paragraph
putdocx paragraph
display " "
display "---------------------------------------"
display "Number of articles and reviews by publication year"
tab `ITEM_PY'

display " "
display "---------------------------------------"
display "Number of papers with JIF percentile"
sum `jif_perc'
putdocx text ("For `r(N)' of `aname''s `sum_t' papers, a Journal Impact Factor (JIF) is available for the journal in which the papers appeared. JIF is a journal metric, which measures the mean number of citations within one year of papers published in the two preceding years (Bornmann, Marx, Gasparyan, & Kitas, 2012). ")
recode `jif_perc' (min/25=1 "First quartile journal") (25.0000001/max=0 "Non first quartile journal"), gen(ITEM_IJIFQ1V1_BEST) label(ITEM_IJIFQ1V1_BEST)
display " "
display "---------------------------------------"
display "Recode of the variable JIF percentiles in the variable Q1. Q1 is a binary variable with 1=journal belongs to the first quartile in its subject category and publication year; 0=Journal belongs to the second, third, or fourth quartile"
tabstat `jif_perc', stats(min max n) f(%8.4f) by(ITEM_IJIFQ1V1_BEST)
display " "
display "---------------------------------------"
display "Number of papers in first quartil journals"
tab ITEM_IJIFQ1V1_BEST
qui sum ITEM_IJIFQ1V1_BEST
local jif : display %4.2f `r(mean)'*100
putdocx text ("`jif'% ")
qui count if ITEM_IJIFQ1V1_BEST==1
putdocx text ("(n=`r(N)') of these papers appeared in a journal which -- measured by the JIF -- belongs to the 25% most-frequently cited in their subject category. ")
qui sum ITEM_IJIFQ1V1_BEST
local jif_1 : display %4.1f `jif'/40
putdocx text ("`aname' has thus published`jif_1' times as many papers in journals from the first quartile as one could expect for `aname' (the expected value is around 40%) (Liu, Hu, & Gu, 2016).")
putdocx paragraph
putdocx pagebreak
putdocx paragraph
display " "
display "---------------------------------------"
display "Comparison of the Q1 indicator for the researcher with the expected value of 40"
sum ITEM_IJIFQ1V1_BEST
display `r(mean)'*100/40

display " "
display "---------------------------------------"
display "Number of papers with more than one country"
count if `ITEM_ITCO_N'>1
putdocx text ("Scientific knowledge is increasingly produced in collaboration, which is reflected in an increasing number of co-authored papers (Gingras, 2016). `aname' has published `r(N)' ")
if `r(N)' == 1 {
 putdocx text ("paper")
 } 
 else {
 putdocx text ("papers")
 }
putdocx text (" in international collaboration (")
local col : display %4.2f `r(N)'/`sum_t' *100
putdocx text ("`col'%); ")
local col_1 : display %4.2f 100-`col'
putdocx text ("`col_1'% of the papers have been published without crossing the national borders.")
putdocx text (" Figure 2 visualizes the network of countries, in which co-authors of papers in `aname''s publication set are located (`aname''s own affiliations are also considered). The countries are labeled with their ISO codes to improve the readability of the network. If unknown, the country names for specific ISO codes can be found at https://countrycode.org. The network is based on all papers in the set with co-authors from more than one country. If a paper was published by more than one author from a specific country, this country was included only once in the analysis. For example, if two authors of a paper are from Germany and four from the US, the network analysis considers the collaboration just once.")

qui save `verz'\initial_dataset_1, replace
keep  `ITEM_ITCO_CODES'
qui split `ITEM_ITCO_CODES', parse(,) gen(co)
local co_h = `r(nvars)'
drop  `ITEM_ITCO_CODES'
forvalues j = 1/`co_h' {
encode co`j', generate(rco`j') label(co)
}
keep rco1-rco`co_h'
keep if rco2~= .
gen group=_n
qui reshape long rco, i(group) j(id)
keep if rco~= .

sort group
by group: gen gfreq = _N
expand gfreq
sort group rco
by group rco: gen numid2 = _n
by group: gen rco2 = rco[gfreq * numid2]
drop if rco == rco2
drop if rco > rco2
label values rco2 co
decode rco, gen(co)
decode rco2, gen(co2)

nwset co co2, edgelist undirected keeporiginal
qui nwplot, lab
qui graph export `verz'\co.png, replace
putdocx paragraph, halign(center)
putdocx image `verz'\co.png
putdocx paragraph
putdocx text ("Figure 2. Network of countries, in which co-authors of papers in `aname''s publication set are located")
putdocx paragraph
putdocx paragraph
putdocx text ("The country, in which `aname' was located most of the time (this may be more than one country), is positioned in the center of the network. The closer countries are positioned to the center, the more `aname' has collaborated with authors from these countries. Dense networks of countries point to intensive collaboration activities.")
use `verz'\initial_dataset_1, clear

putdocx paragraph
putdocx text ("Since many recently published papers have been cited hardly or not at all, no reliable and valid statement can be made on their 'true' impact (Wang, 2013). The data, which has been used for this report, includes citations until the end of `zyear'. To enable a citation window of at least three years for every paper (which is standard in bibliometrics, see Glaenzel & Schoepflin, 1995), the citation analysis covers ")
keep if `ITEM_PY'<=`pyear'
display " "
display "---------------------------------------"
display "Number of articles and reviews which are considered in the citation analyses"
count
putdocx text ("`aname''s `r(N)' papers, which were published until the end of `pyear'. ") 
display " "
display "---------------------------------------"
display "Number of papers with 0 citations"
count if `ITEM_ITXC_N'==0
putdocx text ("`r(N)' ")
if `r(N)' == 1 {
 putdocx text ("paper has")
 } 
 else {
 putdocx text ("papers have")
 }
putdocx text (" gathered no citation until the end of `zyear'; ")
display " "
display "---------------------------------------"
display "Number of papers with at least 1 citation"
count if `ITEM_ITXC_N'>0
putdocx text ("`r(N)' ")
if `r(N)' == 1 {
 putdocx text ("paper has")
 } 
 else {
 putdocx text ("papers have")
 }
putdocx text (" at least one citation. ")
qui count
putdocx text ("Of the total of `r(N)' papers, ")
display " "
display "---------------------------------------"
display "Recode of the variable paper percentiles in the variable P(top10%). P(top10%) is a binary variable with 1=paper belongs to the 10% most cited papers in its subject category and publication year; 0=paper belongs to the bottom 90% in its subject category and publication year"
egen pr2=cut(`ITEM_IPERCBO1_AVG'), at(0,10.1,101)
tabstat `ITEM_IPERCBO1_AVG', stats(min max n) f(%8.4f) by(pr2)
qui recode pr2 (1/max=0 "top 10% paper") (0=1 "bottom 90% paper"), gen(pr2_rec)
display " "
display "---------------------------------------"
display "Number of top 10% and bottom 90% papers"
tab pr2_rec
qui sum pr2_rec
local pr2_rec : display %4.2f `r(mean)'*100
putdocx text ("`pr2_rec'% ")
qui count if pr2_rec==1
putdocx text ("(n=`r(N)') belong to the 10% most frequently cited papers in their subject area and publication year. ")
sum pr2_rec
local pr2_t : display %4.1f `r(mean)'*10
putdocx text ("`aname' has thus published`pr2_t' times as many highly cited papers as one could expect (expected value = 10%).")
display " "
display "---------------------------------------"
display "Comparison of the P(top10%) indicator for the researcher with the expected value of 10"
qui sum pr2_rec
display `r(mean)'*100/10

putdocx paragraph
putdocx text ("The use of percentiles (also known as percent ranks) allows the impact of papers from different subject categories and publication years to be compared directly. The percentile of a particular work indicates the impact that this work has achieved in comparison with similar papers (which have appeared in the same subject category and publication year). A paper, which appeared, for example, in the year 2000 in ")
putdocx text ("Physical Review B "), italic
putdocx text ("is measured against all the papers from 2000 which appeared in the WoS subject category 'Physics, Condensed Matter'. A percentile of 50 corresponds to average impact. A percentile of 10 means that 90% of comparable papers have achieved a lower impact: the paper in question belongs to the 10% of most frequently cited papers from the same year and in the same subject category.")
putdocx paragraph
putdocx text ("The definition of the percentiles used in this study is based on the definition used by Clarivate Analytics for the InCites database (Bornmann, Leydesdorff, & Mutz, 2013). The scale ranges from 100 (low citation impact) to 0 (high citation impact) (see http://researchanalytics.thomsonreuters.com/incites/).")
putdocx paragraph
putdocx text ("A researcher's number of papers and their citation impact (measured in percentiles) can be represented jointly in beam plots (see Figure 3). Beam plots allow one to see at a glance in which years a researcher was particularly (un)productive and how often their papers were cited in comparison with similar papers.")

putdocx pagebreak
display " "
display "---------------------------------------"
display "Median of paper percentiles"
sum `ITEM_IPERCBO1_AVG', detail
local perc_3 = `r(p50)'
sum `ITEM_PY'
local byear = `r(min)'
local eyear = `r(max)'
qui beamplot `ITEM_IPERCBO1_AVG', over(`ITEM_PY') summary(median) height(0.4)/*
*/ ytitle("Publication year") xtitle("Percentile") /*
*/ xline(50, lwidth(medthick) lcolor(gs7) lpattern(dash)) /*
*/ xline(`perc_3', lwidth(medthick) lcolor(red) lpattern(dash)) /*
*/ xlabel(0(10)100) dots(msize(small) mcolor(gs7) msymbol(D))/*
*/ ylabel(`byear'(1)`eyear')  ysize(10)/*
*/ beam(lcolor(black)) fulcrum(lcolor(black) mcolor(red) msize(large)) xscale(reverse)/*
*/ xtitle("Low impact ----------- Percentile ----------- High impact")
qui graph export `verz'\beam.png, replace
putdocx paragraph, halign(center)
putdocx image `verz'\beam.png, width(10 cm) height(18 cm)
putdocx paragraph
putdocx text ("Figure 3. Beam plot of `aname''s productivity and the impact of the publications")

putdocx pagebreak
putdocx paragraph
qui count
putdocx text ("Figure 3 shows `aname''s individual papers (n=`r(N)') as black diamonds. The bandwidth of the citation impact of the papers in the individual publication years extends from left (lower citation impact) to right (higher citation impact). The median of the percentiles for an individual publication year is shown as a red triangle. The vertical black dashed line corresponds to an average impact in the corresponding subject categories and publication years (the expected average citation impact is the percentile of 50). The vertical red dashed line shows the median of all percentiles for `aname''s papers.")
putdocx paragraph
qui sum `ITEM_IPERCBO1_AVG', detail
local perc_1 : display %4.2f `r(p50)'
local perc_2 = round(`r(p50)')
putdocx text ("The median of `perc_1' in Figure 3 means that `aname' has published papers, which belong on average to the `perc_2'% most frequently cited papers in the particular subject category and publication year.")
putdocx paragraph
putdocx text ("Bornmann and Haunschild (2017) have suggested not only presenting the publication output and the impact of the publications in a diagram, but also comparing the success of the researchers (1) in publishing their work in good journals or (2) in achieving high impact with their publications. Figure 4 shows a scatter plot with the impact of the journals in which `aname' has published on the y-axis, and the impact of the individual publications on the x-axis. Both indicators are based on percentiles (see above). To calculate the journal percentile, all the journals within a subject area and publication year are ordered according to their JIF rank. The percentile for a journal indicates which percentage of the other journals scored better than the journal in question.")
putdocx paragraph
keep if `jif_perc'~= . & `ITEM_IPERCBO1_AVG'~= .
display " "
display "---------------------------------------"
display "Median of journal and paper percentiles (without missings in both variables)"
sum `jif_perc', detail
local perc_3 : display %4.2f `r(p50)'
sum `ITEM_IPERCBO1_AVG', detail
local perc_4 : display %4.2f `r(p50)'
count
putdocx text ("Figure 4 includes the `r(N)' of `aname''s publications, which have percentiles for both indicators. The figure is divided into four quadrants. Quadrant q3 is the quadrant in which both the impact of the journals as well as that of the individual papers is above average. The more publications a researcher has in this quadrant, the better they have scored overall. A large number of publications in q2 and q3 indicates a very high level of impact for the individual publications. A large number of publications in q3 and q4 shows that the person has published in high impact journals. The dashed red lines in Figure 4 show the medians of the percentiles (journals and individual publications). In the journal percentiles, `aname' achieves a median of `perc_3', and in the individual publication percentiles a median of `perc_4'.")

if `perc_3' <  `perc_4' {
 putdocx text (" Thus, `aname' was more able to publish in good journals than to publish papers with higher impact.")
 } 
 else if `perc_3' >  `perc_4' {
 putdocx text (" Thus, `aname' was more able to publish papers with higher impact than to publish in good journals.")
 }  
 else {
 putdocx text (" Thus, `aname' was equally able to publish papers with higher impact and to publish in good journals.")
 }

putdocx text (" The red squares in the figure indicate the average values of the percentiles in each quadrant.")


qui babibplot `jif_perc' `ITEM_IPERCBO1_AVG', plot(scatter)
qui graph export `verz'\scatt.png, replace
putdocx paragraph, halign(center)
putdocx image `verz'\scatt.png
putdocx paragraph
putdocx text ("Figure 4. Scatter plot showing `aname''s success in publishing in high impact journals and/or publishing high impact publications")

putdocx pagebreak
putdocx paragraph
putdocx text ("References"), bold
putdocx paragraph
putdocx text ("Bornmann, L., & Haunschild, R. (2017). ")
putdocx text ("Plots for visualizing paper impact and journal impact of single researchers in a single graph."), italic
putdocx text (" Retrieved July 27, 2017, from https://arxiv.org/abs/1707.04050.")
putdocx paragraph
putdocx text ("Bornmann, L., & Marx, W. (2014). How to evaluate individual researchers working in the natural and life sciences meaningfully? A proposal of methods based on percentiles of citations.")
putdocx text (" Scientometrics, 98"), italic
putdocx text ("(1), 487-509.")
putdocx paragraph
putdocx text ("Bornmann, L., & Marx, W. (2015). Methods for the generation of normalized citation impact scores in bibliometrics: Which method best reflects the judgements of experts? ")
putdocx text ("Journal of Informetrics, 9"), italic
putdocx text ("(2), 408-418.")
putdocx paragraph
putdocx text ("Bornmann, L., Leydesdorff, L., & Mutz, R. (2013). The use of percentiles and percentile rank classes in the analysis of bibliometric data: opportunities and limits. ")
putdocx text ("Journal of Informetrics, 7"), italic
putdocx text (" (1), 158-165.")
putdocx paragraph
putdocx text ("Bornmann, L., Marx, W., Gasparyan, A. Y., & Kitas, G. D. (2012). Diversity, value and limitations of the Journal Impact Factor and alternative metrics. ")
putdocx text ("Rheumatology International (Clinical and Experimental Investigations), 32"), italic
putdocx text ("(7), 1861-1867.")
putdocx paragraph
putdocx text ("Gingras, Y. (2016). ")
putdocx text ("Bibliometrics and research evaluation: uses and abuses."), italic
putdocx text (" Cambridge MA, USA: MIT Press.")
putdocx paragraph
putdocx text ("Glaenzel, W., & Schoepflin, U. (1995). A bibliometric study on aging and reception processes of scientific literature.")
putdocx text (" Journal of Information Science, 21"), italic
putdocx text (" (1), 37-53.")
putdocx paragraph
putdocx text ("Liu, W. S., Hu, G. Y., & Gu, M. D. (2016). The probability of publishing in first-quartile journals. ")
putdocx text ("Scientometrics, 106"), italic
putdocx text ("(3), 1273-1276.")
putdocx paragraph
putdocx text ("Wang, Jian. (2013). Citation time window choice for research impact evaluation. ")
putdocx text ("Scientometrics, 94"), italic
putdocx text ("(3), 851-872.")

qui drop  ITEM_IJIFQ1V1_BEST pr2 pr2_rec
qui graph close _all

local sav : display `"`verz'"' "\" `"`aname'"'
putdocx save `sav', replace

*Appendix

use `verz'\initial_dataset, clear
qui keep if `dt'=="article" | `dt'=="review"

keep `Journal'
gen Number=1
replace Number= . if `Journal'==" "
collapse (count) Number, by(`Journal')
gsort- Number `Journal'

putdocx begin, font(Arial, 10) pagesize(A4) landscape
putdocx paragraph
putdocx text ("Appendix"), bold
putdocx paragraph
putdocx paragraph
putdocx text ("Table A1. Journals, in which `aname' has published (n=`sum_t' articles and reviews, sorted in descending order)")
putdocx table tbl1 = data("`Journal' Number"), varnames
putdocx table tbl1(.,1), italic
putdocx table tbl1(1,1) = ("Journal")
putdocx table tbl1(1,2) = ("Number of papers")
putdocx pagebreak

use `verz'\initial_dataset, clear
qui keep if `dt'=="article" | `dt'=="review"
qui keep if `ITEM_PY'<=`pyear'
gsort+ `ITEM_IPERCBO1_AVG'
keep `First_author' `ITEM_PY' `Title' `Journal' `Volume' `Issue' `Page' `ITEM_ITXC_N' `ITEM_IPERCBO1_AVG' `jif_perc'

putdocx paragraph
format `ITEM_IPERCBO1_AVG' `jif_perc' %9.2f
qui count
putdocx text ("Table A2. Papers by `aname', which have been included in the bibliometric report (n=`r(N)' papers, which were published up to the end of `pyear', sorted in ascending order by paper percentiles)")
putdocx table tbl2 = data("`First_author' `ITEM_PY' `Title' `Journal' `Volume' `Issue' `Page' `ITEM_ITXC_N' `ITEM_IPERCBO1_AVG' `jif_perc'"), varnames
putdocx table tbl2(1,1) = ("First author")
putdocx table tbl2(1,2) = ("Publication Year")
putdocx table tbl2(.,3), font(Arial, 8)
putdocx table tbl2(1,3), font(Arial, 10)
putdocx table tbl2(1,3) = ("Title")
putdocx table tbl2(.,4), italic
putdocx table tbl2(1,4) = ("Journal")
putdocx table tbl2(1,5) = ("Volume")
putdocx table tbl2(1,6) = ("Issue")
putdocx table tbl2(1,7) = ("First page")
putdocx table tbl2(1,8) = ("Times cited")
putdocx table tbl2(1,9) = ("Paper percentile")
putdocx table tbl2(1,10) = ("Journal percentile")

local sav : display `"`verz'"' "\" `"`aname'"' "_appendix"
putdocx save `sav', replace

use `verz'\initial_dataset, clear

end

exit