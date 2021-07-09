/*** DO NOT EDIT THIS LINE -----------------------------------------------------
Version: 1.0.0
Title: webimage
Description: prints images from web files in __pdf__, __png__, __jpeg__, 
__gif__, and __bmp__ format. For 
more information [visit webimage homepage on GitHub](https://github.com/haghish/webimage).
----------------------------------------------------- DO NOT EDIT THIS LINE ***/


// Generate the dynamic help file
// ==============================
//
// This program includes documentation for generating automatic Stata help files
// using MarkDoc package.  Execute the code below to generate the help file

* markdoc diagram.ado, exp(sthlp) replace



/***
Syntax
======

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
[phantomjs software](http://www.phantomjs.org/download.html) on the machine{p_end}
{synoptline}
{p2colreset}{...}


Description
===========

[webimage](https://github.com/haghish/webimage) converts web files and online 
web addresses to graphical images including __pdf__, __png__, __jpeg__, 
__gif__, and __bmp__ formats. 

the package can have many implications in statistics and data visualization. 
many web applets are developed using JavaScript for data visualization and 
presentation. however, these web-applications are usually stored in a HTML 
file. the __webimage__ package provides a solution for converting the web content 
to a graphical file.

Third-party software
====================

For exporting graphical files, the package requires [phantomJS](http://phantomjs.org/download.html), 
which is an open-source freeware available for Windows, Mac, and Linux. The 
path to the executable _phantomjs_ file is required in order to export the 
graphical files.  


Example(s)
=================

    rendering a web file to a PDF image 
        . webimage filename.html, export(./image.pdf)                           ///
          phantomjs("/usr/local/bin/phantomjs")	

    rendering an online webpage to PNG
        . webimage "http://www.google.com", export(./image.png)                 ///
          phantomjs("/usr/local/bin/phantomjs")

Author
======

__E. F. Haghish__     
Center for Medical Biometry and Medical Informatics     
University of Freiburg, Germany     
_and_        
Department of Mathematics and Computer Science       
University of Southern Denmark     
haghish@imbi.uni-freiburg.de     
      
{browse "http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php":http://www.haghish.com/markdoc}   
Package Updates on [Twitter](http://www.twitter.com/Haghish)  
***/


    
prog define webimage
	version 11
	syntax [anything] , Export(str) [replace] [phantomjs(str)] [Noisily]
	 

	
	// Syntax processing
	// =========================================================================
	if `magnify' <= 0 {
		di as err "{bf:magnify} cannot be equal or less than 0"
		error 198
	}
	
	local wk : pwd
	qui cd "`c(sysdir_plus)'v"
	local here : pwd
	
	qui cd "`c(sysdir_plus)'d"
	local here : pwd
	capture findfile diagram.js, path("`here'")
	if _rc != 0 {
		di as err "diagram.js javascript not found. Please reinstall {help diagram}"
		error 198
	}
	else local command "`r(fn)'"

	qui cd "`wk'"

	
	if missing("`phantomjs'") local phantomjs phantomjs
	else confirm file "`phantomjs'"
	  
	*local anything : di `"'`macval(anything)''"'
	
	
	if missing("`replace'") {
		capture findfile "`export'"
		if _rc == 0 {
			di as err "`export' already exists. use the {bf:replace} option"
			error 198
		}
	}
	
	
	// Export the graphical file
	// =========================================================================
	
	if index(lower("`export'"),".png") == 0 & 									///
	index(lower("`export'"),".jpeg") == 0 &										///
	index(lower("`export'"),".bmp") == 0 & 										///
	index(lower("`export'"),".gif") == 0 &										///
	index(lower("`export'"),".pdf") == 0 {
		di as err "unsupported file format. see {help diagram}"
		error 198
	}
	
	*qui copy "`tmp'" "_tmp_file_000.html", replace
	
	! "`phantomjs'" "`command'" "`anything'" "`export'"
	
	if missing("`noisily'") capture qui erase "_tmp_file_000.html"
	
	cap confirm file "`export'"
	if _rc == 0 {
		di as txt "{p}({bf:webimage} created "`"{bf:{browse "`export'"}})"' _n
	}
	else display as err "{bf:webimage} could not produce `export'" _n	
	
end

* webimage "http://www.google.com", exp(example.png) phantomjs("/usr/local/bin/phantomjs") replace

 markdoc webimage.ado, exp(sthlp) replace
* markdoc diagram.ado, exp(pdf) replace style(stata) title("Dynamic Diagrams in Stata") author("E. F. Haghish") date 



