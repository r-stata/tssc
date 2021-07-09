{smcl}
{* December 2008}{...}
{* Updated March 2012}{...}

{hline}
{cmd:help for spwmatrix} 
{vieweralsosee "nearstat" "help nearstat"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "anketest" "help anketest"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "spmlreg" "help spmlreg"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "splagvar" "help splagvar"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "spseudor2" "help spseudor2"}{...}
{viewerjumpto "Syntax" "spwmatrix##syntax"}{...}
{viewerjumpto "Description" "spwmatrix##description"}{...}
{viewerjumpto "Options" "spwmatrix##options"}{...}
{viewerjumpto "Examples" "spwmatrix##examples"}{...}
{viewerjumpto "Author information" "spwmatrix##author"}{...}
{viewerjumpto "Citation" "spwmatrix##citat"}{...}

{hline}

{title:Title}

{p 2 8 2}
{bf:spwmatrix --- Generates, imports, and exports spatial weights}

{marker contents}{dlgtab: Table of Contents}
{p 2 16 2}

{p 2}{bf:Click on the "Jump To" link at the top right corner.}

{hline}

{marker syntax}{title:Syntax}

Import first order contiguity spatial weights from ArcGIS (SWM file) and GeoDa (GAL file) or spatial weights from a dta or 
a text file

