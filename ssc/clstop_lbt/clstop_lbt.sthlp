{smcl}
{* *! version 1.1.2; February 09, 2013 @ 13:44:00 DE}{...}
{hi:help clstop_lbt}
{hline}

{title:Title}

{p 4 18 2}
{hi:clstop_lbt} -- Steinley & Brusco's lower bound technique (LBT) to determine the number of kmeans clusters

{title:Syntax}

{phang}
   {cmd: cluster stop [{it:clname}], rule(lbt)}

{title:Description}

{pstd}{cmd:clstop_lbt} adds the rule {hi:lbt} to the post-estimation command {help cluster stop} to
determine the number of k-means clusters using Steinley & Brusco's (2011) lower bound technique
(LBT).

{pstd}{hi:clstop_lbt} creates the normalized index LBT that measures the closeness of the observed
value of the within-cluster sums of squares (SSE) to the minimum value of SSE in terms of total
sums of squares (SST) according to LBT = (SSE - SSE(min))/SST. The method to determine the lower
bound of the SSE is given in Steinley & Brusco (2011, p. 289). If the number of variables is equal or
less than the number of clusters {it:k}, LBT is equal to the ratio SSE/SST (in this case, the LBT cannot
be used). Using the LBT, a partition into {it:k} clusters is chosen such that LBT({it:k}) is minimum.

{pstd}{hi:clstop_lbt} can also be used to determine whether there is more than one cluster. In this
case the ratio SSE(2)/SST of a two cluster solution should be less than the lower bound ratio (LBR)
obtainable when there is only one cluster - assuming a (multivariate) normal distribution, the
LBR(normal) is 1-2/pi = .3634, assuming a univariate distribution the LBR(univariate) is .25.

{pstd}A simulation study by Steinley & Brusco (2011) shows that the LBT index outperforms the
accuracy and precision of the CH (Calinski-Harabasz) index. However, the LBT requires that the
number of variables exceed the number of clusters. In cases of equal or more clusters than the
number of variables Steinley & Brusco recommend to use the CH index which is also calculated by
{cmd: clstop_lbt} (see {help clstop_lbt##results:Saved Results}) and which is the default
when using -cluster stop-.

{title:Example}

{phang}. {stata webuse iris}{p_end}
{phang}. {stata cluster kmeans seplen-petwid, k(2) s(pr(1))}{p_end}
{phang}. {stata cluster stop, rule(lbt)}{p_end}
{phang}. {stata cluster kmeans seplen-petwid, k(3) s(pr(1))}{p_end}
{phang}. {stata cluster stop, rule(lbt)}{p_end}
{phang}. {stata cluster kmeans seplen-petwid, k(4) s(pr(1))}{p_end}
{phang}. {stata cluster stop, rule(lbt)}{p_end}

{marker results}{...}
{title:Saved Results}

{pstd} {cmd:cluster stop} with {cmd:rule(lbt)} saves the following in {cmd:r()}: {p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(N)}}number of valid cases (listwise){p_end}
{synopt:{cmd:r(k)}}number of partitions (clusters){p_end}
{synopt:{cmd:r(SSE_#)}}Within clusters (error) sum of squares for # partitions{p_end}
{synopt:{cmd:r(SSB_#)}}Between clusters sum of squares for # partitions{p_end}
{synopt:{cmd:r(SSE_SST_#)}}Ratio SSE/SST for # partitions{p_end}
{synopt:{cmd:r(calinski_#)}}Calinski & Harabasz pseudo F for # partitions{p_end}
{synopt:{cmd:r(LBT_#)}}Index LBT for # partitions{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:r(clname)}}name of the cluster analysis{p_end}
{synopt:{cmd:r(vars)}}list of variables used{p_end}
{synopt:{cmd:r(rule)}}{cmd:lbt}{p_end}

{title:References}

{phang}Steinley, D. & Brusco, M. J. (2011). {browse "http://psycnet.apa.org/journals/met/16/3/285/":Choosing the number of clusters in K-means clustering}. {it:Psychological Methods}, {it:16}, 285-297.{p_end}

{title:Also see}

{psee}
Manual: {manhelp cluster_subroutines MV:cluster programming subroutines}{p_end}

{title:Author}

{phang}Dirk Enzmann{p_end}
{phang}Institute of Criminal Sciences, Hamburg{p_end}
{phang}email: {browse "mailto:dirk.enzmann@uni-hamburg.de"}{p_end}
