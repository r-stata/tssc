*! irscharities
*! v 1.0.1
*! 20140210


cap prog drop irscharities
prog def irscharities
syntax , SAve(string) [ STate(string) NTEENfix REPlace ]
version 12.1

	// Require namespace to save the data set
	if "`save'" == "" {
		di as err "Need to specify a file name where the data will be stored."
		exit
	}
	else {
		if strmatch("`save'","*.dta")==1 { 
			loc save = subinstr("`save'",".dta","",.)
		}
	}

	// Require State option for now...will be changed in future
	if "`state'" == "" { 
		di as err "Must specify a state"
		exit
	}
	else if "`state'" != "" {
		loc tstate : length loc state
		// Must use 2 letter abbreviations
		if `tstate' > 2 { 
			di as err "Must use 2 character postal abbreviations"
		}
		else {
			loc st = lower("`state'")
			loc fst = upper("`state'")
			loc url `"http://www.irs.gov/pub/irs-soi/eo_`st'.zip"'
		}
	}
	
	// Set Locals for Area Codes
	loc area1 "me" "nh" "vt" "ma" "ri" "ct" "ny" "nj"
	loc area2 "pa" "oh" "wv" "dc" "md" "de" "va" "nc" "sc"
	loc area3 "mi" "ky" "in" "il" "wi" "mn" "ia" "ne" "sd" "nd" 
	loc area4 "tn" "ga" "fl" "al" "ms" "mo" "ar" "la" "tx" "ok" "ks"  
	loc area5 "mt" "wy" "co" "nm" "az" "ut" "nv" "id" "ca" "or" "wa" "ak" "hi"

	// Set Locals for Region Codes
	loc region1 "me" "nh" "vt" "ma" "ri" "ct" "ny" "nj"
	loc region2 "`area2' `area3'"
	loc region3 "`area4' `area5'"
	
	// Keep all data in memory safe
	preserve
	
		// Drop any existing data from memory
		clear
	
		// Create Tempfile for Data
		tempfile zipdat
		
		// Drop if tempfile exists
		cap rm "`zipdat'.zip"
		
		// Copy the ASCII Text file, which is zipped by default
		qui: copy "`url'" "`zipdat'.zip"
		
		// Extract the files
		qui: unzipfile "`zipdat'.zip", replace
		
		// Find Location of Dictionary File
		qui: findfile soi.dct, path(`c(ado_path)')
		
		// Read in the data based on IRS file specification
		qui: infix using "`r(fn)'", using(EO_`fst'.LST)
			
		// Attach variable labels to variables after reading from the dct file
		la var ein 				"Employer Identification Number (EIN)"
		la var name				"Primary Name of Organization"
		la var coname			"In Care of Name"
		la var street			"Street Address"
		la var city				"City"
		la var state			"State"
		la var zipcd			"Zip Code"
		la var exemptnum		"Group Exemption Number"
		la var section			"Subsection Code"
		la var affiliation		"Affiliation Code"
		la var classification	"Classification Code(s)"
		la var ruledate			"Ruling Date"
		la var deduct			"Deductibility Code"
		la var foundation		"Foundation Code"
		la var activity1		"Activity Codes - 1 of 3"
		la var activity2		"Activity Codes - 2 of 3"
		la var activity3		"Activity Codes - 3 of 3"
		la var orgcode			"Organization Code" 
		la var status			"Exempt Organization Status Code"
		la var advruling		"The Advance Ruling process is obsolete as of July 2008"
		la var taxperiod		"Tax Period"
		la var assetcd			"Asset Code"
		la var incomecd			"Income Code"
		la var filingreq			"Filing Requirement Code"
		la var pffilingreq		"PF Filing Requirement Code"
		la var na				"Blanks"
		la var acctperiod		"Accounting Period"
		la var assetamt			"Asset Amount"
		la var incomeamt		"Income Amount"
		la var negincome		"If the Income Amount is negative this contains a negative sign"
		la var revenueamt		"Form 990 Revenue Amount"
		la var negrevenue		"If Revenue Amount is negative this contains a negative sign"
		la var nteecode			"National Taxonomy of Exempt Entities (NTEE) Code"
		la var othername		"Sort Name (Secondary Name Line)"
		
		qui: replace incomeamt = incomeamt * -1 if negincome=="-"
		qui: replace revenueamt = revenueamt * -1 if negrevenue=="-"
		qui: drop na
		
		#d ;
		la def affcode	1 "Central - No Group Exemption" 
						2 "Intermediate - No Group Exemption" 
						3 "Independent" 
						6 "Central - Group Exemption"
						7 "Intermediate - Group Excemption"
						8 "Central - Group Exemption (501c1 or Church)"
						9 "Subordinate", modify ;
						
		la def deductcd	1 "Contributions are deductible"
						2 "Contributions are not deductible"
						3 "Contributions are deducible by treaty", modify ;
						
		la def foundcd	
				0 "All organizations except 501c3"
				2 "Private Operating Foundation (exempt excise)"
				3 "Private Operating Foundation (other)"
				4 "Private Non-Operating Foundation"
				9 "Suspense"
				10 "Church 170(b)(1)(A)(i)"
				11 "School 170(b)(1)(A)(ii)"
				12 "Hospital/Medical Research Facility 170(b)(1)(A)(iii)"
				13 "Higher Ed Benefit Governmental Unit 170(b)(1)(A)(iv)"
				14 "Governmental Unit 170(b)(1)(A)(v)"
				15 "Substantial Support from Gov. Unit or Public 170(b)(1)(A)(vi)"
				16 "< 1/3 from Gross Investment & Unrelated Income 170(b)(1)(A)(vii)"
				17 "Organizations Serving Codes 10-16 509(a)(3)"
				18 "Organization to Test for Public Safety 509(a)(4)"
				21 "509(a)(3) Type I"
				22 "509(a)(3) Type II"
				23 "509(a)(3) Type III - Functionally Integrated"
				24 "509(a)(3) Type III - Not Functionally Integrated", modify ;
					
		la def orgtype	1 "Corporation"
						2 "Trust"
						3 "Cooperative"
						4 "Partnership"
						5 "Association", modify ;
						
		la def status	1 "Unconditional Exemption"
						2 "Conditional Exemption"
						12 "Trust Described in section 4947(a)(2) of the IR code"
						25 "Organization Terminating its Private Foundation Status"
						32 "Organization that Did Not Respond to an IRS CP140 notice",
						modify ;
						
		la def incass	0 "$0"
						1 "$1 to $9,999"
						2 "$10,000 to $24,999"
						3 "$25,000 to $99,999"
						4 "$100,000 to $499,999"
						5 "$500,000 to $999,999"
						6 "$1,000,000 to $4,999,999"
						7 "$5,000,000 to $9,999,999"
						8 "$10,000,000 to $49,999,999"
						9 "$50,000,000 +", modify ;
						
		la def filereq	0 "990 - Not Required to File (All Other)"
						1 "990 - All Other or 990EZ Return"
						2 "990 - Required to File Form 990-N - < $25k Income"
						3 "990 - Group Return"
						4 "990 - Required to File Form 990-BL, Black Lung Trusts"
						6 "990 - Not Required to File (Church)"
						7 "990 - Government 501(c)(1)"
						13 "990 - Not Required to File (Religious Organization)"
						14 "990 - Not Required to File (State/Political Subdivisions",
						modify ;
						
		la def pfreq	1 "Required a 990-PF Return"
						0 "Did Not Require a 990-PF Return", modify ;
						
		la def activities 
				0	"No Information Available"
				// Religious Activities
				1 	"Church, synagogue, etc"
				2	"Association or convention of  churches"
				3	"Religious order"
				4	"Church auxiliary"
				5	"Mission"
				6	"Missionary activities"
				7	"Evangelism"
				8	"Religious publishing activities"
				29  "Other religious activities", modify ;
			
		la def activities 
				// Schools, Colleges, and Related Activites
				30	"School, college, trade school, etc."
				31	"Special school for the blind, handicapped, etc"
				32	"Nursery school"
				33	"Faculty group"
				34	"Alumni association or group"
				35	"Parent or parent-teachers association"
				36	"Fraternity or sorority"
				37	"Other student society or group"
				38	"School or college athletic association"
				39	"Scholarships for children of employees"
				40	"Scholarships (other)"
				41	"Student loans"
				42	"Student housing activities"
				43	"Other student aid"
				44	"Student exchange with foreign country"
				45	"Student operated business"
				46	"Private school"
				59	"Other school related activities", modify ;
		
		la def activities 
				// Cultural, Historical of Other Educational Activities
				60	"Museum, zoo, planetarium, etc."
				61	"Library"
				62	"Historical site, records or reenactment"
				63	"Monument"
				64	"Commemorative event (centennial, festival, pageant, etc.)"
				65	"Fair"
				88	"Community theatrical group"
				89	"Singing society or group"
				90	"Cultural performances"
				91	"Art exhibit"
				92	"Literary activities"
				93	"Cultural exchanges with foreign country"
				94	"Genealogical activities"
				119	"Other cultural or historical activities", modify ;
		
		la def activities 
				// Other Instructions and Training Activities
				120	"Publishing activities"
				121	"Radio or television broadcasting"
				122	"Producing films"
				123	"Discussion groups, forums, panels lectures, etc."
				124	"Study and research (non-scientific)"
				125	"Giving information or opinion (see also Advocacy)"
				126	"Apprentice training"
				149	"Other instruction and training", modify ;
		
		la def activities 
				// Health Services and Related Activities
				150	"Hospital"
				151	"Hospital auxiliary"
				152	"Nursing or convalescent home"
				153	"Care and housing for the aged (see also 382)"
				154	"Health clinic"
				155	"Rural medical facility"
				156	"Blood bank"
				157	"Cooperative hospital service organization"
				158	"Rescue and emergency service"
				159	"Nurses register or bureau"
				160	"Aid to the handicapped (see also 031)"
				161	"Scientific research (diseases)"
				162	"Other medical research"
				163	"Health insurance (medical, dental, optical, etc.)"
				164	"Prepared group health plan"
				165	"Community health planning"
				166	"Mental health care"
				167	"Group medical practice association"
				168	"In-faculty group practice association"
				169	"Hospital pharmacy, parking facility, food services, etc."
				179	"Other health services", modify ;
		
		la def activities 
				// Scientific Research Activities
				180	"Contact or sponsored scientific research for industry"
				181	"Scientific research for government"
				199	"Other scientific research activities", modify ;
		
		la def activities 
				// Business and Professional Organizations
				200	"Business promotion"
				201	"Real estate association"
				202	"Board of trade"
				203	"Regulating business"
				204	"Promotion of fair business practices"
				205	"Professional association"
				206	"Professional association auxiliary"
				207	"Industry trade shows"
				208	"Convention displays"
				209	"Research, development and testing"
				210	"Professional athletic league"
				211	"Underwriting municipal insurance"
				212	"Assigned risk insurance activities"
				213	"Tourist bureau"
				229	"Other business or professional group", modify ;
		
		la def activities 
				// Farming and Related Activities
				230	"Farming"
				231	"Farm bureau"
				232	"Agricultural group"
				233	"Horticultural group"
				234	"Farmers cooperative marketing or purchasing"
				235	"Farmers cooperative marketing or purchasing"
				236	"Dairy herd improvement association"
				237	"Breeders association"
				249	"Other farming and related activities", modify ;
		
		la def activities 
				// Mutual Organizations
				250	"Mutual ditch, irrigation, or utilities organization"
				251	"Credit union"
				252	"Reserve funds or insurance"
				253	"Mutual insurance company"
				254	"Corporation organized under an Act of Congress"
				259	"Other mutual organization", modify ;
		
		la def activities 
				// Employee of Membership Benefit Organizations
				260	"Fraternal Beneficiary society, order, or association"
				261	"Improvement of conditions of workers"
				262	"Association of municipal employees"
				263	"Association of employees"
				264 "Employee or member welfare association"
				265	"Sick, accident, death, or similar benefits"
				266	"Strike benefits"
				267	"Unemployment benefits"
				268	"Pension or retirement benefits"
				269	"Vacation benefits"
				279	"Other services or benefits to members or employees", modify ;
		
		la def activities 
				// Sports, Athletic Recreational and Social Activities
				280	"Country club"
				281	"Hobby club"
				282	"Dinner club"
				283	"Variety club"
				284	"Dog club"
				285	"Women's club"
				286	"Hunting or fishing club"
				287	"Swimming or tennis club"
				288	"Other sports club"
				296	"Community center"
				297	"Community recreational facilities (park, playground, etc)"
				298	"Training in sports"
				299	"Travel tours"
				300	"Amateur athletic association"
				301	"Fundraising athletic or sports event"
				317	"Other sports or athletic activities"
				318	"Other recreational activities"
				319	"Other social activities", modify ;
		
		la def activities 
				// Youth Activities
				320	"Boy Scouts, Girl Scouts, etc."
				321	"Boys Club, Little League, etc."
				322	"FFA, FHA, 4-H club, etc."
				323	"Key club"
				324	"YMCA, YWCA, YMCA, etc."
				325	"Camp"
				326	"Care and housing of children (orphanage, etc)"
				327	"Prevention of cruelty to children"
				328	"Combat juvenile delinquency"
				349	"Other youth organization or activities", modify ;
		
		la def activities 
				// Conservation, Environmental and Beautification Activities
				350	"Preservation of natural resources (conservation)"
				351	"Combating or preventing pollution (air, water, etc)"
				352	"Land acquisition for preservation"
				353	"Soil or water conservation"
				354	"Preservation of scenic beauty"
				355	"Wildlife sanctuary or refuge"
				356	"Garden club"
				379	"Other conservation, environmental or beautification activities", modify ;
		
		la def activities 
				// Housing Activities
				380	"Low-income housing"
				381	"Low and moderate income housing"
				382	"Housing for the aged (see also 153)"
				398	"Instruction and guidance on housing"
				399	"Other housing activities", modify ;
		
		la def activities 
				// Inner City or Community Activities
				400	"Area development, redevelopment of renewal"
				401	"Homeowners association"
				402	"Other activity aimed t combating community deterioration"
				403	"Attracting new industry or retaining industry in an area"
				404	"Community promotion"
				405	"Loans or grants for minority businesses"
				406	"Crime prevention"
				407	"Voluntary firemen's organization or auxiliary"
				408	"Community service organization"
				429	"Other inner city or community benefit activities", modify ;
		
		la def activities 
				// Civil Rights Activities
				430	"Defense of human and civil rights"
				431	"Elimination of prejudice and discrimination"
				432	"Lessen neighborhood tensions"
				449	"Other civil rights activities", modify ;
		
		la def activities 
				// Litigation and Legal Aid Activities
				460	"Public interest litigation activities"
				461	"Other litigation or support of litigation"
				462	"Legal aid to indigents"
				463	"Providing bail"
				465	"Plan under IRC section 120", modify ;
		
		la def activities 
				// Legislative and Political Activities
				480	"Propose, support, or oppose legislation"
				481	"Voter information on issues or candidates"
				482	"Voter education (mechanics of registering, voting etc.)"
				483	"Support, oppose, or rate political candidates"
				484	"Provide facilities or services for political campaign activities"
				509	"Other legislative and political activities", modify ;
		
		la def activities 
				// Advocacy Attempt to influence public opinion concerning:
				510	"Firearms control"
				511	"Selective Service System"
				512	"National defense policy"
				513	"Weapons systems"
				514	"Government spending"
				515	"Taxes or tax exemption"
				516	"Separation of church and state"
				517	"Government aid to parochial schools"
				518	"U.S. foreign policy"
				519	"U.S. military involvement"
				520	"Pacifism and peace"
				521	"Economic-political system of U.S."
				522	"Anti-communism"
				523	"Right to work"
				524	"Zoning or rezoning"
				525	"Location of highway or transportation system"
				526	"Rights of criminal defendants"
				527	"Capital punishment"
				528	"Stricter law enforcement"
				529	"Ecology or conservation"
				530	"Protection of consumer interests"
				531	"Medical care service"
				532	"Welfare systems"
				533	"Urban renewal"
				534	"Busing student to achieve racial balance"
				535	"Racial integration"
				536	"Use of intoxicating beverage"
				537	"Use of drugs or narcotics"
				538	"Use of tobacco"
				539	"Prohibition of erotica"
				540	"Sex education in public schools"
				541	"Population control"
				542	"Birth control methods"
				543	"Legalized abortion"
				559	"Other matters", modify ;
		
		la def activities 
				// Other Activities Directed to Individuals
				560	"Supplying money, goods or services to the poor"
				561	"Gifts or grants to individuals (other than scholarships)"
				562	"Other loans to individuals"
				563	"Marriage counseling"
				564	"Family planning"
				565	"Credit counseling an assistance"
				566	"Job training, counseling, or assistance"
				567	"Draft counseling"
				568	"Vocational counseling"
				569	"Referral service (social agencies)"
				572	"Rehabilitating convicts or ex-convicts"
				573	"Rehabilitating alcoholics, drug abusers, compulsive gamblers, etc."
				574	"Day care center"
				575	"Services for the aged (see also 153 ad 382)", modify ;
		
		la def activities 
				// Activities Purposes and Activities
				600	"Community Chest, United Way, etc."
				601	"Booster club"
				602	"Gifts, grants, or loans to other organizations"
				603	"Non-financial services of facilities to other organizations", modify ;
				
		la def activities 
				// Other Purposes and Activities
				900	"Cemetery or burial activities"
				901	"Perpetual (care fund (cemetery, columbarium, etc)"
				902	"Emergency or disaster aid fund"
				903	"Community trust or component"
				904	"Government instrumentality or agency (see also 254)"
				905	"Testing products for public safety"
				906	"Consumer interest group"
				907	"Veterans activities"
				908 "Patriotic activities"
				909 "Non-exempt charitable trust described in section 4947(a)(1)"
				910	"Domestic organization with activities outside U.S."
				911	"Foreign organization"
				912	"Title holding corporation"
				913 "Prevention of cruelty to animals"
				914	"Achievement pries of awards"
				915	"Erection or maintenance of public building or works"
				916	"Cafeteria, restaurant, snack bar, food services, etc."
				917	"Thrift ship, retail outlet, etc."
				918	"Book, gift  or supply store"
				919	"Advertising"
				920	"Association of employees"
				921	"Loans or credit reporting"
				922	"Endowment fund or financial services"
				923	"Indians (tribes, cultures, etc.)"
				924	"Traffic or tariff bureau"
				925	"Section 501(c)(1) with 50% deductibility"
				926	"Government instrumentality other than section 501(c)"
				927	"Fundraising"
				928	"4947(a)(2) trust"
				930	"Prepaid legal services pan exempt under IRC section 501(c)(20)"
				931	"Withdrawal liability payment fund"
				990 "Section 501(k) child care organization"
				994 "Described in section 170(b)1)(a)(vi) of the Code"
				995 "Described in section 509(a)(2) of the Code"
				998 "Unspecified", modify ;
		
		la def nteeclass
				1	"Arts, Culture and Humanities"
				2	"Educational Institutions and Related Activities"
				3	"Environmental Quality, Protection and Beautification"
				4 	"Animal-Related"
				5	"Health - General and Rehabilitative"
				6	"Mental Health, Crisis Intervention"
				7	"Diseases, Disorders, Medical Disciplines"
				8	"Medical Research"
				9	"Crime, Legal-Related"
				10	"Employment, Job-Related"
				11	"Food, Agriculture and Nutrition"
				12	"Housing, Shelter"
				13	"Public Safety, Disaster Preparedness and Relief"
				14	"Recreation, Sports, Leisure, Athletics"
				15	"Youth Development"
				16	"Human Services - Multipurpose and Other"
				17	"International, Foreign Affairs and National Security"
				18	"Civil Rights, Social Action, Advocacy"
				19	"Community Improvement, Capacity Building"
				20	"Philanthropy, Voluntarism and Grantmaking Foundations"
				21	"Science and Technology Research Institutes, Services"
				22	"Social Science Research Institutes, Services"
				23	"Public, Society Benefit - Multipurpose and Other"
				24	"Religion-Related, Spiritual Development"
				25	"Mutual/Membership Benefit Organizations, Other"
				26	"Unknown"
				.n	"No Information Provided", modify ;
		
		la def nteecodes
			// 1 - Arts, Culture and Humanities
			101 "Alliance/Advocacy Organizations"
			102 "Management & Technical Assistance"
			103 "Professional Societies, Associations"
			105 "Research Institutes and/or Public Policy Analysis"
			111 "Single Organization Support"
			112 "Fund Raising and/or Fund Distribution"
			119 "Nonmonetary Support N.E.C."
			120 "Arts, Cultural Organizations - Multipurpose"
			123 "Cultural, Ethnic Awareness"
			125 "Arts Education"
			126 "Arts Council/Agency"
			130 "Media, Communications Organizations"
			131 "Film, Video"
			132 "Television"
			133 "Printing, Publishing"
			134 "Radio"
			140 "Visual Arts Organizations"
			150 "Museum, Museum Activities"
			151 "Art Museums"
			152 "Children's Museums"
			154 "History Museums"
			156 "Natural History, Natural Science Museums"
			157 "Science and Technology Museums"
			160 "Performing Arts Organizations"
			161 "Performing Arts Centers"
			162 "Dance"
			163 "Ballet"
			165 "Theater"
			168 "Music"
			169 "Symphony Orchestras"
			171 "Opera"
			172 "Singing, Choral"
			173 "Music Groups, Bands, Ensembles"
			174 "Performing Arts Schools"
			170 "Humanities Organizations"
			180 "Historical Societies, Related Historical Activities"
			184 "Commemorative Events"
			190 "Arts Service Organizations and Activities"
			199 "Arts, Culture, and Humanities N.E.C.", modify ;
		
		la def nteecodes
			// 2 - Education
			201 "Alliance/Advocacy Organizations"
			202 "Management & Technical Assistance"
			203 "Professional Societies, Associations"
			205 "Research Institutes and/or Public Policy Analysis"
			211 "Single Organization Support"
			212 "Fund Raising and/or Fund Distribution"
			219 "Nonmonetary Support N.E.C."
			220 "Elementary, Secondary Education, K - 12"
			221 "Kindergarten, Preschool, Nursery School, Early Admissions"
			224 "Primary, Elementary Schools"
			225 "Secondary, High School"
			228 "Specialized Education Institutions"
			230 "Vocational, Technical Schools"
			240 "Higher Education Institutions"
			241 "Community or Junior Colleges"
			242 "Undergraduate College (4-year)"
			243 "University or Technological Institute"
			250 "Graduate, Professional Schools (Separate Entities)"
			260 "Adult, Continuing Education"
			270 "Libraries"
			280 "Student Services, Organizations of Students"
			282 "Scholarships, Student Financial Aid Services, Awards"
			283 "Student Sororities, Fraternities"
			284 "Alumni Associations"
			290 "Educational Services and Schools - Other"
			292 "Remedial Reading, Reading Encouragement"
			294 "Parent/Teacher Group"
			299 "Education N.E.C.", modify ;
		
		la def nteecodes
			// 3 - Environmental Quality, Protection and Beautification 
			301 "Alliance/Advocacy Organizations"
			302 "Management & Technical Assistance"
			303 "Professional Societies, Associations"
			305 "Research Institutes and/or Public Policy Analysis"
			311 "Single Organization Support"
			312 "Fund Raising and/or Fund Distribution"
			319 "Nonmonetary Support N.E.C."
			320 "Pollution Abatement and Control Services"
			327 "Recycling Programs"
			330 "Natural Resources Conservation and Protection"
			332 "Water Resource, Wetlands Conservation and Management"
			334 "Land Resources Conservation"
			335 "Energy Resources Conservation and Development"
			336 "Forest Conservation"
			340 "Botanical, Horticultural, and Landscape Services"
			341 "Botanical Gardens, Arboreta and Botanical Organizations"
			342 "Garden Club, Horticultural Program"
			350 "Environmental Beautification and Aesthetics"
			360 "Environmental Education and Outdoor Survival Programs"
			399 "Environmental Quality, Protection, and Beautification N.E.C.", modify ;
		
		la def nteecodes
			// 4 - Animal-Related 
			401 "Alliance/Advocacy Organizations"
			402 "Management & Technical Assistance"
			403 "Professional Societies, Associations"
			405 "Research Institutes and/or Public Policy Analysis"
			411 "Single Organization Support"
			412 "Fund Raising and/or Fund Distribution" 
			419 "Nonmonetary Support N.E.C."
			420 "Animal Protection and Welfare"
			430 "Wildlife Preservation, Protection"
			431 "Protection of Endangered Species"
			432 "Bird Sanctuary, Preserve"
			433 "Fisheries Resources"
			434 "Wildlife Sanctuary, Refuge"
			440 "Veterinary Services"
			450 "Zoo, Zoological Society"
			460 "Other Services - Specialty Animals"
			461 "Animal Training, Behavior"
			499 "Animal-Related N.E.C.", modify ;
		
		la def nteecodes
			// 5 - Health - General and Rehabilitative
			501 "Alliance/Advocacy Organizations"
			502 "Management & Technical Assistance"
			503 "Professional Societies, Associations"
			505 "Research Institutes and/or Public Policy Analysis"
			511 "Single Organization Support"
			512 "Fund Raising and/or Fund Distribution"
			519 "Nonmonetary Support N.E.C."
			520 "Hospitals and Related Primary Medical Care Facilities"
			521 "Community Health Systems"
			522 "Hospital, General"
			524 "Hospital, Specialty"
			530 "Health Treatment Facilities, Primarily Outpatient"
			531 "Group Health Practice (Health Maintenance Organizations)"
			532 "Ambulatory Health Center, Community Clinic"
			540 "Reproductive Health Care Facilities and Allied Services"
			542 "Family Planning Centers"
			550 "Rehabilitative Medical Services"
			560 "Health Support Services"
			561 "Blood Supply Related"
			562 "Ambulance, Emergency Medical Transport Services"
			565 "Organ and Tissue Banks"
			570 "Public Health Program (Includes General Health/Wellness)"
			580 "Health, General and Financing"
			586 "Patient Services - Entertainment, Recreation"
			590 "Nursing Services (General)"
			591 "Nursing, Convalescent Facilities"
			592 "Home Health Care"
			599 "Health - General and Rehabilitative N.E.C.", modify ;
		
		la def nteecodes
			// 6 - Mental Health, Crisis Intervention
			601 "Alliance/Advocacy Organizations"
			602 "Management & Technical Assistance"
			603 "Professional Societies, Associations"
			605 "Research Institutes and/or Public Policy Analysis"
			611 "Single Organization Support"
			612 "Fund Raising and/or Fund Distribution"
			619 "Nonmonetary Support N.E.C."
			620 "Alcohol and Drug Dependency Prevention and Treatment"
			621 "Alcohol, Drug Abuse, Prevention Only"
			622 "Alcohol, Drug Abuse, Treatment Only"
			630 "Mental Health Treatment - Multipurpose and N.E.C."
			631 "Psychiatric, Mental Health Hospital"
			632 "Community Mental Health Center"
			633 "Group Home, Residential Treatment Facility - Mental Health Related"
			640 "Hot Line, Crisis Intervention Services"
			642 "Rape Victim Services"
			650 "Addictive Disorders N.E.C."
			652 "Smoking Addiction"
			653 "Eating Disorder, Addiction"
			654 "Gambling Addiction"
			660 "Counseling, Support Groups"
			670 "Mental Health Disorders"
			680 "Mental Health Association, Multipurpose"
			699 "Mental Health, Crisis Intervention N.E.C.", modify ;
		
		la def nteecodes
			// 7 - Diseases, Disorders, Medical Disciplines
			701 "Alliance/Advocacy Organizations"
			702 "Management & Technical Assistance"
			703 "Professional Societies, Associations"
			705 "Research Institutes and/or Public Policy Analysis"
			711 "Single Organization Support"
			712 "Fund Raising and/or Fund Distribution"
			719 "Nonmonetary Support N.E.C."
			720 "Birth Defects and Genetic Diseases"
			725 "Down Syndrome"
			730 "Cancer"
			740 "Diseases of Specific Organs"
			741 "Eye Diseases, Blindness and Vision Impairments"
			742 "Ear and Throat Diseases"
			743 "Heart and Circulatory System Diseases, Disorders"
			744 "Kidney Disease"
			745 "Lung Disease"
			748 "Brain Disorders"
			750 "Nerve, Muscle and Bone Diseases"
			751 "Arthritis"
			754 "Epilepsy"
			760 "Allergy Related Diseases"
			761 "Asthma"
			770 "Digestive Diseases, Disorders"
			780 "Specifically Named Diseases"
			781 "AIDS"
			783 "Alzheimer's Disease"
			784 "Autism"
			790 "Medical Disciplines"
			792 "Biomedicine, Bioengineering"
			794 "Geriatrics"
			796 "Neurology, Neuroscience"
			798 "Pediatrics"
			797 "Surgery"
			799 "Diseases, Disorders, Medical Disciplines N.E.C.", modify ; 
		
		la def nteecodes
			// 8 - Medical Research
			801 "Alliance/Advocacy Organizations"
			802 "Management & Technical Assistance"
			803 "Professional Societies, Associations"
			805 "Research Institutes and/or Public Policy Analysis"
			811 "Single Organization Support"
			812 "Fund Raising and/or Fund Distribution"
			819 "Nonmonetary Support N.E.C."
			820 "Birth Defects, Genetic Diseases Research"
			825 "Down Syndrome Research"
			830 "Cancer Research"
			840 "Specific Organ Research"
			841 "Eye Research"
			842 "Ear and Throat Research"
			843 "Heart, Circulatory Research"
			844 "Kidney Research"
			845 "Lung Research"
			848 "Brain Disorders Research"
			850 "Nerve, Muscle, Bone Research"
			851 "Arthritis Research"
			854 "Epilepsy Research"
			860 "Allergy Related Disease Research"
			861 "Asthma Research"
			870 "Digestive Disease, Disorder Research"
			880 "Specifically Named Diseases Research"
			881 "AIDS Research"
			883 "Alzheimer's Disease Research"
			884 "Autism Research"
			890 "Medical Specialty Research"
			892 "Biomedicine, Bioengineering Research"
			894 "Geriatrics Research"
			896 "Neurology, Neuroscience Research"
			898 "Pediatrics Research"
			897 "Surgery Research"
			899 "Medical Research N.E.C.", modify ;
		
		la def nteecodes
			// 9 - Crime, Legal-Related
			901 "Alliance/Advocacy Organizations"
			902 "Management & Technical Assistance"
			903 "Professional Societies, Associations"
			905 "Research Institutes and/or Public Policy Analysis"
			911 "Single Organization Support"
			912 "Fund Raising and/or Fund Distribution"
			919 "Nonmonetary Support N.E.C."
			920 "Crime Prevention N.E.C."
			921 "Delinquency Prevention"
			923 "Drunk Driving Related"
			930 "Correctional Facilities N.E.C."
			931 "Transitional Care, Half-Way House for Offenders, Ex-Offenders"
			940 "Rehabilitation Services for Offenders"
			943 "Services to Prisoners and Families - Multipurpose"
			944 "Prison Alternatives"
			950 "Administration of Justice, Courts"
			951 "Dispute Resolution, Mediation Services"
			960 "Law Enforcement Agencies (Police Departments)"
			970 "Protection Against, Prevention of Neglect, Abuse, Exploitation"
			971 "Spouse Abuse, Prevention of"
			972 "Child Abuse, Prevention of"
			973 "Sexual Abuse, Prevention of"
			980 "Legal Services"
			983 "Public Interest Law, Litigation"
			999 "Crime, Legal Related N.E.C.", modify ; 
		
		la def nteecodes
			// 10 - Employment, Job-Related
			1001 "Alliance/Advocacy Organizations"
			1002 "Management & Technical Assistance"
			1003 "Professional Societies, Associations"
			1005 "Research Institutes and/or Public Policy Analysis"
			1011 "Single Organization Support"
			1012 "Fund Raising and/or Fund Distribution"
			1019 "Nonmonetary Support N.E.C."
			1020 "Employment Procurement Assistance, Job Training"
			1021 "Vocational Counseling, Guidance and Testing"
			1022 "Vocational Training"
			1030 "Vocational Rehabilitation"
			1032 "Goodwill Industries"
			1033 "Sheltered Remunerative Employment, Work Activity Center N.E.C."
			1040 "Labor Unions, Organizations"
			1099 "Employment, Job Related N.E.C.", modify ;
		
		la def nteecodes
			// 11 - Food, Agriculture and Nutrition 
			1101 "Alliance/Advocacy Organizations"
			1102 "Management & Technical Assistance"
			1103 "Professional Societies, Associations"
			1105 "Research Institutes and/or Public Policy Analysis"
			1111 "Single Organization Support"
			1112 "Fund Raising and/or Fund Distribution"
			1119 "Nonmonetary Support N.E.C."
			1120 "Agricultural Programs"
			1125 "Farmland Preservation"
			1126 "Livestock Breeding, Development, Management"
			1128 "Farm Bureau, Grange"
			1130 "Food Service, Free Food Distribution Programs"
			1131 "Food Banks, Food Pantries"
			1134 "Congregate Meals"
			1135 "Eatery, Agency, Organization Sponsored"
			1136 "Meals on Wheels"
			1140 "Nutrition Programs"
			1150 "Home Economics"
			1199 "Food, Agriculture, and Nutrition N.E.C.", modify ; 
		
		la def nteecodes
			// 12 - Housing, Shelter
			1201 "Alliance/Advocacy Organizations"
			1202 "Management & Technical Assistance"
			1203 "Professional Societies, Associations"
			1205 "Research Institutes and/or Public Policy Analysis"
			1211 "Single Organization Support"
			1212 "Fund Raising and/or Fund Distribution"
			1219 "Nonmonetary Support N.E.C."
			1220 "Housing Development, Construction, Management"
			1221 "Public Housing Facilities"
			1222 "Senior Citizens' Housing/Retirement Communities"
			1225 "Housing Rehabilitation"
			1230 "Housing Search Assistance"
			1240 "Low-Cost Temporary Housing"
			1241 "Homeless, Temporary Shelter For"
			1250 "Housing Owners, Renters Organizations"
			1280 "Housing Support Services -- Other"
			1281 "Home Improvement and Repairs"
			1282 "Housing Expense Reduction Support"
			1299 "Housing, Shelter N.E.C.", modify ;
		
		la def nteecodes
			// 13 - Public Safety, Disaster Preparedness and Relief
			1301 "Alliance/Advocacy Organizations" 
			1302 "Management & Technical Assistance"
			1303 "Professional Societies, Associations"
			1305 "Research Institutes and/or Public Policy Analysis"
			1311 "Single Organization Support"
			1312 "Fund Raising and/or Fund Distribution"
			1319 "Nonmonetary Support N.E.C."
			1320 "Disaster Preparedness and Relief Services"
			1323 "Search and Rescue Squads, Services"
			1324 "Fire Prevention, Protection, Control"
			1340 "Safety Education"
			1341 "First Aid Training, Services"
			1342 "Automotive Safety"
			1399 "Public Safety, Disaster Preparedness, and Relief N.E.C.", modify ;
		
		la def nteecodes
			// 14 - Recreation, Sports, Leisure, Athletics 
			1401 "Alliance/Advocacy Organizations"
			1402 "Management & Technical Assistance"
			1403 "Professional Societies, Associations"
			1405 "Research Institutes and/or Public Policy Analysis"
			1411 "Single Organization Support"
			1412 "Fund Raising and/or Fund Distribution"
			1419 "Nonmonetary Support N.E.C."
			1420 "Recreational and Sporting Camps"
			1430 "Physical Fitness and Community Recreational Facilities"
			1431 "Community Recreational Centers"
			1432 "Parks and Playgrounds"
			1440 "Sports Training Facilities, Agencies"
			1450 "Recreational, Pleasure, or Social Club"
			1452 "Fairs, County and Other"
			1460 "Amateur Sports Clubs, Leagues, N.E.C."
			1461 "Fishing, Hunting Clubs"
			1462 "Basketball"
			1463 "Baseball, Softball"
			1464 "Soccer Clubs, Leagues"
			1465 "Football Clubs, Leagues"
			1466 "Tennis, Racquet Sports Clubs, Leagues"
			1467 "Swimming, Water Recreation"
			1468 "Winter Sports (Snow and Ice)"
			1469 "Equestrian, Riding"
			1459 "Golf"
			1470 "Amateur Sports Competitions"
			1471 "Olympics Committees and Related International Competitions"
			1472 "Special Olympics"
			1480 "Professional Athletic Leagues"
			1499 "Recreation, Sports, Leisure, Athletics N.E.C.", modify ;
		
		la def nteecodes
			// 15 - Youth Development 
			1501 "Alliance/Advocacy Organizations"
			1502 "Management & Technical Assistance"
			1503 "Professional Societies, Associations"
			1505 "Research Institutes and/or Public Policy Analysis"
			1511 "Single Organization Support"
			1512 "Fund Raising and/or Fund Distribution"
			1519 "Nonmonetary Support N.E.C."
			1520 "Youth Centers, Clubs, Multipurpose"
			1521 "Boys Clubs"
			1522 "Girls Clubs"
			1523 "Boys and Girls Clubs (Combined)"
			1530 "Adult, Child Matching Programs"
			1531 "Big Brothers, Big Sisters"
			1540 "Scouting Organizations"
			1541 "Boy Scouts of America"
			1542 "Girl Scouts of the U.S.A."
			1543 "Camp Fire"
			1550 "Youth Development Programs, Other"
			1551 "Youth Community Service Clubs"
			1552 "Youth Development - Agricultural"
			1553 "Youth Development - Business"
			1554 "Youth Development - Citizenship Programs"
			1555 "Youth Development - Religious Leadership"
			1599 "Youth Development N.E.C.", modify ;
		
		la def nteecodes
			// 16 - Human Services - Multipurpose and Other 
			1601 "Alliance/Advocacy Organizations"
			1602 "Management & Technical Assistance"
			1603 "Professional Societies, Associations"
			1605 "Research Institutes and/or Public Policy Analysis"
			1611 "Single Organization Support"
			1612 "Fund Raising and/or Fund Distribution"
			1619 "Nonmonetary Support N.E.C."
			1620 "Human Service Organizations - Multipurpose"
			1621 "American Red Cross"
			1622 "Urban League"
			1624 "Salvation Army"
			1626 "Volunteers of America"
			1627 "Young Men's or Women's Associations (YMCA, YWCA, YWHA, YMHA)"
			1628 "Neighborhood Centers, Settlement Houses"
			1629 "Thrift Shops"
			1630 "Children's, Youth Services"
			1631 "Adoption"
			1632 "Foster Care"
			1633 "Child Day Care"
			1640 "Family Services"
			1642 "Single Parent Agencies, Services"
			1643 "Family Violence Shelters, Services"
			1644 "Homemaker, Home Health Aide"
			1645 "Family Services, Adolescent Parents"
			1646 "Family Counseling"
			1650 "Personal Social Services"
			1651 "Financial Counseling, Money Management"
			1652 "Transportation, Free or Subsidized"
			1658 "Gift Distribution"
			1660 "Emergency Assistance (Food, Clothing, Cash)"
			1661 "Travelers' Aid"
			1662 "Victims' Services"
			1670 "Residential, Custodial Care"
			1672 "Half-Way House (Short-Term Residential Care)"
			1673 "Group Home (Long Term)"
			1674 "Hospice"
			1675 "Senior Continuing Care Communities"
			1680 "Services to Promote the Independence of Specific Populations"
			1681 "Senior Centers, Services"
			1682 "Developmentally Disabled Centers, Services"
			1684 "Ethnic, Immigrant Centers, Services"
			1685 "Homeless Persons Centers, Services"
			1686 "Blind/Visually Impaired Centers, Services" 
			1687 "Deaf/Hearing Impaired Centers, Services"
			1699 "Human Services - Multipurpose and Other N.E.C.", modify ; 
		
		la def nteecodes
			// 17 - International, Foreign Affairs and National Security 
			1701 "Alliance/Advocacy Organizations"
			1702 "Management & Technical Assistance"
			1703 "Professional Societies, Associations"
			1705 "Research Institutes and/or Public Policy Analysis"
			1711 "Single Organization Support"
			1712 "Fund Raising and/or Fund Distribution"
			1719 "Nonmonetary Support N.E.C."
			1720 "Promotion of International Understanding"
			1721 "International Cultural Exchange"
			1722 "International Student Exchange and Aid"
			1723 "International Exchanges, N.E.C."
			1730 "International Development, Relief Services"
			1731 "International Agricultural Development"
			1732 "International Economic Development"
			1733 "International Relief"
			1740 "International Peace and Security"
			1741 "Arms Control, Peace Organizations"
			1742 "United Nations Association"
			1743 "National Security, Domestic"
			1770 "International Human Rights"
			1771 "International Migration, Refugee Issues"
			1799 "International, Foreign Affairs, and National Security N.E.C.", modify ;
		
		la def nteecodes
			// 18 - Civil Rights, Social Action, Advocacy 
			1801 "Alliance/Advocacy Organizations"
			1802 "Management & Technical Assistance"
			1803 "Professional Societies, Associations"
			1805 "Research Institutes and/or Public Policy Analysis"
			1811 "Single Organization Support"
			1812 "Fund Raising and/or Fund Distribution"
			1819 "Nonmonetary Support N.E.C."
			1820 "Civil Rights, Advocacy for Specific Groups"
			1822 "Minority Rights"
			1823 "Disabled Persons' Rights"
			1824 "Women's Rights"
			1825 "Seniors' Rights"
			1826 "Lesbian, Gay Rights"
			1830 "Intergroup, Race Relations"
			1840 "Voter Education, Registration"
			1860 "Civil Liberties Advocacy"
			1861 "Reproductive Rights"
			1862 "Right to Life"
			1863 "Censorship, Freedom of Speech and Press Issues"
			1867 "Right to Die, Euthanasia Issues"
			1899 "Civil Rights, Social Action, Advocacy N.E.C.", modify ;
		
		la def nteecodes
			// 19 - Community Improvement, Capacity Building 
			1901 "Alliance/Advocacy Organizations"
			1902 "Management & Technical Assistance"
			1903 "Professional Societies, Associations"
			1905 "Research Institutes and/or Public Policy Analysis"
			1911 "Single Organization Support"
			1912 "Fund Raising and/or Fund Distribution"
			1919 "Nonmonetary Support N.E.C."
			1920 "Community, Neighborhood Development, Improvement (General)"
			1921 "Community Coalitions"
			1922 "Neighborhood, Block Associations"
			1930 "Economic Development"
			1931 "Urban, Community Economic Development"
			1932 "Rural Development"
			1940 "Business and Industry"
			1941 "Promotion of Business"
			1943 "Management Services for Small Business, Entrepreneurs"
			1946 "Boards of Trade"
			1947 "Real Estate Organizations"
			1950 "Nonprofit Management"
			1980 "Community Service Clubs"
			1981 "Women's Service Clubs"
			1982 "Men's Service Clubs"
			1999 "Community Improvement, Capacity Building N.E.C.", modify ;
		
		la def nteecodes
			// 20 - Philanthropy, Voluntarism and Grantmaking Foundations 
			2001 "Alliance/Advocacy Organizations"
			2002 "Management & Technical Assistance"
			2003 "Professional Societies, Associations"
			2005 "Research Institutes and/or Public Policy Analysis"
			2011 "Single Organization Support"
			2012 "Fund Raising and/or Fund Distribution"
			2019 "Nonmonetary Support N.E.C."
			2020 "Private Grantmaking Foundations"
			2021 "Corporate Foundations"
			2022 "Private Independent Foundations"
			2023 "Private Operating Foundations"
			2030 "Public Foundations"
			2031 "Community Foundations"
			2040 "Voluntarism Promotion"
			2050 "Philanthropy, Charity, Voluntarism Promotion, General"
			2070 "Fund Raising Organizations That Cross Categories"
			2090 "Named Trusts/Foundations N.E.C."
			2099 "Philanthropy, Voluntarism, and Grantmaking Foundations N.E.C.", modify ;
		
		la def nteecodes
			// 21 - Science and Technology Research Institutes, Services 
			2101 "Alliance/Advocacy Organizations"
			2102 "Management & Technical Assistance"
			2103 "Professional Societies, Associations"
			2105 "Research Institutes and/or Public Policy Analysis"
			2111 "Single Organization Support"
			2112 "Fund Raising and/or Fund Distribution"
			2119 "Nonmonetary Support N.E.C."
			2120 "Science, General"
			2121 "Marine Science and Oceanography"
			2130 "Physical Sciences, Earth Sciences Research and Promotion"
			2131 "Astronomy"
			2133 "Chemistry, Chemical Engineering"
			2134 "Mathematics"
			2136 "Geology"
			2140 "Engineering and Technology Research, Services"
			2141 "Computer Science"
			2142 "Engineering"
			2150 "Biological, Life Science Research"
			2199 "Science and Technology Research Institutes, Services N.E.C.", modify ;
		
		la def nteecodes
			// 22 - Social Science Research Institutes, Services
			2201 "Alliance/Advocacy Organizations"
			2202 "Management & Technical Assistance"
			2203 "Professional Societies, Associations"
			2205 "Research Institutes and/or Public Policy Analysis"
			2211 "Single Organization Support"
			2212 "Fund Raising and/or Fund Distribution" 
			2219 "Nonmonetary Support N.E.C."
			2220 "Social Science Institutes, Services"
			2221 "Anthropology, Sociology"
			2222 "Economics (as a social science)"
			2223 "Behavioral Science"
			2224 "Political Science"
			2225 "Population Studies"
			2226 "Law, International Law, Jurisprudence"
			2230 "Interdisciplinary Research"
			2231 "Black Studies"
			2232 "Women's Studies"
			2233 "Ethnic Studies"
			2234 "Urban Studies"
			2235 "International Studies"
			2236 "Gerontology (as a social science)"
			2237 "Labor Studies"
			2299 "Social Science Research Institutes, Services N.E.C.", modify ;
		
		la def nteecodes
			// 23 - Public, Society Benefit - Multipurpose and Other
			2301 "Alliance/Advocacy Organizations"
			2302 "Management & Technical Assistance"
			2303 "Professional Societies, Associations"
			2305 "Research Institutes and/or Public Policy Analysis"
			2311 "Single Organization Support"
			2312 "Fund Raising and/or Fund Distribution"
			2319 "Nonmonetary Support N.E.C."
			2320 "Government and Public Administration"
			2322 "Public Finance, Taxation, Monetary Policy"
			2324 "Citizen Participation"
			2330 "Military, Veterans' Organizations"
			2340 "Public Transportation Systems, Services"
			2350 "Telephone, Telegraph and Telecommunication Services"
			2360 "Financial Institutions, Services (Non-Government Related)"
			2361 "Credit Unions"
			2370 "Leadership Development"
			2380 "Public Utilities"
			2390 "Consumer Protection, Safety"
			2399 "Public, Society Benefit - Multipurpose and Other N.E.C.", modify ;
		
		la def nteecodes
			// 24 -	Religion-Related, Spiritual Development 
			2401 "Alliance/Advocacy Organizations"
			2402 "Management & Technical Assistance"
			2403 "Professional Societies, Associations"
			2405 "Research Institutes and/or Public Policy Analysis"
			2411 "Single Organization Support"
			2412 "Fund Raising and/or Fund Distribution"
			2419 "Nonmonetary Support N.E.C."
			2420 "Christian"
			2421 "Protestant"
			2422 "Roman Catholic"
			2430 "Jewish"
			2440 "Islamic"
			2450 "Buddhist"
			2470 "Hindu"
			2480 "Religious Media, Communications Organizations" 
			2481 "Religious Film, Video"
			2482 "Religious Television"
			2483 "Religious Printing, Publishing"
			2484 "Religious Radio"
			2490 "Interfaith Issues"
			2499 "Religion Related, Spiritual Development N.E.C.", modify ;
		
		la def nteecodes
			// 25 -	Mutual/Membership Benefit Organizations, Other
			2501 "Alliance/Advocacy Organizations"
			2502 "Management & Technical Assistance"
			2503 "Professional Societies, Associations"
			2505 "Research Institutes and/or Public Policy Analysis"
			2511 "Single Organization Support"
			2512 "Fund Raising and/or Fund Distribution"
			2519 "Nonmonetary Support N.E.C."
			2520 "Insurance Providers, Services"
			2522 "Local Benevolent Life Insurance, Mutual Utilities, and Like"
			2523 "Mutual Insurance Company or Association"
			2524 "Supplemental Unemployment Compensation"
			2525 "State-Sponsored Worker's Compensation Reinsurance Organizations"
			2530 "Pension and Retirement Funds"
			2533 "Teachers Retirement Fund Association"
			2534 "Employee Funded Pension Trust"
			2535 "Multi-Employer Pension Plans"
			2540 "Fraternal Beneficiary Societies"
			2542 "Domestic Fraternal Societies"
			2543 "Voluntary Employees Beneficiary Associations (Non-Government)"
			2544 "Voluntary Employees Beneficiary Associations (Government)" 
			2550 "Cemeteries, Burial Services"
			2599 "Mutual/Membership Benefit Organizations, Other N.E.C.", modify ;
		
		la def nteecodes
			// 26 -	Unknown
			2699	"Unknown", modify ;
		
		#d cr
		
		tempvar nteelet nteenum
		qui: g `nteelet' = substr(nteecode,1,1)
		qui: g `nteenum' = substr(nteecode,2,2)	
		
		// NTEE Number Fix Changes Letter Characters in Number Positions to 0
		if "`nteenfix'" != "" {
			qui: replace `nteenum' = subinstr(`nteenum',"A","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"B","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"C","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"D","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"E","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"F","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"G","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"H","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"I","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"J","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"K","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"L","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"M","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"N","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"O","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"P","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"Q","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"R","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"S","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"T","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"U","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"V","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"W","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"X","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"Y","0",.)
			qui: replace `nteenum' = subinstr(`nteenum',"Z","0",.)
		}
	
		// Recoding NTEE Classification Codes to Numeric Based on Letter
		{
			qui: replace `nteelet' = "1" if `nteelet' == "A"
			qui: replace `nteelet' = "2" if `nteelet' == "B"
			qui: replace `nteelet' = "3" if `nteelet' == "C"
			qui: replace `nteelet' = "4" if `nteelet' == "D"
			qui: replace `nteelet' = "5" if `nteelet' == "E"
			qui: replace `nteelet' = "6" if `nteelet' == "F"
			qui: replace `nteelet' = "7" if `nteelet' == "G"
			qui: replace `nteelet' = "8" if `nteelet' == "H"
			qui: replace `nteelet' = "9" if `nteelet' == "I"
			qui: replace `nteelet' = "10" if `nteelet' == "J"
			qui: replace `nteelet' = "11" if `nteelet' == "K"
			qui: replace `nteelet' = "12" if `nteelet' == "L"
			qui: replace `nteelet' = "13" if `nteelet' == "M"
			qui: replace `nteelet' = "14" if `nteelet' == "N"
			qui: replace `nteelet' = "15" if `nteelet' == "O"
			qui: replace `nteelet' = "16" if `nteelet' == "P"
			qui: replace `nteelet' = "17" if `nteelet' == "Q"
			qui: replace `nteelet' = "18" if `nteelet' == "R"
			qui: replace `nteelet' = "19" if `nteelet' == "S"
			qui: replace `nteelet' = "20" if `nteelet' == "T"
			qui: replace `nteelet' = "21" if `nteelet' == "U"
			qui: replace `nteelet' = "22" if `nteelet' == "V"
			qui: replace `nteelet' = "23" if `nteelet' == "W"
			qui: replace `nteelet' = "24" if `nteelet' == "X"
			qui: replace `nteelet' = "25" if `nteelet' == "Y"
			qui: replace `nteelet' = "26" if `nteelet' == "Z"
		}
		
		qui: g nteecode2 = `nteelet' + `nteenum'
		
		/* 	This Block fixes some of the numeric activity codes by 
			reassigning values to unassigned values within the same series.     */
		qui: replace nteecode2 ="171" if nteecode=="A6A"
		qui: replace nteecode2 ="172" if nteecode=="A6B"
		qui: replace nteecode2 ="173" if nteecode=="A6C"
		qui: replace nteecode2 ="174" if nteecode=="A6E"
		qui: replace nteecode2 ="797" if nteecode=="G9B"
		qui: replace nteecode2 ="897" if nteecode=="H9B"
		qui: replace nteecode2 ="1459" if nteecode=="N6A"
		
		qui: destring `nteelet', replace
		qui: g nteeclass = `nteelet'
		qui: replace nteeclass = .n if nteeclass == .
		qui: replace nteecode2 = trim(nteecode2)
		qui: destring nteecode2, replace
	
		// Add value labels to recoded activity codes if option nteefix used
		if "`nteenfix'" != "" {
			la val nteecode2 nteecodes
			di as res "NTEE Codes (nteecode2) include value labels"
		}
		else {
			di as res "NTEE Codes contain alphanumeric data." _n "No value labels will be attached."
		}
		
		// Add variable labels to new NTEE variables
		la var nteeclass "NTEE Classification Code"
		la var nteecode2 "NTEE Activity Code (Numeric)"
		
		// Attach value labels to variables
		la val nteeclass nteeclass
		la val affiliation affcode
		la val deduct deductcd
		la val foundation foundcd
		la val assetcd incass
		la val incomecd incass
		la val status status
		la val orgcode orgtype
		la val filingreq filereq
		la val pffilingreq pfreq
		drop `nteelet' `nteenum' 
	
		// Save the data set
		qui: save `"`save'.dta"', `replace'
		
	// Bring back original data into memory
	restore
	
end

