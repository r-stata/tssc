/***** Correlates of War home regions *****/
/* Europe=1, Middle East=2, Africa=3, Asia=4, North and South America=5 */

program k_geo_cow
version 8.2

generate str23 GEO = ""
replace GEO = "Europe" if NAMES_STD == "Albania" ///
   | NAMES_STD == "Andorra" ///
   | NAMES_STD == "Armenia" ///  
   | NAMES_STD == "Austria" /// 
   | NAMES_STD == "Austria-Hungary" ///  
   | NAMES_STD == "Azerbaijan" ///  
   | NAMES_STD == "Baden" /// 
   | NAMES_STD == "Bavaria" /// 
   | NAMES_STD == "Belarus" /// 
   | NAMES_STD == "Belgium" /// 
   | NAMES_STD == "Bosnia and Herzegovina" /// 
   | NAMES_STD == "Bulgaria" /// 
   | NAMES_STD == "Croatia" /// 
   | NAMES_STD == "Cyprus" /// 
   | NAMES_STD == "Czech Republic" /// 
   | NAMES_STD == "Czechoslovakia" /// 
   | NAMES_STD == "Denmark" /// 
   | NAMES_STD == "Estonia" /// 
   | NAMES_STD == "Finland" /// 
   | NAMES_STD == "France" /// 
   | NAMES_STD == "Georgia" /// 
   | NAMES_STD == "German Democratic Republic" ///  
   | NAMES_STD == "Germany" /// 
   | NAMES_STD == "Greece" /// 
   | NAMES_STD == "Hanover" /// 
   | NAMES_STD == "Hesse Electoral" /// 
   | NAMES_STD == "Hesse Grand Ducal" /// 
   | NAMES_STD == "Hungary" /// 
   | NAMES_STD == "Iceland" /// 
   | NAMES_STD == "Ireland" /// 
   | NAMES_STD == "Italy"
// must break up into smaller parts as stata complains
replace GEO = "Europe" if NAMES_STD == "Latvia" /// 
   | NAMES_STD == "Liechtenstein" /// 
   | NAMES_STD == "Lithuania" /// 
   | NAMES_STD == "Luxembourg" /// 
   | NAMES_STD == "Macedonia" /// 
   | NAMES_STD == "Malta" /// 
   | NAMES_STD == "Meckelnburg Schwerin" /// 
   | NAMES_STD == "Modena" /// 
   | NAMES_STD == "Moldova" /// 
   | NAMES_STD == "Monaco" /// 
   | NAMES_STD == "Netherlands" /// 
   | NAMES_STD == "Norway" /// 
   | NAMES_STD == "Parma" /// 
   | NAMES_STD == "Poland" /// 
   | NAMES_STD == "Portugal" /// 
   | NAMES_STD == "Romania" /// 
   | NAMES_STD == "Russia" /// 
   | NAMES_STD == "San Marino" /// 
   | NAMES_STD == "Saxony" /// 
   | NAMES_STD == "Slovak Republic" /// 
   | NAMES_STD == "Slovenia" /// 
   | NAMES_STD == "Spain" /// 
   | NAMES_STD == "Sweden" /// 
   | NAMES_STD == "Switzerland" /// 
   | NAMES_STD == "Tuscany" /// 
   | NAMES_STD == "Two Sicilies" /// 
   | NAMES_STD == "Ukraine" /// 
   | NAMES_STD == "United Kingdom" /// 
   | NAMES_STD == "Vatican" /// 
   | NAMES_STD == "Wuerttemburg" /// 
   | NAMES_STD == "Yugoslavia"  

