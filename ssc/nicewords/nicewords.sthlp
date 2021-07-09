{smcl}
{* *! version 1.3.1 23oct2013}{...}
{cmd:help nicewords}
{hline}

{title:Title}

    {hi:nicewords} {c -} displays a compliment when used.  

{title:Syntax}

{p 8 17 2}
{cmd:nicewords}
[{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help nicewords##options:Options}}
{synopt:{opt not}}display insults instead of compliments{p_end}
{synopt:{opt f:oreign}}switch from "English" to "World"{p_end}
{synopt:{opt smile:y}}put phrase in speech bubble said by a smiley face{p_end}
{synopt:{opt evil}}intensifies negative smileys{p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:nicewords} simply pays a compliment to the user who invokes it. {p_end}

{marker options}
{title:Options}
{dlgtab:Options}
{marker not}
{phang}
{opt not} causes {cmd:nicewords} to act like {cmd:meanwords}; i.e. instead of paying a compliment, it gives an insult.{p_end}
{marker foreign}{...}

{phang}
{opt foreign} changes the list of compliments to choose from from "English" to "World" {p_end}
{marker smiley}{...}

{phang}
{opt smiley} presents the phrase said by a smiley face. The smiley face's mood changes with the type of phrase uttered. {p_end}
{marker evil}{...}

{phang}
{opt evil} causes smileys to become more negative only if they are in {cmd:not} mode. {p_end}

{title:Saved Results}

{phang}
{cmd:nicewords} saves the following in {cmd:r()} :{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Strings}{p_end}
{synopt:{cmd:r(phrase)}}the phrase displayed {p_end}
{p2colreset}{...}

{title:Author}

{phang}
Joe Long, Northwestern University{p_end}
{phang}
jlong@u.northwestern.edu
{p_end}

