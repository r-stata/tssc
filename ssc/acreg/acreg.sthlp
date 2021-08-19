{smcl}


{viewerjumpto "Syntax" "acreg##syntax"}{...}
{viewerjumpto "Menu" "acreg##menu"}{...}
{viewerjumpto "Description" "acreg##description"}{...}
{viewerjumpto "Options" "acreg##options"}{...}
{viewerjumpto "Examples" "acreg##examples"}{...}
{viewerjumpto "Stored results" "acreg##results"}{...}
{viewerjumpto "References" "acreg##references"}{...}

{title:Title}

{p2colset 5 22 24 2}{...}
{p2col :{bf:acreg} {hline 1}} Arbitrary Correlation Regression {p_end}
{p2colreset}{...}



{marker description}{...}
{title:Description}

{pstd}
{cmd:acreg}  computes standard errors corrected for arbitrary cluster correlation in spatial and network settings.
It implements a range of error correction methods for linear regression models: OLS and 2SLS. {hline 1} F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:acreg} {depvar} [{it:{help varlist:varlist1}}]
[{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
        {it:{help varlist:varlist_iv}}{cmd:)} {ifin}]
[{it:{help weight:fweight pweight}}]
[{cmd:,} {bf:id}({it:idvar}) {bf:time}({it:timevar}) 
{bf:spatial} {bf:network}  
{bf:latitude}({it:latitudevar}) {bf:longitude}({it:longitudevar}) 
{bf:links_mat}({it:varlist_links})  {bf:dist_mat}({it:varlist_distances})
{bf:dist}({it:distcutoff}) {bf:lag}({it:timecutoff}) 
{bf:weights}({it:varlist_weights})  {bf:cluster}({it:varlist_cluster}) 
{bf:hac} {bf:bartlett} {bf:nbclust}({it:n_clusters})  
{bf:pfe1}({it:fe1var})  {bf:pfe2}({it:fe2var}) {bf:correctr2} {bf:dropsingletons}       
  {bf:storeweights}
{bf:storedistances}]

{phang}
{it:depvar} is the dependent variable.{p_end}

{phang}
{it:varlist1} is the list of exogenous variables.{p_end}

{phang}
{it:varlist2} is the list of endogenous variables.{p_end}

{phang}
{it:varlist_iv} is the list of exogenous variables used with {it:varlist1}
   as instruments for {it:varlist2}.