replace GEO = "Middle East" if NAMES_STD == "Algeria" /// 
   | NAMES_STD == "Bahrain" /// 
   | NAMES_STD == "Egypt" /// 
   | NAMES_STD == "Iran" /// 
   | NAMES_STD == "Iraq" /// 
   | NAMES_STD == "Israel" /// 
   | NAMES_STD == "Jordan" /// 
   | NAMES_STD == "Kuwait" /// 
   | NAMES_STD == "Lebanon" /// 
   | NAMES_STD == "Libya" /// 
   | NAMES_STD == "Morocco" /// 
   | NAMES_STD == "Oman" /// 
   | NAMES_STD == "Qatar" /// 
   | NAMES_STD == "Saudi Arabia" /// 
   | NAMES_STD == "Sudan" /// 
   | NAMES_STD == "South Sudan" /// 
   | NAMES_STD == "Syria" /// 
   | NAMES_STD == "Tunisia" /// 
   | NAMES_STD == "Turkey" /// 
   | NAMES_STD == "United Arab Emirates" /// 
   | NAMES_STD == "Yemen" /// 
   | NAMES_STD == "Yemen Arab Republic" /// 
   | NAMES_STD == "Yemen People's Republic"  

replace GEO = "Africa" if NAMES_STD == "Angola" ///  
   | NAMES_STD == "Benin" /// 
   | NAMES_STD == "Botswana" /// 
   | NAMES_STD == "Burkina Faso" /// 
   | NAMES_STD == "Burundi" /// 
   | NAMES_STD == "Cameroon" /// 
   | NAMES_STD == "Cape Verde" /// 
   | NAMES_STD == "Central African Republic" /// 
   | NAMES_STD == "Chad" /// 
   | NAMES_STD == "Comoros" /// 
   | NAMES_STD == "Congo" /// 
   | NAMES_STD == "Cote d'Ivoire" /// 
   | NAMES_STD == "Democratic Republic of Congo" /// 
   | NAMES_STD == "Djibouti" /// 
   | NAMES_STD == "Equatorial Guinea" /// 
   | NAMES_STD == "Eritrea" /// 
   | NAMES_STD == "Ethiopia" /// 
   | NAMES_STD == "Gabon" /// 
   | NAMES_STD == "Gambia" /// 
   | NAMES_STD == "Ghana" /// 
   | NAMES_STD == "Guinea" /// 
   | NAMES_STD == "Guinea-Bissau" /// 
   | NAMES_STD == "Kenya" /// 
   | NAMES_STD == "Lesotho" /// 
   | NAMES_STD == "Liberia" /// 
   | NAMES_STD == "Madagascar" /// 
   | NAMES_STD == "Malawi" /// 
   | NAMES_STD == "Mali" /// 
   | NAMES_STD == "Mauritania" /// 
   | NAMES_STD == "Mauritius" /// 
   | NAMES_STD == "Mozambique" /// 
   | NAMES_STD == "Namibia" /// 
   | NAMES_STD == "Niger" /// 
   | NAMES_STD == "Nigeria" /// 
   | NAMES_STD == "Rwanda" /// 
   | NAMES_STD == "Sao Tome and Principe" /// 
   | NAMES_STD == "Senegal" /// 
   | NAMES_STD == "Seychelles" /// 
   | NAMES_STD == "Sierra Leone" /// 
   | NAMES_STD == "Somalia" /// 
   | NAMES_STD == "South Africa" /// 
   | NAMES_STD == "Swaziland" /// 
   | NAMES_STD == "Tanzania" /// 
   | NAMES_STD == "Togo" /// 
   | NAMES_STD == "Uganda" /// 
   | NAMES_STD == "Zambia" /// 
   | NAMES_STD == "Zanzibar" /// 
   | NAMES_STD == "Zimbabwe"  

