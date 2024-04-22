////////////////////////////////////////////////////////////////////////////////
///////// 			 CHN_2018_CFPS                			///////////////////
////////////////////////////////////////////////////////////////////////////////

/* 
Preparation file for China in 2018

	Instrument: P65-66 & p163-166 & P194-198 in "CFPS 2018 household questionnaire (in chinese).pdf"
	
	hexp sepc: In health module, IP, OP, total hexp, and OOP hexp recall in 12 months.
					--> extract OOP-hexp
				for some ind. aged 9-17, both themselves and their parents answered health expense for them. --> use their parents' answers.
				In expense module, OOP-hexp recall in 12 month --> extract
		
!!!!Weight!!!!!:The team haven't release datafiles with household weight. They plan to release it in 2020 summer. 
		http://www.isss.pku.edu.cn/cfps/cjwt/sywt/index.htm
		--> assign hh_weight ==1 so far, need to update the do files when datafile released. 
	
	538 hh have no wel agg
		--> drop

	PPP not avaliable.
		--> use 2016 instead, will automatically replace when avaliable
*/

* set up																		
**********
tempfile t1 t2 t3 t4 tpf Gaul
local refid "CHN_2018_CFPS"

*******************************************************************************************
				***   IMPORT AND MERGE FILES AT HH LVL   ***
*******************************************************************************************
																				** <_import_>
																				
*Health Expenditure
* ind older than 9, self-answer 
use "${SOURCE}/WB MICRO DATA/CHN_2018_CFPS/Data/cfps2018person_201911.dta", clear				
	ren fid18 hh_id
	isid pid
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
	drop if self ==1 & dup !=0	// self=1 if self-answered, =. if answered by parents, prefer parents' answer
	isid pid
	collapse (sum) hexp*,by(hh_id)
	sort 	hh_id
save `t2',replace

* Gaul
use "${OUT}/Subnational regions.dta",clear
	keep if iso3c=="CHN"
	sort gl_adm1_name gl_adm1_name_alt
save `Gaul',replace

* Geo info:
use "${SOURCE}/WB MICRO DATA/CHN_2018_CFPS/Data/cfps2018famconf_202008.dta",clear
	keep fid18 fid_provcd18 fid_countyid18 fid_cid18 fid_urban18 fid_base psu
	duplicates drop
	sort fid18
	ren fid18 hh_id
save `t3',replace

*Wel Agg
use "${SOURCE}/WB MICRO DATA/CHN_2018_CFPS/Data/cfps2018hh.dta", clear
	ren fid18	hh_id
	isid hh_id
	sort hh_id
	merge 1:1 hh_id using `t2'
	tab _m
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'==.
	}	// 253 hh don't have hexp, replace with 0
	drop if _m==2	// 538 hh have no wel agg, drop
	drop _m

	merge 1:1 hh_id using `t3'
	tab _m
	drop if _m == 2 // 875 hh dropped for lacking wel agg
	drop if _m ==1 // 65 hh dropped, cfps2018famconf_202008.dta is the most updated datafiles updated by the team in 2020 summer, prefer geo and demo info. from this datafile.
	drop _m
	
	label define province 11 "Beijing Shi" 12 "Tianjin Shi" 13 "Hebei Sheng" 14 "Shanxi Sheng" 15 "Nei Mongol Zizhiqu" 21 "Liaoning Sheng" 22 "Jilin Sheng" ///
		23 "Heilongjiang Sheng" 31 "Shanghai Shi" 32"Jiangsu Sheng" 33"Zhejiang Sheng" 34"Anhui Sheng" 35"Fujian Sheng" 36"Jiangxi Sheng" 37"Shandong Sheng" ///
		41 "Henan Sheng" 42"Hubei Sheng" 43 "Hunan Sheng" 44 "Guangdong Sheng" 45 "Guangxi Zhuangzu Zizhiqu" 46 "Hainan Sheng" 50 "Chongqing Shi" 51 "Sichuan Sheng" ///
		52 "Guizhou Sheng" 53 "Yunnan Sheng" 54 "Xizang Zizhiqu"  61 "Shaanxi Sheng" 62 "Gansu Sheng" 63 "Qinghai Sheng" 64 "Ningxia Huizu Zizhiqu" 65 "Xinjiang Uygur Zizhiqu"
	label value fid_provcd18 province
	recode fid_provcd18 (-9=.) // 6 hh missing province info.
	decode fid_provcd18, gen(gl_adm1_name)
	sort gl_adm1_name
	merge m:1 gl_adm1_name using `Gaul'
	tab _m  // 6 hh have no province data, can't judge from hhid
	drop _m 	
