{smcl}
{* *! version 1.0.1 29febr2008}
{cmd:help mapch}
{hline}

{title: Title}

{phang}
{bf:mapch -- map chains of events}


{title:Syntax}

{phang}
{cmdab:mapch}
{it:begin}
{it:end}
[{it:time}]
{ifin}


{title: Description}

{pstd}
{cmd: mapch} maps chains of events. A 'chain' consists of at least one event; 
an 'event' in this context is a change of information contained in the 
variable {it:begin} into information contained in the variable {it:end}. 
Optionally, the time at which the event took place can be stored in the variable
{it:time} and used to map the chains chronologically. It is assumed that both 
{it:begin} and {it:end} contain unique information, i.e., each value in both 
variables can only appear once. It is also assumed that events in a chain can 
not occur at the same time and that chains are not circular, i.e., the begin 
value of a chain must not be the same as the end value of that chain. {cmd:mapch}
creates a dataset {it:mapping} that contains maps of each chain and two or 
three additional variables: {it:recent}, whose value is equal to the end value 
of the chain for each step in that chain; {it:date} (only in case real time is 
not available), a fictitious time when the event took place allowing to sort 
the information; and {it:NoOfEvents}, the number of events per chain. {cmd:mapch}
also tabulates the frequency of n-step chains with 1<=n<=N (N=total number of 
events in your dataset). Consider the following two examples.

{cmd:Example 1:}{break}
{it: begin}{col 20}{it: end}
{col 2}A{col 21}B
{col 2}B{col 21}C
{col 2}G{col 21}H
{col 2}C{col 21}D
{col 2}X{col 21}Y
{col 2}H{col 21}I
{col 2}Z{col 21}Z1
{col 2}Z1{col 21}Z2
{col 2}X2{col 21}X3
{col 2}Z2{col 21}Z3

{cmd:mapch} will map the chains and create the dataset {it:mapping} as follows:

{it:begin}{col 15}{it:end}{col 30}{it:recent}{col 45}{it:date}{col 60}{it:NoOfEvents}
A{col 15}B{col 30}D{col 45}1{col 60}3
B{col 15}C{col 30}D{col 45}2{col 60}3
C{col 15}D{col 30}D{col 45}3{col 60}3
G{col 15}H{col 30}I{col 45}1{col 60}2
H{col 15}I{col 30}I{col 45}2{col 60}2
X{col 15}Y{col 30}Y{col 45}.{col 60}1
X2{col 15}X3{col 30}X3{col 45}.{col 60}1
Z{col 15}Z1{col 30}Z3{col 45}1{col 60}3
Z1{col 15}Z2{col 30}Z3{col 45}2{col 60}3
Z2{col 15}Z3{col 30}Z3{col 45}3{col 60}3

{cmd:Example 2:}{break}
{it: begin}{col 20}{it: end}{col 40}{it:time}
{col 2}A{col 21}B{col 40}17004
{col 2}B{col 21}C{col 40}17203
{col 2}G{col 21}H{col 40}15000
{col 2}C{col 21}D{col 40}18999
{col 2}X{col 21}Y{col 40}17034
{col 2}H{col 21}I{col 40}16000
{col 2}Z{col 21}Z1{col 40}14333
{col 2}Z1{col 21}Z2{col 40}14334
{col 2}X2{col 21}X3{col 40}15001
{col 2}Z2{col 21}Z3{col 40}14335

{cmd:mapch} will map the chains and create the dataset {it:mapping} as follows:

{it:begin}{col 15}{it:end}{col 30}{it:time}{col 45}{it:recent}{col 60}{it:NoOfEvents}
A{col 15}B{col 30}17004{col 45}D{col 60}3
B{col 15}C{col 30}17203{col 45}D{col 60}3
C{col 15}D{col 30}18999{col 45}D{col 60}3
G{col 15}H{col 30}15000{col 45}I{col 60}2
H{col 15}I{col 30}16000{col 45}I{col 60}2
X{col 15}Y{col 30}17034{col 45}Y{col 60}1
X2{col 15}X3{col 30}15001{col 45}X3{col 60}1
Z{col 15}Z1{col 30}14333{col 45}Z3{col 60}3
Z1{col 15}Z2{col 30}14334{col 45}Z3{col 60}3
Z2{col 15}Z3{col 30}14335{col 45}Z3{col 60}3


{title:Remarks}

{pstd}
{cmd:mapch} was written based on a do-file that was used to overcome the 
challenge of merging datasets in which unique key identifiers changed over 
time, more precisely driver license numbers. A substantial portion of the 
driver license numbers changed over time because this variable's format was 
alpha-numeric and based on the driver's name. In order to capture all accident 
records when merging datasets in which the updated number was used with 
datasets in which the original number was used, the name changes had to be 
mapped in order to create a cross-reference dataset. To this end, a solution 
consisting of a combination of appending, indexing and merging was developed, 
which proved to be considerably faster than simply looping; e.g., a dataset 
containing 86,000 events with chains of length of up to five events (i.e., 
drivers who changed their name ergo driver's license number up to five times 
in a period of ten years) is mapped in a couple of seconds using {cmd:mapch}, 
while it may take numerous hours in case a simpler combination of looping 
procedures would be used.

{it:Author}: Ward Vanlaar (wardv@trafficinjuryresearch.com)

