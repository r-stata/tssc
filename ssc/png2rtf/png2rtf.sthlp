{smcl}
{* 11nov2010}{...}
{hline}
help for {hi:png2rtf}
{hline}

{title:Including PNG graphs in RTF output}

{title:Syntax}

{p 6 16 2}
{cmd:png2rtf} using {it:newfile.doc}
{bind:[{cmd:,} {cmd:replace}} {cmdab:a:ppend}
{bind:{cmdab:g:raph(}{it:PNG path and filename}{cmd:)}}
{bind:{cmdab:h:eight(}{it:height of graph in pixels, default 753}{cmd:)}}
{bind:{cmdab:w:idth(}{it:width of graph in pixels, default 548}{cmd:)}}
{bind:{cmd:author(}{it:Author name for RTF file properties}{cmd:)}}
{bind:{cmd:title(}{it:Title for RTF file properties}{cmd:)}}
{bind:{cmd:company(}{it:Company for RTF file properties}{cmd:)}}
]
{p_end}

{marker description}{dlgtab:Description}

{p}Suppose you want to export graphs to a document that can be viewed easily by folks who don't use Stata.
Using TeX and making a PDF is arguably the
easiest way to go; see e.g. {stata "ssc d texdoc":texdoc on SSC} for a primer. 
{browse "http://www.stata.com/statalist/archive/2010-10/msg00483.html":Ulrich Kohler has advocated using ghostscript}
and {browse "http://www.stata.com/statalist/archive/2010-10/msg00485.html":Maarten Buis has advocated}
using {help file} to write out html; see also {stata "ssc d log2html":log2html on SSC} for related ideas.
There is also advice from Michael Blasnik on using a mail merge
in Microsoft Word or similar software; see
{browse "http://www.stata.com/statalist/archive/2004-06/msg00301.html":http://www.stata.com/statalist/archive/2004-06/msg00301.html} and 
{browse "http://www.stata.com/meeting/4nasug/abstracts.html#blasnik":http://www.stata.com/meeting/4nasug/abstracts.html#blasnik}.
{p_end}

{p}{cmd:png2rtf} offers yet another alternative: you can export graphs as PNG files
then convert the binary file into a hexdump for
inclusion in an RTF file; {cmd:png2rtf} automates this second step.  
The resulting file can be opened in Microsoft Word and
many other word processors immediately.  Note that the hexdump roughly doubles
the size of the graph file, so do what you can to make sure your PNG is as small 
as possible (e.g. don't plot symbols on top of each other).
{p_end}

{p}You can add other material
to the RTF including text and formatting tags much as you would in
html or TeX, but that functionality is not provided in {cmd:png2rtf} 
(see also e.g. {stata "ssc d estout":estout on SSC} for a program that writes
out estimates and other tables to RTF files).
{p_end}

{marker examples}{dlgtab:Examples}

{p 6 16 2}{stata "sysuse auto, clear": sysuse auto, clear }{p_end}
{p 6 16 2}{stata "sc mpg weight": sc mpg weight }{p_end}
{p 6 16 2}{stata "gr export mpg.png, height(300) width(300) replace": gr export mpg.png, height(300) width(300) replace}{p_end}
{p 6 16 2}{stata "png2rtf using mpg.doc, g(mpg.png) replace": png2rtf using mpg.doc, g(mpg.png) replace}{p_end}
{p 6 16 2}{stata "eststo clear": eststo clear }{p_end}
{p 6 16 2}{stata "_eststo mpg: reg mpg weight": _eststo mpg: reg mpg weight }{p_end}
{p 6 16 2}{stata "_eststo pri: reg price weight": _eststo pri: reg price weight }{p_end}
{p 6 16 2}{stata "esttab mpg pri using mpg.doc, rtf la nogap onecell mti a ti(\par Here is some text{\page}{\b A title})": esttab mpg pri using mpg.doc, rtf la nogap onecell mti a ti(\par Here is some text{\page}{\b A title})}{p_end}
{p 6 16 2}{stata "sc price weight": sc price weight }{p_end}
{p 6 16 2}{stata "gr export price.png, height(300) width(300) replace": gr export price.png, height(300) width(300) replace}{p_end}
{p 6 16 2}{stata "png2rtf using mpg.doc, g(price.png) a": png2rtf using mpg.doc, g(price.png) a}{p_end}

{title:Author}

    Austin Nichols
    Urban Institute
    Washington, DC, USA
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{title:Also see}

{p 1 14}Manual:  {manhelpi png_options G},  {manlink G graph export}
{p_end}

{p 1 10}On-line: help for {help graph export}.
{p_end}
