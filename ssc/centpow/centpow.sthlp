{smcl}
{* 15oct2012}{...}
{hline}
help for {hi:centpow}
{hline}

{title:Network Centrality and Power}

{p 8 16 2}{cmd:centpow}
   {it:filename}
   {cmd:,}
     [ {cmd:{ul:norm}alize}
     {cmd:beta(}{it:real}{cmd:)}
     {cmd:saveas(}{it:filename}{cmd:)}]


{title:Description}

{p 4 4 2}
{cmd:centpow} creates a new dataset containing the degree centrality, alter-based centrality and power, and beta centrality and power for each node in a symmetric network described by {it:filename}. {p_end}
{p 4 4 2}[NOTE: This command does not affect the data in memory.]


{title:Options}
{p 4 8 2}{cmd:normalize} Requests that each measure be normalized using the approach described by Bonacich (1987).{p_end}
{p 4 8 2}{cmd:beta(}{it:real}{cmd:)} Specifies the value of the {it:beta} parameter used to compute beta centrality and power (must be positive).
[Default = .995 * 1/largest eigenvalue; this makes beta centrality roughly equivalent to eigenvector centrality.]{p_end}
{p 4 8 2}{cmd:saveas(}{it:filename}{cmd:)} Specifies the name of the new file containing the centrality and power scores.  The default is {it:centpow.dta}.{p_end}


{title:Input}
{p 4 4 2}{it:filename} must be a comma-delimited file containing a square, symmetric matrix.  The matrix entries may be either binary or valued.


{title:Output}
{p 4 4 2}Each vector of scores is saved as a variable, with the observations in the same order as the rows and columns of the input matrix.

{p 4 4 2}Degree centrality is defined as a node's total number of connections, and is saved as the variable {it:degree}.

{p 4 4 2}Alter-based centrality and power are extensions of degree centrality in which each node's score is based on the degree centrality of the nodes to which it is connected.  
Alter-based centrality is defined as the sum of the degree centralities of a node's alters, and is saved as the variable {it:altercent}.
Alter-based power is defined as the sum of the inverse degree centralities of a node's alters, and is saved as the variable {it:alterpow}.

{p 4 4 2}Beta centrality and power are saved as the variables {it:betacent} and {it:betapow}, respectively.
These measures are conceptually similar to alter-based centrality and power, and often yield similar results.
However, they are computationally distinct (see Bonacich 1987) and are subject to several assumptions:{p_end}

{p 8 8 2}(1) The network contains no disconnected components,{p_end}

{p 8 8 2}(2) The largest eigenvalue is substantially larger than the 2nd largest eigenvalue,{p_end}

{p 8 8 2}(3) The absolute value of {it:beta} is less than the reciprocal of the largest eigenvalue.{p_end}

{p 4 4 2}If any of these assumptions is violated, the command will issue a warning, but will still compute the measures.{p_end} 


{title:References}

{p 0 5}
Neal, Z. P. (2011)  Differentiating Centrality and Power in the World City Network, {it:Urban Studies} 48: 2733-2748. ({browse "https://www.msu.edu/~zpneal/publications/neal-differentiating.pdf":CLICK FOR PDF})

{p 0 5}
Neal, J. W. and Z. P. Neal.  (in press)  Power as a Structural Phenomenon, {it:American Journal of Community Psychology} 48: 157-167. ({browse "https://www.msu.edu/~zpneal/publications/neal-power.pdf":CLICK FOR PDF})

{p 0 5}
Bonacich, P.  (1987)  Power and Centrality: A Family of Measures, {it:American Journal of Sociology} 92: 1070-82.


{title:Author}

Zachary Neal
Department of Sociology
Michigan State University
zpneal@msu.edu

