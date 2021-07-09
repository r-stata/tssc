{smcl}
{right:version 1.0.0}
{title:Title}

{phang}
{cmd:webimage} {hline 2} prints images from web files in {bf:pdf}, {bf:png}, {bf:jpeg}, {bf:gif}, and {bf:bmp} format. For  more information  {browse "https://github.com/haghish/webimage":visit webimage homepage on GitHub}.


{title:Syntax}

{p 8 16 2}
{cmd: webimage} [{it:filename} | {it:http address}] [{cmd:,} 
{it:replace} {it:export(str)} {it:phantomjs(str)} ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}replace the exported diagram{p_end}
{synopt:{opt e:xport(str)}}specifies the image filename. The file extension specifies the 
format and it can be {bf:.pdf}, {bf:.png}, {bf:.jpeg}, {bf:.gif}, or {bf:.bmp}{p_end}
{synopt:{opt phantomjs(str)}}specifies the path to executable 
{browse "http://www.phantomjs.org/download.html":phantomjs software} on the machine{p_end}
{synoptline}
{p2colreset}{...}



{title:Description}

{p 4 4 2}
{browse "https://github.com/haghish/webimage":webimage} converts web files and online 
web addresses to graphical images including {bf:pdf}, {bf:png}, {bf:jpeg}, 
{bf:gif}, and {bf:bmp} formats. 

{p 4 4 2}
the package can have many implications in statistics and data visualization. 
many web applets are developed using JavaScript for data visualization and 
presentation. however, these web-applications are usually stored in a HTML 
file. the {bf:webimage} package provides a solution for converting the web content 
to a graphical file.


{title:Third-party software}

{p 4 4 2}
For exporting graphical files, the package requires  {browse "http://phantomjs.org/download.html":phantomJS}, 
which is an open-source freeware available for Windows, Mac, and Linux. The 
path to the executable {it:phantomjs} file is required in order to export the 
graphical files.    {break}



{title:Example(s)}

    rendering a web file to a PDF image 
        . webimage filename.html, export(./image.pdf)                           ///
          phantomjs("/usr/local/bin/phantomjs")	

    rendering an online webpage to PNG
        . webimage "http://www.google.com", export(./image.png)                 ///
          phantomjs("/usr/local/bin/phantomjs")


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
{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php":http://www.haghish.com/markdoc}     {break}
Package Updates on  {browse "http://www.twitter.com/Haghish":Twitter}    {break}

