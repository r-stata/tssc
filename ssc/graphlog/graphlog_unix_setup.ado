program	graphlog_unix_setup
if "$S_OS" != "Windows" {
	disp `"Open the terminal (the terminal of the operating system, not Stata's Command window)"' `"and type "which pdflatex" (without the quotes)."'
	disp "If you have correctly installed LaTeX with pdflatex, the pdflatex installation path will be displayed."
	disp "Paste that path into the Stata command window now, then press enter" _request(displayedPath)

	tempname myFile
	file open `myFile' using "`c(sysdir_plus)'g/graphlog_pdflatex_path.ado", write replace
	file write `myFile' "program graphlog_pdflatex_path" _n `"global pdflatexPath = "$displayedPath""' _n "end" _n
	file close `myFile'

	disp `"Thank you. graphlog now knows that pdflatex is placed at the following location: "$displayedPath"."'
	disp "Please restart Stata. Then graphlog should work."
	}
else {
	disp "Sorry, this ado-file is only for setting up Unix systems."
	}
end
