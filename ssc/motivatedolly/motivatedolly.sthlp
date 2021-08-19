{smcl}
{* *! version 1.2.2  15may2018}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "examplehelpfile##syntax"}{...}
{viewerjumpto "Description" "examplehelpfile##description"}{...}
{viewerjumpto "Options" "examplehelpfile##options"}{...}
{viewerjumpto "Remarks" "examplehelpfile##remarks"}{...}
{viewerjumpto "Examples" "examplehelpfile##examples"}{...}
{viewerjumpto "Acknowledgements" "examplehelpfile##acknowledgements"}{...}
{viewerjumpto "Author" "examplehelpfile##author"}{...}
{title:Title}

{phang}
{bf:motivatedolly} {hline 2} Generates motivational quotes, song lyrics and other resources from the queen of country, Dolly Parton


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{motivatedolly}
[{cmd:,} {it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt debug}}displays quotes relevant to debugging frustrations{p_end}
{synopt:{opt pers:evere}}quotes to help you KEEP GOING{p_end}
{synopt:{opt regroup}}for when you need to regroup, reorganize or redo your entire do-file{p_end}
{synopt:{opt angry}}self explanatory{p_end}
{synopt:{opt girlp:ower}}also self explanatory{p_end}
{synopt:{opt gohome}}the push you need to close your dang computer and try again tomorrow{p_end}
{synopt:{opt adv:anced}}for truly desperate times{p_end}

{synoptline}
{p2colreset}{...}



{marker description}{...}
{title:Description}

{pstd}
{cmd:motivatedolly} pulls from Dolly's enormous discography spanning over half a decade, plus her famous one-liners, to help us make it through tough times. Song lyrics include a link to youtube where you can listen to the song for some musical 
inspiration. The advanced option includes links to Bedtime with Dolly, a quarantine-era video series of Dolly reading inspirational selections from her Imagination Library. Imagination Library is a charity started by Dolly Parton which sends free, 
age-appropriate books to children each month so that "all children [can] grow up in a home full of books." Here's a {browse  "https://imaginationlibrary.com/news-resources/research/":link} to all the research evaluating the impact of her charity.


{marker remarks}{...}
{title:Remarks}

{pstd}
Some quotes do not have citations because the original context of the quote is difficult to find. If any quotes are incorrectly attributed, please contact the author of this package. Please also contact me if you'd like to see any additions! 


{marker examples}{...}
{title:Examples}

{phang}{cmd:. motivatedolly}{p_end}

{ralign 80:{c 39}I'm a little bit slow to catch on, but when I do I'm caught on.{c 39}}
   
{ralign 80:{browse  www.youtube.com/watch?v=6dPEOrsryoQ":Dolly Parton, 1968}}

{phang}{cmd:. motivatedolly, persevere}{p_end}

{ralign 80:{c 39}You'll never do a whole lot unless you're brave enough to try.{c 39}}
{ralign 80:Dolly Parton}


{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}
{cmd:motivatedolly} was built upon the ideas and code of several good-humored members of the Stata community, including

{phang}{browse "https://econpapers.repec.org/software/bocbocode/s458565.htm":motivate}, from Kabira Namit, who to the best of my knowledge spearheaded the field of fun stata packages.
 
{phang}{browse "https://ideas.repec.org/c/boc/bocode/s458576.html":demotivate}, by Kevin Denny, who provided "a much needed antithesis to Kabira Namit’s motivate package".{p_end}


{marker author}{...}
{title:Author}
I. Bailey Palmer, 1bailey1@gmail.com
