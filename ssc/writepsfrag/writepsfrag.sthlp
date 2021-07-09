{smcl}{* 7 August 2012}{...}{hline}help for {hi:writepsfrag}{right:Ryan E. Kessler (October 2012)}{hline}{title: Automates the use of LaTeX's PSfrag package}{p 8 17 2}{cmd: writepsfrag}{it:filename.eps }{cmd:using }{it:filename.tex}{cmd:, }[{cmd:replace append }{cmd:textsize(}{it:string}{cmd:) scale(}{it:#}{cmd:) body(}{it:string} [,{it:subopts}]{cmd:)} {cmd: substitute(}{it:stringlist}{cmd:)}]{title:Description}{p 4 4 2}
{cmd:writepsfrag} writes to a LaTeX file the {browse "ftp://ctan.tug.org/tex-archive/macros/latex/contrib/psfrag/pfgguide.pdf":PSfrag} commands necessary to
replace all occurences of text in a Stata Encapsulated PostScript (EPS) file with 
properly-formatted LaTeX text. 
{title:Options}{p 4 4 2}{cmd:replace } and {cmd:append } are file commands which specify whether the current output will overwrite or be to appended to {it:filename.tex}; see {help file} for details. {p 4 4 2}{cmd:textsize(}{it:string}{cmd:)} specifies the LaTeX font size. The 10 acceptable values are as follows: \tiny, \scriptsize, \footnotesize, \small, \normalsize (default), \large, \Large, \LARGE, \huge, and \Huge. {p 4 4 2}{cmd:scale(}{it:#}{cmd:)} specifies the PSfrag scaling factor (default=1) which can be used in conjunction with {cmd:textsize(}{it:string}{cmd:)} to address scale/size issues.
{p 4 4 2}
{cmd:substitute(}{it:stringlist}{cmd:)} applies substitutions where {it:`stringlist'} is of the form {it: `from to [from to...]'}. Note that {cmd:substitute($ \$ \dbs \\)} is assumed, since neither {cmd:\$} nor {cmd:\\} can 
be readily displayed in a plot. Accordingly, users should use {cmd:\( ... \)} --- not {cmd:$ ... $} --- to enter LaTeX's math mode. 
{p 4 4 2}{cmd:body(}{it:string }[,{it:subopts}]{cmd:)} specifies the outmost LaTeX environment into which the resulting PSfrag code is to be placed. It accepts two values, {it:figure} and {it:document}, both of which allow the following suboptions:

{p 8 4 2}
{cmd:placement(}{it:string}{cmd:)} specifies the placement argument (default=htbp) of the LaTeX figure environment.

{p 8 4 2}
{cmd:width(}{it:#}{cmd:)} scales the \linewidth argument in the \includegraphics command (default=1).  
{p 8 4 2}
{cmd:caption(}{it:string}{cmd:)} specifies the figure caption.  

{p 8 4 2}
{cmd:label(}{it:string}{cmd:)} specifies the figure label (for cross-referencing). 

{p 8 4 2}
{cmd:packages(}{it:string}{cmd:)} specifies LaTeX packages to be added to the preamble of 
the LaTeX document ({cmd:body(}{it:document}{cmd:)} only).
{title:Examples}
{p 4 4 2}
A simple function:

{p 4 8 2}{cmd:. #delimit;}{p_end}
{p 4 8 2}{cmd:. twoway function y=normalden(x), range(-4 4)}{p_end}
{p 4 8 2}{cmd:> text(0.125 0 "\textbf{\color{blue}{Normal PDF:}}")}{p_end}
{p 4 8 2}{cmd:> text(0.090 0 "\(y=\frac{1}{\sigma\sqrt{2\pi}}e^{\frac{-(x-\mu)^2}{2\sigma^2}}\)")}{p_end}
{p 4 8 2}{cmd:> xlabel(-4 "\(-4\sigma\)" -2 "\(-2\sigma\)" 0 "\(\mu\)" 2 "\(2\sigma\)" 4 "\(4\sigma\)")}{p_end}
{p 4 8 2}{cmd:> xtitle("All text is set in {\LaTeX} font") ytitle("\(y\)");}{p_end}
{p 4 8 2}{cmd:. graph export normal.eps, as(eps);}{p_end}
{p 4 8 2}{cmd:. writepsfrag normal.eps using normal.tex;}{p_end}
{p 4 8 2}{cmd:. #delimit cr}{p_end}

{p 4 4 2}
The resulting PSfrag code can be called using LaTeX's \input command:
{p 4 8 2} {cmd:\begin{figure}[htbp]} {p_end}
{p 4 8 2} {cmd:   \centering}{p_end}
{p 4 8 2} {cmd:   \input{normal.tex}}{p_end}
{p 4 8 2} {cmd:   \resizebox{1\linewidth}{!}{\includegraphics{normal.eps}}}{p_end}
{p 4 8 2} {cmd:	  \caption{Normal Probability Density Function}}{p_end}
{p 4 8 2} {cmd:\end{figure}}{p_end}

{p 4 4 2}
The same LaTeX code can be generated using the {cmd:body(}{it:figure}{cmd:)} option:

{p 4 8 2}
{cmd:. writepsfrag normal.eps using normal.tex, replace body(figure, caption("Normal Probability Density Function"))}{p_end}

{title:Author}

{p 4 4 2}
Ryan E. Kessler{break} 
Research Department{break} 
Federal Reserve Bank of Boston{break} 
{browse "mailto:ryan.edmund.kessler@gmail.com":ryan.edmund.kessler@gmail.com}
{title:References}

{p 4 8 2}
Cox, N. J. 2004. Stata tip 6: Inserting awkward characters in the plot. The Stata Journal 4(1): 95-96.

{p 4 8 2}
Cox, N. J. 2008. Stata tip 65: Beware the backstabbing backslash. The Stata Journal 8(3): 446-447.

{p 4 8 2}
Grant, M. C., and D. Carlisle. 1998. The PSfrag system, version 3. {browse "ftp://ctan.tug.org/tex-archive/macros/latex/contrib/psfrag/pfgguide.pdf"}

{p 4 8 2}
Jann, B. 2005. Making regression tables from stored estimates. The Stata Journal 5(3): 288–308.
{p 4 8 2}
Jann, B. 2007. Making regression tables simplified. The Stata Journal 7(2): 227–244.