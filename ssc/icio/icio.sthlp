{smcl}
{* *! version 1.0.1 30sep2019}{...}

{cmd:help icio}{right:}
{hline}

{title:Title}

{p2colset 5 14 21 2}{...}
{p2col:{hi:icio} {hline 2}}Economic Analysis with Inter-Country Input-Output tables{p_end}
{p2colreset}{...}

{title:Syntax}

{phang}
{ul:{hi:{help icio##load:Load an ICIO table}}} (required to run {cmd:icio}):

{p 8 16 2}{cmd:icio_load}, [{it:{help icio##icioload_options:icio_load_options}}]

{phang}
List of countries and sectors in the loaded ICIO table:

{p 8 16 2}{cmd:icio}, info

{phang}
{ul:{hi:{help icio##supplydemand:Supply, final demand and supply-final demand linkages:}}}

{p 8} {hi: 1. Gross Domestic Product:}

{p 8 16 2}{cmd:icio}, origin({it:country_code}[, {it:sector_code}]) [{it:{help icio##icio_options:standard_options}}]

{p 8} {hi: 2. Final demand:}

{p 8 16 2}{cmd:icio}, destination({it:country_code}[, {it:sector_code}]) [{it:{help icio##icio_options:standard_options}}]

{p 8} {hi: 3. Value-added by origin and final destination:}

{p 8 16 2}{cmd:icio}, origin({it:country_code}[, {it:sector_code}]) destination({it:country_code}[, {it:sector_code}]) [{it:{help icio##icio_options:standard_options}}]

{phang}
{ul:{hi:{help icio##vatrade:Value-added decomposition of trade flows and GVC participation:}}}

{p 8} {hi: 1. Value-added and GVC participation in total exports of a country:}

{p 12} {it: a) Value-added and GVC participation in total aggregate exports:}

{p 12 16 2}{cmd:icio}, exporter({it:country_code}) [{it:{help icio##icio_1a_options:methods_1a}}] [{it:{help icio##icio_out_options:output_exports}}] [{it:{help icio##icio_ori_dest_options:origin_destination}}]
[{it:{help icio##icio_options:standard_options}}]

{p 12} {it:b) Value-added and GVC participation in total sectoral exports:}

{p 12 16 2}{cmd:icio}, exporter({it:country_code}, {it:sector_code}) [{it:{help icio##icio_1b_options:methods_1b}}] [{it:{help icio##icio_out_options:output_exports}}] [{it:{help icio##icio_ori_dest_options:origin_destination}}]
[{it:{help icio##icio_options:standard_options}}]

{p 8} {hi: 2. Value-added and GVC participation in bilateral exports:}

{p 12} {it:a) Value-added and GVC participation in bilateral aggregate exports:}

{p 12 16 2}{cmd:icio}, exporter({it:country_code}) importer({it:country_code}) [{it:{help icio##icio_2a_options:methods_2a}}] [{it:{help icio##icio_out_options:output_exports}}] [{it:{help icio##icio_ori_dest_options:origin_destination}}]
[{it:{help icio##icio_options:standard_options}}]

{p 12} {it:b) Value-added and GVC participation in bilateral sectoral exports:}

{p 12 16 2}{cmd:icio}, exporter({it:country_code}, {it:sector_code}) importer({it:country_code}) [{it:{help icio##icio_2b_options:methods_2b}}] [{it:{help icio##icio_out_options:output_exports}}]
[{it:{help icio##icio_ori_dest_options:origin_destination}}] [{it:{help icio##icio_options:standard_options}}]

{p 8} {hi: 3. Value-added in total imports of a country:}

{p 12} {it:a) Value-added in total aggregate imports:}

{p 12 16 2}{cmd:icio}, importer({it:country_code}) [{it:{help icio##icio_3a_options:methods_3a}}] [{it:{help icio##icio_out_options:output_exports}}] [{it:{help icio##icio_ori_dest_options:origin_destination}}]
[{it:{help icio##icio_options:standard_options}}]

{p 12} {it:b) Value-added in total sectoral imports:}

{p 12 16 2}{cmd:icio}, importer({it:country_code}, {it:sector_code}) [{it:{help icio##icio_3b_options:methods_3b}}] [{it:{help icio##icio_out_options:output_exports}}] [{it:{help icio##icio_ori_dest_options:origin_destination}}]
[{it:{help icio##icio_options:standard_options}}]

{p2colreset}{...}

{title:Description}

{pstd}
    {cmd:icio} is suited to measure trade in value-added and participation in GVCs of countries and sectors by exploiting Inter-Country Input-Output (ICIO) tables.
	It provides decompositions of aggregate, bilateral and sectoral exports and imports according to the source and the destination of their value-added content.

{pstd}
	The {cmd:icio_load} command allows to work directly with the most popular ICIO tables - WIOD (Timmer et al. 2015), TIVA (OECD), EORA (Lenzen et al. 2013), ADB MRIO (Asian Development Bank MRIOT Database); 
	in addition, any other user-provided ICIO table can be loaded(see the option {opt user()} of {cmd:icio_load}). 
	{cmd:icio} also allows to work with user-defined groups of countries, which means that output measures can be computed  for a country
	group (e.g. the "Euro area", "MERCOSUR" or "ASEAN") as a whole while taking into account the specific supply/demand/trade structure of each  member of the group (see the option {opt groups()} for more details).

{pstd}
	{cmd:icio} encompasses the most relevant measures of value-added in exports and imports at different level of aggregation. It follows closely the accounting framework presented in Borin and Mancini (2019), which - in turn - extends,
	refines and reconciles the other main contributions in this strand of the literature (Johnson and Noguera, 2012; Wang et al., 2013; Koopman et al. 2014; 
	Borin and Mancini, 2015; Los et al., 2016; Nagengast and Stehrer, 2016; Johnson, 2018; Miroudot and Ye, 2018; Los and Timmer, 2018).
	A key feature of the conceptual scheme proposed by Borin and Mancini (2019) is that different empirical questions call for distinct accounting methods, 
	along with different level of aggregation of trade flows. The icio command shares
	the same rationale.

{pstd}
	According to the specific empirical application, the user should select:

{p 8 8} i) a certain type of {help icio##tradeflow:trade flow} (i.e. aggregate exports/imports, sectoral exports/imports, bilateral flows, sectoral-bilateral flows), through the options {opt exporter(country_code[, sector_code])}
and/or {opt importer(country_code[, sector_code])};

{p 8 8} ii) a certain {help icio##methodologies:accounting methodology}, that can be specified using the {opt perspective()} and {opt approach()} options, otherwise default options are applied.
These accounting methodologies differ in the way 'double counted' components are computed, i.e. items that are recorded several times in a given gross trade flow due to the back-and-forth shipments that occur in a cross-national production process
(see Borin and Mancini, 2019 and the {help icio##examples:Example section} for a mapping of the questions under investigation and the accounting methods needed to address them).

{p 8 8} iii) the desired {help icio##icio_out_options:output measures}. The possibility to choose among different output measures allows to address a wide range of empirical issues.

{pstd}
Moreover, {opt origin(country_code[, sector_code])} and {opt destination(country_code[, sector_code])} options can always be specified in order to select the country/sector where
the trade value is produced (origin) and the country/sector where it is absorbed by final demand (destination).

{pstd}
The command allows to reproduce many of the measures of trade in value-added proposed in the literature, however they are not computed using the original formulations whenever they have been found to be inexact or imprecise.
For instance, a corrected version of the Koopman et al. (2014) decomposition of aggregate exports can be computed as: {cmd: icio, exporter(country_code) perspective(world) approach(sink)}.

{pstd}
For export flows at different disaggregation level it is also possible to compute the value of trade that is related to GVCs, i.e. that crosses more than one border.
The backward and forward GVC participation measures are based on Borin and Mancini (2015, 2019) which consistently refine the vertical specialization index proposed by Hummels et al.(2001).

{pstd}
When neither {opt exporter()} nor {opt importer()} options are specified, the {cmd:icio} command can be used to compute the GDP (i.e. value-added) produced by a given country or industry ({opt origin()}),
to measure final demand in different countries and sectors ({opt destination()}), or a combination of the two (when both origin and destination are specified).


{title:Options}
{marker load}{...}
{pstd} Load an ICIO table (required to run icio):{p_end}
{synoptline}

{marker icioload_options}{...}
{synoptset 44 tabbed}{...}
{synopthdr : icio_load options}
{synoptline}
{synopt :{cmdab:iciot:able(}{it:{help icio##table_name:table_name}} [, {it:{help icio##usertable_options:usertable_options}}])}specify the icio table to be used for the analysis; default is {opt wiodn} {p_end}
{synopt :{opt year(#)}}set the year to be used for the analysis; default is the last available year: {opt year(2014)} for {opt wiodn}, {opt year(2015)} for {opt tivan}, {opt year(2015)} for eora. Not needed for user-provided tables{p_end}
{synopt :{opt info}}describe the source and the version of the Input Output databases available in {cmd:icio}{p_end}
{synoptline}

{marker table_name}{...}
{synoptset 39 tabbed}{...}
{synopthdr: table_name}
{synoptline}
{synopt :{opt wiodn}}World Input-Output Database, last version. See Timmer et al. (2015) and {browse "http://www.wiod.org":WIOD website}{p_end}
{synopt :{opt tivan}}OECD Trade in value-added tables, last version. See OECD (2018) and the dedicated {browse "http://oe.cd/tiva":OECD website}{p_end}
{synopt :{opt eora}}Eora Global MRIO tables. See Lenzen et al. (2013) and {browse "http://worldmrio.com/":http://worldmrio.com/}{p_end}
{synopt :{opt adb}}ADB MRIO tables. See the Asian Development Bank MRIOT Database at {browse "http://mrio.adbx.online/":http://mrio.adbx.online/}{p_end}
{synopt :{opt wiodo}}World Input-Output Database, previous version{p_end}
{synopt :{opt tivao}}OECD Trade in value-added tables, previous version{p_end}
{synopt :{opt user}}User-created tables. This option allows {cmd:icio} to work with tables that have been pre-downloaded
and formatted by the user. See {it: usertable_options}. Details on the required format are specified in the Remarks section below.{p_end}
{synoptline}

{marker usertable_options}{...}
{synoptset 39 tabbed}{...}
{synopthdr:usertable_options}
{synoptline}
{synopt : {it: Only when user is selected in table_name}}{p_end}
{synopt :{opt userp:ath(string)}}specifies the full path to a folder containing two {it: user-defined} files: the {it: user-defined} table and country-list files{p_end}
{synopt :{opt tablen:ame(string)}}specifies the name of the {it: user-created} table{p_end}
{synopt :{opt countryl:istname(string)}}specifies the name of the {it: user-created} country-list{p_end}
{synoptline}

{pstd} Remarks on user provided tables{p_end}
{synoptline}

{pstd}
{cmd:icio} user-created tables and related country lists must be provided in csv format. The table's csv file must contain only one matrix of dimension (GxN)x(GxN+GxU), where G is the number of countries, N the number of sectors
and U the number of uses (i.e., consumption, investment, etc.). As a purely illustrative example, consider the case of importing a IO table from WIOD 2016 release  (indeed, the user does not need to manually import WIOD, TiVA, EORA or ADB tables,
they are already included in the {cmd:icio} package and can be loaded using the {cmd:icio_load} command with the appropriate options, see {it:{help icio##icioload_options:icio_load_options}}).
In this case, the matrix dimension in the user-provided csv file should be (44x56)x(44x56+44X5), that is 2464x2684, since G=44, N=56, U=5. Thus considering a standard excel file of a WIOD table (release 2016) downloaded from the official website,
the user provided csv should include only data in the cell range E7 to CYJ2470. More in general, country and sector labels, total output, total consumption and total value-added must not be included in the csv.
Country list's csv file must only contain a vector (Gx1) of country names, reflecting the same order adopted in the provided table's csv file.{p_end}
{synoptline}

{marker supplydemand}{...}
{pstd} {ul:{hi:Supply, final demand and supply-final demand linkages:}}{p_end}
{synoptline}

{pstd}
Through basic Input Output accounting, {cmd:icio} can display the GDP (i.e. value-added) produced by a given country/industry (origin of the value-added),
the final demand in different countries and sectors (destination of the value-added), or a combination of the two.
With the options {opt origin(country_code[, sector_code])} and {opt destination(country_code[, sector_code])} the desired measure is selected.
Results for all countries or all sectors can be computed and displayed simultaneously, using the option {opt all} for {opt country_code} or {opt sector_name}.
Note that within a specific origin/destination option, {opt country_code} and {opt sector_name} cannot be {opt all} at the same time.

{pstd} 1. Gross Domestic Product:{p_end}
{pstd} Display the value-added produced in a selected country/sector. All countries or all sectors can be selected at once with the option {opt all}. Examples are:{p_end}
{phang2}{cmd: icio, origin(usa)} {p_end}
{phang2}{cmd: icio, origin(deu,18)} {p_end}
{phang2}{cmd: icio, origin(all,18)} {p_end}
{phang2}{cmd: icio, origin(deu,all)} {p_end}

{pstd} 2. Final demand:{p_end}
{pstd} Display the final demand absorbed in a selected country/sector.  All countries or all sectors can be selected at once with the option {opt all}.	Examples are:{p_end}
{phang2}{cmd: icio, destination(usa)} {p_end}
{phang2}{cmd: icio, destination(deu,18)} {p_end}
{phang2}{cmd: icio, destination(all,18)} {p_end}
{phang2}{cmd: icio, destination(deu,all)} {p_end}

{pstd} 3. Value-added by origin and final destination:{p_end}
{pstd} Display the value-added originated in a a selected country/sector and absorbed by the final demand of a selected country/sector. 
All countries or all sectors of origin as well as all countries or all sectors of final demand can be selected at once with the option {opt all}. Examples are:{p_end}
{phang2}{cmd: icio, origin(deu) destination(chn)} {p_end}
{phang2}{cmd: icio, origin(all) destination(chn)} {p_end}
{phang2}{cmd: icio, origin(deu,8) destination(chn,9)} {p_end}
{phang2}{cmd: icio, origin(deu,all) destination(chn,all)} {p_end}

{marker vatrade}{...}
{pstd} {ul:{hi:Value-added decomposition of trade flows and GVC participation in exports:}}{p_end}
{synoptline}

{pstd}
Depending on the specific empirical application, the user can choose the appropriate options in order to select: i) the desired {help icio##tradeflow:trade flow};
ii) the best suited {help icio##methodologies:accounting methodology} to single out 'double counted' components, i.e. items that are recorded several times in gross trade; iii) the appropriate {help icio##icio_out_options:output measures}.{p_end}

{marker tradeflow}{...}
{pstd}{hi:i) Selection of trade flow:}{p_end}
{synoptline}

{pstd}Through the options {opt exporter(country_code[,sector_code])} and/or {opt importer(country_code[,sector_code])} the user chooses to retrieve information on:

{p 8}1.a - the total aggregate exports of a country{p_end}
{p 12}Example:{cmd: icio, exporter(usa)}{p_end}
{p 8}1.b - the total sectoral exports of a country{p_end}
{p 12}Example:{cmd: icio, exporter(deu,20)} {p_end}
{p 8}2.a - the bilateral aggregate exports of a country toward an importing partner{p_end}
{p 12}Example:{cmd: icio, exporter(chn) importer(usa)} {p_end}
{p 8}2.b - the bilateral sectoral exports of a country toward an importing partner{p_end}
{p 12}Example:{cmd: icio, exporter(deu,20) importer(usa)} {p_end}
{p 8}3.a - the total aggregate imports of a country{p_end}
{p 12}Example:{cmd: icio, importer(usa)} {p_end}
{p 8}3.b - the total sectoral imports of a country{p_end}
{p 12}Example:{cmd: icio, importer(usa,20)} {p_end}

{marker methodologies}{...}
{pstd}{hi:ii) Accounting methodology:}{p_end}
{synoptline}

{pstd}The options {opt perspective()} and {opt approach()} can be used to select the accounting methodology best suited to the specific phenomenon under investigation. In particular the
option {opt perspective()} defines the 'perimeter' according to which something is classified as 'value-added' or 'double counted', the latter being the items that cross this perimeter more than once.
For instance, the boundaries may be defined at the level of the exporting country (or the importing one), or of a specific bilateral relation, or of a single exporting sector within a bilateral flow.
Note that the perspective may differ from the level of disaggregation of trade flow that is considered (i.e. the perimeter that identifies the perspective can be set at a more aggregate level as compared to the selected trade flow).
For instance, if the question is: what part of a country's GDP is exported? It will be necessary to select {opt exporter(country_code)} and {opt perspective(exporter)} as options, such that the exporting country's frontiers as a whole
constitute the perimeter that matters in deciding whether or not a certain item has to be classified as domestic value-added (GDP) or double-counted. 
The {opt perspective(exporter)} has to be used also when one seeks a measure of value-added in sectoral and/or bilateral exports that can be added up to the exporter's GDP in its total exports.{p_end}

{pstd}Alternative perspectives are better suited to address other issues. For instance, if we are interested in measuring the exporter's value-added that is exposed to a tariff imposed on a given sector
from a certain partner, we want to consider as 'value-added' the entire GDP that is involved in this sectoral-bilateral relationship, even if part of that was previously exported to other countries/sectors
(i.e. classified as 'domestic double counting' when {opt perspective(exporter)} is selected). In this case the option {opt perspective(sectbil)} has to be chosen so that the specific sectoral-bilateral
relationship become the new relevant perimeter, and only the items that enter multiple times in this trade flow are considered as 'double counting'. Whenever an exporting country is specified, the command always allows
to select the {opt perspective(exporter)} as an option, while {opt perspective(sectexp)}, {opt perspective(bilateral)} and {opt perspective(sectbil)} are available only for sectoral, bilateral and sectoral-bilateral flows respectively.{p_end}

{pstd}For the aggregate exports of a country, it is possible to choose {opt perspective(world)} as an option which is applied to the accounting of foreign value added (FVA), as in Koopman et al. (2014) and Miroudot and Ye (2018).
According to this perspective a certain item is considered as FVA only the first (or the last) time it crosses a foreign border, whereas all the other times it crosses any foreign border it is classified as double counted.
Then by using {opt perspective(exporter)} a certain item is accounted for as FVA only once in the total exports of a country, whereas {opt perspective(world)} requires it to be accounted for as FVA only once in total world exports.{p_end}

{pstd}When the {opt exporter()} is not specified, {cmd:icio} allows only {opt perspective(importer)} for aggregate imports and {opt perspective(sectimp)} for sectoral imports. The former should be adopted to compute
the value-added of a given country that enters, directly or indirectly, in the total imports of a given country; the latter to compute the value-added that enters in a specific sector of import.{p_end}

{pstd}Whenever the perspective is set at a more aggregate level as compared to the considered trade flow, also the option {opt approach()} can be defined to choose in which disaggregated flow a certain item
should be accounted for as 'value-added' or 'double-counted'. Suppose, for instance, that along the production process a certain item is exported by country A first to country B and than to country C.
By choosing {opt approach(source)} the item is classified as 'value-added' the first time it leaves the national border (i.e. in the exports toward B), whereas the sink-based approach considers it as 'value-added'
the last time it crosses the border (i.e. in the exports toward C). The choice between the two approaches depends on the particular empirical issue we want to address. The source approach is designed to examine the production
linkages and the country/sector participation to different types of production processes and to study the features of the production processes in which export flows are involved. 
Conversely, the value-added in the sink-based approach is recorded as closely as possible to the moment when it is ultimately absorbed.
This makes it more suited to studying the relationship between value-added in exports and final demand.{p_end}

{pstd} All the {opt perspective()} and {opt approach()} options available for the different trade flows are reported here below.{p_end}

{p 8} 1. Value-added and GVC participation in total exports of a country

{marker icio_1a_options}{...}
{synoptset 50 tabbed}{...}
{synopthdr : a) Value-added and GVC participation in total aggregate exports:}
{synoptline}
{synopt :{opt perspective(exporter)}}the default{p_end}
{synopt :{opt perspective(world)}}world perspective for foreign value-added accounting. This perspective entails the selection of {opt approach(source)} (the default) or {opt approach(sink)}{p_end}
{synoptline}

{marker icio_1b_options}{...}
{synoptset 50 tabbed}{...}
{synopthdr : b) Value-added and GVC participation in total sectoral exports:}
{synoptline}
{synopt :{opt perspective(exporter)}}the default. This allows to display output for each exporting sector at once by setting {it:sector_code} as {opt all}. This perspective entails the selection of
{opt approach(source)} (the default) or {opt approach(sink)}{p_end}
{synopt :{opt perspective(sectexp)}}{p_end}
{synoptline}

{p 8} 2. Value-added and GVC participation in bilateral exports:

{marker icio_2a_options}{...}
{synoptset 50 tabbed}{...}
{synopthdr : a) Value-added and GVC participation in bilateral aggregate exports:}
{synoptline}
{synopt :{opt perspective(exporter)}}the default. This perspective entails the selection of {opt approach(source)} (the default) or {opt approach(sink)}{p_end}
{synopt :{opt perspective(bilateral)}}{p_end}
{synoptline}

{marker icio_2b_options}{...}
{synoptset 50 tabbed}{...}
{synopthdr : b) Value-added and GVC participation in bilateral sectoral exports:}
{synoptline}
{synopt :{opt perspective(exporter)}}the default. This allows to display output for each exporting sector at once by setting {it:sector_code} as {opt all}. This perspective entails the selection of
{opt approach(source)} (the default) or {opt approach(sink)}{p_end}
{synopt :{opt perspective(sectbil)}}{p_end}
{synoptline}

{p 8} 3. Value-added in total imports of a country:

{marker icio_3a_options}{...}
{synoptset 50 tabbed}{...}
{synopthdr : a) Value-added in total aggregate imports:}
{synoptline}
{synopt :{opt perspective(importer)}}the default{p_end}
{synoptline}

{marker icio_3b_options}{...}
{synoptset 50 tabbed}{...}
{synopthdr : b) Value-added and GVC participation in bilateral sectoral exports:}
{synoptline}
{synopt :{opt perspective(sectimp)}}the default{p_end}
{synoptline}

{marker icio_out_options}{...}
{pstd}{hi:iii) Output and other options:}{p_end}
{synoptline}

{pstd}For the selected trade flow, {cmd:icio} allows to compute the main indicators of gross trade and value-added by specifying the {opt output()} option. For export flows the default
output option - {opt output(detailed)} - shows a complete value-added decomposition of the trade flows according to the conceptual scheme proposed by Koopman et al. (2014) and refined by Borin and Mancini (2019).
Gross trade - {opt gtrade} - is first split in the part that is originally produced by the exporting country (domestic content - {opt dc}) and the part that is produced abroad (foreign content - {opt fc}); in turn,
each of these components is broken down in a part of value-added item (domestic value-added - {opt dva} - and foreign value-added - {opt fva}) and in a part of double counting.
The methodology used to single out the value-added and double-counted components changes according to the selected perspective/approach options (while {opt gtrade}, {opt dc}, {opt fc} measures have to be the same for all the accounting methodologies by construction).
The detailed output include also additional indicators of trade in value-added that have been singled out in the literature (es. VAX by Johnson and Noguera, 2012; Reflection by Koopman et al. 2014; DAVAX and
VAXIM by Borin and Mancini, 2015 and 2019).
The additional indicators that are included in the detailed output vary consistently with the selected perspective/approach.{p_end}

{pstd}Instead of the whole detailed output the user can compute only one of the main trade indicators choosing one of the following {opt output()} options: {opt gtrade}, {opt dc}, {opt dva}, {opt fc} and {opt fva}.{p_end}

{pstd}In addition to value-added and gross trade measures, for any export flow it is also possible to compute the value of trade that is related to GVCs, as developed in Borin and Mancini (2015).
The 'GVC-related trade' includes all the traded items that cross at least two international borders, i.e. that are re-exported at least once.
The backward and forward GVC participation measures are based on Borin and Mancini (2019) which consistently refine the vertical specialization index proposed by Hummels et al.(2001).
GVC-related indicators, that are sub-components of the selected export flow, are shown in the detailed output by default (or when {opt perspective(exporter)} and {opt approach(source)} are specified).
Alternatively it is possible to obtain a single measure of GVC trade by specifying {opt gvc}, {opt gvcb} and {opt gvcf} as arguments of the {opt output()} option for total, backward and forward GVC indicators respectively.{p_end}

{pstd}For value-added and GVC indicators of the selected trade flow it is also possible to single out the country/sector where the goods/services where originally produced by specifying
the {opt origin(country_code[,sector_code])} option, as well as the market/sector where it is absorbed in final demand by specifying the {opt destination(country_code[,sector_code])} option.
When one seeks a measure of value-added produced by a specific country/sector the option {opt output(va)} should be specified. Note that, when the country in {opt origin()} correspond
to that specified in {opt exporter()}, {cmd:icio} provides the same results when selecting {opt output(dva)} or {opt output(va)}.{p_end}

{pstd}{opt output()} options and the other options available for export and import trade flows are reported here below.


{synoptset 52 tabbed}{...}
{synopthdr: Output options for decomposition of exports:}
{synoptline}
{synopt :{opt detailed}}ask for the detailed decomposition. This is the default if origin/destination are not specified.{p_end}
{synopt :{opt gtrade}}ask for gross trade. This is the default if origin/destination are specified.{p_end}
{synopt :{opt va}}ask for value-added{p_end}
{synopt :{opt dc}}ask for domestic content (dva+domestic double counting){p_end}
{synopt :{opt dva}}ask for domestic value-added{p_end}
{synopt :{opt fc}}ask for foreign content (fva+foreign double counting){p_end}
{synopt :{opt fva}}ask for foreign value-added{p_end}
{synopt :{opt gvc}}ask for global value chain related trade (gvcb+gvcf). It can be computed only if {opt perspective(exporter)} and {opt approach(source)} are selected, which are also the default options for any type of exports{p_end}
{synopt :{opt gvcb}}ask for backward global value chain related trade. It can be computed only if {opt perspective(exporter)} and {opt approach(source)} are selected, which are also the default options for any type of exports{p_end}
{synopt :{opt gvcf}}ask for forward global value chain related trade. It can be computed only if {opt perspective(exporter)} and {opt approach(source)} are selected, which are also the default options for any type of exports{p_end}
{synoptline}

{synoptset 52 tabbed}{...}
{synopthdr: Output options for decomposition of imports:}
{synoptline}
{synopt :{opt gtrade}}ask for gross trade. This is the default{p_end}
{synopt :{opt va}}ask for value-added{p_end}
{synoptline}

{marker icio_ori_dest_options}{...}
{synoptset 52 tabbed}{...}
{synopthdr: Origin and destination of the decomposed trade flow:}
{synoptline}
{synopt :{cmdab:orig:in(}{it:country_code} [, {it:sector_code}])} ask for the country/sector where the trade value is produced. Results for all countries or all sectors can be computed and displayed simultaneously, using the option {opt all} for {it:country_code} or {it:sector_code}.
{p_end}
{synopt :{cmdab:dest:ination(}{it:country_code} [, {it:sector_code}])} ask for the country/sector where the trade value is absorbed by final demand. Results for all countries or all sectors can be computed and displayed simultaneously, using the option {opt all} for {it:country_code} or {it:sector_code}. {p_end}
{synoptline}

{marker icio_options}{...}
{synoptset 52 tabbed}{...}
{synopthdr: General options:}
{synoptline}
{synopt :{opt save}({it:{help filename}} [, replace])}save the {cmd:icio} output (scalar, vector or matrix) in memory to an excel file. {opt replace} specifies that it is okay to replace {it:filename.xls} if it already exists{p_end}
{synopt :{opt gr:oups}({it:grouping_rule} {cmd:"}{it:user_defined_group}{cmd:"} [...])}specifies
a user-defined grouping of countries. For example, if {cmd:groups(prt,esp,ita,cyp,grc,mlt,tur "south_europe")} is specified, the
group "south_europe" will be created including Portugal, Spain, Italy, Cyprus, Greece, Malta and Turkey. The comma-separated list of country codes {cmd:prt,esp,ita,cyp,grc,mlt,tur} is in this case the {it:grouping_rule} while {cmd:"south_europe"}
is the {it:user_defined_group} name. Run {cmd:icio, info} for the list of available country codes for the currently loaded IO table{p_end}
{synoptline}


{marker examples}{...}
{title:Examples}

{pstd}{cmd:Set-up:}{p_end}
{synoptline}

{pstd}Load a specific year of the WIOD (last version) table{p_end}
{phang2}{cmd: icio_load, iciot(wiodn) year(2014)} {p_end}

{pstd}Display available country and sector codes for the loaded table{p_end}
{phang2}{cmd: icio, info} {p_end}

{pstd}{cmd:Supply-final demand linkages:}{p_end}
{synoptline}

{pstd}What is the GDP (value-added) produced by each country?{p_end}
{phang2}{cmd: icio, origin(all)} {p_end}

{pstd}How much value-added does each country produces in a given sector?{p_end}
{phang2}{cmd: icio, origin(all,19)} {p_end}

{pstd}What is the aggregate final demand of each country?{p_end}
{phang2}{cmd: icio, destination(all)} {p_end}

{pstd}What is the value-added originated in Germany and absorbed in China?{p_end}
{phang2}{cmd: icio, origin(deu) destination(chn)} {p_end}

{pstd}Where the value-added produced in the Italian sector 19 is absorbed?{p_end}
{phang2}{cmd: icio, origin(ita,19) destination(all)} {p_end}

{pstd}Which final demand sectors in China are the most important for the absorption of US-made value-added?{p_end}
{phang2}{cmd: icio, origin(usa) destination(chn,all)} {p_end}

{pstd}Where the GDP produced in each country is absorbed (and save the output as "supply_demand.xls" in the current working directory)?{p_end}
{phang2}{cmd: icio, origin(all) destination(all) save("supply_demand.xls")} {p_end}

{pstd}How much USMCA (former NAFTA) countries' final demand in sector 20 is satisfied by Chinese productions?{p_end}
{phang2}{cmd: icio, origin(chn) destination(usmca,20)  groups(usa, mex, can, "usmca")} {p_end}

{pstd}{cmd:Value-added trade and GVC participation:}{p_end}
{synoptline}

{pstd}Which part of a country’s total exports is home produced, i.e. is domestic GDP?{p_end}
{phang2}{cmd: icio, exporter(deu) output(dva)} {p_end}

{pstd}Which part of a country’s total exports can be traced back to other countries GDP?{p_end}
{phang2}{cmd: icio, exporter(deu) output(fva)} {p_end}

{pstd}Where the foreign value-added in German exports is produced?{p_end}
{phang2}{cmd: icio, origin(all) exporter(deu) output(fva)} {p_end}

{pstd}Considering the bilateral exports from Italy to Germany, where the Italian GDP (domestic VA) re-exported by Germany is absorbed?{p_end}
{phang2}{cmd: icio, exporter(ita) importer(deu) destination(all) output(dva)} {p_end}

{pstd}How can be obtained the complete breakdown by origin and destination of the value-added (both domestic and foreign) for Chinese exports to the US?{p_end}
{phang2}{cmd: icio, origin(all) exporter(chn) importer(usa) destination(all) output(va) save("CHN_to_USA.xls")} {p_end}

{pstd}Which share of the German exports is related to GVC, i.e. cross more than one border?{p_end}
{phang2}{cmd: icio, exporter(deu) output(gvc)} {p_end}

{pstd}Which share of the German exports is related to backward and forward GVC?{p_end}
{phang2}{cmd: icio, exporter(deu) output(gvcb)} {p_end}
{phang2}{cmd: icio, exporter(deu) output(gvcf)} {p_end}

{pstd}Note that it is possible to get a detailed assessment of trade in value-added and GVC participation regarding a certain trade flow running:{p_end}
{phang2}{cmd: icio, exporter(deu)} {p_end}
{phang2}{cmd: icio, exporter(usa)  importer(chn)} {p_end}
{phang2}{cmd: icio, exporter(deu,19)  importer(chn)} {p_end}

{pstd}How can the (corrected) Koopman et al. (2014) decomposition be retrieved using icio?{p_end}
{phang2}{cmd: icio, exporter(deu) perspective(world) approach(sink)} {p_end}

{pstd}{cmd:Trade policy analysis:}{p_end}
{synoptline}

{pstd}Which is the Chinese GDP that at any point in time, passes through a certain bilateral trade flow, say Chinese exports to the US? In other terms, what is the Chinese GDP potentially exposed to US tariffs on imports from China?{p_end}
{phang2}{cmd: icio, exp(chn) imp(usa) persp(bilat) output(dva)} {p_end}

{pstd}Which is the German GDP potentially exposed to US tariffs on all imports?{p_end}
{phang2}{cmd: icio, origin(deu) imp(usa) persp(importer) output(va)} {p_end}

{pstd}Which is the German GDP that could be affected by US tariffs on imports in sector 20?{p_end}
{phang2}{cmd: icio, origin(deu) imp(usa,20) persp(sectimp) output(va)} {p_end}

{pstd}Which is the exposure of US GDP to a Chinese tariff on US imports in sector 17?{p_end}
{phang2}{cmd: icio, exp(usa,17) imp(chn) persp(sectbil) output(dva)} {p_end}

{pstd}To what extent are Italian sectors exposed to a shock on German's exports in sector 20?{p_end}
{phang2}{cmd: icio, origin(ita,all) exp(deu,20) persp(sectexp) output(va)} {p_end}

{pstd}{cmd: Miscellaneous:}{p_end}
{synoptline}

{pstd}Store results in an excel file{p_end}
{phang2}{cmd: icio, exporter(usa,all) save("USA_exports_decomp.xls")} {p_end}

{pstd}Display (and save) large dimension results{p_end}
{phang2}{cmd: icio, exporter(usa,all) save("USA_exports_decomp.xls")} {p_end}
{phang2}{cmd: matlist r(detailed)} {p_end}

{phang2}{cmd: icio, origin(all) destination(all) save("supply_demand.xls")} {p_end}
{phang2}{cmd: matlist r(vby)} {p_end}

{pstd}Load a user-created table{p_end}
{phang2}{cmd: icio_load, iciot(user, userp("path_to_the_table_folder") tablen(ADB_2011.csv) countrylist(adb_countrylist.csv))} {p_end}

{pstd} Computes the detailed decomposition for a list of countries and stores the results in two matrices (dollar values and shares).{p_end}
{phang2}{cmd: loc countries "ita deu fra esp"} {p_end}
{phang2}{cmd: foreach c of local countries {c -(}} {p_end}
{phang2}{cmd: {space 4} qui icio, exp(`c')} {p_end}
{phang2}{cmd: {space 4} m st_matrix("total_exports", st_matrix("r(detailed)")[.,1])} {p_end}
{phang2}{cmd: {space 4} mat results_dollars = nullmat(results_dollars), total_exports} {p_end}
{phang2}{cmd: {space 4} m st_matrix("total_exports_shares", st_matrix("r(detailed)")[.,2])} {p_end}
{phang2}{cmd: {space 4} mat results_shares = nullmat(results_shares), total_exports_shares} {p_end}
{phang2}{cmd: }} {p_end}
{phang2}{cmd: matlist results_dollars} {p_end}
{phang2}{cmd: matlist results_shares} {p_end}


{title:Citations}

{pstd}
{cmd:icio} is not an official Stata command. It is a free contribution to the research community. See {browse "http://www.tradeconomics.com/icio/":tradeconomics.com/icio/} for information on last updates. Please cite it as such:

{phang}
Belotti, F., Borin, A., and Mancini, M. (2020). 
{browse "http://documents.worldbank.org/curated/en/587121582136569876/icio-Economic-Analysis-with-Inter-Country-Input-Output-Tables-in-Stata":icio: Economic Analysis with Inter-Country Input-Output tables in Stata}. 
Policy Research Working Paper; No. 9156. World Bank.

{pstd}
When measures of value-added in trade and GVC participation are used, please also cite:

{phang}
Borin, A., and Mancini, M. (2019). {browse "http://documents.worldbank.org/curated/en/639481554384583291/Measuring-What-Matters-in-Global-Value-Chains-and-Value-Added-Trade":Measuring What Matters in Global Value Chains and Value-Added Trade}. 
Policy Research Working Paper; No. 8804. World Bank.

{phang}
Remember to cite the original reference of the Inter-Country Input-Output database you are using with {cmd:icio}.

{pstd}
Further, you can cite the other works that have contributed to the development of each specific measure (see Borin and Mancini, 2019, for a critical discussion of the different accounting methodologies proposed in the literature).


{title:References}

{pstd}Borin, A., and Mancini, M. (2015). Follow the value added: bilateral gross export accounting. Economic Working Papers;  No. 1026. Bank of Italy.

{pstd}Borin, A., and Mancini, M. (2019). Measuring What Matters in Global Value Chains and Value-Added Trade. Policy Research Working Paper; No. 8804. World Bank.

{pstd}Hummels, D., Ishii, J. and Yi, K. M. (2001). The Nature and Growth of Vertical Specialization in World Trade. Journal of International Economics, Vol. 54, pp. 75-96.

{pstd}Koopman, R., Wang, Z., and Wei, S. (2014). Tracing Value-Added and Double Counting in Gross Exports.  American Economic Review, 104(2), 459-94.

{pstd}Johnson, R. C., (2018). Measuring Global Value Chains. Annual Review of Economics; Vol. 10:207-236.

{pstd}Johnson, R. C., and Noguera, G. (2012). Accounting for Intermediates: Production Sharing and Trade in Value Added. Journal of International Economics; Vol. 86, Iss. 2, pp. 224-236.

{pstd}Lenzen, M., Moran, D., Kanemoto, K., and Geschke, A. (2013). Building Eora: A Global Multi-regional Input-Output Database at High Country and Sector Resolution. Economic Systems Research; Vol. 25:1, pp.20-49.

{pstd}Los, B., and Timmer, M. P. (2018). Measuring Bilateral Exports of Value Added: A Unified Framework. NBER Working Paper; No. 24896.

{pstd}Los, B., Timmer, M. P., and de Vries, G. J. (2016). Tracing Value-Added and Double Counting in Gross Exports: Comment. American Economic Review; Vol. 106 (7), pp. 1958-66.

{pstd}Miroudot, S., and Ye, M. (2018). Tracing value-added and double counting in sales of foreign affiliates and domestic-owned companies. MPRA Paper; No. 85723. University Library of Munich.

{pstd}Nagengast, A.J., and Stehrer, R. (2016). Collateral imbalances in intra-European trade? Accounting for the differences between gross and value-added trade balances. The World Economy; Vol. 39, No. 9, 2016, pp. 1276–1306.

{pstd}OECD, Trade in Value Added database, 2018, oe.cd/tiva and http://www.oecd.org/sti/ind/inter-country-input-output-tables.htm.

{pstd}Timmer, M. P., Dietzenbacher, E., Los, B., Stehrer, R. and de Vries, G. J. (2015).  An Illustrated User Guide to the World Input-Output Database: the Case of Global Automotive Production.  Review of International Economics; Vol. 23, pp. 575–605.

{pstd}Wang, Z., Wei, S., and Zhu, K. (2013). Quantifying International Production Sharing at the Bilateral and Sector Levels. NBER Working Paper; No. 19677.


{title:Saved results}

{pstd}
{cmd:icio} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmd)}}{cmd:icio}{p_end}
{synopt:{cmd:r(table)}}the name of the loaded table{p_end}
{synopt:{cmd:r(year)}}the year of the loaded table{p_end}
{synopt:{cmd:r(version)}}the vintage of the loaded table{p_end}

{synopt:{cmd:r(exporter)}}the exporter country{p_end}
{synopt:{cmd:r(importer)}}the importer country{p_end}
{synopt:{cmd:r(perspective)}}the perspective{p_end}
{synopt:{cmd:r(approach)}}the approach{p_end}
{synopt:{cmd:r(origin)}}the origin country{p_end}
{synopt:{cmd:r(destination)}}the destination country{p_end}
{synopt:{cmd:r(output)}}output detail{p_end}

{synoptset 25 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(vby)}}matrix containing the results of the supply-final demand analysis{p_end}
{synopt:{cmd:r(detailed)}}matrix containing the detailed results of the value-added decomposition of trade{p_end}
{synopt:{cmd:r(gtrade)}}matrix containing the gross trade{p_end}
{synopt:{cmd:r(va)}}matrix containing the value-added{p_end}
{synopt:{cmd:r(dc)}}matrix containing the domestic content{p_end}
{synopt:{cmd:r(dva)}}matrix containing the domestic value-added{p_end}
{synopt:{cmd:r(fc)}}matrix containing the foreign content{p_end}
{synopt:{cmd:r(fva)}}matrix containing the foreign value-added{p_end}
{synopt:{cmd:r(gvc)}}matrix containing the GVC related exports{p_end}
{synopt:{cmd:r(gvcb)}}matrix containing the GVC related exports, backward{p_end}
{synopt:{cmd:r(gvcf)}}matrix containing the GVC related exports, forward{p_end}
{p2colreset}{...}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Department of Economics and Finance{p_end}
{pstd}University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Alessandro Borin{p_end}
{pstd}Bank of Italy{p_end}
{pstd}Rome, Italy{p_end}
{pstd}alessandro.borin@bancaditalia.it{p_end}

{pstd}Michele Mancini{p_end}
{pstd}Bank of Italy{p_end}
{pstd}Rome, Italy{p_end}
{pstd}michele.mancini@bancaditalia.it{p_end}
