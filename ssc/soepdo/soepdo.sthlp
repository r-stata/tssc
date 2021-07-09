{smcl}
{* *! Version 1.1.1   29jul2008}{...}
{cmd:help soepdo}
{hline}

{title:Title}

{pstd}
{hi:soepdo} {hline 2} Retrieval of SOEP drop-outs made easy



{title:Syntax}

{pstd}
{opt soepdo} [{opt namelist}] , {opt s:oepdir()} {opt y:perg()} [{opt e:rhebj()}]



{title:Description}

{pstd}
{cmd:soepdo} is intended for people who need to build datasets which contain
 drop-outs from the German Socio-Economic Panel Study (SOEP Group, 2001). In the
 current version only the retrieval of variables in {it:YPBRUTTO} is supported.

{pstd}
Where appropriate the options are named as the variables in
{it:YPBRUTTO} which are
 used as criterium for inclusion of observation in your dataset.



{title:Options}

{phang}
{opt namelist} is optional. One may specify variables from {it:YPBRUTTO} here which are than included in the new dataset. If no variables are given, all variables from 
  {it:YPBRUTTO} are included. PERSNR, ERHEBJ and YPERG are always included.

{phang}
{opt s:oepdir} is mandatory. It tells {cmd:soepdo} the path to the directory
 where SOEP files are stored.

{phang}
{opt y:perg} is manadatory. Here one specifies the reasons for drop-outs in 
 terms of YPERG (see Frick and Haisken-DeNew, 2005). If no integer is given,
 no observations will be in your dataset.

{phang}
{opt e:rhebj} is optional. Some drop-outs can occur multiple times per person,
 e.g. moving abroad. By default, {cmd:soepdo} will keep all observations but
 one may specify {opt e(last)} or {opt e(first)} to keep only the first or the
 last drop-out in terms of ERHEBJ.



{title:Author}

{pstd}Please send your suggestions and comments to:

{phang2}Tim Stegmann{p_end}
{phang2}Institute for Work, Skills and Training(IAQ){p_end}
{phang2}University of Duisburg-Essen{p_end}
{phang2}45117 Essen{p_end}
{phang2}Germany{p_end}

{phang2}E-Mail: tim.stegmann{c 64}uni-due.de{p_end}



{title:History}

{pstd}Version 1.1.1

{phang2}- {opt varlist} is now {opt namelist}{p_end}
{phang2}- fixed some typos in help file{p_end}


{title:Disclaimer}

{pstd}
This software comes "as is" without warrenty. Use at your own risk.



{title:References}

{phang}Haisken-DeNew, J. P. {c 38} Frick, J. R. (ed.)(2005): DTC. Desktop Companion to the German Socio-Economic Panel Study (SOEP). Version 8. Berlin: Deutsches Institut für Wirtschaftsforschung

{phang}SOEP Group (2001): The German Socio-Economic Panel (GSOEP) after more than 15 years {hline 2} Overview. {it:Vierteljahreshefte zur Wirtschaftsforschung}, 70(1), 7-14

