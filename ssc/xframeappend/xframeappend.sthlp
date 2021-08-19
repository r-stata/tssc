{smcl}
{hline}
help for {cmd:xframeappend} {right:(Roger Newson)}
{hline}


{title:Append {help frame:data frames} to the end of the current {help frame:data frame}}

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:xframeappend}
{it:framelist}
[ {cmd:,} {cmd:drop} {opth g:enerate(newvarname)} {cmd:fast} ]

{synoptset 24 tabbed}{...}
{synopthdr}

{synoptline}
{synopt:{opt drop}} drops the frames listed in {it:framelist} after they have been appended{p_end}

{synoptline}
{synopt:{opth g:enerate(newvarname)}} specifies the name of a new variable to be created,
to mark the source of observations.
It will have values {cmd:0} for observations in the master dataframe (the current frame),
and the value {it:k} for observations from the {it:k}th frame in the {it:framelist}.

{synoptline}
{synopt:{opt fast}} specifies that no extra work will be done to restore the original current dataset,
if the program fails, or if the user presses {helpb break:Break}.
{p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:xframeappend} appends the contents of one or more {help frame:frames} in the input {it:framelist}
to the current {help frame:data frame}.
The new observations will be at the bottom of the current frame.
And any variables in the appended frames in the {it:framelist} but not in the current frame
will be ordered in order of appearance in the {it:framelist}.
The command works for variables whose names begin with an underscore.


{title:Remarks and Acknowledgements}

{pstd}
{cmd:xframeappend} is Roger Newson's idea of what a future {cmd:frame append} command shuld be like.
It is based on the existing {help ssc:SSC} package {helpb frameappend},
written by Jeremy Freese and revised with help from Daniel Fernandez,
and adds a few improvements (in Roger Newson's opinion and not necessarily anybody else's).
For more about data frames in Stata Version 16 (and above),
see online help for {help frame:data frames}.


{marker authors}{...}
{title:Author}

{pstd}
Roger Newson, Imperial College London, United Kingdom.
Email: {browse "mailto:r.newson@imperial.ac.uk":r.newson@imperial.ac.uk}
