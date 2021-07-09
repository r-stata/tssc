{smcl}
{* *! version 0.2  3mar2015}{...}
{cmd:help randomize}
{hline}

{title:Title}

{pstd}
{hi:randomize} {hline 2} Random assignment for experimental trials, including blocking, balance checking, and automated rerandomization.
{p_end}

{marker syntax}{title:Syntax}

{pstd} 
{cmd:randomize} {ifin}{cmd:, }
[{it:options}]

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}

{syntab:Main}
{synopt:{opt {ul on}bal{ul off}ance:(varlist)}} List of variables on which to test for balance. {p_end}
{synopt:{opt {ul on}gr{ul off}oups:(#)}} Number of groups to create of equal size within the assignment variable; default is {cmd:2}. {p_end}
{synopt:{opt {ul on}gen{ul off}erate(newvar)}} Name of the assignment variable; default is {cmd:_assignment}. {p_end}
{synopt:{opt {ul on}bl{ul off}ock(varlist)}} List of variables to block on. These are combined into a strata variable, and randomizations are conducted within blocks. {p_end}
{synopt:{opt {ul on}minr{ul off}uns(#)}} Minimum number of randomizations to run; default is {cmd:1}. Per-block. {p_end}
{synopt:{opt {ul on}maxr{ul off}uns(#)}} Maximum number of randomizations to run; default is {cmd:1}. Per-block. {p_end}
{synopt:{opt seed(integer)}} The random number generator seed to use, which ensures the randomization is replicable. Can also be set manually. {p_end}
{synopt:{opt replace}} Overwrite existing assignment variable. {p_end}
{synopt:{opt {ul on}agg{ul off}regate(numlist)}} Provide a list of numbers denoting how the resulting assignments should be aggregated into larger groups.
This allows for unequal allocation sizes while still checking balance on equally sized groups. The list of numbers must sum to the number of groups.

{syntab:Advanced}
{synopt:{opt jointp(real)}} Minimum balance p-value allowable to accept a given randomization, ranging from 0 to 1. {p_end}
{synopt:{opt details}} Show the detailed results for each randomization attempt, which are hidden by default.

{marker desc}{title:Description}

{pstd} {cmd:randomize} conducts random assignment of units to equally sized groups. It can check for balance on a specified list of covariates.
If blocking variables are specified it will conduct the randomization within blocks. It can rerandomize within blocks a certain number of times, such as conducting 100 randomizations
and choosing the randomization with the best balance across covariates. It can also rerandomize until the balance statistic (Wilks' lambda on a manova)
exceeds a certain cut-off value (e.g. 0.2). If unequal allocation sizes are desired, multiple groups can be aggregated after the randomization.
Assignments are allocated in a random order within each block, ensuring that group sizes differ by no more than one observation in each block.

{pstd} For clustered random assignment, one will need to handle the clustering manually, such as collapsing the dataset to the cluster level or choosing one representative unit
per cluster. The randomization algorithm can then be run on that dataset, and the assignments can be copied to all units in the cluster.

{marker ex}{title:Examples}

{phang}1. Randomize a dataset into 2 groups, checking for balance by gender.{p_end}

{pmore}{inp:. randomize, balance(gender)}

{phang}2. Randomize a dataset into 5 equally-sized groups, blocking by state and gender.{p_end}

{pmore}{inp:. randomize, groups(3) balance(age gender) jointp(0.2)}

{phang}3. Randomize a dataset into 3 groups, checking for balance on age and gender. Rerandomize up to 100 times or until the balance p-value exceeds 0.2.{p_end}

{pmore}{inp:. randomize, groups(3) balance(age gender) jointp(0.2) maxruns(100)}

{phang}4. Create 4 groups, check for covariate balance on gender, race, and age, block on state, choose the most balanced of 500 randomizations within each block, and specify the random number generator seed.{p_end}

{pmore}{inp:. randomize, groups(4) balance(gender race age) block(state) minruns(500) seed(1)}

{phang}5. Create a 10% / 20% / 70% split by randomizing into 10 equally sized groups then aggregating those assignments.{p_end}

{pmore}{inp:. randomize, groups(10) aggregate(1 2 7)}

{phang}6. Use the quiet prefix to hide all randomization output and just get the result.{p_end}

{pmore}{inp:. quiet randomize, balance(state) minruns(1000)}

{phang}7. Use the details option to show all randomization output.{p_end}

{pmore}{inp:. randomize, balance(state) minruns(1000) details}

{phang}8. Simulated dataset example - randomize 10,000 records across 4 blocks, and take the best randomization out of 500 per block.{p_end}

{pmore}{inp: clear}{p_end}
{pmore}{inp: set obs 10000}{break}{p_end}
{pmore}{inp: set seed 2}{p_end}
{pmore}{inp: gen covariate = uniform()}{p_end}
{pmore}{inp: gen block_var = ceil(uniform() * 4)}{p_end}
{pmore}{inp: randomize, block(block_var) balance(covariate) minruns(500)}{p_end}

{phang}9. Clustered Randomization v1 - select a random record within the cluster, conduct the randomization on those records, then apply the assignment to the full cluster.{p_end}

{pmore}{inp: * Create a combined cluster id}{p_end}
{pmore}{inp: egen cluster_id = group(cluster_field1 cluster_field2)}{p_end}
{pmore}{inp: set seed 1}{p_end}
{pmore}{inp: set sortseed 2}{p_end}
{pmore}{inp: gen double random = runiform()}{p_end}
{pmore}{inp: * Randomly order individuals within clusters.}{p_end}
{pmore}{inp: bysort cluster_id (random): egen cluster_seq = seq()}{p_end}
{pmore}{inp: * Randomize using the demographics of the first cluster member to check for balance.}{p_end}
{pmore}{inp: randomize if cluster_seq == 1, balance(covar1 covar2) block(blockvar1 blockvar2) replace}{p_end}
{pmore}{inp: * Expand assignment to all units in the cluster.}{p_end}
{pmore}{inp: bysort cluster_id: egen assignment = mode(_assignment)}{p_end}


{phang}10. Clustered Randomization v2 - compress the dataset to the cluster level, conduct the randomization, then merge the assignment back to the full dataset.{p_end}

{pmore}{inp: * Create a combined cluster id}{p_end}
{pmore}{inp: egen cluster_id = group(cluster_field1 cluster_field2)}{p_end}
{pmore}{inp: set seed 1}{p_end}
{pmore}{inp: set sortseed 2}{p_end}
{pmore}{inp: * Save the uncompressed version of the dataset.}{p_end}
{pmore}{inp: preserve}{p_end}
{pmore}{inp: * Aggregate to the cluster level, creating summary statistics for the randomization.}{p_end}
{pmore}{inp: collapse (mean) covar1 covar2 (max) rare_covar3 (count) cluster_size, by(cluster_id)}{p_end}
{pmore}{inp: * Execute the randomization at the cluster level.}{p_end}
{pmore}{inp: randomize, balance(covar1 covar2 rare_covar3) replace}{p_end}
{pmore}{inp: * Restrict to the data that we need.}{p_end}
{pmore}{inp: keep cluster_id _assignment}{p_end}
{pmore}{inp: save "cluster-assignments.dta", replace}{p_end}
{pmore}{inp: * Switch back to the full dataset.}{p_end}
{pmore}{inp: restore}{p_end}
{pmore}{inp: merge m:1 cluster_id using "cluster-assignments.data"}{p_end}

{title:References}

{phang}
Lock Morgan, K. and Rubin, D. B. (2012). Rerandomization to improve covariate balance in experiments. Ann. Statist. Volume 40, Number 2, 1263-1282.
{p_end}

{phang}
Lock Morgan, K. (2011). Rerandomization to improve covariate balance in randomized experiments. PhD dissertation. Harvard University, Department of Statistics.
{p_end}

{title:Website}

{pstd}{cmd:Randomize} is maintained at {browse "http://github.com/ck37/randomize_ado":http://github.com/ck37/randomize_ado}{p_end}

{title:Authors}

{pstd}Chris J. Kennedy{p_end}
{pstd}University of California, Berkeley{p_end}
{pstd}{browse "mailto:ck37@berkeley.edu":ck37@berkeley.edu}{p_end}
{pstd}{browse "http://ck37.com":http://ck37.com}{p_end}

{pstd}Christopher B. Mann{p_end}
{pstd}Skidmore College{p_end}
{pstd}{browse "mailto:christopherbmann@gmail.com":christopherbmann@gmail.com}{p_end}
{pstd}{browse "http://www.christopherbmann.com/":http://www.christopherbmann.com}{p_end}

{title:Acknowledgements}

{phang} We thank Debby Kermer for earlier contributions to parts of the algorithm, John Ternovski for helpful comments, and Kari Lock Morgan for the underlying theory and suggestion of the Wilks lambda balance statistic.
