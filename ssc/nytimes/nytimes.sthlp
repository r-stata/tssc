{smcl}
{* *! version 1.1.0  01jan2010}{...}
{cmd:help nytimes}
{hline}

{title:Title}

{phang}
{bf:nytimes} {hline 2} Top news stories from the New York Times


{title:Syntax}

{p 8 17 2}
{cmdab:nytimes}
[{cmd:,}
 {opt f:eed(feedname)}
 {opt n:umber(#)}]

{title:Description}

{pstd}
{cmd:nytimes} displays items from  New York Times RSS feeds. It requires a connection to the internet.




{title:Options}

{p 4 8 2}
{opt feed(feedname)} allows the user to specify which New York Times feed will be displayed. The default is the NYTimes.com Home Page (U.S.).
As of January 2011, other feed possiblities included: global home; 
news sites focusing on the world, Africa, the Americas, Asia Pacific, Europe, Middle East; 
US news feeds focusing on the US, education, politics, NY region, and energy environment; 
business news feeds focusing on global business, small business, economy, media and advertising, and your money; 
technology news feeds focusing on business-computing, internet, personal tech, and start-ups;
sports news feeds focusing on sports, global sports, baseball, college basketball, college football, golf, hockey, pro basketball, pro football, soccer, and tennis;
science news feeds focusing on science, environment, space, health research, nutrition, health care policy; and many more.
 A complete list is {browse "http://www.nytimes.com/services/xml/rss/index.html":available}.
 
{p 4 8 2}
{opt number(#)} allows the user to specify how many feeds will displayed. The default is 5.

{title:Remarks}
{pstd} This command is a very crude RSS reader for feeds produced by the New York Times. It reports the headline, which is a hyperlink
to the full text of the newspaper article, a brief article summary, and the date and time the article was published. Clicking on a headline will open up the article in your default web browser.

{pstd} If you want a number of feed items different than five, you may include the number as option. For example {cmd:nytimes, n(10)} will return the ten more recent items.
Normally, the Times feed only reports about a dozen items which creates an upper limit for the number of story summaries that will be displayed.

{pstd} {cmd:nytimes} doesn't work well for NYTimes.com blogs, as it is not set up to parse the ones that are routed through Feedburner. Some blog feeds will work, some will not.

{pstd} {cmd:nytimes} has no knowledge of whether or not you have seen a particular item before, so it will repeat items if you make multiple calls to it over a short period of time. 

{title:Examples}

{p 8 12}{stata "nytimes" :. nytimes} {p_end}

{p 8 12}{stata "nytimes, feed(arts)" :. nytimes, feed(arts)} {p_end}

{p 8 12}{stata "nytimes, n(1)" :. nytimes, n(1) } {p_end}

{p 8 12}{stata "nytimes, f(sports) n(3)" :. nytimes, f(sports) n(3) } {p_end}


{title:Author}

{p 0 4} Neal Caren (neal.caren@unc.edu) University of North Carolina, Chapel Hill
