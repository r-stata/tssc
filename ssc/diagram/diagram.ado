/*** DO NOT EDIT THIS LINE -----------------------------------------------------
Version: 1.0.1
Title: diagram
Description: implements [Graphviz](http://www.graphviz.org/) in Stata
and generates dynamic diagrams 
using [DOT markup language](http://en.wikipedia.org/wiki/Dot) and 
exports images in __pdf__, __png__, __jpeg__, __gif__, and __bmp__ format. 
The package also includes several programs that generate automatic path diagrams. For 
more information [visit diagram homepage](http://www.haghish.com/diagram/diagram.php).
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
{cmd: diagram} {{it:DOT} | {help using} {it:filename}} {cmd:,} {it:export(filename)} 
[{it:replace}  {it:magnify(real)} {it:phantomjs(str)} {it:engine(name)} ]
{p_end}

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt replace}}replace the exported diagram{p_end}
{synopt:{opt engine(name)}}specifies the  
{browse "http://www.graphviz.org/Download.php":graphViz} engine for rendering the 
diagram which can be {bf:dot}, {bf:osage}, {bf:circo}, {bf:neato}, {bf:twopi} and {bf:fdp}. 
The default engine is {bf:dot} {p_end}
{synopt:{opt e:xport(filename)}}export the diagram. The file extension specifies the 
format and it can be {bf:.pdf}, {bf:.png}, {bf:.jpeg}, {bf:.gif}, or {bf:.bmp}{p_end}
{synopt:{opt mag:nify(real)}}increases the resolution of the exported image by multiplying its 
resolution to the specified number. The value of the real number should be above {bf:0} and 
by default is {bf:1.0}{p_end}
{synopt:{opt phantomjs(str)}}specifies the path to executable 
[phantomjs software](http://www.phantomjs.org/download.html) on the machine{p_end}
{synoptline}
{p2colreset}{...}


Example programs
================

The package includes several example programs that generate DOT path diagrams 
that can be rendered using the __diagram__ command. These programs can be used to 
visualize a function call of an ado-program, generate path diagram from data set, 
and also create dynamic SEM models (prototype development). These example programs 
are documented in separate help files:

{* the new Stata help format of putting detail before generality}{...}
{synoptset 20 tabbed}{...}
{synopthdr:Example program}
{synoptline}
{synopt:{help semdiagram}}draws dynamic SEM models{p_end}
{synopt:{help makediagram}}generates DOT path diagram from data set{p_end}
{synopt:{help calldiagram}}visualizes the function calls of an ado-program{p_end}
{synoptline}
{p2colreset}{...}

Description
===========

__diagram__ renders [graphViz](http://www.graphviz.org/Download.php) graphs 
within Stata and exports them to several graphical formats including __pdf__, 
__png__, __jpeg__, __gif__, and __bmp__. This package is 
independent of the software and does not require installing graphViz. The __diagram__ 
command can render a graph using _DOT_ markup or by using file that includes the 
markup. For large graphs, it is advices to create a file and then render the graph. 

[graphViz](http://www.graphviz.org/Download.php) is an open source graph visualization 
software which can be used to represent structural information such as diagrams of 
algorithms, groups, abstract graphs, and networks. The software has had notable 
applications in a variety of fields such as network visualization, bioinformatics,  
machine learning. The software renders graphics using a markup language which is 
highly customizable and can be altered with precision. Yet, it can be written in a 
very simple and basic way to make it human-readable. FOr more information regarding 
the software visit [graphViz homepage](http://www.graphviz.org/). 

This package can have plenty of applications for Stata users. For example, it can 
be used to develop analysis diagrams, visualize information/algorithms, create 
diagrams for education purpose as well as write Stata programs that generate 
dynamic diagrams based on the results of data analysis. 


Engines
=======

[graphViz](http://www.graphviz.org/Documentation/pdf/libguide.pdf) has several engines which are __dot__, 
__neato__, __fdp__, __twopi__, __circo__, and __osage__. These engines render the 
diagrams differently but their markup is not identical. All of these engines are 
supported in this package but the user should read the engines carefully. 
The most popular engines are __dot__ and __neato__. A brief description of the 
engines is presented below : 

[dot](http://www.graphviz.org/pdf/dot.1.pdf) - "directed graphs" which is the 
default engine for rendering graphs where edges have directionality e.g. 
{bf:A -> B}.

[neato](http://www.graphviz.org/pdf/neatoguide.pdf) is recommended for undirected diagrams, 
especially when the size of the diagram is about 100 nodes or less. 

[fdp](http://www.graphviz.org/pdf/fdp.1.pdf) draws undirected graphs similar to 
__neato__, but applies different layouts.

[twopi](http://www.graphviz.org/pdf/twopi.1.pdf) applies radial layouts. 

[circo](http://www.graphviz.org/pdf/circo.1.pdf) applies circular layouts.

[osage](http://www.graphviz.org/pdf/osage.1.pdf) applies clustered layouts.


Third-party software
====================

For exporting graphical files, the package requires [phantomJS](http://phantomjs.org/download.html), 
which is an open-source freeware available for Windows, Mac, and Linux. The 
path to the executable _phantomjs_ file is required in order to export the 
graphical files.  


Example(s)
=================

    rendering DOT markup
        . graphviz digraph G {a -> b;}, magnify(2.5) export(../diagram.png) 	///
          phantomjs("/usr/local/bin/phantomjs")

    rendering a graphviz file
        . graphviz using myfile.dot, magnify(2.5) export(../diagram.png) 	///
          phantomjs("/usr/local/bin/phantomjs")

		  
Acknowledgements
================

The JavaScript engine of the program was developed by 
[Michael Daines](https://www.github.com/mdaines).  

Author
======

__E. F. Haghish__     
Center for Medical Biometry and Medical Informatics     
University of Freiburg, Germany     
_and_        
Department of Mathematics and Computer Science       
University of Southern Denmark     
haghish@imbi.uni-freiburg.de     
      
[http://www.haghish.com/markdoc](http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php)         
Package Updates on [Twitter](http://www.twitter.com/Haghish)  

- - -

This help file was dynamically produced by {help markdoc:MarkDoc Literate Programming package}
***/

