*! version 1.2.1  20jul2021
program def pyconvertu
	version 16.0
	/*
		By default, this small program converts country names (in English) to
		ISO 3166-1 codes (alpha-2, alpha-3, and numeric) and to full names
		in English and French using regular expressions with Unicode support.
		The from() option allows the user to import an external JSON file as
		a dictionary to replace the default classification.
		The JSON file can be created from data in memory, provided they include
		headings "Data", "Metadata" and "Sources" in the first variable,
		immediately followed by content. The template JSON file structure is
		the following ("regex" is a compulsory key and the file is saved using
		Python's json.dump()):
		[
			{
				"regex":"^(.*afgh.*|\\s*AFG\\s*|\\s*AF\\s*|\\s*4\\s*)$",
				"name_en":"Afghanistan",        # classification A
				"name_fr":"Afghanistan (l')",   # classification B
				"iso3":"AFG",                   # ...
				"iso2":"AF",
				"isoN":"4"
			},
			...
		]
		Author: Ilya Bolotov, MBA, Ph.D.
		Date: 20 July 2021
	*/
	syntax 																	///
	name(name=name) [, to(string) Generate(string) replace print]			///
	[from(string) *]
	tempname json sections_n vars
	tempvar converted
	// import classification
	if `"`from'"' == "" {
		qui findfile `"pyconvertu_classification.json"'
		local from `"`r(fn)'"'
	}
	// convert the variable to classification
	cap confirm variable `name'
	if ! _rc {
		/* check options for errors */
		if `"`to'"' == "" {					// check for missing options
			di as err "option to() required"
			exit 198
		}
		if `"`replace'`generate'`print'"' == "" {
			di as err "must specify either generate, replace or print option"
			exit 198
		}
		/* ado + python */
		python: l = _pyconvertu(r'`from'', Data.get('`name''), '`to'')
		if `"`print'"' == "" {				// store the converted variable
			g `converted' = ""
			python: Data.store('`converted'', None, l)
			if `"`generate'"'  != "" {		// generate a new variable
				g `generate' = `converted'
			}
			if `"`replace'"'   != "" {		// replace the existing one
				replace `name' = `converted'
			}
		}
		else {								// print only
			python: print('`"' + '""'.join(l).replace('""', '"\', `"') + '"\'')
		}
		exit 0
	}
	// save classification to a variable
	if `"`name'"' == "__classification" {
		/* check options for errors */
		if `"`to'"' == "" {
			di as err "option to() required"
			exit 198
		}
		if `"`generate'`print'"' == "" {
			di as err "must specify either generate or print option"
			exit 198
		}
		/* ado + python */
		python: l = _pyconvertu_list(r'`from'', '`to''); l.sort()
		python: n = len(l) - Data.getObsTotal()
		if `"`print'"' == "" {				// store the classification
			g `converted' = ""
			python: Data.addObs((lambda n: n if n > 0 else 0)(n))
			python: Data.store('`converted'', [i for i in range(0, len(l))], l)
			if `"`generate'"' != "" {		// generate a new variable
				g `generate' = `converted'
			}
		}
		else {								// print only
			python: print('\`"' + '"\' \`"'.join(l) + '"\'')
		}
		exit 0
	}
	// print metadata and sources
	if `"`name'"' == "__info" {
		python: l = _pyconvertu_info(r'`from'')
		python: print(f'\n'.join(l))
		exit 0
	}
	// dump classification from data to a json file
	if `"`name'"' == "__dump" {
		qui ds
		local `vars' = r(varlist)
		/* find _n of the json sections */
		forvalues n = 1/`=_N' {
			if regexm(`=word("``vars''", 1)'[`n'], "^\s*(Data|Meta|Sources)") {
				local `sections_n' "``sections_n'' `n'"
			}
		}
		/* ado + python */
		scalar `json' = ""
		cap preserve
		forvalues i = 1/`=wordcount("``sections_n''")' {
			local n = word("``sections_n''", `i')
			restore, preserve
			qui {
				drop if _n < `n'			// isolate each json section
				cap drop if _n > `=real(word("``sections_n''", `i' + 1)) - `n''
				drop if mi(`=word("``vars''", 1)')
				if regexm(`=word("``vars''", 1)'[1], "^\s*Data") {
					foreach var in ``vars'' {
						tostring `var', replace force
						replace `var' = `""`=`var'[2]'": ""' + `var' + `"""'
					}
					drop if _n <= 2			// Data (the classification)
					egen `converted' = concat(``vars''), punct(", ")
					replace `converted' = "{" + `converted' + "}"
					levelsof `converted', clean s(", ")
					scalar `json' = `json' + r(levels) + ", "
				}
				if regexm(`=word("``vars''", 1)'[1], "^\s*Meta") {
					drop if _n <= 2			// Metadata
					g `converted' = `"""' + `=word("``vars''", 1)' + 		///
					`"": ""' + `=word("``vars''", 2)' + `"""'
					levelsof `converted', clean s(", ")
					scalar `json' = `json' + `"{"metadata": {"' + 			///
					r(levels) + "}}, "
				}
				if regexm(`=word("``vars''", 1)'[1], "^\s*Sources") {
					drop if _n <= 2			// Sources
					g `converted' = `""["' + `=word("``vars''", 2)' + 		///
					"](" + `=word("``vars''", 1)' + `")""'
					levelsof `converted', clean s(", ")
					scalar `json' = `json' + `"{"sources": ["' + 			///
					r(levels) + "]}, "
				}
			}
		}
		python: _pyconvertu_dump(r'`to'', Scalar.getString('`json''))
		exit 0
	}
	// or display error
	di as err 																///
	"must specify either a variable, __classification, __info, or __dump"
	exit 198
end

* Python 3 code ***********
python:
# Stata Function Interface
from sfi import Data, Scalar

# Python Modules
import json
import os
import re

# User-defined Functions
def _pyconvertu(
	source_file=r'', from_list=[], to_classification='', *args, **kwargs
):
	"""
	/*
		Converts a list of strings (from_list) to classification
		(to_classification) based on a JSON file (source_file),
		unmatched strings are returned unchanged.
	*/
	"""
	try:
		#// load classification
		with open(os.path.expanduser(source_file)) as f:
			classification = list(filter(
				lambda d: not d.get('metadata') and not d.get('sources'),
				json.load(f)
			))
		#// convert list
		return list(map(
			lambda s:
				(lambda l, s: 
					l[1].get(to_classification) if len(l) > 1 else l[0]
				)(
					[s] + list(filter(
						lambda d: re.search(
							r'' + d.get('regex') + r'', s, flags=re.I|re.M
						),
						classification
					)),
					str(s)
				),
			from_list
		))
	except:
		return {}

def _pyconvertu_list(
	source_file=r'', from_classification='', *args, **kwargs
):
	"""
	/*
		Creates a list of strings from classification
		(from_classification) based on a JSON file (source_file).
	*/
	"""
	try:
		#// load classification
		with open(os.path.expanduser(source_file)) as f:
			classification = list(filter(
				lambda d: not d.get('metadata') and not d.get('sources'),
				json.load(f)
			))
		#// create list
		return list(map(
			lambda d: d.get(from_classification),
			classification
		))
	except:
		return {}

def _pyconvertu_info(
	source_file=r'', *args, **kwargs
):
	"""
	/*
		Returns a list based on a JSON file (source_file).
	*/
	"""
	try:
		#// load classification metadata
		with open(os.path.expanduser(source_file)) as f:
			metadata = list(filter(
				lambda d: d.get('metadata') or d.get('sources'),
				json.load(f)
			))
		#// create list
		return list(map(
			lambda d: str(d),
			metadata
		))
	except:
		return {}

def _pyconvertu_dump(
	target_file=r'', json_string='', *args, **kwargs
):
	"""
	/*
		Writes JSON string to a JSON file (target_file).
	*/
	"""
	target_file = target_file.replace('.json', '') + '.json'
	with open(os.path.expanduser(target_file), 'w') as f:
		#// dump classification and print message
		json.dump(
			json.loads('[' + json_string[0:-2].replace('\\', '\\\\') + ']'),
			f
		)
		print(
			'JSON file \'' + target_file.replace('.json', '') + '.json' +
			'\' created'
		)

end
