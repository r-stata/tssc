{smcl}
{* 11january2013}
{hline}
help for {hi:airnet}
{hline}

{title:Airline Traffic Network Construction}

{p 8 16 2}{cmd:airnet} {cmd:,} [ {opt options} ]

{title:Description}

{p 4 4 2}
{cmd:airnet} creates weighted and directed inter-airport or inter-city networks using data from the Bureau of Transportation Statistics' Origin and Destination Survey (DB1D).
(NOTE: This command does not affect the data in memory.){p_end}


{title:Options}
{p 4 8 2}{opt stub(str)} specifies the stub (if any) used to name input (ticket{it:stub}.csv and coupon{it:stub}.csv) and output (airnet{it:stub}.dta) files.{p_end}
{p 4 8 2}{opt alpha(real)} sets the alpha-level used for identifying likely business and leisure passengers. 
The default is 0.05.{p_end}
{p 4 8 2}{opt {ul on}max{ul off}fare(real)} and {opt {ul on}min{ul off}fare(real)} sets the maximum and minimum credible fares;
fares outside these limits are not used in calculations to identify business and leisure passengers.
The defaults are $5000 and $20.{p_end}
{p 4 8 2}{opt {ul on}leg{ul off}type} separately reports the number of passengers traveling on each type of leg in a route network (i.e. first, last, middle, and only).{p_end}
{p 4 8 2}{opt matrix} saves the route, origin-destination, business, and leisure networks in matrix form as separate comma-delimited files.{p_end}
{p 4 8 2}{opt metro(new | old)} aggregates airports into metropolitan areas (cannot be used with {opt intl}; see below for details).{p_end}
{p 4 8 2}{opt intl(1 | 2 | 3 | 4)} constructs a partial, international route network for the given quarter (cannot be used with {opt metro}; see below for details).{p_end}
{p 4 8 2}{opt {ul on}desc{ul off}riptives} returns selected descriptives concerning the raw data in {cmd:r()}. {p_end}


{title:Input}
{p 4 4 2}{cmd:airnet} requires two input files, which may be obtained from the BTS website.  Both files must be located in the working directory.{p_end}

{p 6 6 2}
ticket{it:stub}.csv - A comma-delimited file generated from the DB1BTicket database, containing only the following variables: ItinID, RoundTrip, Passengers, ItinFare.
{browse "http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=272":available here}{p_end} {p 6 6 2}
coupon{it:stub}.csv - A comma-delimited file generated from the DB1BCoupon database, containing only the following variables: ItinID, MktID, Origin, Dest, SeqNum.
{browse "http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=289":available here}{p_end}


{title:Output}
{p 4 4 2}{cmd:airnet} produces several types of airline traffic networks, each stored in edgelist-format as a separate variable in airnet{it:stub}.dta:{p_end}

{p 6 6 2}
{it:Route} - Edges indicates the number of passengers that flew from {it:orig} to {it:dest}.
Using the {cmd:legtype} option decomposes this total by the leg's position in the passenger's trip: first leg, last leg, a middle leg, or the only leg.{p_end} {p 6 6 2}
{it:Origin-Destination} (origdest) - Edges indicate the number of passengers that flew from an initial origin in {it:orig} to a final destination in {it:dest}; any intermediate stops are ignored.{p_end} {p 6 6 2}
{it:Single-Destination Round-Trip} (sdrt) - A subset of the origin-destination network that includes only passengers taking single-destination round-trip flights.{p_end} {p 6 6 2}
{it:Business Passengers} (business) - A subset of the SDRT network that includes only passengers that flew alone and paid a significantly above-average fare for travel between the same origin and destination airports.{p_end} {p 6 6 2}
{it:Leisure Passengers} (leisure) - A subset of the SDRT network that includes only passengers that flew with one or more companions and paid a significantly below-average fare for travel between the same origin and destination airports.{p_end}


{title:The -metro- option}
{p 4 4 2}Using the {opt metro} option aggregates airports into metropolitan areas, and thus results in the construction of intercity, rather than interairport, networks.
The aggregation is performed only for the 139 airports identified by the Federal Aviation Administration as "Primary Hubs" in 2010.
This option also creates a variable containing the great circle distance (in km) between metropolitan areas, which is stored in the "distance" variable in the airnet{it:stub}.dta and, if the {opt matrix} option is specified, is saved as a matrix.
The aggregation units are set by the suboption:
{p_end}

{p 6 6 2}
{opt metro(old)} - Airports are aggregated into Consolidated Metropolitan Statistical Areas (CMSAs) and Metropolitan Statistical Areas (MSAs) using 1999 US Census definitions.{p_end} {p 6 6 2}
{opt metro(new)} - Airports are aggregated into Consolidated Statistical Areas (CSAs) and Metropolitan Statistical Areas (MSAs) using 2009 US Census definitions.{p_end}


{title:The -intl- option}
{p 4 4 2}The {opt intl} option constructs a partial, international route network in addition to the complete, domestic networks constructed by {cmd:airnet}.
This network contains all intra-US route edges and all route edges between US and international airports, but does not include route edges between international airports.
It is stored in the "routeintl" variable in the airnet{it:stub}.dta, and if {opt matrix} is specified, is also saved as a matrix.
International origin-destination pairs are coded as missing.
This international route network is constructed from supplementary BTS T-100 data, and requires an additional input file:{p_end}

{p 6 6 2}intl{it:stub}.csv - A comma-delimited file generated from the T-100 International Segment database, containing only the following variables: Passengers, Origin, Dest, Quarter.{p_end}

{p 4 4 2}This file may be obtained from the BTS website {browse "http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=261":(available here)} and must be located in the working directory.
The downloaded data should cover all months in the desired year, and the quarter of the BTS DB1B data (i.e. the data in ticket{it:stub}.csv and coupon{it:stub}.csv) should be identified in the {opt intl} option.
For example, if ticket{it:stub}.csv and coupon{it:stub}.csv contain data on air traffic in the 2nd quarter (April-June) of 2010, the intl{it:stub}.csv file should contain data for all months in 2010 and the option should be specified as {opt intl(2)}.{p_end}


{title:Saved Results}
{p 4 4 2}If the {opt descriptives} option is specified, {cmd:airnet} saves the following in {cmd:r()}:{p_end}

{p 6 6 2}{cmd:r(movements)} - Number of intra-US passenger movements{p_end}
{p 6 6 2}{cmd:r(airports)} - Number of US airports{p_end}
{p 6 6 2}{cmd:r(all_pass)} - Number of intra-US passengers{p_end}
{p 6 6 2}{cmd:r(sdrt_pass)} - Number of intra-US passengers taking single-destination round-trips{p_end}
{p 6 6 2}{cmd:r(lowfare)} - Number of intra-US passengers paying less than the minimum credible fare{p_end}
{p 6 6 2}{cmd:r(highfare)} - Number of intra-US passengers paying more that the maximum credible fare{p_end}
{p 6 6 2}{cmd:r(time)} - Command running time, in seconds.{p_end}


{title:References}
{p 0 5}
Neal, Z. P. 2010. Refining the air traffic approach: An analysis of the US city network, Urban Studies 47: 2195-2215. ({browse "https://www.msu.edu/~zpneal/publications/neal-airtraffic.pdf":CLICK FOR PDF})

{title:Author}
Zachary Neal
Department of Sociology
Michigan Sate University
zpneal@msu.edu
