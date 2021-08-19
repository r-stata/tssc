/*

							  Stata Weaver Package
					   
					   Developed by E. F. Haghish (2014)
			  Center for Medical Biometry and Medical Informatics
						University of Freiburg, Germany
						
						  haghish@imbi.uni-freiburg.de

		
                   The Weaver Package comes with no warranty    	
				  
				  
	DESCRIPTION
	==============================
	
	This program is only executed by "weave.ado" program to add the Weaver Markup 
	code the Weaver document. This code is written in JavaScript to process 
	Weaver Markup syntax and convert it to HTML. 

*/

		
program define weavermarkup
    version 11
	
	tempname canvas 
	capture file open `canvas' using "$htmldoc" , write text append
			
	********************************************************************
	* JavaScript Markdown Syntax
	********************************************************************
	file write `canvas' _n(2) "<!-- Weaver Markup Syntax  -->"  _n(2) 			///
	`"<script type="text/javascript">"' 						_n(2) 			///
	_skip(4) "function correction() {" 							_n 				///
	_skip(4) "document.body.innerHTML = document.body.innerHTML" _n 			///
	_skip(8) ".replace(/<results><\/results>/g, '')" _n 						///
	_skip(8) ".replace(/<\/result><result>/g, '')" _n 							///
	/// defining the H1, H2, H3, H4 symbols
	_skip(8) ".replace(/\*----/g, '<h4>')" _n 									///
	_skip(8) ".replace(/----\*/g, '</h4><p>')" _n 								///
	_skip(8) ".replace(/\*---/g, '<h3>')" _n 									///
	_skip(8) ".replace(/---\*/g, '</h3><p>')" _n 								///
	_skip(8) ".replace(/\*--/g, '<h2>')" _n 									///
	_skip(8) ".replace(/--\*/g, '</h2><p>')" _n 								///
	_skip(8) ".replace(/\*-/g, '<h1>')" _n 										///
	_skip(8) ".replace(/-\*/g, '</h1><p>')" _n 									///
	/// break and pagebreak
	_skip(8) ".replace(/page-break/g, '<div class="`"""'"pagebreak"`"""'" ></div>')" _n ///
	_skip(8) ".replace(/line-break/g, '<br />')" _n 							///
	/// text decoration
	_skip(8) ".replace(/#___/g, '<strong><em>')" _n 							///
	_skip(8) ".replace(/___#/g, '</em></strong>')" _n 							///
	_skip(8) ".replace(/#__/g, '<strong>')" _n 									///
	_skip(8) ".replace(/__#/g, '</strong>')"  _n 								///
	_skip(8) ".replace(/#_/g, '<em>')" _n 										///
	_skip(8) ".replace(/_#/g, '</em>')" _n 										///
	_skip(8) ".replace(/#\*/g, '<u>')" _n 										///
	_skip(8) ".replace(/\*#/g, '</u>')" _n 										///
	/// link codes
	_skip(8) ".replace(/\[--/g, '<a href=')" _n 								///
	_skip(8) ".replace(/\--]\[-/g, ' >')" _n 									///
	_skip(8) ".replace(/-\]/g, '</a>')" _n 										///
	_skip(8) ".replace(/\[#\]/g, '</span>')" _n 								///
	/// background colors
	_skip(8) ".replace(/\[-yellow\]/g, '<span style="`"""'"background-color:#FAE768"`"""'">')" _n ///
	_skip(8) ".replace(/\[-green\]/g, '<span style="`"""'"background-color:#CBEF66"`"""'">')" _n ///
	_skip(8) ".replace(/\[-blue\]/g, '<span style="`"""'"background-color:#ABC5F6"`"""'">')" _n ///
	_skip(8) ".replace(/\[-pink\]/g, '<span style="`"""'"background-color:#F1A8D0"`"""'">')" _n ///
	_skip(8) ".replace(/\[-purple\]/g, '<span style="`"""'"background-color:#D6ABEF"`"""'">')" _n ///
	_skip(8) ".replace(/\[-gray\]/g, '<span style="`"""'"background-color:#D6D6D6"`"""'">')" _n ///
	/// font colors
	_skip(8) ".replace(/\[blue\]/g, '<span style="`"""'"color:#00F"`"""'">')" _n ///
	_skip(8) ".replace(/\[pink\]/g, '<span style="`"""'"color:#FF0080"`"""'">')" _n ///
	_skip(8) ".replace(/\[purple\]/g, '<span style="`"""'"color:#8000FF"`"""'">')" _n ///
	_skip(8) ".replace(/\[green\]/g, '<span style="`"""'"color:#408000"`"""'">')" _n ///
	_skip(8) ".replace(/\[orange\]/g, '<span style="`"""'"color:#FF8000"`"""'">')" _n ///
	_skip(8) ".replace(/\[red\]/g, '<span style="`"""'"color:#F00"`"""'">')" _n ///
	/// text positionning 
	_skip(8) ".replace(/\[center\]/g, '<span style="`"""'"display:block; text-align:center"`"""'">')" _n ///
	_skip(8) ".replace(/\[right\]/g, '<span style="`"""'"display:block; text-align:right"`"""'">')" _n ///
	_skip(8) ".replace(/\[box\]/g, '<span class="`"""'"code"`"""'">')" _n 		///
	_skip(8) ".replace(/\[mono\]/g, '<span class="`"""'"mono"`"""'">')" _n 		///
	_skip(4) ";}" _n 															///
	///_skip(4) " window.onload = correction;" _n /// //this will only load this JS
	"</script>" _n(2)
	
	file close `canvas'
end
