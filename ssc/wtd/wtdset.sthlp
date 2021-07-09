{smcl}
{* 21feb2005}{...}
{hline}
help for {hi:wtdset}
{hline}

{title:Declare data to be Waiting Time Distribution data}

{p 8 16 2}{cmd:wtdset} {it:eventvar} {it:exitvar}
	[{cmd:if} {it:exp}] [{it:weight}]{cmd:,}
	{cmd:start(}{it:date}{cmd:)}
	{cmd:end(}{it:date}{cmd:)}
	[{cmd:id(}{it:varname}{cmd:)}
	{cmd:robust}
	{cmd:cluster(}{it:varname}{cmd:)}
	{cmd:scale(}{it:#}{cmd:)}]

{p 8 16 2}{cmd:wtd}

{p 4 4 2}
{cmd:fweight}s are allowed; see help {help weights}.


{title:Description}

{p 4 4 2} {cmd:wtdset} declares data to be Waiting Time Distribution
(wtd) data; see help {help wtd}.

{p 4 4 2}
{cmd:wtd} displays how the data are currently declared.

{p 4 4 2} {red:{bf:Caution:}} {cmd:wtdset} is destructive in the sense that
it prunes and collapses data so that subsequent wtd commands can
exploit frequency weighting. This improves estimation speed
dramatically, but it is the users responsibility (exclusively!) to
ensure preservation of original data, see help {help save}.

{title:Options for {cmd:wtdset}}

{p 4 8 2}
{cmd:start(}{it:date}{cmd:)} specifies the starting date with
syntax acceptable by the {cmd:d() function}, see help {help dfcn}. If
your earliest possible observation is 1 january 1997 then the
starting date should be set to 31 december 199{bf:6}. In other words
the starting date is time zero, with observation of dates only
possible for date 1, 2,...

{p 4 8 2}
{cmd:end(}{it:date}{cmd:)} specifies the date of the last possible
observation time.

{p 4 8 2} 
{cmd:id(}{it:varname}{cmd:)} specifies the subject-id variable. For
each subject only the first observation in the observation period is
kept. If {cmd:id} is not specified it is assumed that each observation
corresponds to a single individual.

{p 4 8 2}{cmd:robust} specifies that the Huber/White/sandwich
estimator of variance is to be used as default in place of the
traditional calculation in subsequent estimations with {cmd:wtdml}.
Although set it may be overruled in the {cmd:wtdml} statement using
option {cmd:norobust}, and if not set, it can be added in the
{cmd:wtdml} statement. {cmd:robust} combined with {cmd:cluster()}
further allows observations which are not independent within cluster
(although they must be independent between clusters). See 
{hi:[U] 23.14 Obtaining robust variance estimates} and help 
{help robust}.

{p 4 8 2} {cmd:cluster(}{it:varname}{cmd:)} specifies that data are
clustered, ie. the observations are independent across groups
(clusters) but not necessarily independent within groups. {it:varname}
specifies to which group each observation belongs. Specifying
{cmd:cluster()} implies default {cmd:robust} variance estimation.

{p 4 8 2} 
{cmd:scale(}{it:#}{cmd:)} defines the scale of analysis time. This can
be handy for making units of rate estimates more readable (such as
converting person-days to person-years).

{title:Examples}

{p 4 8 2}{cmd:. wtdset event exit, start(31dec1996) end(31dec1997) id(id)}

{p 4 8 2}
{cmd:. wtdset event exit, start(31dec1996) end(31dec1997) id(id) scale(365)}

{p 4 8 2}
{cmd:. wtd}

{title:Also see}

    Manual:  {hi:[ST] stset}

{p 4 13 2}Online:  help for {help wtd}, {help dfcn}