*cap prog drop diagram    
prog define diagram

	version 11
	syntax [anything] [using/] , [Export(str)] [MAGnify(real 1.0)] [replace] 	///
	[phantomjs(str)] [install] [engine(name)] [Noisily]
	 
	
	// -------------------------------------------------------------------------
	// Syntax processing
	// =========================================================================
	
	// setpath permanently
	// -------------------------------------------------------------------------
	if substr(trim(`"`macval(0)'"'),1,7) == "setpath" {
		local 0 : subinstr local 0 "setpath" ""
		confirm file `0'
		
		//Save an ado file
		tempfile diagrampath
		tempname knot
		qui file open `knot' using "`diagrampath'", write text replace
		file write `knot' "program define diagrampath" _n
		file write `knot' `"	global diagrampath `macval(0)'"' _n
		file write `knot' "end" _n
		qui file close `knot'
		qui copy "`diagrampath'" "`c(sysdir_plus)'d/diagrampath.ado", replace
		exit
	}
	
	// else check for the export option to make it obligatory
	else if missing("`export'") {
		di as err "the {bf:export} option is required"
		err 198
	}
	
	
	
	// Get phantomJS path, if defined
	// -------------------------------------------------------------------------
	capture prog drop diagrampath
	capture diagrampath
	
	// checking for double quotation
	// -------------------------------------------------------------------------
	if !missing(`"`macval(anything)'"') {
		capture local anything: di `anything'
	}	
	local anything : di `"'`macval(anything)''"'
	
	// check input:
	if !missing(`"`macval(anything)'"') & missing("`using'") & !missing("`noisily'") {
		di  _n(2) "{title:input}" _n `"{p}`macval(anything)'"'
	}
	
	// Remowing double quotation from `anything'
	if !missing(`"`macval(anything)'"') {
		if substr(`"`macval(anything)'"', 1,1) == `"""' {
			local anything : di substr(`"`macval(anything)'"',2,.)
		}
		if substr(`"`macval(anything)'"', -1,1) == `"""' {
			local anything : di substr(`"`macval(anything)'"',1,strlen(`"`macval(anything)'"')-1)
		}
	}
	
	// Magnify option
	if `magnify' <= 0 {
		di as err "{bf:magnify} cannot be equal or less than 0"
		error 198
	}
	
	// Make sure the webimage package is installed 
	capture quietly findfile webimage.ado
	if _rc != 0 {
		di as err "{stata ssc install webimage: the {bf:webimage} package is required}"
		error 198
	}
	
	
	local wk : pwd
	qui cd "`c(sysdir_plus)'v"
	local here : pwd
	
	// Get the path to graphViz JavaScript file
	capture findfile viz.js, path("`here'")
	if _rc != 0 {
		di as err "graphViz javascript not found. Please reinstall {help diagram}"
		error 198
	}
	else local javascript "`r(fn)'"
	
	qui cd "`c(sysdir_plus)'d"
	local here : pwd
	capture findfile diagram.js, path("`here'")
	if _rc != 0 {
		di as err "diagram.js javascript not found. Please reinstall {help diagram}"
		error 198
	}
	else local command "`r(fn)'"

	qui cd "`wk'"

	// check for phantomJS
	if missing("`phantomjs'") {
		if !missing("$diagrampath") local phantomjs $diagrampath
		else {
			di as err "path to phantomJS software is required"
			error 198
		}	
	}	
	confirm file "`phantomjs'"
	  
	
	
	// Analyze DOT scripts and data sets
	// =========================================================================
	if !missing("`using'") {
		
		*confirm file "`using'"
		// figure out a way to confirm files from internet. the "confirm file" fails
		tempfile tmp 
		quietly copy "`using'" "`tmp'", replace		// this already confirms the file
		
		tempname hitch 
		qui file open `hitch' using "`tmp'", read
		file read `hitch' line
		while r(eof)==0 {
			
			// Make sure the DOT script file DOES NOT HAVE COMMENTS...
			if substr(`"`macval(line)'"',1,1) == "#" {
				file read `hitch' line
			}
			
			local source = `"`macval(source)'"' +  `"`macval(line)'"'
			file read `hitch' line
		}
		local anything `"'`macval(source)''"'
	}
	
	// di as err `"'`macval(source)''"'
	
	// Specify the engine
	if missing("`engine'") {
		cap tokenize `"`anything'"'
		if `"`1'"' == `"graph"' local engine neato
	}
	if !missing("`engine'") {
		*local additional `",{ engine: "`engine'" }"'
		*local anything = `"`macval(anything)'"' + `"`macval(additional)'"'
		local anything `"`macval(anything)',{ engine: "`engine'" }"'
	}
	
	if "`engine'" != "dot" & "`engine'" != "neato" & "`engine'" != "fdp" 		///
	& "`engine'" != "circo" & "`engine'" != "osage" & "`engine'" != "twopi"  	///
	& !missing("`engine'") {
		di as err "{bf:engine} not recognized"
		error 198
	}
	
	
	*else if "`engine'" == "dot" {
	*	local engine 
	*}

	
	
	
	if missing("`replace'") {
		capture findfile "`export'"
		if _rc == 0 {
			di as err "`export' already exists. use the {bf:replace} option"
			error 198
		}
	}
	*di as err `"`macval(anything)'"'
	*di as txt "ENGINE: `engine'"
	
	// Create the HTML file
	// =========================================================================
	tempfile tmp 
	tempname hitch knot 
	qui file open `knot' using `"`tmp'"', write replace
	
	file write `knot' 															///
	"<!doctype html>" _n														///
	"<html>" _n																	///
	`"<script type="text/javascript" src="`javascript'"></script>"' _n				///
	`"<style type="text/css">"' _n "body {zoom:`magnify';}" _n "</style>" _n	///
	"</head>" _n																///
	"<body>" _n																	///
	"<script>" _n																///
	"document.body.innerHTML += Viz(" _n										///
	`"`macval(anything)'"' _n 													///
	");" _n																		///
	"</script>" _n																///
	"</body>" _n																///
	"</html>" _n
	file close `knot'
	
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
	
	qui copy "`tmp'" "_tmp_file_000.html", replace
	! "`phantomjs'" "`command'" "_tmp_file_000.html" "`export'"
	
	if missing("`noisily'") capture qui erase "_tmp_file_000.html"
	
	cap confirm file "`export'"
	if _rc == 0 {
		di as txt "{p}({bf:diagram} created "`"{bf:{browse "`export'"}})"' _n
	}
	else display as err "diagram could not produce `export'" _n	
	
end

* diagram setpath "/Users/haghish/Downloads/phantomjs/bin/phantomjs"
* markdoc diagram.ado, exp(sthlp) replace
* markdoc diagram.ado, exp(pdf) replace style(stata) title("Dynamic Diagrams in Stata") author("E. F. Haghish") date 
