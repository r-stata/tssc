{smcl}
{* *! version 1.0 2020.03.25}{...}
{viewerjumpto "Syntax" "uirt_sim##syntax"}{...}
{viewerjumpto "Description" "uirt_sim##description"}{...}
{viewerjumpto "Options" "uirt_sim##options"}{...}
{viewerjumpto "Examples" "uirt_sim##examples"}{...}
{viewerjumpto "Stored results" "uirt_sim##results"}{...}
{cmd:help uirt_sim}
{hline}

{title:Title}

{phang}
{bf:uirt_sim} {hline 2} Stata module to simulate data from unidimensional Item Response Theory models


{marker syntax}{...}
{title:Syntax}

{p 8 17 2} {cmd:uirt_sim} [{it:namelist}] {cmd:,} ipar() [ {it:{help uirt_sim##options:options}}]

{p 8 17 2} where {it:namelist} is a list of items to select from {opt ipar()} matrix; 
optional - used if one wants to generate a dataset just for some of the items listed in {opt ipar()}; 
not an abbreviated varlist, exact list of item names is required


{synoptset 24 tabbed}
{p2colset 7 32 34 4}
{marker options}{...}
{synopthdr :options}
{synoptline}

{syntab:Obligatory}
{synopt:{opt ipar(name)}} item parameters {p_end}

{syntab:Single group options}
{synopt:{opt m:ean(#)}} mean of normal distribution of theta; default value is mean(0) {p_end}
{synopt:{opt sd(#)}} standard deviation of normal distribution of theta; default value is sd(1) {p_end}
{synopt:{opt o:bs(#)}} number of generated observations; default value is obs(1000) {p_end}

{syntab:Multiple groups options}
{synopt:{opt grp:ar(name)}} parameters of normal distribution of theta in each group {p_end}
{synopt:{opt grn(name)}} number of observations in each group {p_end}

{syntab:User-specified variables}
{synopt:{opt theta(varname)}} use existing Stata variable with theta values {p_end}
{synopt:{opt gr:oup(varname)}} use existing Stata variable with grouping information {p_end}

{syntab:Other}
{synopt:{opt add:theta}} add a "theta" variable at the end of the dataset {p_end}
{synopt:{opt igrn(name)}} number of observations for each item in each group {p_end}
{synopt:{opt ic:ats(name)}} matrix with item categories {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:uirt_sim} generates responses according to IRT model specifications provided by the user.
It is capable of generating multigroup and incomplete design datasets. 
IRT model parameter formulation is the same as in  {helpb uirt} output, so the {cmd: uirt} results can be directly used as input for {cmd:uirt_sim}.


{marker options}{...}
{title:Options}

{dlgtab:Obligatory}

{phang}
{opt ipar(name)} sets the item parameters used for response simulation.
{opt ipar()} has to be a Stata matrix specified like {bf:e(item_par)} in {helpb uirt} output.


{dlgtab:Single group options}

{phang}
{opt mean(#)} sets the mean of normal distribution of theta; default value is mean(0).
Used if {opt theta()} or {opt grpar()} are not provided.

{phang}
{opt sd(#)} sets the standard deviation of normal distribution of theta; default value is sd(1).
Used if {opt theta()} or {opt grpar()} are not provided.

{phang}
{opt obs(#)} sets the number of generated observations; default value is obs(1000).
Used if theta() or grn() are not provided.
Can be used in multigroup setting - each group will be of size {opt obs()}.


{dlgtab:Multiple groups options}

{phang}
{opt grpar(name)} sets the parameters of normal distribution of theta in each group.
For single group it can be replaced by setting mean() and sd().
A "group" variable indicating group membership is added at the end of the dataset.
{opt grpar()} has to be a Stata matrix specified like {bf:e(group_par)} in {helpb uirt} output.

{phang}
{opt grn(name)} sets the number of observations in each group.
For single group it can be replaced by setting {opt obs()}.
{opt grn()} has to be a Stata matrix specified like {bf:e(group_N)} in {helpb uirt} output.


{dlgtab:User-specified variables}

{phang}
{opt theta(varname)} is used to provide a name of existing Stata variable with theta values to be used in response simulation.
If theta(varname) is specified {opt mean()} {opt and sd()} and {opt obs()} and {opt grpar()} and {opt grn()} options are ignored.
Missing values are not allowed in the theta() variable.

{phang}
{opt group(varname)} is used to provide a name of existing Stata variable with grouping information.
It requires {opt theta()} or properly specified {opt grpar()}. 
Missing values are not allowed in the group() variable.


{dlgtab:Other}

{phang}
{opt addtheta} adds a "theta" variable at the end of the dataset.
The variable contains theta values used in generating responses for each observation.
It is ignored if {opt theta()} is provided by the user.

{phang}
{opt igrn(name)} used to set the number of observations for each item in each group.
It is useful for defining incomplete design datasets.
If an item has less observations in a group than specified in {opt obs()} or {opt grn()} then the missing item responses 
will be generated at random within the group.
{opt igrn()} has to be a Stata matrix specified like {bf:e(item_group_N)} in {helpb uirt} output.

{phang}
{opt icats(name)} sets a matrix with item categories.
If it is not specified the responses are generated as consequtive integers 0,1,...,max_cat where max_cat is inferred from ipar() matrix.
{opt icats()} has to be a Stata matrix specified like {bf:e(item_cats)} in {helpb uirt} output.



{marker examples}{...}
{title:Examples}

{pstd}Creating a matrix with item parameters for 6 items in 2pl model {p_end}
{phang2}{cmd:. matrix define ipar_example=(1,1,1,1.5,1.5,1.5\-1,0,1,-1,0,1)'} {p_end}
{phang2}{cmd:. matrix colnames ipar_example= a b} {p_end}
{phang2}{cmd:. matrix roweq ipar_example= i1 i2 i3 i4 i5 i6} {p_end}
{phang2}{cmd:. matrix rownames ipar_example= 2plm 2plm 2plm 2plm 2plm 2plm} {p_end}
{phang2}{cmd:. mat l ipar_example} {p_end}

{pstd}Generating data according to "ipar_example" with default settings{p_end}
{phang2}{cmd:. uirt_sim,ipar(ipar_example)} {p_end}

{pstd}Generating two-group data according to "ipar_example" with {opt grpar()} and {opt grn()} settings{p_end}
{phang2}{cmd:. *1) creating an example matrix with parameters of normal distribution for each group to use in {opt grpar()}} {p_end}
{phang2}{cmd:. matrix define grpar_example=(0,-1\1,2)} {p_end}
{phang2}{cmd:. matrix colnames grpar_example=group_1 group_2} {p_end}
{phang2}{cmd:. matrix rownames grpar_example=mean sd} {p_end}
{phang2}{cmd:. mat l grpar_example} {p_end}
{phang2}{cmd:. *2) creating an example matrix with number of observations each group to use in {opt grn()}} {p_end}
{phang2}{cmd:. matrix define grn_example=(1000,2000)} {p_end}
{phang2}{cmd:. matrix colnames grn_example=group_1 group_2} {p_end}
{phang2}{cmd:. matrix rownames grn_example=N} {p_end}
{phang2}{cmd:. mat l grn_example} {p_end}
{phang2}{cmd:. *Generating the dataset} {p_end}
{phang2}{cmd:. uirt_sim,ipar(ipar_example) grpar(grpar_example) grn(grn_example)} {p_end}

{pstd}Previous example in NEAT design using {opt igrn()} setting{p_end}
{phang2}{cmd:. *3) creating an example matrix to use in {opt igrn()}: i1 i2 - responded in group_1, i5 i6 - responded in group_2, i3 i4 -  common items} {p_end}
{phang2}{cmd:. matrix define igrn_example=(1000,1000,1000,1000,0,0\0,0,2000,2000,2000,2000)'} {p_end}
{phang2}{cmd:. matrix colnames igrn_example=group_1 group_2} {p_end}
{phang2}{cmd:. matrix rownames igrn_example=i1 i2 i3 i4 i5 i6} {p_end}
{phang2}{cmd:. mat l igrn_example} {p_end}
{phang2}{cmd:. *Generating the dataset} {p_end}
{phang2}{cmd:. uirt_sim,ipar(ipar_example) grpar(grpar_example) grn(grn_example) igrn(igrn_example)} {p_end}

{pstd}Generating data only for items i1 i2 i3 i6 from "ipar_example" with user-provided "theta_user" variable{p_end}
{phang2}{cmd:. uirt_sim i1 i2 i3 i6,ipar(ipar_example) theta(theta_user)} {p_end}

{pstd} Generating data according to "ipar_example" matrix with items i1 and i3 scored 0,2 instead of 0,1 with {opt icats()} option{p_end}
{phang2}{cmd:. * creating an example matrix to use in {opt icats()}; only entries for item i1 and i3, remaining items will be scored as defaulted} {p_end}
{phang2}{cmd:. matrix define icats_example=(0,2\0,2)} {p_end}
{phang2}{cmd:. matrix colnames icats_example=cat_1 cat_2} {p_end}
{phang2}{cmd:. matrix rownames icats_example=i1 i3} {p_end}
{phang2}{cmd:. *Generating the dataset} {p_end}
{phang2}{cmd:. uirt_sim,ipar(ipar_example) icats(icats_example)} {p_end}


{marker results}{...}
{title:Stored results}

{syntab: {cmd: uirt_sim} does not store anything in r() or e()}


{title:Author}

Bartosz Kondratek
everythingthatcounts@gmail.com


{title:Funding}
Preparation of {cmd:uirt_sim} was funded by the National Science Center research grant number 2015/17/N/HS6/02965.





