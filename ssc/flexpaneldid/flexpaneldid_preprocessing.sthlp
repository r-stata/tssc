{smcl}

{title:Title}

{pstd}
{hi:flexpaneldid_preprocessing} {hline 1} Data preprocessing for flexpaneldid 
{p_end}


{title:Syntax}

{p 4 32 2}
{cmd:flexpaneldid_preprocessing}{cmd:,} 
{cmd:id(}{it:varname}{cmd:)} 
{cmd:treatment(}{it:varname}{cmd:)} 
{cmd:time(}{it:varname}{cmd:)} 
{cmd:matchvars(}{it:varlist}{cmd:)} {cmd:matchtimerel(}{it:integer}{cmd:)}
[{cmd:matchvarsexact(}{it:varlist}{cmd:)} {cmd:prepdataset(}{it:string}{cmd:)} {cmd:replace}]
{p_end}


{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}
{synopt :{opt id(varname)}}name of the panel id variable{p_end}
{synopt :{opt treatment(varname)}}name of the treatment variable{p_end}
{synopt :{opt time(varname)}}name of the time variable{p_end}
{synopt :{opt matchvars(varlist)}}list of matching variables{p_end}
{synopt :{opt matchtimerel(integer)}}definition of matching time in relation to treatment start{p_end}
{synopt :{opt matchvarsexact(varlist)}}list of exact matching variables{p_end}
{synopt :{opt prepdataset(filename)}}filename of preprocessed dataset{p_end}
{synoptline}


{title:Description}

{pstd}
{cmd:flexpaneldid} is a Stata package for causal analysis of treatments with varying start dates and varying treatment durations within panel data with more than two observation times. It consists of two commands based on each other, 
{cmd:flexpaneldid_preprocessing} and 
{cmd:flexpaneldid}. In the 
{cmd:flexpaneldid_preprocessing}, the original data set is rearranged in that individual selection groups for every treated unit are created which contain all potential controls. The result of this preprocessing is a temporary dataset with information that are crucial for the use of  
{cmd:flexpaneldid}.
{p_end}

{pstd}
Based on the temporary data set, 
{cmd:flexpaneldid} estimates the average treatment effect for the treated. For this step, different matching approaches are available. Additionally, quality and robustness checks can be conducted.
{p_end}

{pstd}
The flexpaneldid package requires the installation of the Stata ado-files psmatch2, pstest and cem, which are used in the {cmd:flexpaneldid} command.
{p_end}


{title:Arguments}

{dlgtab:Main}

{phang}
{opt id(varname)} uniquely identifies objects in the panel dataset. The variable must be an integer or string.

{phang}
{opt treatment(varname)} contains the variable defining the treatment. Input must be in 0-1 format.
{break}
IMPORTANT NOTE: The variable must equal to one for the whole treatment phase. In case of repeated treatments for 
one unit (identified by a unique id), the repeated treatments are handled as one treatment phase. 

{phang}
{opt time(varname)} identifies the time information in the panel. Input must be an integer indicating an absolute time, e. g. year, month, quarter.
{break}
IMPORTANT NOTE: If the data contain only information in date-format, this information must be converted into an integer.

{phang}
{opt matchvars(varlist)}} should contain all variables that may be used for matching.

{phang}
{opt matchtimerel(int)} is a relative time specification (in relation to the treatment start) that defines the time of matching;
default = 0 (if no matching time is defined). In this case, {cmd:flexpaneldid_preprocessing} uses variable values observed at the treatment start.
{break}
IMPORTANT NOTE: The dimension of the parameter in brackets depends on the dimension of time that is defined for {cmd:time()}.
For example, {opt matchtimerel(-1)} means that the matching process is conducted one year before the treatment starts, if the dimension of the time variable is years.

{dlgtab:Options}

{phang}
{opt matchvarsexact(varlist)} indicates those variables that are used for exact matching. Exact matching variables are applied already at the preprocessing step.

{phang}
{opt prepdataset(string)} {cmd:replace} specifies the path where the data set containing the preprocessing result is stored. {cmd:replace} overwrites any existing data set with the new data. We highly recommend the use of this option, since this file is a required argument for {cmd:flexpaneldid}. Otherwise you have to manually save the output dataset.
{p_end}

{title:Output}

{pstd}
After preprocessing the dataset is no longer in a panel structure. Every observation represent an {cmd:id} at {cmd:matchtimerel()}, where the exact matching selects the potential controls for every treated into a "selection group".
{p_end}

{synoptset 20 tabbed}{...}
{synopt:{cmd:id}}id variable as defined in {cmd:id()} option{p_end}
{synopt:{cmd:selection_goup}}all potential controls, exact matched to a treated, are in the same selection group{p_end}
{synopt:{cmd:treated}}dummy variable for treated(1) / non treated(0){p_end}
{synopt:{cmd:first_treatment}}first treatment time of treated, valid for whole selection group{p_end}
{synopt:{cmd:last_treatment}}last treatment time of treated, valid for whole selection group{p_end}
{synopt:{cmd:matchvars}}all variables defined in {cmd:matchvars()} at {cmd:matchtimerel()}{p_end}


{title:Stored results}

{pstd}{cmd:flexpaneldid_preprocessing} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 25 2: Scalars}{p_end}
{synopt:{cmd:r(treated)}}number of unique treated {cmd:id} in initial dataset{p_end}
{synopt:{cmd:r(treated_dropped)}}number of unique treated {cmd:id} dropped during preprocessing{p_end}
{synopt:{cmd:r(treated_kept)}}number of unique treated {cmd:id} after preprocessing{p_end}
{synopt:{cmd:r(group_size_mean)}}mean size of selection groups after exact matching{p_end}


{title:Example}

{phang}
{cmd: . use flexpaneldid_example_data.dta, clear}

{phang}
{cmd: . flexpaneldid_preprocessing, id(cusip) treatment(treatment) time(year) matchvars(employ stckpr rnd sales return pats_cat rndstck_cat rndeflt_cat) matchtimerel(-1) matchvarsexact(sic_cat) prepdataset("preprocessed_data.dta") replace}                              

{title:Also see}

{pstd}
{help flexpaneldid}
{p_end}


{title:Authors}

{pstd}Eva Dettmann, Halle Institute for Economic Research (IWH), eva.dettmann@iwh-halle.de{p_end}

{pstd}Alexander Giebler, Halle Institute for Economic Research (IWH), alexander.giebler@iwh-halle.de{p_end}

{pstd}Antje Weyh, Institute for Employment Research (IAB), antje.weyh@iab.de


{title:Thanks for citing the toolbox as follows}

{pstd}
E. Dettmann, A. Giebler and A. Weyh. (2020). flexpaneldid. A Stata toolbox for causal analysis with varying treatment time and duration.
{break}
https://ideas.repec.org/p/zbw/iwhdps/32020.html
{p_end}