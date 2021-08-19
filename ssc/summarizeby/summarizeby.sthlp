{smcl}
{* *! version 1.1.0  20nov2020}{...}
{viewerjumpto "Examples" "summarizeby##examples"}{...}
{title:Title}

{phang}
{bf:summarizeby} {hline 2} Extend {helpb statsby}
for {helpb summarize} with the same syntax but no ": command"

{marker examples}{...}
{title:Examples}

        {cmd:. sysuse auto, clear}

        * simple example, collect all statistics returned by summarize
        {cmd:. summarizeby, clear}

        * same example with by()
        {cmd:. summarizeby, clear by(foreign)}

        * save main statistics into a DTA file
        {cmd:. summarizeby mean=r(mean) sd=r(sd) min=r(min) max=r(max), saving(stats)}

        * compare and contrast main statistics for two datasets
        {cmd:. tempfile tmpf}
        {cmd:. preserve}
        {cmd:. summarizeby mean=r(mean) sd=r(sd) if mpg > 20, saving(`tmpf')}
        {cmd:. restore}
        {cmd:. summarizeby mean=r(mean) sd=r(sd), clear}
        {cmd:. append using `tmpf', gen(id)}
        {cmd:. order id}
        {cmd:. label define dataset 0 "full" 1 "reduced"}
        {cmd:. label values id dataset}

        * export to excel
        {cmd:. export excel * using "stats.xlsx", firstrow(variables)}
