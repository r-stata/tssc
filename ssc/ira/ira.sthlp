{smcl}
{* *! version 0.1.0  01nov2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "ira##syntax"}{...}
{viewerjumpto "Description" "ira##description"}{...}
{viewerjumpto "Reported indices" "ira##indices"}{...}
{viewerjumpto "Remarks" "ira##remarks"}{...}
{viewerjumpto "Citation" "ira##citation"}{...}
{viewerjumpto "Examples" "ira##examples"}{...}
{title:Title}

{phang}
{bf:ira} {hline 2} Stata module to calculate rwg and related interrater agreement indices


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:ira}
{it: judge_id}
{it: rating}
[{helpb if}]
[{helpb in}]
[{cmd:,} {it:item(item_id)} {it:group(group_id)} {it:options(#)} {it:distribution(#)}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt item}}variable that identifies scale items; if none is specified, {cmd:ira} will assume a single-item scale{p_end}
{synopt:{opt group}}variable that identifies groups; if none is specified, {cmd:ira} will assume a single group{p_end}
{synopt:{opt options(#)}}number of response options (anchors) on scale;
        default is {cmd:options(7)}{p_end}
{synopt:{opt distribution(#)}}variance of user-specified null distribution for rwg(j){p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:ira} calculates the within-group interrater agreement indices {it:rwg(j)}, {it:r*wg(j)}, {it:r'wg(j)}, {it:awg(j)}, and {it:AD(j)}.{p_end}

{pstd}{cmd:ira} calculates these indices for all groups in the data and reports mean, median, and range (absolute difference between maximum and minimum) across groups for each index.{p_end}

{pstd}To do so, {cmd:ira} needs the user to specify the following variables:{p_end}
{pstd}- {it:judge_id}: identifier for the judge (rater); must be unique within a group{p_end}
{pstd}- {it:rating}: judges' ratings (scores){p_end}
{pstd}- {it:item_id}: identifier for the scale item (if a multiple-item scale was employed){p_end}
{pstd}- {it:group_id}: identifier for the group (target) (if there is more than one){p_end}

{pstd}The dataset must be in "long" format. Use the {cmd:{helpb reshape}} command if needed.{p_end}


{pstd}Notes on ratings:{p_end}
{phang}- Ratings must be values between 1 and the number of scale options specified through {it:options(#)} ({cmd:ira} assumes that the scale's lowest response option is 1).{p_end}
{phang}- Ratings should be numeric (although {cmd:ira} will make an attempt to de-string if needed). Ratings need not be integer values. However, if they are not, the interpretation of some indices may change.{p_end}
{phang}- All judges of a group must provide ratings for all items.{p_end}


{pstd}{cmd:ira} can also provide results for cases in which there is only one group or provide results separately by group. There are at least three ways of doings this, depending on how the user's dataset is set up.{p_end}

{phang}1) If the dataset only includes data for a single group, simply omit the {it:group(group_id)} option. All indices reported by {cmd:ira} will pertain to the one group.{p_end}

{phang}2) If the dataset comprises data for multiple groups, but individual indices for a single group are desired, {cmd:ira} can be invoked using the "{helpb if}" functionality to indicate which group should be analyzed. If the grouping variable is called {it: my_group_id} and results are desired for group 3, the user might specify:{p_end}

{pstd}{cmd:. ira judge rating if my_group_id == 3}{p_end}

{phang}3) If the dataset comprises data for multiple groups and individual indices for {it:all} groups are desired, {cmd:ira} can be used with "{helpb by}":{p_end}

{pstd}{cmd: . by my_group_id: ira judge rating}{p_end}


{marker indices}{...}
{title:Reported indices}

{pstd}{cmd:ira} produces the following indices:{p_end}

{pstd}{it:rwg(j)}{p_end}

{p 8 8 2}{cmd:ira} calculates James et al.'s (1984, 1993) rwg(j) indices using various null distributions: uniform, skewed, triangular, and normal. Results for non-uniform distributions are only calculated if the specified number of scale items is between 5 and 11. Variances for non-uniform null distributions are taken from LeBreton & Senter (2008).{p_end}

{p 8 8 2}If the {it:distribution(#)} option is specified, {cmd:ira} calculates an additional rwg index using the supplied parameter as the variance of the null distribution.{p_end}

{p 8 8 2}Finn (1970) does not specify a range for rwg but explains that unity indicates perfect agreement and zero indicates no agreement (i.e., agreement equal to the null distribution). Following James et al. (1984), {cmd:ira} sets rwg(j) values for groups to zero if they exceed unity or are negative. If this happens, {cmd:ira} notifies the user. Possible reasons for such values include sampling error (James et al., 1984) and inappropriate specification of the null distribution.{p_end}

{pstd}{it:r*wg(j)}{p_end}

{p 8 8 2}Lindell et al. (1999) propose r*wg(j) as an improvement over rwg(j) that does not increase as the number of response options in the scale increases.{p_end}

{p 8 8 2}Interpretation is similar to rwg(j). Unlike rwg(j), negative values are not set to zero.{p_end}

{p 8 8 2}Lindell et al. (1999) suggest several indices. {cmd:ira} implements what they refer to as "Index C."{p_end}

{pstd}{it:r'wg(j)}{p_end}

{p 8 8 2}Lindell (2001) proposes further alternatives to rwg(j). {cmd:ira} calculates all four proposed variants.{p_end}

{p 8 8 2}Interpretation is similar to rwg(j).

{pstd}{it:awg(j)}{p_end}

{p 8 8 2}{cmd:ira} calculates the awg(j) index as proposed by Brown & Hauenstein (2005).{p_end}

{p 8 8 2}The measure attempts to address limitations of rwg(j), namely that the magnitude of the measure depends on sample size and the used scale.{p_end}

{p 8 8 2}awg(j) is an analogue to Cohen's kappa. A value of positive unity indicates perfect agreement, given the group mean. A value of negative unity indicates maximum disagreement, given the group mean.{p_end}

{p 8 8 2}awg(j) canot be interpreted if a group's mean is extremely low or high. In such cases, {cmd:ira} will issue a warning and omit the case from the calculation of mean, median, and range across groups.{p_end}

{pstd}{it:AD(j)}{p_end}

{p 8 8 2}{cmd: ira} follows Burke et al. (1999) and calculates two variants: Average deviation of the mean (ADM(j)) and average deviation of the median (ADMd(j)).{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}For rwg-type measures, values >.70 are conventionally taken to indicate acceptable interrater agreement. See Harvey & Hollander (2004) for a critical discussion. See LeBreton & Senter (2008) and O'Neill (2017) for further information on cut-off values for rwg(j) and other measures.{p_end}

{pstd}{cmd: ira} does not calculate statistical significance of the interrater agreement measures. See Dunlap et al. (2003) and Smith-Crowe et al. (2014) for further information and critical values.{p_end}

{pstd}For general reference regarding various interrater agreement indices, see LeBreton & Senter (2008) and O'Neill (2017).{p_end}

{marker citation}{...}
{title:Citation}

{pstd}{cmd: ira} is not an official Stata command. It is a free contribution to the research community. If you use it, please cite it as:{p_end}

{pstd}Graf-Vlachy, L. 2017. {it:ira: Stata module to calculate rwg and related interrater agreement indices}, http://www.repec.org/bocode/i/ira.html.{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:ira} stores the following in {cmd:r()}:

{synoptset 30 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of observations{p_end}
{synopt:{cmd:r(J)}}number of items{p_end}
{synopt:{cmd:r(groups)}}number of groups{p_end}
{synopt:{cmd:r(A)}}number of response options{p_end}

{synopt:{cmd:r(rwg_unif_mean)}}mean of rwg(j) across groups (uniform null distribution){p_end}
{synopt:{cmd:r(rwg_unif_median)}}median of rwg(j) across groups (uniform null distribution){p_end}
{synopt:{cmd:r(rwg_unif_range)}}range of rwg(j) across groups (uniform null distribution){p_end}
{synopt:{cmd:r(rwg_slight_skew_mean)}}mean of rwg(j) across groups (slightly skewed null distribution){p_end}
{synopt:{cmd:r(rwg_slight_skew_median)}}median of rwg(j) across groups (slightly skewed null distribution){p_end}
{synopt:{cmd:r(rwg_slight_skew_range)}}range of rwg(j) across groups (slightly skewed null distribution){p_end}
{synopt:{cmd:r(rwg_mod_skew_mean)}}mean of rwg(j) across groups (moderately skewed null distribution){p_end}
{synopt:{cmd:r(rwg_mod_skew_median)}}median of rwg(j) across groups (moderately skewed null distribution){p_end}
{synopt:{cmd:r(rwg_mod_skew_range)}}range of rwg(j) across groups (moderately skewed null distribution){p_end}
{synopt:{cmd:r(rwg_heavy_skew_mean)}}mean of rwg(j) across groups (heavily skewed null distribution){p_end}
{synopt:{cmd:r(rwg_heavy_skew_median)}}median of rwg(j) across groups (heavily skewed null distribution){p_end}
{synopt:{cmd:r(rwg_heavy_skew_range)}}range of rwg(j) across groups (heavily skewed null distribution){p_end}
{synopt:{cmd:r(rwg_tri_mean)}}mean of rwg(j) across groups (triangular null distribution){p_end}
{synopt:{cmd:r(rwg_tri_median)}}median of rwg(j) across groups (triangular null distribution){p_end}
{synopt:{cmd:r(rwg_tri_range)}}range of rwg(j) across groups (triangular null distribution){p_end}
{synopt:{cmd:r(rwg_norm_mean)}}mean of rwg(j) across groups (normal null distribution){p_end}
{synopt:{cmd:r(rwg_norm_median)}}median of rwg(j) across groups (normal null distribution){p_end}
{synopt:{cmd:r(rwg_norm_range)}}range of rwg(j) across groups (normal null distribution){p_end}

{synopt:{cmd:r(rwg_custom_mean)}}mean of rwg(j) across groups (user-specified null distribution){p_end}
{synopt:{cmd:r(rwg_custom_median)}}median of rwg(j) across groups (user-specified null distribution){p_end}
{synopt:{cmd:r(rwg_custom_range)}}range of rwg(j) across groups (user-specified null distribution){p_end}

{synopt:{cmd:r(rstarwg_mean)}}mean of r*wg(j) across groups{p_end}
{synopt:{cmd:r(rstarwg_median)}}median of r*wg(j) across groups{p_end}
{synopt:{cmd:r(rstarwg_range)}}range of r*wg(j) across groups{p_end}

{synopt:{cmd:r(rapowgA_mean)}}mean of r'wg(A) across groups{p_end}
{synopt:{cmd:r(rapowgA_median)}}median of r'wg(A) across groups{p_end}
{synopt:{cmd:r(rapowgA_range)}}range of r'wg(A) across groups{p_end}
{synopt:{cmd:r(rapowgB_mean)}}mean of r'wg(B) across groups{p_end}
{synopt:{cmd:r(rapowgB_median)}}median of r'wg(B) across groups{p_end}
{synopt:{cmd:r(rapowgB_range)}}range of r'wg(B) across groups{p_end}
{synopt:{cmd:r(rapowgC_mean)}}mean of r'wg(C) across groups{p_end}
{synopt:{cmd:r(rapowgC_median)}}median of r'wg(C) across groups{p_end}
{synopt:{cmd:r(rapowgC_range)}}range of r'wg(C) across groups{p_end}
{synopt:{cmd:r(rapowgD_mean)}}mean of r'wg(D) across groups{p_end}
{synopt:{cmd:r(rapowgD_median)}}median of r'wg(D) across groups{p_end}
{synopt:{cmd:r(rapowgD_range)}}range of r'wg(D) across groups{p_end}

{synopt:{cmd:r(awg_mean)}}mean of awg(j) across groups{p_end}
{synopt:{cmd:r(awg_median)}}median of awg(j) across groups{p_end}
{synopt:{cmd:r(awg_range)}}range of awg(j) across groups{p_end}

{synopt:{cmd:r(ADM_mean)}}mean of ADM across groups{p_end}
{synopt:{cmd:r(ADM_median)}}median of ADM across groups{p_end}
{synopt:{cmd:r(ADM_range)}}range of ADM across groups{p_end}
{synopt:{cmd:r(ADMd_mean)}}mean of ADMd across groups{p_end}
{synopt:{cmd:r(ADMd_median)}}median of ADMd across groups{p_end}
{synopt:{cmd:r(ADMd_range)}}range of ADMd across groups{p_end}

{p2colreset}{...}

{marker examples}{...}
{title:Examples}

{pstd}Multiple groups, multi-item five-point scale{p_end}
{phang2}{cmd:. ira judge_id rating, item(item_id) group(group_id) options(5)}{p_end}

{pstd}Single group, multi-item scale{p_end}
{phang2}{cmd:. ira judge_id rating, item(item_id)}{p_end}

{pstd}Multiple groups, single-item scale{p_end}
{phang2}{cmd:. ira judge_id rating, group(group_id)}{p_end}

{pstd}Single group, single-item six-point scale{p_end}
{phang2}{cmd:. ira judge_id rating, options(6)}{p_end}

{pstd}Single group, single-item scale{p_end}
{phang2}{cmd:. ira judge_id rating}{p_end}

{marker references}{...}
{title:References}

{phang}Brown, R. D., & Hauenstein, N. M. (2005). Interrater agreement reconsidered: An alternative to the rwg indices. {it:Organizational Research Methods}, 8(2), 165-184.{p_end}
{phang}Burke, M. J., Finkelstein, L. M., & Dusig, M. S. (1999). On average deviation indices for estimating interrater agreement. {it:Organizational Research Methods}, 2(1), 49-68.{p_end}
{phang}Dunlap, W. P., Burke, M. J., & Smith-Crowe, K. (2003). Accurate tests of statistical significance for rWG and average deviation interrater agreement indexes. {it:Journal of Applied Psychology}, 88(2), 356-362.{p_end}
{phang}Finn, R. H. (1970). A note on estimating the reliability of categorical data. {it:Educational and Psychological Measurement}, 30(1), 71-76.{p_end}
{phang}Harvey, R. J., & Holl, E. (2004). Benchmarking rwg interrater agreement indices: Let’s drop the .70 rule-of-thumb. Paper presented at the {it:Annual Conference of the Society for Industrial and Organizational Psychology}.{p_end}
{phang}James, L. R., Demaree, R. G., & Wolf, G. (1984). Estimating within-group interrater reliability with and without response bias. {it:Journal of Applied Psychology}, 69(1), 85-98.{p_end}
{phang}James, L. R., Demaree, R. G., & Wolf, G. (1993). r wg: An assessment of within-group interrater agreement. {it:Journal of Applied Psychology}, 78(2), 306-309.{p_end}
{phang}LeBreton, J. M., & Senter, J. L. (2008). Answers to 20 questions about interrater reliability and interrater agreement. {it:Organizational Research Methods}, 11(4), 815-852.{p_end}
{phang}Lindell, M. K. (2001). Assessing and testing interrater agreement on a single target using multi-item rating scales. {it:Applied Psychological Measurement}, 25(1), 89-99.{p_end}
{phang}Lindell, M. K., Brandt, C. J., & Whitney, D. J. (1999). A revised index of interrater agreement for multi-item ratings of a single target. {it:Applied Psychological Measurement}, 23(2), 127-135.{p_end}
{phang}O'Neill, T. A. (2017). An Overview of Interrater Agreement on Likert Scales for Researchers and Practitioners. {it:Frontiers in Psychology}, 8:777.{p_end}
{phang}Smith-Crowe, K., Burke, M. J., Cohen, A., & Doveh, E. (2014). Statistical significance criteria for the rWG and average deviation interrater agreement indices. {it:Journal of Applied Psychology}, 99(2), 239-261.{p_end}

{marker author}{...}
{title:Author}

{phang}Lorenz Graf-Vlachy{p_end}
{phang}{browse "http://www.graf-vlachy.com":graf-vlachy.com}{p_end}
{phang}mail@graf-vlachy.com{p_end}

