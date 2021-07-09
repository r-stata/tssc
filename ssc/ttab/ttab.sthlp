{smcl}
{* version 1.0 08aug2013}{...}
{hline}
help for {hi:ttab} (August 8, 2013)
{hline}


{title:tables with t-test for two-groups mean-comparison}

{p 8 16 2}
{cmd:ttab varlist [if] [in]}{cmd:, }{opt by(groupvars)} [options]


{marker ttaboptions}{...}
{synoptset 29 tabbed}{...}
{synopthdr :ttab_options}
{synoptline}
{synopt :{opt *by}({it:groupvars})}specifies the {it:groupvar} that defines the two groups that {help ttest} will use to test the hypothesis that their means are equal, and implies an unpaired (two sample) t test. 
More than one {it:groupvar} can be specified. If this is the case, {cmd:ttab} will stack the resulting tables.{p_end}
{synopt :{opt over}({it:varname})}group over subpopulations defined by {it:varname}.{p_end}
{synopt :{opt over2}({it:varname2})}group over subpopulations defined by {it:varname2}.{p_end}
{synopt :{opt tshow}}displays the t-test statistic (and related p-value, if requested through the {help estout} option {opt se}) instead of the means' difference (and related standard error).{p_end}
{synopt :{opt tofile}({it:filename} [, replace])}specifies a {it:filename} to export the table. You have to specify the {it:filename} in quotes if it contains blanks or other special characters.{p_end}
{synopt :{opt byvarslab:els(string)}}specifies labels for the {opt by}() variable(s).{p_end}
{synopt :{opt ti:tle(string)}}specifies the title for the table. It is rarely used.{p_end}
{synopt :{opt ttest(string)}}specifies the {it:{help ttest##options2:ttest}} options to perform the two-group mean-comparison test.{p_end}
{synopt :{opt estout(string)}}specifies the {it:{help estout##opt0:estout}} options to format the output table. {help estout} must be installed.{p_end}
{synoptline}
{p 4 6 2}*{opt by}({it:groupvars}) is required.
{p_end}


{title:Description}

{pstd}
{cmd:ttab} displays a table of means for the variable(s) specified in {it:varlist} together with a t-test for the two-groups mean-comparison. The two groups are defined by the variable(s) specified in {opt by}({it:groupvars}). 
{opt over}({it:varname}) and {opt over2}({it:varname2}) can be used to group over subpopulations defined by {it:varname} and {it:varname2}.

{pstd}
{cmd:ttab} is basically a wrapper for {help ttest} and {help estout}. 
It makes use of {help ttest} to perform the two-groups mean-comparison test. 
It makes use of {help estout} to produce and display a publication quality table that can be simply displayed or exported as a separate file. See {help estout} for more details on the "style" for the output table.


{title:Example}

{cmd:webuse byssin}

{cmd:ttab pop, by(smokes) estout(c(b(fmt(2) star)) mlab(,none) collab(,none))}

{cmd:ttab pop, by(smokes) over(race) estout(c(b(fmt(2) star)) mlab("other" "white") collab(,none))}

{cmd:ttab pop, by(smokes) over(race) over2(workplace) estout(c(b(fmt(2)) se(fmt(3) par)) ///}
{cmd:  			mlab("white" "white" "white" "other" "other" "other") ///}
{cmd:  			mgroups("least" "less" "most", pattern(1 0 1 0 1 0)) collab(,none))}

{cmd:ttab pop, by(smokes) over(race) over2(workplace) tshow estout(c(b(fmt(2)) se(fmt(3) par))}
{cmd:  			mlab("white" "white" "white" "other" "other" "other") ///}
{cmd:  			mgroups("least" "less" "most", pattern(1 0 1 0 1 0)) collab(,none))}


{title:Authors}

   Federico Belotti
   Tor Vergata University
   federico.belotti@uniroma2.it

