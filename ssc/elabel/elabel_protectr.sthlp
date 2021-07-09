{smcl}
{cmd:help elabel protectr}
{hline}

{title:Title}

{p 4 8 2}
{cmd:elabel protectr} {hline 2} Protect {cmd:r()} results


{title:Syntax}

{p 8 12 2}
{cmd:elabel protectr}
[ {cmd:, not} ]


{title:Description}

{pstd}
{cmd:elabel protectr} is used in 
{help elabel_programming##addcmd:{bf:elabel} subcommands} to preserve 
contents in {cmd:r()}. {cmd:elabel protectr} copies the current contents 
from {cmd:r()} and restores it when the respective command, 
{cmd:elabel_cmd_{it:newcmd}}, concludes.

{pstd}
Note that {cmd:elabel_cmd_{it:newcmd}} must be called as

{phang2}
{cmd:. elabel {it:newcmd ...}}
{p_end}

{pstd}
for {cmd:elabel protectr} to work correctly.


{title:Remarks}

{pstd}
Say, you want to 
{help elabel_programming##addcmd:add a command to {bf:elabel}} and you do 
not want your command to store anything in {cmd:r()}. Your command, however, 
needs to call other commands that do store contents in {cmd:r()}. Once your 
command concludes, the contents in {cmd:r()} will be changed to whatever 
other commands have stored there. Specifying {cmd:elabel protectr} at the 
beginning of your command assures that, regardless of other commands you are 
calling, the contents in {cmd:r()} remain unchanged after your command has 
concluded. 

{pstd}
Typical usage is

{col 10}{hline 4} begin elabel_cmd_{it:newcmd}.ado {hline}
{p 10 12 2}
{cmd:program elabel_cmd_{it:newcmd}}
{p_end}
{p 14 16 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 14 16 2}
{cmd:elabel protectr}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:end}
{p_end}
{col 10}{hline 4} end elabel_cmd_{it:newcmd}.ado {hline}

{pstd}
{cmd:elabel protectr} may be called within sub-programs; however, 
the contents in {cmd:r()} will not be restored until the main program 
concludes. In {cmd:elabel_cmd_{it:newcmd}.ado}, you may code

{col 10}{hline 4} begin elabel_cmd_{it:newcmd}.ado {hline}
{p 10 12 2}
{cmd:program elabel_cmd_{it:newcmd}}
{p_end}
{p 14 16 2}
{cmd:version {ccl stata_version}}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 14 16 2}
{cmd:{it:newcmd}_{it:subcmd ...}}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:end}

{p 10 12 2}
{cmd:program {it:newcmd}_{it:subcmd}}
{p_end}
{p 14 16 2}
{cmd:elabel protectr}
{p_end}
{p 14 16 2}
{it:...}
{p_end}
{p 10 12 2}
{cmd:end}
{p_end}
{col 10}{hline 4} end elabel_cmd_{it:newcmd}.ado {hline}

{pstd}
Here, {cmd:elabel protectr} preserves the contents in {cmd:r()} 
at the time {cmd:{it:newcmd}_{it:subcmd}} is called. However, it 
is not before {cmd:elabel_cmd_{it:newcmd}} concludes that the 
contents in {cmd:r()} will be restored.


{title:Options}

{phang}
{opt not} specifies that previously copied contents from {cmd:r()} 
not be restored at the command's conclusion.


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb _return}{p_end}

{psee}
if installed: {help elabel}
{p_end}
