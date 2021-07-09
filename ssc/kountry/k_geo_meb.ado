/***** Middle East "broad" *****/
// based on k_geo_undet.ado

program k_geo_meb
version 8.2

generate str11 GEO = ""
replace GEO = "Middle East" if NAMES_STD == "Bahrain" | ///
   NAMES_STD == "Egypt" | ///
   NAMES_STD == "Iran" | ///
   NAMES_STD == "Iraq" | ///
   NAMES_STD == "Israel" | ///
   NAMES_STD == "Jordan" | ///
   NAMES_STD == "Kuwait" | ///
   NAMES_STD == "Lebanon" | ///
   NAMES_STD == "Oman" | ///
   NAMES_STD == "Palestine" | ///
   NAMES_STD == "Qatar" | ///
   NAMES_STD == "Saudi Arabia" | ///
   NAMES_STD == "Syria" | ///
   NAMES_STD == "Turkey" | ///
   NAMES_STD == "United Arab Emirates" | ///
   NAMES_STD == "Yemen" | ///
   NAMES_STD == "Afghanistan" | ///
   NAMES_STD == "Algeria" | ///
   NAMES_STD == "Djibouti" | ///
   NAMES_STD == "Mauritania" | ///
   NAMES_STD == "Morocco" | ///
   NAMES_STD == "Libya" | ///
   NAMES_STD == "Pakistan" | ///
   NAMES_STD == "Somalia" | ///
   NAMES_STD == "Sudan" | ///
   NAMES_STD == "South Sudan" | /// 
   NAMES_STD == "Tunisia" | ///
   NAMES_STD == "Western Sahara"

replace GEO = "Africa" if NAMES_STD == "Burundi" | ///
   NAMES_STD == "Comoros" | ///
   NAMES_STD == "Eritrea" | ///
   NAMES_STD == "Ethiopia" | ///
   NAMES_STD == "Kenya" | ///
   NAMES_STD == "Madagascar" | /// 
   NAMES_STD == "Malawi" | ///
   NAMES_STD == "Mayotte" | ///
   NAMES_STD == "Mozambique" | /// 
   NAMES_STD == "Reunion" | ///
   NAMES_STD == "Rwanda" | ///
   NAMES_STD == "Seychelles" | /// 
   NAMES_STD == "Uganda" | ///
   NAMES_STD == "Tanzania" | ///
   NAMES_STD == "Zambia" | ///
   NAMES_STD == "Zimbabwe" | ///
   NAMES_STD == "Angola" | ///
   NAMES_STD == "Cameroon" | /// 
   NAMES_STD == "Central African Republic" | ///
   NAMES_STD == "Chad" | /// 
   NAMES_STD == "Congo" | /// 
   NAMES_STD == "Democratic Republic of Congo" | /// 
   NAMES_STD == "Equatorial Guinea" | /// 
   NAMES_STD == "Gabon" | /// 
   NAMES_STD == "Sao Tome and Principe" 

replace GEO = "Africa" if NAMES_STD == "Botswana" | ///
   NAMES_STD == "Lesotho" | /// 
   NAMES_STD == "Namibia" | /// 
   NAMES_STD == "South Africa" | /// 
   NAMES_STD == "Swaziland" | /// 
   NAMES_STD == "Benin" | /// 
   NAMES_STD == "Burkina Faso" | ///
   NAMES_STD == "Cape Verde" | ///
   NAMES_STD == "Cote d'Ivoire" | /// 
   NAMES_STD == "Gambia" | ///
   NAMES_STD == "Ghana" | ///
   NAMES_STD == "Guinea" | ///
   NAMES_STD == "Guinea-Bissau" | /// 
   NAMES_STD == "Liberia" | ///
   NAMES_STD == "Mali" | ///
   NAMES_STD == "Mauritius" | ///
   NAMES_STD == "Niger" | ///
   NAMES_STD == "Nigeria" | ///
   NAMES_STD == "Saint Helena" | ///
   NAMES_STD == "Senegal" | ///
   NAMES_STD == "Sierra Leone" | ///
   NAMES_STD == "Togo"
    
