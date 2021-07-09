*1.0.1 GHR April 27, 2009
program graphexportpdf
	version 10
	set more off
	syntax anything(name=filename) [, DROPeps replace]
	local extension=regexm("`filename'","(.+)\.pdf")
	if `extension'==1 {
		disp "{text:note, the file extension .pdf is allowed but not necessary}"
		local filename=regexs(1) 
	}
	if "`replace'"=="replace" {
		disp "{text:note, replace option is always on with graphexportpdf}"
	}
	graph export "`filename'.eps", replace
	if "$S_OS"=="Windows" {
		disp "{error:Sorry, this command only works properly with Mac, Linux, and Solaris. Although I can't make a pdf for you, I have generated an eps file that you can convert to pdf with programs like ghostscript or acrobat distiller}"
	}
	else {
		shell ps2pdf -dAutoPositionEPSFiles=true -dPreserveEPSInfo=true -dAutoRotatePages=/None -dEPSCrop=true "`filename'.eps" "`filename'.pdf"
		if "`dropeps'"=="dropeps" | "`dropeps'"=="drop" {
			shell rm "`filename'.eps"
		}
	}
end
