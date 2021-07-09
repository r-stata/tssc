*! version 1.3.1 Joe Long 06nov2013
cap program drop nicewords
program nicewords, rclass
	version 12.0
	syntax, [NOT Foreign SMILEy EVIL]
	if "`evil'" != "" & ("`not'" == "" | "`smiley'" == "") {
		di as err "evil does not work without the -not- and -smiley- option"
		exit 666
	}
	if "`foreign'" != ""{
		if "`not'" == ""{
			loc	w0	Bien
			loc	w1	Bueno
			loc	w2	Que bueno
			loc	w3	Muy bien
			loc	w4	Excelente
			loc	w5	Bien hecho
			loc	w6	Usted es mi heroe
			loc	w7	Increible
			loc	w8	Incroyable
			loc	w9	Vous etes mon heros
			loc	w10	Bien
			loc	w11	Bon
			loc	w12	Tres bien
			loc	w13	Excellent
			loc	w14	Bien fait
			loc	w15	Gut
			loc	w16	Sehr gut
			loc	w17	Gut gemacht
			loc	w18	Buono
			loc	w19	Bene
			loc	w20	Ben fatto
			loc	w21	Molto buono
			loc	w22	Bom
			loc	w23	Muito bom
			loc	w24	Bem feito
			loc	w25	Yoku dekimashita
			loc	w26	Ii desu yo
			loc	w27	Dare yori mo ii desu yo
			loc	w28	Sugoi desu yo
			loc	w29	Sugeeeee
			loc	w30	Hoc bonum est
			loc	w31	Feichang hao
			loc	w32	Zuo de hao
			loc	w33	Ting hao
			loc	w34	Hen hao
			loc	w35	Hao youxiu
			loc	w36	Zhen liaobuqi
			loc	w37	Hao liaobuqi
			loc	w38	Mirabile visu
			loc	w39	Chaoji hao
			loc	w40	Spectaculaire
			loc	w41	Impressionant
			loc	w42	Genial
			loc	w43	Vous etes mon inspiration
			loc	w44	Bien
			loc	w45	Bueno
			loc	w46	Que bueno
			loc	w47	Muy bien
			loc	w48	Excelente
			loc	w49	Bien hecho
			loc	w50	Usted es mi heroe
			loc	w51	Increible
			loc	w52	Incroyable
			loc	w53	Vous etes mon heros
			loc	w54	Bien
			loc	w55	Bon
			loc	w56	Tres bien
			loc	w57	Excellent
			loc	w58	Bien fait
			loc	w59	Gut
			loc	w60	Sehr gut
			loc	w61	Gut gemacht
			loc	w62	Buono
			loc	w63	Bene
			loc	w64	Ben fatto
			loc	w65	Molto buono
			loc	w66	Yoku dekimashita
			loc	w67	Ii desu yo
			loc	w68	Dare yori mo ii desu yo
			loc	w69	Sugoi desu yo
			loc	w70	Sugeeeee
			loc	w71	Hoc bonum est
			loc	w72	Feichang hao
			loc	w73	Zuo de hao
			loc	w74	Ting hao
			loc	w75	Hen hao
			loc	w76	Hao youxiu
			loc	w77	Zhen liaobuqi
			loc	w78	Hao liaobuqi
			loc	w79	Ni zhen shi yige yingxiong
			loc	w80	Chaoji hao
			loc	w81	Spectaculaire
			loc	w82	Impressionant
			loc	w83	Genial
			loc	w84	Vous etes mon inspiration
			loc	w85	Bien
			loc	w86	Bueno
			loc	w87	Que bueno
			loc	w88	Muy bien
			loc	w89	Excelente
			loc	w90	Bien hecho
			loc	w91	Usted es mi heroe
			loc	w92	Increible
			loc	w93	Incroyable
			loc	w94	Vous etes mon heros
			loc	w95	Bien
			loc	w96	Bon
			loc	w97	Tres bien
			loc	w98	Excellent
			loc	w99	Bien fait
			loc	w100	Gut
			loc	w101	Sehr gut
			loc	w102	Gut gemacht
			loc	w103	Buono
			loc	w104	Bene
			loc	w105	Ben fatto
			loc	w106	Molto buono
			loc	w107	Mihi vere placet
			loc	w108	Mihi vere placet
			loc	w109	Mihi vere placet
			loc	w110	Yoku dekimashita
			loc	w111	Ii desu yo
			loc	w112	Dare yori mo ii desu yo
			loc	w113	Sugoi desu yo
			loc	w114	Sugeeeee
			loc	w115	Mihi vere placet
			loc	w116	Feichang hao
			loc	w117	Zuo de hao
			loc	w118	Ting hao
			loc	w119	Hen hao
			loc	w120	Hao youxiu
			loc	w121	Zhen liaobuqi
			loc	w122	Hao liaobuqi
			loc	w123	Ni zhen shi yige yingxiong
			loc	w124	Chaoji hao
			loc	w125	Spectaculaire
			loc	w126	Impressionant
			loc	w127	Genial
			loc	w128	Vous etes mon inspiration
			loc	w129	Bien
			loc	w130	Bueno
			loc	w131	Que bueno
			loc	w132	Muy bien
			loc	w133	Excelente
			loc	w134	Bien hecho
			loc	w135	Usted es mi heroe
			loc	w136	Increible
			loc	w137	Incroyable
			loc	w138	Vous etes mon heros
			loc	w139	Bien
			loc	w140	Bon
			loc	w141	Tres bien
			loc	w142	Excellent
			loc	w143	Bien fait
			loc	w144	Gut
			loc	w145	Sehr gut
			loc	w146	Gut gemacht
			loc	w147	Buono
			loc	w148	Bene
			loc	w149	Ben fatto
			loc	w150	Molto buono
			loc	w151	Yoku dekimashita
			loc	w152	Ii desu yo
			loc	w153	Dare yori mo ii desu yo
			loc	w154	Sugoi desu yo
			loc	w155	Sugeeeee
			loc	w156	Hoc bonum est
			loc	w157	Feichang hao
			loc	w158	Zuo de hao
			loc	w159	Ting hao
			loc	w160	Hen hao
			loc	w161	Hao youxiu
			loc	w162	Zhen liaobuqi
			loc	w163	Hao liaobuqi
			loc	w164	Ni zhen shi yige yingxiong
			loc	w165	Chaoji hao
			loc	w166	Spectaculaire
			loc	w167	Impressionant
			loc	w168	Genial
			loc	w169	Vous etes mon inspiration
			loc	w170	Bien
			loc	w171	Bueno
			loc	w172	Que bueno
			loc	w173	Muy bien
			loc	w174	Excelente
			loc	w175	Bien hecho
			loc	w176	Usted es mi heroe
			loc	w177	Increible
			loc	w178	Incroyable
			loc	w179	Vous etes mon heros
			loc	w180	Bien
			loc	w181	Bon
			loc	w182	Tres bien
			loc	w183	Excellent
			loc	w184	Bien fait
			loc	w185	Gut
			loc	w186	Sehr gut
			loc	w187	Gut gemacht
			loc	w188	Buono
			loc	w189	Bene
			loc	w190	Ben fatto
			loc	w191	Molto buono
			loc	w192	Hoc bonum est
			loc	w193	Hoc bonum est
			loc	w194	Hoc bonum est
			loc	w195	Yoku dekimashita
			loc	w196	Ii desu yo
			loc	w197	Dare yori mo ii desu yo
			loc	w198	Sugoi desu yo
			loc	w199	Sugeeeee
			loc	w200	Hoc bonum est
			loc	w201	Feichang hao
			loc	w202	Zuo de hao
			loc	w203	Ting hao
			loc	w204	Hen hao
			loc	w205	Hao youxiu
			loc	w206	Zhen liaobuqi
			loc	w207	Hao liaobuqi
			loc	w208	Ni zhen shi yige yingxiong
			loc	w209	Chaoji hao
			loc	w210	Hao weida
		}
		else {
			forvalues n = 0/210{
				loc w`n' No bueno
			}
		}
	}
	else {
		if "`not'" == ""{
			loc	w0	"A+ work"
			loc	w1	"Absolutely amazing"
			loc	w2	"Absolutely awesome"
			loc	w3	"Absolutely beautiful"
			loc	w4	"Absolutely brilliant"
			loc	w5	"Absolutely excellent"
			loc	w6	"Absolutely fabulous"
			loc	w7	"Absolutely genius"
			loc	w8	"Absolutely great"
			loc	w9	"Absolutely incredible"
			loc	w10	"Absolutely magnificent"
			loc	w11	"Absolutely marvelous"
			loc	w12	"Absolutely masterful"
			loc	w13	"Absolutely outstanding"
			loc	w14	"Absolutely phenomenal"
			loc	w15	"Absolutely remarkable"
			loc	w16	"Absolutely stupendous"
			loc	w17	"Absolutely superb"
			loc	w18	"Absolutely terrific"
			loc	w19	"Absolutely unbelievable"
			loc	w20	"Absolutely wonderful"
			loc	w21	"Brilliantly handled"
			loc	w22	"Excellent work"
			loc	w23	"Good job"
			loc	w24	"Good work"
			loc	w25	"Great job"
			loc	w26	"Hats off to you"
			loc	w27	"High five"
			loc	w28	"I expected no less of a genius"
			loc	w29	"I like"
			loc	w30	"It's a masterpiece"
			loc	w31	"Just amazing"
			loc	w32	"Just amazing"
			loc	w33	"Just awesome"
			loc	w34	"Just beautiful"
			loc	w35	"Just brilliant"
			loc	w36	"Just excellent"
			loc	w37	"Just fabulous"
			loc	w38	"Just genius"
			loc	w39	"Just great"
			loc	w40	"Just incredible"
			loc	w41	"Just incredible"
			loc	w42	"Just magnificent"
			loc	w43	"Just marvelous"
			loc	w44	"Just masterful"
			loc	w45	"Just outstanding"
			loc	w46	"Just phenomenal"
			loc	w47	"Just remarkable"
			loc	w48	"Just stupendous"
			loc	w49	"Just superb"
			loc	w50	"Just terrific"
			loc	w51	"Just unbelievable"
			loc	w52	"Just wonderful"
			loc	w53	"Me likey"
			loc	w54	"Nice job"
			loc	w55	"Nice work"
			loc	w56	"Take a bow"
			loc	w57	"Take a bow"
			loc	w58	"Top notch"
			loc	w59	"Truly exceptional"
			loc	w60	"Way to go"
			loc	w61	"Way to use your head"
			loc	w62	"Well done"
			loc	w63	"You are amazing"
			loc	w64	"You are great"
			loc	w65	"So sick bro"
			loc	w66	"You should be proud"
			loc	w67	"You're a natural"
			loc	w68	"You're a star"
			loc	w69	"You're amazing"
			loc	w70	"You're awesome"
			loc	w71	"You're incredible"
			loc	w72	"You're number one"
			loc	w73	Amazing
			loc	w74	Awesome
			loc	w75	Beautiful
			loc	w76	Bravo
			loc	w77	Brilliant
			loc	w78	Cool
			loc	w79	Creative
			loc	w80	Excellent
			loc	w81	Fabulous
			loc	w82	Genius
			loc	w83	Gnarly
			loc	w84	Good
			loc	w85	Great
			loc	w86	Groovy
			loc	w87	Incredible
			loc	w88	Inspired
			loc	w89	Magnificent
			loc	w90	Marvelous
			loc	w91	Masterful
			loc	w92	Neato
			loc	w93	Nice
			loc	w94	Outstanding
			loc	w95	Phenomenal
			loc	w96	Rad
			loc	w97	Remarkable
			loc	w98	Siiiick
			loc	w99	Stupendous
			loc	w100	Super
			loc	w101	Superb
			loc	w102	Sweet
			loc	w103	Terrific
			loc	w104	Tight
			loc	w105	Unbelievable
			loc	w106	Wonderful
			loc	w107	"A+ work"
			loc	w108	"Absolutely amazing"
			loc	w109	"Absolutely awesome"
			loc	w110	"Absolutely beautiful"
			loc	w111	"Absolutely brilliant"
			loc	w112	"Absolutely excellent"
			loc	w113	"Absolutely fabulous"
			loc	w114	"Absolutely genius"
			loc	w115	"Absolutely great"
			loc	w116	"Absolutely incredible"
			loc	w117	"Absolutely magnificent"
			loc	w118	"Absolutely marvelous"
			loc	w119	"Absolutely masterful"
			loc	w120	"Absolutely outstanding"
			loc	w121	"Absolutely phenomenal"
			loc	w122	"Absolutely remarkable"
			loc	w123	"Absolutely stupendous"
			loc	w124	"Absolutely superb"
			loc	w125	"Absolutely terrific"
			loc	w126	"Absolutely unbelievable"
			loc	w127	"Absolutely wonderful"
			loc	w128	"Brilliantly handled"
			loc	w129	"Excellent work"
			loc	w130	"Good job"
			loc	w131	"Good work"
			loc	w132	"Great job"
			loc	w133	"Hats off to you"
			loc	w134	"High five"
			loc	w135	"I expected no less of a genius"
			loc	w136	"Thumbs up"
			loc	w137	"It's a masterpiece"
			loc	w138	"Just amazing"
			loc	w139	"Just amazing"
			loc	w140	"Just awesome"
			loc	w141	"Just beautiful"
			loc	w142	"Just brilliant"
			loc	w143	"Just excellent"
			loc	w144	"Just fabulous"
			loc	w145	"Just genius"
			loc	w146	"Just great"
			loc	w147	"Just incredible"
			loc	w148	"Just incredible"
			loc	w149	"Just magnificent"
			loc	w150	"Just marvelous"
			loc	w151	"Just masterful"
			loc	w152	"Just outstanding"
			loc	w153	"Just phenomenal"
			loc	w154	"Just remarkable"
			loc	w155	"Just stupendous"
			loc	w156	"Just superb"
			loc	w157	"Just terrific"
			loc	w158	"Just unbelievable"
			loc	w159	"Just wonderful"
			loc	w160	"Like a modern-day Joan of Arc"
			loc	w161	"Nice job"
			loc	w162	"Nice work"
			loc	w163	"Take a bow"
			loc	w164	"Top notch"
			loc	w165	"Truly exceptional"
			loc	w166	"Way to go"
			loc	w167	"Way to use your head"
			loc	w168	"Well done"
			loc	w169	"You are amazing"
			loc	w170	"You are great"
			loc	w171	"You should be proud"
			loc	w172	"You're a natural"
			loc	w173	"You're a star"
			loc	w174	"You're amazing"
			loc	w175	"You're awesome"
			loc	w176	"You're incredible"
			loc	w177	"You're number one"
			loc	w178	Amazing
			loc	w179	Awesome
			loc	w180	Beautiful
			loc	w181	Bravo
			loc	w182	Brilliant
			loc	w183	Cool
			loc	w184	"You've got a gift for this"
			loc	w185	Excellent
			loc	w186	Fabulous
			loc	w187	Genius
			loc	w188	"The hero of our generation"
			loc	w189	Good
			loc	w190	Great
			loc	w191	Incredible
			loc	w192	Inspired
			loc	w193	Magnificent
			loc	w194	Marvelous
			loc	w195	Masterful
			loc	w196	"An inspiration to us all"
			loc	w197	Nice
			loc	w198	Outstanding
			loc	w199	Phenomenal
			loc	w200	"Proud of you"
			loc	w201	Remarkable
			loc	w202	Stupendous
			loc	w203	Super
			loc	w204	Superb
			loc	w205	Sweet
			loc	w206	Terrific
			loc	w207	"You've done it again"
			loc	w208	Unbelievable
			loc	w209	Wonderful
			loc	w210	"How do you do it?"
		}
		else{
			loc	w0	Terrible
			loc	w1	Awful
			loc	w2	Useless
			loc	w3	Lowly
			loc	w4	Bad
			loc	w5	The worst
			loc	w6	Scum
			loc	w7	Disgusting
			loc	w8	Fail
			loc	w9	Disastrous
			loc	w10	Horrendous
			loc	w11	How poor
			loc	w12	How inferior
			loc	w13	Unsatisfactory
			loc	w14	Inadequate
			loc	w15	Unacceptable
			loc	w16	Deficient
			loc	w17	Faulty
			loc	w18	Shoddy
			loc	w19	Substandard
			loc	w20	Worthless
			loc	w21	What junk
			loc	w22	How could you
			loc	w23	Unthinkable
			loc	w24	Try to not do so terribly next time
			loc	w25	And I trusted you
			loc	w26	Despicable
			loc	w27	Scum of the earth
			loc	w28	Unforgivable
			loc	w29	I don't think you deserve to have STATA installed on your computer
			loc	w30	You deserve an error code of your own
			loc	w31	Just awful
			loc	w32	Simply terrible
			loc	w33	Simply awful
			loc	w34	Simply useless
			loc	w35	Absolutely terrible
			loc	w36	Absolutely awful
			loc	w37	Absolutely useless
			loc	w38	Just disgusting
			loc	w39	Just disastrous
			loc	w40	Just horrendous
			loc	w41	What were you thinking
			loc	w42	Just no
			loc	w43	Simply disgusting
			loc	w44	So much fail
			loc	w45	Just unacceptable
			loc	w46	Absolutely the worst
			loc	w47	Absolute scum
			loc	w48	Simply disastrous
			loc	w49	Simply horrendous
			loc	w50	How worthless
			loc	w51	Just unthinkable
			loc	w52	An absolute fail
			loc	w53	Absolutely disastrous
			loc	w54	Absolutely horrendous
			loc	w55	Just unforgivable
			loc	w56	Just despicable
			loc	w57	Simply despicable
			loc	w58	Simply unforgivable
			loc	w59	Absolutely despicable
			loc	w60	Absolutely unforgivable
			loc	w61	Simply unsatisfactory
			loc	w62	Simply inadequate
			loc	w63	Simply unacceptable
			loc	w64	Simply worthless
			loc	w65	Absolutely unsatisfactory
			loc	w66	Absolutely inadequate
			loc	w67	Absolutely unacceptable
			loc	w68	Absolutely worthless
			loc	w69	Terrible
			loc	w70	Awful
			loc	w71	Useless
			loc	w72	Lowly
			loc	w73	Bad
			loc	w74	The worst
			loc	w75	Scum
			loc	w76	Disgusting
			loc	w77	Fail
			loc	w78	Disastrous
			loc	w79	Horrendous
			loc	w80	How poor
			loc	w81	How inferior
			loc	w82	Unsatisfactory
			loc	w83	Inadequate
			loc	w84	Unacceptable
			loc	w85	Deficient
			loc	w86	Faulty
			loc	w87	Shoddy
			loc	w88	Substandard
			loc	w89	Worthless
			loc	w90	What junk
			loc	w91	How could you
			loc	w92	Unthinkable
			loc	w93	Try to not do so badly next time
			loc	w94	And I trusted you
			loc	w95	Despicable
			loc	w96	Scum of the earth
			loc	w97	Unforgivable
			loc	w98	Just terrible
			loc	w99	Just awful
			loc	w100	Simply terrible
			loc	w101	Simply awful
			loc	w102	Simply useless
			loc	w103	Absolutely terrible
			loc	w104	Absolutely awful
			loc	w105	Absolutely useless
			loc	w106	Just disgusting
			loc	w107	Just disastrous
			loc	w108	Just horrendous
			loc	w109	What were you thinking
			loc	w110	Just no
			loc	w111	Simply disgusting
			loc	w112	So much fail
			loc	w113	Just unacceptable
			loc	w114	Absolutely the worst
			loc	w115	Absolute scum
			loc	w116	Simply disastrous
			loc	w117	Simply horrendous
			loc	w118	How worthless
			loc	w119	Just unthinkable
			loc	w120	An absolute fail
			loc	w121	Absolutely disastrous
			loc	w122	Absolutely horrendous
			loc	w123	Just unforgivable
			loc	w124	Just despicable
			loc	w125	Simply despicable
			loc	w126	Simply unforgivable
			loc	w127	Absolutely despicable
			loc	w128	Absolutely unforgivable
			loc	w129	Simply unsatisfactory
			loc	w130	Simply inadequate
			loc	w131	Simply unacceptable
			loc	w132	Simply worthless
			loc	w133	Absolutely unsatisfactory
			loc	w134	Absolutely inadequate
			loc	w135	Absolutely unacceptable
			loc	w136	Absolutely worthless
			loc	w137	Terrible
			loc	w138	Awful
			loc	w139	Useless
			loc	w140	Lowly
			loc	w141	Bad
			loc	w142	The worst
			loc	w143	Scum
			loc	w144	Disgusting
			loc	w145	Fail
			loc	w146	Disastrous
			loc	w147	Horrendous
			loc	w148	How poor
			loc	w149	How inferior
			loc	w150	Unsatisfactory
			loc	w151	Inadequate
			loc	w152	Unacceptable
			loc	w153	Deficient
			loc	w154	Faulty
			loc	w155	Shoddy
			loc	w156	Substandard
			loc	w157	Worthless
			loc	w158	What junk
			loc	w159	How could you
			loc	w160	Unthinkable
			loc	w161	Try to not do so poorly next time
			loc	w162	And I trusted you
			loc	w163	Despicable
			loc	w164	Scum of the earth
			loc	w165	Unforgivable
			loc	w166	Just terrible
			loc	w167	Just awful
			loc	w168	Simply terrible
			loc	w169	Simply awful
			loc	w170	Simply useless
			loc	w171	Absolutely terrible
			loc	w172	Absolutely awful
			loc	w173	Absolutely useless
			loc	w174	Just disgusting
			loc	w175	Just disastrous
			loc	w176	Just horrendous
			loc	w177	What were you thinking
			loc	w178	Just no
			loc	w179	Simply disgusting
			loc	w180	So much fail
			loc	w181	Just unacceptable
			loc	w182	Absolutely the worst
			loc	w183	Absolute scum
			loc	w184	Simply disastrous
			loc	w185	Simply horrendous
			loc	w186	How worthless
			loc	w187	Just unthinkable
			loc	w188	An absolute fail
			loc	w189	Absolutely disastrous
			loc	w190	Absolutely horrendous
			loc	w191	Just unforgivable
			loc	w192	Just despicable
			loc	w193	Simply despicable
			loc	w194	Simply unforgivable
			loc	w195	Absolutely despicable
			loc	w196	Absolutely unforgivable
			loc	w197	Simply unsatisfactory
			loc	w198	Simply inadequate
			loc	w199	Simply unacceptable
			loc	w200	Simply worthless
			loc	w201	Absolutely unsatisfactory
			loc	w202	Absolutely inadequate
			loc	w203	Absolutely unacceptable
			loc	w204	Absolutely worthless
			loc	w205	Terrible
			loc	w206	Awful
			loc	w207	Useless
			loc	w208	Lowly
			loc	w209	Bad
			loc	w210	Just terrible
		}
	}
	
	loc n = int((210)*runiform())
	
	if "`not'" == ""{
		if "`smiley'"!=""{
			loc poop = length("`w`n''")+2
			local mystring : display _dup(`poop') "_"
			local mystring2 : display _dup(`poop') " "
			noi di "   ___________" _n "  /           \" _n " /             \" ///
				_n "|   /\     /\   |   `mystring'" _n "|               |  |`mystring2'|" ///
				_n "|    _______    |  | `w`n''!|" _n " \   \_____/   /  <`mystring'_|" _n "  \___________/"
		}
		else{
			noi di "`w`n''!"
		}
	}
	else{
		if "`smiley'"!=""{
			if "`evil'"!=""{
				loc evil as err
			}
			loc poop = length("`w`n''")+4
			local mystring : display _dup(`poop') "_"
			local mystring2 : display _dup(`poop') " "
			noi di `evil' "   ___________" _n "  /           \" _n " /             \" ///
				_n "|   \/     \/   |   `mystring'" _n "|               |  |`mystring2'|" ///
				_n "|     _____     |  | `w`n''...|" _n " \   /_____\   /  <`mystring'_|" _n "  \___________/"
		}
		else{
			noi di "`w`n''..."
		}
	}
	return local phrase `w`n''
end



