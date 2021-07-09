/*	
	'GETDATA': module to import data
	Author: Duarte Goncalves (duarte.goncalves.dg@outlook.com)
	Last update: 24 March 2016
	Version 1.22
	
	This program uses the SDMX Connector for STATA, licensed to Banca d'Italia (Bank of Italy) under a European Union Public Licence
	(world-wide, royalty-free, non-exclusive, sub-licensable licence). 
	See https://github.com/amattioc/SDMX/wiki/SDMX-Connector-for-STATA and
	https://joinup.ec.europa.eu/sites/default/files/eupl1.1.-licence-en_0.pdf
	
	
	I dearly thank Attilio Mattiocco (Attilio.Mattiocco@bancaditalia.it) for all the help regarding the SDMX Connector for STATA
	and Bo Werth (Bo.WERTH@oecd.org) for additional clarifications.
*/






cap program drop getdata_imf_num
program getdata_imf_num
args geo2
version 13
replace `geo2'_num = 4 if `geo2' == "512"
replace `geo2'_num = 1 if `geo2' == "001"
replace `geo2'_num = 8 if `geo2' == "914"
replace `geo2'_num = 12 if `geo2' == "612"
replace `geo2'_num = 16 if `geo2' == "859"
replace `geo2'_num = 20 if `geo2' == "171"
replace `geo2'_num = 24 if `geo2' == "614"
replace `geo2'_num = 28 if `geo2' == "311"
replace `geo2'_num = 31 if `geo2' == "912"
replace `geo2'_num = 32 if `geo2' == "213"
replace `geo2'_num = 36 if `geo2' == "193"
replace `geo2'_num = 40 if `geo2' == "122"
replace `geo2'_num = 44 if `geo2' == "313"
replace `geo2'_num = 48 if `geo2' == "419"
replace `geo2'_num = 50 if `geo2' == "513"
replace `geo2'_num = 51 if `geo2' == "911"
replace `geo2'_num = 52 if `geo2' == "316"
replace `geo2'_num = 56 if `geo2' == "124"
replace `geo2'_num = 60 if `geo2' == "319"
replace `geo2'_num = 64 if `geo2' == "514"
replace `geo2'_num = 68 if `geo2' == "218"
replace `geo2'_num = 70 if `geo2' == "963"
replace `geo2'_num = 72 if `geo2' == "616"
replace `geo2'_num = 76 if `geo2' == "223"
replace `geo2'_num = 84 if `geo2' == "339"
replace `geo2'_num = 86 if `geo2' == "585"
replace `geo2'_num = 90 if `geo2' == "813"
replace `geo2'_num = 92 if `geo2' == "371"
replace `geo2'_num = 96 if `geo2' == "516"
replace `geo2'_num = 100 if `geo2' == "918"
replace `geo2'_num = 104 if `geo2' == "518"
replace `geo2'_num = 108 if `geo2' == "618"
replace `geo2'_num = 112 if `geo2' == "913"
replace `geo2'_num = 116 if `geo2' == "522"
replace `geo2'_num = 120 if `geo2' == "622"
replace `geo2'_num = 124 if `geo2' == "156"
replace `geo2'_num = 132 if `geo2' == "624"
replace `geo2'_num = 136 if `geo2' == "377"
replace `geo2'_num = 140 if `geo2' == "626"
replace `geo2'_num = 144 if `geo2' == "524"
replace `geo2'_num = 148 if `geo2' == "628"
replace `geo2'_num = 152 if `geo2' == "228"
replace `geo2'_num = 156 if `geo2' == "924"
replace `geo2'_num = 158 if `geo2' == "528"
replace `geo2'_num = 162 if `geo2' == "814"
replace `geo2'_num = 166 if `geo2' == "865"
replace `geo2'_num = 170 if `geo2' == "233"
replace `geo2'_num = 174 if `geo2' == "632"
replace `geo2'_num = 175 if `geo2' == "920"
replace `geo2'_num = 178 if `geo2' == "634"
replace `geo2'_num = 180 if `geo2' == "636"
replace `geo2'_num = 184 if `geo2' == "815"
replace `geo2'_num = 188 if `geo2' == "238"
replace `geo2'_num = 191 if `geo2' == "960"
replace `geo2'_num = 192 if `geo2' == "928"
replace `geo2'_num = 196 if `geo2' == "423"
replace `geo2'_num = 203 if `geo2' == "935"
replace `geo2'_num = 204 if `geo2' == "638"
replace `geo2'_num = 208 if `geo2' == "128"
replace `geo2'_num = 212 if `geo2' == "321"
replace `geo2'_num = 214 if `geo2' == "243"
replace `geo2'_num = 218 if `geo2' == "248"
replace `geo2'_num = 222 if `geo2' == "253"
replace `geo2'_num = 226 if `geo2' == "642"
replace `geo2'_num = 231 if `geo2' == "644"
replace `geo2'_num = 232 if `geo2' == "643"
replace `geo2'_num = 233 if `geo2' == "939"
replace `geo2'_num = 234 if `geo2' == "816"
replace `geo2'_num = 242 if `geo2' == "819"
replace `geo2'_num = 246 if `geo2' == "172"
replace `geo2'_num = 248 if `geo2' == "323"
replace `geo2'_num = 250 if `geo2' == "132"
replace `geo2'_num = 254 if `geo2' == "333"
replace `geo2'_num = 258 if `geo2' == "887"
replace `geo2'_num = 260 if `geo2' == "876"
replace `geo2'_num = 262 if `geo2' == "611"
replace `geo2'_num = 266 if `geo2' == "646"
replace `geo2'_num = 268 if `geo2' == "915"
replace `geo2'_num = 270 if `geo2' == "648"
replace `geo2'_num = 275 if `geo2' == "487"
replace `geo2'_num = 276 if `geo2' == "134"
replace `geo2'_num = 288 if `geo2' == "652"
replace `geo2'_num = 292 if `geo2' == "823"
replace `geo2'_num = 296 if `geo2' == "826"
replace `geo2'_num = 300 if `geo2' == "174"
replace `geo2'_num = 304 if `geo2' == "326"
replace `geo2'_num = 308 if `geo2' == "328"
replace `geo2'_num = 312 if `geo2' == "329"
replace `geo2'_num = 316 if `geo2' == "829"
replace `geo2'_num = 320 if `geo2' == "258"
replace `geo2'_num = 324 if `geo2' == "656"
replace `geo2'_num = 328 if `geo2' == "336"
replace `geo2'_num = 332 if `geo2' == "263"
replace `geo2'_num = 336 if `geo2' == "187"
replace `geo2'_num = 340 if `geo2' == "268"
replace `geo2'_num = 344 if `geo2' == "532"
replace `geo2'_num = 348 if `geo2' == "944"
replace `geo2'_num = 352 if `geo2' == "176"
replace `geo2'_num = 356 if `geo2' == "534"
replace `geo2'_num = 360 if `geo2' == "536"
replace `geo2'_num = 364 if `geo2' == "429"
replace `geo2'_num = 368 if `geo2' == "433"
replace `geo2'_num = 372 if `geo2' == "178"
replace `geo2'_num = 376 if `geo2' == "436"
replace `geo2'_num = 380 if `geo2' == "136"
replace `geo2'_num = 384 if `geo2' == "662"
replace `geo2'_num = 388 if `geo2' == "343"
replace `geo2'_num = 392 if `geo2' == "158"
replace `geo2'_num = 398 if `geo2' == "916"
replace `geo2'_num = 400 if `geo2' == "439"
replace `geo2'_num = 404 if `geo2' == "664"
replace `geo2'_num = 408 if `geo2' == "954"
replace `geo2'_num = 410 if `geo2' == "542"
replace `geo2'_num = 414 if `geo2' == "443"
replace `geo2'_num = 417 if `geo2' == "917"
replace `geo2'_num = 418 if `geo2' == "544"
replace `geo2'_num = 422 if `geo2' == "446"
replace `geo2'_num = 426 if `geo2' == "666"
replace `geo2'_num = 428 if `geo2' == "941"
replace `geo2'_num = 430 if `geo2' == "668"
replace `geo2'_num = 434 if `geo2' == "672"
replace `geo2'_num = 438 if `geo2' == "147"
replace `geo2'_num = 440 if `geo2' == "946"
replace `geo2'_num = 442 if `geo2' == "137"
replace `geo2'_num = 446 if `geo2' == "546"
replace `geo2'_num = 450 if `geo2' == "674"
replace `geo2'_num = 454 if `geo2' == "676"
replace `geo2'_num = 458 if `geo2' == "548"
replace `geo2'_num = 462 if `geo2' == "556"
replace `geo2'_num = 466 if `geo2' == "678"
replace `geo2'_num = 470 if `geo2' == "181"
replace `geo2'_num = 474 if `geo2' == "349"
replace `geo2'_num = 478 if `geo2' == "682"
replace `geo2'_num = 480 if `geo2' == "684"
replace `geo2'_num = 484 if `geo2' == "273"
replace `geo2'_num = 492 if `geo2' == "183"
replace `geo2'_num = 496 if `geo2' == "948"
replace `geo2'_num = 498 if `geo2' == "921"
replace `geo2'_num = 499 if `geo2' == "943"
replace `geo2'_num = 500 if `geo2' == "351"
replace `geo2'_num = 504 if `geo2' == "686"
replace `geo2'_num = 508 if `geo2' == "688"
replace `geo2'_num = 512 if `geo2' == "449"
replace `geo2'_num = 516 if `geo2' == "728"
replace `geo2'_num = 520 if `geo2' == "836"
replace `geo2'_num = 524 if `geo2' == "558"
replace `geo2'_num = 528 if `geo2' == "138"
replace `geo2'_num = 531 if `geo2' == "354"
replace `geo2'_num = 533 if `geo2' == "314"
replace `geo2'_num = 534 if `geo2' == "352"
replace `geo2'_num = 535 if `geo2' == "357"
replace `geo2'_num = 540 if `geo2' == "839"
replace `geo2'_num = 548 if `geo2' == "846"
replace `geo2'_num = 554 if `geo2' == "196"
replace `geo2'_num = 558 if `geo2' == "278"
replace `geo2'_num = 562 if `geo2' == "692"
replace `geo2'_num = 566 if `geo2' == "694"
replace `geo2'_num = 570 if `geo2' == "851"
replace `geo2'_num = 574 if `geo2' == "849"
replace `geo2'_num = 578 if `geo2' == "142"
replace `geo2'_num = 583 if `geo2' == "868"
replace `geo2'_num = 584 if `geo2' == "867"
replace `geo2'_num = 585 if `geo2' == "565"
replace `geo2'_num = 586 if `geo2' == "564"
replace `geo2'_num = 591 if `geo2' == "283"
replace `geo2'_num = 598 if `geo2' == "853"
replace `geo2'_num = 600 if `geo2' == "288"
replace `geo2'_num = 604 if `geo2' == "293"
replace `geo2'_num = 608 if `geo2' == "566"
replace `geo2'_num = 612 if `geo2' == "863"
replace `geo2'_num = 616 if `geo2' == "964"
replace `geo2'_num = 620 if `geo2' == "182"
replace `geo2'_num = 624 if `geo2' == "654"
replace `geo2'_num = 626 if `geo2' == "537"
replace `geo2'_num = 630 if `geo2' == "359"
replace `geo2'_num = 634 if `geo2' == "453"
replace `geo2'_num = 638 if `geo2' == "696"
replace `geo2'_num = 642 if `geo2' == "968"
replace `geo2'_num = 643 if `geo2' == "922"
replace `geo2'_num = 646 if `geo2' == "714"
replace `geo2'_num = 654 if `geo2' == "865"
replace `geo2'_num = 659 if `geo2' == "361"
replace `geo2'_num = 660 if `geo2' == "312"
replace `geo2'_num = 662 if `geo2' == "362"
replace `geo2'_num = 666 if `geo2' == "363"
replace `geo2'_num = 670 if `geo2' == "364"
replace `geo2'_num = 674 if `geo2' == "135"
replace `geo2'_num = 678 if `geo2' == "716"
replace `geo2'_num = 682 if `geo2' == "456"
replace `geo2'_num = 686 if `geo2' == "722"
replace `geo2'_num = 688 if `geo2' == "942"
replace `geo2'_num = 690 if `geo2' == "718"
replace `geo2'_num = 694 if `geo2' == "724"
replace `geo2'_num = 702 if `geo2' == "576"
replace `geo2'_num = 703 if `geo2' == "936"
replace `geo2'_num = 704 if `geo2' == "582"
replace `geo2'_num = 705 if `geo2' == "961"
replace `geo2'_num = 706 if `geo2' == "726"
replace `geo2'_num = 710 if `geo2' == "199"
replace `geo2'_num = 716 if `geo2' == "698"
replace `geo2'_num = 724 if `geo2' == "184"
replace `geo2'_num = 728 if `geo2' == "733"
replace `geo2'_num = 729 if `geo2' == "732"
replace `geo2'_num = 732 if `geo2' == "793"
replace `geo2'_num = 740 if `geo2' == "366"
replace `geo2'_num = 748 if `geo2' == "734"
replace `geo2'_num = 752 if `geo2' == "144"
replace `geo2'_num = 756 if `geo2' == "146"
replace `geo2'_num = 760 if `geo2' == "463"
replace `geo2'_num = 762 if `geo2' == "923"
replace `geo2'_num = 764 if `geo2' == "578"
replace `geo2'_num = 768 if `geo2' == "742"
replace `geo2'_num = 772 if `geo2' == "818"
replace `geo2'_num = 776 if `geo2' == "866"
replace `geo2'_num = 780 if `geo2' == "369"
replace `geo2'_num = 784 if `geo2' == "466"
replace `geo2'_num = 788 if `geo2' == "744"
replace `geo2'_num = 792 if `geo2' == "186"
replace `geo2'_num = 795 if `geo2' == "925"
replace `geo2'_num = 796 if `geo2' == "381"
replace `geo2'_num = 798 if `geo2' == "869"
replace `geo2'_num = 800 if `geo2' == "746"
replace `geo2'_num = 804 if `geo2' == "926"
replace `geo2'_num = 807 if `geo2' == "962"
replace `geo2'_num = 818 if `geo2' == "469"
replace `geo2'_num = 826 if `geo2' == "112"
replace `geo2'_num = 831 if `geo2' == "113"
replace `geo2'_num = 832 if `geo2' == "117"
replace `geo2'_num = 833 if `geo2' == "118"
replace `geo2'_num = 834 if `geo2' == "738"
replace `geo2'_num = 840 if `geo2' == "111"
replace `geo2'_num = 850 if `geo2' == "373"
replace `geo2'_num = 854 if `geo2' == "748"
replace `geo2'_num = 858 if `geo2' == "298"
replace `geo2'_num = 860 if `geo2' == "927"
replace `geo2'_num = 862 if `geo2' == "299"
replace `geo2'_num = 876 if `geo2' == "857"
replace `geo2'_num = 882 if `geo2' == "862"
replace `geo2'_num = 887 if `geo2' == "474"
replace `geo2'_num = 894 if `geo2' == "754"
replace `geo2'_num = 1200 if `geo2' == "934"
replace `geo2'_num = 2100 if `geo2' == "998"
replace `geo2'_num = 2150 if `geo2' == "163"
replace `geo2'_num = 2301 if `geo2' == "110"
replace `geo2'_num = 2302 if `geo2' == "148"
replace `geo2'_num = 2303 if `geo2' == "512"
replace `geo2'_num = 2304 if `geo2' == "010"
replace `geo2'_num = 2305 if `geo2' == "050"
replace `geo2'_num = 2306 if `geo2' == "758"
replace `geo2'_num = 2307 if `geo2' == "904"
replace `geo2'_num = 2308 if `geo2' == "901"
replace `geo2'_num = 2309 if `geo2' == "762"
replace `geo2'_num = 2310 if `geo2' == "355"
replace `geo2'_num = 2311 if `geo2' == "505"
replace `geo2'_num = 2312 if `geo2' == "200"
replace `geo2'_num = 2313 if `geo2' == "903"
replace `geo2'_num = 2314 if `geo2' == "503"
replace `geo2'_num = 2315 if `geo2' == "149"
replace `geo2'_num = 2316 if `geo2' == "EMEUR"
replace `geo2'_num = 2317 if `geo2' == "035"
replace `geo2'_num = 2318 if `geo2' == "EMFLAT"
replace `geo2'_num = 2319 if `geo2' == "EMMENA"
replace `geo2'_num = 2320 if `geo2' == "EMMENAP"
replace `geo2'_num = 2321 if `geo2' == "168"
replace `geo2'_num = 2322 if `geo2' == "080"
replace `geo2'_num = 2323 if `geo2' == "092"
replace `geo2'_num = 2324 if `geo2' == "120"
replace `geo2'_num = 2325 if `geo2' == "119"
replace `geo2'_num = 2326 if `geo2' == "IIO"
replace `geo2'_num = 2327 if `geo2' == "093"
replace `geo2'_num = 2328 if `geo2' == "091"
replace `geo2'_num = 2329 if `geo2' == "967"
replace `geo2'_num = 2330 if `geo2' == "230"
replace `geo2'_num = 2331 if `geo2' == "229"
replace `geo2'_num = 2332 if `geo2' == "231"
replace `geo2'_num = 2333 if `geo2' == "235"
replace `geo2'_num = 2334 if `geo2' == "234"
replace `geo2'_num = 2335 if `geo2' == "232"
replace `geo2'_num = 2336 if `geo2' == "405"
replace `geo2'_num = 2337 if `geo2' == "440"
replace `geo2'_num = 2338 if `geo2' == "406"
replace `geo2'_num = 2339 if `geo2' == "353"
replace `geo2'_num = 2340 if `geo2' == "641"
replace `geo2'_num = 2341 if `geo2' == "225"
replace `geo2'_num = 2342 if `geo2' == "226"
replace `geo2'_num = 2343 if `geo2' == "837"
replace `geo2'_num = 2344 if `geo2' == "983"
replace `geo2'_num = 2345 if `geo2' == "982"
replace `geo2'_num = 2346 if `geo2' == "910"
replace `geo2'_num = 2347 if `geo2' == "972"
replace `geo2'_num = 2348 if `geo2' == "454"
replace `geo2'_num = 2349 if `geo2' == "Countries"
replace `geo2'_num = 2350 if `geo2' == "Regions and Groups"
replace `geo2'_num = 2351 if `geo2' == "608"
replace `geo2'_num = 2352 if `geo2' == "965"
replace `geo2'_num = 2353 if `geo2' == "227"
replace `geo2'_num = 2354 if `geo2' == "757"
replace `geo2'_num = 2355 if `geo2' == "763"
replace `geo2'_num = 2356 if `geo2' == "860"
replace `geo2'_num = 2357 if `geo2' == "721"
replace `geo2'_num = 2358 if `geo2' == "715"
replace `geo2'_num = 2359 if `geo2' == "704"
replace `geo2'_num = 2360 if `geo2' == "651"
replace `geo2'_num = 2361 if `geo2' == "702"
replace `geo2'_num = 2362 if `geo2' == "703"
replace `geo2'_num = 2363 if `geo2' == "048"
replace `geo2'_num = 2364 if `geo2' == "699"
replace `geo2'_num = 2365 if `geo2' == "700"
replace `geo2'_num = 2366 if `geo2' == "697"
replace `geo2'_num = 2367 if `geo2' == "650"
replace `geo2'_num = 2368 if `geo2' == "603"
replace `geo2'_num = 2369 if `geo2' == "653"
replace `geo2'_num = 2370 if `geo2' == "617"
replace `geo2'_num = 2371 if `geo2' == "604"
replace `geo2'_num = 2372 if `geo2' == "649"
replace `geo2'_num = 2373 if `geo2' == "602"
replace `geo2'_num = 2374 if `geo2' == "932"
replace `geo2'_num = 2375 if `geo2' == "877"
replace `geo2'_num = 2376 if `geo2' == "759"
replace `geo2'_num = 2377 if `geo2' == "205"
replace `geo2'_num = 2378 if `geo2' == "123"
replace `geo2'_num = 2379 if `geo2' == "511"
replace `geo2'_num = 2380 if `geo2' == "92011"
replace `geo2'_num = 2381 if `geo2' == "9202"
replace `geo2'_num = 2382 if `geo2' == "92031"
replace `geo2'_num = 2383 if `geo2' == "92041"
replace `geo2'_num = 2384 if `geo2' == "92051"
replace `geo2'_num = 2385 if `geo2' == "94051"
replace `geo2'_num = 2386 if `geo2' == "9502"
replace `geo2'_num = 2387 if `geo2' == "95031"
replace `geo2'_num = 2388 if `geo2' == "95041"
replace `geo2'_num = 2389 if `geo2' == "95051"
replace `geo2'_num = 2390 if `geo2' == "95071"
replace `geo2'_num = 2391 if `geo2' == "95091"
replace `geo2'_num = 2392 if `geo2' == "9602"
replace `geo2'_num = 2393 if `geo2' == "96031"
replace `geo2'_num = 2394 if `geo2' == "96051"
replace `geo2'_num = 2395 if `geo2' == "99011"
replace `geo2'_num = 2396 if `geo2' == "99021"
replace `geo2'_num = 2397 if `geo2' == "99031"
replace `geo2'_num = 2398 if `geo2' == "99051"




