{smcl}
{* *! version 3.1  13jul2015}{...}
{vieweralsosee "mvmeta" "mvmeta"}{...}
{vieweralsosee "Main mvmeta demonstration" "mvmetademo_run"}{...}
{hline}
{cmd:Demonstration for the mvmeta package in Stata: getting the data into mvmeta format}
{cmd:Ian White}
{hline}

{p}{cmd:mvmeta} expects the data to be organised with one line per study,
with each line containing the estimates and their variances for that study. 
The estimates must be named as a common stub followed by a unique ending, 
and the variances must be named as a (different) common stub followed by a repeated ending. 
Ideally, covariances are also included, named as the variance stub followed by two endings. 

{p}Let's make that more concrete by inputting the p53 data. 
These data are described in
{help mvmetademo_run##p53:the main demonstration}.
The data are the estimated log hazard ratios (lnHR) 
for mutant vs. normal p53 gene for two outcomes.

{p}The data for overall survival look like this:

    study estimate  std.error
        1     -.18        .56  
        2      .79        .24  
        3      .21        .66  
        4     -.63        .29  
        5     1.01        .48  
        6     -.64         .4  
		
{p}and the corresponding data for disease-free survival 
(which was only reported in 3 studies) look like this:

    study estimate  std.error
        1     -.58        .56  
        4    -1.02        .39  
        6     -.69         .4  

{p}We enter these using lnHR as the stub for the log hazard ratios 
and selnHR as a stub for the standard errors,
and using abbreviations os for overall survival and dfs 
for disease-free survival:

{stata clear}
{stata input study lnHRos selnHRos lnHRdfs selnHRdfs}
          {stata       1   -.18      .56    -.58       .56}
          {stata       2    .79      .24       .         .}
          {stata       3    .21      .66       .         .}
          {stata       4   -.63      .29   -1.02       .39}
          {stata       5   1.01      .48       .         .}
          {stata       6   -.64       .4    -.69        .4}
{stata end}

{p}Note that we have entered missing values for disease-free survival in studies 2, 3 and 5.

{p}{cmd:mvmeta} requires variables representing the variances. 
These must be named as <stub><ending><ending>. We choose VlnHR as the stub for the variances, so:

{pstd}{stata  gen VlnHRosos =      selnHRos^2}   

{pstd}{stata  gen VlnHRdfsdfs =    selnHRdfs^2}   

{p}These data are now in the format required by {cmd:mvmeta} and can be analysed 
as shown in {help mvmetademo_run##p53:the main demonstration}.

{p}If we also knew the within-study covariances, we could have input them with the main data.
If we knew the within-study correlations, we could have input them with the main data (say as variable corrosdfs)
and then computed the covariances using {stata gen VlnHRosdfs = corrosdfs*selnHRos*selnHRdfs}.

