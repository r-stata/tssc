{smcl}
{* February 2013}{...}
{hline}
{cmd:help for dta2html} 
{hline}

{title:Title}

{p 4 8 2}
{bf:dta2html --- Generate HTML code to display a Stata dataset on the web}

{title:Syntax}

{phang}
{cmd: dta2html} [{varlist}] [if] [in]{cmd:,}  {opt sav:ing(html_filename,[sub_option])} 
 [{opt page:title("title")} {opt tabt:itle("title")} 
 {opt d:atalink("address")} {opt t:odisp("todisname", "txt"|"img")} {opt css("path")}]


{synoptline}

{marker description}{dlgtab:Description}

{pstd}
dta2html generates minimum HTML code necessary to display a Stata dataset loaded in memory on the 
web. At the completion of the process, an HTML file containing the code is created and placed in the 
working directory, and two links are created. Whereas clicking on the first link will display the HTML 
file contents in Stata's result window, clicking on the second link will display the data in Internet 
Explorer, assuming you are running Windows and Internet Explorer is your default browser. To display 
the data in Google Chrome, with Google Chrome being your default browser or not, follow these steps:
1) Open Google Chrome if it is not already open 2) While in Google Chrome, press "CTRL O" 3) Navigate 
to the HTML file and select it 4) Finally click "Open." 

{pstd}
{cmd:dta2html} is intended to provide a quick way to display a sample dataset on the web. Unless instructed 
otherwise (e.g., {varlist} is specified), {cmd:dta2html} will provide HTML code for the entire dataset.

{pmore} Stata 11.0 or higher is required.

{title:Options}

{dlgtab:Options}

{phang}
{opt saving(html_filename, sub_option)} requests that the dataset be written to the file {it:html_filename}, where 
{it:html_filename} is the name for the HTML file to be created. Extension .html will be added to the file name. 
If {it:sub_option}, where {it:sub_option} must equal {it:replace}, is specified, {cmd:dta2thml} will overwrite an 
existing file with the same name. This option is required. 

{phang}
{opt pagetitle("title")} specifies the browser page title; default is {bf:pagetitle("Stata Dataset in your Browser")}.

{phang}
{opt tabtitle("title")} specifies a caption or a title for the displayed dataset; default is {bf:tabtitle("Stata Dataset")}.

{phang}
{opt datalink("address")} provides a link where the displayed data or a related dataset can be downloaded. This can
be a web link or a link to a file on your personal computer (see examples below). Note that some web servers do not 
allow uploading .dta files. In this case, you might want to save your .dta file to a compressed zip file. In the case 
of a web link, you need to find out what the address is and then supply it with option {opt datalink()}. The link will be
placed on top of the displayed data in your browser.

{phang}
{opt todisp("dispname", txt|img)} indicates whether to display the link as a clickable text or a clickable image. 
Links sometimes look better when adorned with fancy image buttons. A not-so fancy button image to be used with option 
{opt datalink()} is provided with {cmd:dta2html}. The file must be placed in the current directory. You can provide a file, 
web or server address where your own fancy image file resides. 

{pmore}Option {opt todisp()} must be combined with {opt datalink()}.

{phang}   
{opt css("path")} provides the cascading style sheet for the web page. {cmd:dta2html} provides the minimum HTML 
code necessary for a nice looking page. To obtain a fancier look, you might want to provide your own CSS file using this 
option and edit the tags appropriately, or you can just edit the provided style sheet after the creation of the HTML file. 

{title: Examples}

{phang}
1) Generate HTML code to display the auto dataset on the web

{pmore}{stata sysuse auto, clear: . sysuse auto, clear}

{pmore}{cmd:. dta2html, saving(auto_dataset) pagetitle("The Auto Dataset in my Browser") tabtitle("Auto Dataset")}{p_end}
{pmore}{stata `"dta2html, saving(auto_dataset) pagetitle("The Auto Dataset in my Browser") tabtitle("Auto Dataset")"':--> Click to run}

{phang}
2) Generate HTML code to display the auto dataset on the web and provide a link to download the data

{pmore}{cmd:. dta2html, saving(auto_dataset, replace) datalink("http://www.stata-press.com/data/r12/auto.dta") todisp("Download data from here", "txt")}{p_end}
{pmore}{stata `"dta2html, saving(auto_dataset, replace) datalink("http://www.stata-press.com/data/r12/auto.dta") todisp("Download data from here", "txt")"':--> Click to run}

{phang}
3) Try the same thing on your PC but with the provided image file (dta2html_img.png) assumed to be saved to the current directory  

{pmore}{cmd:. dta2html, saving(auto_dataset, replace) datalink("file:///`c(sysdir_base)'a/auto.dta") todisp("file:///`c(pwd)'/dta_img.png", "img")}{p_end}
{pmore}{stata `"dta2html, saving(auto_dataset, replace) datalink("file:///`c(sysdir_base)'a/auto.dta") todisp("file:///`c(pwd)'/dta_img.png", "img")"':--> Click to run}

{phang}
4) Specify a CSS file

{pmore}{cmd:. dta2html, saving(auto_dataset, replace) css("./mystyles.css")}{p_end}


{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, Rice University,{break} 
           
{p 4 4 2}Email to {browse "mailto:pwjeanty@rice.edu":pwjeanty@rice.edu}.


{title:Also see}

{p 4 13 2} {helpb hlp2html} if installed

