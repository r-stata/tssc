{smcl}
{* *! version 1.1.1 4oct2020}{...}
{cmd:help heart}
{hline}

{title:Title}

    {hi:heart} {c -} displays row of hearts, graphs about love and randomly generated pick-up line to relieve coding stress and make coding fun and accessible!  

{title:Syntax}

{p 2 4}{cmd:heart} , [{it:options}]

{synoptset 20 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{it:    Display Options}

{synopt:{opt li:ne}}displays a row of hearts{p_end}
{synopt:{opt sca:tter}}displays a scatter plot of hearts{p_end}
{synopt:{opt pi:e}}displays a pie chart answering a very important question{p_end}
{synopt:{opt fli:rt}}randomly generates pick up lines! {p_end}
{synoptline}
{p2colreset}{...}

{title:Description}

{pstd}
{cmd:heart} simply displays a row of hearts for those who invoke it {p_end}

{marker overview}
{title:Overview}
{text}{p 2}The {cmdab: heart} package aims to celebrate love in all its types and forms and spread joy while coding! Fill in your Stata breaks, send yourself some hearts for smooth code, find out how cute you are through a pie 
chart, let hearts scatter on your screen, show your admiration for your collaborators by sneaking it in code for others to run or let Stata dazzle you with 
its wit and try to win you over with its pick up lines to once and for all settle the Stata vs R debate. 

{marker example}
{title:Examples}

{phang}{text} 1. Generate a row of hearts.{p_end}

{phang}{inp} {stata heart}

{phang}{text} 2. Generate a scatter plot of hearts.{p_end}

{phang}{inp} {stata heart, scatter}

{phang}{text} 3. Generate a pie chart to answer a pressing question.{p_end}

{phang} {inp} {stata heart, pie}

{phang}{text} 4. Randomly generate a pick-up line.{p_end}

{phang}{inp} {stata heart, flirt}

{break}

{hline}

{marker acknowledgements}
{title:Acknowledgements}

{text}{p 2}The author would like to acknowledge the guidance and support of Anurati Srivastva and Akanksha Saletore in developing this command.{p_end}
{text}{p 2}All randomly generated pick up lines have been compiled from various sources. {p_end}

{title:Author}

{phang}
Prashansa Srivastava{p_end}
{phang}
prashansa.srivastava98@gmail.com
{p_end}
