* Authors:
* Program written by Bolin, Song (松柏林) Shenzhen University, China.
* Wechat:YJYSY91, 2021-01-02
* Original Data Source: https://data.stats.gov.cn/
* Please do not use this code for commerical purpose

capture program drop cngdf
program define cngdf

	version 14.0
    
syntax [anything] ,YEAR(numlist max=1 min=1 ) [CHINA] 
    qui{
        if missing("`china'") {
            if `year'<1993 | `year'>2019 {
                disp as error  `"The year must be between 1993 and 2019"'
                exit 198 
            }
            capture confirm integer number `year' 
		    if _rc {
			    di as err "The year must be a  integer"
			    exit 198 
		    }
            local URL "https://gitee.com/songbolin/stata/raw/master/8458467434930237.dta"
            tempfile  data   
            cap copy `"`URL'"' "`data'.dta", replace  
            local times = 0
		    while _rc ~= 0 {
			    local times = `times' + 1
			    sleep 1000
			    cap copy `"`URL'"' "`data'.dta", replace 
			    if `times' > 10 {
				    disp as error "Internet speeds is too low to get the data"
				    exit 601
			    }
		    }                    
            use "`data'.dta", clear
            gen Real_GDP = GDP if year == `year'  
            bysort id :replace  Real_GDP= Real_GDP[_n-1]*GDPindex/100 if year!=`year' 
            gen gdp_deflator=GDP/Real_GDP   
            drop GDP  Real_GDP GDPindex
            drop if year<`year'
            label variable gdp_deflator "GDP deflator based on `year'"
            label data "GDP deflator based on `year'"
            exit
        }
        
        if `year'<1978 | `year'>2019 {
            disp as error  `"The year must be between 1978 and 2019"'
            exit 198 
        }
        capture confirm integer number `year' 
		if _rc {
			di as err "The year must be a  integer"
			exit 198 
		}
        local URL "https://gitee.com/songbolin/stata/raw/master/8458490029.dta"
        tempfile  data   
        cap copy `"`URL'"' "`data'.dta", replace  
        local times = 0
		while _rc ~= 0 {
			local times = `times' + 1
			sleep 1000
			cap copy `"`URL'"' "`data'.dta", replace 
			if `times' > 10 {
				disp as error "Internet speeds is too low to get the data"
				exit 601
			}
		}                    
        use "`data'.dta", clear 
        gen Real_gdp = gdp if year == `year'  
        replace Real_gdp= Real_gdp[_n-1]*gdp_index/100 if year!=`year' 
        gen gdp_deflator=gdp/Real_gdp   
        drop gdp Real_gdp gdp_index
        drop if year<`year'
        label variable gdp_deflator "GDP deflator based on `year'"
        label data "GDP deflator based on `year'"     
    }
end