{smcl}
{* *! version 1 21aug2019}{...}
{viewerdialog osort "dialog osort"}{...}
{vieweralsosee "[D] osort" "mansection D osort"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[D] describe" "help describe"}{...}
{vieweralsosee "[D] gsort" "help gsort"}{...}
{p2colset 1 13 15 2}{...}
{p2col:{bf:[D] osort}}-- A single command to reorder variable(s) and sort data{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{opt osort}
{varlist}


{marker description}{...}
{title:Description}

{pstd}
{opt osort} combines the {manhelp order P} and {manhelp sort P} commands into a single command. The data are ordered and then sorted based on {varlist}. {opt osort} only accepts a {varlist}.

{marker author}{...}
{title:Author}

{pstd}
Joshua Sussman, University of California, Berkeley,
jsussman@berkeley.edu


