cap prog drop heart

prog def heart
syntax	,									/// No variable required
												///
	   [LIne]									/// Displays line of heart
	   [SCAtter]								/// Displays scatter plot of hearts
	   [PIe]									/// Displays pie chart of heart
	   [FLIrt]									/// Displays pick up line

// Set minimum version for this command
	version 10
	
	if "`line'" !=""{
	
		di "♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥"
	}

		
	if "`scatter'" != "" {
	tempvar var1 var2 var3 var4
	
	quietly {
	
		describe
		
		if r(N)<950 {
			preserve
			set obs 950
		}

		generate `var1' = runiform()
		generate `var2' = runiform()

		egen `var3' = seq(), f(0) t(1)
		
		gen `var4' = "♥" if `var3' == 0
		replace `var4' = "♡" if `var3' == 1
		twoway ///
		(scatter `var1' `var2', msymbol(none) mlabel(`var4') xtitle("") ytitle("") title("Love is in the air!"))

		}
		}

		
	if "`pie'" != "" {
	tempvar var5 
	
	quietly {
		
		describe
		
		if r(N)<1 {
			preserve
			set obs 1
		}
		
		generate `var5' = 1
		label variable `var5' "Extremely"
		graph pie `var5', pie(1, color(lavender)) title("How cute is the person reading this?") note("Source: Survey across everyone in the universe") legend(on)

		}
		}
		
	if "`flirt'" != "" {
	
		local w1 "Are you gold? Because I'm in Au of your beauty."
		local w2 "Are you made of copper and tellurium? Because you're CuTe."
		local w3 "You're like a dictionary, you add meaning to my life"
		local w4 "You look familiar, didn’t we take a class together? I could’ve sworn we had chemistry."
		local w5 "Your hand looks heavy, can I hold it for you?"
		local w6 "Do you have a band aid? Cause I scraped my knees falling for you."
		local w7 "Forget hydrogen, you’re my number one element."
		local w8 "Are you a keyboard? Because you’re just my type."
		local w9 "Are you a time traveler? Cause I see you in my future!"
		local w10 "Do you know if there are any police around? Cause I’m about to steal your heart."
		local w11 "If I were a cat I'd spend all 9 lives with you."
		local w12 "Are you australian? Because you meet all of my koalafications."
		local w13 "Do you play soccer? Because you’re a keeper!"
		local w14 "Wanna grab a coffee because I like you a latte!"
		local w15 "Are you a doughnut? Cause I find you a-dough-rable!"
		local w16 "You’re the macaroni to my cheese"
		local w17 "This may be cheesy, but I think you’re grate"
		local w18 "Life without you is like a broken pencil... pointless."
		local w19 "Are you my appendix? Because I don't understand how you work but this feeling in my stomach makes me want to take you out."
		local w20 "Is your name Wi-fi? Because I'm really feeling a connection."
		local w21 "You must be a ninja, because you snuck into my heart"
		local w22 "I’m not a photographer, but I can picture me and you together."
		local w23 "Are you less than 30 degree? Because you are aCUTE angle "
		local w24 "Did the sun come out or did you just smile at me?"
		local w25 "Isn't your e-mail address beautifulhuman@mydreams.com?"
		local w26 "If you were a vegetable, you would be a cutecumber!"
		local w27 "Is this the Hogwarts Express? Because it feels like you and I are headed somewhere magical."
		local w28 "Do you like Star Wars? Because Yoda only one for me!"
		local w29 "Did you invent the airplane? Because you seem Wright for me."
		local w30 "Do you know CPR? Because you are taking my breath away!"
		local w31 "We’re not socks, but I think we’d make a great pair."
		local w32 "You must be tired because you've been running through my mind all night."
		local w33 "Do you have a map? I keep getting lost in your eyes."
		local w34 "Are you an electrician? Because you’re definitely lighting up my day!"
		local w35 "Can I call-cu-later?"
		local w36 "My love for you is like dividing by zero… It can't be defined!"
		local w37 "Without you, I'm like a null set…Empty"
		local w38 "Are you the square root of -1? 'Cause you can't be real!"
		local w39 "You're sweet as Π!"
		local w40 "If you were a function, then you'd be my asymptote…'Cause I always tend toward you!"
		local w41 "Are you a 45º angle? Cause you're acute-y!"
		local w42 "My admiration for you is like √(-1)…Complex, but not imaginary!"
		local w43 "We fit together like coordinates on an axis."
		local w44 "Without you I am just a semi-circle; you complete me."
		local w45 "You are like the back of a math book, because you are the answer to all of my problems."
		local w46 "You must be p > 0.5, because I fail to reject you."
		local w47 " I have a math equation for you: you plus me equals awesome."
		local w48 "Being myself around you is as easy as pi."
		local w49 "If you were a triangle, you would be such acute one."
		local w50 "You and I must be inverse logical functions because I could compliment you all day."
		local w51 "I am binary and I think that you are the 1 for me."
		local w52 "If the universe wanted me to assign you a number, you would be my number 1."
		local w53 "If 4 plus 4 equals 8, then you plus me equals fate."
		local w54 "Are you Siri? Because you autocomplete me!"
		local w55 "Do you like cheese? Because you're looking Gouda today!"
		local w56 "I want our love to be like the number Pi: irrational and never-ending."
		local w57 "Are you a florist? Cause ever since I met you, my life has been Rosey."
		local w58 "Is there an airport nearby or is that just my heart taking off?"
		local w59 "If I’m vinegar, then you must be baking soda. Because you make me feel all bubbly inside!"
		local w60 "Excuse me, I think you have something in your eye. Oh wait, it's just a sparkle."
		local w61 "I know we're not in Professor Flitwick's class, but you still are charming."
		local w62 "Being without you is like being afflicted with the Cruciatus Curse."
		local w63 "Your smile is like Expelliarmus. Disarming!"
		local w64 "Without you, I'm like a null set…Empty"
		local w65 "Is this the Hogwarts Express? Because it feels like you and I are headed somewhere magical."
		local w66 "Are you australian? Because you meet all of my koalafications."
		local w67 "Can I call-cu-later?"
		local w68 "This may be cheesy, but I think you’re grate"
		local w69 "If I were a cat I'd spend all 9 lives with you."
		local w70 "If you were a vegetable, you would be a cutecumber!"
		local w71 "You are like the back of a math book, because you are the answer to all of my problems."
		local w72 "Are you a keyboard? Because you’re just my type."
		local w73 "You and I must be inverse logical functions because I could compliment you all day."
		local w74 "If you were a function, then you'd be my asymptote…'Cause I always tend toward you!"
		local w75 "Do you know CPR? Because you are taking my breath away!"
		local w76 "Do you like Star Wars? Because Yoda only one for me!"
		local w77 "Are you a doughnut? Cause I find you a-dough-rable!"
		local w78 "You must be p > 0.5, because I fail to reject you."
		local w79 "Your smile is like Expelliarmus. Disarming!"
		local w80 "Your hand looks heavy, can I hold it for you?"
		local w81 "You’re the macaroni to my cheese"
		local w82 "I want our love to be like the number Pi: irrational and never-ending."
		local w83 "You must be a ninja, because you snuck into my heart"
		local w84 "Do you know if there are any police around? Cause I’m about to steal your heart."
		local w85 "Do you like cheese? Because you're looking Gouda today!"
		local w86 "Are you less than 30 degree? Because you are aCUTE angle "
		local w87 "Are you the square root of -1? 'Cause you can't be real!"
		local w88 "I’m not a photographer, but I can picture me and you together."
		local w89 "I know we're not in Professor Flitwick's class, but you still are charming."
		local w90 "If I’m vinegar, then you must be baking soda. Because you make me feel all bubbly inside!"
		local w91 "Is there an airport nearby or is that just my heart taking off?"
		local w92 "If the universe wanted me to assign you a number, you would be my number 1."
		local w93 "Are you an electrician? Because you’re definitely lighting up my day!"
		local w94 "Did you invent the airplane? Because you seem Wright for me."
		local w95 "Life without you is like a broken pencil... pointless."
		local w96 "Do you have a map? I keep getting lost in your eyes."
		local w97 "Do you have a band aid? Cause I scraped my knees falling for you."
		local w98 "Being without you is like being afflicted with the Cruciatus Curse."
		local w99 "Excuse me, I think you have something in your eye. Oh wait, it's just a sparkle."
		local w100 "Is your name Wi-fi? Because I'm really feeling a connection."
		local w101 "You're like a dictionary, you add meaning to my life"
		local w102 "Without you I am just a semi-circle; you complete me."
		local w103 " I have a math equation for you: you plus me equals awesome."
		local w104 "Are you a 45º angle? Cause you're acute-y!"
		local w105 "Are you made of copper and tellurium? Because you're CuTe."
		local w106 "We fit together like coordinates on an axis."
		local w107 "My love for you is like dividing by zero… It can't be defined!"
		local w108 "If you were a triangle, you would be such acute one."
		local w109 "I am binary and I think that you are the 1 for me."
		local w110 "You look familiar, didn’t we take a class together? I could’ve sworn we had chemistry."
		local w111 "Isn't your e-mail address beautifulhuman@mydreams.com?"
		local w112 "Did the sun come out or did you just smile at me?"
		local w113 "Being myself around you is as easy as pi."
		local w114 "Are you gold? Because I'm in Au of your beauty."
		local w115 "Wanna grab a coffee because I like you a latte!"
		local w116 "Forget hydrogen, you’re my number one element."
		local w117 "If 4 plus 4 equals 8, then you plus me equals fate."
		local w118 "Are you a time traveler? Cause I see you in my future!"
		local w119 "You must be tired because you've been running through my mind all night."
		local w120 "Are you my appendix? Because I don't understand how you work but this feeling in my stomach makes me want to take you out."
		local w121 "My admiration for you is like √(-1)…Complex, but not imaginary!"
		local w122 "We’re not socks, but I think we’d make a great pair."
		local w123 "Are you Siri? Because you autocomplete me!"
		local w124 "Do you play soccer? Because you’re a keeper!"
		local w125 "You're sweet as Π!"
		local w126 "Are you a florist? Cause ever since I met you, my life has been Rosey."
		local w127 "If the universe wanted me to assign you a number, you would be my number 1."
		local w128 "Your smile is like Expelliarmus. Disarming!"
		local w129 "You're like a dictionary, you add meaning to my life"
		local w130 "You are like the back of a math book, because you are the answer to all of my problems."
		local w131 "This may be cheesy, but I think you’re grate"
		local w132 "You look familiar, didn’t we take a class together? I could’ve sworn we had chemistry."
		local w133 "Excuse me, I think you have something in your eye. Oh wait, it's just a sparkle."
		local w134 "Forget hydrogen, you’re my number one element."
		local w135 "Do you have a map? I keep getting lost in your eyes."
		local w136 "I want our love to be like the number Pi: irrational and never-ending."
		local w137 "My admiration for you is like √(-1)…Complex, but not imaginary!"
		local w138 "Is this the Hogwarts Express? Because it feels like you and I are headed somewhere magical."
		local w139 "Are you Siri? Because you autocomplete me!"
		local w140 "Are you the square root of -1? 'Cause you can't be real!"
		local w141 "Is your name Wi-fi? Because I'm really feeling a connection."
		local w142 "If you were a vegetable, you would be a cutecumber!"
		local w143 "If you were a function, then you'd be my asymptote…'Cause I always tend toward you!"
		local w144 "Your hand looks heavy, can I hold it for you?"
		local w145 "Do you know if there are any police around? Cause I’m about to steal your heart."
		local w146 "Wanna grab a coffee because I like you a latte!"
		local w147 "If I’m vinegar, then you must be baking soda. Because you make me feel all bubbly inside!"
		local w148 "If you were a triangle, you would be such acute one."
		local w149 "Do you have a band aid? Cause I scraped my knees falling for you."
		local w150 "Do you play soccer? Because you’re a keeper!"
		local w151 "Are you made of copper and tellurium? Because you're CuTe."
		local w152 "Are you a keyboard? Because you’re just my type."
		local w153 "You and I must be inverse logical functions because I could compliment you all day."
		local w154 "Are you a doughnut? Cause I find you a-dough-rable!"
		local w155 "My love for you is like dividing by zero… It can't be defined!"
		local w156 "Did you invent the airplane? Because you seem Wright for me."
		local w157 "I know we're not in Professor Flitwick's class, but you still are charming."
		local w158 "You must be a ninja, because you snuck into my heart"
		local w159 "Is there an airport nearby or is that just my heart taking off?"
		local w160 "We’re not socks, but I think we’d make a great pair."
		local w161 "Are you less than 30 degree? Because you are aCUTE angle "
		local w162 "Are you australian? Because you meet all of my koalafications."
		local w163 "You’re the macaroni to my cheese"
		local w164 "Are you a time traveler? Cause I see you in my future!"
		local w165 "Being myself around you is as easy as pi."
		local w166 "Are you a florist? Cause ever since I met you, my life has been Rosey."
		local w167 "Did the sun come out or did you just smile at me?"
		local w168 "If 4 plus 4 equals 8, then you plus me equals fate."
		local w169 "We fit together like coordinates on an axis."
		local w170 " I have a math equation for you: you plus me equals awesome."
		local w171 "Being without you is like being afflicted with the Cruciatus Curse."
		local w172 "Are you my appendix? Because I don't understand how you work but this feeling in my stomach makes me want to take you out."
		local w173 "I am binary and I think that you are the 1 for me."
		local w174 "Without you I am just a semi-circle; you complete me."
		local w175 "You must be p > 0.5, because I fail to reject you."
		local w176 "Without you, I'm like a null set…Empty"
		local w177 "Life without you is like a broken pencil... pointless."
		local w178 "If I were a cat I'd spend all 9 lives with you."
		local w179 "Do you like cheese? Because you're looking Gouda today!"
		local w180 "Do you know CPR? Because you are taking my breath away!"
		local w181 "Are you an electrician? Because you’re definitely lighting up my day!"
		local w182 "Do you like Star Wars? Because Yoda only one for me!"
		local w183 "Isn't your e-mail address beautifulhuman@mydreams.com?"
		local w184 "Can I call-cu-later?"
		local w185 "I’m not a photographer, but I can picture me and you together."
		local w186 "You're sweet as Π!"
		local w187 "You must be tired because you've been running through my mind all night."
		local w188 "Are you a 45º angle? Cause you're acute-y!"
		local w189 "Are you gold? Because I'm in Au of your beauty."
		local w190 "Are you a 45º angle? Cause you're acute-y!"
		local w191 "Are you australian? Because you meet all of my koalafications."
		local w192 "Life without you is like a broken pencil... pointless."
		local w193 "Is this the Hogwarts Express? Because it feels like you and I are headed somewhere magical."
		local w194 "If you were a function, then you'd be my asymptote…'Cause I always tend toward you!"
		local w195 "Can I call-cu-later?"
		local w196 "I’m not a photographer, but I can picture me and you together."
		local w197 "Are you gold? Because I'm in Au of your beauty."
		local w198 "Do you have a map? I keep getting lost in your eyes."
		local w199 "Are you Siri? Because you autocomplete me!"
		local w200 "Did the sun come out or did you just smile at me?"
		local w201 "Are you a keyboard? Because you’re just my type."
		local w202 "If I were a cat I'd spend all 9 lives with you."
		local w203 "This may be cheesy, but I think you’re grate"
		local w204 "You and I must be inverse logical functions because I could compliment you all day."
		local w205 "Is there an airport nearby or is that just my heart taking off?"
		local w206 "You're like a dictionary, you add meaning to my life"
		local w207 "Wanna grab a coffee because I like you a latte!"
		local w208 "Without you, I'm like a null set…Empty"
		local w209 " I have a math equation for you: you plus me equals awesome."
		local w210 "If the universe wanted me to assign you a number, you would be my number 1."
		local w211 "You're sweet as Π!"
		local w212 "Being myself around you is as easy as pi."
		local w213 "Are you less than 30 degree? Because you are aCUTE angle "
		local w214 "I know we're not in Professor Flitwick's class, but you still are charming."
		local w215 "Do you like Star Wars? Because Yoda only one for me!"
		local w216 "Do you play soccer? Because you’re a keeper!"
		local w217 "Are you a time traveler? Cause I see you in my future!"
		local w218 "Without you I am just a semi-circle; you complete me."
		local w219 "If I’m vinegar, then you must be baking soda. Because you make me feel all bubbly inside!"
		local w220 "We fit together like coordinates on an axis."
		local w221 "We’re not socks, but I think we’d make a great pair."
		local w222 "If you were a vegetable, you would be a cutecumber!"
		local w223 "You look familiar, didn’t we take a class together? I could’ve sworn we had chemistry."
		local w224 "Are you made of copper and tellurium? Because you're CuTe."
		local w225 "Isn't your e-mail address beautifulhuman@mydreams.com?"
		local w226 "You must be p > 0.5, because I fail to reject you."
		local w227 "You are like the back of a math book, because you are the answer to all of my problems."
		local w228 "Do you like cheese? Because you're looking Gouda today!"
		local w229 "Do you know CPR? Because you are taking my breath away!"
		local w230 "Are you my appendix? Because I don't understand how you work but this feeling in my stomach makes me want to take you out."
		local w231 "I want our love to be like the number Pi: irrational and never-ending."
		local w232 "You must be a ninja, because you snuck into my heart"
		local w233 "Did you invent the airplane? Because you seem Wright for me."
		local w234 "Is your name Wi-fi? Because I'm really feeling a connection."
		local w235 "Your hand looks heavy, can I hold it for you?"
		local w236 "If 4 plus 4 equals 8, then you plus me equals fate."
		local w237 "Being without you is like being afflicted with the Cruciatus Curse."
		local w238 "Are you the square root of -1? 'Cause you can't be real!"
		local w239 "If you were a triangle, you would be such acute one."
		local w240 "I am binary and I think that you are the 1 for me."
		local w241 "You’re the macaroni to my cheese"
		local w242 "Your smile is like Expelliarmus. Disarming!"
		local w243 "Are you a florist? Cause ever since I met you, my life has been Rosey."
		local w244 "You must be tired because you've been running through my mind all night."
		local w245 "Are you an electrician? Because you’re definitely lighting up my day!"
		local w246 "Excuse me, I think you have something in your eye. Oh wait, it's just a sparkle."
		local w247 "Are you a doughnut? Cause I find you a-dough-rable!"
		local w248 "Forget hydrogen, you’re my number one element."
		local w249 "My love for you is like dividing by zero… It can't be defined!"
		local w250 "Do you know if there are any police around? Cause I’m about to steal your heart."
		local w251 "Do you have a band aid? Cause I scraped my knees falling for you."
		local w252 "My admiration for you is like √(-1)…Complex, but not imaginary!"

	
	loc n = int((252)*runiform())
	noi di "`w`n''"
	}
		
//If all options missing display line 

	if "`line'" == "" & "`scatter'" == "" & "`pie'" == "" & "`flirt'" == ""{
		di "♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥♥"
	}
		end
		

		
