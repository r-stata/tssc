// Write KML file for mapping lat/lon
// 	stored in a Stata data set -- 2011.09.20
// Bug fix: writeKMLFile used to rely on explicit
// 	variable names. No longer -- 2011.11.19
// 2 improvements -- 2012.12.27
// 	-- place names and descriptions are now optional.
//			if missing, the place category will be filled into
// 		both the name and the description slot.
// 	-- place category can be numeric now.
// Gabi Huiber -- ghuiber@gmail.com

program writekml

version 9.0

syntax, filename(string) plcategory(varname) [plname(varname string) pldesc(varname string)]

local keepthese longitude latitude `plcategory' `plname' `pldesc'

confirm numeric variable longitude
confirm numeric variable latitude

quietly {
	preserve
	tempfile keeps
	keep `keepthese'
	compress
	save "`keeps'", replace
	count
	local obs=r(N)
	levelsof `plcategory', local(kinds)
	capture confirm numeric variable `plcategory'
	if _rc==0 {
		local chex
		foreach k in `kinds' {
			local chex `chex' `plcategory'`k'
		}
		local	kinds `chex'
	}	
	local kinds: list clean kinds
	restore
}

local checkname=length("`plname'")
local checkdesc=length("`pldesc'")
local myargs obs(`obs') filename(`filename') plcategory(`plcategory')
if `checkname'>0 {
	local myargs `myargs' plname(`plname')
}
if `checkdesc'>0 {
	local myargs `myargs' pldesc(`pldesc')
}	 	

writeKMLFile `kinds', `myargs'

end

// write kml file. this is a wrapper that
// relies on components defined below.
capture prog drop writeKMLFile
program writeKMLFile

version 9.0

syntax namelist(min=1), obs(integer) filename(string)  plcategory(varname) [plname(varname string) pldesc(varname string)]

local kinds `namelist'
local kindct: list sizeof kinds
local colors red green blue ltblue yellow orange pink purple 

local colorct: list sizeof colors
if `colorct'<`kindct' {
	di as err "Not enough colors."
	exit
}	
forvalues i=1/`kindct' {
	local kindname: word `i' of `kinds'
	local `kindname': word `i' of `colors' // so, e.g. "local academic green"
}	
local checkname=length("`plname'")
local checkdesc=length("`pldesc'")
local checkncat=0
capture confirm numeric variable `plcategory'
if _rc==0 {
	local checkncat=1
}	

// now write out the KML file 
// -- header first
writeKMLHeader `filename'
// -- then a style corresponding to each kind of object
foreach kindname in `kinds' {
	writeKMLStyle ``kindname'' `filename'
}
// -- then a place marker for each valid observation in the address file
forvalues i=1/`obs' {
	local kind=`plcategory' in `i'
	if `checkncat'==1 {
		local kind `plcategory'`kind'
	}	
	local lat =latitude in `i'
	local lon =longitude in `i'
	local myargs color(``kind'') lon(`lon') lat(`lat')
	if `checkname'>0 {
		local name=`plname' in `i'
		local myargs `myargs' name(`name')
	}
	else {
		local myargs `myargs' name(`kind')
	}	
	if `checkdesc'>0 {	
		local desc=`pldesc' in `i'
		local myargs `myargs' desc(`desc')
	}
	else {
		local myargs `myargs' desc(`kind')
	}		
	writeKMLPlacemark, kmlfile(`filename') `myargs'
}
// -- and finally the footer
writeKMLFooter `filename'
di "`filename' written to `c(pwd)'"

end

// set locals
capture prog drop setKMLLocals
program setKMLLocals, rclass

version 9.0

return local lilpaddles "http://www.google.com/intl/en_us/mapfiles/ms/micons/"
return local bigpaddles "http://maps.google.com/mapfiles/kml/paddle/"

end

// write style corresponding to a paddle color,
// which in turn corresponds to a given kind of mapped
// object (e.g. coffee shop, gas station) as defined
// in the writeKMLFile wrapper.
capture prog drop writeKMLStyle
program writeKMLStyle

version 9.0

args color filename
setKMLLocals
local path `r(lilpaddles)'

tempname fwrite
local writeto `filename'

file open `fwrite' using `writeto', write append

file write `fwrite' `"`kml_header'"' _n
file write `fwrite' `"`kml_open'"' _n
file write `fwrite' "`doc_open'" _n

local styleid <Style id="`color'">
local iconsrc <href>`path'`color'-dot.png</href>

file write `fwrite' _tab                 `"`styleid'"' _n
file write `fwrite' _tab _tab    			"<IconStyle>" _n
file write `fwrite' _tab _tab _tab        "<scale>1</scale>" _n
file write `fwrite' _tab _tab _tab        "<Icon>" _n
file write `fwrite' _tab _tab _tab _tab  `"`iconsrc'"' _n
file write `fwrite' _tab _tab _tab 	  		"</Icon>" _n                               
file write `fwrite' _tab _tab    			"</IconStyle>" _n
file write `fwrite' _tab         			"</Style>" _n

file close `fwrite'

end

// write a place mark, corresponding to a given style. see
// color mapping in writeKMLFile and header of writeKMLStyle
capture prog drop writeKMLPlacemark
program writeKMLPlacemark

version 9.0

syntax,  kmlfile(string) color(string) lon(real) lat(real) name(string) desc(string)

local checkname=length("`plname'")
local checkdesc=length("`pldesc'")

local styletag    <styleUrl>#`color'</styleUrl>
local nametag     <name>`name'</name>
local desctag     <description>`desc'</description>
local coordinates <coordinates>`lon',`lat',0</coordinates>

tempname fwrite
local writeto `kmlfile'

file open `fwrite' using `writeto', write append

file write `fwrite' _tab                "<Placemark>" _n
file write `fwrite' _tab                "`macval(nametag)'" _n
file write `fwrite' _tab                "`macval(desctag)'" _n	
file write `fwrite' _tab _tab           "`macval(styletag)'" _n
file write `fwrite' _tab _tab           "<Point>" _n
file write `fwrite' _tab _tab _tab      "`macval(coordinates)'" _n
file write `fwrite' _tab _tab           "</Point>" _n
file write `fwrite' _tab                "</Placemark>" _n

file close `fwrite'

end

// write kml file header
capture prog drop writeKMLHeader
program writeKMLHeader

version 9.0

local 0 `"using `0'"'
syntax using/

tempname fwrite
local writeto `using'

file open `fwrite' using `writeto', write replace

local kml_header <?xml version="1.0" encoding="UTF-8"?>
local kml_open   <kml xmlns="http://www.opengis.net/kml/2.2">
local doc_open    <Document>

file write `fwrite' `"`kml_header'"' _n
file write `fwrite' `"`kml_open'"' _n
file write `fwrite' "`doc_open'" _n

file close `fwrite'

end

// write kml file footer
capture prog drop writeKMLFooter
program writeKMLFooter

version 9.0

local 0 `"using `0'"'
syntax using/

tempname fwrite
local writeto `using'

file open `fwrite' using `writeto', write append

file write `fwrite' "</Document>" _n
file write `fwrite' "</kml>" _n

file close `fwrite'

end