replace GEO = "Americas" if NAMES_STD == "Anguilla" | /// 
   NAMES_STD == "Antigua and Barbuda" | ///
   NAMES_STD == "Aruba" | ///
   NAMES_STD == "Bahamas" | ///
   NAMES_STD == "Barbados" | ///
   NAMES_STD == "British Virgin Islands" | ///
   NAMES_STD == "Cayman Islands" | ///
   NAMES_STD == "Cuba" | ///
   NAMES_STD == "Dominica" | ///
   NAMES_STD == "Dominican Republic" | ///
   NAMES_STD == "Grenada" | ///
   NAMES_STD == "Guadeloupe" | ///
   NAMES_STD == "Haiti" | ///
   NAMES_STD == "Jamaica" | ///
   NAMES_STD == "Martinique" | ///
   NAMES_STD == "Montserrat" | ///
   NAMES_STD == "Netherlands Antilles" | ///
   NAMES_STD == "Puerto Rico" | ///
   NAMES_STD == "Saint Kitts and Nevis" | ///
   NAMES_STD == "Saint Lucia" | ///
   NAMES_STD == "Saint Vincent and the Grenadines" | ///
   NAMES_STD == "Trinidad and Tobago" | ///
   NAMES_STD == "Turks and Caicos Islands" | ///
   NAMES_STD == "United States Virgin Islands"
    
replace GEO = "Americas" if NAMES_STD == "Belize" | /// 
   NAMES_STD == "Costa Rica" | ///
   NAMES_STD == "El Salvador" | /// 
   NAMES_STD == "Guatemala" | ///
   NAMES_STD == "Honduras" | ///
   NAMES_STD == "Mexico" | ///
   NAMES_STD == "Nicaragua" | ///
   NAMES_STD == "Panama" | ///
   NAMES_STD == "Argentina" | ///  
   NAMES_STD == "Bolivia" | ///
   NAMES_STD == "Brazil" | ///
   NAMES_STD == "Chile" | ///
   NAMES_STD == "Colombia" | ///
   NAMES_STD == "Ecuador" | ///
   NAMES_STD == "Falkland Islands" | ///
   NAMES_STD == "French Guiana" | ///
   NAMES_STD == "Guyana" | ///
   NAMES_STD == "Paraguay" | ///
   NAMES_STD == "Peru" | ///
   NAMES_STD == "Suriname" | ///
   NAMES_STD == "Uruguay" | ///
   NAMES_STD == "Venezuela" | ///
   NAMES_STD == "Bermuda" | ///  
   NAMES_STD == "Canada" | /// 
   NAMES_STD == "Greenland" | /// 
   NAMES_STD == "Saint Pierre and Miquelon" | ///
   NAMES_STD == "United States"
    
replace GEO = "Asia" if NAMES_STD == "Kazakhstan" | ///  
   NAMES_STD == "Kyrgyz Republic" | ///
   NAMES_STD == "Tajikistan" | /// 
   NAMES_STD == "Turkmenistan" | /// 
   NAMES_STD == "Uzbekistan" | ///
   NAMES_STD == "China" | /// 
   NAMES_STD == "Hong Kong" | ///
   NAMES_STD == "Macao" | ///
   NAMES_STD == "South Korea" | /// 
   NAMES_STD == "Japan" | /// 
   NAMES_STD == "Mongolia" | /// 
   NAMES_STD == "North Korea" | ///
   NAMES_STD == "Bangladesh" | /// 
   NAMES_STD == "Bhutan" | ///
   NAMES_STD == "India" | ///
   NAMES_STD == "Maldives" | ///
   NAMES_STD == "Nepal" | ///
   NAMES_STD == "Sri Lanka" | ///
   NAMES_STD == "Brunei" | /// 
   NAMES_STD == "Cambodia" | ///
   NAMES_STD == "Indonesia" | ///
   NAMES_STD == "Laos" | ///
   NAMES_STD == "Malaysia" | ///
   NAMES_STD == "Myanmar" | ///
   NAMES_STD == "Philippines" | /// 
   NAMES_STD == "Singapore" | ///
   NAMES_STD == "Thailand" | ///
   NAMES_STD == "Timor" | ///
   NAMES_STD == "Vietnam" | ///
   NAMES_STD == "Armenia" | /// 
   NAMES_STD == "Azerbaijan" | ///
   NAMES_STD == "Cyprus" | ///
   NAMES_STD == "Georgia"
    
