*===============================================================================
* This is scatter3.ado beta version
* Date : 13 Sept 2014
* Version : 1.1
* 
* Questions, comments and bug reports : 
* rocat@afd.fr or roca.thomas@gmail.com
*
* Version history :
* Fix machine specific issues remplacing shell xcopy by stata copy command
*===============================================================================

capture program drop scatter3D
program define scatter3D, rclass sortpreserve
version 11
syntax varlist(min=4 max=4) 			/// variable  
	using								/// filename
	[, 									/// options					
	width(integer 850)					/// Width of the map   ->[default 850px]					
	height(integer 700)					/// height of the map  ->[default 700px]
	]

	
quietly {

capture cd "`dir'"

*===============================================================================
* 	Generate folders that will host HTML, java & image files needed 
*===============================================================================
capture mkdir scatter3D
cd "`c(pwd)'/scatter3D"
capture mkdir images
capture mkdir js

*===============================================================================
*       Copy from ado directory the java & image files needed 
*===============================================================================

*List of files to copy into Scatter3D/images/.
local listImage camera.png cancel1.png canvasXpress.gif cog-add.png cog-delete.png cog-error.png cog-go.png cog.png configure_hide.png configure_show.png configure_simple_show.png data.png datatable.png disk.png find.png funnel.png funnel_cross.png green_code.png help1.png loading1.gif loading2.gif magnifier_zoom_in.png mem.png pattern1.png pattern2.png pattern3.png pattern4.png pattern5.png pattern6.png pattern7.png pattern8.png patt_art.png patt_circles.png patt_cross.png patt_cx.png patt_diag_nw_se.png patt_diag_sw_ne.png patt_hor.png patt_plus.png patt_polkadot.png patt_square.png patt_squigle.png patt_stairs.png patt_ver.png patt_ver_hor.png pin.png pixel_w.png processing.gif purple_code.png save.png simple_find.png table.png transpose.png unchecked.gif unchecked.png unpin.png

*List of files to copy into Scatter3D/js/.
local listJava app.js canvas.text.js canvas.text.min.js canvas2png.js canvasXpress.doc.js canvasXpress.gif canvasXpress.js canvasXpress.min.js canvasXpress.public.min.js canvas_wrapper.js canvas_wrapper.min.js color-field.js date.format.js date.format.min.js excanvas.js ext-canvasXpress.js Ext.ux.SearchWindow.js extext.js flash10canvas.swf flash9canvas.swf flashcanvas.js gentilis_regular.typeface.js helvetiker_regular.typeface.js optimer_regular.typeface.js sprintf.js sprintf.min.js tableXpress.js

*Search for scatter3D.ado and store its path
findfile scatter3D.ado, all
local folder=subinstr(`"`r(fn)'"',"scatter3D.ado","",.)

*Copy the image files needed 
foreach file in `listImage' {
capture copy `folder'/scatter3D/images/`file' images/`file'
}

*Copy the js files needed 
foreach file in `listJava' {
capture copy `folder'/scatter3D/js/`file' js/`file'
}
*store directory
capture local dir=subinstr(`"`c(pwd)'"',"/scatter3D","",.) 		// unix
capture local dir=subinstr(`"`c(pwd)'"',"\scatter3D","",.)  	// windows

*===============================================================================
*      Set parameters 
*===============================================================================

*Store the filename
gettoken ucmd filename : using 
local         filename `filename'

*Store var1 and var2 one of them is the iso3 coutry code (string) the other is a number
local Y: word 1 of `varlist'
local X: word 2 of `varlist'
local Z: word 3 of `varlist'
local ID: word 4 of `varlist'

*Make sure `ID' is string
tempvar id  // Generate a temp. variable & test if ID is a string, otherwise convert it
gen `id'=`ID'
capture tostring `id', replace

*Set Canvas dimension
if missing("`width'") local width=850
if missing("`height'") local height=700

*erase previous handle if any
capture erase "`filename'"

*Save variable labels
local labelX="`: var label `X''"
local labelY="`: var label `Y''"
local labelZ="`: var label `Z''"

*display default variable label if not existing
if missing("`labelX'") local labelX="Variable X"
if missing("`labelY'") local labelY="Variable Y"
if missing("`labelZ'") local labelZ="variable Z"

*count the observations, use tab instead of summ id is now a string for sure!
qui tab `id'
local obs=`r(N)'

*fix common cname problem
replace `id'="Ivory coast" if `id'=="Cote d`Ivoire" 
replace `id'="Ivory coast" if `id'=="Cote d'Ivoire" 


*===============================================================================
*       					Module to save all the scores
*===============================================================================
forval v=1/`obs' {

local ID_`v'=`id'[`v'] 						 // save individual id name
levelsof `X' in `v', local(X_`v')			 // save X id name
levelsof `Y' in `v', local(Y_`v')
levelsof `Z' in `v', local(Z_`v')

local nodata_`v'=0
if "`ID_`v''"=="" local  nodata_`v'=1	
if "`X_`v''"==""   local nodata_`v'=1	
if "`Y_`v''"==""   local nodata_`v'=1	
if "`Z_`v''"==""   local nodata_`v'=1
}

*===============================================================================
*									Writing HTML
*===============================================================================

tempname page
file open `page' using "page", r w
file write `page' ///
`"            <html>																											"' _n /// 
`"             <head>																											"' _n /// 
`"                <!--[if lt IE 9]><script type="text/javascript" src="./js/flashcanvas.js"></script><![endif]-->				"' _n /// 
`"                <script type="text/javascript" src="./js/canvasXpress.min.js"></script>										"' _n /// 
`"                <script id='demoScript'>																						"' _n /// 																			
`"                  var showDemo = function () {																				"' _n /// 
`"                    var cx1 = new CanvasXpress('canvas1',	  {	  'y' : {														"' _n /// 
`"                          'vars' : [																							"' _n
			  
		
forval v=1/`obs'{
if `nodata_`v''==0  file write `page' `" "`ID_`v''",  "' _n
}
file write `page' `"   " " ],  "' _n
file write `page' 	`"  'smps' : [' X:`labelX' ', ' Y:`labelY' ', ' Z:`labelZ' '],  	"' _n
file write `page' 	`"  'data' : [		  				"' _n
   
forval v=1/`obs'{
if `nodata_`v''  ==0  file write `page'  	`" 		[`X_`v'', `Y_`v'', `Z_`v''], 	  "' _n
}
file write `page' `" [ , , ] "' _n   
file write `page' 	`" ]  } }, {'graphType': 'Scatter3D', "' _n
file write `page' 	`"          'xAxis': ['`labelX''], 'yAxis': ['`labelY''], 'zAxis': ['`labelZ'']} ); }  "' _n
  
 file write `page' ///
`"	</script> </head>										 			"' _n ///
`"    <body onload="showDemo();">       								"' _n ///
`"	  <div id="Scatter3D">												"' _n ///
`"   <canvas id='canvas1' width='`width'' height='`height''></canvas>	"' _n ///
`"   </div>	 															"' _n ///
`"   </body> </html>													"' _n ///
  
*===============================================================================
file close `page'
capture erase "`filename'"
capture !rename  "page"  "`filename'"			// windows
capture !mv  "page"  "`filename'"			    // unix
capture erase "page"
noisily di as text "....."
noisily di as text "Open output web page: " `"{browse  "`c(pwd)'/`filename'"}"' // for windows

cd "`dir'"

} // end of quietly command


end

