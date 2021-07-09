{smcl}
{* 1 November 2002/22 November 2013}{...}
{hline}
help for {hi:labvalclone}
{hline}

{title:Clone a set of value labels under another name}

{p 4 10 2}
{cmd:labvalclone} 
{it:vallblname}
{it:newvallblname}


{title:Description}

{p 4 4 2}{cmd:labvalclone} clones the value labels with name {it:vallblname} 
as a new set of value labels with name {it:newvallblname}. 
This might be useful if you want to use almost the same 
labels as an existing set, so that you first want a copy of 
the labels, which you can then modify. 

{p 4 4 2}This command uses {cmd:file}, introduced 
into Stata 7 on 8 May 2001, so your Stata must have 
been updated after that for this to work. 


{title:Examples}

{p 12 12 2}{inp:. labvalclone oldlabel newlabel}{break} 
{inp:. label def newlabel 5 "5 or more", modify}


{title:Author} 

         Nicholas J. Cox, University of Durham, U.K.
         n.j.cox@durham.ac.uk


{title:Acknowledgements}  

         Roger Harbord suggested this problem. Sergiy Radyakin found a bug. 


{title:Also see}

 Manual:  {hi:[U] 15.6.3 Value labels}, {hi:[R] label}  
{p 0 19}On-line:  help for {help label}{p_end}

