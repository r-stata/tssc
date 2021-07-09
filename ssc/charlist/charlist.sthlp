{smcl}
{* 17 December 2002/28 April 2005/28 February 2014}{...}
{hline}
help for {hi:charlist}
{hline}

{title:List characters present in string variable}

{p 8 17 2}
{cmd:charlist} 
{it:strvar} 
[{cmd:if} {it:exp}] 
[{cmd:in} {it:range}] 


{title:Description}

{p 4 4 2}{cmd:charlist} displays a sorted list of the distinct
characters present in values of string variable {it:strvar}. 


{title:Remarks}

{p 4 4 2}{cmd:charlist} may, for example, reveal the presence of
problematic characters in a string variable which "should be" numeric.
It leaves behind a terse character list in {cmd:r(chars)};  a
space-separated character list in {cmd:r(sepchars)}; and a
space-separated numlist of ASCII codes in {cmd:r(ascii)}.  Any may be
used in a subsequent command. Sometimes copying and pasting all or part
of the displayed output to the command window may be the most practical
way to use the output, say as argument to {cmd:destring, ignore()}.  

{p 4 4 2}Note in particular that many awkward characters may not 
print comprehensibly or visibly in your Results window. To 
some extent, this will depend on the font you choose. A particular 
pitfall is that char(32) and char(160) appear identical and may be 
overlooked in any case. The returned results showing ASCII codes are 
needed to solve many of these difficulties.  


{title:Examples}

{p 4 8 2}{cmd:. charlist make}

{p 4 8 2}{cmd:. charlist make if foreign}

{p 4 8 2}{cmd:. charlist rank}{p_end}
{p 4 8 2}{cmd:. return list}{p_end}
{p 4 8 2}[suppose results show instances of char(160)]{p_end}
{p 4 8 2}{cmd:. destring rank, ignore(`=char(160)')} 

   
{title:Saved results} 

{p 4 28}{cmd:r(chars)}{space 12}compressed list of distinct characters{p_end}
{p 4 28}{cmd:r(sepchars)}{space 9}space-separated list of distinct characters{p_end}
{p 4 28}{cmd:r(ascii)}{space 12}numeric list of distinct ASCII codes (cf. {cmd:char()})


{title:Acknowledgements} 

{p 4 4 2}Daniel Egan posed a problem that led to extra comments and 
examples in this help file. Martyn Sherriff posed an example that led to 
rewriting the program to cope better with occurrences of char(96). 


{title:Author} 

{p 4 4 2}Nicholas J. Cox, Durham University, U.K.{break} 
n.j.cox@durham.ac.uk

	 
{title:Also see}

{p 4 13 2}On-line:  help for {help destring}, {help functions}{p_end}

