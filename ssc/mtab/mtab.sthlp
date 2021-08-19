{smcl}
{* v 1.0.3 Chunsen Wu 26Oct2020 storing results in matrix}{...}

{cmd:help mtab}{right: ({browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":User-written stata packages: mtab})}
{hline}

{title:Title}

{p 4 4 2}{hi:mtab} {hline 2} A package for storing results in {helpb matrix}.

{title:Description}

{pstd}
The {it:mtab} package consists of a collection of commands: {helpb mtab1}, {helpb mtab2}, {helpb msum}, {helpb mest}, {helpb mmat}, {helpb mexcel}, and {helpb mobs}. Combining the commands can easily store the results in {helpb matrix}{p_end}
{pstd}The {helpb matrix} with results can easily be further used to make tables in Excel or Word.{p_end}
{pstd}
{helpb mtab1} is a command of making an one-way table and store the results (frequencies and percentages) in {helpb matrix}.{p_end}
{pstd}
{helpb mtab2} is a command of making a two-way table and store the results (frequencies and percentages) in {helpb matrix}.{p_end}
{pstd}
{helpb msum} is a command of storing the results of mean, standard deviation, quantitles in {helpb matrix}.{p_end}
{pstd}
{helpb mest} is a command of exporting and storing the results (coefficient and confidence interval) in {helpb matrix}.{p_end}
{pstd}
{helpb mmat} is a command of extracting the results from an existing {helpb matrix} to a new {helpb matrix}.{p_end}
{pstd}
{helpb mexcel} is a command of exporting results from a {helpb matrix} to an Excel file.{p_end}
{pstd}
{helpb mobs} is a command of showing and storing the results (number of repeated observations within specified variable categories) in {helpb matrix}.{p_end}


{title:More information}: click on {browse "http://medical-statistics.dk/MSDS/statistics/stata/package/mtab/mtab.html":her} 


{title:Author}

{pstd}
Chunsen Wu, the University of Southern Denmark; Odense University Hospital, Denmark{break} 
{browse cwu@health.sdu.dk}{break} 
{browse chunsen.wu@rsyd.dk}

       ../m/mtab.sthlp
       ../m/mtab1.ado
       ../m/mtab1.sthlp
       ../m/mtab2.ado
       ../m/mtab2.sthlp
       ../m/msum.ado
       ../m/msum.sthlp
       ../m/mest.ado
       ../m/mest.sthlp
	   ../m/mmat.ado
       ../m/mmat.sthlp
       ../m/mexcel.ado
       ../m/mexcel.sthlp
       ../m/mobs.ado
       ../m/mobs.sthlp	   


{title:Also see}

{p 7 14 2}
Help: {helpb mtab1}, {helpb mtab2}, {helpb msum}, {helpb mest}, {helpb mmat}, {helpb mexcel}, and {helpb mobs}
{p_end}