save `t4',replace
																				// </_import_>

*******************************************************************************************
					***   COMMON VARIABLES   ***
*******************************************************************************************															** <_common_vars_>
* Health exp																		** <_hexp_>	
*************
	* Total exp aggregates
	gen hh_hexp = hexp_OOP	// oop hexp recall in 12 month
	
	gen hh_hexp_alt =  fp511 // OOP hhexp recall in 12 month from expenditure module
	replace hh_hexp_alt = 0 if fp511==-1
		
	gen hh_hexp_coicop_61	=.															
    gen hh_hexp_coicop_62	=.																
    gen hh_hexp_coicop_63	=.															
    gen hh_hexp_coicop_64	=.															
	
																					// </_hexp_>
																					
* WELFARE AGGREGATE		
	gen hh_exp= expense
/*													** <_exp_>
	gen hh_exp= fexp 	// Total annual household expenditure 
	replace hh_exp = fexp_est if fexp == -1 | fexp ==-2 // use extimated wel agg if hh member refuse to answer/don't know wel agg														// </_exp_>
	replace hh_exp = fexp1 if (fexp == -1 | fexp ==-2) & !inlist(fexp1,-8,-1)  // use "adjusted extimated wel agg" to replace "extimated wel agg" if avaliable
*/
* Food / non-food expenditure (annual)												** <_fexp_>
	ren food hh_fexp																	// Annual total household food expenditures
	gen hh_nfexp = hh_exp-hh_fexp													
	count if hh_nfexp<0	 // 0
																					// </_fexp_>
* survey variables																	** <_svy_>
	ren familysize18 hh_size	
	ren subpopulation hh_strata
	ren psu hh_psu																		// search also for clusterm enumerating area ea groupement

	ren  provcd18 hh_region															
	gen  hh_region_rep = 1	// 9													
	
	gen hh_urban=urban18==1 if inlist(urban18,0,1) // 237 hh missing 
	
	gen hh_sampleweight =1 						 // need to be updated when household weight released (expecting in 2020 summer)								
	gen popweight = int(hh_size*hh_sampleweight)
																			// </_svy_>
																				
*spec
	gen spec = "Ch"												// first capital letter: C or I: either consumption or income aggregate. Iat = Income_after_tax. Ibt= Income_before_tax
																// second small letter: health exp comes from h=health_section  c=consumption_section m=mix_of_section  d=diary

	gen int  IP_recall = 365														// in days
	gen 	 IP_level = "ind"														// "hh" or "ind"
	gen byte IP_itemN = 2														// number of items
	gen int	 OP_recall = 365
	gen 	 OP_level = "ind"
	gen byte OP_itemN = 6

	
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
	replace PPP = 4.1131082 if PPP==.
	drop if _merge==2
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

For China-rural 2016
------------------------- Distributional Estimation --------------------
                                         Gini index(%): 33.1798
                         median income(or expenditure): 195.893560245584
                                             MLD index: 0.182151
                                 polarization index(%): 27.8001
                           distribution corrected mean: 43.1759(PPP$)
            mean income/expenditure of the poorest 50%: 35.8088(PPP$)
                                       estimate median: 52.9999(PPP$)
------------------------------------------------------------------------

For China-urban 2016
------------------------- Distributional Estimation --------------------
                                         Gini index(%): 36.1248
                         median income(or expenditure): 353.108893536246
                                             MLD index: 0.218692
                                 polarization index(%): 31.3856
                           distribution corrected mean: 76.3559(PPP$)
            mean income/expenditure of the poorest 50%: 61.3638(PPP$)
                                       estimate median: 95.5353(PPP$)
------------------------------------------------------------------------
*/
