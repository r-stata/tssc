*! version 0.1 12OCT2019 Matteo Ruzzante ruzzante.matteo@gmail.com

// Reggae music random generator

cap prog drop reggae_music
	prog def  reggae_music

	syntax	,									/// No variable required
												///
	   [BRowse]									/// Directly open the link in browser
	   [NUMber(numlist int min=1)]				/// Number of songs (must be an interger equal or greater than 1)
	   [PLAYlist]								/// Full playlist
	   [PLATFORM(string)]						/// Music platform or website
	   [ARTIST(string)]							/// Name of the artist
	   [COUNTRY(string)]						/// Country of origin of (one of) the artist(s)
	   [SEX(string)]        					/// Sex of (one of) the artist(s)
	   
	   
	// Set minimum version for this command
	version 10
		
	if "`playlist'" != "" {
		
		// Error for playlist and other option incorrectly used together
		
		foreach optionName in number artist country sex {
	
			if "``optionName''" != "" {
			
				noi di as error "Option {bf:`optionName'} may not be used in combination with option {bf:playlist}."
						  error  197
			}
		}
	}
	
	// Transform all option strings
	foreach optionName in platform artist country sex {
		
		local `optionName' =  trim("``optionName''") //trim() is older syntax, compare to strtrim() in Stata 15 and newer
		local `optionName' = lower("``optionName''")
	}
	
	// If 'platform' option is used, check that it exists in our package
	if "`platform'" != "" {
	
		if "`platform'" != "youtube" &  "`platform'" != "spotify" {
			
			noi di as error "The {bf:platform} you selected is not available in our package."
			noi di as error "Feel free to suggest it by opening an issue in:""
			noi di as error `" {browse "https://github.com/MRuzzante/Jah-referencing/issues":https://github.com/MRuzzante/Jah-referencing/issues}
					  exit
		}
	}	
	
	// If `platform' option is not used, we will use Youtube
	if "`platform'" == "" local platform "youtube"
	
	// If 'playlist' option is selected, we display the link to the Youtube playlist and exit the program
	if "`playlist'" != "" {
		
		if "`platform'" == "youtube" {
			
			di as txt   "Enjoy the reggae playlist for rasta Stata users in Youtube."
			di as txt   "Blessing!"
			di		    ""
			di as text 			`"  {browse "https://www.youtube.com/watch?v=hzqFmXZ8tOE&list=PLC-aST3UH2m5tfv3RALnUA-z753ZDYSm7":https://www.youtube.com/watch?v=hzqFmXZ8tOE&list=PLC-aST3UH2m5tfv3RALnUA-z753ZDYSm7}
			
			if "`browse'" != "" view browse "https://www.youtube.com/watch?v=hzqFmXZ8tOE&list=PLC-aST3UH2m5tfv3RALnUA-z753ZDYSm7"
			exit
		}
		
		if "`platform'" == "spotify" {
			
			di as txt   "Enjoy the reggae playlist for rasta Stata users in Spotify."
			di as txt   "Blessing!"
			di		    ""
			di as text 			`"  {browse "https://open.spotify.com/user/ruzzante.matteo/playlist/100XebrUHtUthBEoaKo0Ge?si=d592jMbFRl2EDf9w0QlPLA":https://open.spotify.com/user/ruzzante.matteo/playlist/100XebrUHtUthBEoaKo0Ge?si=d592jMbFRl2EDf9w0QlPLA}
			
			if "`browse'" != "" view browse "https://open.spotify.com/user/ruzzante.matteo/playlist/100XebrUHtUthBEoaKo0Ge?si=d592jMbFRl2EDf9w0QlPLA"
			exit
		}
	}
		
	// Error for artist, country and/or sex option incorrectly used together
	if   "`artist'" != "" {
	
		if "`country'" != "" {
			
				noi di as error "Option {bf:country} may not be used in combination with option {bf:artist}."
						  error  197
		}
		
		if "`sex'" != "" {
			
				noi di as error "Option {bf:sex} may not be used in combination with option {bf:artist}."
						  error  197
		}
	}	
	
	// If 'number' option is not used, we display one song
	if 	 "`number'" == "" local number = 1
		
	// List artists available in the package
	#d	;
		local  artistList
		
			   99posse
			   alborosie anthonyb
			   bobmarley busysignal
			   chronixx claudialeitte colliebuddz
			   damianmarley diplomatico dubinc duobucolico
			   etana
			   forelock
			   gentleman
			   hempresssativa
			   jah9 jahcure jimmycliff juniorkelly
			   kabakapyramid kathrynaria koffee konshens kymanimarley
			   mamamarjas mellowmood morganheritage mortimer
			   naâman nas natiruts
			   protoje
			   queenifrica
			   ragingfyah randyvalentine rc richiecampbell richiespice ritamarley romainvirgo
			   saralugo sizzla soja stephenmarley sudsoundsystem
			   tarrusriley terroniuniti thewailers tribalseeds
			   ziggymarley
		;
	#d	cr
	
	// Remove hyphen
	if   "`artist'"	   == "ky-manimarley"						///
	local  artist 	    = "kymanimarley"
	
	// Replace too long artists
	if   "`artist'"	   == "diplomaticoeilcollettivoninconanco"	///
	local  artist 	    = "diplomatico"
	
	// If 'artist' option is used, check that artist exists in our list
	if	 "`artist'"	   != "" {
		
		local artistIfList  ""
		
		foreach artistName of local artistList {
		
			local artistIfList `" `artistIfList' "`artist'" != "`artistName'" & "'
		}
		
		if `artistIfList' ("rasta" == "rasta") {
			 
				 noi di as error "The {bf:artist} you selected is not present in our playlist."
				 noi di as error "If he/she is a reggae artist you like, feel free to suggest it by opening an issue in:"
				 noi di as error `" {browse "https://github.com/MRuzzante/Jah-referencing/issues":https://github.com/MRuzzante/Jah-referencing/issues} "'
						   exit
		}
	}
	
	// If 'artist' option is used, we switch artist locals on
	if	 "`artist'"	   != "" {
		
		foreach artistName of local artistList {
						
			// Start local
			local `artistName' = 0
			
			// Turn local to 1 if the name matches
			if "`artist'" == "`artistName'" local `artistName' = 1
		}		
	} 
	
	// If 'artist' option is not used, we switch all artist locals on
	if	 "`artist'"	   == "" {
		
		foreach artistName of local artistList {
		
			local `artistName' = 1
		}
	}
	
	// Do the same process for countries
	local countryList jamaica brazil canada france germany italy portugal unitedstates
	
	if    inlist("`country'", "us", "usa", "theunitedstates")	///
	local country 	    	= "unitedstates"
	
	if	 "`country'"	   != "" {
		
		if   "`country'"   != "jamaica" 	 & ///
			 "`country'"   != "brazil"		 & ///
			 "`country'"   != "canada"   	 & ///
			 "`country'"   != "france"   	 & ///
			 "`country'"   != "germany" 	 & ///
			 "`country'"   != "italy"   	 & ///
			 "`country'"   != "portugal"   	 & ///
			 "`country'"   != "unitedstates" {
				
				 noi di as error "The {bf:country} you selected is not present in our playlist."
				 noi di as error "If you like any reggae artist from there, feel free to suggest it by opening an issue in:""
				 noi di as error `" {browse "https://github.com/MRuzzante/Jah-referencing/issues":https://github.com/MRuzzante/Jah-referencing/issues}
						   exit
		}
	}
	
	if	 "`country'"	   != "" {
	
		foreach countryName of local countryList {
			
											  local `countryName' = 0
			if "`country'" == "`countryName'" local `countryName' = 1
		}
	}
	
	if	  "`country'"	   == "" {
	
		foreach countryName of local countryList {
		
			local `countryName' = 1
		}
	}
	
	// Do the same process for sex
	if	 "`sex'"	   != "" {
		
		if   "`sex'"   != "female" & ///
			 "`sex'"   != "male"   {
				
				 noi di as error "The {bf:sex} you selected is not available. Please make sure to type Female or Male in the option argument."
						   exit
		}
	}
	
	if	 "`sex'"	   != "" {
	
		foreach sexType in female male {
			
									  local `sexType' = 0
			if "`sex'" == "`sexType'" local `sexType' = 1
		}
	}
	
	if	  "`sex'"   == "" {
	
		foreach sexType in female male {
		
			local `sexType' = 1
		}
	}
	
	
	// Initialize song counter
	local  totalSong  = 127
	local  songCount  =   0
	
	// If the number of songs chosen is larger than the total, we print an error
	if 	  `number'    >   `=`totalSong'-2' { //two less than the actual total to allow command to stop,
										     //otherwise, it will keep searching for a song without success,
											 //after all 'chooseSong' locals are shut down
		
		   noi di as error "The {bf:number} you selected exceeds the number of songs available in the playlist. Please make sure to choose a number lower than `totalSong'."
		   exit
	}
	
	forv   songNumber = 1/`totalSong' {
		
		local chooseSong`songNumber' = 1
	}
	
	// Randomly pick song(s)
	// ---------------------
	
	// Loop on number of songs
	while `songCount' 	 < `number' {
		
		// Set locals for randomizing song
		local  rangeMin	 =  0
		local  interval	 =  1 		  / `totalSong'
		local  rangeMax	 = `rangeMin' + `interval'
	
		// Generate random number
		local randomSong = runiform()

		// 1) "Curre Curre Guagliò Still Running"
		if `randomSong' <= `rangeMax' {
			if (`99posse' == 1 | `alborosie' == 1 | `mamamarjas' == 1) & `italy' == 1 & (`male' == 1 | `female' == 1) & `chooseSong1' == 1 {
				
				di  		""
				di as txt  `""A Sud curre cumbà"'
				di as txt  `" A Nord curre cumbà"'
				di as txt  `" Tandè'anna c'am'a scappà"'
				di as txt  `" Camine nu te ferma.""'

				di as txt   " {bf:99 Posse & Alborosie & Mama Marjas}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=E4aVwfumPkk":https://www.youtube.com/watch?v=E4aVwfumPkk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=E4aVwfumPkk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2T4bVyARdbXLMzQ3XOCHyU?si=aGPP7hjbRz-Pf_nowqa3JQ":https://open.spotify.com/track/2T4bVyARdbXLMzQ3XOCHyU?si=aGPP7hjbRz-Pf_nowqa3JQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2T4bVyARdbXLMzQ3XOCHyU?si=aGPP7hjbRz-Pf_nowqa3JQ"
				}
				
				local chooseSong1 = 0
				local songCount   = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 2) "Combat Reggae"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`99posse' == 1 | `mamamarjas' == 1) & `italy' == 1 & (`male' == 1 | `female' == 1) & `chooseSong2' == 1 {
				
				di  		""
				di as txt  `""Combat reggae I see the light"'
				di as txt  `" Combat reggae roots of my style.""'
				
				di as txt   " {bf:99 Posse & Mama Marjas}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=N_mwZugEs28":https://www.youtube.com/watch?v=N_mwZugEs28}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=N_mwZugEs28"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6g2pNZmhhPoxU03trjii4M?si=-zUYuEzeQKGdTkjozSKuBg":https://open.spotify.com/track/6g2pNZmhhPoxU03trjii4M?si=-zUYuEzeQKGdTkjozSKuBg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6g2pNZmhhPoxU03trjii4M?si=-zUYuEzeQKGdTkjozSKuBg"
				}
				
				local chooseSong2 = 0
				local songCount   = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 3) "Herbalist"
        if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong3' {
			
				di  		""
				di as txt  `""Babylon dem thief my herb dem thief my herb.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=MYp_gJQwRx8":https://www.youtube.com/watch?v=MYp_gJQwRx8}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=MYp_gJQwRx8"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1UOhKnE2fZJuGdB7ssn9nf?si=qQdKxu_tQoa2mp55McLfQg":https://open.spotify.com/track/1UOhKnE2fZJuGdB7ssn9nf?si=qQdKxu_tQoa2mp55McLfQg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1UOhKnE2fZJuGdB7ssn9nf?si=qQdKxu_tQoa2mp55McLfQg"
				}
				
				local chooseSong3 = 0
				local songCount   = 1 + `songCount'
			}
        }

        local rangeMin    = `rangeMin' + `interval'
        local rangeMax    = `rangeMax' + `interval' 
		
		// 4) "Kingston Town"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong4' {
			
				di  		""
				di as txt  `""Sipple it down down, sipple it down down."'
				di as txt  `" It's a rudeboy town, it's Kingston Town.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=w0c_dv0TUmU":https://www.youtube.com/watch?v=w0c_dv0TUmU}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=w0c_dv0TUmU"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2OHQhOiGIYaXqqJVIMpNrF?si=pt2K4eo7QOG6W-3sAyD7Xg":https://open.spotify.com/track/2OHQhOiGIYaXqqJVIMpNrF?si=pt2K4eo7QOG6W-3sAyD7Xg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2OHQhOiGIYaXqqJVIMpNrF?si=pt2K4eo7QOG6W-3sAyD7Xg"
				}
				
				local chooseSong4 = 0
				local songCount   = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 5) "Living Dread"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong5' {
				
				di  		""
				di as txt  `""I and I are the living dread"'
				di as txt  `" Inna these ya dawn of the living dead.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=FxEubwOGzqY":https://www.youtube.com/watch?v=FxEubwOGzqY}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=FxEubwOGzqY"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1desgoyWi5qgAHbtC0VRQJ?si=kyY7od-LTYyY2MmQNMOltA":https://open.spotify.com/track/1desgoyWi5qgAHbtC0VRQJ?si=kyY7od-LTYyY2MmQNMOltA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1desgoyWi5qgAHbtC0VRQJ?si=kyY7od-LTYyY2MmQNMOltA"
				}
				
				local chooseSong5 = 0
				local songCount   = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 6) "No Cocaine"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong6' {
				
				di  		""
				di as txt  `""No coca, no coca, no coca inna mi brain"'
				di as txt  `" No coca and nuh ero inga go inna mi vein.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=4dYSkCVcPuc":https://www.youtube.com/watch?v=4dYSkCVcPuc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=4dYSkCVcPuc"
				}
				
				if "`platform'" == "spotify" {
				
					di as text			`"  {browse "https://open.spotify.com/track/07QuKUTu5O40AibYYPx98I?si=CCTF9h40Syu98E_0aVuWUQ":https://open.spotify.com/track/07QuKUTu5O40AibYYPx98I?si=CCTF9h40Syu98E_0aVuWUQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/07QuKUTu5O40AibYYPx98I?si=CCTF9h40Syu98E_0aVuWUQ"
				}
				
				local chooseSong6 = 0
				local songCount   = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 7) "Poser"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong7' {
				
				di  		""
				di as txt  `""Dem a poser, nuff a dem a poser"'
				di as txt  `" Yes dem a poser, many a dem a pose.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=4Ois3zB7SJ4":https://www.youtube.com/watch?v=4Ois3zB7SJ4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=4Ois3zB7SJ4"
				}
				
				if "`platform'" == "spotify" {
				
					di as text			`"  {browse "https://open.spotify.com/track/3v41srJ4jzBxzN066bfu9N?si=kLa328OvTMK1bDge3-tWYg":https://open.spotify.com/track/3v41srJ4jzBxzN066bfu9N?si=kLa328OvTMK1bDge3-tWYg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3v41srJ4jzBxzN066bfu9N?si=kLa328OvTMK1bDge3-tWYg"
				}
				
				local chooseSong7 = 0
				local songCount   = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 8) "Rastafari Anthem"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong8' {
				
				di  		""
				di as txt  `""I and I a praise"'
				di as txt  `" King Selassie"'
				di as txt  `" And endorse di ghetto youth dem.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=3A0ETb9z_PQ":https://www.youtube.com/watch?v=3A0ETb9z_PQ}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=3A0ETb9z_PQ"
				}
				
				if "`platform'" == "spotify" {
				
					di as text			`"  {browse "https://open.spotify.com/track/3pn1vCQMA2wNQiaPkiIHI7?si=rPcW6nETQmKJ1B-whXs1cw":https://open.spotify.com/track/3pn1vCQMA2wNQiaPkiIHI7?si=rPcW6nETQmKJ1B-whXs1cw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3pn1vCQMA2wNQiaPkiIHI7?si=rPcW6nETQmKJ1B-whXs1cw"
				}
				
				local chooseSong8 = 0
				local songCount   = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 9) "Rock The Dancehall"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong9' {
				
				di  		""
				di as txt  `""Reggae Music still a ram the dancehall"'
				di as txt  `" Rub a dub music still a rock the dancehall.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=4uKX5CS75fA":https://www.youtube.com/watch?v=4uKX5CS75fA}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=4uKX5CS75fA"
				}
				
				if "`platform'" == "spotify" {
				
					di as text			`"  {browse "https://open.spotify.com/track/2dePsNPukZ3fqikLNieXvk?si=-p7BIzP0Q5Ck45qdum1MzA":https://open.spotify.com/track/2dePsNPukZ3fqikLNieXvk?si=-p7BIzP0Q5Ck45qdum1MzA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2dePsNPukZ3fqikLNieXvk?si=-p7BIzP0Q5Ck45qdum1MzA"
				}
				
				local chooseSong9 = 0
				local songCount   = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
	
		
		// 10) "Still Blazing"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `alborosie' & `italy' & `male' & `chooseSong10' {
				
				di  		""
				di as txt  `""Don't let nobody rule your soul, no way.""'
				di as txt   " {bf:Alborosie}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=uA112N_meog":https://www.youtube.com/watch?v=uA112N_meog}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=uA112N_meog"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/3sbBOn0ifcgoX3MfaTeFKr?si=eonpS3P0QcS2h_6O0yGmiA":https://open.spotify.com/track/3sbBOn0ifcgoX3MfaTeFKr?si=eonpS3P0QcS2h_6O0yGmiA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3sbBOn0ifcgoX3MfaTeFKr?si=eonpS3P0QcS2h_6O0yGmiA"
				}
				
				local chooseSong10 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 11) "Contradiction"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`alborosie' == 1 | `chronixx' == 1) & (`italy' == 1 | `jamaica' == 1) & `male' == 1 & `chooseSong11' == 1 {	
				
				di  		""
				di as txt  `""Contradiction global"'
				di as txt  `" Madness taking over.""'
				di as txt   " {bf:Alborosie & Chronixx}"
				
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=kuFI_jOSyGw":https://www.youtube.com/watch?v=kuFI_jOSyGw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=kuFI_jOSyGw"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4A2EuH7CRXeUpLh84TLsav?si=CXsKn2SASYWTUI9fYtBvSg":https://open.spotify.com/track/4A2EuH7CRXeUpLh84TLsav?si=CXsKn2SASYWTUI9fYtBvSg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4A2EuH7CRXeUpLh84TLsav?si=CXsKn2SASYWTUI9fYtBvSg"
				}
				
				local chooseSong11 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 12) "Blessings"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`alborosie' == 1 | `etana' == 1) & ((`italy' == 1  & `male' == 1) | (`jamaica' == 1 & `female' == 1)) & `chooseSong12' == 1 {
				
				di  		""
				di as txt  `""Cause when a man love a woman and a woman love a man"'
				di as txt  `" a Jah Jah blessing.""'
				di as txt   " {bf:Alborosie & Etana}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=gAMZMWvAxjo":https://www.youtube.com/watch?v=gAMZMWvAxjo}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=gAMZMWvAxjo"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4T1YRV5aIiOD7i0TB9yKKA?si=GIgj0g4hTc2uZTju6F9lPw":https://open.spotify.com/track/4T1YRV5aIiOD7i0TB9yKKA?si=GIgj0g4hTc2uZTju6F9lPw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4T1YRV5aIiOD7i0TB9yKKA?si=GIgj0g4hTc2uZTju6F9lPw"
				}
				
				local chooseSong12 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 13) "Journey to Jah"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`alborosie' == 1 | `gentleman' == 1) & (`italy' == 1 | `germany' == 1) & `male' == 1  & `chooseSong13' == 1 {
				
				//"Journey to Jah" is only availabe on Youtube
				if "`platform'" == "youtube" {
					
					di  		""
					di as txt  `""Crossing border, divine is the order.""'
					di as txt   " {bf:Alborosie & Gentleman}"
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=dN8FTAx06rE":https://www.youtube.com/watch?v=dN8FTAx06rE}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=dN8FTAx06rE"
					
					local chooseSong13 = 0
					local songCount    = 1 + `songCount'
				}
				
				if "`platform'" == "spotify" continue				
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 14) "Mystical Reggae"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`alborosie' == 1 | `jahcure' == 1) & (`italy' == 1 | `jamaica' == 1) & `male' == 1 & `chooseSong14' == 1 {
				
				//"Mystical Reggae" is only availabe on Spotify
				if "`platform'" == "youtube" continue
								
				if "`platform'" == "spotify" {
					
					di  		""
					di as txt  `""There's a natural mystic inna di air.""'
					di as txt   " {bf:Alborosie & Jah Cure}"
					
					di as text 			`"  {browse "https://open.spotify.com/track/3yjjW4ajNwJ5ikNb4fxGy2?si=zaS3l5eASauRPOSgpHuC9Q":https://open.spotify.com/track/3yjjW4ajNwJ5ikNb4fxGy2?si=zaS3l5eASauRPOSgpHuC9Q}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3yjjW4ajNwJ5ikNb4fxGy2?si=zaS3l5eASauRPOSgpHuC9Q"
				
					local chooseSong14 = 0
					local songCount    = 1 + `songCount'
				}
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 15) "Strolling"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`alborosie' == 1 | `protoje' == 1) & (`italy' == 1 | `jamaica' == 1) & `male' == 1 & `chooseSong15' == 1 {
				
				di  		""
				di as txt  `""Over the mountains, across the seas"'
				di as txt  `" You feel it mystically in the breeze"'
				di as txt  `" When the Rastaman strolling into town.""'
				di as txt   " {bf:Alborosie & Protoje}"
								
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=QXczfq3MCYQ":https://www.youtube.com/watch?v=QXczfq3MCYQ}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=QXczfq3MCYQ"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3NAw0zn9VETypbwkJMt747?si=YRb-WvlxRPWfiCDjkrsAXw":https://open.spotify.com/track/3NAw0zn9VETypbwkJMt747?si=YRb-WvlxRPWfiCDjkrsAXw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3NAw0zn9VETypbwkJMt747?si=YRb-WvlxRPWfiCDjkrsAXw"
				}
				
				local chooseSong15 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 16) "The Unforgiven"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`alborosie' == 1 | `ragingfyah' == 1) & (`italy' == 1 | `jamaica' == 1) & `male' == 1 & `chooseSong16' == 1 {
				
				di  		""
				di as txt  `""Never free"'
				di as txt  `" Never me"'
				di as txt  `" So I dub thee unforgiven.""'
				di as txt   " {bf:Alborosie & Raging Fyah}"
								
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=W5IBHF98mSI":https://www.youtube.com/watch?v=W5IBHF98mSI}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=W5IBHF98mSI"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/59ZLlnNh4oAbEKouRqQ3tX?si=VQ8xjtp0T9algIlxd-b3ZQ":https://open.spotify.com/track/59ZLlnNh4oAbEKouRqQ3tX?si=VQ8xjtp0T9algIlxd-b3ZQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/59ZLlnNh4oAbEKouRqQ3tX?si=VQ8xjtp0T9algIlxd-b3ZQ"
				}
				
				local chooseSong16 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 17) "Can't Stop The Fire"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong17' {
				
				di  		""
				di as txt  `""Can't stop di fiyah keep it burning.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=g9D1wowY7q4":https://www.youtube.com/watch?v=g9D1wowY7q4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=g9D1wowY7q4"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4jmULYj986UBTySibS1Bdn?si=6-PDscBZQVabfVqgzNuwkA":https://open.spotify.com/track/4jmULYj986UBTySibS1Bdn?si=6-PDscBZQVabfVqgzNuwkA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4jmULYj986UBTySibS1Bdn?si=6-PDscBZQVabfVqgzNuwkA"
				}
				
				local chooseSong17 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 18) "Freedom Fighter"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong18' {
				
				di  		""
				di as txt  `""Run for cover"'
				di as txt  `" Rebel is taking over, right now.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=plYcRr5nnSc":https://www.youtube.com/watch?v=plYcRr5nnSc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=plYcRr5nnSc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/37L9OjM5qrJMa29gT9HKGW?si=NnRf59oATqm7_yQ07V_Y0g":https://open.spotify.com/track/37L9OjM5qrJMa29gT9HKGW?si=NnRf59oATqm7_yQ07V_Y0g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/37L9OjM5qrJMa29gT9HKGW?si=NnRf59oATqm7_yQ07V_Y0g"
				}
				
				local chooseSong18 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 19) "Good Cop Bad Cop"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong19' {
				
				di  		""
				di as txt  `""Good cop, bad cop.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=Zpe2zHk0m4s":https://www.youtube.com/watch?v=Zpe2zHk0m4s}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=Zpe2zHk0m4s"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3nkhq24WT28eKVYta3yyhE?si=cD1N-FdWQ1aCwT-sZV-Frw":https://open.spotify.com/track/3nkhq24WT28eKVYta3yyhE?si=cD1N-FdWQ1aCwT-sZV-Frw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3nkhq24WT28eKVYta3yyhE?si=cD1N-FdWQ1aCwT-sZV-Frw"
				}
				
				local chooseSong19 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 20) "King In My Castle"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong20' {
				
				di  		""
				di as txt  `""Each and everyone was born as a king"'
				di as txt  `" Equal rights is for the globe, the world"'
			    di as txt  `" Doesn't matter your race, your color, your class.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=Zpe2zHk0m4s":https://www.youtube.com/watch?v=Zpe2zHk0m4s}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=Zpe2zHk0m4s"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3nkhq24WT28eKVYta3yyhE?si=cD1N-FdWQ1aCwT-sZV-Frw":https://open.spotify.com/track/3nkhq24WT28eKVYta3yyhE?si=cD1N-FdWQ1aCwT-sZV-Frw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3nkhq24WT28eKVYta3yyhE?si=cD1N-FdWQ1aCwT-sZV-Frw"
				}
				
				local chooseSong20 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 21) "Love Come Down"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong21' {
				
				di  		""
				di as txt  `""Girl you make my love come down.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=cAZPBv28dpA":https://www.youtube.com/watch?v=cAZPBv28dpA}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=cAZPBv28dpA"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/63SqSUAOIcPxCt4piwgyFh?si=k4h8eRNzRg26gF_fauR7YA":https://open.spotify.com/track/63SqSUAOIcPxCt4piwgyFh?si=k4h8eRNzRg26gF_fauR7YA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/63SqSUAOIcPxCt4piwgyFh?si=k4h8eRNzRg26gF_fauR7YA"
				}
				
				local chooseSong21 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 22) "My Yes & My No"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong22' {
				
				di  		""
				di as txt  `""You are my yes and my no"'
				di as txt  `" My high and my low.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=qJlAANOTQjE":https://www.youtube.com/watch?v=qJlAANOTQjE}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=qJlAANOTQjE"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7HwzUApZNxS4ZzUhyyokx7?si=hasSCIShRHmF_VaGFlExWA":https://open.spotify.com/track/7HwzUApZNxS4ZzUhyyokx7?si=hasSCIShRHmF_VaGFlExWA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7HwzUApZNxS4ZzUhyyokx7?si=hasSCIShRHmF_VaGFlExWA"
				}
				
				local chooseSong22 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 23) "Police"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong23' {
				
				di  		""
				di as txt  `""Who want the dancehall fi stop?""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=mN1-hI19p9k":https://www.youtube.com/watch?v=mN1-hI19p9k}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=mN1-hI19p9k"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6LtaXQAwy6qy3lnSP0BuZ3?si=lHfeWkPdTICj08LoI3fuaA":https://open.spotify.com/track/6LtaXQAwy6qy3lnSP0BuZ3?si=lHfeWkPdTICj08LoI3fuaA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6LtaXQAwy6qy3lnSP0BuZ3?si=lHfeWkPdTICj08LoI3fuaA"
				}
				
				local chooseSong23 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 24) "Unbalance"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong24' {
				
				di  		""
				di as txt  `""Unbalance"'
				di as txt  `" You don't see that I'm unbalanced.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=UqeAr1gqxyU":https://www.youtube.com/watch?v=UqeAr1gqxyU}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=UqeAr1gqxyU"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/74LWzRoSPSOPDgmcMlCUVs?si=n9ePvGN2SIuS-ZvxVU5t8g":https://open.spotify.com/track/74LWzRoSPSOPDgmcMlCUVs?si=n9ePvGN2SIuS-ZvxVU5t8g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/74LWzRoSPSOPDgmcMlCUVs?si=n9ePvGN2SIuS-ZvxVU5t8g"
				}
				
				local chooseSong24 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
			
		// 25) "World A Reggae Music"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `anthonyb' & `jamaica' & `male' & `chooseSong25' {
				
				di  		""
				di as txt  `""World a reggae music on ya - eh"'
				di as txt  `" Keep me rockin with me daughter - eh-a.""'
				di as txt   " {bf:Anthony B}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=nsa_I6nbZo0":https://www.youtube.com/watch?v=nsa_I6nbZo0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=nsa_I6nbZo0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3Gym3Rtm6FHpTrLlJTcz3j?si=5Xkwl1UkRG6PjyicqqtCjA":https://open.spotify.com/track/3Gym3Rtm6FHpTrLlJTcz3j?si=5Xkwl1UkRG6PjyicqqtCjA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3Gym3Rtm6FHpTrLlJTcz3j?si=5Xkwl1UkRG6PjyicqqtCjA"
				}
				
				local chooseSong25 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 26) "Buffalo Soldier"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong26' == 1 {
				
				di  		""
				di as txt  `""Buffalo Soldier, Dreadlock Rasta"'
				di as txt  `" There was a Buffalo Soldier"'
				di as txt  `" In the heart of America"'
				di as txt  `" Stolen from Africa, brought to America"'
				di as txt  `" Fighting on arrival, fighting for survival.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=S5FCdx7Dn0o":https://www.youtube.com/watch?v=S5FCdx7Dn0o}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=S5FCdx7Dn0o"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7BfW1eoDh27W69nxsmRicb?si=l5iJ2FilQ8OxoyXTzJF7Kg":https://open.spotify.com/track/7BfW1eoDh27W69nxsmRicb?si=l5iJ2FilQ8OxoyXTzJF7Kg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7BfW1eoDh27W69nxsmRicb?si=l5iJ2FilQ8OxoyXTzJF7Kg"
				}
				
				local chooseSong26 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 27) "Could You Be Loved"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong27' == 1 {
				
				di  		""
				di as txt  `""Could you be loved and be loved?""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=g3t6YDnGXAc":https://www.youtube.com/watch?v=g3t6YDnGXAc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=g3t6YDnGXAc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5O4erNlJ74PIF6kGol1ZrC?si=RWWB6q5ER3y2QedyWwrheg":https://open.spotify.com/track/5O4erNlJ74PIF6kGol1ZrC?si=RWWB6q5ER3y2QedyWwrheg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5O4erNlJ74PIF6kGol1ZrC?si=RWWB6q5ER3y2QedyWwrheg"
				}
				
				local chooseSong27 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 28) "Don't Worry Be Happy"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong28' == 1 {
					
				if "`platform'" == "youtube" {
					
					di  		""
					di as txt  `""Ain't got no cash, ain't got no style"'
					di as txt  `" Ain't got no gal to make you smile"'
					di as txt  `" Don't worry, be happy.""'
					di as txt   " {bf:Bob Marley & The Wailers}"
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=L3HQMbQAWRc":https://www.youtube.com/watch?v=L3HQMbQAWRc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=L3HQMbQAWRc"
				
					local chooseSong28 = 0
					local songCount    = 1 + `songCount'
				}
					
				if "`platform'" == "spotify" continue
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 29) "Iron Lion Zion"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong29' == 1 {
				
				di  		""
				di as txt  `""I had to run like a fugitive just to save the life I live"'
				di as txt  `" I'm gonna be Iron like a Lion in Zion.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=HgXMoZdY5A0":https://www.youtube.com/watch?v=HgXMoZdY5A0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=HgXMoZdY5A0"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/57bvNqmSDfAakSot4cCn70?si=ep0nKfvETvK0gbYRLrhN9A":https://open.spotify.com/track/57bvNqmSDfAakSot4cCn70?si=ep0nKfvETvK0gbYRLrhN9A}
					if "`browse'" != "" view browse "https://open.spotify.com/track/57bvNqmSDfAakSot4cCn70?si=ep0nKfvETvK0gbYRLrhN9A"
				}
				
				local chooseSong38 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 30) "Is This Love"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong30' == 1 {
				
				di  		""
				di as txt  `""I want to love you, and treat you right"'
				di as txt  `" I want to love you, every day and every night.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=CHekNnySAfM":https://www.youtube.com/watch?v=CHekNnySAfM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=CHekNnySAfM"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6JRLFiX9NJSoRRKxowlBYr?si=JPsxdL4mROyvBs8LiQYoTg":https://open.spotify.com/track/6JRLFiX9NJSoRRKxowlBYr?si=JPsxdL4mROyvBs8LiQYoTg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6JRLFiX9NJSoRRKxowlBYr?si=JPsxdL4mROyvBs8LiQYoTg"
				}
				
				local chooseSong30 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 31) "Natural Mystic"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong31' == 1 {
				
				di  		""
				di as txt  `""There's a natural mystic"'
				di as txt  `" Blowing through the air.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=PWoDSGfSu6o":https://www.youtube.com/watch?v=PWoDSGfSu6o}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=PWoDSGfSu6o"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1YP719l4JjsOmyU4PGv3c0?si=Cm3KbJbiQ6KRsAhBuUaLiA":https://open.spotify.com/track/1YP719l4JjsOmyU4PGv3c0?si=Cm3KbJbiQ6KRsAhBuUaLiA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1YP719l4JjsOmyU4PGv3c0?si=Cm3KbJbiQ6KRsAhBuUaLiA"
				}
				
				local chooseSong31 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 32) "No Woman No Cry"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong32' == 1 {
								
				di  		""
				di as txt  `""No woman, no cry"'
				di as txt  `" Here little darlin', don't shed no tears.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=pHlSE9j5FGY":https://www.youtube.com/watch?v=pHlSE9j5FGY}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=pHlSE9j5FGY"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3PQLYVskjUeRmRIfECsL0X?si=QKAD7Q6PSe2Q-40wxtOQ0Q":https://open.spotify.com/track/3PQLYVskjUeRmRIfECsL0X?si=QKAD7Q6PSe2Q-40wxtOQ0Q}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3PQLYVskjUeRmRIfECsL0X?si=QKAD7Q6PSe2Q-40wxtOQ0Q"
				}
				
				local chooseSong32 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		// 33) "One Love"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong33' == 1 {
				
				di  		""
				di as txt  `""Let's get together and feel all right.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=vdB-8eLEW8g":https://www.youtube.com/watch?v=vdB-8eLEW8g}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=vdB-8eLEW8g"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2HcyIzVsX45jLIxK7SH2aI?si=O7RBmeEvQcKIhP1nGywRZQ":https://open.spotify.com/track/2HcyIzVsX45jLIxK7SH2aI?si=O7RBmeEvQcKIhP1nGywRZQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2HcyIzVsX45jLIxK7SH2aI?si=O7RBmeEvQcKIhP1nGywRZQ"
				}
				
				di  		""
				di as txt  `""Let's get together and feel all right.""'
				di as txt   " {bf:Bob Marley  & The Wailers}"
								
				local chooseSong33 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 34) "Redemption Song"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong34' == 1 {
				
				di  		""
				di as txt  `""Emancipate yourselves from mental slavery"'
				di as txt  `" None but ourselves can free our minds.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=kOFu6b3w6c0":https://www.youtube.com/watch?v=kOFu6b3w6c0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=kOFu6b3w6c0"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/26PwuMotZqcczKLHi4Htz3?si=5qd3QT0zSXmpB9ympgwRnQ":https://open.spotify.com/track/26PwuMotZqcczKLHi4Htz3?si=5qd3QT0zSXmpB9ympgwRnQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/26PwuMotZqcczKLHi4Htz3?si=5qd3QT0zSXmpB9ympgwRnQ"
				}
				
				local chooseSong34 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 35) Three Little Birds
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`bobmarley' == 1 | `thewailers' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong35' == 1 {
				
				di  		""
				di as txt  `""Don't worry about a thing"'
				di as txt  `" Cause every little thing gonna be alright.""'
				di as txt   " {bf:Bob Marley & The Wailers}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=4k2PJFPu57Y":https://www.youtube.com/watch?v=4k2PJFPu57Y}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=4k2PJFPu57Y"
				}
					
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6A9mKXlFRPMPem6ygQSt7z?si=QNtFurRxQBKtTjwgipP9aA":https://open.spotify.com/track/6A9mKXlFRPMPem6ygQSt7z?si=QNtFurRxQBKtTjwgipP9aA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6A9mKXlFRPMPem6ygQSt7z?si=QNtFurRxQBKtTjwgipP9aA"
				}
				
				local chooseSong35 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		// 36) "Here Comes Trouble"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `chronixx' & `jamaica' & `male' & `chooseSong36' {
				
				di  		""
				di as txt  `""Welcome the savior"'
				di as txt  `" Welcome the rasta youths.""'
				di as txt   " {bf:Chronixx}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=LfeIfiiBTfY":https://www.youtube.com/watch?v=LfeIfiiBTfY}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=LfeIfiiBTfY"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5Wwr2S7QZTR5PVJn6jhgdk?si=p1vSLV5RSmqU9G21KrmNhg":https://open.spotify.com/track/5Wwr2S7QZTR5PVJn6jhgdk?si=p1vSLV5RSmqU9G21KrmNhg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5Wwr2S7QZTR5PVJn6jhgdk?si=p1vSLV5RSmqU9G21KrmNhg"
				}
				
				local chooseSong36 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 37) "Skankin' Sweet"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `chronixx' & `jamaica' & `male' & `chooseSong37' {
				
				di  		""
				di as txt  `""Skankin' sweet"'
				di as txt  `" Everybody wanna feel irie.""'
				di as txt   " {bf:Chronixx}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=049km3Vc02c":https://www.youtube.com/watch?v=049km3Vc02c}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=049km3Vc02c"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5SQaQWvBDEAeug4EPyYEGE?si=0Rw6KzRfQ_OmBgmx8kGcKg":https://open.spotify.com/track/5SQaQWvBDEAeug4EPyYEGE?si=0Rw6KzRfQ_OmBgmx8kGcKg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5SQaQWvBDEAeug4EPyYEGE?si=0Rw6KzRfQ_OmBgmx8kGcKg"
				}
				
				local chooseSong37 = 0
				local songCount    = 1 + `songCount'
			}
		}	
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 38) "Smile Jamaica"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `chronixx' & `jamaica' & `male' & `chooseSong38' {
				
				di  		""
				di as txt  `""Smile girl smile"'
				di as txt  `" Smile for me Jamaica.""'
				di as txt   " {bf:Chronixx}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=vofff0Ei3kk":https://www.youtube.com/watch?v=vofff0Ei3kk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=vofff0Ei3kk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7KhQx2EJaZIPGsbMAjf4jg?si=Hct-rsyBReemG39GQsxURQ":https://open.spotify.com/track/7KhQx2EJaZIPGsbMAjf4jg?si=Hct-rsyBReemG39GQsxURQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7KhQx2EJaZIPGsbMAjf4jg?si=Hct-rsyBReemG39GQsxURQ"
				}
				
				local chooseSong38 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 39) "Spanish Town Rockin'"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `chronixx' & `jamaica' & `male' & `chooseSong39' {
				
				di  		""
				di as txt  `""Spanish Town groovy"'
				di as txt  `" Everybody nice.""'
				di as txt   " {bf:Chronixx}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=K2grZsqpvEI":https://www.youtube.com/watch?v=K2grZsqpvEI}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=K2grZsqpvEI"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4Qup2zholspnhLpgkO77C2?si=ZoWaBjb-Rs232yhw-jvC9w":https://open.spotify.com/track/4Qup2zholspnhLpgkO77C2?si=ZoWaBjb-Rs232yhw-jvC9w}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4Qup2zholspnhLpgkO77C2?si=ZoWaBjb-Rs232yhw-jvC9w"
				}
				
				local chooseSong39 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 40) "Bun Down Di System"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `colliebuddz' & `unitedstates' & `male' & `chooseSong40' == 1 {
					
				if "`platform'" == "youtube" {
					
					di  		""
					di as txt  `""Bun down di system, keep dem 'fore yuh burning"'
					di as txt  `" Teach the youths what dem need to be learning""'
					di as txt   " {bf:Collie Buddz}"
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=LCIXqFm9YEU":https://www.youtube.com/watch?v=LCIXqFm9YEU}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=LCIXqFm9YEU"
				
					local chooseSong40 = 0
					local songCount    = 1 + `songCount'
				}
					
				if "`platform'" == "spotify" continue
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 41) "Autumn Leaves"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `damianmarley' & `jamaica' & `male' & `chooseSong41' {
				
				di  		""
				di as txt  `""Life is full of ups and downs"'
				di as txt  `" The carousel of love"'
				di as txt  `" Good times, bad times, smiles, and frowns."'
				di as txt  `" Darling, don't give up on me.""'
				di as txt   " {bf:Damian Marley}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=QLiYemcdFUw":https://www.youtube.com/watch?v=QLiYemcdFUw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=QLiYemcdFUw"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/318LuiMBWwZ2yKK2D1w5l2?si=3OMAzswISj6YY-XASMy4kQ":https://open.spotify.com/track/318LuiMBWwZ2yKK2D1w5l2?si=3OMAzswISj6YY-XASMy4kQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/318LuiMBWwZ2yKK2D1w5l2?si=3OMAzswISj6YY-XASMy4kQ"
				}
				
				local chooseSong41 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 42) "Living It Up"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `damianmarley' & `jamaica' & `male' & `chooseSong42' {
				
				di  		""
				di as txt  `""Believe in your dreams"'
				di as txt  `" Believe you and me, don't let go.""'
				di as txt	" {bf:Damian Marley}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=8XN8h3JHmHw":https://www.youtube.com/watch?v=8XN8h3JHmHw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=8XN8h3JHmHw"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0Xd3LUIjRESt5rSAGzvAvA?si=9UxmnVStQLidUU3VSoeABg":https://open.spotify.com/track/0Xd3LUIjRESt5rSAGzvAvA?si=9UxmnVStQLidUU3VSoeABg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0Xd3LUIjRESt5rSAGzvAvA?si=9UxmnVStQLidUU3VSoeABg"
				}
				
				local chooseSong42 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 43) "Welcome To Jamrock"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `damianmarley' & `jamaica' & `male' & `chooseSong43' {
				
				di  		""
				di as txt  `""Hey, welcome to Jamrock"'
				di as txt  `" Out in the streets, they call it murder.""'
				di as txt	" {bf:Damian Marley}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=xlCmQcRPtRg":https://www.youtube.com/watch?v=xlCmQcRPtRg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=xlCmQcRPtRg"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/22AbXxQbMdVqEz7xJjhccG?si=SHnoYAvWQ_mMYQZC3WMdEw":https://open.spotify.com/track/22AbXxQbMdVqEz7xJjhccG?si=SHnoYAvWQ_mMYQZC3WMdEw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/22AbXxQbMdVqEz7xJjhccG?si=SHnoYAvWQ_mMYQZC3WMdEw"
				}
				
				local chooseSong43 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 44) "Road to Zion"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`damianmarley' == 1 | `nas' == 1) & (`jamaica' == 1 | `unitedstates' == 1) & `male' == 1 & `chooseSong44' == 1 {
				
				di  		""
				di as txt  `""I got to keep on walking on the road to Zion, man"'
				di as txt  `" We gots to keeps it burning on the road to Zion, man.""'
				di as txt	" {bf:Damian Marley & Nas}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=AkXVBRV1vWo":https://www.youtube.com/watch?v=AkXVBRV1vWo}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=AkXVBRV1vWo"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6Ja1mjO9WcJFX3LsH22gRk?si=aYe53A6aTrKbndMSWBjwSQ":https://open.spotify.com/track/6Ja1mjO9WcJFX3LsH22gRk?si=aYe53A6aTrKbndMSWBjwSQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6Ja1mjO9WcJFX3LsH22gRk?si=aYe53A6aTrKbndMSWBjwSQ"
				}
				
				local chooseSong44 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 45) "Medication"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`damianmarley' == 1 | `stephenmarley' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong45' == 1 {
				
				di  		""
				di as txt  `""Elevation"'
				di as txt  `" Your medication makes me high.""'
				di as txt	" {bf:Damian Marley & Stephen Marley}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=9PukqhfMxfc":https://www.youtube.com/watch?v=9PukqhfMxfc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=9PukqhfMxfc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2WQKHNETUytUGsD32TTNeO?si=xjZJFgn2SASIyaHk1WVjXw":https://open.spotify.com/track/2WQKHNETUytUGsD32TTNeO?si=xjZJFgn2SASIyaHk1WVjXw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2WQKHNETUytUGsD32TTNeO?si=xjZJFgn2SASIyaHk1WVjXw"
				}
				
				local chooseSong45 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 46) "Due Mari"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `diplomatico' & `italy' & `male' & `chooseSong46' {
				
				if "`platform'" == "youtube" {
					
					di  		""
					di as txt  `""E non è vero che è poco importante"'
					di as txt  `" Fatti sentire la mia gente risponde"'
					di as txt  `" Che non abbiam venduto l'anima.""'
					di as txt	" {bf:Diplomatico e il Collettivo Ninco Nanco}"
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=xlCmQcRPtRg":https://www.youtube.com/watch?v=xlCmQcRPtRg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=xlCmQcRPtRg"
					
					local chooseSong46 = 0
					local songCount    = 1 + `songCount'
				}
				
				if "`platform'" == "spotify" continue
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 47) "Maché Bécif"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `dubinc' & `france' & `male' & `chooseSong47' {
				
				di  		""
				di as txt  `""Même couleur dans nos mains malgré notre épiderme,"'
				di as txt  `" Les consonnes peuvent se lire s’il y a des voyelles,"'
				di as txt  `" Le futur de nos vies se conjugue au pluriel.""'
				di as txt	" {bf:Dub Inc}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=7v_e7xAvvDc":https://www.youtube.com/watch?v=7v_e7xAvvDc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=7v_e7xAvvDc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2GJSKtIC8zUXJtTLu3mMgr?si=viItVi1KTdadwhrno71nnQ":https://open.spotify.com/track/2GJSKtIC8zUXJtTLu3mMgr?si=viItVi1KTdadwhrno71nnQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2GJSKtIC8zUXJtTLu3mMgr?si=viItVi1KTdadwhrno71nnQ"
				}
				
				local chooseSong47 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 48) "Rude Boy"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `dubinc' & `france' & `male' & `chooseSong48' {
				
				di  		""
				di as txt  `""Call me say rudeboy"'
				di as txt  `" In a dance hall reggae music.""'
				di as txt	" {bf:Dub Inc}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=ZLbmIQohjMc":https://www.youtube.com/watch?v=ZLbmIQohjMc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=ZLbmIQohjMc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1OR5HVQgKpCZn2JNIwTKmq?si=-R9G3EfgTySnsjJyeGmUZg":https://open.spotify.com/track/1OR5HVQgKpCZn2JNIwTKmq?si=-R9G3EfgTySnsjJyeGmUZg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1OR5HVQgKpCZn2JNIwTKmq?si=-R9G3EfgTySnsjJyeGmUZg"
				}
				
				local chooseSong48 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 49) "Tout ce qu'ils veulent"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `dubinc' & `france' & `male' & `chooseSong49' {
				
				di  		""
				di as txt  `""Tout ce qu'ils veulent c'est une France qui ferme sa gueule,"'
				di as txt  `" Une fois de plus la machine est lancée,"'
				di as txt  `" Tout ce qu'ils veulent c'est une nation comme idole,"'
				di as txt  `" Une fois de plus la sentence est tombée.""'
				di as txt	" {bf:Dub Inc}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=d9ZsWR4unWY":https://www.youtube.com/watch?v=d9ZsWR4unWY}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=d9ZsWR4unWY"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0Na0p2ZgAfOqETd5E6X1Xf?si=6Bu6r9GNQziOoHB0vDj2NQ":https://open.spotify.com/track/0Na0p2ZgAfOqETd5E6X1Xf?si=6Bu6r9GNQziOoHB0vDj2NQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0Na0p2ZgAfOqETd5E6X1Xf?si=6Bu6r9GNQziOoHB0vDj2NQ"
				}
				
				local chooseSong49 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 50) "Justice"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`dubinc' == 1 | `mellowmood' == 1) & (`france' == 1 | `italy' == 1) & `male' == 1 & `chooseSong50' == 1 {
				
				di  		""
				di as txt  `""Equality will bring more peace"'
				di as txt  `" We said"'
				di as txt  `" Humanity have to come first.""'
				di as txt	" {bf:Dub Inc & Mellow Mood}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=FYXddyG4xIg":https://www.youtube.com/watch?v=FYXddyG4xIg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=FYXddyG4xIg"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6kVhMQRlKoH39wCRnkY1uc?si=PV1rLtvnT1iqaOJt8yPLhw":https://open.spotify.com/track/6kVhMQRlKoH39wCRnkY1uc?si=PV1rLtvnT1iqaOJt8yPLhw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6kVhMQRlKoH39wCRnkY1uc?si=PV1rLtvnT1iqaOJt8yPLhw"
				}
				
				local chooseSong50 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 51) "Don't Be A Victim"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`dubinc' == 1 | `naâman' == 1) & `france' == 1 & `male' == 1 & `chooseSong51' == 1 {
				
				di  		""
				di as txt  `""I’m a rebel!"'
				di as txt  `" I won’t be a victim, I’d rather die!"'
				di as txt  `" Don’t be a fool, stand up and fight!.""'
				di as txt	" {bf:Dub Inc. & Naâman}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=w1K8lsjQ3mM":https://www.youtube.com/watch?v=w1K8lsjQ3mM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=w1K8lsjQ3mM"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0Nlx0VlTs6Kfgs1CAzRGMw?si=OEiNgWawTN-Y_CpqqTW7nQ":https://open.spotify.com/track/0Nlx0VlTs6Kfgs1CAzRGMw?si=OEiNgWawTN-Y_CpqqTW7nQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0Nlx0VlTs6Kfgs1CAzRGMw?si=OEiNgWawTN-Y_CpqqTW7nQ"
				}
				
				local chooseSong51 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 52) "Tempi d'oro"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `duobucolico' & `italy' & `male' & `chooseSong52' {
				
				di  		""
				di as txt  `" Une fois de plus la machine est lancée,"'
				di as txt  `" Passavamo il nostro tempo ad ascoltare"'
				di as txt  `" La musica Reggae, Bob Marley, Peter Tosh.""'
				di as txt	" {bf:Duo Bucolico}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=WRN2-y5mxtc":https://www.youtube.com/watch?v=WRN2-y5mxtc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=WRN2-y5mxtc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5nSLBWWay6jW8IW4XzmNoy?si=eg0tHHasR4aFKYv_EY9UvQ":https://open.spotify.com/track/5nSLBWWay6jW8IW4XzmNoy?si=eg0tHHasR4aFKYv_EY9UvQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5nSLBWWay6jW8IW4XzmNoy?si=eg0tHHasR4aFKYv_EY9UvQ"
				}
				
				local chooseSong52 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 53) "I Am Not Afraid"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `etana' & `jamaica' & `female' & `chooseSong53' {
				
				di  		""
				di as txt  `""If dem a come let them come 'cause I am protected by the most one.""'
				di as txt	" {bf:Etana}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=jI7Y1SXPNXI":https://www.youtube.com/watch?v=jI7Y1SXPNXI}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=jI7Y1SXPNXI"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0EhMnGX0ayyKkwBiHCzfQy?si=UCi_BqkgT1ueod7C3PAO1Q":https://open.spotify.com/track/0EhMnGX0ayyKkwBiHCzfQy?si=UCi_BqkgT1ueod7C3PAO1Q}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0EhMnGX0ayyKkwBiHCzfQy?si=UCi_BqkgT1ueod7C3PAO1Q"
				}
				
				local chooseSong53 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 54) "I Rise"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `etana' & `jamaica' & `female' & `chooseSong54' {
								
				di  		""
				di as txt  `""Gonna be free like a bird in the sky"'
				di as txt  `" Gonna be free, gonna fly so high"'
				di as txt  `" Gonna be free, gonna free my mind.""'
				di as txt	" {bf:Etana}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=y6OummuSaIk":https://www.youtube.com/watch?v=y6OummuSaIk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=y6OummuSaIk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1dPXtN41yN7Od22IV7SZ33?si=QFDqS1gjQ9iHnZFXCf_s0g":https://open.spotify.com/track/1dPXtN41yN7Od22IV7SZ33?si=QFDqS1gjQ9iHnZFXCf_s0g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1dPXtN41yN7Od22IV7SZ33?si=QFDqS1gjQ9iHnZFXCf_s0g"
				}
				
				local chooseSong54 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 55) "Spread Love"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `etana' & `jamaica' & `female' & `chooseSong55' {
								
				di  		""
				di as txt  `""Spread love, spread it all over the world"'
				di as txt  `" To every boy, every girl, yeah, yeah.""'
				di as txt	" {bf:Etana}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=zZftuxaI8b8":https://www.youtube.com/watch?v=zZftuxaI8b8}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=zZftuxaI8b8"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6VOeOHvMILlzAYORXJVEAS?si=jReKhVgbSgmCtTRNj5kJwA":https://open.spotify.com/track/6VOeOHvMILlzAYORXJVEAS?si=jReKhVgbSgmCtTRNj5kJwA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6VOeOHvMILlzAYORXJVEAS?si=jReKhVgbSgmCtTRNj5kJwA"
				}
				
				local chooseSong55 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 56) "Trigger"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `etana' & `jamaica' & `female' & `chooseSong56' {
								
				di  		""
				di as txt  `""Mamma me affi pull the trigger again.""'
				di as txt	" {bf:Etana}"

				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=X0Ha6ZFrHFM":https://www.youtube.com/watch?v=X0Ha6ZFrHFM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=X0Ha6ZFrHFM"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2nDiT97jjG7FXY6ZcwG5Cz?si=63cdk0dZS5-kB4qgbGuykg":https://open.spotify.com/track/2nDiT97jjG7FXY6ZcwG5Cz?si=63cdk0dZS5-kB4qgbGuykg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2nDiT97jjG7FXY6ZcwG5Cz?si=63cdk0dZS5-kB4qgbGuykg"
				}
				
				local chooseSong56 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 57) "Intoxication"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `gentleman' & `germany' & `male' & `chooseSong57' {
				
				di  		""
				di as txt  `""Joy ina your eyes me nuh see no tears"'
				di as txt  `" Love is what you giving me troughout the years.""'
				di as txt   " {bf:Gentleman}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=BtzGQIDOCkM":https://www.youtube.com/watch?v=BtzGQIDOCkM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=BtzGQIDOCkM"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/76GvclaeLjwJV408jF2NgZ?si=BNxknVFET96AJZLB_JG16g":https://open.spotify.com/track/76GvclaeLjwJV408jF2NgZ?si=BNxknVFET96AJZLB_JG16g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/76GvclaeLjwJV408jF2NgZ?si=BNxknVFET96AJZLB_JG16g"
				}
				
				local chooseSong57 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 58) "Red Town"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `gentleman' & `germany' & `male' & `chooseSong58' {
			
				di  		""
				di as txt  `""The destination is freedom from stress"'
				di as txt  `" That's the getaway.""'
				di as txt   " {bf:Gentleman}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=aktSkJ3USR4":https://www.youtube.com/watch?v=aktSkJ3USR4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=aktSkJ3USR4"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7IH9KJrlF1xteGD2nssZTp?si=sZxDUkVySYGn60S3Md3rWQ":https://open.spotify.com/track/7IH9KJrlF1xteGD2nssZTp?si=sZxDUkVySYGn60S3Md3rWQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7IH9KJrlF1xteGD2nssZTp?si=sZxDUkVySYGn60S3Md3rWQ"
				}
				
				local chooseSong58 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 59) "Signs Of The Times"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`gentleman' == 1 | `kymanimarley' == 1) & (`germany' == 1 | `jamaica' == 1) & `male' == 1 & `chooseSong59' == 1 {
			
				di  		""
				di as txt  `""These are the signs of the times"'
				di as txt  `" It is time for us to define."'
				di as txt  `" Who destroys, who design.""'
				di as txt   " {bf:Gentleman & Ky-Mani Marley}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=Dmpgi7POB88":https://www.youtube.com/watch?v=Dmpgi7POB88}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=Dmpgi7POB88"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7kkJPjjepAoiBUiXQWXdRj?si=5xe4bqIAQsOP3wZT6f_Xow":https://open.spotify.com/track/7kkJPjjepAoiBUiXQWXdRj?si=5xe4bqIAQsOP3wZT6f_Xow}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7kkJPjjepAoiBUiXQWXdRj?si=5xe4bqIAQsOP3wZT6f_Xow"
				}
				
				local chooseSong59 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 60) "Boom Shakalak"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `hempresssativa' & `jamaica' & `female' & `chooseSong60' {
			
				di  		""
				di as txt  `""Boom Shakalak!""'
				di as txt   " {bf:Hempress Sativa}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=eLYuJX460OU":https://www.youtube.com/watch?v=eLYuJX460OU}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=eLYuJX460OU"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/56SSNFPQklO6cOWZYqm2Mw?si=I4LXWumCQxe_RZsiOuj0KQ":https://open.spotify.com/track/56SSNFPQklO6cOWZYqm2Mw?si=I4LXWumCQxe_RZsiOuj0KQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/56SSNFPQklO6cOWZYqm2Mw?si=I4LXWumCQxe_RZsiOuj0KQ"
				}
				
				local chooseSong60 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 61) Boom (Wah Da Da Deng)
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `hempresssativa' & `jamaica' & `female' & `chooseSong61' {
			
				di  		""
				di as txt  `""Hempress Sativa"'
				di as txt  `" Di lyrical machine"'
				di as txt  `" When di Lioness Roars no dog bark.""'
				di as txt   " {bf:Hempress Sativa}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=1WLGT_AAD2Y":https://www.youtube.com/watch?v=1WLGT_AAD2Y}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=1WLGT_AAD2Y"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4lh97cAH0qOlEcPvozgtmU?si=nmkpWEU-QdWvFccyHmVG6A":https://open.spotify.com/track/4lh97cAH0qOlEcPvozgtmU?si=nmkpWEU-QdWvFccyHmVG6A}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4lh97cAH0qOlEcPvozgtmU?si=nmkpWEU-QdWvFccyHmVG6A"
				}
				
				local chooseSong61 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 62) Rock It Ina Dance
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `hempresssativa' & `jamaica' & `female' & `chooseSong62' {
			
				di  		""
				di as txt  `""Cause a long time wi a rock it ina dance"'
				di as txt  `" Mi say a long time wi a skank it ina dance.""'
				di as txt   " {bf:Hempress Sativa}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=5imDwddcVKs":https://www.youtube.com/watch?v=5imDwddcVKs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=5imDwddcVKs"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6kl8xQWg0k9mAC58mfAqbT?si=mjyIyHAbQgGHosOO1DE49g":https://open.spotify.com/track/6kl8xQWg0k9mAC58mfAqbT?si=mjyIyHAbQgGHosOO1DE49g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6kl8xQWg0k9mAC58mfAqbT?si=mjyIyHAbQgGHosOO1DE49g"
				}
				
				local chooseSong62 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 63) I Can See Clearly Now
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong63' {
			
				di  		""
				di as txt  `""Here is that rainbow I've been praying for"'
				di as txt  `" It's gonna be a bright"'
				di as txt  `" Bright sunshiny day.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=MrHxhQPOO2c":https://www.youtube.com/watch?v=MrHxhQPOO2c}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=MrHxhQPOO2c"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7aJZxI6TVdIvQSuWxQ4rqp?si=dkvtBi0JSmWQlQ1QxyHQZQ":https://open.spotify.com/track/7aJZxI6TVdIvQSuWxQ4rqp?si=dkvtBi0JSmWQlQ1QxyHQZQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7aJZxI6TVdIvQSuWxQ4rqp?si=dkvtBi0JSmWQlQ1QxyHQZQ"
				}
				
				local chooseSong63 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 64) Reggae Night
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong64' {
				
				di  		""
				di as txt  `""Reggae night"'
				di as txt  `" We come together when the feeling's right"'
				di as txt  `" Reggae night"'
				di as txt  `" And we'll be jamming till the morning light.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=DH4cZlLPeQ0":https://www.youtube.com/watch?v=DH4cZlLPeQ0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=DH4cZlLPeQ0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1OE5bn5HUmCqTLNpo13ya3?si=MNYyRquASJqsZfnv9YUhAA":https://open.spotify.com/track/1OE5bn5HUmCqTLNpo13ya3?si=MNYyRquASJqsZfnv9YUhAA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1OE5bn5HUmCqTLNpo13ya3?si=MNYyRquASJqsZfnv9YUhAA"
				}
				
				local chooseSong64 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 65) Many Rivers To Cross
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong65' {
				
				di  		""
				di as txt  `""Many rivers to cross and it's only my will"'
				di as txt  `" That keeps me alive.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=SF3IktTk_pQ":https://www.youtube.com/watch?v=SF3IktTk_pQ}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=SF3IktTk_pQ"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4hHGirIgXzCaPaTPrsR9RQ?si=yAlApkpOSJG5daqH-E03uA":https://open.spotify.com/track/4hHGirIgXzCaPaTPrsR9RQ?si=yAlApkpOSJG5daqH-E03uA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4hHGirIgXzCaPaTPrsR9RQ?si=yAlApkpOSJG5daqH-E03uA"
				}
				
				local chooseSong65 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 66) The Harder They Come
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong66' {
				
				di  		""
				di as txt  `""So as sure as the sun will shine"'
				di as txt  `" I'm gonna get my share now of what's mine"'
				di as txt  `" And then the harder they come"'
				di as txt  `" The harder they'll fall, one and all.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=7Znh0OM9jiA":https://www.youtube.com/watch?v=7Znh0OM9jiA}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=7Znh0OM9jiA"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1rRwITygDIIVmidBzP6OU8?si=zRlufJB-RveR2VwfEV7mbA":https://open.spotify.com/track/1rRwITygDIIVmidBzP6OU8?si=zRlufJB-RveR2VwfEV7mbA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1rRwITygDIIVmidBzP6OU8?si=zRlufJB-RveR2VwfEV7mbA"
				}
				
				local chooseSong66 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 67) You Can Get It If You Really Want
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong67' {
				
				di  		""
				di as txt  `""You can get it if you really want"'
				di as txt  `" But you must try, try and try, try and try"'
				di as txt  `" You'll succeed at last.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=18EAqHx2lMk":https://www.youtube.com/watch?v=18EAqHx2lMk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=18EAqHx2lMk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5WinBEkwdn2jQwm6epQR6i?si=RC-e9XIGQ4-AQYn4v-zYXw":https://open.spotify.com/track/5WinBEkwdn2jQwm6epQR6i?si=RC-e9XIGQ4-AQYn4v-zYXw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5WinBEkwdn2jQwm6epQR6i?si=RC-e9XIGQ4-AQYn4v-zYXw"
				}
				
				local chooseSong67 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 68) Wild World
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong68' {
				
				di  		""
				di as txt  `""Oh baby, baby, it's a wild world"'
				di as txt  `" It's hard to get by just upon a smile.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=yLvq-OLUo3w":https://www.youtube.com/watch?v=yLvq-OLUo3w}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=yLvq-OLUo3w"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/24Dt3Zopsc50OE9dZ741Fg?si=-HemtivjTQOFuQuhvo_lKg":https://open.spotify.com/track/24Dt3Zopsc50OE9dZ741Fg?si=-HemtivjTQOFuQuhvo_lKg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/24Dt3Zopsc50OE9dZ741Fg?si=-HemtivjTQOFuQuhvo_lKg"
				}
				
				local chooseSong68 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 69) Wonderful World, Beautiful People
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `jimmycliff' & `jamaica' & `male' & `chooseSong69' {
				
				di  		""
				di as txt  `""We could have a wonderful world, beautiful people"'
				di as txt  `" You and your girl things could be pretty.""'
				di as txt   " {bf:Jimmy Cliff}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=zCJYl9Irayk":https://www.youtube.com/watch?v=zCJYl9Irayk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=zCJYl9Irayk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0iH2q2PiyKpSvgOCSUZq5X?si=h0YZ6z2GSa2hwAEzY7kdZA":https://open.spotify.com/track/0iH2q2PiyKpSvgOCSUZq5X?si=h0YZ6z2GSa2hwAEzY7kdZA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0iH2q2PiyKpSvgOCSUZq5X?si=h0YZ6z2GSa2hwAEzY7kdZA"
				}
				
				local chooseSong69 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 70) "If Love So Nice"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `juniorkelly' & `jamaica' & `male' & `chooseSong70' {
				
				di  		""
				di as txt  `""Tell me if love so nice.""'
				di as txt   " {bf:Junior Kelly}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=tSkuJJnKk7o":https://www.youtube.com/watch?v=tSkuJJnKk7o}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=tSkuJJnKk7o"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/5hAOJvfhTB07VcFhno9EY1?si=WvqK4YC-QVa_VnZi4KftFA":https://open.spotify.com/track/5hAOJvfhTB07VcFhno9EY1?si=WvqK4YC-QVa_VnZi4KftFA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5hAOJvfhTB07VcFhno9EY1?si=WvqK4YC-QVa_VnZi4KftFA"
				}
				
				local chooseSong70 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 71) "Can't Breathe"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong71' {
				
				di  		""
				di as txt  `""Me say me cyaan breathe"'
				di as txt  `" Inna this yah suffocation"'
				di as txt  `" The people living inna sufferation.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=BOx3nqWBe1c":https://www.youtube.com/watch?v=BOx3nqWBe1c}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=BOx3nqWBe1c"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/4DfCv5IfEsFeYJE87liL47?si=-WV83RsfQy29EJ-0dtTNHw":https://open.spotify.com/track/4DfCv5IfEsFeYJE87liL47?si=-WV83RsfQy29EJ-0dtTNHw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4DfCv5IfEsFeYJE87liL47?si=-WV83RsfQy29EJ-0dtTNHw"
				}
				
				local chooseSong71 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 72) "Lead The Way"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong72' {
				
				di  		""
				di as txt  `""Selassie I lead the way.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=ip8YaBsRQgg":https://www.youtube.com/watch?v=ip8YaBsRQgg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=ip8YaBsRQgg"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/4ziWAz5EhwFMH0Cx9LXueL?si=erSCtOj7TKaMvGDDyGiJVg":https://open.spotify.com/track/4ziWAz5EhwFMH0Cx9LXueL?si=erSCtOj7TKaMvGDDyGiJVg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4ziWAz5EhwFMH0Cx9LXueL?si=erSCtOj7TKaMvGDDyGiJVg"
				}
				
				local chooseSong72 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
			
		// 73) "Make Way"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong73' {
				
				di  		""
				di as txt  `""Mi go say"'
				di as txt  `" Make way"'
				di as txt  `" Rastaman bursting through your gateway.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text			`"  {browse "https://www.youtube.com/watch?v=yAbSe6JXOZs":https://www.youtube.com/watch?v=yAbSe6JXOZs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=yAbSe6JXOZs"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/0hWI17CuUzsbBG38bqdfDH?si=QcXu1ZimQr6iuvY86sp4zQ":https://open.spotify.com/track/0hWI17CuUzsbBG38bqdfDH?si=QcXu1ZimQr6iuvY86sp4zQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0hWI17CuUzsbBG38bqdfDH?si=QcXu1ZimQr6iuvY86sp4zQ"
				}
				
				local chooseSong73 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 74) "Meaning of Life"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong74' {
		
				di  		""
				di as txt  `""What is the meaning of life, If you only have one chance to live"'
				di as txt  `" Not even twice, without nuh choiceg.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=9XwSvzzr05c":https://www.youtube.com/watch?v=9XwSvzzr05c}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=9XwSvzzr05c"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/5GiANgDhRVRgP2HDVKwMLe?si=pdaRtKJtTTOrykge8jv3Vg":https://open.spotify.com/track/5GiANgDhRVRgP2HDVKwMLe?si=pdaRtKJtTTOrykge8jv3Vg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5GiANgDhRVRgP2HDVKwMLe?si=pdaRtKJtTTOrykge8jv3Vg"
				}
				
				local chooseSong74 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 75) "Mr Gunman"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong75' {
				
				di  		""
				di as txt  `""Mr Gunman"'
				di as txt  `" Tell mi wah yuh get outta killing.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=TxoF9y3KvO4":https://www.youtube.com/watch?v=TxoF9y3KvO4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=TxoF9y3KvO4"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/6p3r7HKvhhDoqyg8kiywbs?si=d6fvQAOMTpiFxPeUPMgXEQ":https://open.spotify.com/track/6p3r7HKvhhDoqyg8kiywbs?si=d6fvQAOMTpiFxPeUPMgXEQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6p3r7HKvhhDoqyg8kiywbs?si=d6fvQAOMTpiFxPeUPMgXEQ"
				}
				
				local chooseSong75 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 76) "My Time"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong76' {
		
				di  		""
				di as txt  `""I've been waiting patient so long"'
				di as txt  `" Now a my time fi shine.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=TVGcIUNn3dg":https://www.youtube.com/watch?v=TVGcIUNn3dg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=TVGcIUNn3dg"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/0XBEOCvH7bO524HUYGvAdu?si=nSBjeiNnTWulCqgVYgWECw":https://open.spotify.com/track/0XBEOCvH7bO524HUYGvAdu?si=nSBjeiNnTWulCqgVYgWECw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0XBEOCvH7bO524HUYGvAdu?si=nSBjeiNnTWulCqgVYgWECw"
				}
				
				local chooseSong76 = 0
				local songCount    = 1 + `songCount'
			}
		}

		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 77) "Reggae Music"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong77' {
			
				di  		""
				di as txt  `""Well, if the music sounds sweet and the people dem a dance"'
				di as txt  `" A must the reggae music, nothing else no have a chance.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=q05liMm3LI4":https://www.youtube.com/watch?v=q05liMm3LI4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=q05liMm3LI4"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/4LH6TQajTVHlPz1283KHAw?si=BHToHoGTSoal5GCtAqjPvA":https://open.spotify.com/track/4LH6TQajTVHlPz1283KHAw?si=BHToHoGTSoal5GCtAqjPvA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4LH6TQajTVHlPz1283KHAw?si=BHToHoGTSoal5GCtAqjPvA"
				}
				
				local chooseSong77 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 78) "Well Done"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kabakapyramid' & `jamaica' & `male' & `chooseSong78' {
			
				di  		""
				di as txt  `""Well done, well done, Mr. Politician Man"'
				di as txt  `" You done a wonderful job a tear down we country, demolition man.""'
				di as txt   " {bf:Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
				
					di as text 			`"  {browse "https://www.youtube.com/watch?v=h8rClH-Jbno":https://www.youtube.com/watch?v=h8rClH-Jbno}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=h8rClH-Jbno"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/33Xl6nfOScCLuvgZyohurw?si=aHMtQNG7SVOuabEflJQNwA":https://open.spotify.com/track/33Xl6nfOScCLuvgZyohurw?si=aHMtQNG7SVOuabEflJQNwA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/33Xl6nfOScCLuvgZyohurw?si=aHMtQNG7SVOuabEflJQNwA"
				}
				
				local chooseSong78 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 79) "Kontraband"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`kabakapyramid' == 1 | `damianmarley' == 1) & `jamaica' == 1 & `male' == 1 & `chooseSong79' == 1 {
			
				di  		""
				di as txt  `""Kontraband"'
				di as txt  `" Now what's in that recipe?"'
				di as txt  `" Kontraband"'
				di as txt  `" Dat giving me the stress relief.""'
				di as txt   " {bf:Kabaka Pyramid & Damian Marley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=DFqRUKTDvn4":https://www.youtube.com/watch?v=DFqRUKTDvn4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=DFqRUKTDvn4"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/4xSgbZ1CFc7f3PZd7RLwF3?si=SKWzvvlTRFSyFY0uTpk5cw":https://open.spotify.com/track/4xSgbZ1CFc7f3PZd7RLwF3?si=SKWzvvlTRFSyFY0uTpk5cw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4xSgbZ1CFc7f3PZd7RLwF3?si=SKWzvvlTRFSyFY0uTpk5cw"
				}
				
				local chooseSong79 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		// 80) "Rapture"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `koffee' & `jamaica' & `female' & `chooseSong80' {
				
				di  		""
				di as txt  `""Koffee come in like a rapture"'
				di as txt  `" And everybody get capture.""'
				di as txt   " {bf:Koffee}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=b9NculQEBa0":https://www.youtube.com/watch?v=b9NculQEBa0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=b9NculQEBa0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0PtDNK2Q49fAM4ZbKtN0mz?si=GL0BznfiQG2HL1VWDRKjAg":https://open.spotify.com/track/0PtDNK2Q49fAM4ZbKtN0mz?si=GL0BznfiQG2HL1VWDRKjAg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0PtDNK2Q49fAM4ZbKtN0mz?si=GL0BznfiQG2HL1VWDRKjAg"
				}
				
				local chooseSong80 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 81) "Throne"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `koffee' & `jamaica' & `female' & `chooseSong81' {
				
				di  		""
				di as txt  `""Ina mi zone"'
				di as txt  `" Alto to Baritone'"
				di as txt  `" Soon dem a go see seh is a queen deh pon di throne.""'
				di as txt   " {bf:Koffee}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=5V4ZDNV4si0":https://www.youtube.com/watch?v=5V4ZDNV4si0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=5V4ZDNV4si0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/35a521ZDkbwBkbJfWyPHEq?si=4H21fBm1T5GheyPnuHGcDg":https://open.spotify.com/track/35a521ZDkbwBkbJfWyPHEq?si=4H21fBm1T5GheyPnuHGcDg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/35a521ZDkbwBkbJfWyPHEq?si=4H21fBm1T5GheyPnuHGcDg"
				}
				
				local chooseSong81 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 82) "Toast"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `koffee' & `jamaica' & `female' & `chooseSong82' {
				
				di  		""
				di as txt  `""Toast"'
				di as txt  `" We nuh rise and boast.""'
				di as txt   " {bf:Koffee}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=p8HoEvDh70Y":https://www.youtube.com/watch?v=p8HoEvDh70Y}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=p8HoEvDh70Y"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3VEpRXloN4rbzNRPSQzZFW?si=OhM_fc17ThqJYW77Zh9Lbg":https://open.spotify.com/track/3VEpRXloN4rbzNRPSQzZFW?si=OhM_fc17ThqJYW77Zh9Lbg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3VEpRXloN4rbzNRPSQzZFW?si=OhM_fc17ThqJYW77Zh9Lbg"
				}
				
				local chooseSong82 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 83) "New Heights"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `kymanimarley' & `jamaica' & `male' & `chooseSong83' {
				
				di  		""
				di as txt  `""I've been working all day and a this me a wait for"'
				di as txt  `" Pass me the blunt and the rolling paper.""'
				di as txt   " {bf:Ky-Mani Marley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=rKIl5nfFASs":https://www.youtube.com/watch?v=rKIl5nfFASs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=rKIl5nfFASs"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/09aLLGz6xaH8C86a6Fs4CO?si=0RAjBdQsQBiI5Oi2nsMUXg":https://open.spotify.com/track/09aLLGz6xaH8C86a6Fs4CO?si=0RAjBdQsQBiI5Oi2nsMUXg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/09aLLGz6xaH8C86a6Fs4CO?si=0RAjBdQsQBiI5Oi2nsMUXg"
				}
				
				local chooseSong83 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		// 84) "Dance Inna Babylon"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `mellowmood' & `italy' & `male' & `chooseSong84' {
				
				di  		""
				di as txt  `""Dance inna Babylon, until its throne a fall"'
				di as txt  `" I'n'I who see teachings of the Rastaman.""'
				di as txt   " {bf:Mellow Mood}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=zVim3go8kso":https://www.youtube.com/watch?v=zVim3go8kso}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=zVim3go8kso"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3fuXNQ0yLJYgXUr3HMb3AZ?si=Jurvgn32QPCNErB3n1uXLA":https://open.spotify.com/track/3fuXNQ0yLJYgXUr3HMb3AZ?si=Jurvgn32QPCNErB3n1uXLA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3fuXNQ0yLJYgXUr3HMb3AZ?si=Jurvgn32QPCNErB3n1uXLA"
				}
				
				local chooseSong84 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 85) "Sound of a War"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `mellowmood' & `italy' & `male' & `chooseSong85' {
				
				di  		""
				di as txt  `""Mister minister don't take we fi fool"'
				di as txt  `" You think we don't know the things weh you do.""'
				di as txt   " {bf:Mellow Mood}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=SI7Hhe9Eu7A":https://www.youtube.com/watch?v=SI7Hhe9Eu7A}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=SI7Hhe9Eu7A"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1GtJLda3q1xRy34J6lR23q?si=HFWvyeDhQrC2iGmyV3jGhg":https://open.spotify.com/track/1GtJLda3q1xRy34J6lR23q?si=HFWvyeDhQrC2iGmyV3jGhg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1GtJLda3q1xRy34J6lR23q?si=HFWvyeDhQrC2iGmyV3jGhg"
				}
				
				local chooseSong85 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 86) "Inna Jamaica pt. 2"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`mellowmood' == 1 | `forelock' == 1 | `hempresssativa' == 1) & ((`italy' == 1  & `male' == 1) | (`jamaica' == 1 & `female' == 1)) & `chooseSong86' == 1 {
				
				di  		""
				di as txt  `""More time mi waan fi spend inna Jamaica"'
				di as txt  `" Mi nuh waan fi go away.""'
				di as txt   " {bf:Mellow Mood & Forelock & Hempress Sativa}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=-e1FxadIqbI":https://www.youtube.com/watch?v=-e1FxadIqbI}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=-e1FxadIqbI"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7obN7CIn2WQqXEzXx612sk?si=ZQtsE04JSE6pPqh6wRcaTg":https://open.spotify.com/track/7obN7CIn2WQqXEzXx612sk?si=ZQtsE04JSE6pPqh6wRcaTg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7obN7CIn2WQqXEzXx612sk?si=ZQtsE04JSE6pPqh6wRcaTg"
				}
				
				local chooseSong86 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 87) "Inna Jamaica"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`mellowmood' == 1 | `richiecampbell' == 1) & (`italy' == 1  | `portugal' == 1) & `male' == 1 & `chooseSong87' == 1 {
				
				di  		""
				di as txt  `""Man affi reach di land of the sun hold a vybz in Jamaica.""'
				di as txt   " {bf:Mellow Mood & Richie Campbell}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=M-SUT4ddfuo":https://www.youtube.com/watch?v=M-SUT4ddfuo}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=M-SUT4ddfuo"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/24y98VFyG8tA5Grb9hYSHn?si=2cVvU7xcTqiV2FQChE4gzw":https://open.spotify.com/track/24y98VFyG8tA5Grb9hYSHn?si=2cVvU7xcTqiV2FQChE4gzw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/24y98VFyG8tA5Grb9hYSHn?si=2cVvU7xcTqiV2FQChE4gzw"
				}
				
				local chooseSong87 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 88) "Andei Só"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `natiruts' & `brazil' & `male' & `chooseSong88' {
								
				di  		""
				di as txt  `""Andei meio só pela noite"'
				di as txt  `" Cantei um Reggae pros cachorros na rua.""'
				di as txt   " {bf:Natiruts}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=Tu4sXwpY6S0":https://www.youtube.com/watch?v=Tu4sXwpY6S0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=Tu4sXwpY6S0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2lWExLBiCX9ZDYjCWZkYPN?si=IHhr4p4lSL2H6RSwt4XPFA":https://open.spotify.com/track/2lWExLBiCX9ZDYjCWZkYPN?si=IHhr4p4lSL2H6RSwt4XPFA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2lWExLBiCX9ZDYjCWZkYPN?si=IHhr4p4lSL2H6RSwt4XPFA"
				}
				
				local chooseSong88 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 89) "Liberdade Pra Dentro da Cabeça"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `natiruts' & `brazil' & `male' & `chooseSong89' {
								
				di  		""
				di as txt  `""Liberdade pra dentro da cabeça.""'
				di as txt   " {bf:Natiruts}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=xGpk-k-TK4s":https://www.youtube.com/watch?v=xGpk-k-TK4s}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=xGpk-k-TK4s"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4oyaAgUMDBM0j8At75jOHn?si=02VoLlp9SI-nqNpJp9R41Q":https://open.spotify.com/track/4oyaAgUMDBM0j8At75jOHn?si=02VoLlp9SI-nqNpJp9R41Q}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4oyaAgUMDBM0j8At75jOHn?si=02VoLlp9SI-nqNpJp9R41Q"
				}
				
				local chooseSong89 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 90) "Presente de um Beija-Flor "
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `natiruts' & `brazil' & `male' & `chooseSong90' {
							
				di  		""
				di as txt  `""Beija-flor que trouxe meu amor"'
				di as txt  `" Voou e foi embora"'
				di as txt  `" Olha só como é lindo meu amor"
				di as txt  `" Estou feliz agora.""'
				di as txt   " {bf:Natiruts}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=kkGDWRIe8rs":https://www.youtube.com/watch?v=kkGDWRIe8rs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=kkGDWRIe8rs"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2Iu5NDjHE7GEi1SGfMgyRT?si=LV1A0wtKQ_Gr8795mwHhGA":https://open.spotify.com/track/2Iu5NDjHE7GEi1SGfMgyRT?si=LV1A0wtKQ_Gr8795mwHhGA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2Iu5NDjHE7GEi1SGfMgyRT?si=LV1A0wtKQ_Gr8795mwHhGA"
				}
				
				local chooseSong90 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 91) "Quero Ser Feliz Também"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `natiruts' & `brazil' & `male' & `chooseSong91' {
								
				di  		""
				di as txt  `""Quero ser feliz também, navegar nas águas do teu mar"'
				di as txt  `" Desejar para tudo que vem flores brancas, paz e Iemanjá.""'
				di as txt   " {bf:Natiruts}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=i1Nm-MJ313w":https://www.youtube.com/watch?v=i1Nm-MJ313w}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=i1Nm-MJ313w"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/09h91oP3t1c5fSEI5P6maS?si=niEVFykoR8CDpgBhLiWKCQ":https://open.spotify.com/track/09h91oP3t1c5fSEI5P6maS?si=niEVFykoR8CDpgBhLiWKCQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/09h91oP3t1c5fSEI5P6maS?si=niEVFykoR8CDpgBhLiWKCQ"
				}
				
				local chooseSong91 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 92) "Sorri, Sou Rei"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`natiruts' == 1 | `claudialeitte' == 1) & `brazil' == 1 & (`male' == 1 | `female' == 1) & `chooseSong92' == 1 {
				
				di  		""
				di as txt  `""Quando você se foi chorei, chorei, chorei"'
				di as txt  `" Agora que voltou sorri"'
				di as txt  `" Sorri, sou rei.""'
				di as txt   " {bf:Natiruts & Claudia Leitte}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=tRmtL8yxcSA":https://www.youtube.com/watch?v=tRmtL8yxcSA}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=tRmtL8yxcSA"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/5lKHrBigpyKZM6uMvbOGh2?si=zLV1-Lp-QhqOLM-YO_u6fA":https://open.spotify.com/track/5lKHrBigpyKZM6uMvbOGh2?si=zLV1-Lp-QhqOLM-YO_u6fA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5lKHrBigpyKZM6uMvbOGh2?si=zLV1-Lp-QhqOLM-YO_u6fA"
				}
				
				local chooseSong92 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 93) "A Matter of Time"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong93' {
				
				di  		""
				di as txt  `""And I got to get what's mine"'
				di as txt  `" It's only a matter of time.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=Z1LOOZeh7qA":https://www.youtube.com/watch?v=Z1LOOZeh7qA}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=Z1LOOZeh7qA"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/62yLFzTjO2shNlxoIiMQrb?si=xLVx9foZRfCSZI13bSfozA":https://open.spotify.com/track/62yLFzTjO2shNlxoIiMQrb?si=xLVx9foZRfCSZI13bSfozA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/62yLFzTjO2shNlxoIiMQrb?si=xLVx9foZRfCSZI13bSfozA"
				}
				
				local chooseSong93 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 94) "All Will Have To Change"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong94' {

				di  		""
				di as txt  `""I say we all will have to change"'
				di as txt  `" In each his own way.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=eenWXAyUMSw":https://www.youtube.com/watch?v=eenWXAyUMSw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=eenWXAyUMSw"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1UwY88aleBy0U4NAwqF8JG?si=_x_Zd-KsS-6-DpWdaLcPqg":https://open.spotify.com/track/1UwY88aleBy0U4NAwqF8JG?si=_x_Zd-KsS-6-DpWdaLcPqg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1UwY88aleBy0U4NAwqF8JG?si=_x_Zd-KsS-6-DpWdaLcPqg"
				}
				
				local chooseSong94 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 95) "Blood Money"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong95' {

				di  		""
				di as txt  `""If what you see no really phase you"'
				di as txt  `" Then you a the problem that we face too.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=etdnIFC4erw":https://www.youtube.com/watch?v=etdnIFC4erw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=etdnIFC4erw"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3WzNtP1VFi5QYoO3io6Ybl?si=5HQtwUoySJaIdmLz2Guwmw":https://open.spotify.com/track/3WzNtP1VFi5QYoO3io6Ybl?si=5HQtwUoySJaIdmLz2Guwmw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3WzNtP1VFi5QYoO3io6Ybl?si=5HQtwUoySJaIdmLz2Guwmw"
				}
				
				local chooseSong95 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 96) "Criminal"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong96' {

				di  		""
				di as txt  `""Them a criminal watch it them a criminal"'
				di as txt  `" Seh them a criminal the whole a dem a criminal.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=CbRW9U2Oj7U":https://www.youtube.com/watch?v=CbRW9U2Oj7U}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=CbRW9U2Oj7U"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/29yLT78oDQ25d9vfewcUIc?si=nmdjK-jpQFa-GKFOnnrzTQ":https://open.spotify.com/track/29yLT78oDQ25d9vfewcUIc?si=nmdjK-jpQFa-GKFOnnrzTQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/29yLT78oDQ25d9vfewcUIc?si=nmdjK-jpQFa-GKFOnnrzTQ"
				}
				
				local chooseSong96 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 97) "I&I"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong97' {
				
				di  		""
				di as txt  `""Ites I a gwaan hold"'
				di as txt  `" A love we living in"'
				di as txt  `" I&I a pass through"'
				di as txt  `" Greetings I bring again.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=-sks_McbbqM":https://www.youtube.com/watch?v=-sks_McbbqM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=-sks_McbbqM"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4w6V1r193RxPSaJQRbESEN?si=5Vp7HPSYRWi4a0c97qHOGQ":https://open.spotify.com/track/4w6V1r193RxPSaJQRbESEN?si=5Vp7HPSYRWi4a0c97qHOGQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4w6V1r193RxPSaJQRbESEN?si=5Vp7HPSYRWi4a0c97qHOGQ"
				}
				
				local chooseSong97 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 98) "Kingston Be Wise"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong98' {

				di  		""
				di as txt  `""Kingston, be wise"'
				di as txt  `" Kingston, free up your mind.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=FFA5e_1Mrvo":https://www.youtube.com/watch?v=FFA5e_1Mrvo}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=FFA5e_1Mrvo"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0qbouIdcN4lrj49jem7TEz?si=eYeXCU4gTsi_V64WxikFjw":https://open.spotify.com/track/0qbouIdcN4lrj49jem7TEz?si=eYeXCU4gTsi_V64WxikFjw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0qbouIdcN4lrj49jem7TEz?si=eYeXCU4gTsi_V64WxikFjw"
				}
				
				local chooseSong98 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 99) "Like This"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong99' {

				di  		""
				di as txt  `""I’ma do my thing like this"'
				di as txt  `" Rock to the riddim like this.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=JLO4IoWCk-8":https://www.youtube.com/watch?v=JLO4IoWCk-8}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=JLO4IoWCk-8"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/40Y6wU9MHPSCTFs5QoO23X?si=kvLwWqh2Q6S4sME9gFFsKA":https://open.spotify.com/track/40Y6wU9MHPSCTFs5QoO23X?si=kvLwWqh2Q6S4sME9gFFsKA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/40Y6wU9MHPSCTFs5QoO23X?si=kvLwWqh2Q6S4sME9gFFsKA"
				}
				
				local chooseSong99 = 0
				local songCount    = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 100) "Mind of a King"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `protoje' & `jamaica' & `male' & `chooseSong100' {

				di  		""
				di as txt  `""Every country, every town"'
				di as txt  `" Calling for the sound.""'
				di as txt   " {bf:Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=iPG7Wlluf_E":https://www.youtube.com/watch?v=iPG7Wlluf_E}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=iPG7Wlluf_E"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3vor1l4dID6poAHLvsTLp3?si=BJE4qrdtTHu2bxcnPMOzIg":https://open.spotify.com/track/3vor1l4dID6poAHLvsTLp3?si=BJE4qrdtTHu2bxcnPMOzIg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3vor1l4dID6poAHLvsTLp3?si=BJE4qrdtTHu2bxcnPMOzIg"
				}
				
				local chooseSong100 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 101) "No Guarantee"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`protoje' == 1) | (`chronixx' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong101' == 1 {
				
				di  		""
				di as txt  `""No matter what them a go say, me haffi live me life"'
				di as txt  `" No worries pon me head when me a go a bed a night.""'
				di as txt   " {bf:Protoje & Chronixx}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=00u5MpRgw1Y":https://www.youtube.com/watch?v=00u5MpRgw1Y}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=00u5MpRgw1Y"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4YVRnPf2I5FXyY8hsHP019?si=Yik923oNSkKmmmXKZUQCyw":https://open.spotify.com/track/4YVRnPf2I5FXyY8hsHP019?si=Yik923oNSkKmmmXKZUQCyw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4YVRnPf2I5FXyY8hsHP019?si=Yik923oNSkKmmmXKZUQCyw"
				}
				
				local chooseSong101 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 102) "Who Knows"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`protoje' == 1) | (`chronixx' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong102' == 1 {
				
				di  		""
				di as txt  `""I'm pleased to be chilling in the West Indies"'
				di as txt  `" Jah provide all my wants and needs.""'
				di as txt   " {bf:Protoje & Chronixx}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=hzqFmXZ8tOE":https://www.youtube.com/watch?v=hzqFmXZ8tOE}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=hzqFmXZ8tOE"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2WPurGHHJunuAkFCczyEe3?si=HtVvBAzQRgq82VgAKSCa8g":https://open.spotify.com/track/2WPurGHHJunuAkFCczyEe3?si=HtVvBAzQRgq82VgAKSCa8g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2WPurGHHJunuAkFCczyEe3?si=HtVvBAzQRgq82VgAKSCa8g"
				}
				
				local chooseSong102 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'		
		
		// 103) "The Flame"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`protoje' == 1) | (`kabakapyramid' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong103' == 1 {
				
				di  		""
				di as txt  `""Forever the same"'
				di as txt  `" Is only Jah love will remain.""'
				di as txt   " {bf:Protoje & Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=-mngMDY4dbI":https://www.youtube.com/watch?v=-mngMDY4dbI}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=-mngMDY4dbI"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0JxiVVApeEgVqvzUQ5sURe?si=d9KEP-l0TPmvWpTqsly2Fw":https://open.spotify.com/track/0JxiVVApeEgVqvzUQ5sURe?si=d9KEP-l0TPmvWpTqsly2Fw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0JxiVVApeEgVqvzUQ5sURe?si=d9KEP-l0TPmvWpTqsly2Fw"
				}
				
				local chooseSong103 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
		// 104) "Rasta Love"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`protoje' == 1) | (`kymanimarley' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong104' == 1 {
				
				di  		""
				di as txt  `""She didnt know how"'
				di as txt  `" To tell him"'
				di as txt  `" She was in love with a rastaman.""'
				di as txt   " {bf:Protoje & Ky-Mani Marley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=AkWXXGe49cw":https://www.youtube.com/watch?v=AkWXXGe49cw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=AkWXXGe49cw"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0cSkIGgh1uICEIcmEb1niw?si=0hTLNAnGS76Moo6bFb3Juw":https://open.spotify.com/track/0cSkIGgh1uICEIcmEb1niw?si=0hTLNAnGS76Moo6bFb3Juw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0cSkIGgh1uICEIcmEb1niw?si=0hTLNAnGS76Moo6bFb3Juw"
				}
				
				local chooseSong104 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 105) "Protection"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`protoje' == 1) | (`mortimer' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong105' == 1 {
				
				di  		""
				di as txt  `""Cause out here in this jungle we roar"'
				di as txt  `" Every king has his throne.""'
				di as txt   " {bf:Protoje & Mortimer}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=nJhuT6zMleM":https://www.youtube.com/watch?v=nJhuT6zMleM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=nJhuT6zMleM"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5UgbG3huDFp8AWzSYpIqaY?si=-AQPb8huQ1mTGUKpzGZZMw":https://open.spotify.com/track/5UgbG3huDFp8AWzSYpIqaY?si=-AQPb8huQ1mTGUKpzGZZMw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5UgbG3huDFp8AWzSYpIqaY?si=-AQPb8huQ1mTGUKpzGZZMw"
				}
				
				local chooseSong105 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 106) "Truths & Rights"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`protoje' == 1) | (`mortimer' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong106' == 1 {
				
				di  		""
				di as txt  `""Cah jah jah bless I with the brightest light"'
				di as txt  `" An I a shine it pon di yout dem plight"'
				di as txt  `" Oh we deh ya so fi truths an rights.""'
				di as txt   " {bf:Protoje & Mortimer}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=n8j7vojNYco":https://www.youtube.com/watch?v=n8j7vojNYco}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=n8j7vojNYco"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3l8jrocAE9zn2W7CAz0on9?si=gZ8iHKIgQaOxvhk98lDXWQ":https://open.spotify.com/track/3l8jrocAE9zn2W7CAz0on9?si=gZ8iHKIgQaOxvhk98lDXWQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3l8jrocAE9zn2W7CAz0on9?si=gZ8iHKIgQaOxvhk98lDXWQ"
				}
				
				local chooseSong106 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 107) "Beautiful Life"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`richiespice' == 1) | (`kathrynaria' == 1)) & ((`jamaica' == 1  & `male' == 1) | (`canada' == 1 & `female' == 1)) & `chooseSong107' == 1 {
				
				di  		""
				di as txt  `""It’s a beautiful life"'
				di as txt  `" One sky, one life, two hearts, one night.""'
				di as txt   " {bf:Richie Spice & Kathryn Aria}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=eBbJNLHaJ5U":https://www.youtube.com/watch?v=eBbJNLHaJ5U}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=eBbJNLHaJ5U"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0PZWdXle8jfsWBpWT98PeQ?si=uyAnG7EJSrCZhrPenTxjyg":https://open.spotify.com/track/0PZWdXle8jfsWBpWT98PeQ?si=uyAnG7EJSrCZhrPenTxjyg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0PZWdXle8jfsWBpWT98PeQ?si=uyAnG7EJSrCZhrPenTxjyg"
				}
				
				local chooseSong107 = 0
				local songCount     = 1 + `songCount'
			}
		}
			
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 108) "Black & White"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax'  {
			if `saralugo' & `germany' & `female' & `chooseSong108' {

				di  		""
				di as txt  `""I'm not black and I'm not white"'
				di as txt  `" Something in between and thats alright"'
				di as txt  `" Believe me its alright.""'
				di as txt   " {bf:Sara Lugo}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=yxZPMfx_DYA":https://www.youtube.com/watch?v=yxZPMfx_DYA}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=yxZPMfx_DYA"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2mRYXkOe3Z9LmGJZbn6Axo?si=H3WSu8CBTKK-ACJc077JWw":https://open.spotify.com/track/2mRYXkOe3Z9LmGJZbn6Axo?si=H3WSu8CBTKK-ACJc077JWw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2mRYXkOe3Z9LmGJZbn6Axo?si=H3WSu8CBTKK-ACJc077JWw"
				}
				
				local chooseSong108 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 109) "Play With Fire"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax'  {
			if `saralugo' & `germany' & `female' & `chooseSong109' {

				di  		""
				di as txt  `""Well if you play with fire you will get burnt.""'
				di as txt   " {bf:Sara Lugo}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=3wMu41Kkv30":https://www.youtube.com/watch?v=3wMu41Kkv30}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=3wMu41Kkv30"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5dLXutiPFJ7hxc2u3uPOjp?si=Gse_7z3CQlqi4jBmALp9tA":https://open.spotify.com/track/5dLXutiPFJ7hxc2u3uPOjp?si=Gse_7z3CQlqi4jBmALp9tA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5dLXutiPFJ7hxc2u3uPOjp?si=Gse_7z3CQlqi4jBmALp9tA"
				}
				
				local chooseSong109 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 110) "High & Windy"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`kabakapyramid' == 1 | `saralugo' == 1) & ((`jamaica' == 1  & `male' == 1) | (`germany' == 1 & `female' == 1)) & `chooseSong110' == 1 {
			
				di  		""
				di as txt  `""Riding on a high and windy day"'
				di as txt  `" Riding my troubles away.""'
				di as txt   " {bf:Sara Lugo & Kabaka Pyramid}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=XDng01g3Ejw":https://www.youtube.com/watch?v=XDng01g3Ejw}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=XDng01g3Ejw"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/0E1HHOAk52Z5STOKrUmBhR?si=ErZazDuITPiiVZu5keORTQ":https://open.spotify.com/track/0E1HHOAk52Z5STOKrUmBhR?si=ErZazDuITPiiVZu5keORTQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0E1HHOAk52Z5STOKrUmBhR?si=ErZazDuITPiiVZu5keORTQ"
				}
				
				local chooseSong110 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 111) "Really Like You"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`saralugo' == 1 | `protoje' == 1) & ((`jamaica' == 1  & `male' == 1) | (`germany' == 1 & `female' == 1)) & `chooseSong111' == 1 {
				
				di  		""
				di as txt  `""Cos I really really like you"'
				di as txt  `" There's something about you"'
				di as txt  `" Don't you think so, too.""'
				di as txt   " {bf:Sara Lugo & Protoje}"
				
				if "`platform'" == "youtube" {
					
					di as text			`"  {browse "https://www.youtube.com/watch?v=dr9OXGqR8Tg":https://www.youtube.com/watch?v=dr9OXGqR8Tg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=dr9OXGqR8Tg"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/21HsvKIyvp2HtVIqg4LHQH?si=wZxN3WEtQtCxMd6cEFQYWw":https://open.spotify.com/track/21HsvKIyvp2HtVIqg4LHQH?si=wZxN3WEtQtCxMd6cEFQYWw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/21HsvKIyvp2HtVIqg4LHQH?si=wZxN3WEtQtCxMd6cEFQYWw"
				}
				
				local chooseSong111 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 112) "Really Like You"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if (`saralugo' == 1 | `randyvalentine' == 1) & ((`jamaica' == 1  & `male' == 1) | (`germany' == 1 & `female' == 1)) & `chooseSong112' == 1 {
				
				di  		""
				di as txt  `""In my living room, I'm growing a jungle"'
				di as txt  `" Cause it's cold out and winter is coming".""'
				di as txt   " {bf:Sara Lugo & Randy Valentine}"
				
				if "`platform'" == "youtube" {
					
					di as text			`"  {browse "https://www.youtube.com/watch?v=NzEe1GMG3ZI":https://www.youtube.com/watch?v=NzEe1GMG3ZI}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=NzEe1GMG3ZI"
				}
				
				if "`platform'" == "spotify" {
				
					di as text 			`"  {browse "https://open.spotify.com/track/3APqC16VGdbo1Z9vwzdDUr?si=baLOG0C8SHuMLCk2TT47lA":https://open.spotify.com/track/3APqC16VGdbo1Z9vwzdDUr?si=baLOG0C8SHuMLCk2TT47lA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3APqC16VGdbo1Z9vwzdDUr?si=baLOG0C8SHuMLCk2TT47lA"
				}
				
				local chooseSong112 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 113) "Le Radici Ca Tieni"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `sudsoundsystem' & `italy' & `male' & `chooseSong113' {

				di  		""
				di as txt  `""Se nu te scierri mai de le radici ca tieni"'
				di as txt  `" Rispetti puru quiddre de li paisi luntani"'
				di as txt  `" Se nu te scierri mai de du ede ca ssa ieni"'
				di as txt  `" Dai chiù valore a la cultura ca tieni.""'
				di as txt   " {bf:Sud Sound System}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=LsTQM4t76r8":https://www.youtube.com/watch?v=LsTQM4t76r8}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=LsTQM4t76r8"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4oVjEZ8WwGt67ZhoNchF1q?si=BQePs4NEQGSoPrkG0EyK7w":https://open.spotify.com/track/4oVjEZ8WwGt67ZhoNchF1q?si=BQePs4NEQGSoPrkG0EyK7w}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4oVjEZ8WwGt67ZhoNchF1q?si=BQePs4NEQGSoPrkG0EyK7w"
				}
				
				local chooseSong113 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 114) "Sciamu A Ballare"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `sudsoundsystem' & `italy' & `male' & `chooseSong114' {

				di  		""
				di as txt  `""Fatte beddrha pe sta sira cè na festa"'
				di as txt  `" Ne scuamu a ballare a innanzi a mare.""'
				di as txt   " {bf:Sud Sound System}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=LYeEV1ZEVpQ":https://www.youtube.com/watch?v=LYeEV1ZEVpQ}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=LYeEV1ZEVpQ"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0zzZJCmaDU6IHubleLEAUQ?si=NQMGaErUR4epUUuRQoflfw":https://open.spotify.com/track/0zzZJCmaDU6IHubleLEAUQ?si=NQMGaErUR4epUUuRQoflfw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0zzZJCmaDU6IHubleLEAUQ?si=NQMGaErUR4epUUuRQoflfw"
				}
				
				local chooseSong114 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 115) "She's Royal"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `tarrusriley' & `jamaica' & `male' & `chooseSong115' {

				di  		""
				di as txt  `""And she's royal, yeah so royal""'
				di as txt   " {bf:Tarrus Riley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=qGuLqe-NMKg":https://www.youtube.com/watch?v=qGuLqe-NMKg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=qGuLqe-NMKg"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6dFOwtd9iBMERardJvsIxY?si=Vx3a5SjPRniDp4wTiIdSxQ":https://open.spotify.com/track/6dFOwtd9iBMERardJvsIxY?si=Vx3a5SjPRniDp4wTiIdSxQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6dFOwtd9iBMERardJvsIxY?si=Vx3a5SjPRniDp4wTiIdSxQ"
				}
				
				local chooseSong115 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 116) "Sorry Is A Sorry Word"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `tarrusriley' & `jamaica' & `male' & `chooseSong116' {

				di  		""
				di as txt  `""I'm sorry that you're sorry but sorry's not good enough for me baby"'
				di as txt  `" I'm sorry that you're sorry but sorry can't dry my tears lady.""'
				di as txt   " {bf:Tarrus Riley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=0OKNG7-8RVs":https://www.youtube.com/watch?v=0OKNG7-8RVs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=0OKNG7-8RVs"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/05Z4eQ7llqucxW1BMeGOVR?si=2QmwvDQiRxiB7Elf0Xm81g":https://open.spotify.com/track/05Z4eQ7llqucxW1BMeGOVR?si=2QmwvDQiRxiB7Elf0Xm81g}
					if "`browse'" != "" view browse "https://open.spotify.com/track/05Z4eQ7llqucxW1BMeGOVR?si=2QmwvDQiRxiB7Elf0Xm81g"
				}
				
				local chooseSong116 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 117) "Superman"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `tarrusriley' & `jamaica' & `male' & `chooseSong117' {

				di  		""
				di as txt  `""I will be there when you need someone to tell you"'
				di as txt  `" That you're beautiful baby.""'
				di as txt   " {bf:Tarrus Riley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=l4yD1dsv5Ho":https://www.youtube.com/watch?v=l4yD1dsv5Ho}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=l4yD1dsv5Ho"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4E6TkulZSnor5RzOkkW32U?si=owXJJ8VkQii9h604kyZ7Hg":https://open.spotify.com/track/4E6TkulZSnor5RzOkkW32U?si=owXJJ8VkQii9h604kyZ7Hg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4E6TkulZSnor5RzOkkW32U?si=owXJJ8VkQii9h604kyZ7Hg"
				}
				
				local chooseSong117 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 118) "Gente do Sud"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `terroniuniti' & `italy' & `male' & `chooseSong118' {
				
				di  		""
				di as txt  `""Gente d''o sud"'
				di as txt  `" Gente d''o mare"'
				di as txt  `" Gente capace 'e credere ancora dint'a ll'ammore.""'
				di as txt   " {bf:Terroni Uniti}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=TVKGGyoUlRo":https://www.youtube.com/watch?v=TVKGGyoUlRo}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=TVKGGyoUlRo"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3aehno2i6NeUbu6p9ewOog?si=AucDJRDdQYCM2uOleIQShA":https://open.spotify.com/track/3aehno2i6NeUbu6p9ewOog?si=AucDJRDdQYCM2uOleIQShA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3aehno2i6NeUbu6p9ewOog?si=AucDJRDdQYCM2uOleIQShA"
				}
				
				local chooseSong118 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 119) Dawn of Time
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `tribalseeds' & `unitedstates' & `male' & `chooseSong119' {
				
				di  		""
				di as txt  `""Virtuous girl"'
				di as txt  `" Jah has your heart"'
				di as txt  `" Lust of earth couldn't set you apart.""'
				di as txt   " {bf:Tribal Seeds}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=LD_XAEw_npg":https://www.youtube.com/watch?v=LD_XAEw_npg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=LD_XAEw_npg"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/445qQk3nyQwmjf4vzDghKd?si=z9D4rlaKR4SIYT6pjcttuw":https://open.spotify.com/track/445qQk3nyQwmjf4vzDghKd?si=z9D4rlaKR4SIYT6pjcttuw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/445qQk3nyQwmjf4vzDghKd?si=z9D4rlaKR4SIYT6pjcttuw"
				}
				
				local chooseSong119 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 120) Moonlight
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `tribalseeds' & `unitedstates' & `male' & `chooseSong120' {
				
				di  		""
				di as txt  `""We're jamming in the moonlight"'
				di as txt  `" Hear the sound waves by the seaside"'
				di as txt  `" We don't need to play for anyone.""'
				di as txt   " {bf:Tribal Seeds}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=cq_zQ3lPKDk":https://www.youtube.com/watch?v=cq_zQ3lPKDk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=cq_zQ3lPKDk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5G8xknglIO3jFYIXS34YB2?si=i4ZkECqdSta1nQeZjfgePg":https://open.spotify.com/track/5G8xknglIO3jFYIXS34YB2?si=i4ZkECqdSta1nQeZjfgePg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5G8xknglIO3jFYIXS34YB2?si=i4ZkECqdSta1nQeZjfgePg"
				}
				
				local chooseSong120 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 121) Rasta Refuse It
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `tribalseeds' & `unitedstates' & `male' & `chooseSong121' {
				
				di  		""
				di as txt  `""What Babylon try to offer, rasta refuse it.""'
				di as txt   " {bf:Tribal Seeds}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=YejW4Tm2KK0":https://www.youtube.com/watch?v=YejW4Tm2KK0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=YejW4Tm2KK0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1T6FRo7wf886jV2iq0remh?si=vrJGPzdmSNqrsWt61siAIg":https://open.spotify.com/track/1T6FRo7wf886jV2iq0remh?si=vrJGPzdmSNqrsWt61siAIg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1T6FRo7wf886jV2iq0remh?si=vrJGPzdmSNqrsWt61siAIg"
				}
				
				local chooseSong121 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 122) Love Is My Religion
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
			if `ziggymarley' & `jamaica' & `male' & `chooseSong122' {
				
				di  		""
				di as txt  `""Love is my religion"'
				di as txt  `" I'll take you to the temple tonight.""'
				di as txt   " {bf:Ziggy Marley}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=r-eXYJnV3V4":https://www.youtube.com/watch?v=r-eXYJnV3V4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=r-eXYJnV3V4"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3NmRPLkEx1EL7LHAe3OZVr?si=uLMdqpLcRmiZ8E5CuAQkug":https://open.spotify.com/track/3NmRPLkEx1EL7LHAe3OZVr?si=uLMdqpLcRmiZ8E5CuAQkug}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3NmRPLkEx1EL7LHAe3OZVr?si=uLMdqpLcRmiZ8E5CuAQkug"
				}
				
				local chooseSong122 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// Bonus tracks
		// ------------
		
		// 123) "Beach and Country"
		if `randomSong'  > `rangeMin' & `randomSong' <= `rangeMax' {
			if `morganheritage' & `jamaica' & `male' & `chooseSong123' {
			
				di  		""
				di as txt  `""Now tell me where can you find this vibe all the time only.""'
				di as txt   " {bf:Morgan Heritage}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=_n68lXBeKG0":https://www.youtube.com/watch?v=_n68lXBeKG0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=_n68lXBeKG0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6GcSetw1kC8VCxbXJ3lG6i?si=vn2tRQQ0SVe2Uzv6I-fVgg":https://open.spotify.com/track/6GcSetw1kC8VCxbXJ3lG6i?si=vn2tRQQ0SVe2Uzv6I-fVgg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6GcSetw1kC8VCxbXJ3lG6i?si=vn2tRQQ0SVe2Uzv6I-fVgg"
				}
				
				local chooseSong123 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		//124) "Dreams Of Brighter Days"
		if `randomSong'  > `rangeMin' & `randomSong' <= `rangeMax' {
			if ((`busysignal' == 1) | (`rc' == 1)) & `jamaica' == 1 & `male' == 1 & `chooseSong124' == 1 {
			
				di  		""
				di as txt  `""Dreams of brighter days ..."'
				di as txt  `" Highest grades we blaze.""'
				di as txt   " {bf:Busy Signal & RC}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=dU09pwNot9c":https://www.youtube.com/watch?v=dU09pwNot9c}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=dU09pwNot9c"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1Fo1kCjIFWcy6uyr2btG3R?si=ToM7QixcQ9eFBv_GNMPzDg":https://open.spotify.com/track/1Fo1kCjIFWcy6uyr2btG3R?si=ToM7QixcQ9eFBv_GNMPzDg}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1Fo1kCjIFWcy6uyr2btG3R?si=ToM7QixcQ9eFBv_GNMPzDg"
				}
				
				local chooseSong124 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		//125) "To Serve And Protect"
		if `randomSong'  > `rangeMin' & `randomSong' <= `rangeMax' {
			if `queenifrica' & `jamaica' & `female' & `chooseSong125' {
			
				di  		""
				di as txt  `""We need somebody fi defend the poor.""'
				di as txt   " {bf:Queen Ifrica}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=R_3vZA3g4G8":https://www.youtube.com/watch?v=R_3vZA3g4G8}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=R_3vZA3g4G8"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6JPmyr2qSrgE6TgtSA48Dc?si=cSXI4VrES3O4n4AqZHBz9w":https://open.spotify.com/track/6JPmyr2qSrgE6TgtSA48Dc?si=cSXI4VrES3O4n4AqZHBz9w}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6JPmyr2qSrgE6TgtSA48Dc?si=cSXI4VrES3O4n4AqZHBz9w"
				}
				
				local chooseSong125 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		//126) "Rest Of My File"
		if `randomSong'  > `rangeMin' & `randomSong' <= `rangeMax' {
			if `soja' & `unitedstates' & `female' & `chooseSong126' {
			
				di  		""
				di as txt  `""If I could spend the rest of my life with my people,"'
				di as txt  `" I would do it over and over again.""'
				di as txt   " {bf:SOJA}"
				
				if "`platform'" == "youtube" {
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=X572Mp_r46E":https://www.youtube.com/watch?v=X572Mp_r46E}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=X572Mp_r46E"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/7aP6GXrxvq0836pzL4kHK8?si=MzRFjndCSuO4fWIJummKug":https://open.spotify.com/track/7aP6GXrxvq0836pzL4kHK8?si=MzRFjndCSuO4fWIJummKug}
					if "`browse'" != "" view browse "https://open.spotify.com/track/7aP6GXrxvq0836pzL4kHK8?si=MzRFjndCSuO4fWIJummKug"
				}
				
				local chooseSong126 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		//127) "When We Were Younger
		if `randomSong'  > `rangeMin' & `randomSong' <= `rangeMax' {
			if `soja' & `unitedstates' & `female' & `chooseSong127' {
			
				if "`platform'" == "youtube" {
				
					di  		""
					di as txt  `""When I was younger,"'
					di as txt  `" had the answers, I've got to say"'
					di as txt  `" but all of my answers, now that I'm older"'
					di as txt  `" turned into questions, in front of me.""'
					di as txt   " {bf:SOJA}"				
					
					di as text 			`"  {browse "https://www.youtube.com/watch?v=td2Kv4ZbJWs":https://www.youtube.com/watch?v=td2Kv4ZbJWs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=td2Kv4ZbJWs"
				}
				
				if "`platform'" == "spotify" continue
				
				local chooseSong127 = 0
				local songCount     = 1 + `songCount'
			}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
	}
	
// End
end

// Blessings!

