{smcl}
{* *! version 1.0 09feb2016}{...}
{cmd:help iati}{right:dialog:  {bf:{dialog iati}}}
{right: {bf:version 1.0}}
{hline}

{title:Title}
{phang}
{bf: iati -- International Aid Transparency Initiative (IATI) Donor Activities Import}

{title:Syntax}
{p 8 17 2}
{cmd:iati}
{it:donorcode} 
[ 
{cmd:,}
{cmd:fy(}
{it:month} 
{cmd:)}
]

{title:Description}

{pstd}{cmd:iati} downloads and converts aid activity data from the IATI datastore API into Stata format. Converted data are saved in the working directory. Data are imported from:{p_end}

{phang}
{browse "http://datastore.iatistandard.org/docs/api/"}

{title:Donor Code}
{pstd}{cmd:donorcode} specifies a valid IATI organization ID/donor code to request the aid activity file for that organization. A number of larger IATI affiliated donors are listed below and have been confirmed to work correctly with this script.

{pstd}Other IATI organization ID/donor codes may also be imported, but have not been tested with the current version of this scripts. A full list of IATI publishers and associated ID codes is available here:{p_end}

{phang}
{browse "http://iatiregistry.org/publisher"} (Click on individual publishers and use the idenfier code to convert their activity data).{p_end}

{synoptset 20 tabbed}{...}
{synopthdr: IATI Donor Code}
{synoptline}
{syntab:BILATERAL}
{synopt:{opt AU-5}}Australia - Department of  Foreignffairs and Trade {p_end}
{synopt:{opt BE-10}}Belgian Development Cooperation {p_end}
{synopt:{opt CA-3}}Canada - Global Affairs Canada | Affaires mondiales Canada {p_end}
{synopt:{opt CH-4}}Switzerland - Swiss Agency for Development and Cooperation (SDC) {p_end}
{synopt:{opt DE-1}}Germany - Ministry for Economic Cooperation and Development {p_end}
{synopt:{opt DK-1}}Denmark - Danida - Danish Ministry of Foreigh Affairs {p_end}
{synopt:{opt ES-DIR3-E04585801}}Spain - Ministry of Foreign Affairs and Cooperation {p_end}
{synopt:{opt FI-3}}Finland - Ministry of Foreign Affairs {p_end}
{synopt:{opt FR-3}}France - Agence Française de Développement {p_end}
{synopt:{opt FR-6}}France - Ministry of Foreign Affairs and International Development {p_end}
{synopt:{opt GB-1}}UK - Department for International Development (DFID) {p_end}
{synopt:{opt NL-1}}Netherlands - Ministry of Foreign Affairs {p_end}
{synopt:{opt NZ-1}}New Zealand - Ministry of Foreign Affairs and Trade - New Zealand Aid Programme {p_end}
{synopt:{opt SE-0}}Sweden, through Swedish International Development Cooperation Agency (Sida) {p_end}
{synopt:{opt US-1}}USA - United States Agency for International Development (USAID) {p_end}
{synopt:{opt XI-IATI-EC_DEVCO}}European Commission - Development and Cooperation-EuropeAid {p_end}
{synopt:{opt XM-DAC-21-1}}Ireland - Department of Foreign Affairs and Trade {p_end}
{synopt:{opt XM-DAC-701-8}}Japan - Japan International Cooperation Agency {p_end}

{syntab:MULTILATERAL}
{synopt:{opt 41108}}International Fund for Agricultural Development (IFAD) {p_end}
{synopt:{opt 41119}}United Nations Population Fund (UNFPA) {p_end}
{synopt:{opt 41122}}United Nations Children's Fund (UNICEF) {p_end}
{synopt:{opt 44000}}The World Bank {p_end}
{synopt:{opt 46002}}African Development Bank {p_end}
{synopt:{opt 46004}}Asian Development Bank {p_end}
{synopt:{opt 47045}}The Global Fund to Fight AIDS, Tuberculosis and Malaria {p_end}
{synopt:{opt 47111}}Adaptation Fund {p_end}
{synopt:{opt 47122}}GAVI Alliance {p_end}
{synopt:{opt 47135}}Climate Investment Funds {p_end}
{synopt:{opt 411124}}UN Women {p_end}

{syntab:PRIVATE}
{synopt:{opt DAC-1601}}Bill & Melinda Gates Foundation

{title:Options}

{phang}{opt fy} specifies the starting month for the fiscal year to be applied to the donor data. 
By default, the {cmd:fy} option is automatically set to April (4) unless you specify otherwise.

{title:Examples} 

{pstd}Import activity data from Global Affairs Canada{p_end}
{phang}{stata "iati CA-3" : . iati CA-3}{p_end}

{pstd}Import activity data from the World Bank{p_end}
{phang}{stata "iati 44000" : . iati 44000}{p_end}

{pstd}Import activity data from USAID with a fiscal year starting in October{p_end}
{phang}{stata "iati US-1, fy(10)" : . iati US-1, fy(10)}

{pstd}Load {cmd: iati} dialog box interface:{p_end}
{phang}{stata "db iati" : . db iati}{p_end}

{title:Author}
{pstd}Liam Swiss{break}
Memorial University{break} 
lswiss@mun.ca{p_end}

