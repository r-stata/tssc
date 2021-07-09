{smcl}
{* Copyright 2012 Brendan Halpin brendan.halpin@ul.ie }
{* Distribution is permitted under the terms of the GNU General Public Licence }
{* 24June2012}{...}
{cmd:help discrepancy}
{hline}

{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{hi:discrepancy} {hline 2}}Calculate Studer et al's discrepancy measure{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}
{cmd:discrepancy} {it: groupvar} , DISTmat(string) IDvar(varname) [NITer(integer 100) DCG(string)]

{synoptset 22 tabbed}{...}
{synopthdr:options}
{synoptline}
{syntab:Required}
{synopt :{opt dist:mat(matname)}} names the distance matrix{p_end}
{synopt :{opt id:var(varname)}} identifies the variable that links the sort-order of the distance matrix to the sort-order of the data{p_end}
{syntab:Optional}
{synopt :{opt nit:er(interger)}} number of permutations used to calculate p-value, defaults to 100{p_end}
{synopt :{opt dcg:(string)}} variable in which to store the distance to the group centre{p_end}

{title:Description}

{pstd}{cmd:discrepancy} calculates Studer et al's measure of the
{it:discrepancy} of a distance matrix, grouped by a categorical variable
{it: groupvar}. The pseudo-R-squared and pseudo-F statistic are based on
the extent to which the average distance to the centres of the groups
are less than the average distance to the centre of the ungrouped
distance matrix. The p-value is based on permutations (100 by default,
but Studer et al recommend 1000 to 5000; set it to 1 for speed if you
are not interested in the p-value). {p_end}

{pstd}The distance to the centre of the group can optionally be saved in
a variable. This can be used to identify group medoids.{p_end}

{pstd}Returns:{p_end}
{phang}r(p_perm){p_end}
{phang}r(pseudoF){p_end}
{phang}r(pseudoR2){p_end}



{title:References}

{p 4 4 2}
M Studer, G Ritschard, A Gabadinho and NS Müller, Discrepancy analysis of state sequences, 
{it:Sociological Methods and Research}, 40(3):471-510

{title:Author}

{phang}Brendan Halpin, brendan.halpin@ul.ie{p_end}


{title:Examples}

{phang}{cmd:. discrepancy sex, dist(d) id(id) dcg(dsex)}{p_end}
{phang}{cmd:. bysort sex: egen mindist = min(dsex)}{p_end}
{phang}{cmd:. gen medoid = mindist == min(dsex)}{p_end}
