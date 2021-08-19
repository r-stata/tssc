{smcl}
{* *! version 1.1.1 19oct2020}{...}
{cmd:help ghazal_guzzler}
{hline}

{title:Title}

    {hi:ghazal_guzzler} {c -} module for ghazal guzzling Stata users!

{title:Syntax}

{p 2 4}{cmd:heart} , [{it:options}]

{synoptset 20 tabbed}{...}
{marker Options}{...}
{synopthdr:Options}
{synoptline}
{it:    Display Options}
{synopt:{opt  br:owse}}Open the link directly in your web browser.{p_end}
{synopt:{opth num:ber(#)}}Choose number of songs to be selected, by default only 1 song is selected.{p_end}
{synopt:{opt  play:list}}Display full playlist instead of song(s).{p_end}
{synopt:{opt  platform(string)}}Specify music platform ({it:YouTube} or {it:Spotify}); default is {it:Youtube}.{p_end}
{break}
{synoptline}
{p2colreset}{...}


{marker overview}
{title:Overview}
{text}{p 2}The {cmdab: ghazal_guzzler} package is great to find comfort in the melancholic tunes, get lost in the beauty of Farida 
Khanum's voice or to experience a sadness deeper than trying to figure out a particularly difficult reshape in Begum Akhtar's voice. 
A glass of wine, dim lights and a wintry evening are said to be the perfect environment for you to enjoy a ghazal, but the light from 
your laptop screen will suffice, so take a step back and let the command generate some ghazal tunes for you to enjoy!

{marker example}
{title:Examples}
{phang}{text} 1. Generate a clickable link to a ghazal.{p_end}

{phang}{inp} {stata ghazal_guzzler}

{phang}{text} 2. Open the link created on your web browser, instead of displaying it on the result window.{p_end}

{phang}{inp} {stata ghazal_guzzler, browse}

{phang}{text} 3. Generate 4 clickable links with different songs.{p_end}

{phang} {inp} {stata ghazal_guzzler, number(4)}

{phang}{text} 4. Open the Youtube playlist link (instead of picking a song).{p_end}

{phang}{inp} {stata ghazal_guzzler, browse playlist}

{phang}{text} 5. Generate a clickable link to a ghazal for Spotify.{p_end}

{phang}{inp} {stata ghazal_guzzler, platform(Spotify)}

{phang}{text} 6. Browse the ghazal playlist on Spotify.{p_end}

{phang}{inp} {stata ghazal_guzzler, browse playlist platform(Spotify)}

{break}

{hline}

{marker acknowledgements}
{title:Acknowledgements}

{text}{p 2}The author would like to acknowledge Matteo Ruzzante for inspiring this command.{p_end}

{title:Author}

{phang}
Prashansa Srivastava{p_end}
{phang}
prashansa.srivastava98@gmail.com
{p_end}