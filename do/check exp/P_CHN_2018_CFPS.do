////////////////////////////////////////////////////////////////////////////////
///////// 			 CHN_2018_CFPS                			///////////////////
////////////////////////////////////////////////////////////////////////////////

/* 
Preparation file for China in 2018

	Instrument: p in ".pdf"
	
	hexp sepc: IP, OP, total-hexp, and OOP-hexp recall in 12 month in health module.
		--> extract OOP-hexp
			for some ind. aged 9-17, both themself and their parents answered their health expense. 
		--> use their parents' answers.
			recall in 12 month in expense module
				
	wel agg ready to use 
				
	 hh have no wel agg
		--> drop
				
	In raw data, affect hh. Use http://worldmap.harvard.edu/data/geonode:g2008_1 as reference
            --> 

	PPP not avaliable.
		--> use instead, will automatically replace when avaliable
			
Lookfor heal med pay exp hos item sick tot
*/

* set up																		
**********
tempfile t1 t2 t3 t4 Gaul
local refid "CHN_2018_CFPS"
global TEMP "${root}/tmp"

*******************************************************************************************
				***   IMPORT AND MERGE FILES AT HH LVL   ***
*******************************************************************************************
																				** <_import_>
																				
*Health Expenditure
* ind older than 9, self-answer 
use "${SOURCE}/WB MICRO DATA/CHN_2018_CFPS/Data/cfps2018person_201911.dta", clear				
	ren fid18	hh_id
	isid 	pid
	ren qc701 hexp_OOP   // OOP hexp recall in 12 month
	ren qc7a hexp_IP // IP 
	ren qc7b hexp_OP // OP
	ren metotal hexp // total hexp
	
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'<0
	}
	
	keep hexp* hh_id pid age
	sort pid
	gen self = 1 
save `t1',replace

* ind younger than 17, answered by their parents
use "${SOURCE}/WB MICRO DATA/CHN_2018_CFPS/Data/cfps2018children.dta", clear		
	isid pid
	ren fid18 hh_id
	ren wc701 hexp_OOP   // OOP hexp recall in 12 month
	ren wc7a hexp_IP // IP 
	ren wc7b hexp_OP // OP
	ren metotal hexp // total hexp
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'<0
	}
	keep pid hh_id hexp* age
	append using `t1'
	duplicates tag pid,gen(dup)
	tab age if dup !=0 // age: 9-17
	drop if self ==1 & dup !=0	// self=1 if self-answered, =. if answered by parents
	isid pid
	collapse (sum) hexp*,by(hh_id)
	sort 	hh_id
save `t2',replace

* Gaul
use "${OUT}/Subnational regions.dta",clear
	keep if iso3c=="CHN"
	sort gl_adm1_name gl_adm1_name_alt
save `Gaul',replace


*Wel Agg
use "${SOURCE}/WB MICRO DATA/CHN_2018_CFPS/Data/cfps2018hh.dta", clear
	ren fid18	hh_id
	isid 	hh_id
	sort hh_id
	merge 1:1 hh_id using `t2'
	tab _m
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'==.
	}	// 253 hh don't have hexp, replace with 0
	drop if _m==2	// 538 hh have no wel agg, drop
	drop _m

	label define province 11 "Beijing Shi" 12 "Tianjin Shi" 13 "Hebei Sheng" 14 "Shanxi Sheng" 15 "Nei Mongol Zizhiqu" 21 "Liaoning Sheng" 22 "Jilin Sheng" ///
		23 "Heilongjiang Sheng" 31 "Shanghai Shi" 32"Jiangsu Sheng" 33"Zhejiang Sheng" 34"Anhui Sheng" 35"Fujian Sheng" 36"Jiangxi Sheng" 37"Shandong Sheng" ///
		41 "Henan Sheng" 42"Hubei Sheng" 43 "Hunan Sheng" 44 "Guangdong Sheng" 45 "Guangxi Zhuangzu Zizhiqu" 46 "Hainan Sheng" 50 "Chongqing Shi" 51 "Sichuan Sheng" ///
		52 "Guizhou Sheng" 53 "Yunnan Sheng" 54 "Xizang Zizhiqu"  61 "Shaanxi Sheng" 62 "Gansu Sheng" 63 "Qinghai Sheng" 64 "Ningxia Huizu Zizhiqu" 65 "Xinjiang Uygur Zizhiqu"
	label value provcd18 province
	decode provcd18, gen(gl_adm1_name)
	sort gl_adm1_name
	merge m:1 gl_adm1_name using `Gaul'
	tab _m
	drop if _m==9 // 9 hh have no province data, can't judge from hhid, drop
	drop _m 	
save "${TEMP}/CHN_2018_merged.dta",replace
																				// </_import_>

*******************************************************************************************
					***   COMMON VARIABLES   ***
*******************************************************************************************
use "${TEMP}/CHN_2018_merged.dta",clear
local refid "CHN_2018_CFPS"

																				** <_common_vars_>

