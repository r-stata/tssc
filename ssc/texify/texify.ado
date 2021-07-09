*! texify version 1.0.0 28apr2010 roywada@hotmail.com
*! Invoke texify command for MikTex

prog define texify
version 7

syntax anything
if "`c(os)'" == "Windows" {
	!texify -p -c -b --run-viewer `anything'
}
else {
	local temp = subinstr("`anything'",".tex","",.)
	!pdflatex `temp'
}
end
exit