{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{dlgtab:Panel}

{synopt :{opt idvar}} is the unique identifier, required in panel database. {p_end}

{synopt :{opt timevar}} is the time unit variable, required in panel database. {p_end}

{dlgtab: Spatial Environment}

{synopt:{opt spatial}} specifies that the environment is a spatial environment,
{it:not required if no arbitrary cluster correction and if varlist_weights or varlist_cluster or network option is specified}.{p_end}

{synopt:{opt + latitudevar}} is the variable containing the latitude of each observation, decimal degrees: range[-180,180].{p_end }

{synopt:{opt + longitudevar}} is the variable containing the longitude of each observation, decimal degrees: range[-180,180].{p_end }

{synopt:{opt # varlist_distances}} is the list of N variables containing bilateral distances between observations. 
In the spatial environment, bilateral distance is the spatial distance between observations, i.e., physical distance between two locations (in the network environment, it is the network distance between observations, i.e., the number of links along the shortest path between two nodes).
{p_end }

{synopt:{opt distcutoff}} specifies the distance cutoff in kilometers beyond which the correlation between error term of two observations is assumed to be zero,
{it: required if latitude and longitude are specified or dist_mat is specified}. The distance cutoff is in kilometers if
latitude and longitude are specified. It can be in any other meaningful metric if bilateral distances are specified. {p_end }

{synopt:{opt timecutoff}} specifies the time lag for observations with the same {bf: idvar},
{it: not required in cross-sectional environment, default in panel environment is 0, i.e. when id and time are specified.}
In {it: panel environment} when {it: timecutoff} is 0, or not specified, Standard Errors are automatically clustered at id-x-time cell level. {p_end }

{dlgtab: Network Environment}

{synopt:{opt network}} specifies that the environment is a network environment, 
{it:not required if no arbitrary cluster correction and if varlist_weights or varlist_cluster or spatial option is specified}.{p_end }

{synopt:{opt * varlist_links}} is the list of N dummy variables specifying the links between observations, i.e., the adjacency matrix. If distcutoff>1 only the first  observation in time of each individual will be used as input to compute the bilateral distance between two nodes. {p_end }

{synopt:{opt # varlist_distances}} is the list of N variables containing bilateral distances between observations. 
In the network environment, bilateral distance is the network distance between observations, i.e., the number of links along the shortest path between two nodes (in the spatial environment, it is the spatial distance between observations, i.e., physical distance between two locations).
{p_end }

{synopt:{opt distcutoff}} specifies the distance cutoff (geodesic paths) beyond which the correlation between error term of two observations is assumed to be zero,
{it: required if dist_mat is specified, optional if links_mat is specified, default is 1}. When {it: links_mat} is specified and {it: distcutoff} is grerater than 1, acreg will automatically computes the bilateral distance between two nodes. {p_end }

{synopt:{opt timecutoff}} specifies the time lag for observations with the same {bf: idvar},
{it: not required in cross-sectional environment, default in panel environment is 0, i.e. when id and time are specified.}
In {it: panel environment} when {it: timecutoff} is 0, or not specified, Standard Errors are automatically clustered at id-x-time cell level.{p_end }

{dlgtab: Multiway Clustering Environment}

{synopt:{opt varlist_cluster}} is the list of variables to use for multy-way clustered SEs, 
{it: not required if no arbitrary cluster correction and if the option spatial or the option network or varlist_weights is specified}.{p_end }

{dlgtab: Arbitrary Clustering Environment}

{synopt:{opt varlist_weights}} is the list of NxT variables containing the weights that will be used for error correction, 
{it: not required if no arbitrary cluster correction and if the option spatial or the option network or varlist_cluster is specified}. The NxT variables need to follow the same order of the observations.{p_end }

{dlgtab: Correlation Structure}

{synopt:{opt hac}} reports Heteroskedastic and Autocorrelation Corrected (HAC) standard errors; lagcutoff will be the temporal decay;
{it: requires id, time and lagcutoff}.{p_end }

{synopt:{opt bartlett}} imposes a distance linear decay between observations within the cutoff in the correlation structure. {p_end }

{synopt:{opt n_clusters}} is the number of clusters used to compute the Kleibergen-Paap statistic in case of cluster correction. Default is 100. {p_end }



{dlgtab: High Dimensional Fixed Effects (partial out)}

{synopt:{opt fe1var}} identification of the first high dimensional fixed effects variable. {p_end }

{synopt:{opt fe2var}} identification of the second high dimensional fixed effects variable.{p_end }

{synopt:{opt correctr2}} when pfe1 or pfe2 are specified the r-squared is computed on the "partialled out sample". This option reports the correct r-squared, i.e. the pre-partialling out r-squared. {it: not allowed with fweights}.{p_end }

{synopt:{opt dropsingletons}} drop singleton groups when pfe1 or pfe2 are specified. {p_end }

{dlgtab: Storing}

{synopt:{opt storeweights}} stores the computed weights used to correct the VCV for arbitrary cluster correlation as a matrix under the name {it: weightsmat}, which may be used as input for the option {bf:varlist_weights}, 
{it: only if the option spatial or the option network or varlist_cluster is specified}.{p_end }

{synopt:{opt storedistances}} stores the computed distances used to correct the VCV for arbitrary cluster correlation as a matrix under the name {it:distancesmat}, which may be used as input for the option {bf:varlist_distances}, 
{it: only if the option spatial or the option network is specified and {bf:varlist_distances} is not specified}.{p_end }


{synoptline}
{pstd}Notes:{p_end }
{pstd}{bf: distcutoff} may be integer or float. {bf:TIMEcutoff} has to be integer.{p_end }

{pstd}+ These options have to be specified when {bf:spatial} is specified and {bf:varlist_distances} is not specified.{p_end }

{pstd}* This option has to be specified when {bf:network} is specified and {bf:varlist_distances} is not specified.{p_end }

{pstd}# This option may be specified only when {bf:spatial} is pecified and {bf:latitudevar} and {bf:longitudevar} are not specified, or when {bf:network} is specified and {bf:varlist_links} is not specified.{p_end }

{pstd}   acreg uses some functions from the following external pakages: ivreg2, ranktest, hdfe. To install these packages please type {bf: acregpackcheck} after having installed the program. {p_end }
{p2colreset}{...}


{marker examples}{...}
{title:Examples}


{pstd} Please find some examples below, for additional examples please visit the page {it: https://acregstata.weebly.com/} {p_end}


{dlgtab: Spatial Environment}


{smcl}
{pstd}Setup - load spatial database {p_end}
{phang2}{cmd}{stata "webuse homicide_1960_1990.dta":. webuse homicide_1960_1990.dta} {p_end}

{txt}{...}
{pstd}Fit a regression via 2SLS, with no cluster correction - robust standard errors {p_end}
{phang2}{cmd}{stata "acreg  hrate ln_population age (ln_income=unemployment)":. acreg  hrate ln_population age (ln_income=unemployment)} {p_end}

{txt}{...}
{pstd}Fit a regression via 2SLS, using Longitude and Latitude as input - cross section {p_end}
{phang2}{cmd}{stata "acreg hrate ln_population age (ln_income=unemployment),  latitude(_CX) longitude(_CY)  dist(50)  spatial":. acreg hrate ln_population age (ln_income=unemployment),  latitude(_CX) longitude(_CY)  dist(50)  spatial} {p_end}

{txt}{...}
{pstd}Fit a regression via 2SLS, using Longitude and Latitude as input - panel,  no hac {p_end}
{phang2}{cmd}{stata "acreg hrate ln_population age (ln_income=unemployment),  id(_ID) time(year) latitude(_CX) longitude(_CY)  dist(50) lag(50)  spatial":. acreg hrate ln_population age (ln_income=unemployment),  id(_ID) time(year) latitude(_CX) longitude(_CY)  dist(50) lag(50)  spatial} {p_end}

{txt}{...}
{pstd}Fit a regression via 2SLS, using Longitude and Latitude as input - panel, hac {p_end}
{phang2}{cmd}{stata "acreg hrate ln_population age (ln_income=unemployment),  id(_ID) time(year) latitude(_CX) longitude(_CY)  dist(50) lag(50)  spatial  hac ":. acreg hrate ln_population age (ln_income=unemployment),  id(_ID) time(year) latitude(_CX) longitude(_CY)  dist(50) lag(50)  spatial  hac } {p_end}
{txt}{...}



{dlgtab: Network Environment}

{smcl}
{pstd}Setup - load network database - Grund and Densley (2012) {p_end}
{phang2}{cmd}{stata "ssc desc acreg":. ssc desc acreg} {p_end}
{phang2}{cmd}{stata "net get acreg":. net get acreg} {p_end}
{phang2}{cmd}{stata "use nwexample.dta":. use nwexample.dta}{p_end}

{txt}{...}
{pstd}Fit a regression via OLS, with no cluster correction - robust standard errors {p_end}
{phang2}{cmd}{stata "acreg Arrests Ranking Age Residence i.Birthplace":. acreg Arrests Ranking Age Residence i.Birthplace}{p_end}

{txt}{...}
{pstd}Fit a regression via OLS, cluster correction {p_end}
{phang2}{cmd}{stata "acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) dist(1)":. acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) dist(1)}

{txt}{...}
{pstd}Fit a regression via OLS, cluster correction ut to second degree {p_end}
{phang2}{cmd}{stata "acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) dist(2)":. acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) dist(2)}{p_end}


{marker results}{...}
{title:Stored results}
{synoptset 13 tabbed}{...}

{syntab: {bf:acreg} stores the following in e():}

{syntab: Scalars}
{synopt: {bf:e(N)}} number of observations {p_end }
{synopt: {bf:e(mss)}} model sum of squares (centered) {p_end }
{synopt: {bf:e(mssu)}} model sum of squares (uncentered) {p_end }
{synopt: {bf:e(rss)}} residual sum of squares {p_end }
{synopt: {bf:e(tss)}} total sum of squares (centered) {p_end }
{synopt: {bf:e(tssu)}} total sum of squares (uncentered) {p_end }
{synopt: {bf:e(r2)}} centered R2 (1-rss/tss) {p_end }
{synopt: {bf:e(r2u)}} uncentered R2 {p_end }
{synopt: {bf:e(widstat)}} Kleibergen-Paap rk Wald F statistic {p_end }

{syntab: Matrices}
{synopt: {bf:e(b)}} coefficient vector {p_end }
{synopt: {bf:e(V)}} corrected variance-covariance matrix of the estimators {p_end }

{syntab: Functions}
{synopt: {bf:e(sample)}} marks estimation sample {p_end }



{marker installation}{...}
{title:Installation}

{pstd}To install the package, please type the following in the Stata command window or download and run the ado files below:{p_end}
{phang2}{cmd:. ssc install acreg}{p_end}

{pstd}To erase the package please type the following in the Stata command window:{p_end}
{phang2}{cmd:. ado uninstall acreg }{p_end}


{marker references}{...}
{title:References}

{marker CLST2019}{...}

{pstd}Colella, Fabrizio; Lalive, Rafael; Sakalli, Seyhun Orcan; Thoenig, Mathias. (2019) Inference with Arbitrary Clustering, IZA Discussion Paper n. 12584 {p_end}

{marker CLST-STATA2020}{...}

{pstd}Colella, Fabrizio; Lalive, Rafael; Sakalli, Seyhun Orcan; Thoenig, Mathias. (2020) Acreg: arbitrary correlation regression. {p_end}


{synoptline}
{marker VERSION}{...}
{pstd}This Version: December 2020  (1.1.0) {p_end}






