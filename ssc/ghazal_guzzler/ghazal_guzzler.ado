
// Ghazal music random generator

cap prog drop ghazal_guzzler
	prog def  ghazal_guzzler
        version 14

	syntax	,									/// No variable required
												///
	   [BRowse]									/// Directly open the link in browser
	   [NUMber(numlist int min=1)]				/// Number of songs (must be an interger equal or greater than 1)
	   [PLAYlist]								/// Full playlist
	   [PLATFORM(string)]						/// Music platform or website
	   
	   
	// Set minimum version for this command
	version 10
		
	if "`playlist'" != "" {
		
		// Error for playlist and number option incorrectly used together
		
		foreach optionName in number {
	
			if "``optionName''" != "" {
			
				noi di as error "Option {bf:`optionName'} may not be used in combination with option {bf:playlist}."
						  error  197
			}
		}
	}
	
	// Transform all option strings
	foreach optionName in platform {
		
		local `optionName' =  trim("``optionName''") //trim() is older syntax, compare to strtrim() in Stata 15 and newer
		local `optionName' = lower("``optionName''")
	}
	
	// If 'platform' option is used, check that it exists in our package
	if "`platform'" != "" {
	
		if "`platform'" != "youtube" &  "`platform'" != "spotify" {
			
			noi di as error "The {bf:platform} you selected is not available in our package."
			noi di as error "Feel free to suggest it by opening an issue in:""
			noi di as error `" {browse "https://github.com/prashansasrivastava/ghazal_guzzler/issues":https://github.com/prashansasrivastava/ghazal_guzzler/issues}
					  exit
		}
	}	
	
	// If `platform' option is not used, we will use Youtube
	if "`platform'" == "" local platform "youtube"
	
	// If 'playlist' option is selected, we display the link to the Youtube playlist and exit the program
	if "`playlist'" != "" {
		
		if "`platform'" == "youtube" {
			
			di as txt   "Enjoy the melancholic comforting tunes- here is the Ghazal playlist for Stata users on Youtube!"
			di		    ""
			di as text 			`"  {browse "https://www.youtube.com/playlist?list=PLTgBj_KQ43m_Xo6WDUlrlgOHBshdYvGSr":https://www.youtube.com/playlist?list=PLTgBj_KQ43m_Xo6WDUlrlgOHBshdYvGSr}
			
			if "`browse'" != "" view browse "https://www.youtube.com/playlist?list=PLTgBj_KQ43m_Xo6WDUlrlgOHBshdYvGSr"
			exit
		}
		
		if "`platform'" == "spotify" {
			
			di as txt   "Enjoy the melancholic comforting tunes- here is the Ghazal playlist for Stata users on Spotify!"
			di		    ""
			di as text 			`"  {browse "https://open.spotify.com/playlist/0bDBDFzuxeE5RjMEkTwVE3":https://open.spotify.com/playlist/0bDBDFzuxeE5RjMEkTwVE3}
			
			if "`browse'" != "" view browse "https://open.spotify.com/playlist/0bDBDFzuxeE5RjMEkTwVE3"
			exit
		}
	}
		
	
	// If 'number' option is not used, we display one song
	if 	 "`number'" == "" local number = 1
		
	
	// Initialize song counter
	local  totalSong  = 25
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

		// 1) "Gulon mein rang bhare"

		if `randomSong' <= `rangeMax' {
			if `chooseSong1' == 1 {	
				di  		""
				di as txt  `""Gulon mein rang bhare"'
				di as txt  `" baad-e-naubahaar chale "'
				di as txt  `" Chale bhi aao ke "'
				di as txt  `" gulshan ka kaarobaar chale.""'

				di as txt   " {bf: Written by Faiz, sung by Mehdi Hassan}"
				
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
		
		// 2) "Ranjish hi sahi"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong2' == 1	{
				di  		""
				di as txt  `""Ranjish hi sahi dil hi dukhane ke liye aa"'
				di as txt  `" aa phir se mujhe "'
				di as txt  `" chhod ke jaane ke liye aa.""'

				di as txt   " {bf: Written by Ahmed Faraz, sung by Mehdi Hassan}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=dOtqwZdhBkc&ab_channel=HayatEntertainment":https://www.youtube.com/watch?v=dOtqwZdhBkc&ab_channel=HayatEntertainment}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=dOtqwZdhBkc&ab_channel=HayatEntertainment"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1Ot6UNRGj2aYS3xtqw1YtA?si=VbHm5yj2TUKY7kqRUYvTGQ":https://open.spotify.com/track/1Ot6UNRGj2aYS3xtqw1YtA?si=VbHm5yj2TUKY7kqRUYvTGQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1Ot6UNRGj2aYS3xtqw1YtA?si=VbHm5yj2TUKY7kqRUYvTGQ"
				}
				
				local chooseSong2 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'

		// 3) "Hum dekhenge"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong3' == 1	{		
				di  		""
				di as txt  `""Hum Dekhenge, Hum Dekhenge"'
				di as txt  `" Lazim hai ke hum bhi dekhenge"'
				di as txt  `" Wo din ke jis ka wada hai"'
				di as txt  `" Jo lauh-e-azl mein likha hai, Hum Dekhenge.""'

				di as txt   " {bf: Written by Faiz, sung by Iqbal Bano}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=dxtgsq5oVy4":https://www.youtube.com/watch?v=dxtgsq5oVy4}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=dxtgsq5oVy4"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2k0WWTywTT1r591Zo7GI0r?si=wo8asjw-TtmA9rnSBPXpdw":https://open.spotify.com/track/2k0WWTywTT1r591Zo7GI0r?si=wo8asjw-TtmA9rnSBPXpdw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2k0WWTywTT1r591Zo7GI0r?si=wo8asjw-TtmA9rnSBPXpdw"
				}
				
				local chooseSong3 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
		// 4) "Hum ke thehray ajnabi"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong4' == 1	{		
				di  		""
				di as txt  `""Hum ke thehre ajnabi "'
				di as txt  `" itni madaaraaton ke baad"'
				di as txt  `" Phir baneinge aashna"'
				di as txt  `" kitni mulaaqaaton ke baad""'

				di as txt   " {bf: Written by Faiz, sung by Nayyara Noor}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=KB7aZ8RYTD4&ab_channel=FarrukhManzoor":https://www.youtube.com/watch?v=KB7aZ8RYTD4&ab_channel=FarrukhManzoor}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=KB7aZ8RYTD4&ab_channel=FarrukhManzoor"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3Gxg0ktusCTpJwj15nedu2":https://open.spotify.com/track/3Gxg0ktusCTpJwj15nedu2}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3Gxg0ktusCTpJwj15nedu2"
				}
				
				local chooseSong4 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'		
		
		// 5) "Aaj bazaar main"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong5' == 1	{		
				di  		""
				di as txt  `""Aaj bazaar main pa bajolan chalo "'
				di as txt  `" Chashm-e-nam, jaan-e-shoreeda kafi nahin"'
				di as txt  `" Tohmat-e-ishq-posheeda kafi nahin""'

				di as txt   " {bf: Written by Faiz, sung by Nayyara Noor}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=xt25z-tuBio&ab_channel=EMIPakistan":https://www.youtube.com/watch?v=xt25z-tuBio&ab_channel=EMIPakistan}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=xt25z-tuBio&ab_channel=EMIPakistan"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5Mfzkm28Rh6eErgh40CjDy":https://open.spotify.com/track/5Mfzkm28Rh6eErgh40CjDy}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5Mfzkm28Rh6eErgh40CjDy"
				}
				
				local chooseSong5 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
		
		// 6) "Dasht-e-tanhai"
		
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong6' == 1	{		
				di  		""
				di as txt  `""Dasht-e-tanhai mein"'
				di as txt  `" Aye Jaan-e-jahaan Larzan Hai"'
				di as txt  `" Teri Aawaaz Ke Saaye"'
				di as txt  `" Tere Honton Ke Seraab""'

				di as txt   " {bf: Written by Faiz, sung by Iqbal Bano}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=vaYXmhX7GmM":https://www.youtube.com/watch?v=vaYXmhX7GmM}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=vaYXmhX7GmM"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0PZO1Ih1qTQawy5Wc9B7zy":https://open.spotify.com/track/0PZO1Ih1qTQawy5Wc9B7zy}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0PZO1Ih1qTQawy5Wc9B7zy"
				}
				
				local chooseSong6 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
		
		// 7) "Aaj jaane ki zidd"
		
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong7' == 1	{		
				di  		""
				di as txt  `""Waqt ki kaid mein zindagee hai magar"'
				di as txt  `" Chand ghadiyaan yahee hain jo aazaad hai"'
				di as txt  `" Inko kho kar meree jaanejaan"'
				di as txt  `" Umr bhar na tarasate raho"'
				di as txt  `" Aaj jaane ki zid na karo""'

				di as txt   " {bf: Written by Fayyaz Hashmi, sung by Farida Khanum}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=hBvdIsBmQ6g":https://www.youtube.com/watch?v=hBvdIsBmQ6g}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=hBvdIsBmQ6g"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4pFPpJJpv4bW7KFCcU7abM":https://open.spotify.com/track/4pFPpJJpv4bW7KFCcU7abM}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4pFPpJJpv4bW7KFCcU7abM"
				}
				
				local chooseSong7 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
			// 8) "Aaj jaane ki zidd"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong8' == 1	{		
				di  		""
				di as txt  `""When Farida Khanum sings now,she does not hide the age"'
				di as txt  `"in her voice,instead she wraps it in paisleys and for a moment"'
				di as txt  `"holds it in both of her hands, before she drowns it in our sky."'
				di as txt  `"When she sings now,she knows that at the end of that note"'
				di as txt  `"when her voice breaks like a wishbone,"'
				di as txt  `"he will stay.""'

				di as txt   " {bf: Written by Fayyaz Hashmi, sung by Farida Khanum. Above poetry by Akhil Katyal.}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=hBvdIsBmQ6g":https://www.youtube.com/watch?v=hBvdIsBmQ6g}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=hBvdIsBmQ6g"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4pFPpJJpv4bW7KFCcU7abM":https://open.spotify.com/track/4pFPpJJpv4bW7KFCcU7abM}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4pFPpJJpv4bW7KFCcU7abM"
				}
				
				local chooseSong8 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		


			// 9) "Mohabbat karne wale"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong9' == 1	{		
				di  		""
				di as txt  `""Zamane bhar ke gum ya ik tera gum"'
				di as txt  `"Ye gum hoga to kitne gum na honge"'
				di as txt  `"Teri mehfil mein lekin hum na honge"'
				di as txt  `"Mohabbat karne wale kam na honge.""'

				di as txt   " {bf: Written by Haffiz Hoshyarpuri, sung by Farida Khanum.}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=XPyrj6WTIy0&ab_channel=EMIPakistan":https://www.youtube.com/watch?v=XPyrj6WTIy0&ab_channel=EMIPakistan}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=XPyrj6WTIy0&ab_channel=EMIPakistan"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0S5eseK4Kt7DJmPqT5TOGH":https://open.spotify.com/track/0S5eseK4Kt7DJmPqT5TOGH}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0S5eseK4Kt7DJmPqT5TOGH"
				}
				
				local chooseSong9 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'		
		
			// 10) "Ab ke sawan ghar aaja"


		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong10' == 1	{		
				di  		""
				di as txt  `""Ab ke sawan ghar aaja"'

				di as txt   " {bf: - Thumri by Begum Akhtar.}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=oWRLb6vRcYQ&ab_channel=thetrialofjosefk":https://www.youtube.com/watch?v=oWRLb6vRcYQ&ab_channel=thetrialofjosefk}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=oWRLb6vRcYQ&ab_channel=thetrialofjosefk"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0cis70ubbGdK9l1TiV8995":https://open.spotify.com/track/0cis70ubbGdK9l1TiV8995}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0cis70ubbGdK9l1TiV8995"
				}
				
				local chooseSong10 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
			// 11) "Muddat hui hai yaar ko"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong11' == 1	{		
				di  		""
				di as txt  `""Muddat huī hai yaar ko"'
				di as txt  `"mehmāñ kiye hue "'
				di as txt  `"josh-e-qadah se bazm"'
				di as txt  `"charāġhāñ kiye hue .""'

				di as txt   " {bf: Written by Ghalib, sung by Mehdi Hassan}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=t090kx5NTf8&ab_channel=MehdiHassan-Topic":https://www.youtube.com/watch?v=t090kx5NTf8&ab_channel=MehdiHassan-Topic}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=t090kx5NTf8&ab_channel=MehdiHassan-Topic"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2J7ebDHapZDMG5rKbUQieq":https://open.spotify.com/track/2J7ebDHapZDMG5rKbUQieq}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2J7ebDHapZDMG5rKbUQieq"
				}
				
				local chooseSong11 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'			
		
			// 12) "Sham-e-Firaq ab na"

		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong12' == 1	{		
				di  		""
				di as txt  `""shām-e-firāq ab na pūchh"' 
				di as txt  `"aaī aur aa ke Tal gai"' 
				di as txt  `"dil thā ki phir bahal gayā"' 
				di as txt  `"jaañ thī ki phir sambhal ga.ī ""' 

				di as txt   " {bf: Written by Faiz, sung by Iqbal Bano }"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=MfM01I0RtAg":https://www.youtube.com/watch?v=MfM01I0RtAg}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=MfM01I0RtAg"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5lrBubRWjoRTwMaS1qpkvD":https://open.spotify.com/track/5lrBubRWjoRTwMaS1qpkvD}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5lrBubRWjoRTwMaS1qpkvD"
				}
				
				local chooseSong12 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
		
			// 13) "Mora saiyaan"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong13' == 1	{		
				di  		""
				di as txt  `""Sawan beeto jaye peeharwa"'
				di as txt  `"Mann mera ghabraaye"'
				di as txt  `"Aiso gaye pardes piya tum"'
				di as txt  `"Chain hume nahi aa aaye"'
				di as txt  `"Mora saiyaan mo se bole na""'

				di as txt   " {bf: Sung by Shafqat Amanat Ali}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=MpdvAKR52MQ&ab_channel=LyricPur":https://www.youtube.com/watch?v=MpdvAKR52MQ&ab_channel=LyricPur}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=MpdvAKR52MQ&ab_channel=LyricPur"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/1CTFgZCW0ljb0P4mv7hzQU":https://open.spotify.com/track/1CTFgZCW0ljb0P4mv7hzQU}
					if "`browse'" != "" view browse "https://open.spotify.com/track/1CTFgZCW0ljb0P4mv7hzQU"
				}
				
				local chooseSong13 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'		
		
			
			// 14) "Dil jalane ki baat karte"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong14' == 1	{		
				di  		""
				di as txt  `""āshiyāne kī baat karte ho"' 
				di as txt  `"dil jalāne kī baat karte ho"' 
				di as txt  `"saarī duniyā ke ranj-o-ġham de kar"' 
				di as txt  `"muskurāne kī baat karte ho""' 

				di as txt   " {bf: Written by Javeed Qureshi, sung by Farida Khanum}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=zRM_NXPY0ro&ab_channel=Shemaroo":https://www.youtube.com/watch?v=zRM_NXPY0ro&ab_channel=Shemaroo}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=zRM_NXPY0ro&ab_channel=Shemaroo"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/6r0jQzLgo0YsLKAbkl8qfB":https://open.spotify.com/track/6r0jQzLgo0YsLKAbkl8qfB}
					if "`browse'" != "" view browse "https://open.spotify.com/track/6r0jQzLgo0YsLKAbkl8qfB"
				}
				
				local chooseSong14 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'		
		
		
			// 15) "Mere ham-nafas mere ham-navā"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong15' == 1	{		
				di  		""
				di as txt  `""Mere ham-nafas mere ham-navā "' 
				di as txt  `"Mujhe dost ban ke daġhā na de "' 
				di as txt  `"Maiñ huuñ dard-e-ishq se jāñ-ba-lab"' 
				di as txt  `"Mujhe zindagī kī duā na de""' 

				di as txt   " {bf: Written by Shakeel Badayuni, sung by Begum Akhtar}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=XYgG6SiX7ZE&ab_channel=shaukeentabiyat":https://www.youtube.com/watch?v=XYgG6SiX7ZE&ab_channel=shaukeentabiyat}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=XYgG6SiX7ZE&ab_channel=shaukeentabiyat"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5FeePbQVljzJRqXCQEqX6C":https://open.spotify.com/track/5FeePbQVljzJRqXCQEqX6C}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5FeePbQVljzJRqXCQEqX6C"
				}
				
				local chooseSong15 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'		
		
		
			// 16) "Rafta Rafta"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong16' == 1	{		
				di  		""
				di as txt  `""Rafta Rafta Wo Meri "' 
				di as txt  `"Hasti Ka Saman Ho Gaye "' 
				di as txt  `"Pehle Jaan Phir Jaan-e-jaan"' 
				di as txt  `"Phir Jaan-e-jaana Ho Gaye""' 

				di as txt   " {bf: Written by Naushad, sung by Mehdi Hassan}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=jtzioa3ddKE&ab_channel=qadrathejutt":https://www.youtube.com/watch?v=jtzioa3ddKE&ab_channel=qadrathejutt}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=jtzioa3ddKE&ab_channel=qadrathejutt"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/5fCtkQFAKBv2zxbfYaKqu7":https://open.spotify.com/track/5fCtkQFAKBv2zxbfYaKqu7}
					if "`browse'" != "" view browse "https://open.spotify.com/track/5fCtkQFAKBv2zxbfYaKqu7"
				}
				
				local chooseSong16 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'			

		
				// 17) "Wo jo ham men tum men qaraar tha "
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong17' == 1	{		
				di  		""
				di as txt  `""Wo jo ham mein tum mein qaraar tha "' 
				di as txt  `"Tumhein yaad ho ki na yaad ho "' 
				di as txt  `"Wahi yaani waada nibaah ka"' 
				di as txt  `"Tumhein yaad ho ki na yaad ho ""' 

				di as txt   " {bf: Written by Momin Khan Momin, sung by Begum Akhtar}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=Uzq1rpuFMig":https://www.youtube.com/watch?v=Uzq1rpuFMig}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=Uzq1rpuFMig"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/0gzjSKitTWq3sU3oy13Pok?si=w87IflDzQEqpk45voOMeGQ":https://open.spotify.com/track/0gzjSKitTWq3sU3oy13Pok?si=w87IflDzQEqpk45voOMeGQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/0gzjSKitTWq3sU3oy13Pok?si=w87IflDzQEqpk45voOMeGQ"
				}
				
				local chooseSong17 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
					// 18) "Aah ko chahiye"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong18' == 1	{		
				di  		""
				di as txt  `"aah ko chāhiye"  "' 
				di as txt  `"ik umr asar hote tak"' 
				di as txt  `"kaun jiitā hai tirī zulf ke"' 
				di as txt  `"sar hote tak ""' 

				di as txt   " {bf: Written by Mirza Ghalib, sung by Begum Akhtar }"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=ih6BTkJ1Ujc":https://www.youtube.com/watch?v=ih6BTkJ1Ujc}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=ih6BTkJ1Ujc"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/4SiShhE6LiRweqU4OnY9jQ":https://open.spotify.com/track/4SiShhE6LiRweqU4OnY9jQ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/4SiShhE6LiRweqU4OnY9jQ"
				}
				
				local chooseSong18 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'	
		
		// 19) "Hum ko mita sake
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong19' == 1	{		
				di  		""
				di as txt  `""ham ko mitā sake"' 
				di as txt  `"ye zamāne meñ dam nahīñ"' 
				di as txt  `"ham se zamāna ḳhud hai"' 
				di as txt  `"zamāne se ham nahīñ ""' 

				di as txt   " {bf: Written by Jigar Moradabadi, sung by Begum Akhtar}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=GcKjArRuLJU&ab_channel=shaukeentabiyat":https://www.youtube.com/watch?v=GcKjArRuLJU&ab_channel=shaukeentabiyat}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=GcKjArRuLJU&ab_channel=shaukeentabiyat"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/12Xwo51Wen0jU8Z5Y5mHRa":https://open.spotify.com/track/12Xwo51Wen0jU8Z5Y5mHRa}
					if "`browse'" != "" view browse "https://open.spotify.com/track/12Xwo51Wen0jU8Z5Y5mHRa"
				}
				
				local chooseSong19 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
		// 20) "Chann Kithan"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong20' == 1	{		
				di  		""
				di as txt  `""Chann Kithan Guzaariya"' 
				di as txt  `"Ee Raat Ve"' 
				di as txt  `"Mendha Jee Daleela’n"' 
				di as txt  `"De Vaat Ve""' 

				di as txt   " {bf: Written by various Punjabi poets, cover by Ali Sethi }"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=mx1V0f9YLrE":https://www.youtube.com/watch?v=mx1V0f9YLrE}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=mx1V0f9YLrE"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/20mLcWdIpEZWVpzboSZJil":https://open.spotify.com/track/20mLcWdIpEZWVpzboSZJil}
					if "`browse'" != "" view browse "https://open.spotify.com/track/20mLcWdIpEZWVpzboSZJil"
				}
				
				local chooseSong20 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
	
			// 21) "Hazaron khwahishen aisi"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong21' == 1	{		
				di  		""
				di as txt  `""hazāroñ ḳhvāhisheñ aisī"' 
				di as txt  `"ki har ḳhvāhish pe dam nikle"' 
				di as txt  `"bahut nikle mire armān lekin"' 
				di as txt  `"phir bhī kam nikle ""' 

				di as txt   " {bf: Written by Mirza Ghalib, sung by Jagjit Singh }"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=8HZCGOQINh0":https://www.youtube.com/watch?v=8HZCGOQINh0}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=8HZCGOQINh0"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2Z1ipYzepcbBVUhq3DTW5L":https://open.spotify.com/track/2Z1ipYzepcbBVUhq3DTW5L}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2Z1ipYzepcbBVUhq3DTW5L"
				}
				
				local chooseSong21 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
	
	
	
	
			// 22) "Aap ki yaad aati rahi"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong22' == 1	{		
				di  		""
				di as txt  `""aap kī yaad aatī rahī raat bhar"' 
				di as txt  `"chāñdnī dil dukhātī rahī raat bhar"' 
				di as txt  `"gaah jaltī huī gaah bujhtī huī"' 
				di as txt  `"sham-e-ġham jhilmilātī rahī raat bhar""' 

				di as txt   " {bf: Written by Faiz, sung by Tina Sani}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=0GY-vlPjnHs":https://www.youtube.com/watch?v=0GY-vlPjnHs}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=0GY-vlPjnHs"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/70dJEYGVeZjaj9OlLEfpCS?si=vtXsVAPSSKiNXP2-1QhSsA":https://open.spotify.com/track/70dJEYGVeZjaj9OlLEfpCS?si=vtXsVAPSSKiNXP2-1QhSsA}
					if "`browse'" != "" view browse "https://open.spotify.com/track/70dJEYGVeZjaj9OlLEfpCS?si=vtXsVAPSSKiNXP2-1QhSsA"
				}
				
				local chooseSong22 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
					// 23) "Mujhse pehli si mohabbat"
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong23' == 1	{		
				di  		""
				di as txt  `""tū jo mil jaa.e to taqdīr nigūñ ho jaa.e "' 
				di as txt  `"yuuñ na thā maiñ ne faqat chāhā thā yuuñ ho jaa.e "' 
				di as txt  `"aur bhī dukh haiñ zamāne meñ mohabbat ke sivā "' 
				di as txt  `"rāhateñ aur bhī haiñ vasl kī rāhat ke sivā"' 
				di as txt  `"mujh se pahlī sī mohabbat mere mahbūb na maañg""' 

				di as txt   " {bf: Written by Faiz, sung by Noor Jehan }"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=2purc8WbAls":https://www.youtube.com/watch?v=2purc8WbAls}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=2purc8WbAls"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/39hCQjPyTtsHzsp0cx1fuJ":https://open.spotify.com/track/39hCQjPyTtsHzsp0cx1fuJ}
					if "`browse'" != "" view browse "https://open.spotify.com/track/39hCQjPyTtsHzsp0cx1fuJ"
				}
				
				local chooseSong23 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
	

	
	
					// 24) "Kab Thehray ga dard"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong24' == 1	{		
				di  		""
				di as txt  `""kab thahregā dard ai dil "' 
				di as txt  `"kab raat basar hogī"' 
				di as txt  `"sunte the vo ā.eñge"' 
				di as txt  `"sunte the sahar hogī""' 

				di as txt   " {bf: , sung by Iqbal Bano}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=j1Z_khWJD-A":https://www.youtube.com/watch?v=j1Z_khWJD-A}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=j1Z_khWJD-A"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/3V4yQsCVTO9TGSLOudZXCM":https://open.spotify.com/track/3V4yQsCVTO9TGSLOudZXCM}
					if "`browse'" != "" view browse "https://open.spotify.com/track/3V4yQsCVTO9TGSLOudZXCM"
				}
				
				local chooseSong24 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
	
		// 25) "Bol ke lub azad"
			
		if `randomSong' > `rangeMin' & `randomSong' <= `rangeMax' {
		if `chooseSong25' == 1	{		
				di  		""
				di as txt  `""bol ki lab āzād haiñ tere"' 
				di as txt  `"bol zabāñ ab tak terī hai"' 
				di as txt  `"terā sutvāñ jism hai terā"' 
				di as txt  `"bol ki jaañ ab tak terī hai""' 

				di as txt   " {bf: Written by Faiz, sung by Nayyara Noor}"
				
				if "`platform'" == "youtube" {
				
					di as text `"  {browse "https://www.youtube.com/watch?v=OchGMA7cOc8&ab_channel=EMIPakistan":https://www.youtube.com/watch?v=OchGMA7cOc8&ab_channel=EMIPakistan}
					if "`browse'" != "" view browse "https://www.youtube.com/watch?v=OchGMA7cOc8&ab_channel=EMIPakistan"
				}
				
				if "`platform'" == "spotify" {
					
					di as text 			`"  {browse "https://open.spotify.com/track/2HCiFKfWpHHg2FG5hrwnLw":https://open.spotify.com/track/2HCiFKfWpHHg2FG5hrwnLw}
					if "`browse'" != "" view browse "https://open.spotify.com/track/2HCiFKfWpHHg2FG5hrwnLw"
				}
				
				local chooseSong25 = 0
				local songCount   = 1 + `songCount'
			
		}
		}
		local rangeMin	= `rangeMin' + `interval'
		local rangeMax	= `rangeMax' + `interval'
		
}
	
// End





end