replace GEO = "Asia" if NAMES_STD == "Afghanistan" /// 
   | NAMES_STD == "Australia" /// 
   | NAMES_STD == "Bangladesh" /// 
   | NAMES_STD == "Bhutan" /// 
   | NAMES_STD == "Brunei" /// 
   | NAMES_STD == "Cambodia" /// 
   | NAMES_STD == "China" /// 
   | NAMES_STD == "Fiji" /// 
   | NAMES_STD == "India" /// 
   | NAMES_STD == "Indonesia" /// 
   | NAMES_STD == "Japan" /// 
   | NAMES_STD == "Kazakhstan" /// 
   | NAMES_STD == "Kiribati" /// 
   | NAMES_STD == "Kyrgyz Republic" /// 
   | NAMES_STD == "Laos" /// 
   | NAMES_STD == "Malaysia" /// 
   | NAMES_STD == "Maldives" /// 
   | NAMES_STD == "Marshall Islands" /// 
   | NAMES_STD == "Micronesia" /// 
   | NAMES_STD == "Mongolia" /// 
   | NAMES_STD == "Myanmar" /// 
   | NAMES_STD == "Nauru" /// 
   | NAMES_STD == "Nepal" /// 
   | NAMES_STD == "New Zealand" /// 
   | NAMES_STD == "North Korea" /// 
   | NAMES_STD == "Pakistan" /// 
   | NAMES_STD == "Palau" /// 
   | NAMES_STD == "Papua New Guinea" /// 
   | NAMES_STD == "Philippines" /// 
   | NAMES_STD == "Republic of Vietnam" /// 
   | NAMES_STD == "Samoa" ///
   | NAMES_STD == "Singapore" /// 
   | NAMES_STD == "Solomon Islands" /// 
   | NAMES_STD == "South Korea" /// 
   | NAMES_STD == "Sri Lanka" /// 
   | NAMES_STD == "Taiwan" /// 
   | NAMES_STD == "Tajikistan" /// 
   | NAMES_STD == "Timor" /// 
   | NAMES_STD == "Thailand" /// 
   | NAMES_STD == "Tonga" /// 
   | NAMES_STD == "Turkmenistan" /// 
   | NAMES_STD == "Tuvalu" /// 
   | NAMES_STD == "Uzbekistan" /// 
   | NAMES_STD == "Vanuatu" /// 
   | NAMES_STD == "Vietnam" 


replace GEO = "North and South America" if NAMES_STD == "Antigua and Barbuda" /// 
   | NAMES_STD == "Argentina" /// 
   | NAMES_STD == "Bahamas" /// 
   | NAMES_STD == "Barbados" /// 
   | NAMES_STD == "Belize" /// 
   | NAMES_STD == "Bolivia" /// 
   | NAMES_STD == "Brazil" /// 
   | NAMES_STD == "Canada" /// 
   | NAMES_STD == "Chile" /// 
   | NAMES_STD == "Colombia" /// 
   | NAMES_STD == "Costa Rica" /// 
   | NAMES_STD == "Cuba" /// 
   | NAMES_STD == "Dominica" /// 
   | NAMES_STD == "Dominican Republic" /// 
   | NAMES_STD == "Ecuador" /// 
   | NAMES_STD == "El Salvador" /// 
   | NAMES_STD == "Grenada" /// 
   | NAMES_STD == "Guatemala" /// 
   | NAMES_STD == "Guyana" /// 
   | NAMES_STD == "Haiti" /// 
   | NAMES_STD == "Honduras" /// 
   | NAMES_STD == "Jamaica" /// 
   | NAMES_STD == "Mexico" /// 
   | NAMES_STD == "Nicaragua" /// 
   | NAMES_STD == "Panama" /// 
   | NAMES_STD == "Paraguay" /// 
   | NAMES_STD == "Peru" /// 
   | NAMES_STD == "Saint Kitts and Nevis" /// 
   | NAMES_STD == "Saint Lucia" /// 
   | NAMES_STD == "Saint Vincent and the Grenadines" /// 
   | NAMES_STD == "Suriname" /// 
   | NAMES_STD == "Trinidad and Tobago" /// 
   | NAMES_STD == "United States" /// 
   | NAMES_STD == "Uruguay" /// 
   | NAMES_STD == "Venezuela"  


end 
exit
