{smcl}
{* *! version 1.0.0  10oct2019}{...}
{cmd:help md2ddi2_5}
{hline}

{title:Title}

{phang}
{bf:md2ddi2_5} {hline 2} Convert metadata file to DDI 2.5 compliant xml file.{p_end}


{title:Table of contents}

    {help md2ddi2_5##syn:Syntax}
    {help md2ddi2_5##des:Description}
    {help md2ddi2_5##ack:Acknowledgements}
    {help md2ddi2_5##aut:Author}

{marker syn}{...}
{title:Syntax}

{p 8 15 2}
{cmd:md2ddi2_5} {cmdab:in:put(}{it:filename}{cmd:)} {cmdab:out:put(}{it:filename}{cmd:)} [{cmdab:re:place} {cmdab:relat:ion}]

{marker args}{...}

{synoptset 28}{...}
{synopthdr:Arguments}
{synoptline}
{synopt:{cmdab:in:put}}specifies the meta data file which is converted to DDI2.5 compliant xml.{p_end}

{synopt:{cmdab:out:put}}specifies where the DDI2.5 compliant xml file is saved.{p_end}

{synopt:{cmdab:re:place}}specifies if output file replaces existing file.{p_end}

{synopt:{cmdab:relat:ion}}specifies that a relation among variables has been specified, i.e. the {cmd:mother} in the meta data file can be processed accordingly.{p_end}

{marker des}{...}
{title:Description}

{p 4 4 2}
{cmd:md2ddi2_5} convert metadata file created by {cmd:dta2md} to a DDI 2.5 compliant xml file. If no group variable is used, 
there is one variable element that contains information for the whole sample. If a group variable used, there is - in addition to the variable 
element for the whole sample - a variable element for each level of the group variable. If dependencies between variables have been defined using the relation option, 
these are presented in the DDI xml file as <varGrp> (variable groups). The variable groups have an unique id and contain the main 
variable as well as all associated variables in the "var"-attribute. In the case that the group option (to compute separate frequencies and descriptive statistics along the categories of a defined variable) 
was additionally used while creating the meta-file, the above mentioned aggregation will be made first for the value-specific main and the associated variables. 


{marker ack}{...}
{title:Acknowledgments}

{p 4 4 2}
Anne Balz

{marker aut}{...}
{title:Authors}

    Florian Thirolf, GESIS, florian.pforr@gesis.org
    Klaus Pforr, GESIS, klaus.pforr@gesis.org


