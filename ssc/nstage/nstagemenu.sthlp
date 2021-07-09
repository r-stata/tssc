{smcl}
{* *! version 1.0.0 29sep2014}{...}
{cmd:help nstagemenu}{right: ({browse "http://www.stata-journal.com/article.html?article=st0175_1":SJ15-2: st0175_1})}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{hi:nstagemenu} {hline 2}}Activates dialog for multiarm, multistage trial designs{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 18 2}
{cmd:nstagemenu on} | {cmd:off}


{title:Description}

{pstd}
{cmd:nstagemenubeta on} turns on the {cmd:n-stage trial} menu.  A new item,
{cmd:n-stage trial}, appears in the User menu on the main menu bar.  To
access the facility, click on {cmd:User} > {cmd:n-stage trial} >
{cmd:Multi-Stage Trial Designs}.

{pstd}
{cmd:nstagemenubeta off} removes {cmd:n-stage trial} from the User menu.


{title:Authors}

{pstd}
Patrick Royston{break}
MRC Clinical Trials Unit{break}
University College London{break}
London, UK{break}
j.royston@ucl.ac.uk

{pstd}
Friederike Maria-Sophie (Sophie) Barthel{break}
Independent consultant


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 2: {browse "http://www.stata-journal.com/article.html?article=st0175_1":st0175_1},{break}
                    {it:Stata Journal}, volume 9, number 4: {browse "http://www.stata-journal.com/article.html?article=st0175":st0175}

{p 7 14 2}Help:  {helpb nstage}, {helpb nstagedlg} (if installed){p_end}
