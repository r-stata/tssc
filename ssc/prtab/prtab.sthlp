{smcl}
{* documented: Mar2017}{...}
{cmd:help prtab}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :prtab {hline 2}}Precision-recall curves{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:prtab}
{it:refvar}
{it:classvar}
{ifin}
{cmd:,} [{it:{help prtab##prtaboptions:prtab_options}}]


{marker prtaboptions}{...}
{synoptset 27 tabbed}{...}
{synopthdr :prtab_options}
{synoptline}
{syntab:Main}
{synopt :{opt com:pare(varname)}}compares with another classifier{p_end}
{synopt :{opt prec_at(real)}}affects the values of precision that are displayed{p_end}
{synopt :{opt thres:hold}}uses the cutoff threshold for the horizontal axis{p_end}
{synopt :{opt rank}}uses the item's rank for the horizontal axis{p_end}
{synopt :{opt fscore}}plots the the F-score as a function of cutoff thresholds{p_end}
{synopt :{opt inter:polate}}provides an interpolated precision curve{p_end}
{syntab:Plot}
{synopt :{opt nog:raph}}supresses graphical output{p_end}
{synopt :{opt noref:line}}does not display a reference line{p_end}
{p2col:{it:{help twoway_options}}}any options other than {cmd:by()} documented in {manhelpi twoway_options G-3}{p_end}



{title:Description}

{pstd}
{cmd:prtab} plots precision-recall curves. Precision-recall curves are an alternative to ROC curves for examining predictions of a binary outcome. See Cook and Ramadas (2018) for more details on precision-recall curves and this command.
 
 
{title:Options}

{dlgtab:Main}

{phang}

{phang}
{opt compare(varname)} compares with another classifier

{phang}
{opt prec_at(real)} affects the values of precision that are displayed. The displayed values of precision will be around the specified value of recall. When {opt rank} is specified, this option is used to specify a rank.

{phang}
{opt thershold} uses the cutoff threshold for the horizontal axis. 

{phang}
{opt rank} uses the item's rank for the horizontal axis. Note that if multiple observations have the same classifier score (i.e., there are ties), the precision is averaged of all possible rankings.

{phang}
{opt fscore} plots the the F-score as a function of cutoff thresholds. The F-score is the harmonic mean of precision and recall.

{phang}
{opt interpolate} provides an interpolated precision curve. Can be used with {opt threshold}, but not {opt rank}.

{phang}

{dlgtab:Plot}

{phang}

{phang}
{opt nograph} surpresses graphical output.

{phang}
{opt norefline} does not include a reference line in plot.

{phang}
{opt twoway_options} are any of the options documented in {manhelpi twoway_options G-3}, excluding {cmd:by()}.

 
{title:Example}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse ct2, clear}{p_end}

{pstd}Create precision-recall curve{p_end}
{phang2}{cmd:. prtab status mod1}{p_end}

{pstd}Use plot options{p_end}
{phang2}{cmd:. prtab status mod1, lwidth(medthick)}{p_end}  
  
{pstd}Compare two classifiers{p_end}
{phang2}{cmd:. prtab status mod1, compare(mod2)}{p_end}  
  
{title:Saved results}


{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalar}{p_end}
{synopt:{cmd:r(AUC)}}Area under the precision-recall curve (not provided if {opt rank} is used){p_end}
{synopt:{cmd:r(AUC2)}}Area under the precision-recall curve of the comparison classifier (only provided if {opt compare} is used){p_end}
{synopt:{cmd:r(N)}}Number of observations{p_end}
{synopt:{cmd:r(unique_val)}}Number of unique classifier values (not provided if {opt compare} is used){p_end}
{synopt:{cmd:r(pos_cases)}}Number of positive cases{p_end}
{synopt:{cmd:r(prct_pos)}}Percent of positive cases{p_end}

{title:Author}

	Jonathan Cook, jacook@uci.edu
	
		
{title:References}

{phang}
Cook, J. and V. Ramadas. 2018. When to consult precision-recall curves. {it:Working paper}.

