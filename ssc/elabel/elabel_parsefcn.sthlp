{smcl}
{cmd:help elabel parsefcn}
{hline}

{p 2 4 2}
{cmd:elabel parsefcn} is no longer used; see 
{helpb elabel_fcncall:elabel fcncall} for the 
recommended way to parse calls to 
{cmd:elabel_fcn_{it:fcn}}

{hline}


{pstd}
The syntax for {cmd:elabel parsefcn} is

{p 8 12 2}
{cmd:elabel parsefcn} 
[ {it:lmacname1} ] {it:lmacname2} {it:lmacname3}
{cmd::} {it:elabel_fcn_call}

{pstd}
and it is equivalent to

{p 8 12 2}
{cmd:elabel fcncall} 
{cmd:*} [ {it:lmacname1} ] {it:lmacname2} {it:lmacname3}
{cmd::} {it:elabel_fcn_call}


{title:Author}

{pstd}
Daniel Klein{break}
University of Kassel{break}
klein.daniel.81@gmail.com


{title:Also see}

{psee}
Online: {helpb gettoken}{p_end}

{psee}
if installed: {help elabel}
{p_end}
