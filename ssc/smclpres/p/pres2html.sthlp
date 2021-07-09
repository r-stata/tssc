{smcl}
{* *! version 3.1.0 12Sept2018 MLB}{...}
{title:Title}

{phang}
{cmd:pres2html} {hline 2} Turn a .smcl presentation created by {cmd:smclpres} 
into a .html handout

{title:Syntax}

{p 8 17 2}
{cmd:pres2html}
{cmd:using} {it:{help filename}} [{cmd:,}
{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}files created by {cmd:pres2html} will replace files with the
        same name if they already exist{p_end}
{synopt:{opt dir(directory_name)}}specifies the directory in which the handout
        is to be stored. The default is the current working directory.{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:pres2html} turns a .smcl presentation created by {help smclpres} into a 
handout in html format.

{pstd}
{it:filename} is the name of the first .smcl file of the presentation. 


{title:Options}

{phang}
{cmd:replace} allows {cmd:pres2html} to replace files when they already exist.


{title:Example}

{pstd}
In the example from {help smclpres} there was a file minimalist.do, that was
turned into a .smcl presentation. The first slide will then be called 
minimalist.smcl, so that presentation can be turned into a .html handout by 
typing:

{cmd}
        pres2html using minimalist.smcl, replace

	
{title:Author}

{pstd}Maarten Buis, University of Konstanz{break} 
      maarten.buis@uni.kn
	