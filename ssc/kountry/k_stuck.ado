/***** ISO 3 numeric codes *****/

program k_stuck
version 8.2

gen _ISO3N_ = .
replace _ISO3N_ = 4	if NAMES_STD=="Afghanistan"  
replace _ISO3N_ = 8	if NAMES_STD=="Albania"  
replace _ISO3N_ = 12	if NAMES_STD=="Algeria" 
replace _ISO3N_ = 16	if NAMES_STD=="American Samoa" 
replace _ISO3N_ = 20	if NAMES_STD=="Andorra" 
replace _ISO3N_ = 24	if NAMES_STD=="Angola" 
replace _ISO3N_ = 660 if NAMES_STD=="Anguilla"
replace _ISO3N_ = 28	if NAMES_STD=="Antigua and Barbuda" 
replace _ISO3N_ = 32	if NAMES_STD=="Argentina" 
replace _ISO3N_ = 51	if NAMES_STD=="Armenia" 
replace _ISO3N_ = 533 if NAMES_STD=="Aruba"
replace _ISO3N_ = 36	if NAMES_STD=="Australia" 
replace _ISO3N_ = 40	if NAMES_STD=="Austria" 
replace _ISO3N_ = 31	if NAMES_STD=="Azerbaijan" 
replace _ISO3N_ = 44	if NAMES_STD=="Bahamas" 
replace _ISO3N_ = 48	if NAMES_STD=="Bahrain" 
replace _ISO3N_ = 50	if NAMES_STD=="Bangladesh" 
replace _ISO3N_ = 52	if NAMES_STD=="Barbados" 
replace _ISO3N_ = 112 if NAMES_STD=="Belarus"
replace _ISO3N_ = 56	if NAMES_STD=="Belgium" 
replace _ISO3N_ = 58	if NAMES_STD=="Belgium-Luxembourg" 
replace _ISO3N_ = 84	if NAMES_STD=="Belize" 
replace _ISO3N_ = 204 if NAMES_STD=="Benin"
replace _ISO3N_ = 60	if NAMES_STD=="Bermuda" 
replace _ISO3N_ = 64	if NAMES_STD=="Bhutan" 
replace _ISO3N_ = 68	if NAMES_STD=="Bolivia" 
replace _ISO3N_ = 534 if NAMES_STD=="Bonaire"
replace _ISO3N_ = 70	if NAMES_STD=="Bosnia and Herzegovina" 
replace _ISO3N_ = 72	if NAMES_STD=="Botswana" 
replace _ISO3N_ = 76	if NAMES_STD=="Brazil" 
replace _ISO3N_ = 92	if NAMES_STD=="British Virgin Islands" 
replace _ISO3N_ = 96	if NAMES_STD=="Brunei" 
replace _ISO3N_ = 100 if NAMES_STD=="Bulgaria"
replace _ISO3N_ = 854 if NAMES_STD=="Burkina Faso"
replace _ISO3N_ = 108 if NAMES_STD=="Burundi"
replace _ISO3N_ = 116 if NAMES_STD=="Cambodia"
replace _ISO3N_ = 120 if NAMES_STD=="Cameroon"
replace _ISO3N_ = 124 if NAMES_STD=="Canada"
replace _ISO3N_ = 132 if NAMES_STD=="Cape Verde"
replace _ISO3N_ = 136 if NAMES_STD=="Cayman Islands"
replace _ISO3N_ = 140 if NAMES_STD=="Central African Republic"
replace _ISO3N_ = 148 if NAMES_STD=="Chad"
replace _ISO3N_ = 830 if NAMES_STD=="Channel Islands"
replace _ISO3N_ = 152 if NAMES_STD=="Chile"
replace _ISO3N_ = 156 if NAMES_STD=="China"
replace _ISO3N_ = 162 if NAMES_STD=="Christmas Islands"
replace _ISO3N_ = 166 if NAMES_STD=="Cocos Islands"
replace _ISO3N_ = 170 if NAMES_STD=="Colombia"
replace _ISO3N_ = 174 if NAMES_STD=="Comoros"
replace _ISO3N_ = 178 if NAMES_STD=="Congo"
replace _ISO3N_ = 184 if NAMES_STD=="Cook Islands"
replace _ISO3N_ = 188 if NAMES_STD=="Costa Rica"
replace _ISO3N_ = 384 if NAMES_STD=="Cote d'Ivoire"
replace _ISO3N_ = 191 if NAMES_STD=="Croatia"
replace _ISO3N_ = 192 if NAMES_STD=="Cuba"
replace _ISO3N_ = 535 if NAMES_STD=="Curacao"
replace _ISO3N_ = 196 if NAMES_STD=="Cyprus"
replace _ISO3N_ = 203 if NAMES_STD=="Czech Republic"
replace _ISO3N_ = 200 if NAMES_STD=="Czechoslavakia"
replace _ISO3N_ = 180 if NAMES_STD=="Democratic Republic of Congo"
replace _ISO3N_ = 208 if NAMES_STD=="Denmark"
replace _ISO3N_ = 262 if NAMES_STD=="Djibouti"
replace _ISO3N_ = 212 if NAMES_STD=="Dominica"
replace _ISO3N_ = 214 if NAMES_STD=="Dominican Republic"
replace _ISO3N_ = 218 if NAMES_STD=="Ecuador"
replace _ISO3N_ = 818 if NAMES_STD=="Egypt"
replace _ISO3N_ = 222 if NAMES_STD=="El Salvador"
replace _ISO3N_ = 226 if NAMES_STD=="Equatorial Guinea"
replace _ISO3N_ = 232 if NAMES_STD=="Eritrea"
replace _ISO3N_ = 233 if NAMES_STD=="Estonia"
replace _ISO3N_ = 231 if NAMES_STD=="Ethiopia"
replace _ISO3N_ = 234 if NAMES_STD=="Faeroe Islands"
replace _ISO3N_ = 238 if NAMES_STD=="Falkland Islands"
replace _ISO3N_ = 242 if NAMES_STD=="Fiji"
replace _ISO3N_ = 246 if NAMES_STD=="Finland"
replace _ISO3N_ = 250 if NAMES_STD=="France"
replace _ISO3N_ = 254 if NAMES_STD=="French Guiana"
replace _ISO3N_ = 258 if NAMES_STD=="French Polynesia"
replace _ISO3N_ = 266 if NAMES_STD=="Gabon"
replace _ISO3N_ = 270 if NAMES_STD=="Gambia"
replace _ISO3N_ = 268 if NAMES_STD=="Georgia"
replace _ISO3N_ = 278 if NAMES_STD=="German Democratic Republic"
replace _ISO3N_ = 276 if NAMES_STD=="Germany"
replace _ISO3N_ = 288 if NAMES_STD=="Ghana"
replace _ISO3N_ = 292 if NAMES_STD=="Gibraltar"
replace _ISO3N_ = 300 if NAMES_STD=="Greece"
replace _ISO3N_ = 304 if NAMES_STD=="Greenland"
replace _ISO3N_ = 308 if NAMES_STD=="Grenada"
replace _ISO3N_ = 312 if NAMES_STD=="Guadeloupe"
replace _ISO3N_ = 316 if NAMES_STD=="Guam"
replace _ISO3N_ = 320 if NAMES_STD=="Guatemala"
replace _ISO3N_ = 324 if NAMES_STD=="Guinea"
replace _ISO3N_ = 624 if NAMES_STD=="Guinea-Bissau"
replace _ISO3N_ = 328 if NAMES_STD=="Guyana"
replace _ISO3N_ = 332 if NAMES_STD=="Haiti"
replace _ISO3N_ = 340 if NAMES_STD=="Honduras"
replace _ISO3N_ = 344 if NAMES_STD=="Hong Kong"
replace _ISO3N_ = 348 if NAMES_STD=="Hungary"
replace _ISO3N_ = 352 if NAMES_STD=="Iceland"
replace _ISO3N_ = 356 if NAMES_STD=="India"
replace _ISO3N_ = 360 if NAMES_STD=="Indonesia"
replace _ISO3N_ = 364 if NAMES_STD=="Iran"
replace _ISO3N_ = 368 if NAMES_STD=="Iraq"
replace _ISO3N_ = 372 if NAMES_STD=="Ireland"
replace _ISO3N_ = 376 if NAMES_STD=="Israel"
replace _ISO3N_ = 380 if NAMES_STD=="Italy"
replace _ISO3N_ = 388 if NAMES_STD=="Jamaica"
replace _ISO3N_ = 392 if NAMES_STD=="Japan"
replace _ISO3N_ = 400 if NAMES_STD=="Jordan"
replace _ISO3N_ = 398 if NAMES_STD=="Kazakhstan"
replace _ISO3N_ = 404 if NAMES_STD=="Kenya"
replace _ISO3N_ = 296 if NAMES_STD=="Kiribati"
replace _ISO3N_ = 414 if NAMES_STD=="Kuwait"
replace _ISO3N_ = 417 if NAMES_STD=="Kyrgyz Republic"
replace _ISO3N_ = 418 if NAMES_STD=="Laos"
replace _ISO3N_ = 428 if NAMES_STD=="Latvia"
replace _ISO3N_ = 422 if NAMES_STD=="Lebanon"
replace _ISO3N_ = 426 if NAMES_STD=="Lesotho"
replace _ISO3N_ = 430 if NAMES_STD=="Liberia"
replace _ISO3N_ = 434 if NAMES_STD=="Libya"
replace _ISO3N_ = 438 if NAMES_STD=="Liechtenstein"
replace _ISO3N_ = 440 if NAMES_STD=="Lithuania"
replace _ISO3N_ = 442 if NAMES_STD=="Luxembourg"
replace _ISO3N_ = 446 if NAMES_STD=="Macao"
replace _ISO3N_ = 807 if NAMES_STD=="Macedonia"
replace _ISO3N_ = 450 if NAMES_STD=="Madagascar"
replace _ISO3N_ = 454 if NAMES_STD=="Malawi"
replace _ISO3N_ = 458 if NAMES_STD=="Malaysia"
replace _ISO3N_ = 462 if NAMES_STD=="Maldives"
replace _ISO3N_ = 466 if NAMES_STD=="Mali"
replace _ISO3N_ = 470 if NAMES_STD=="Malta"
replace _ISO3N_ = 584 if NAMES_STD=="Marshall Islands"
replace _ISO3N_ = 474 if NAMES_STD=="Martinique"
replace _ISO3N_ = 478 if NAMES_STD=="Mauritania"
replace _ISO3N_ = 480 if NAMES_STD=="Mauritius"
replace _ISO3N_ = 175 if NAMES_STD=="Mayotte"
replace _ISO3N_ = 484 if NAMES_STD=="Mexico"
replace _ISO3N_ = 583 if NAMES_STD=="Micronesia"
replace _ISO3N_ = 498 if NAMES_STD=="Moldova"
replace _ISO3N_ = 492 if NAMES_STD=="Monaco"
replace _ISO3N_ = 496 if NAMES_STD=="Mongolia"
replace _ISO3N_ = 499 if NAMES_STD=="Montenegro"
replace _ISO3N_ = 500 if NAMES_STD=="Montserrat"
replace _ISO3N_ = 504 if NAMES_STD=="Morocco"
replace _ISO3N_ = 508 if NAMES_STD=="Mozambique"
replace _ISO3N_ = 104 if NAMES_STD=="Myanmar"
replace _ISO3N_ = 516 if NAMES_STD=="Namibia"
replace _ISO3N_ = 520 if NAMES_STD=="Nauru"
replace _ISO3N_ = 524 if NAMES_STD=="Nepal"
replace _ISO3N_ = 528 if NAMES_STD=="Netherlands"
replace _ISO3N_ = 530 if NAMES_STD=="Netherlands Antilles"
replace _ISO3N_ = 540 if NAMES_STD=="New Caledonia"
replace _ISO3N_ = 554 if NAMES_STD=="New Zealand"
replace _ISO3N_ = 558 if NAMES_STD=="Nicaragua"
replace _ISO3N_ = 562 if NAMES_STD=="Niger"
replace _ISO3N_ = 566 if NAMES_STD=="Nigeria"
replace _ISO3N_ = 570 if NAMES_STD=="Niue"
replace _ISO3N_ = 408 if NAMES_STD=="North Korea"
replace _ISO3N_ = 578 if NAMES_STD=="Norway"
replace _ISO3N_ = 512 if NAMES_STD=="Oman"
replace _ISO3N_ = 586 if NAMES_STD=="Pakistan"
replace _ISO3N_ = 585 if NAMES_STD=="Palau"
replace _ISO3N_ = 275 if NAMES_STD=="Palestine"
replace _ISO3N_ = 591 if NAMES_STD=="Panama"
replace _ISO3N_ = 598 if NAMES_STD=="Papua New Guinea"
replace _ISO3N_ = 600 if NAMES_STD=="Paraguay"
replace _ISO3N_ = 604 if NAMES_STD=="Peru"
replace _ISO3N_ = 608 if NAMES_STD=="Philippines"
replace _ISO3N_ = 616 if NAMES_STD=="Poland"
replace _ISO3N_ = 620 if NAMES_STD=="Portugal"
replace _ISO3N_ = 630 if NAMES_STD=="Puerto Rico"
replace _ISO3N_ = 634 if NAMES_STD=="Qatar"
replace _ISO3N_ = 868 if NAMES_STD=="Republic of Vietnam"
replace _ISO3N_ = 638 if NAMES_STD=="Reunion"
replace _ISO3N_ = 642 if NAMES_STD=="Romania"
replace _ISO3N_ = 810 if NAMES_STD=="Russia"
replace _ISO3N_ = 646 if NAMES_STD=="Rwanda"
replace _ISO3N_ = 654 if NAMES_STD=="Saint Helena"
replace _ISO3N_ = 659 if NAMES_STD=="Saint Kitts and Nevis"
replace _ISO3N_ = 662 if NAMES_STD=="Saint Lucia"
replace _ISO3N_ = 666 if NAMES_STD=="Saint Pierre and Miquelon"
replace _ISO3N_ = 670 if NAMES_STD=="Saint Vincent and the Grenadines"
replace _ISO3N_ = 882 if NAMES_STD=="Samoa"
replace _ISO3N_ = 674 if NAMES_STD=="San Marino"
replace _ISO3N_ = 678 if NAMES_STD=="Sao Tome and Principe"
replace _ISO3N_ = 682 if NAMES_STD=="Saudi Arabia"
replace _ISO3N_ = 686 if NAMES_STD=="Senegal"
replace _ISO3N_ = 690 if NAMES_STD=="Seychelles"
replace _ISO3N_ = 694 if NAMES_STD=="Sierra Leone"
replace _ISO3N_ = 702 if NAMES_STD=="Singapore"
replace _ISO3N_ = 703 if NAMES_STD=="Slovak Republic"
replace _ISO3N_ = 705 if NAMES_STD=="Slovenia"
replace _ISO3N_ = 90  if NAMES_STD=="Solomon Islands" 
replace _ISO3N_ = 706 if NAMES_STD=="Somalia"
replace _ISO3N_ = 710 if NAMES_STD=="South Africa"
replace _ISO3N_ = 410 if NAMES_STD=="South Korea"
replace _ISO3N_ = 728 if NAMES_STD=="South Sudan"
replace _ISO3N_ = 724 if NAMES_STD=="Spain"
replace _ISO3N_ = 144 if NAMES_STD=="Sri Lanka"
replace _ISO3N_ = 736 if NAMES_STD=="Sudan"
replace _ISO3N_ = 740 if NAMES_STD=="Suriname"
replace _ISO3N_ = 748 if NAMES_STD=="Swaziland"
replace _ISO3N_ = 752 if NAMES_STD=="Sweden"
replace _ISO3N_ = 756 if NAMES_STD=="Switzerland"
replace _ISO3N_ = 760 if NAMES_STD=="Syria"
replace _ISO3N_ = 158 if NAMES_STD=="Taiwan"
replace _ISO3N_ = 762 if NAMES_STD=="Tajikistan"
replace _ISO3N_ = 834 if NAMES_STD=="Tanzania"
replace _ISO3N_ = 764 if NAMES_STD=="Thailand"
replace _ISO3N_ = 626 if NAMES_STD=="Timor"
replace _ISO3N_ = 768 if NAMES_STD=="Togo"
replace _ISO3N_ = 776 if NAMES_STD=="Tonga"
replace _ISO3N_ = 780 if NAMES_STD=="Trinidad and Tobago"
replace _ISO3N_ = 788 if NAMES_STD=="Tunisia"
replace _ISO3N_ = 792 if NAMES_STD=="Turkey"
replace _ISO3N_ = 795 if NAMES_STD=="Turkmenistan"
replace _ISO3N_ = 796 if NAMES_STD=="Turks and Caicos Islands"
replace _ISO3N_ = 798 if NAMES_STD=="Tuvalu"
replace _ISO3N_ = 800 if NAMES_STD=="Uganda"
replace _ISO3N_ = 804 if NAMES_STD=="Ukraine"
replace _ISO3N_ = 784 if NAMES_STD=="United Arab Emirates"
replace _ISO3N_ = 826 if NAMES_STD=="United Kingdom"
replace _ISO3N_ = 840 if NAMES_STD=="United States"
replace _ISO3N_ = 850 if NAMES_STD=="United States Virgin Islands"
replace _ISO3N_ = 858 if NAMES_STD=="Uruguay"
replace _ISO3N_ = 860 if NAMES_STD=="Uzbekistan"
replace _ISO3N_ = 548 if NAMES_STD=="Vanuatu"
replace _ISO3N_ = 336 if NAMES_STD=="Vatican"
replace _ISO3N_ = 862 if NAMES_STD=="Venezuela"
replace _ISO3N_ = 704 if NAMES_STD=="Vietnam"
replace _ISO3N_ = 876 if NAMES_STD=="Wallis and Futuna"
replace _ISO3N_ = 732 if NAMES_STD=="Western Sahara"
replace _ISO3N_ = 887 if NAMES_STD=="Yemen"
replace _ISO3N_ = 886 if NAMES_STD=="Yemen Arab Republic"
replace _ISO3N_ = 720 if NAMES_STD=="Yemen People's Republic"
replace _ISO3N_ = 890 if NAMES_STD=="Yugoslavia"
replace _ISO3N_ = 894 if NAMES_STD=="Zambia"
replace _ISO3N_ = 836 if NAMES_STD=="Zanzibar"
replace _ISO3N_ = 716 if NAMES_STD=="Zimbabwe"

end
exit
