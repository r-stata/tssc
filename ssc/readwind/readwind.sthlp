{smcl}
{right:version:  3.0.0}
{cmd:help readWind} {right:May 19, 2021}
{hline}

{title:Title}

{p 4 4 8}{cmd:readwind}  -  Read the data downloaded from the Wind into Stata in a long form {p_end}


{title:Syntax}

{p 4 8 2}
{cmd:readwind namelist(min=1)}
{cmd:,} 
{cmd:key(keywords)}
{cmd:timeType(time type)}
{cmd:t0(start time)}
{cmd:tn(end time)}
[{it:type(excel type)}
{it:sheet(excel sheet number)}
{it:encoding(encoding type)}
{it:tostring}]

{title:Description}

{p 4 8 2} readwind is a command to import downloaded data from the Wind database into Stata more efficiently. Note that, the work (fastreshpe) of Michael Droste helped us to solve the problem of converting the data form of long/wide  into wide/long, and it's appreciated. {p_end}


{p 4 8 2} {cmd: namelist} Namalist is the name of the imported variable, at least one variable.  {p_end}

{p 4 8 2} {cmd: key} keywords of the object excel. {p_end}

{p 4 8 2} {cmd: timeType} timeType refers to whether the downloaded sample is annual, quarterly, monthly of daily, so its value is y/q/m/d. {p_end}

{p 4 8 2} {cmd: t0} Sample start time, for example, if you choose to download it from January 1995, then t0 could be set as 1995m1. 
                    Quarterly and monthly correspond to 1995q1 and 1995 respectively. {p_end}

{p 4 8 2} {cmd: tn} Sample end time, for example, if your sample deadline is at January 2018, then tn could be set as 2018m1. 
                    Quarterly, monthly and daily are also permitted.  {p_end}

{p 4 8 2} {cmd: type(file type) sheet(excel sheet number) encoding(encoding type) tostring} are optional. 
                The optional attribute in type is corresponding to your data file, and it can be set to xls, xlsx or csv. 
				When your dataset is excel format and the suffix of your excel is xls, you should set type(xls), the default is xlsx; 
				Sheet specifies the number of tables in the object Excel, and the default is set to sheet1. 
				Note that if your original data is in CSV format, ignore the sheet option, and you can encoding the text to prevent scrambling. 
				The default encoding is utf-8. Option tostring forces variables to be converted to character type. {p_end}



{title:Example}
 {p 4 8 2} cd ".\tagetFile\" {p_end}
 {p 4 8 2}{stata "readwind ROE, key(ROE) timeType(q) t0(1995q1) tn(2017q4)" :. readwind ROE, key(ROE) timeType(q) t0(1995q1) tn(2017q4) } {p_end}
 {p 4 8 2}{stata "readwind ROE ROA, key(ROE_ROA) timeType(q) t0(1995q1) tn(2017q4) type(csv) encoding(gbk) tostring" :. readwind ROE ROA, key(ROE_ROA) timeType(q) t0(1995q1) tn(2017q4) type(csv) encoding(gbk) tostring} {p_end}



{title:Author}

{pstd} {cmd:Hongbing,Zhu (朱红兵)}{p_end}
{pstd} . Business School, Nanjing University, China. {p_end}
{pstd} . E-mail: {browse "mailto:zhuhong_bing@163.com":zhuhong_bing@163.com} {p_end}


{title:Also see}

{pstd} Online: {helpb fastreshape}{p_end}
