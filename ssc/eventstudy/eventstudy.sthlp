{smcl}
{* *! version 12.0  13 Mar 2013}{...}

{viewerdialog eventstudy "dialog eventstudy"}{...}
{viewerjumpto "Syntax" "eventstudy##syntax"}{...}
{viewerjumpto "Description" "eventstudy##description"}{...}
{viewerjumpto "Options" "eventstudy##options"}{...}
{viewerjumpto "Examples" "eventstudy##examples"}{...}

{cmd:help eventstudy}


{title:Title}

{p2colset 5 20 22 2}{...}
{p2col : eventstudy {hline 2}} Module to do an eventstudy{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:eventstudy}
{cmd:using}
{it:{help filename}}
{cmd:,} 
{it:options}


{synoptset 40 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Event File}
{synopt:{opt event_file_name(EventFile)}} Specify the event file with path, which contains a list of events with even id,event firm id or ticker, event date and other control variables.{p_end}                            
{synopt:{opt event_id(EventID)}} Specify variable name which stands for the event id in the even file specified by option {it: event_file_name(EventFile)} .{p_end}
{synopt:{opt event_date(EventDate)}} Specify variable name in event file which stands for the event date.{p_end}
{synopt:{opt event_firm_id(EventFirmID)}} Specify variable name in event file which stands for the firm id or ticker.{p_end}
{synopt:{opt event_control(EventControls)}} Specify variable names in event file, which has nothing to do with the CAR calculation, but may be used in later investigations. We call those variables as conrols.{p_end}
{syntab:Trade File}
{synopt:{opt trade_file_name(TradeFile)}} Specify the event file with a path. This file ought to be a Stata's .dta file.{p_end}
{synopt:{opt firm_id(FirmID)}} Specify variable name in trade file which stands for firm id or ticker.{p_end}
{synopt:{opt trade_date(TradeDate)}} Specify the variable name stands for trading date in the trade data file.{p_end}
{synopt:{opt rit(rit)}} Specify the variable which stands for individual stock's daily return.{p_end}
{synopt:{opt rmt(rmt)}} Specify the variable which stands for market's daily return.{p_end}
{syntab:Method}
{synopt:{opt est_window_st(#)}} Set the start date of the estimate window. The default is -200, which stands for a date 200 tradding days before the event.{p_end}
{synopt:{opt est_window_end(#)}} Set the end date of the estimate window. The default is -10, which stands for a date 10 tradding days before the event.{p_end}
{synopt:{opt event_window_st(#)}} Set the start date of the event window. The default is -3, which stands for a date 3 tradding days before the event.{p_end}
{synopt:{opt event_window_end(#)}} Set the end date of the estimate window. The default is 3, which stands for a date 3 tradding days after the event {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}If your filename or file path contains spaces, remember to enclose it in double quotes{p_end}


{marker description}{...}
{title:Description}

{pstd}{opt eventstudy} can carry out a standard market model event study. it calculate the abnormal returns and Cumulative abnormal returns for each event.{p_end}
{pstd}                 To run this command, you have to specify the parameters on event file, trading file, and event windows by using option.{p_end}


{pstd}You need to choose a event file and a trading file, but they must contain some necessary variables as below:{p_end}

{pstd}Event file must contain variable of event code which identify each record uniqely, must contain variable of event
date that record the date when the event happens, must contain variable of event firm id which identify subject of each event record. For instance:{p_end}

{center:event_id	event_date	firm_id	event_control	event_control1	event_control2}
{center:1	2015 10 19	26	.0000118	.7135224	.9420305}
{center:2	2009 02 16	32	3.66e-06	.838579		.5355735}
{center:3	2024 04 29	46	7.20e-06	.5568867	.4753747}
{center:4	2020 12 01	48	7.22e-06	.9708269	.0968665}
{center:5	2022 07 04	48	4.51e-06	.0298252	.4498624}
{center:...	   ...	        ...	   ...		   ...		   ...  }
{pmore}


{pstd}Trading file must contain varible of firm id whic identify every company uniqely, must contain variable of trading date, and must contain variable of stock return and market return for every company on each trading date.For instance:{p_end}

{center:firm_id	   trade_date	   rit	           rmt}
{center:   23	  2000 08 30	-.0206074	.0240483}
{center:   23	  2000 08 31	.0427704	.0123303}
{center:    23	   2000 09 01	 .0177395	 -.0137796}
{center:   ...	      ...          ...  	    ...  }
{center:    85	   2024 11 07	-.0026962	-.0134778}
{center:   85	  2024 11 08	.0309724	.0086254}
{center:   85	  2024 11 12	-.0185169	.0192949}
{center:   ...	      ...          ...  	    ...  }
{pmore}

{pstd}As to the study method, you have to specify the relative date to event date to set the event window and estimate window. {p_end}
{pstd}For example, you may choose (-200-10) as the estimate window, and (-3,+2) as event window,{p_end}
{pstd} then you may set the option like this: ...est_window_st(-200) est_window_end(-10) event_window_st(-3) event_window_end(2). {p_end}
{pstd}In this command, we use market model to calculate the abnormal return.{p_end}

{pstd}the result file will be stored in {opt using} filename which contains variables of event code, {p_end}
{pstd}event control variables(variables you preserve in evnet file and can be more than one), AR, and CAR.{p_end}


{pstd}Since the options are too many, you are highly recommended to run this command with the dialog box. you can input "db eventstudy" in the command window.{p_end}
{pstd}The dialog box is quite self-explainary just try it after you running the following program to simulate an event file, a trading data file.{p_end}
{pstd}Or, you can also use your own data to test this program. Good Luck!{p_end}


{marker examples}{...}
{title:Example1}

{pstd}// To generate sample data set of Event by simulation

	{cmd:clear all}
	{cmd:set more off}
	{cmd:set obs 1000000}

	{cmd:gen int firm_id = _n/10000+23} 	
	{cmd:replace firm_id =23 if firm_id==123} 	
	{cmd:sort firm_id} 
	
	{cmd:by firm_id: gen trade_date = _n+mdy(8,29,2000)} 	
	{cmd:format trade_date %dCY_N_D} 	
	{cmd:drop if dow(trade_date)==0 | dow(trade_date)==6} 	
	{cmd:drop if uniform()<.02} 
	
	{cmd:sort trade_date} 	
	{cmd:bysort trade_date: gen rmt =(uniform()-0.5)*0.05} 	
	{cmd:gen rit=.} 	
	{cmd:forval i = 23(1) 123 {c -(}} 	
		{cmd:local beta = uniform()*3-0.8} 	
		{cmd:qui replace rit = `beta'*rmt+invnorm(uniform())*0.03 if firm_id==`i'} 	
	{cmd:{c )-}} 
	
	{cmd:sort firm_id trade_date} 	
	{cmd:order firm_id trade_date rit rmt} 	
	{cmd:save trade, replace}  
	
	{cmd:keep firm_id trade_date}  	
	{cmd:gen rand = uniform()} 	
	{cmd:sort rand} 	
	{cmd:keep if _n <= 10} 	
	{cmd:rename rand event_control} 	
	{cmd:gen event_control1=uniform()} 	
	{cmd:gen event_control2=uniform()} 	
	{cmd:sort firm_id trade_date}  	
	{cmd:gen event_id = _n}  	
	{cmd:rename trade_date event_date} 	
	{cmd:order event_id event_date firm_id event_control event_control1 event_control2} 	
	{cmd:save event, replace}  	

//describe sampe event file and trade file

	{cmd:describe using event.dta}
	{cmd:describe using trade.dta}

//defing some locals represent the parameters
 
	{cmd:local event_file_name event.dta}
	{cmd:local event_id  event_id}
	{cmd:local event_firm_id firm_id} 
	{cmd:local event_date event_date} 
	{cmd:local event_control "event_control event_control1 event_control2"} 

	{cmd:local trade_file_name trade.dta}
	{cmd:local trade_rit rit} 
	{cmd:local trade_rmt rmt} 
	{cmd:local trade_firm_id firm_id}
	{cmd:local trade_date trade_date}

	{cmd:local event_window_st = -3}
	{cmd:local event_window_end = 2}
	{cmd:local est_window_st = -200}
	{cmd:local est_window_end = -10}
//run the command, result will be saved in d:\result.dta

	{cmd:eventstudy using d:\result.dta ,event_file_name(`event_file_name')  ///}
		{cmd:trade_file_name(`trade_file_name') rit(`trade_rit') ///}
		{cmd:rmt(`trade_rmt') firm_id(`trade_firm_id') ///}
		{cmd:trade_date(`trade_date') event_id(`event_id') ///}
		{cmd:event_control(`event_control') event_firm_id(`event_firm_id') ///}
		{cmd:event_date(`event_date') event_window_st(`event_window_st')  ///}
		{cmd:event_window_end(`event_window_end') est_window_st(`est_window_st') ///}
		{cmd:est_window_end(`est_window_end')}
//erase the sample data set
	{cmd:erase event.dta}
	{cmd:erase trade.dta}


{title:Example2}
{pstd} //after generate sample data set, run this command in dialog box:

	{cmd:db eventstudy}

{title:Author}
{pstd}Xuan Zhang{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}zhangx@znufe.edu.cn{p_end}

{pstd}Chuntao Li{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@znufe.edu.cn{p_end}

{pstd}Xin Xu{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}xinkexuxin@gmail.com{p_end}
