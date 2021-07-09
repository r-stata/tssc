{smcl}
help for {cmd:dtapaper}{right:also see: {helpb setdtapaper}}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col :Data Paper} {p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 17 2}{cmd:dtapaper}

{title:Description}

{pstd} {cmd:dtapaper} creates a datapaper in HTML-format. It collects information
by user-input as well as automatically generated information based on the data stored
in memory.

{pstd} The objective of this program is to create a quotable paper, which contains
information about a self-created dataset. This paper will help other researchers to find 
your data within databases or with a search engine.

{pstd} It will not only help other researchers to find sepcial datasets, researches who 
spent a lot of time in creating a unique dataset can get credits by others using and citing 
this datasat. In the near future {cmd:dtapaper} will be harmonized in order to easily provide 
meta-information for different databases like Sowiport or Datorium.

{pstd} You can use {helpb setdtapaper} to create global macros that will be used as 
default values in {cmd:dtapaper}. Thus you avoid entering all the information, that 
is required for dtapaper, over and over again.

{dlgtab 4 2:Main}

{title:Data description}
{pstd} In this part you describe your dataset. While {bf:Title}, {bf:Abstract} and
{bf:Time} are obligatory information, all other fields are optional. We recommend to
give as much information as possible.{p_end}
{pstd}NOTE: The {bf:Abstract}-field does not provide line-breaks! Do not press {it:Enter}
to get a new line, this would result in closing the dtapaper-window.

{pstd} In {bf:Source} you should provide information on what data your dataset is
originally based on. For example you combine your own data with data from other sources,
you should give this information in this field.

{pstd} If your dataset is accessible for others, you should provide this information
(e.g. URL, DOI, ...) in the {bf:Access} field.

{pstd} For the {bf:Time-Range} of your data you can either use the drop-down menus, or
type in the year manually.

{title:Personal information}
{pstd} For the {bf:Author} field you have to follow two rules: 1. Separate multiple authors
with "and". 2. Write each name in the following format: {it:Lastname, Firstname}

{title:Output}
{pstd} Specify where to save the datapaper on your computer. You should only type the
filename {ul:without} a file-extension. The file will be automatically saved in HTML-format.

{dlgtab 4 2:Options}

{title:Labels and notes}
{pstd} The first option will include a list of variables and variable-labels. It is also possible
to add value labels (max. 10) for each variable. This last option may require some time,
depending on your computer and the number of variables.


{pstd} The next options have no effect for the datapaper, but will modify the dataset:

{pstd} You can add a data-label (up to 80 characters) in the format {it:Author(Year): Title}.
You can also add notes to your data with all information you provided before. If you add notes,
you have to decide whether to drop the orignal notes or keep them and append the new notes.

{pstd} You can save (and replace) your dataset in order to keep the new data-label and/or the
notes permanently.

{title:Additional information}
{pstd} You can add more information like {bf:number of observations}, {bf:number of variables}
and also the {bf:filename} to your datapaper. Again, we recommend to include as much information
as possible in order to make your data discoverable and most accessible for other researches.


{title:Author}
{pstd}Christoph Thewes, University of Potsdam, thewes@uni-potsdam.de{p_end}
{psee} {hi:http://www.uni-potsdam.de/soziologie-methoden/thewes.html}

{title:Version}
{pstd}1.0.0: 02/12/2015
