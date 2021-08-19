/*

					   Developed by E. F. Haghish (2016)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de
								   
                    * this software come with no warranty *
	
	
	DESCRIPTION
	===========
	
	This program defines the filepaths to wkhtmltopdf, pdfLaTeX, Pandoc, and 
	MathJax for Weaver and MarkDoc packages
	
	To edit this file, insert the path to the executable file inside the 
	quotations to define the global macro. Here is an example for defining the 
	file path to pdfLaTeX:
	
	. global pathPdflatex  "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe"
	
	
	WARNING 1
	-----------
	If you wish to remove a path, make sure not to leave an empty space between the 
	quotation marks. for example you can remove the example above by making the 
	global macro NULL (i.e. no string character is defined): 
		
	. global pathPdflatex    ""
	
	
	
	WARNING 2
	-----------
	
	The changes made in this file are permanent and do not get replaced with the 
	next package update. But you can always access them using the "weave setup" 
	command
*/
	
	
	
	
program define weaversetup
version 11
	
// -----------------------------------------------------------------------------
// Path to executable third-party software, required by Weaver and MarkDoc                   
// =============================================================================
	
// wkhtmltopdf                   
// -----------------------------------
global pathWkhtmltopdf ""	//example: "C:\wkhtmltopdf\bin\wkhtmltopdf.exe"
	
	
// pdfLaTeX
// -----------------------------------
global pathPdflatex    ""	//example: "C:\Program Files\MiKTeX 2.9\miktex\bin\x64\pdflatex.exe"
	
	
// MathJax 
// -----------------------------------
global pathMathJax     ""	//example: "C:\Users\haghish\Downloads\MathJax-master"
	
	
// Pandoc (for MarkDoc)                    
// -----------------------------------
global pathPandoc      ""	//example: "C:\Pandoc\pandoc.exe"
	


	
// -----------------------------------------------------------------------------
// Settings for Weaver and MarkDoc                   
// =============================================================================

// markup language for MarkDoc
// -----------------------------------
global markdocDefault  ""	//example: "markdown" or "html" or "latex" 

// Default paper size
// -----------------------------------
global doc_paper       ""   //example: "a4"  or "letter" 
	
// -----------------------------------------------------------------------------
// DO NOT EDIT THE REST OF THIS FILE                
// =============================================================================
if !missing("$markdocDefault") {
	if "$markdocDefault" != "markdown" & "$markdocDefault" != "html" & 			///
	"$markdocDefault" != "latex" {
		di as err `"{p}global macro {bf:markdocDefault} is not recognized. "' ///
		"type {stata weave setup} to redifine the default markup language for MarkDoc"
			exit 198
	}
}
	
	
end
	
	
	
	
	
	
	