* Health exp																		** <_hexp_>	
*************
	* Total exp aggregates
	gen hh_hexp = hexp_OOP	// oop hh hexp recall in 12 month
		* 
		gen hh_hexp_alt =  med // hhexp recall in 12 month from expenditure module
		
	gen hh_hexp_coicop_61	=.															
    gen hh_hexp_coicop_62	=.																
    gen hh_hexp_coicop_63	=.															
    gen hh_hexp_coicop_64	=.															
	
																					// </_hexp_>
																					
* WELFARE AGGREGATE																	** <_exp_>
	ren  fexp hh_exp	// Total annual household expenditure 
																					// </_exp_>


* Food / non-food expenditure (annual)												** <_fexp_>
	ren food hh_fexp																	// Annual total household food expenditures
	gen hh_nfexp = hh_exp-hh_fexp													
	count if hh_nfexp<0	 // 0
																					// </_fexp_>
* survey variables																	** <_svy_>
	ren familysize18 hh_size	
	ren hh_strata
	ren hh_psu																		// search also for clusterm enumerating area ea groupement
	
	ren  hh_region															
	gen  hh_region_rep = 	// 9													
	
	ren urban18 hh_urban
	drop if urban18==-9 // 245 hh missing 
	ren hh_sampleweight  														
	gen popweight = int(hh_size*hh_sampleweight)
																					// </_svy_>
																				
*spec
	gen spec = ""												// first capital letter: C or I: either consumption or income aggregate. Iat = Income_after_tax. Ibt= Income_before_tax
																// second small letter: health exp comes from h=health_section  c=consumption_section m=mix_of_section  d=diary

	gen int  IP_recall = 														// in days
	gen 	 IP_level = ""														// "hh" or "ind"
	gen byte IP_itemN = 0														// number of items
	gen int	 OP_recall = 30
	gen 	 OP_level = "ind"
	gen byte OP_itemN = 4

	
																				** </_common_vars_>
/*
codebook hh_size hh_exp hh_fexp hh_nfexp hh_strata hh_psu hh_sampleweight hh_region hh_urban  	
gen healthshare= hh_hexp/hh_exp
gen foodshare = hh_fexp/hh_exp
sum hh_hexp* hh_exp	*share 
xx
*/						
														
********************************************************************************************
				***   Survey Specific modifications  ***
********************************************************************************************
																				** <_currency_adj_>
*INSERT3

																				// </_currency_adj_>


																				
																				
*******************************************************************************************
				*** SURVEY IDENTIFICATION VARIABLES   ***
*******************************************************************************************
																				** <_survey_id_>
cap label drop _all
** Reference ID follows DDI see IHSN (http://catalog.ihsn.org/index.php/catalog)
	gen referenceid=    "`refid'"
** First v position
	local v1 = strpos(referenceid,"v")
** Second v position
	local v2 = strpos(subinstr(referenceid, "v", "x", 1), "v")
** String length
	local len = strlen(referenceid)
** Extract survey from referenceid
	cap drop survey
	generate str1 survey = ""
	cap replace survey = substr(referenceid,10,`v1' - 11)
** Extract adaptation from referenceid
	generate str1 adapt = ""
	replace adapt = substr(referenceid,`v2'+6,`len' - (`v2'+5)) if `v2'!=0
** Extract year from referenceid
	cap drop year
	gen year = substr(referenceid,5,4)
	destring year, replace
** Extract iso3c from referenceid
	cap drop iso3c
	gen iso3c = substr(referenceid,1,3)
	local iso3c = iso3c
** Merge with CountryCodes.dta
	save `tpf', replace
	merge m:1 iso3c using "${SOURCE}/CountryCodes.dta"
	labmask iso3n, value(iso3c)
	drop if _merge==2
	drop _merge
	order referenceid iso3c iso3n year survey adapt WB_cname WHO_cname
																				// </_survey_id_>
local cname = iso3c
local year = year


*******************************************************************************************
				***   STANDARD EXPENDITURE   ***
*******************************************************************************************
																				
**Add poverty lines
	merge m:1 iso3c year using "${OUT}/PPPfactors_2011.dta"
	tab _merge
	keep if _merge==3
	drop _merge

** std exp	
	qui do "${DO}/Standard-Expenditure${stdexp_v}.do"	

** labels
	qui do "${DO}/Label-Variables.do"
																				
** save																				
	saveold "${OUT}/ADePT READY/`refid'_ADEPT.dta",replace
	*saveold "${OUT}/ADePT READY/`refid'_YYY_ADEPT.dta",replace

////////////////////////////////////////////////////////////////////////////////
////////////////////         E N D           ///////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

gen cons = hh_expcapd*365/12/PPP
gen cons_LCU = hh_expcapd*365/12
mean cons* [aw=popweight]

*qui do "${DO}/Standard-Indicators_2011PPP_n"	
*sum cata_tot_10 cata_nf_40* imp_np190 imp_np320 imp_npSPL


/* Use PCN to verify consumption. 
	1) http://iresearch.worldbank.org/PovcalNet/povOnDemand.aspx#
	2) select country	--> submit
	3) select all years --> submit
	4) for the closest year, click on "detail output" (last col.) --> detailed results in a pop up windows
	5) copy section "----------------- PPP$ and local currency --------------" at the bottom
	6) compare mean exp. monthly average. Both in LCU and $int. 

For 
*/
erase 
