{smcl}
{* *! version 1.0.0  08jan2018}{...}

{title:Title}

{p2colset 5 14 0 0}{...}
{p2col :estudy  {hline 2} Event study}{p_end}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:estudy} performs an event study, permitting to specify multiple varlists and event windows (up to six), allowing both parametric and non-parametric diagnostics. Several options allow the user to customize the analytical set-up.{p_end}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{opt estudy} varlist1 [(varlist2)... (varlistN)] [{cmd:,} {it:options}]

{synoptset 40 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Date specifications}
{p2coldent:* {opth dat:evar(varname)}}specify the date variable in the dataset{p_end}
{p2coldent:* {opth evd:ate(strings:string)}}specify the event date; {it:evdate} format may be: {cmd:mmddyyyy}, {cmd:ddmmyyyy} or {cmd:yyyymmdd}{p_end}
{p2coldent:* {opth datef:ormat(strings:string)}}indicate the format of the event date ({opt evdate} option); {it:dateformat} may be: {cmd:MDY}, {cmd:DMY} or {cmd:YMD}{p_end}
{p2coldent:✝ {opt lb1(#)} {opt ub1(#)} [{cmd:... lb6(#) ub6(#)}]}specify lower and upper bounds of event window(s){p_end}
{synopt :{opt eswlb(#)}}specify the lower bound of the estimation window; default is the first trading day available{p_end}
{synopt :{opt eswub(#)}}specify the upper bound of the estimation window; default is {cmd:eswlb(-30)}{p_end}

{syntab:Model}
{synopt :{opth modt:ype(strings:string)}}specify the model to compute ARs; {it:modtype} may be {opt SIM}, {opt MAM}, {opt MFM} or {opt HMM}; default is {cmd:modtype(SIM)}{p_end}
{p2coldent:+ {opth ind:exlist(varlist)}}specify the varlist used to compute (ab)normal returns{p_end}
{synopt :{opth diagn:osticsstat(strings:string)}}specify the diagnostic test; {it:diagnosticsstat} may be {opt Norm}, {opt Patell}, {opt ADJPatell}, {opt BMP}, {opt KP}, {opt Wilcoxon} or {opt GRANK}; default is {cmd:diagnosticsstat(Norm)}{p_end}

{syntab:Output}
{synopt :{opth supp:ress(strings:string)}}suppress part of the output; {it:suppress} may be {opt ind} or {opt group}{p_end}
{synopt :{opt dec:imal(#)}}set the number of decimals for the output table; default is {cmd:decimal(2)}, maximum is {cmd:7}{p_end}
{synopt :{opt showp:values}}add a row below ARs, reporting pvalues{p_end}
{synopt :{opt nos:tar}}hide significance stars (and the associated legend) from the output table{p_end}
{synopt :{opth outp:utfile(strings:filename)}}store results in a .xlsx file (filename is required){p_end}
{synopt :{opth myd:ataset(strings:datasetname)}}store results in a .dta file (filename is required){p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* These options are required{p_end}
{p 6 6 2} When specifying lower and upper bounds of the event windows, only the first is required, the others are discretionary{p_end}
{p 4 6 2}+ The {cmd:indexlist} option is conditional to {cmd:modtype}; see modtype and indexlist descriptions below{p_end}
{p 4 6 2}✝ Only the first upper and lower bounds are required, the other ones are optional

{marker options}{...}
{title:Options}

{dlgtab:Date specifications}

{phang}
{opth *datevar(varname)} specifies the name of the date variable in the dataset. The program cannot perform an event study if the time series of securities return is not linked to a date variable. If the variable reported in {cmd:datevar} is not formatted as date, the program stops.{p_end}

{phang}
{opt *dateformat(string)} specifies the format of the event date. {cmd:MDY}, {cmd:DMY} or {cmd:YMD}, indicate that the event date {cmd:evdate} has been specified respectively as {it:"mmddyyyy"}, {it:"ddmmyyyy"} or {it:"yyyymmdd"}.{p_end}
 
{phang}
{opt *lb1(#)} {opt ub1(#)} [{cmd:... lb6(#) ub6(#)}] specify up to 6 event windows (only the first one is required). For each event window, both lower and upper bounds must be specified. They must be indicated as integer values.{p_end}

{phang}
{opt eswlb(#)} and {opt eswub(#)} specify lower and upper bounds of the estimation window. By default, the lower bound is the first trading day available, and the upper bound is the 30th trading day before the event.{p_end}

{dlgtab:Model}

{phang}
{opt modtype(string)} specifies the model to compute ARs; {cmd:modtype} may be:{p_end}
{phang2}
i) {opt SIM} ({it:Single Index Model}), the default option, requires to specify only one variable (factor) in {cmd:indexlist}{p_end}
{phang2}
ii) {opt MAM} ({it:Market Adjusted Model}), requires to specify only one variable (factor) in {cmd:indexlist}{p_end}
{phang2}
iii) {opt MFM} ({it:Multi-Factor Model}), requires to specify more than one variable (factors) in {cmd:indexlist}{p_end}
{phang2}
iv) {opt HMM} ({it:Historical Mean Model}), ignores {cmd:indexlist}{p_end}

{phang}
{opt indexlist(varlist)} specifies the factor/factors for the model indicated in {cmd:modtype}.{p_end}
{pmore}
{it:Single index model} ("SIM") and {it:market adjusted model} ("MAM") require only one variable, whereas {it:multi-factor model} ("MFM") requires more than one variable.
With {it:historical mean model} ("HMM") the program ignores this option.{p_end}

{phang}
{opt diagnosticsstat(string)} allows the user to select the statistical test for the ARs significance (parametric and non-parametric tests are available). {p_end}
{pmore}
Parametric tests are: {p_end}
{phang3} 
1) {opt Norm}, the default option, is based on the Normal distribution{p_end}
{phang3}
2) {opt Patell}, following the Patell (1976) approach{p_end}
{phang3}
3) {opt ADJPatell}, performs the Patell's test with the Kolari and Pynnonen (2010) adjustment for cross-correlation of ARs{p_end}
{phang3}
4) {opt BMP}, performs the test proposed by Boehmer, Musumeci and Poulsen (1991){p_end}
{phang3}
5) {opt KP}, performs the BMP's test with the Kolari and Pynnonen (2010) adjustment for cross-correlation of ARs{p_end}
{pmore}
Non-parametric tests are {p_end}
{phang3}
1) {opt Wilcoxon}, performs the the signed-rank test, proposed by Wilcoxon (1945){p_end}
{phang3}
2) {opt GRANK}, performs the generalized RANK test, proposed by Kolari and Pynnonen (2011){p_end}

{dlgtab:Output}

{phang}
{opt suppress(string)} sets the format of the output table.{p_end}
{pmore}
{opt ind} hides single securities from the output table, while {opt group} keeps them only; by default, single securities, average and portfolio ARs are shown.
{cmd:suppress} cannot be used with only one variable specified in varlist.{p_end}

{marker Remarks}{...}
{title:Remarks}

{phang}
If an event window does not contain any value, the output will show ARs (p-values) equal to 0 (".").{p_end}

{phang}
If the estimation window has less than 25 observations, the program shows a warning message. {p_end}

{phang}
If the event date occurs on Saturday or Sunday, {cmd:estudy} substitutes it with the first following Monday and considers it as (+1) day (the Friday is considered as -1, accordingly).
If such a date is still not available, the program terminates showing an error message. {p_end}

{phang}
Labels cannot contain the "." symbol. Their length is automatically cut to 45 characters (if in excess), or to 32 characters if the {cmd: outputfile} and/or {cmd: mydataset} options have been specified.{p_end}

{phang}
{cmd: estudy} shows in the output table (and in the .xslx and .dta files as well) the label of each variable indicated in the {it: varlist1}, {it: varlist2}, ... , {it: varlistN}. If labels are missing, variable names are used.{p_end}

{phang}
The option {cmd: suppress} is also valid for the table exported with {cmd: outputfile} and {cmd: mydataset} options.{p_end}

{marker example}{...}
{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. use data_estudy.dta}{p_end}

{pstd}Performs an event study on two varlists with two event windows around 09 July 2015. ARs are reported with four decimals.{p_end}
{phang2}{cmd:. estudy boa ford boeing (apple netflix amazon facebook google) , datevar(date) evdate(07092015) dateformat(MDY) indexlist(mkt) decimal(4) lb1(-1) ub1(1) lb2(-3) ub2(3)}{p_end}

{pstd}Performs an event study on three varlists with four event windows around 09 July 2015, using a Fama and French (1993) 3 factors model and the Kolari and Pynnonen (2010) test.{p_end}
{phang2}{cmd:. estudy boa ford boeing (apple netflix amazon facebook google) (boa ford boeing apple netflix amazon facebook google) , datevar(date) evdate(07092015) dateformat(MDY)}
{cmd:modtype(MFM) indexlist(mkt smb hml) diagnosticsstat(KP) lb1(-1) ub1(1) lb2(-3) ub2(3) lb3(-1) ub3(0) lb4(0) ub4(3)}{p_end}

{pstd}Performs an event study on three varlists with two event windows around 09 July 2015, using the historical mean model and the signed-rank test by Wilcoxon (1945). The output table will show the p-values instead of significance stars.{p_end}
{phang2}{cmd:. estudy boa ford boeing (apple netflix amazon facebook google) (boa ford boeing apple netflix amazon facebook google) , datevar(date) evdate(09072015) dateformat(DMY)}
{cmd:modtype(HMM) diagnosticsstat(Wilcoxon) showpvalues nostar lb1(-1) ub1(1) lb2(-3) ub2(3) lb3(-1) ub3(0)}{p_end}

{pstd}Performs an event study on two varlists with two event windows around 09 July 2015, and stores the results in the {it:my_output_tables}.xslx file.{p_end}
{phang2}{cmd:. estudy boa ford boeing (apple netflix amazon facebook google) , datevar(date) evdate(07092015) dateformat(MDY) indexlist(mkt) outputfile(my_output_tables) lb1(-1) ub1(1) lb2(-3) ub2(3)}{p_end}

{pstd}Performs an event study on two varlists with two event windows around 09 July 2015, and stores the results in the {it:my_ar_dataset}.dta file.{p_end}
{phang2}{cmd:. estudy boa ford boeing (apple netflix amazon facebook google) , datevar(date) evdate(07092015) dateformat(MDY) indexlist(mkt) mydataset(my_ar_dataset) lb1(-1) ub1(1) lb2(-3) ub2(3)}{p_end}

{marker references}{...}
{title:References}

{marker BMP1991}{...}
{phang}
Boehmer, E., Musumeci, J., Poulsen, A. B. (1991). {it:Event-study methodology under conditions of event-induced variance}.
Journal of Financial Economics 30, 253-272. {p_end}

{marker KP2010}{...}
{phang}
Kolari, J. W., & Pynnonen, S. (2010). {it:Event study testing with cross-sectional correlation of abnormal returns}.
Review of financial studies, 23(11), 3996-4025. {p_end}

{marker KP2011}{...}
{phang}
Kolari, J. W., & Pynnonen, S. (2011). {it:Nonparametric rank tests for event studies}.
Journal of Empirical Finance, 18(5), 953-971. {p_end}

{marker PAT1976}{...}
{phang}
Patell, J. A., (1976). {it:Corporate forecasts of earnings per share and stock price behavior: Empirical test}.
Journal of Accounting Research 14, 246-276. {p_end}

{marker WX1945}{...}
{phang}
Wilcoxon, F. (1945). {it:Individual comparisons by ranking methods}.
Biometrics Bulletin 1, 80-83. {p_end}


{marker authors}{...}
{title:Authors}

{phang}
Fausto Pacicco, LIUC Università Carlo Cattaneo - fpacicco@liuc.it
{p_end}

{phang}
Luigi Vena, LIUC Università Carlo Cattaneo - lvena@liuc.it
{p_end}

{phang}
Andrea Venegoni, LIUC Università Carlo Cattaneo - avenegoni@liuc.it
{p_end}
