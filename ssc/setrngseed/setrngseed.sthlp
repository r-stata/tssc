{smcl}
{* Help file for -setrngseed-, version 2, Oct, 1, 2010}{...}
{hline}
help for {hi:setrngseed}                                
{hline}

{title:Set random-number seed using random integer from random.org}

{p 8 17 2}
{cmd:setrngseed}
[{cmd:,} {it:options}]


{col 9}{it:options}{col 30}description
{col 8}{hline 60}
{col 9}{it:none}{col 30}set seed

{col 9}{cmdab:v:erify}{col 30}set seed, but first verify random.org working

{col 9}{cmdab:q:uery}{col 30}do not set seed; report random.org quota
{col 9}{cmdab:noset:seed}{col 30}do not set seed, report it instead
{col 8}{hline 60}


{title:Description}

{p 4 4 2}
Typing {cmd:setrngseed} without arguments is an alternative to using Stata's
{help set seed} command.  {cmd:setrngseed} obtains truely random integers from
{browse "www.random.org"} and uses those results to set the seed of Stata's
pseudo-random-number generator.

{p 4 4 2}
www.random.org will currently deliver roughly 32,000 seeds per 24-hour period.
You can visit www.random.org and purchase additional random numbers should you
need them, which is unlikely, or to make a donation in support of their
efforts.

{p 4 4 2}
{cmd:setrngseed} is usually used without any options being specified.


{title:Options}

{p 4 8 2}
{cmd:verify} 
    specifies that before setting the seed, {cmd:setrngseed} verify 
    that www.random.org is working as 
    {cmd:setrngseed} expects.  This involves obtaining two rather 
    than one random number and so consumes your 24-hour quota more 
    quickly.

{p 8 8 2}
    www.random.org is a separate organization from www.stata.com, 
    and thus they could change the way their site operates.  When option 
    {cmd:verify} is specified, {cmd:setrngseed} requests two random 
    numbers and verifies that they are different from each other.

{p 4 8 2}
{cmd:query}
    does not set the random-number seed.  It instead reports the number of
    seeds www.random.org would supply remaining in your 24-hour quota.

{p 4 8 2}
{cmd:nosetseed}
    does not set the random-number seed.  It instead reports the seed that
    would have been set.  {cmd:nosetseed} is used in debugging 
    {cmd:setrngseed}.


{title:Remarks}

{p 4 4 2}
{cmd:setrngseed} sets the 
Stata's random-number {help set seed:seed}
randomly based on measurements of atmospheric
noise obtained from the website {browse "www.random.org"}.

{p 4 4 2}
As of September 30, 2010, {browse "www.random.org"} has a quota system in
which each IP address starts off with a quota of 1,000,000 random bits
which is topped off with up to 200,000 bits each 24-hour period.
{cmd:setrngseed} uses 31 bits each time it sets Stata's random-number seed, so
your quota starts off with approximately 32,258 seeds and is topped off with
up to 6,451 seeds per day.  Additional random bits can be purchased through
the {browse "http://www.random.org":website}.


{p 4 4 2} 
{cmd:setrngseed} will very likely break if {browse www.random.org} changes the
protocol for obtaining random numbers.  If {cmd:setrngseed} fails repeatedly,
please send the the authors email, but only after checking your current
random-bit allowance with {cmd:setrngseed, query}.


{title:Methods and formulas}

{p 4 4 2}
A random integer between -1,000,000,000 and +1,000,000,000 is obtained from
random.org, 1,000,000,000 is added to it, and that number is used to set the
random-number seed.


{title:Saved results}

{pstd}
{cmd:setrngseed} saves the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(seed)}}value returned by the web service (only if {cmd:query} has not been specified){p_end}
{synopt:{cmd:r(quota)}}your current IP's quota (only if {cmd:query} has been specified){p_end}
{p2colreset}{...}


{title:Authors}

{p 4 4 2}
Antoine Terracol, Université Paris 1 {break}terracol@univ-paris1.fr

{p 4 4 2}
William Gould, StataCorp{break}wgould@stata.com



{title:Also see}

{p 4 4 2}
Manual: {hi:[R] set seed}, {hi:[D] generate}
{p_end}

{p 4 4 2}
Online: help for {help set seed}, {help random numbers}
{p_end}
