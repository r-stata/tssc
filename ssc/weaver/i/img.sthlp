{smcl}
{title:Title}

{phang}
{cmd:img} {hline 2} captures and imports images and graphs into the dynamic document. This command belongs to {bf:{help Weaver}} package but it also supports the 
 {bf:{help MarkDoc}} package. This document only describes {bf:txt} in Weaver package. 
 For using the command in MarkDoc package, 
 {browse "https://github.com/haghish/MarkDoc/wiki/img/":read the MarkDoc manual}. 
 

{title:Syntax}

    Import graphical files in the dynamic document
	
	{cmdab:img} [using {it:{help filename}}] [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center}  ]

    Automatically include the {it:current graph} from Stata in the dynamic document
	
	{cmdab:img} [{cmd:,} {opt tit:le(str)} {opt w:idth(int)} {opt h:eight(int)} {opt left} {opt center}  ]


{title:Description}

{p 4 4 2}
The {bf:img} command imports images and graphs into the dynamic document. 
Any graphical file that is compatible with a web-browser can be inserted in the 
html log. This command belongs to {help Weaver} package but it also supports the 
{help MarkDoc} package. The syntax for both packages is the same but
the {bf:img} command behave differently based on which of the packages is in use. 
If Weaver html log and smcl log are open at the same time, the command 
only functions for Weaver and not for MarkDoc. In contrast, when Weaver html log is
not open and scml log is on, it will function for MarkDoc package. 


{title:Options}

{phang}{cmdab:tit:tle(}{it:str}{cmd:)} specify a header string (title) for the figure {p_end}

{phang}{opt w:idth(int)} define the width of the figure. This option must be used 
with {opt h:ight(int)} option. Otherwise, it will keep the actual hight of the 
figure and only changes the width. {p_end}

{phang}{opt h:ight(int)} define the hight of the figure. This option must be used 
with {opt w:idth(int)} option for the same reason mentioned above. {p_end}

{phang}{cmdab::left} this option is the default and it aligns the figure to the 
left-side of the dynamic document. {p_end}

{phang}{cmdab::left} aligns the figure to the center of the dynamic document. {p_end}


{title:Examples}

{p 4 4 2}
You have created a graph in Stata. Before importing in the HTML log, you should 
export it in a format that can be interpreted in html. Such as PNG which is recommended 
because it is lossless format and the same file can be used for publication. 

        . sysuse auto
        . histogram price
        . graph export price.png, replace 

        . img using price.png
        . img using price.png, title("Histogram of the Price variable")
        . img using price.png, w(300) h(200) center

{p 4 4 2}
	Alternatively, the image can be obtained from Stata automatically

        . histogram mpg
        . img, title("Histogram of the MPG variable")


{title:Author}

{p 4 4 2}
{bf:E. F. Haghish}       {break}
Center for Medical Biometry and Medical Informatics       {break}
University of Freiburg, Germany       {break}
{it:and}          {break}
Department of Mathematics and Computer Science         {break}
University of Southern Denmark       {break}
haghish@imbi.uni-freiburg.de       {break}

{p 4 4 2}
{browse "www.haghish.com/weaver":Weaver Homepage}           {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter}    {break}

    {hline}

{p 4 4 2}
{it:This help file was dynamically produced by {browse "http://www.haghish.com/markdoc/":MarkDoc Literate Programming package}} 

