{smcl}
{* *! version 1.0.0 07August 2012}{...}
{vieweralsosee "[G] graphics" "mansection G graphics"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "worldstat##syntax"}{...}
{viewerjumpto "Description" "worldstat##description"}{...}
{viewerjumpto "Options" "worldstat##options"}{...}
{viewerjumpto "Examples" "worldstat##examples"}{...}
{viewerjumpto "References" "worldstat##references"}{...}

{hline}
help for {hi:worldstat}
{hline}


{title:Title}

{p 8 20 2}
    {hi:worldstat} {hline 2} A visualisation of the state of world development



{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmdab:worldstat} {help worldstat##options:place_name}{cmd:,}
stat({help worldstat##options:statistic_name}) [{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt s:tat(namelist)}}lists the statistic which the user wishes to visualise.
{p_end}
{...}
{synopt :{cmdab:year(}#{cmdab:)}}lists the year which the user wishes to visualise for the statistic in question; genearlly should be between 1960-2010.
{p_end}
{...}
{synopt :{cmdab:pres:erve}}allows for the dataset in memory to be {help preserve:preserved} and  {help restore:restored} once worldstat finishes running
{p_end}
{...}
{synopt :{cmdab:sn:ame(}{help string}{cmd:)}}allows for a name to be given to the statistic of interest (for graphical outputs) when the {browse "http://data.worldbank.org/indicator/all":World Bank data} code is not the desired name
{p_end}
{...}
{synopt :{cmdab:cn:ame}}adds country names to the {help spmap:map} produced as output
{p_end}
{...}
{synopt :{cmdab:map:only}}prints only the geographical output while suppressing the time series graph
{p_end}
{...}
{synoptline}
{p2colreset}



{marker description}{...}
{title:Description}

{p 6 6 2}
{hi:worldstat} is a module which allows for the current state of world development to be visualised in a computationally simple way.  {hi:worldstat} presents both the geographic and
temporal variation in a wide range of macroeconomic and microeconomic statistics retrieved automatically from the World Bank Data Bank.  While {hi:worldstat} includes a number of "in-built" statistics such as GDP,
maternal mortality and years of schooling, it is extremely flexible, and can, (thanks to the World Bank's module {help wbopendata}), easily incorporate any of the 5,000+ indicators collated by the 
World Bank.
 
 {p 6 6 2}
The {hi:worldstat} module is not demanding of computer hard disk space, as all statistics and map files are accessed remotely, and are, by default, not saved to the hard disk.  For the full list 
of indicators which can be accessed, visit {browse "http://worldbank.270a.info/classification/indicator.html"} or see the {help wbopendata} help file.



{marker options}{...}
{title:Options}
 {p 6 6 2}
{cmd:place_name} The region of the world which the the user wishes to visualize.  This defines the map which will be produced as output, and average results in the time series  are presented aggregated at the level
of the region defined in {it:place_name}. One of the following options must be specified:

           place name       Region
           {hline 80}
              {cmd:Africa}		All African countries
              {cmd:America}		All Latin American countries, plus the Caribbean
              {cmd:Asia}		All Asian countries
              {cmd:Europe}		All European countries
              {cmd:NSAmerica}		Latin America, North America, and the Carribean
              {cmd:Oceania}		Australia, New Zealand, Papua New Guinea and the Pacific Islands
              {cmd:SAmerica}		All countries in South America
              {cmd:world}		Every country in the world
          {hline 80}

 {p 6 6 2}
{cmd:statistic_name} The statistic of interest which is to be downloaded from the World Bank Data Bank.  This may be one of the following options (where  only the short code is required), or any other indicator from the
World Bank Data Base.  If a short-cut for the indicator of interest is not provided in the following table, the indicator's complete {browse "http://worldbank.270a.info/classification/indicator.html":WB Code} is required.

           Short-cut    WB Code				Description
           {hline 80}
              {cmd:GDP}       {it:NY.GDP.PCAP.KD}      GDP per capita (constant 2000 US$)
              {cmd:MMR}       {it:SH.STA.MMRT}         Maternal mortality ratio (modeled estimate, per  
					     100,000 live births)
              {cmd:EDUP}      {it:SE.PRM.NENR}         School enrollment, primary (% net)
              {cmd:EDUS}      {it:SE.SEC.NENR}         School enrollment, secondary (% net)
              {cmd:CO2}       {it:EN.ATM.CO2E.PC}      Carbon dioxide emissions p.c. (metric tons)
              {cmd:MORT}      {it:SH.DYN.MORT}         Mortality rate, under-5 (per 1,000 live births)
              {cmd:LIFE}      {it:SP.DYN.LE00.FE.IN}   Life expectancy at birth, female (years)
              {cmd:CAB}       {it:BN.CAB.XOKA.GD.ZS}   Current account balance (% of GDP)
              {cmd:FDI}       {it:BX.KLT.DINV.CD.WD}   Foreign direct investment, net inflows (BoP, 
					     current US$)
              {cmd:INF}       {it:FP.CPI.TOTL.ZG}      Inflation, consumer prices (annual %)
              {cmd:ODA}       {it:DT.ODA.ODAT.PC.ZS}   Net ODA received per capita (current US$) 
              {cmd:HIV}       {it:SH.DYN.AIDS.ZS}      Prevalence of HIV, total (% of population ages 
					     15-49)   
              {cmd:ENER}       {it:EG.GDP.PUSE.KO.PP}  GDP per unit of energy use (PPP $) 	  
              {cmd:SLR}        {it:IC.LGL.CRED.XQ}     Strength of legal rights index (0=weak to 
				             10=strong)
              {cmd:AGE}        {it:SP.POP.DPND.YG}     Age dependency ratio, young (% of working age 
				             population)
              {cmd:BIRTH}      {it:SP.DYN.CBRT.IN}     Birth rate, crude (per 1,000 people)
              {cmd:FERT}       {it:SP.DYN.TFRT.IN}     Fertility rate, total (births per woman)			  
              {cmd:IMM}        {it:SH.IMM.IDPT}        Immunization DPT, (% children aged 12-23 months)			  
           {hline 80}
		note: This is a very small subset of the total Data Bank.  The entire 
		Data Bank is available at {browse "http://worldbank.270a.info/classification/indicator.html"}.
{pmore}

 {p 6 6 2}
{cmd:year(}#{cmdab:)} Determines the year of interest which will be presented in the geographic graph.  If this option is not specified, the year 2010 is assumed.  Year must generally fall between 1960 and 2011, and in 
some cases, World Bank data is not available for each of these year.

 {p 6 6 2}
{cmdab:sn:ame(}{help string}{cmd:)} Gives the name which is to be assigned to graphical output when the long World Bank code is not required.  For example, if the user wishes to visualise Gini
data, they must enter si.pov.gini as the {help worldstat##options:statistic_name}, however they may wish to specify the option sname(Gini) to avoid printing out the more cumbersome full name.

 {p 6 6 2}
{cmdab:cn:ame} Allows for country names to be included as labels on the {help spmap:country maps} produced. 

 {p 6 6 2}
{cmdab:map:only} Only the part of the graphical output which corresponds to geographical data is displayed.  The map is printed, and time series graphs are not included.

{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Visualise GDP per capita in African countries {p_end}

{phang2}{cmd:. worldstat Africa, stat(GDP) year(2009) cname}{p_end}

    {hline}
{pstd}Visualise maternal mortality per capita for the entire world {p_end}

{phang2}{cmd:. worldstat world, stat(FERT)}{p_end}

    {hline}


{marker references}{...}
{title:References}

    {p 4 4 2} Azevedo, J.P. (2011) "wbopendata: Stata module to access World Bank databases," Statistical Software Components S457234, Boston College Department of 
Economics.{browse "http://ideas.repec.org/c/boc/bocode/s457234.html"}{p_end} 



{title:Acknowledgements}

    {p 4 4 2} I thank J.P. Azevedo and the LAC Team for Statistical Development,
	who developed the {helpb wbopendata} module which allows simple access to The World Bank's data
	from Stata.  I also acknowledge Maurizio Pisati who developed the {helpb spmap} module for
	the visualisation of spatial data.  I thank the Comisi{c o'}n Nacional de Investigaci{c o'}n Cient{c i'}fica
	y Tecnol{c o'}gica of the Government of Chile who supported my research during the writing of this
	program. 


{title:Also see}

{psee}
Online:  {manhelp graph G}, {help wbopendata}, {help spmap},


{title:Author}

{pstd}
Damian C. Clarke, The University of Oxford. {browse "mailto:damian.clarke@economics.ox.ac.uk":damian.clarke@economics.ox.ac.uk}
{p_end}