replace GEO = "Europe" if NAMES_STD == "Belarus" | /// 
   NAMES_STD == "Bulgaria" | /// 
   NAMES_STD == "Czech Republic" | /// 
   NAMES_STD == "Hungary" | /// 
   NAMES_STD == "Moldova" | /// 
   NAMES_STD == "Poland" | ///
   NAMES_STD == "Romania" | /// 
   NAMES_STD == "Russia" | ///
   NAMES_STD == "Slovak Republic" | ///
   NAMES_STD == "Ukraine" | ///
   NAMES_STD == "Channel Islands" | ///   
   NAMES_STD == "Denmark" | ///
   NAMES_STD == "Estonia" | ///
   NAMES_STD == "Faeroe Islands" | /// 
   NAMES_STD == "Finland" | ///
   NAMES_STD == "Iceland" | ///
   NAMES_STD == "Ireland" | ///
   NAMES_STD == "Latvia" | ///
   NAMES_STD == "Lithuania" | ///
   NAMES_STD == "Norway" | ///
   NAMES_STD == "Sweden" | ///
   NAMES_STD == "United Kingdom"
    
replace GEO = "Europe" if NAMES_STD == "Albania" | ///   
   NAMES_STD == "Andorra" | /// 
   NAMES_STD == "Bosnia and Herzegovina" | /// 
   NAMES_STD == "Croatia" | ///
   NAMES_STD == "Gibraltar" | ///
   NAMES_STD == "Greece" | ///
   NAMES_STD == "Vatican" | ///
   NAMES_STD == "Italy" | ///
   NAMES_STD == "Malta" | ///
   NAMES_STD == "Portugal" | ///
   NAMES_STD == "San Marino" | ///
   NAMES_STD == "Yugoslavia" | ///
   NAMES_STD == "Slovenia" | ///
   NAMES_STD == "Spain" | ///
   NAMES_STD == "Macedonia" | ///
   NAMES_STD == "Austria" | ///   
   NAMES_STD == "Belgium" | ///
   NAMES_STD == "France" | ///
   NAMES_STD == "Germany" | ///
   NAMES_STD == "Liechtenstein" | /// 
   NAMES_STD == "Luxembourg" | ///
   NAMES_STD == "Monaco" | ///
   NAMES_STD == "Netherlands" | ///
   NAMES_STD == "Switzerland"
   
replace GEO = "Oceania" if NAMES_STD == "Australia" | ///   
   NAMES_STD == "New Zealand" | ///
   NAMES_STD == "Fiji" | ///    
   NAMES_STD == "New Caledonia" | ///
   NAMES_STD == "Papua New Guinea" | /// 
   NAMES_STD == "Solomon Islands" | ///
   NAMES_STD == "Vanuatu" | ///
   NAMES_STD == "Micronesia" | ///    
   NAMES_STD == "Guam" | ///
   NAMES_STD == "Kiribati" | ///
   NAMES_STD == "Marshall Islands" | /// 
   NAMES_STD == "Micronesia" | ///
   NAMES_STD == "Nauru" | ///
   NAMES_STD == "Palau" | ///
   NAMES_STD == "American Samoa" | ///
   NAMES_STD == "Cook Islands" | ///
   NAMES_STD == "French Polynesia" | ///
   NAMES_STD == "Niue" | ///
   NAMES_STD == "Samoa" | ///
   NAMES_STD == "Tonga" | ///
   NAMES_STD == "Tuvalu" | ///
   NAMES_STD == "Wallis and Futuna"

end
exit
