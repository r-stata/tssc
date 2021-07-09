{smcl}
{* *! version 1.3.74  29Apr2018}{...}
{cmd:help mat2do} {right: ({browse "http://staskolenikov.net/stata/":Stas Kolenikov's webpage})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:ipfraking_report} {hline 2}}Reports on raked weights{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:ipfraking_report using} {it:report_file}{cmd:, raked_weight(}{it:weight_variable}{cmd:)} [{it:options}]

{synoptset 43 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{cmd:matrices(}{it:matrix_list}{cmd:)}}list of control total matrices to provide summaries for{p_end}
{synopt :{cmd:by(}{it:varlist}{cmd:)}}variables to break down summaries by{p_end}
{synopt :{cmd:force}}list a variable more than once{p_end}
{synopt :{cmd:replace}}overwrite the existing file(s){p_end}
{synopt :{cmd:xls}}export the resulting report to an Excel file, see {help export excel}{p_end}


{title:Description}

{pstd}{cmd:ipfraking_report} produces a detailed report and summaries of raked weights
produced previously by {cmd:ipfraking}. 
The results are placed into {it:report_file.dta} (and, if {cmd:xls} option is specified,
also to {it:report_file.xls}).
{p_end}

{pstd}
Along the way, {cmd:ipfraking_report} runs a regression of the log raking ratio 
on the calibration variables. This regression is expected to have R^2 very close to 1,
and the regression coefficients provide insights regarding which categories received
greater vs. smaller adjustments.


{title:Structure of the report}

{pstd}
Each line of the report corresponds to one of the categories of a control total variable,
and would contain information on what that control total category is, unweighted counts,
totals, proportions; totals and proportions with the source and the raked weights;
and descriptive statistcs of source weights, raked weights, and raking ratios.
{cmd:ipfraking_report} picks up the weighting margins from meta-information stored
by the {cmd:meta} option of {cmd:ipfraking} command that was used 
to generate raked weights; see {help ipfraking}.
{p_end}

{pstd}
{cmd:ipfraking_report} produces the following variables.
{p_end}

{p2colset 8 40 44 8}

{p2col:Variable name} Definition{p_end}
{p2line}
{p2col:{cmd:Weight_Variable}}The name of the weight variable, {cmd:generate()}{p_end}
{p2col:{cmd:C_Total_Margin_Variable_Name}}The name of the control margin,
            {cmd:rowname} of the corresponding {cmd:ctotal()} matrix{p_end}
{p2col:{cmd:C_Total_Margin_Variable_Label}}The label of the control margin variable{p_end}
{p2col:{cmd:Variable_Class}}The role of the variable in the report:{p_end}
{p2col:}  {it:Raking margin}: a variable used as a calibration margin 
   (picked up automatically from the {cmd:ctotal()} matrix, provided {cmd:meta} option was specified){p_end}
{p2col:}  {it:Other known target}: supplied with {cmd:matrices()} option of {cmd:ipfraking_report}{p_end}
{p2col:}  {it:Auxiliary variable}: additional variable supplied with {cmd:by()} option of {cmd:ipfraking_report}{p_end}
{p2col:{cmd:C_Total_Arg_Variable_Name}}The name of the multiplier variable{p_end}
{p2col:{cmd:C_Total_Arg_Variable_Label}}The label of the multiplier variable{p_end}
{p2col:{cmd:C_Total_Margin_Category_Number}}Numeric value of the control total category{p_end}
{p2col:{cmd:C_Total_Margin_Category_Label}}Label of the control total category{p_end}
{p2col:{cmd:Category_Total_Target}}The control total to be calibrated to (the specific entry in the {cmd:ctotal()} matrix){p_end}
{p2col:{cmd:Category_Total_Prop}}Control total proportion 
        (the ratio of the specific entry in the {cmd:ctotal()}
        matrix to the matrix total){p_end}
{p2col:{cmd:Unweighted_Count}}Number of sample observations in the category{p_end}
{p2col:{cmd:Unweighted_Prop}}Unweighted proportion{p_end}
{p2col:{cmd:Unweighted_Prop_Discrep}}Difference {cmd:Unweighted_Prop} - {cmd:Category_Total_Prop}{p_end}
{p2col:{cmd:Category_Total_SRCWGT}}Weighted category total, with source weight{p_end}
{p2col:{cmd:Category_Prop_SRCWGT}}Weighted category proportion, with source weight{p_end}
{p2col:{cmd:Category_Total_Discrep_SRCWGT}}Difference {cmd:Category_Total_SRCWGT} 
        - {cmd:Category_Total_Target}{p_end}
{p2col:{cmd:Category_Prop_Discrep_SRCWGT}}Difference {cmd:Category_Prop_SRCWGT}
        - {cmd:Category_Total_Prop}{p_end}
{p2col:{cmd:Category_RelDiff_SRCWGT}}{cmd:reldif(Category_Total_SRCWGT,}
        {cmd:Category_Total_Target)}{p_end}
{p2col:{cmd:Overall_Total_SRCWGT}}Sum of source weights{p_end}
{p2col:{cmd:Category_Total_RKDWGT}}Weighted category total, with calibrated weight{p_end}
{p2col:{cmd:Category_Prop_RKDWGT}}Weighted category proportion, with calibrated weight{p_end}
{p2col:{cmd:Category_Total_Discrep_RKDWGT}}Difference {cmd:Category_Total_RKDWGT} 
        - {cmd:Category_Total_Target}{p_end}
{p2col:{cmd:Category_Prop_Discrep_RKDWGT}}Difference {cmd:Category_Prop_RKDWGT}
        - {cmd:Category_Total_Prop}{p_end}
{p2col:{cmd:Category_RelDiff_RKDWGT}}{cmd:reldif(Category_Total_RKDWGT,}
        {cmd:Category_Total_Target)}{p_end}
{p2col:{cmd:Overall_Total_RKDWGT}}Sum of calibrated weights{p_end}
{p2col:{cmd:Source}}The name of the matrix from which the totals were obtained{p_end}
{p2col:{cmd:Comment}}Placeholder for comments, to be entered during manual review{p_end}
{p2line}

{pstd}
For each of the input weights ({cmd:SRCWGT} suffix), raked weights ({cmd:RKDWGT} suffix) and raking ratio
(the ratio of raked and input weights, {cmd:RKDRATIO} suffix), the following summaries are provided.
{p_end}

{p2col:Variable name} Definition{p_end}
{p2line}
{p2col:{cmd:Min_{it:WEIGHT}}}Min of the weights{p_end}
{p2col:{cmd:P25_{it:WEIGHT}}}25th percentile of the weights{p_end}
{p2col:{cmd:P50_{it:WEIGHT}}}Median of the weights{p_end}
{p2col:{cmd:P75_{it:WEIGHT}}}75th percentile of the weights{p_end}
{p2col:{cmd:Max_{it:WEIGHT}}}Max of the weights{p_end}
{p2col:{cmd:Mean_{it:WEIGHT}}}Mean of the weights{p_end}
{p2col:{cmd:SD_{it:WEIGHT}}}Standard deviation of the weights{p_end}
{p2col:{cmd:DEFF_{it:WEIGHT}}}Apparent UWE DEFF of the weights{p_end}
{p2line}

{title:Options}

{dlgtab:Rows of the report}

{phang}{cmd:by(}{it:varlist}{cmd:)} requests a breakdown of the sample and weight summaries by categories
of the variables specified in this option.{p_end}

{phang}{cmd:matrices(}{it:matrix_name} [{it:matrix_name} ...]{cmd:)} provides a list of known control totals.{p_end}

{pmore}{cmd:ipfraking_report} will pick up the raking variables and their categories.
Each matrix is expected to be compatible with the matrices consumed by {cmd:ipfraking}
as control totals, {cmd:ctotal()} option. 
While the functionality of producing results by different variables is provided with
{cmd:by()} option, passing the known control totals with {cmd:matrices()} allows comparing
the required vs. achieved control totals.
See {help ipfraking##remarks:ipfraking Remarks} and {help ipfraking##examples:ipfraking Examples}.
{p_end}

{phang}{cmd:force} requests that {cmd:ipfraking_report} provides summaries of weights 
for a given variable each time it is encountered.{p_end}

{pmore}The multiple opportunities include:
being one of the raking margins picked up from the control totals saved by 
{cmd:ipfraking, meta}; supplied with {cmd:by()} option; and supplied with {cmd:matrices()} option.
The reasons to include a variable multiple times in these options is to see how the weights
perform depending on whether a variable with known control totals is included or not
as a raking margin.
{p_end}

{dlgtab:Files}

{phang}{cmd:replace} overwrite the existing file(s)

{phang}{cmd:xls} export the report as an Excel file, see {help export excel}.


{title:Example}

{pstd}A variation of the following example was given in {help ipfraking}:{p_end}

{phang2}{cmd:. webuse nhanes2, clear}{p_end}

{phang2}{cmd:. * setting up the totals}{p_end}
{phang2}{cmd:. generate byte _one = 1}{p_end}
{phang2}{cmd:. svy: total _one, over(sex, nolab)}{p_end}
{phang2}{cmd:. matrix total_sex = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_sex = sex}{p_end}

{phang2}{cmd:. svy: total _one, over(race, nolab)}{p_end}
{phang2}{cmd:. matrix total_race = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_race = race}{p_end}

{phang2}{cmd:. * interaction of sex and race}{p_end}
{phang2}{cmd:. generate sex_race = sex*10 + race}{p_end}
{phang2}{cmd:. svy: total _one, over(sex_race, nolab)}{p_end}
{phang2}{cmd:. matrix total_sex_race = e(b)}{p_end}
{phang2}{cmd:. matrix rownames total_sex_race = sex_race}{p_end}

{phang2}{cmd:. * obtaining the sample}{p_end}
{phang2}{cmd:. sample 500, count by(region)}{p_end}

{phang2}{cmd:. * calibrating the weights}{p_end}
{phang2}{cmd:. ipfraking [pw=finalwgt], ctotal(total_sex total_race) generate(rakedwgt2) meta}{p_end}

{pstd}Let us extend this example to post-stratification (note that the requisite interaction
variable {cmd:race_sex} was generated with the full data set):{p_end}

{phang2}{cmd:. * post-stratification}{p_end}
{phang2}{cmd:. ipfraking [pw=finalwgt], ctotal(total_sex_race) generate(pstrwgt2) meta}{p_end}

{pstd}Let us now and generate weight reports for each version of the weights.{p_end}

{phang2}{cmd:. * reports}{p_end}
{phang2}{cmd:. ipfraking_report using rakedwgt2-report, raked_weight(rakedwgt2)} ///{p_end}
{pmore2}{cmd:xls replace by(_one) matrices(total_sex total_race total_sex_race)}{p_end}
{phang2}{cmd:. ipfraking_report using pstrwgt2-report, raked_weight(pstrwgt2)} ///{p_end}
{pmore2}{cmd:xls replace by(_one) matrices(total_sex total_race total_sex_race)}{p_end}

{pstd}Fine points of these reports:{p_end}

{phang2}* Excel copies are produced for each report ({cmd:xls} options){p_end}

{phang2}* The list of the known control totals {cmd:matrices(total_sex total_race total_sex_race)}
can be copied and pasted between the reports. {p_end}

{pmore2}- For the {cmd:rakedwgt2} weight variable,
its margins {cmd:sex} and {cmd:race} will be picked up from {cmd:meta} results,
and will be reported as {cmd:Variable_Class == "{it:Raking margin}"}, while the interaction
{cmd:sex_race} will be assigned the role of {cmd:Variable_Class == "{it:Other known target}"}.
A warning will be produced for {cmd:sex} and {cmd:race} that these variables
are processed as raking margins, and will not be processed again due to the 
{cmd:matrices()} option.{p_end}

{pmore2}- For the {cmd:pstrwgt2} weight variable,
{cmd:sex_race} will be reported as {cmd:Variable_Class == "{it:Raking margin}"},
while the main effects {cmd:sex} and {cmd:race} will be 
reported as {cmd:Variable_Class == "{it:Other known target}"}.
A warning will be produced for {cmd:sex_race} variable that
it is processed as a raking margin, and will not be processed again due to the 
{cmd:matrices()} option.
{p_end}

{phang2}* Overall summaries are produced for the weights through {cmd:by(_one)} specification.
This variable has only one category, so summaries for the weights will be computed 
for the data set as a whole.
This row of the data will have 
{cmd:Variable_Class == "{it:Auxiliary variable}"}, as we did not supply the control
totals for it.
{p_end}


{title:Author}

{pstd}Stanislav Kolenikov{p_end}
{pstd}Senior Scientist{p_end}
{pstd}Abt Associates{p_end}
{pstd}skolenik at gmail dot com{p_end}


{title:Also see}

{psee}{help ipfraking} (if installed)

