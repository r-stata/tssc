{smcl}
{* *! version July 26, 2018 @ 22:58:09}{...}
{* a divider if needed}{...}
{vieweralsosee "[user] go" "help go" "--"}{...}
{* link to other help files which could be of use}{...}
{viewerjumpto "Syntax" "pushd##syntax"}{...}
{viewerjumpto "Description" "pushd##description"}{...}
{viewerjumpto "Options" "pushd##options"}{...}
{viewerjumpto "Remarks" "pushd##remarks"}{...}
{viewerjumpto "Example" "pushd##examples"}{...}
{viewerjumpto "Author" "pushd##author"}{...}
{...}
{title:Title}

{phang}
{cmd:pushd} and {cmd:popd} {hline 2} Change directory, push current directory on stack, come back
{p_end}

{marker syntax}{...}
{title:Syntax}

{* put the syntax in what follows. Don't forget to use [ ] around optional items}{...}
{p 4 8 2} Change directory, keeping track of where you are now
{p_end}
{p 8 16 2}
   {cmd: pushd}
   {it: dir}
{p_end}
{p 4 8 2} Go back to where you were
{p_end}
{p 8 16 2}
   {cmd: popd}
   [{cmd:,}
   {it:keep}
   ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{* no options}{...}
{marker description}{...}
{title:Description}

{pstd}
{cmd:pushd} is a generalization of {help cd}. Just like {cmd:cd}, it changes
the working directory, but unlike {cmd:cd}, it saves the current directory.
You can then come back to the pushed directory by typing {cmd:popd}.
{p_end}

{pstd}
{cmd:popd} returns to the last directory left via {cmd:pushd}.
{p_end}

{marker options}{...}
{title:Options}

{phang}{opt keep} tells {cmd:popd} to keep the directory being popped to on the stack. This is really only for debugging, so it isn't of much use.
{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
Sometimes it is worth jumping to a another directory to do a specific task, or to experiment without cluttering the current working directory.
When you want to do this, change to the other directory with {cmd:pushd} and come back with {cmd:popd}.
{p_end}

{marker examples}{...}
{title:Example}{* Be sure to change Example(s) to either Example or Examples}

{pstd}
Suppose you are currently working in the directory {bf:/Volumes/Secrets/Development/wickedgood}, and want to jump over to {bf:/Users/yourname/Scratch} to try an experiment. You can do this by
{p_end}

{pin}{cmd:. pushd "/Users/yourname/Scratch"}{break}
{cmd:. }{it:some experiments...}
{p_end}

{pstd}When finished with the experiments, you could then type{p_end}

{pin}{cmd:. popd}{p_end}

{pstd}
and you would pop back to {bf:/Volumes/Secrets/Development/wickedgood}.
The good news is that you don't have to remember where you were or type out
the long directory name.
{p_end}

{marker author}{...}
{title:Author}

{pstd}
Bill Rising, StataCorp{break}
email: brising@stata.com{break}
web: {browse "http://louabill.org":http://louabill.org}
{p_end}

