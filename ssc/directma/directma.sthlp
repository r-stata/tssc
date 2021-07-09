{smcl}
{* *! version 1.0  13November2017}{...}
{hline}
{cmd:help directMA} 
Version 1.0 November 13, 2017
{hline}
{viewerjumpto "Syntax" "directMA##syntax"}{...}
{viewerjumpto "Description" "directMA##description"}{...}
{viewerjumpto "Examples" "directMA##examples"}{...}
{viewerjumpto "Authors" "directMA##authors"}{...}
{viewerjumpto "Acknowledgments" "directMA##acknowledgments"}{...}
{viewerjumpto "Also see" "directMA##alsosee"}{...}

{title:Title}

{phang}
{bf:directMA} {hline 2} Conduct multiple pair-wise meta-analysis (head-to-head comparisons) and export the pooled results to a Microsoft Excel file. Support data in long form.  {p_end}
    {bf:Only works on Stata version 13 or later.}    

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:directMA}
studyid studyname 
{varlist} 
{ifin}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Outcome measure}
{synopt:{opt rr}}relative risk{p_end}
{synopt:{opt or}}odds ratio{p_end}
{synopt:{opt rd}}risk difference{p_end}
{synopt:{opt wmd}}weighted mean difference{p_end}
{synopt:{opt cohen}}standardized mean difference using Cohen's method{p_end}
{synopt:{opt hedges}}standardized mean difference using Hedges' method{p_end}
{synopt:{opt glass}}standardized mean difference using Glass' method{p_end}

{syntab:Pooling method}
{synopt:{opt fixed}}fixed effect model{p_end}
{synopt:{opt random}}random effect model using the "DerSimonian and Laird" method{p_end}
{synopt:{opt peto}}Peto's method for odds ratio{p_end}
{synopt:{opt reml}}random effect model using the "Restricted Maximum Likelihood" method{p_end}
{synopt:{opt ml}}random effect model using the "Maximum Likelihood" method{p_end}
{synopt:{opt pl}}random effect model using the "Profile Likelihood" method{p_end}
{synopt:{opt eb}}random effect model using "Empirical Bayes" method to estimate tau2{p_end}
{synopt:{opt kh}}random effect model using the "Knapp and Hartung" method to adjust for p-value and confidence interval{p_end}

{syntab:Forest Plot}
{synopt:{opt forest}}Forest plot{p_end}
{synopt:}Forest plots automatically export to the working folder in wmf format{p_end}
{synopt:}Forest plots do NOT work for the Knapp and Hartung and Empirical Bayes method{p_end}

{syntab:Funnel Plot}
{synopt:{opt funnel}}Funnel plot{p_end}
{synopt:}Funnel plots automatically export to the working folder in wmf format{p_end}
{synopt:}Funnel plots do NOT work when the number of studies is less than 10{p_end}


{syntab:Exporting results to Excel}
{synopt:{opt filename(string)}}file name{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:directMA} conducts multiple pair-wise meta-analysis (head-to-head comparisons) in one single command. All pooled results are suppressed (aka. no terminal/windows output) and exported to a Microsoft Excel file. {p_end}
{pstd}
It supports random effects models, including the DerSimonian and Laird (D-L) method, Peto's method for odds ratio,
Restricted Maximum Likelihood, Maximum Likelihood, Profile Likelihood, Knapp and Hartung method, and Empirical Bayes. Fixed effect models are also supported. {p_end}

{pstd}
The option, {opt forest}, automatically exports forest plots to the working folder in wmf format. forest does NOT work for the Knapp and Hartung and Empirical Bayes method.{p_end}

{pstd}
The option, {opt funnel}, automatically exports funnel plots to the working folder in wmf format. funnel does NOT work when the number of studies is less than 10.{p_end}

{pstd}Data Format:{p_end}
{pstd}{cmd:directMA} handles data in long format. Each row should {it: at least} have study ID, study name, treatment, event and no_event
(for continuous outcomes), and number of patients, effect size, and standard deviation (for continuous outcomes) 
from one arm/group in each study.{p_end}

{pstd}For example:{p_end}
{p 4 8 2}

           {it:Dichotomized outcomes}
        {c TLC}{hline 61}{c TRC}                  
        {c |} {it:studyid  studyname}	       {it:treatment} 	    {it: event no_event} {c |}                
        {c |}{hline 61}{c |}                 
        {c |}    1    {bf: Study name, 2001}   treatment 1 	 10     20     {c |}  
        {c |} 	 1    {bf: Study name, 2001}   treatment 2	 15     15     {c |}   
        {c |}    2    {bf: Study name, 2004}   treatment 1	 20     10     {c |}                 
        {c |}    2    {bf: Study name, 2004}   treatment 2	 20      5     {c |}                 
        {c BLC}{hline 61}{c BRC}

{p 4 8 2}

           {it:Continuous outcomes}
        {c TLC}{hline 67}{c TRC}                  
        {c |} {it:studyid  studyname}           {it:treatment} 	  {it: patient effsize eff_SD} {c |}                
        {c |}{hline 67}{c |}                 
        {c |}    1    {bf: Study name, 2001}    treatment 1    100      20     2.5   {c |}  
        {c |} 	 1    {bf: Study name, 2001}    treatment 2    100      15     2.0   {c |}   
        {c |}    2    {bf: Study name, 2004}    treatment 1     20      10     1.0   {c |}                 
        {c |}    2    {bf: Study name, 2004}    treatment 2     20      15     1.5   {c |}  
        {c |}    2    {bf: Study name, 2004}    treatment 3     20      15     1.5   {c |}   		
        {c BLC}{hline 67}{c BRC}

{pstd}
{cmd:directMA} requires a numeric variable (studyid) and a string/numeric variable (study name)to identify each study. treatment can be a string or numeric variable.     
{p_end}

{marker examples}{...}
{title:Examples}

{phang}{cmd:. directMA id study treatment event non_event, rr random forest funnel filename(test)}{p_end}

{phang}{cmd:. directMA id study treatment event non_event, or kh filename(test)}{p_end}

{phang}{cmd:. directMA id study treatment n eff sd, wmd kh filename(example)}{p_end}

{marker authors}{...}
{title:Authors}

{pstd}Zhen Wang{p_end}
{pstd}Mayo Clinic, USA{p_end}
{pstd}Wang.Zhen@mayo.edu{p_end}

{pstd}M.Hassan Murad{p_end}
{pstd}Mayo Clinic, USA{p_end}
{pstd}Murad.Mohammad@mayo.edu{p_end}

{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}This command is built upon {cmd:metareg} (author: Roger M. Harbord), {cmd:metan} (authors: Michael J Bradburn, Jonathan J Deeks, and Douglas G Altman), 
 {cmd:metaan} (authors: Evangelos Kontopantelis,and David Reeves), and {cmd:metafunnel} (authors: Jonathan A. C. Sterne and Roger M. Harbord).{p_end}

{marker alsosee}{...}
{title:Also see}

{psee} 
Article:{it:Stata Journal}, volume 10, number 3: {browse "http://www.stata-journal.com/sjpdf.html?articlenum=st0201": st0201}{break}
		{it:Stata Journal}, volume 8, number 1: {browse "http://www.stata-journal.com/sjpdf.html?articlenum=sbe24_2":sbe24_2}{break}
        {it:Stata Technical Bulletin} 42: {browse "http://www.stata.com/products/stb/journals/stb42.pdf":sbe23}

{psee} 
Manual:  {hi:[R] metan}{break}
{hi:[R] metaan}{break}
{hi:[R] metareg}{break}
{hi:[R] metafunnel}


