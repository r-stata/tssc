{smcl}
{* *! version 1.0.0 29nov2017}{...}
{phang}
{bf:rdatasets}{hline 2} R Datasets Available in CSV format from GitHub

{marker description}{...}
{title:Description}

{pstd}
{bf:rdatasets} facilitates access to a large collection of datasets
distributed with R or some of its packages. The collection was assembled
"to make these data more broadly accessible for teaching and statistical 
software development". The command has three subcommands: {bf:list},
{bf:doc} and {bf:get}, described below.

{marker list}{...}
{title:List}

{phang}
{bf:rdatasets list [, clear]} 

{p 8 8 2}
with no additional arguments, will list the
packages available. On first use the command downloads a
database of datasets, so you must start with an empty dataset or specify clear.
The list of packages includes links to list the datasets in each package.

{phang}
{bf:rdatasets list} {it:package} {bf:[, clear]}

{p 8 8 2}
lists the datasets available in a particular package or collection. 
The list of datasets includes links to access their
online documentation.  Like its predecessor, this subcommand will download
the database if necessary. The database may be searched directly.

{marker doc}{...}
{title:Doc}

{phang}
{bf:rdatasets doc} {it:package} {it:dataset}

{p 8 8 2}
Accesses the online documentation of a dataset. You must specify both the
package name and the dataset name. This subcommand does not interfere
with the dataset currently in memory, which may, of course, be the database.

{marker get}{...}
{title:Get}

{phang}
{bf:rdatasets get} {it:package} {it:dataset} {bf:[, clear]}

{p 8 8 2}
Downloads a given dataset. You must specify both the package name and the
dataset name. You must also start with an empty dataset or specify clear.
The command uses insheet, which prints the number of variables and the number 
of observations downloaded.

{marker remarks}{...}
{title:Remarks}

{pstd}
The command requires an Internet connection to operate, as the database and
any requested datasets are always downloaded directly from GitHub to ensure
that you always get the latest version available. Some of these datasets
may be available in Stata format from other sources.

{marker author}{...}
{title:Authors}

{pstd}
The collection was assembled in GitHub by Vincent Arel-Bundock,
see {browse "https://vincentarelbundock.github.io/Rdatasets/":R Datasets}.
The {cmd:rdatasets} command was written by Germ{c a'}n Rodr{c i'}guez
<grodri@princeton.edu>.
