////////////////////////////////////////////////////////////////////////////////
///////// 			CHN_2010_CFPS                 			///////////////////
////////////////////////////////////////////////////////////////////////////////

/* 
Preparation file for China 2010

	Instrument: p42-44 in "CFPS 2010 Quesionnaire.pdf"
	
	hexp sepc: in expense module, hexp (medical treatment and hygiene) recall in 12 month in expense module --> extract 
	In health module, OOP-IP avaliable for ind older than 16, total hexp avaliable for ind younger than 15
		--> not extract		
	
	Gaul Code: 25 out of 31 regions covered, these regions covered 95% of national population
	
	Wel agg: 2 ready to use expenditure: [fh601] An approximated total annual hh expenditure. [expense] An adjusted sum of expense from expense module. 
		--> use adjusted sum of expense. For hh missing [expense], generated a wel agg by suming adjusted expense and replace. 
		--> if still missing wel agg, drop. 39 hh dropped.  
	
	weight: 
		
*/

* set up																		
**********
tempfile t1 t2 t3 t4 tpf Gaul
local refid "CHN_2010_CFPS"

*******************************************************************************************
				***   IMPORT AND MERGE FILES AT HH LVL   ***
*******************************************************************************************
																				** <_import_>
																			
* Gaul 
use "${OUT}/Subnational regions.dta",clear
	keep if iso3c=="CHN"
	sort gl_adm1_name gl_adm1_name_alt
save `Gaul',replace


*Wel Agg and health expense from expense module
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2010famecon_201906.dta", clear // p42-44 in "CFPS 2010 Quesionnaire.pdf"
	ren fid	hh_id
	isid hh_id
	sort hh_id

	gen hexp_total = med // hexp recall in 12 month
	foreach k in med food {
		replace `k' = 0 if `k' ==.
	}
	
	* Generate Wel Agg 
	gen wel = expense // an adjusted sum of expense
	* Wel agg alt 1: sum of adjusted expense
	egen wel_alt1 = rowtotal(food dress house daily med trco eec other eptran epwelf mortage) // sum of adjusted expense
	replace wel = wel_alt1 if wel ==. 
	
	* Wel agg Alt 2: annualized sum of unadjusted expense, for comparasion. Not used.
	foreach var of varlist fh30* fh4* fh502 fh601 {
		replace `var' = 0 if `var'==-2 | `var'==-1 | `var'==. |`var'==-8
	}	
	egen welmonth=rowtotal(fh301 fh302 fh303 fh304 fh305 fh306 fh307 fh308 fh309)
	egen welyear=rowtotal(fh401 fh402 fh403 fh404 fh405 fh406 fh407 fh408 fh409 fh410 fh411 fh502)
	gen wel_alt2 = welmonth*12+welyear
	
	drop if wel ==0 // 39 hh drop 

	* Gaul Code
	label define province 11 "Beijing Shi" 12 "Tianjin Shi" 13 "Hebei Sheng" 14 "Shanxi Sheng" 15 "Nei Mongol Zizhiqu" 21 "Liaoning Sheng" 22 "Jilin Sheng" ///
		23 "Heilongjiang Sheng" 31 "Shanghai Shi" 32"Jiangsu Sheng" 33"Zhejiang Sheng" 34"Anhui Sheng" 35"Fujian Sheng" 36"Jiangxi Sheng" 37"Shandong Sheng" ///
		41 "Henan Sheng" 42"Hubei Sheng" 43 "Hunan Sheng" 44 "Guangdong Sheng" 45 "Guangxi Zhuangzu Zizhiqu" 46 "Hainan Sheng" 50 "Chongqing Shi" 51 "Sichuan Sheng" ///
		52 "Guizhou Sheng" 53 "Yunnan Sheng" 54 "Xizang Zizhiqu"  61 "Shaanxi Sheng" 62 "Gansu Sheng" 63 "Qinghai Sheng" 64 "Ningxia Huizu Zizhiqu" 65 "Xinjiang Uygur Zizhiqu"
	label value provcd province
	decode provcd, gen(gl_adm1_name)
	sort gl_adm1_name
	merge m:1 gl_adm1_name using `Gaul'
	tab _m
	drop if _m==2 // 6 provinces are not covered in the data 
	drop _m 	
																				// </_import_>

*******************************************************************************************
					***   COMMON VARIABLES   ***
*******************************************************************************************

																				** <_common_vars_>

* Health exp																		** <_hexp_>	
*************
	* Total exp aggregates
	gen hh_hexp = hexp_total	// health expenditure recall in 12 month 
	
	gen hh_hexp_coicop_61	=.															
    gen hh_hexp_coicop_62	=.																
    gen hh_hexp_coicop_63	=.															
    gen hh_hexp_coicop_64	=.															
	
																					// </_hexp_>
																					
* WELFARE AGGREGATE	: total annual expenditure										** <_exp_>
	ren wel_alt2 hh_exp
																					// </_exp_>

* Food / non-food expenditure (annual)												** <_fexp_>
	ren food hh_fexp
	gen hh_nfexp = hh_exp-hh_fexp													
	count if hh_nfexp<0	 // 0
																					// </_fexp_>
																																								
* survey variables																	** <_svy_>
	ren familysize hh_size	
	ren subpopulation hh_strata 
	ren psu hh_psu																		// search also for clusterm enumerating area ea groupement
	
	ren  provcd hh_region															
	gen  hh_region_rep = 1	// 25 out of 31 regions covered												
	
	ren urban hh_urban
	ren fswt_nat hh_sampleweight  														
	gen popweight = int(hh_size*hh_sampleweight)
																					// </_svy_>
																				
*spec
	gen spec = "Cc"												// first capital letter: C or I: either consumption or income aggregate. Iat = Income_after_tax. Ibt= Income_before_tax
																// second small letter: health exp comes from h=health_section  c=consumption_section m=mix_of_section  d=diary

	gen int  IP_recall = .														// in days
	gen 	 IP_level = ""														// "hh" or "ind"
	gen byte IP_itemN = 0														// number of items
	gen int	 OP_recall = 365
	gen 	 OP_level = "hh"
	gen byte OP_itemN = 1

	
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

For Rural
------------------------- Distributional Estimation --------------------
                                         Gini index(%): 40.6079
                         median income(or expenditure): 96.1130453011558
                                             MLD index: 0.276586
                                 polarization index(%): 33.6183
                           distribution corrected mean: 21.3061(PPP$)
            mean income/expenditure of the poorest 50%: 16.9351(PPP$)
                                       estimate median: 26.0038(PPP$)
------------------------------------------------------------------------
For urban
------------------------- Distributional Estimation --------------------
                                         Gini index(%): 35.7445
                         median income(or expenditure): 244.204118348348
                                             MLD index: 0.21403
                                 polarization index(%): 29.517
                           distribution corrected mean: 53.3759(PPP$)
            mean income/expenditure of the poorest 50%: 43.6249(PPP$)
                                       estimate median: 66.0706(PPP$)
------------------------------------------------------------------------
*/

