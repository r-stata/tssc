* version 1.0.8 Niels Henrik Bruun	2019-02-27
* version 1.0.7 Niels Henrik Bruun	
* version 1.0.6 Niels Henrik Bruun	2017-10-10
* version 1.0.5 Niels Henrik Bruun	2017-05-19
* 2017-05-19 >	lines2markup(): Added sampleline to handle broken sample lines
* version 1.0.4	Niels Henrik Bruun	2017-03-31
* version 1.0.3	Niels Henrik Bruun	2016-08-19
* version 1.0.2	Niels Henrik Bruun	2016-03-16
* version 1.0.1	Niels Henrik Bruun	2016-02-15
* version 1.0		Niels Henrik Bruun	2016-02-15
version 12

program define log2markup
	syntax using/ 			/* The Stata text log file to use
		*/[,				/* Optional
		*/log					/* To test the code in Results window, no markdown file is generated
		*/replace				/* Overwrite existing markdown file
			//Use when transforming markdown to eg html or latex
			*/extension(string)		/* Specify the extension of the outputfile
			*/codestart(string)		/* Set the marking of code start in markdown document
			*/codeend(string)		/* Set the marking of code end in markdown document
			*/samplestart(string)	/*	Set the marking of sample/output start in markdown document
			*/sampleend(string)		/* Set the marking of sample/output end in markdown document
		*/]
	mata {
		extension = ("`extension'" == "" ? "markup" : "`extension'")
		code_start = ("`codestart'" == "" ? "~~~" : "`codestart'")
		code_end = ("`codeend'" == "" ? "~~~~" : "`codeend'")
		sample_start = ("`samplestart'" == "" ? "~~~~~" : "`samplestart'")
		sample_end = ("`sampleend'" == "" ? "~~~~~~" : "`sampleend'")

		lines = loglines2markup("`using'", extension, code_start, code_end, sample_start, sample_end, ("`log'"=="log"), "`replace'"=="replace")
	}
end