{phang}
{cmd: spwmatrix} {it:import} {helpb using} {it:filename}{cmd:,} {opt wn:ame(wght_name)}  
[{opt dta text} {opt swm(idvar_name)} {help spwmatrix##other_options:Other_options}]

Generate geographic and economic distance-based spatial weights using latitude and longitude

{phang}
{cmd: spwmatrix} {it:gecon} {varlist} [{help if}] [{help in}]{cmd:,} {opt wn:ame(wght_name)} [{opt wt:ype(bin|inv|econ|invecon)} 
	{opt cart} {opt r(#)} {opth db:and(numlist)} /// {p_end}  
	 {opt alpha(#)} {opt knn(#)} {cmd:econvar({varname:1})} {opt beta(#)} {help spwmatrix##other_options:Other_options}] 

Generate social network and socio-economic spatial weights

{phang}
{cmd: spwmatrix} {it:socio} {varname:2} [{help if}] [{help in}]{cmd:,} {opt wn:ame(wght_name)} 
	{opt wt:ype(socnet|socecon)} [{cmd:idvar({varname:3})} {opt dt:hres(#)} {opt g:amma(#)} /// {p_end}
	 {opt snn(#)} {cmd:dmins(}{newvar:1}{cmd:)} {help spwmatrix##other_options:Other_options}] 

{phang}
where {it:import, gecon, and socio} are sub-commands. 

{synoptset 32 tabbed}
{synopthdr}
{marker options}
{synoptline}
{syntab:{help spwmatrix##main_options:Main Options}}   
     
{synopt :{opt wn:ame(wght_name)}}indicate the name of the spatial weights matrix to be generated{p_end}

{synopt :{opt wt:ype(bin|inv|econ|invecon|socnet|socecon)}}request binary, distance decay, economic distance, inverse economic distance,
social network, or socio-economic spatial weights{p_end}

{synopt :{opt dta}}import spatial weights from a dta file{p_end}

{synopt :{opt text}}import spatial weights from a comma or tab delimited text file{p_end}

{synopt :{opt swm(idvar_name)}}import spatial weights generated in ArcGIS{p_end}

{synopt :{opt alpha(#)}}indicate the value of the dampening parameter; default is {opt alpha(1)}{p_end}

{synopt :{opth db:and(numlist)}}indicate the distance band or cut-off{p_end}

{synopt :{opt cart}}use Cartesian coordinates (projected latitudes and longitudes){p_end}

{synopt :{opt r(#)}}indicate the earth radius value to be used in case of spherical coordinates; 
default is r(6371.009), i.e. 6371.009 km{p_end}

{synopt :{opt knn(#)}}request nearest neighbor spatial weights{p_end}

{synopt :{cmd: econvar({varname:1})}}request economic or inverse economic distance spatial weights{p_end}

{synopt :{opt beta(#)}}specify the coefficient beta for the exponential function; default {opt beta(1)}{p_end}

{synopt :{cmd:idvar({varname:3})}}specify the identifier variable{p_end}

{synopt :{cmdab:dth:res(#)}}set an absolute difference threshold 
 
{synopt :{cmdab:g:amma(#)}}set the dampening parameter, in reminiscence to alpha 
 
{synopt :{cmd:snn(#)}}generate socio-economic spatial weights based on the first # smaller absolute differences 

{synopt :{cmd:dmins({newvar:1})}}generate a variable containing the minimum absolute difference for each observation

{marker other_options}
{synoptline}
{syntab:{help spwmatrix##oth_options:Other Options}} 

{synopt :{opt xtw(#)}}generate spatial weights to be used with a balanced panel dataset{p_end}

{synopt :{opt m:ataf}}save the spatial weights matrix and/or its eigenvalues to Mata file(s){p_end}

{synopt :{opt external}}make the spatial weights reside in Mata memory{p_end}

{synopt :{opt eignv:al(eignv_name)}}place the eigenvalues of the spatial weights matrix into a column vector{p_end}

{synopt :{cmd:eignvar({newvar:2})}}generate a variable to hold the eigenvalues of the spatial weights matrix{p_end}

{synopt :{opt nois:land}}remove observations with no neighbors when generating the spatial weights{p_end}

{synopt :{opt row:stand}}row-standardize the spatial weights matrix{p_end}

{synopt :{opt con:nect}}display connectivity information about the spatial weights matrix{p_end}

{synopt :{opt xport(wght_filename, filetype)}}export the spatial weights matrix to a .dat, .txt, or a .gwt file{p_end}
		where {it:filetype=dat|txt|gwt}

{synopt :{opt replace}}overwrite existing {newvar:1}, {newvar:2}, and {it:wght_filename} as well as {it:wght_name} and {it:eignv_name}
		                      if {opt mataf} specified{p_end}

{synopt :{opt favor(speed|space)}}favor speed or space{p_end}

{synoptline}
{p2colreset}{...}

{marker description}{dlgtab:Description}

{pstd}
{cmd:spwmatrix} generates geographic distance based spatial weights and economic distance spatial weights based on an economic variable 
(see Fingleton and Le Gallo, 2008) and social network and socio-economic spatial weights based on a 
socio-economic variable (see Anselin and Bera, 1998). {cmd:spwmatrix} also imports pre-generated contiguity spatial weights 
from ArcGIS (SWM file) and GeoDa (GAL file) or spatial weights from a .dta or a text (csv or tab delimited) file. Optionally, 
created and imported spatial weights are exported to a .dat file for use in Matlab. Created spatial weights may also be exported 
to a .gwt file for use in GeoDa. Ultimately, the requested spatial weights are delivered as a matrix loaded in Stata memory 
(Stata object), as a matrix residing in Mata memory (Mata object), or as a permanent Mata file. When creating distance-related 
spatial weights, {cmd:spwmatrix} uses either the straight-line (crow-fly) Euclidean distance or the Great Circle distance 
depending on whether the latitudes and longitudes supplied in {varlist} are projected or not. 

{pmore}{bf:spwmatrix} requires at least Stata 12.0{p_end}

{marker main_options}{dlgtab:Main Options}

{phang}
{opt wname(wght_name)} specifies the name of the spatial weights matrix to be generated. This option is required.

{phang}
{opt wtype(bin|inv|econ|invecon|socnet|socecon)} indicates whether binary, distance decay, economic distance, inverse economic distance,
social network, or socio-economic spatial weights should be created.

{pmore}Refer to the literature cited below for a background on these spatial weights, except for inverse economic distance spatial 
weights which are defined as:

{pmore2}{bf:W_ij = [1/|econvar_i - econvar_j +1|] * exp(-beta*D_ij) (1)} , where {it:D_ij} is the distance between location {it:i} and location {it:j}

{phang}
{opt dta} specifies that the spatial weights matrix to be imported is from a Stata .dta file. 

{phang}
{opt text} specifies that the spatial weights matrix to be imported is from a comma or tab delimited text file instead of the 
default .gal file. The text file may or may not contain a header row with variable names. Although {cmd:spwmatrix} can determine for itself 
whether a file is comma or tab delimited, it is recommended that the file name be specified with extension .csv or .txt. The same goes for 
a .gal file.  

{phang}
{opt swm(id_varname)} indicates the name of the unique id variable (field) supplied to ArcGIS at the time of creation of the spatial weights matrix. 
For more details on how to generate spatial weights in ArcGIS 9.3, click 
{browse "http://webhelp.esri.com/arcgisdesktop/9.3/index.cfm?TopicName=Generate_Spatial_Weights_Matrix_%28Spatial_Statistics%29":here} 
and in ArcGIS 10, click {browse "http://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#/Generate_Spatial_Weights_Matrix/005p00000020000000/":here}.
After generating the spatial weights matrix, you must use the {bf:Convert Spatial Weights Matrix To Table} script from the {bf:Utilities} toolbox 
to convert the spatial weights matrix to a table. This process will generate a dbf file. For more details, click 
{browse "http://help.arcgis.com/en/arcgisdesktop/10.0/help/index.html#/Convert_Spatial_Weights_Matrix_to_Table/005p0000003t000000/":here}.
The dbf table will be added to the table of contents. Finally from ArcGIS, export the dbf table to a text (.csv) file. That .csv file can be imported 
by {cmd:spwmatrix}. Should you need that the eigenvalues be computed, instead of ArcGIS, let {cmd:spwmatrix} row-standardize the spatial weights.  

{pmore}
If none of {opt dta}, {opt text}, and {opt swm()} is specified, a .gal file from GeoDa will be assumed when the sub-command {bf:import} is invoked.

{pmore}
{bf:Stop:} When the {bf:import} subcommand is invoked, {bf:spwmatrix} assumes the dataset to carry the analysis is loaded and the user is 
importing the spatial weights to proceed. The sort order for the observations used when you created the weights matrix must be the same for 
the dataset. Otherwise, you will muck up the spatial relationship defined by the spatial weights matrix.
 
{phang}
{opt alpha(#)} specifies the value to be used for the dampening parameter when requesting inverse distance spatial weights.
If {opt wtype(inv)} is specified, the default will be {opt alpha(1)}. Specifying {opt alpha(2)} requests inverse distance squared spatial 
weights. 

{phang}
{opth dband(numlist)} indicates the distance cut-off to be used. Beyond this cut-off, no spatial autocorrelation is assumed. This option is required 
when option {opt wtype(bin)} is specified. Following the literature (see Boarnet et al., 2006), option {opt dband(numlist)} is not required when 
an inverse distance weights matrix is requested. When {opth dband(numlist)} is specified, by default, the distance unit is assumed to be 
kilometers, but that can be overridden with {opt cart} or {opt r(#)}. 

{phang}
{opt cart} indicates that the latitudes and longitudes supplied in {varlist} are projected and that, in generating the spatial weights, Euclidean or 
crow-fly distance should be calculated. By default, the Great Circle distance is calculated. For more details, see the help file for {helpb nearstat}. 

{phang}
{opt r(#)} indicates the value to be used for the Earth radius or mean radius in case of spherical coordinates. 
The Earth radius usually refers to various fixed distances and to various mean radii since only a sphere has a true radius. 
Fortunately, the numerical differences among different radii vary by far less than one percent, making the choice of {bf:#}
less of a concern.

{pmore}{bf:N.B.:} As indicated above, by default, the distance unit for {opth dband(numlist)} is assumed to be kilometers. If you want the unit to 
be miles, then you must specify {opt r(3958.761)}. 

{pmore}Options {opt r(#)} and {opt cart} may not be combined.

{phang}
{opt knn(#)} requests nearest neighbor spatial weights and indicates the number of nearest neighbors to be used. 
Option {opt knn(#)} may not be combined with either {opt wtype()} or {opt dband()}. 

{phang}
{cmd:econvar({varname:1})} specifies the name of the economic variable to be used in creating economic or inverse economic distance spatial weights. 

{phang}
{opt beta(#)} specifies the value to be used for the beta coefficient. The default is {opt beta(1)}. You might want to choose # so that 
the spatial weights matrix does not contain any rows with elements summing up to zero (the number of neighbors for each areal unit should 
be at least one).  

{phang}
{cmd:idvar({varname:3})} specifies the identifier variable with values varying from 1 to N, with N being the total number of observations. This option is 
required when you specify {opt wtype(socnet)} to request a social network spatial weights matrix. The variable holding the groups or the networks 
should be supplied with {varname:2}. For instance, you can generate spatial weights based on the idea that two households are considered neighbors 
if they belong to the same village. In this case, {varname:3} would contain the household identification numbers and {varname:2} would take on the 
village names or identification numbers. If your identifier variable does not vary from 1 to N, assuming your dataset is in the correct sort order, 
you can easily generate one that does by coding:

{pmore}{cmd:. gen myidvar=_n}

{phang}
In a social network spatial weights matrix, the elements are defined as:

{pmore2}{bf:W_ij = 1 if {hi:{bf:i}} and {hi:{bf:j}} are neighbors and W_ij =0 otherwise (2)} 
 
{pmore}In the case of socio-economic spatial weights requested by specifying {opt wtype(socecon)}, {varname:2} could be the name of the socio-economic 
variable. The elements of the spatial weights matrix in this instance are defined by:

{pmore2}{bf:W_ij = [1/(diff_ij + 1)], where diff_ij=abs({varname:2}_i - {varname:2}_j) (3)}

{phang}
{opt dthres(#)} specify an absolute difference threshold beyond which no spatial autocorrelation is assumed. In this case, {bf:equation (3)}
 becomes:

{pmore2}{bf:W_ij = [1/(diff_ij + 1)] if diff_ij<=dthres and W_ij =0 otherwise (4)}
 
{phang} 
{opt gamma(#)} specify a dampening parameter, in reminiscence to {bf:alpha()} in the case of distance based weights matrix. The elements of the weights 
matrix are now defined as:
 
{pmore2}{bf:W_ij = [1/(diff_ij + 1)^gamma] if diff_ij<=dthres and W_ij =0 otherwise (5)}

{phang} 
{opt snn(#)} generate socio-economic spatial weights based on the first {bf:snn} smaller absolute differences in a manner similar to
{opt knn(#)}. In contrast to {opt knn(#)}, {opt snn(#)} may be combined with {opt wtype()}. 

{phang}
{cmd:dmins({newvar:1})} generate a variable containing the minimum absolute difference for each observation. This option may be helpful 
in setting {opt dthres(#)}. The maximum of those minimums will guarantee at least one neighbor.

{marker oth_options}{dlgtab:Other Options}

{phang}
{marker xtw}{opt xtw(#)} specifies the number of time periods (T) to generate spatial weights to be used with a balanced panel data. This option 
assumes that the dataset is sorted by {bf:time} and {bf:geoid} and that the data for one is time period is kept to generate the spatial weights.
{bf:geoid} is considered to be the identifier variable for the areal units.

{phang}
{marker mataf}{opt mataf} requests that the spatial weights - and its eigenvalues if {opt eignval()} is specified - be saved to permanent Mata file(s). 
By default, the spatial weights matrix and its eigenvalues are created as Stata matrices temporarily loaded in memory. However, if the size of the 
spatial weights matrix to be created or imported exceeds the {help matsize} limit of your Stata flavor and option {opt mataf} is not specified, the 
spatial weights matrix and its eigenvalues will automatically be saved to Mata files. In such a case, the names supplied with options {opt wname()} 
and {opt eignval()} will be suffixed with "_n" to avoid replacing existing files. For instance, if you specify {opt wname(mywght)}, then the Mata 
file {it:mywght_n} will be created.

{pmore}{bf:N.B.:} Unless your goal is to generate a spatial weights matrix to be used with {cmd:spatreg}, in which case you should also specify 
{opt eignval()}, I recommend specifying option {opt mataf} always.

{phang}
{opt external} requests that the spatial weights matrix be stored as a Mata object residing in Mata memory.

{phang}
{opt eignval(eign_name)} specifies that the spatial weights matrix eigenvalues be written to the {it:N x 1} vector or file {it:eign_name}. 

{phang}
{marker eigv}{cmd: eignvar({newvar:2})} specifies the name of a variable to hold the eigenvalues. This option must be specified if the spatial 
weights matrix to be generated will be used to estimate spatial models using the {help spmlreg} command. 

{pmore}{bf:N.B.:} Before you specify the {bf:eignvar()} option, be sure that the number of observations in your loaded dataset is the same as
the number of rows or columns in your spatial weights matrix. Otherwise, Stata will respond with a conformability error message.

{phang}
{opt noisland} requests that island observations be removed so that the spatial weights matrix does not contain rows/columns with elements
summing up to zero. Note that {bf:spwmatrix} does not delete those observations from the dataset. Rather, it simply lists them so that their
deletion remains at the sole discretion of the user.

{pmore}{bf:N.B.:} When option {bf:eignvar()} is specified, if one of {bf:xtw()} and {bf:noisland} is  also specified, then the eigenvalue variable 
will be saved to a file and placed into the current directory. The file name will be the same as the name specified for the eigenvalue variable. An existing 
file with the same name will be overwritten. The eigenvalue variable can be added to the estimation dataset by coding:

{pmore}{bf:. merge 1:1 _n using {it:filename}}

{phang}
{marker rowst}{opt rowstand} requests that the spatial weights matrix be row-standardized. {cmd:spwmatrix} will deny this request if elements of at least one 
row sum up to zero. When this is the case, the indexes of such rows will be displayed, pointing to the observations with no neighbors.

{phang}
{opt connect} requests that connectivity information such as sparseness, minimum and average number of neighbors, etc... for the generated 
spatial weights matrix be displayed. Specifying this option is heartily recommended specifically when option {bf:beta(#)} is specified. If the minimum number 
of neighbors is zero, then you need to adjust your criteria.

{phang}
{opt xport(wght_filename, filetype)} specifies that the spatial weights matrix (generated or imported) be written to the text file with 
.dat format for use in Matlab, a .txt format for use with other Stata commands, or a .gwt format for other packages. Prior to using the 
.gwt file in GeoDa, a header line containing 0, the number of observations, name of a shapefile, and the key variable should be inserted. 
This can be done in Notepad. To use the .dat file in Matlab, you code:

{pmore}{bf: load wght_filename.dat;}

{pmore}{bf: W=wght_filename(:,:);}

{phang}
{opt replace} overwrites existing {newvar:1}, {newvar:2}, and {it:wght_filename} as well as {it:wght_name} and {it:eign_name} if {opt mataf} is specified.

{phang}
{opt favor(speed|space)} instructs {cmd:spwmatrix} to favor speed or space when performing all calculations.
{opt favor(speed)} is the default. This option provides a trade-off between speed and memory use. See {help mata_set:[M-3] mata set}.

{marker examples}{dlgtab:Examples}

{phang}
1) Create a row-standardized binary spatial weights matrix assuming spherical coordinates and a distance cut-off of 10 miles

{pmore}{cmd:. spwmatrix gecon latitude longitude, wn(wbin) wtype(bin) db(0 10) ///}{p_end}
	  {cmd:r(3958.761) row} 

{synoptline}

{phang}
2) Generate a spatial weights matrix as specified above, but save both the weights matrix and its eigenvalues to Mata files
 {it: wbin} and {it:eignwbin}, and export the weights matrix to the text file {it:wghtotxt.dat} for use in Matlab

{pmore}{cmd:. spwmatrix gecon latitude longitude, wn(wbin) wtype(bin) dband(0 10) ///}{p_end}
	  {cmd:r(3958.761) rowstand eignval(eignwbin) mataf matlab(wghtotxt)}

{synoptline}

{phang}
3) Generate an inverse distance squared spatial weights matrix using projected latitudes and longitudes

{pmore}{cmd:. spwmatrix gecon latitude longitude, wname(winvsq) wtype(inv) ///}{p_end}
	  {cmd:alpha(2) dband(0 100) cart }

{phang}
Here the distance cut-off unit is assumed to be the same as that of the projected latitudes and longitudes.

{synoptline}

{phang}
4) Generate an economic distance spatial weights matrix using employment as the economic variable

{pmore}{cmd:. spwmatrix gecon latitude longitude, wn(wecon) wtype(econ) ///}{p_end}
	  {cmd:econvar(employment) rowstand}

{synoptline}
 
{phang}
5) Generate an inverse economic distance spatial weights matrix using income as the economic variable

{pmore}{cmd:. spwmatrix gecon latitude longitude, wn(winvecon) wtype(invecon) econvar(income) rowstand}{p_end}

{synoptline}

{phang}
6) Import a first order contiguity spatial weights matrix created in GeoDa to be used in {cmd:Stata} 

{pmore}{cmd:. spwmatrix import using C:\data\wcontig.gal, wname(wcontig) rowstand}{p_end}

{phang}
As mentioned before, the .gal extension is required for {cmd:spwmatrix} to locate the file. Also, the identifier or key 
variable supplied to GeoDa when you generate a contiguity spatial weights matrix should take on values ranging 
from 1 to N, where N is the number of observations. But, the header line in the GeoDa .gal file needs not be removed.

{synoptline}

{phang}
7) Import a first order contiguity spatial weights matrix created in GeoDa and save it to a .dat file to be used in Matlab  

{pmore}{cmd:. spwmatrix import using C:\data\wcontig.gal, wname(wcontig) xport(wcontig, dat)}{p_end}

{synoptline}

{phang}
8) Generate a row-standardized 5-nearest neighbor spatial weights matrix

{pmore}{cmd:. spwmatrix gecon latitude longitude, wname(wknn5) knn(5) rowstand}{p_end}

{synoptline}

{phang}
9) Generate a socio-economic spatial weights matrix

{pmore}{cmd:. spwmatrix socio socecon_var, wname(socecon_wght) row wtype(socecon)}

{synoptline}

{phang}
10) Generate a social network spatial weights matrix (e.g., households are considered neighbors if they belong to the same village)

{pmore}{cmd:. spwmatrix socio village_id, wname(socnet_wght) wtype(socnet) idvar(hhid)}

{synoptline}

{phang}
11) Import into Stata a spatial weights matrix created in ArcGIS and save it to a Mata file  

{pmore}{cmd:. spwmatrix import using C:\data\wcontig.csv, wname(contigswm) swm(uniqid) mataf rowstand}{p_end}

	where {bf:wcontig.csv} is a file generated when exporting the converted table from ArcGIS. 
	
{synoptline}
	
{phang}
12) Import into Stata a spatial weights matrix in .csv format and save it to a Mata file. 

{pmore}{cmd:. spwmatrix import using C:\data\distspw.csv, wname(myswm_csv) mataf rowstand}{p_end}

	where {bf:distspw.csv} is a file generated by a spreadsheet. 
	
	
{marker refs}{title:References}

{bf:Anselin, L, and A. Bera}. 1998. "Spatial Dependence in Linear Regression Models with an Introduction to Spatial Econometrics." 
In A. Ullah and D.E. Giles (Eds), {it:Handbook of Applied Economic Statistics}. New York: Marcel Dekker, pp.237-89.

{bf:Boarnet MG, Chalermpong S, Geho E}. 2006 "Specification Issues in Models of Population and Employment Growth.
{it:Papers in Regional Science} 84: 21–46.

{bf:Fingleton. B. and J. Le Gallo}. 2008. "Estimating Spatial Models with Endogenous Variables, a Spatial Lag and Spatially
Dependent Disturbances: Finite Sample Properties ", {it:Papers in Regional Science} 87(3): 319-339. 

{bf:Wikipedia}. 2008. {it:Earth Radius}. {browse "http://en.wikipedia.org/wiki/Earth_radius#Mean_radii":http://en.wikipedia.org/wiki/Earth_radius#Mean_radii.}

{bf:--------} {it:Great-Circle Distance}. {browse "http://en.wikipedia.org/wiki/Great-circle_distance":http://en.wikipedia.org/wiki/Great-circle_distance}

{marker author}{title:Author}

{p 4 4 2}{hi: P. Wilner Jeanty}, The Kinder Institute for Urban research/Hobby Center for the Study of Texas, 
    	   Rice University{break}
	   
{p 4 4 2}Email to {browse "mailto:pwjeanty@rice.edu":pwjeanty@rice.edu} for any comments or suggestions.

{p 4 4 2}Note: The previous version of {cmd:spwmatrix} was written when the author was a Research Economist 
			with the Department of Agricultural, Environmental, and Development Economics, The Ohio State University.


{marker citat}{title:Citation}

Users please cite this software as follows:

{bf:Jeanty, P.W.}, 2010. {bf:spwmatrix}: Stata module to generate, import, and export spatial weights. Available from http://ideas.repec.org/c/boc/bocode/s457111.html.

{title:Also see}

{p 4 13 2}Online: {helpb nearstat}, {helpb spwmatfill}, {helpb splagvar}, {helpb anketest} (if installed) 


