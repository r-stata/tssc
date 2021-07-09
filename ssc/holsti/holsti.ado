* ==========================================================
* holsti: compute Holsti intercoder reliability coefficient
* Version 1.1.1, 2015-01-14
* (Version 1.0.0 corresponds to 2013-12-09)
* ==========================================================
*! version 1.1.1, Alexander Staudt, Mona Krewel, Julia Partheymueller, 14jan2015

*mata mata clear
*program drop _all
program define holsti
	version 11.2
	syntax anything(name=var) [if] [in], [GENerate(string)]
	
	set more off
	preserve
	
	* select variables for which coefficients shall be calculated
	mark touse `if' `in'
	
	mata lfdn() // 

	quietly keep if touse==1 // behalte nur die Beobachtungen, die betrachtet werden sollen
	quietly tab touse

	mata: lfdn = st_data(., "$lfdn_1") // lfdn: Vektor mit denjenigen Beobachtungen, die betrachtet werden
	mata: st_global("lfdn_1", "") // lösche lfdn_1, da es nicht mehr benötigt wird
	mata: st_matrix("lfdn", lfdn) // speichere lfdn zur weiteren Verwendung in Stata
	scalar units = `r(N)'

	if `r(N)' == 0 { // prüfe, ob durch Auswahl mit [if] und [in] überhaupt Beobachtungen vorliegen
		mata: _error(111, "the data you selected does not contain any observation")
	} 
	else {
		mata nocid() // erzeuge Variable, die die Zeilennummern jeder Beobachtung enthält
		mata auswahl("`var'") // erstelle Variablenliste, die die zu betrachtenden Variablen/Kodierer enthält
		keep `r(varlist)' // behalte zu beobachtende Variablen/Kodierer
		
		capture confirm numeric variable `r(varlist)' // prüfe, ob Variablen in der Variablenliste numerisch oder string sind.
		scalar rc = _rc
		mata abweichungen() // erstelle Variable, die die Kodierabweichungen für jede Beobachtung enthält
		
		foreach x in `r(varlist)' {
			local i = `i' + 1
			quietly gen coder_`i' = `x'
		}
		* create variables for each pair of coders containing coincident ratings
		foreach num1 of numlist 1/`=ncoder' {
			foreach num2 of numlist 1/`=ncoder' {
			quietly gen uepaar_`num1'_`num2' = 1 if (coder_`num1' == coder_`num2')
			quietly replace uepaar_`num1'_`num2' = 0 if (coder_`num1' != coder_`num2')
			quietly label var uepaar_`num1'_`num2' "Übereinstimmung: Coder `num1' / Coder `num2'"
			}
		}
		quietly describe uepaar_*, varlist //"`var'"
		* drop all variables except those containing coincident ratings
		keep `r(varlist)'
		* compute Holsti coefficients
		mata holsti("`var'")			
		restore
		local x = "`generate'"
		if (length("`x'")>0) { // schreibe Abweichungen in die in gen(var) definierte Variable
			mata: diff("`generate'")
		}

		mata: ncoder = st_numscalar("ncoder")
		mata: st_numscalar("r(coder)", ncoder)
		mata: units = st_numscalar("units")
		mata: st_numscalar("r(units)", units)
		mata: varnames = st_global("varnames")
		mata: st_global("r(varnames)", varnames)
		mata: varcoder = st_global("varcoder")
		mata: st_global("r(varcoder)", varcoder)
		
		* show results
		display as txt
		display as txt " Variable/Coders " as result "`var'" // alternativ "$varnames"
		display as txt
		display as txt " Results"
		display as txt "{hline 19}"
		display as txt "    Units " _col(13) as result `r(units)'
		display as txt "    Rater " _col(13) as result `r(coder)'
		display as txt "   Holsti " _col(12) as result round(`r(holsti)', 0.001)	
		display as txt "{hline 19}"
		
		scalar drop _all
		matrix drop _all
		macro drop varnames diff cid
		mata mata drop lfdn ncoder units
	}
end
	
mata:
function holsti(string scalar var)
	{ // define function that will compute Holsti coefficients
	var = var
	// get number of coders
	ncoder = st_numscalar("ncoder")
	// load vectors of pairwise coincidence between coders
	x = st_data(., .)
	// count coincident ratings (numerator)
	rn = colsum(x)*2
	crn = rowshape(rn, ncoder)
	if (rows(crn)==1) _error(102, "only one coder specified: intercoder reliabilitiy cannot be calculated.")
	// count total ratings (denominator)
	rd = colnonmissing(x)*2
	crd = rowshape(rd, ncoder)
	// pairwise Holsti coefficients
	pwh = crn:/crd
	// overall Holsti coefficient
	d = diag(vec(pwh))
	sum = (trace(d)-trace(pwh))/2
	holsti = sum/(ncoder*(ncoder-1)/2)
	// save results to stata
	st_rclear()
	st_matrix("r(numerator)", crn)
	st_matrix("r(denominator)", crd)
	st_matrix("r(pw_holsti)", pwh)
	st_numscalar("r(holsti)", holsti)
	}

// Funktion zur Auswahl der zu verwendenden Variablen
function auswahl(string scalar x)
{
	if (regexm(x,"\*$")==1) // prüfe, ob "*" im Variablennamen angegeben ist
	{
		_error(198, "* invalid name") // falls ja, gebe Fehlermeldung aus
	} else { // ansonsten
	st_global("varcoder", x)
	list = tokens(x) // erzeuge Zeilenvektor list, der die in "var" angegebenen Variablen enthält (gilt besonders, wenn stubs genannt werden
	rc = _stata("quietly describe *"+x+", varlist", 1) // zeige alle Variablen an, die auf einen bestimmten stub enden
	varnames = st_global("r(varlist)")
	st_global("varnames", varnames) // Variablenliste in Stata als globales Macro speichern
	vars = tokens(varnames) // schreibe Variablennamen, die stubs enthalten, in Zeilenvektor vars
	varlist = invtokens(vars)
	ncoder = length(vars) // ermittle Anzahl der Variablen (entspricht aufgrund der Struktur des Datensatzes der Anzahl der Kodierer)
	st_numscalar("coder", ncoder)
	if (length(list)==0) // falls Länge = 0, das heißt keine Angabe zu den zu beobachtenden Variablen gemacht wurde
	{
		exit(error(111)) // gebe Fehlermeldung aus
	}
	else
	{
		st_numscalar("ncoder", ncoder) // ansonsten: gebe Anzahl an Kodierern aus
	}
	}
}

// Vorbereitungen für Funktion diff()
function lfdn()
{
	rc = _stata("quietly describe lfdn*, varlist", 1) // zeige alle Variablen an, die lfdn heißen oder mit lfdn anfangen, und speichere sie in mittels describe in r(varlist). Existiert lfdn nicht, erzeuge lfdnn_1
	if (rc==0) 
	{
		varlist = st_global("r(varlist)") // verwende Inhalt von r(varlist)
		v = tokens(varlist) // zerlege Varlist in einzelne Variablennamen; diese schreibe ich in einen Zeilenvektor
		lv = length(v) // ermittle Anzahl der Variablen, die mit lfdn anfangen (Länge des Zeilenvektors)
		lfdn_1 = v[1,lv]+"_1" // erzeuge eindeutige lfdn-Variable (betrachte gesamte Variablenliste. Eindeutige Variable entspricht Namen der letzten Variable, mit angefügtem "_1" 
		st_global("lfdn_1", lfdn_1) // speichere neu erstellten Variablennamen in lfdn_1 zur weiteren Verwendung in Stata
	} 
	else 
	{
	lfdn_1= "lfdn" // erzeuge lfdn_1
	st_global("lfdn_1", lfdn_1) // speichere neu erstellten Variablennamen in lfdn_1 zur weiteren Verwendung in Stata (siehe Funktion "diff()")
	}
	y = st_data(., 1) // importiere 1. Spalte des Datensatzes in Mata
	ly = length(y) // ermittle Länge des Vektors
	n = (1::ly) // n: Spaltenvektor, der Beobachtungszahl für jede Beobachtung im Datensatz enthält
	lfdn = st_addvar("int", lfdn_1) // erzeuge Variable, die laufende Nummer der Beobachtungen im Datensatz enthält (Variable wird in anderen Mata-Funktionen verwendet)
	st_store(., lfdn, n)
	st_matrix("n", n) // speichere n zur weiteren Verwendung in Stata
}

	
// ermitteln der Anzahl abweichender Kodierungen
// Prinzip: Ermitteln aller unterschiedlichen Kodierungen je Beobachtung.
// Zählen der Beobachtungen. Die häufigste Beobachtung gilt als Norm.
// Alle davon abweichenden Kodierungen gelten als Abweichung.
function abweichungen()
{
	cid = st_matrix("cid") // importiere durchnummerierten Spaltenvektor
	ncoder = st_numscalar("ncoder") // importiere Anzahl der Kodierer
	rc = st_numscalar("rc") // importiere Returncode für den Test, ob Variable numerisch ist oder string
	stata("scalar drop rc") // lösche Returncode in Stata
	if (rc==0) { // falls Returncode = 0 (Variable numerisch)
		y = st_data(., .) // importiere numerische Daten
	} else { // ansonsten
		y = st_sdata(., .) // importiere string-Daten
	}
	y1 = y'	// transponiere importierte Daten: die in einer Zeile enthaltenen Werte sind alle "möglichen Kodierungen"
	diff = J(1, cols(y1), .) // erzeuge Matrix diff  mit einer Zeile und so vielen Spalten, wie in y1 enthalten sind
	for (k=1;k<=cols(y1);k++) // solange k kleiner oder gleich der Spaltenanzahl von y1 ist
	{
		obs = y1[., k] // obs: Spalte k aus Matrix y1 (Spalte 1 bis k)
		levels = uniqrows(obs)' // levels: enthält diejenigen Zeilen von obs, die in der Matrix jeweils nur ein mal vorkommen. Schreibe Ergebnis ins Zeilenvektor "levels"
		countlevels = J(1, length(levels), .) // countlevels: Zeilenvektor (Matrix mit einer Zeile) der Länge von "levels", gefüllt mit missings
		for (j=1;j<=length(levels);j++) // solange j kleiner oder gleich die Länge des Vektors "levels"...
		{
			levels1 = select(obs, obs[., 1]:==levels[., j]) // erzeuge "levels1": dieses enthält die Werte von "obs", die dem Wert der j-ten Spalte von "levels" entsprechen.
			// levels1 enthält nur Werte von einer Sorte
			lev = length(levels1) // lev: Länge des Vektors "levels1". Zähle Anzahl jeder Kodierung
			countlevels[., j] = lev // schreibe in die j-te Spalte von "countlevels" den Wert der Länge von "levels1". Gibt für jede Kodierung die Anzahl an, mit der diese kodiert wurde
		}
		if (rc==0) { // falls Returncode gleich 0 (Variable numerisch)
			countlevels2 = (levels\countlevels) // countlevels2: enthält in der ersten Zeile die unterschiedlichen Kodierungen, in der zweiten Zeilen deren Häufigkeiten
			i = .
			w = .
			maxindex(countlevels2[2, .], 1, i, w) // ermittle in der zweiten Zeile von countlevels2 die Spalte, in der die meisten Kodierungen für eine Beobachtung enthalten sind
			i = i[1, 1]
			normlevels = levels[., i] // wähle die häufigste Kodierung als Norm
			nnormlevel = countlevels2[2, i] // schreibe die Anzahl der häufigsten Kodierung in "normlevel"
		} else 
{ // das gleiche wie eben, nur für string-Variablen
			countlevels2 = (levels\strofreal(countlevels))
			i = .
			w = .
			maxindex(strtoreal(countlevels2[2, .]), 1, i, w)
			i = i[1, 1]
			normlevel = levels[., i]
			nnormlevel = strtoreal(countlevels2[2, i])
		}
		diff[., k] = length(obs)-nnormlevel // alle Kodierungen, die ungleich der Norm sind, gelten als Abweichung: 
		// Anzahl der Kodierungen entspricht Anzahl aller Kodierungen minus Anzahl der häufigsten Kodierung.
	} 
	st_matrix("diff_1", diff) // speichere diff als Macro in Stata
	diff1 = (cid'\diff)
	diff2 = select(diff1, diff1[2, .]:!=0)'
	if (length(diff2)!=0)
	{
		diff3 = round(diff2[., 2]/(ncoder-1), 0.01)
		diff4 = (diff2, diff3)
		st_matrix("diff", diff4)
	}
}

function cid(string scalar id)
{
	cid = st_data(., id)
	st_matrix("cid", cid)
}
// ermmittelt Anzahl an Zeilen (Beobachtungen) im Datensatz
function nocid()
{	
	y = st_data(., 1) // y entspricht der 1. Spalte im Datensatz
	cid = J(rows(y), 1, .) // Erzeuge Matrix cid mit so viele Zeilen, wie in y enthalten sind und einer Spalte. Matrix ist mit missings gefüllt
	for (i=1;i<=rows(y);i++) // Zähle Zeilen durch, von 1 bis zur maximalen Anzahl an Zeilen
	{
		cid[i, 1] = i
	}
	st_matrix("cid", cid) // exportiere Matrix cid in Stata
}


// schreibt Übereinstimmungen in Variable
function diff(string scalar name)
{
	lfdn = st_matrix("lfdn") // lfdn: diejenigen Beobachtungen, die für die Analyse verwendet wurden
	st_global("lfdn", "") // lösche Matrix aus Stata-Speicher
	n = st_matrix("n") // n: Gesamtanzahl an Beobachtungen
	st_global("n", "") // lösche Matrix aus Stata-Speicher
	var = J(1, length(n), .) // var: Vektor, der so viele Einträge hat, wie es es Beobachtungen gibt (alle Anfangs missing)
	diff = st_matrix("diff_1") // diff: Abweichungsvektor
	var[1, lfdn] = diff // ersetze die Beobachtungen in var, für die Werte im Abweichungsvektor enthalten (und die auch Untersucht wurden)
	idx = st_addvar("int", name) // füge dem Datensatz neue Variable hinzu
	st_store(., idx, var') // speichere den Vektor, der die Abweichungen für die untersuchten Beobachtungen hat, in neue Variable. Für die nicht untersuchten Beobachtungen wird missing gesetzt
}
end