label def country_iso_num 2301 "Advanced Economies", modify
label def country_iso_num 2302 "Advanced Economies G20", modify
label def country_iso_num 2303 "Africa", modify
label def country_iso_num 2304 "All Countries", modify
label def country_iso_num 2305 "APEC", modify
label def country_iso_num 2306 "CEMAC", modify
label def country_iso_num 2307 "Central and Eastern Euro", modify
label def country_iso_num 2308 "CIS", modify
label def country_iso_num 2309 "COMESA", modify
label def country_iso_num 2310 "Curacao and St. Maarten", modify
label def country_iso_num 2311 "Emerging and Developing Asia", modify
label def country_iso_num 2312 "Emerging and Developing Countries", modify
label def country_iso_num 2313 "Emerging and Developing Europe", modify
label def country_iso_num 2314 "Emerging Asia", modify
label def country_iso_num 2315 "Emerging Economies G20", modify
label def country_iso_num 2316 "Emerging Europe", modify
label def country_iso_num 2317 "Emerging Market and Middle Income Economies", modify
label def country_iso_num 2318 "Emerging Market Latin America", modify
label def country_iso_num 2319 "Emerging Market Middle East and North Africa", modify
label def country_iso_num 2320 "Emerging Market Middle East and North Africa and Pakistan", modify
label def country_iso_num 2321 "European Central Bank", modify
label def country_iso_num 2322 "Export earnings: fuel", modify
label def country_iso_num 2323 "Export earnings: nonfuel", modify
label def country_iso_num 2324 "G20", modify
label def country_iso_num 2325 "G7", modify
label def country_iso_num 2326 "Institutions and International Organizations", modify
label def country_iso_num 2327 "International Organization + SEFER", modify
label def country_iso_num 2328 "International Organizations", modify
label def country_iso_num 2329 "Kosovo", modify
label def country_iso_num 2330 "Low-Income Asia", modify
label def country_iso_num 2331 "Low-Income Developing Countries", modify
label def country_iso_num 2332 "Low-Income Latin America", modify
label def country_iso_num 2333 "Low-Income Oil Producers", modify
label def country_iso_num 2334 "Low-Income Others", modify
label def country_iso_num 2335 "Low-Income Sub-Saharan Africa", modify
label def country_iso_num 2336 "Middle East", modify
label def country_iso_num 2337 "Middle East, North Africa, Afghanistan, and Pakistan", modify
label def country_iso_num 2338 "Middle East and North Africa", modify
label def country_iso_num 2339 "Netherlands Antilles", modify
label def country_iso_num 2340 "North Africa (CDIS)", modify
label def country_iso_num 2341 "North America (CDIS)", modify
label def country_iso_num 2342 "North Atlantic and Caribbean", modify
label def country_iso_num 2343 "Oceania and Polar Regions (CDIS)", modify
label def country_iso_num 2344 "Other Countries, not specified", modify
label def country_iso_num 2345 "Other Countries Confidential", modify
label def country_iso_num 2346 "Other Countries n.i.e.", modify
label def country_iso_num 2347 "Other European Economies (CDIS)", modify
label def country_iso_num 2348 "Other Near and Middle East Economies (CDIS)", modify
label def country_iso_num 2349 "COU", modify
label def country_iso_num 2350 "GRP", modify
label def country_iso_num 2351 "SACCA excluding South Africa", modify
label def country_iso_num 2352 "Serbia and Montenegro", modify
label def country_iso_num 2353 "South America (CDIS)", modify
label def country_iso_num 2354 "SACU", modify
label def country_iso_num 2355 "SADC", modify
label def country_iso_num 2356 "SSA fixed exchange rate regime countries", modify
label def country_iso_num 2357 "SSA floating exchange rate regime countries", modify
label def country_iso_num 2358 "SSA fragile countries", modify
label def country_iso_num 2359 "SSA low-income countries", modify
label def country_iso_num 2360 "SSA low-income countries excluding fragile countries", modify
label def country_iso_num 2361 "SSA middle-income countries", modify
label def country_iso_num 2362 "SSA middle-incomes countries excluding South Africa", modify
label def country_iso_num 2363 "SSA Multilateral Debt Relief Initiative Countries", modify
label def country_iso_num 2364 "SSA oil-exporting countries", modify
label def country_iso_num 2365 "SSA oil-exporting countries excluding Nigeria", modify
label def country_iso_num 2366 "SSA oil-importing countries", modify
label def country_iso_num 2367 "SSA oil-importing countries excluding South Africa", modify
label def country_iso_num 2368 "Sub-Saharan Africa", modify
label def country_iso_num 2369 "Sub-Saharan Africa (CDIS)", modify
label def country_iso_num 2370 "Sub-Saharan Africa excluding Nigeria, South Africa and Zimbabwe", modify
label def country_iso_num 2371 "Sub-Saharan Africa excluding Nigeria and South Africa", modify
label def country_iso_num 2372 "Sub-Saharan Africa excluding South Sudan", modify
label def country_iso_num 2373 "Sub-Saharan Africa excluding Zimbabwe", modify
label def country_iso_num 2374 "Unspecified", modify
label def country_iso_num 2375 "US Possession in Oceania", modify
label def country_iso_num 2376 "WAEMU", modify
label def country_iso_num 2377 "Western Hemisphere", modify
label def country_iso_num 2378 "Other advanced economies", modify
label def country_iso_num 2379 "ASEAN-5", modify
label def country_iso_num 2380 "Caribbean (Region)", modify
label def country_iso_num 2381 "Central America (Region)", modify
label def country_iso_num 2382 "North America (Region)", modify
label def country_iso_num 2383 "South America (Region)", modify
label def country_iso_num 2384 "Western Hemisphere (Region)", modify
label def country_iso_num 2385 "Middle East (Region)", modify
label def country_iso_num 2386 "South Asia (Region)", modify
label def country_iso_num 2387 "Australia and New Zealand (Region)", modify
label def country_iso_num 2388 "Pacific Islands (Region)", modify
label def country_iso_num 2389 "Asia and Pacific (Region)", modify
label def country_iso_num 2390 "Southeast Asia (Region)", modify
label def country_iso_num 2391 "East Asia (Region)", modify
label def country_iso_num 2392 "North Africa (Region)", modify
label def country_iso_num 2393 "Sub-Saharan Africa (Region)", modify
label def country_iso_num 2394 "Africa (Region)", modify
label def country_iso_num 2395 "Central Asia and the Caucasus (Region)", modify
label def country_iso_num 2396 "Eastern Europe (Region)", modify
label def country_iso_num 2397 "Western Europe (Region)", modify
label def country_iso_num 2398 "Europe (Region)", modify



end
