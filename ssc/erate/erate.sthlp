{smcl}
{* *! version 1.0.0 20February 2012}{...}
{vieweralsosee "[D] copy" "mansection D copy"}{...}
{vieweralsosee "[P] file" "mansection P file"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "erate##syntax"}{...}
{viewerjumpto "Description" "erate##description"}{...}
{viewerjumpto "Options" "erate##options"}{...}
{viewerjumpto "Examples" "erate##examples"}{...}

{hline}
help for {hi:erate}
{hline}


{title:Title}

{p 8 20 2}
    {hi:erate} {hline 2} Module to import up-to-date exchange rates between any currency pairs



{marker syntax}{...}
{title:Syntax}

{p 8 20 2}
{cmdab:erate} {help erate##options:basecurrency targetcurrency}{cmd:,} [{it:options}]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Options}
{synopt :{opt q:uantity(#)}}Gives the quantity of base currency for the exchange rate calculation.  If quantity is not specified, this is assumed to be 1.
{p_end}
{...}
{synopt :{cmdab:vars}}Store returned exchange rates as new variables.
{p_end}
{...}
{synoptline}
{p2colreset}



{marker description}{...}
{title:Description}

{p 6 6 2}
{hi:erate} is a module which allows exchange rate conversion between any two currency pairs.  {hi:erate} consults {browse "https://www.google.com/finance/converter":google's currency conversion tool}
and gives up-to-date rates.  Exchange rates are automatically saved as an {help return:rlist}, and can be consulted by displaying r({help erate##options:basecurrency}) and
r({help erate##options:targetcurrency}).  Alternatively the user can store results as variables by specifying the {cmdab:vars} option.  By default these are stored as _rateAAA where AAA will be replace
with the currency's {help erate##options:isocode}.

{p 6 6 2}
For details of the conversion tool consulted, see {browse "https://www.google.com/intl/en/help/currency_disclaimer.html":the online disclaimer}.


{marker options}{...}
{title:Further Details}
 {p 6 6 2}
The following currencies are available for conversion.

           Isocode       Currency
           {hline 80}
		{cmd:AED}	United Arab Emirates Dirham
		{cmd:ANG}	Netherlands Antilles Guilder
		{cmd:ARS}	Argentina Peso
		{cmd:AUD}	Australia Dollar
		{cmd:BGN}	Bulgaria Lev
		{cmd:BHD}	Bahrain Dinar
		{cmd:BND}	Brunei Darussalam Dollar
		{cmd:BOB}	Bolivia Boliviano
		{cmd:BRL}	Brazil Real
		{cmd:BWP}	Botswana Pula
		{cmd:CAD}	Canada Dollar
		{cmd:CHF}	Switzerland Franc
		{cmd:CLP}	Chile Peso
		{cmd:CNY}	China Yuan Renminbi
		{cmd:COP}	Colombia Peso
		{cmd:CRC}	Costa Rica Colon
		{cmd:CZK}	Czech Republic Koruna
		{cmd:DKK}	Denmark Krone
		{cmd:DOP}	Dominican Republic Peso
		{cmd:DZD}	Algeria Dinar
		{cmd:EGP}	Egypt Pound
		{cmd:EUR}	Euro Member Countries
		{cmd:FJD}	Fiji Dollar
		{cmd:GBP}	United Kingdom Pound
		{cmd:HKD}	Hong Kong Dollar
		{cmd:HNL}	Honduras Lempira
		{cmd:HRK}	Croatia Kuna
		{cmd:HUF}	Hungary Forint
		{cmd:IDR}	Indonesia Rupiah
		{cmd:ILS}	Israel Shekel
		{cmd:INR}	India Rupee
		{cmd:JMD}	Jamaica Dollar
		{cmd:JOD}	Jordan Dinar
		{cmd:JPY}	Japan Yen
		{cmd:KES}	Kenya Shilling
		{cmd:KRW}	Korea (South) Won
		{cmd:KWD}	Kuwait Dinar
		{cmd:KYD}	Cayman Islands Dollar
		{cmd:KZT}	Kazakhstan Tenge
		{cmd:LBP}	Lebanon Pound
		{cmd:LKR}	Sri Lanka Rupee
		{cmd:LTL}	Lithuania Litas
		{cmd:LVL}	Latvia Lat
		{cmd:MAD}	Morocco Dirham
		{cmd:MDL}	Moldova Leu
		{cmd:MKD}	Macedonia Denar
		{cmd:MUR}	Mauritius Rupee
		{cmd:MXN}	Mexico Peso
		{cmd:MYR}	Malaysia Ringgit
		{cmd:NAD}	Namibia Dollar
		{cmd:NGN}	Nigeria Naira
		{cmd:NIO}	Nicaragua Cordoba
		{cmd:NOK}	Norway Krone
		{cmd:NPR}	Nepal Rupee
		{cmd:NZD}	New Zealand Dollar
		{cmd:OMR}	Oman Rial
		{cmd:PEN}	Peru Nuevo Sol
		{cmd:PGK}	Papua New Guinea Kina
		{cmd:PHP}	Philippines Peso
		{cmd:PKR}	Pakistan Rupee
		{cmd:PLN}	Poland Zloty
		{cmd:PYG}	Paraguay Guarani
		{cmd:QAR}	Qatar Riyal
		{cmd:RON}	Romania New Leu
		{cmd:RSD}	Serbia Dinar
		{cmd:RUB}	Russia Ruble
		{cmd:SAR}	Saudi Arabia Riyal
		{cmd:SCR}	Seychelles Rupee
		{cmd:SEK}	Sweden Krona
		{cmd:SGD}	Singapore Dollar
		{cmd:SLL}	Sierra Leone Leone
		{cmd:SVC}	El Salvador Colon
		{cmd:THB}	Thailand Baht
		{cmd:TND}	Tunisia Dinar
		{cmd:TRY}	Turkey Lira
		{cmd:TTD}	Trinidad and Tobago Dollar
		{cmd:TWD}	Taiwan New Dollar
		{cmd:TZS}	Tanzania Shilling
		{cmd:UAH}	Ukraine Hryvna
		{cmd:UGX}	Uganda Shilling
		{cmd:USD}	United States Dollar
		{cmd:UYU}	Uruguay Peso
		{cmd:UZS}	Uzbekistan Som
		{cmd:VEF}	Venezuela Bolivar
		{cmd:VND}	Viet Nam Dong
		{cmd:YER}	Yemen Rial
		{cmd:ZAR}	South Africa Rand
          {hline 80}


{marker examples}{...}
{title:Examples}

    {hline}
{pstd}Convert 1 United States Dollar into Mexican Pesos {p_end}

{phang2}{cmd:. erate USD MXN}{p_end}

    {hline}
{pstd}Convert 1000 Australian Dollars into Chilean Pesos and store output as variables{p_end}

{phang2}{cmd:. erate AUD CLP, q(1250.50) vars}{p_end}
{phang2}{cmd:. sum _rateAUD _rateCLP}{p_end}


    {hline}


{title:Also see}

{psee}
If installed: {help usd}.


{title:Authors}

{pstd}
Damian C. Clarke, The University of Oxford. {browse "mailto:damian.clarke@economics.ox.ac.uk":damian.clarke@economics.ox.ac.uk}
{p_end}
{pstd}
Pavel Luengas Sierra, The University of Oxford. {browse "mailto:pavel.luengas-sierra@economics.ox.ac.uk":pavel.luengas-sierra@economics.ox.ac.uk}
{p_end}



