*! timestamp_zones version 1.0 (13/05/2016)
*! Lars Zeigermann

program define timestamp_zones
		version 12
		
		syntax, [REGion(string)]

		if "`region'" == ""{
			local region africa america antarctica arctic asia atlantic		///
				australia europe indian pacific others
		}
		else {
			local region = lower("`region'")
		}

		local africa Abidjan Accra Addis_Ababa Algiers Asmara Asmera Bamako	///
			Bangui Banjul Bissau Blantyre Brazzaville Bujumbura Cairo		///
			Casablanca Ceuta Conakry Dakar Dar_es_Salaam Djibouti Douala	///
			El_Aaiun Freetown Gaborone Harare Johannesburg Juba Kampala		///
			Khartoum Kigali Kinshasa Lagos Libreville Lome Luanda			///
			Lubumbashi Lusaka Malabo Maputo Maseru Mbabane Mogadishu		///
			Monrovia Nairobi Ndjamena Niamey Nouakchott Ouagadougou			///
			Porto-Novo Sao_Tome Timbuktu Tripoli Tunis Windhoek
		
		local america Adak Anchorage Anguilla Antigua Araguaina				///
			Buenos_Aires Catamarca Cordoba Jujuy La_Rioja Mendoza			///
			Rio_Gallegos Salta San_Juan San_Luis Tucuman Ushuaia			///
			Aruba Asuncion Atikokan Bahia Bahia_Banderas Barbados Belem		///
			Belize Blanc-Sablon Boa_Vista Bogota Boise  Cambridge_Bay	    ///
			Campo_Grande Cancun Caracas Cayenne Cayman Chicago Chihuahua	///
			Costa_Rica Creston Cuiaba Curacao Danmarkshavn Dawson			///
			Dawson_Creek Denver Detroit Dominica Edmonton Eirunepe			///
			El_Salvador Fort_Nelson Fortaleza Glace_Bay Godthab Goose_Bay	///
			Grand_Turk Grenada Guadeloupe Guatemala Guayaquil Guyana		///
			Halifax Havana Hermosillo Indianapolis Knox Marengo Petersburg	///
			Tell_City Vevay Vincennes Winamac Inuvik Iqaluit Jamaica Juneau ///
			Louisville Monticello Kralendijk La_Paz Lima Los_Angeles 		///
			Lower_Princes Maceio Managua Manaus Marigot Martinique			///
			Matamoros Mazatlan Menominee Merida	Metlakatla Mexico_City		///
			Miquelon Moncton Monterrey Montevideo Montserrat Nassau			///
			New_York Nipigon Nome Noronha Beulah Center New_Salem Ojinaga	///
			Panama Pangnirtung Paramaribo Phoenix Port-au-Prince 			///
			Port_of_Spain Porto_Acre Porto_Velho Puerto_Rico Rainy_River	///
			Rankin_Inlet Recife Regina Resolute Rio_Branco Rosario			///
			Santa_Isabel Santarem Santiago Santo_Domingo Sao_Paulo 			///
			Scoresbysund Shiprock Sitka St_Barthelemy St_Johns St_Kitts 	///
			St_Lucia St_Thomas St_Vincent Swift_Current Tegucigalpa Thule	///
			Thunder_Bay Tijuana Toronto	Tortola Vancouver Virgin Whitehorse	///
			Winnipeg Yakutat Yellowknife

		local antarctica Casey Davis DumontDUrville Macquarie Mawson		///
			McMurdoPalmer Rothera South_Pole Syowa Troll Vostok
		
		local arctic Longyearbyen
		
		local asia Aden Almaty Amman Anadyr Aqtau Aqtobe Ashgabat Ashkhabad	///
			Baghdad Bahrain Baku Bangkok Beirut Bishkek Brunei Calcutta		///
			Chita Choibalsan Chongqing Chungking Colombo Dacca Damascus		///
			Dhaka Dili Dubai Dushanbe Gaza Harbin Hebron Ho_Chi_Minh		///
			Hong_Kong Hovd Irkutsk Istanbul Jakarta Jayapura Jerusalem		///
			Kabul Kamchatka Karachi Kashgar Kathmandu Katmandu Khandyga		///
			Kolkata Krasnoyarsk Kuala_Lumpur Kuching Kuwait Macao Macau 	///
			Magadan Makassar Manila Muscat Nicosia Novokuznetsk Novosibirsk	///
			Omsk Oral Phnom_Penh Pontianak Pyongyang Qatar Qyzylorda		///
			Rangoon	Riyadh Saigon Sakhalin Samarkand Seoul Shanghai			///
			Singapore Srednekolymsk Taipei Tashkent Tbilisi Tehran Tel_Aviv	///
			Thimbu Thimphu Tokyo Ujung_Pandang Ulaanbaatar Ulan_Bator		///
			Urumqi Ust-Nera Vientiane Vladivostok Yakutsk Yekaterinburg		///
			Yerevan
		
		local atlantic Azores Bermuda Canary Cape_Verde Faeroe Faroe		///
			Jan_Mayen Madeira Reykjavik South_Georgia St_Helena Stanley
			
		local australia Adelaide Brisbane Broken_Hill Canberra Currie		///
			Darwin Eucla Hobart Lindeman Lord_Howe Melbourne Perth 			///
			Queensland South Sydney Tasmania Victoria West Yancowinna

		local europe Amsterdam Andorra Athens Belfast Belgrade Berlin		///
			Bratislava Brussels Bucharest Budapest Busingen Chisinau 		///
			Copenhagen Dublin Gibraltar Guernsey Helsinki Isle_of_Man		///
			Istanbul Jersey	Kaliningrad Kiev Lisbon Ljubljana London		///
			Luxembourg Madrid Malta Mariehamn Minsk Monaco Moscow Nicosia	///
			Oslo Paris Podgorica Prague Riga Rome Samara San_Marino 		///
			Sarajevo Simferopol Skopje Sofia Stockholm Tallinn Tirane 		///
			Tiraspol Uzhgorod Vaduz Vatican Vienna Vilnius Volgograd Warsaw	///
			Zagreb Zaporozhye Zurich

		local indian Antananarivo Chagos Christmas Cocos Comoro Kerguelen	///
			Mahe Maldives Mauritius Mayotte Reunion
			
		local pacific Apia Auckland Bougainville Chatham Chuuk Easter Efate	/// 
			Enderbury Fakaofo Fiji Funafuti Galapagos Gambier Guadalcanal 	///
			Guam Honolulu Johnston Kiritimati Kosrae Kwajalein Majuro		///
			Marquesas Midway Nauru Niue Norfolk Noumea Pago_Pago Palau		///
			Pitcairn Pohnpei Ponape Port_Moresby Rarotonga Saipan Samoa		///
			Tahiti Tarawa Tongatapu Truk Wake Wallis Yap
			
		local others UTC ETC GMT Zulu
		
		local invalid
		
		foreach i of local region {
			if ("``i''" != "") {			
				disp _newline upper("`i':")
				disp "``i''"
			}
			else {
				local invalid `invalid' `i'
			}
		}
		
		if "`invalid'" != "" {
			di as err _newline "The following regions are invalid: `invalid'"
		}

end
