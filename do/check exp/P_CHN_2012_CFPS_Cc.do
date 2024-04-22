////////////////////////////////////////////////////////////////////////////////
///////// 			CHN_2012_CFPS                 			///////////////////
////////////////////////////////////////////////////////////////////////////////

/* 
Preparation file for China, 2012

	Instrument: p40-44 in "CFPS 2012 questionnaire.pdf"
	
	hexp sepc: avaliable in health and expense module. In expense module: 
		--> extract
	
	Wel agg: [expense] An adjusted sum of expense from expense module. 
		--> For hh missing [expense], generated a wel agg by suming adjusted expense and replace. 
		--> if still missing wel agg, drop. 14 hh dropped.  

	70 hh have no wel agg --> drop
		
	Gaul Code: 25 out of 31 regions covered, covered 95% of national population						
			
*/

* set up																		
**********
tempfile t1 t2 t3 t4 tpf Gaul
local refid "CHN_2012_CFPS"

*******************************************************************************************
				***   IMPORT AND MERGE FILES AT HH LVL   ***
*******************************************************************************************
																				** <_import_>
																				
*Health Expenditure in health module											//p70-74, P153-158 in "CFPS 2012 questionnaire.pdf"
* Adult: age >=16 
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2012adult_201906.dta", clear				
	ren fid12	hh_id
	isid 	pid
	
	foreach var of varlist qp5*{
		replace `var' = 0 if `var'==-8 | `var'==-1 | `var'==.| `var'==-2
	}	
	* health expense recall in 12 month:
	* IP cost on medical treatment 
	egen hexp_IPmed= rowtotal(qp508_a_1 qp508_a_2 qp508_a_3 qp508_a_4 qp508_a_5 qp508_a_6 qp508_a_7 qp508_a_8 qp508_a_9 qp508_a_10 qp508_a_11 qp508_a_12)
	* IP cost on non-medical treatment (food, nursary care, lodging)
	egen hexp_IPnonmed = rowtotal(qp507_a_1 qp507_a_2 qp507_a_3 qp507_a_4 qp507_a_5 qp507_a_6 qp507_a_7 qp507_a_8 qp507_a_9 qp507_a_10 qp507_a_11 qp507_a_12)
	
	gen hexp_IP = qp501followuptotal 

	gen hexp_OOPIP = qp509a	// out-of-pocket IP expense
	gen hexp_OP = qp510		// total OP hexp
	gen hexp_total = qp511  // total hexp (subquestion for hh pay no IP visit)
	gen hexp_OOPOP = qp512 	// out-of-pocket health expense, no data
	
	* hh_hexp 
	gen hexp_adult = hexp_OOPIP + hexp_OP 								// out-of-pocket IP expense + OP hexp
	replace hexp_adult = hexp_total 		if   qp501 ==0				// total hexp (from subquestion for hh pay no IP visit)
	* hh_hexp_alt 
	gen hexp_adult_alt = hexp_IPmed + hexp_OP      						// total IP expense on medical treatment  + tptal OP hexp
	replace hexp_adult_alt = hexp_total  	if   qp501 ==0				// total hexp (from subquestion for hh pay no IP visit)

	collapse (sum) hexp*, by (hh_id)
save `t1',replace

* Child: age <=15
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2012child_201906.dta", clear				
	ren fid12	hh_id
	isid 	pid
	gen hexp_child = wc7 	//  health expense recall in 12 month
	gen hexp_OOPchild = wc701 // OOP health expense recall in 12 month
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'==-8 | `var'==-1 | `var'==.| `var'==-2
	}	
	collapse (sum) hexp*, by (hh_id) 
		
	merge 1:1 hh_id using `t1'   // have checked no duplicates on ind level
	drop _m
	
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'==.
	}	

	g hexp = hexp_adult + hexp_OOPchild
	g hexp_alt = hexp_adult_alt + hexp_OOPchild
	
	duplicates drop hh_id,force
	sort 	hh_id
save `t2',replace

* Gaul
use "${OUT}/Subnational regions.dta",clear
	keep if iso3c=="CHN"
	sort gl_adm1_name gl_adm1_name_alt
save `Gaul',replace

*Wel Agg & hexp in expense module												// p40-44 in "CFPS 2012 questionnaire.pdf"
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2012famecon_201906.dta", clear
	ren fid12	hh_id
	isid hh_id
	sort hh_id
	merge 1:1 hh_id using `t2'
	tab _m
	drop if _m==2 // 70 hh have no wel agg
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'==.
	} // 78 hh have 0 hexp
	drop _m

	* hh total OOP hexp recall in 12 month in expense module
	gen hexp_total_OOPexp = fp509 
	replace hexp_total_OOPexp = fp509_t if fp509 ==. | fp509 ==-8
	replace hexp_total_OOPexp = 0 if hexp_total_OOPexp==-1 | hexp_total_OOPexp==.| hexp_total_OOPexp==-2
	
	* Generate Wel Agg 
	gen wel = expense // an adjusted sum of expense
	* Wel agg alt 1: sum of adjusted expense
	egen wel_alt1 = rowtotal(food dress house daily med trco eec other eptran epwelf mortage) // sum of adjusted expense
	replace wel = wel_alt1 if wel ==. 
	
	drop if wel ==0 // 14 hh drop 
	
	* Wel agg Alt 2: annualized sum of unadjusted expense, for comparasion. Not used.
	foreach var of varlist fp30* fp4* fp5* {
		replace `var' = 0 if `var'==-2 | `var'==-1 | `var'==. |`var'==-8
	}	
	egen welagg_week = rowtotal(fp301 fp302 fp303 fp304)
	egen welagg_month = rowtotal(fp401 fp402 fp403 fp404 fp405 fp407 fp408)
	egen welagg_year = rowtotal(fp502 fp504 fp505 fp506 fp507 fp508 fp509 fp510 fp511 fp513 fp515 fp516)
	gen wel_alt2 = welagg_week*52 + welagg_month*12 + welagg_year
	
	* Gaul Code
	label define province 11 "Beijing Shi" 12 "Tianjin Shi" 13 "Hebei Sheng" 14 "Shanxi Sheng" 15 "Nei Mongol Zizhiqu" 21 "Liaoning Sheng" 22 "Jilin Sheng" ///
		23 "Heilongjiang Sheng" 31 "Shanghai Shi" 32"Jiangsu Sheng" 33"Zhejiang Sheng" 34"Anhui Sheng" 35"Fujian Sheng" 36"Jiangxi Sheng" 37"Shandong Sheng" ///
		41 "Henan Sheng" 42"Hubei Sheng" 43 "Hunan Sheng" 44 "Guangdong Sheng" 45 "Guangxi Zhuangzu Zizhiqu" 46 "Hainan Sheng" 50 "Chongqing Shi" 51 "Sichuan Sheng" ///
		52 "Guizhou Sheng" 53 "Yunnan Sheng" 54 "Xizang Zizhiqu"  61 "Shaanxi Sheng" 62 "Gansu Sheng" 
	label value provcd province
	decode provcd, gen(gl_adm1_name)
	sort gl_adm1_name
	merge m:1 gl_adm1_name using `Gaul'
	tab _m
	drop if _m!=3 // 3 hh have no province data, 6 provinces are not covered in the data 
	drop _m 	
																				// </_import_>

*******************************************************************************************
					***   COMMON VARIABLES   ***
*******************************************************************************************
														** <_common_vars_>

* Health exp																		** <_hexp_>	
*************
	* Total health expenditure aggregates
	gen hh_hexp = hexp_total_OOPexp				// out-of-pocket health expense recall in 12 month


	gen hh_hexp_coicop_61	=.															
    gen hh_hexp_coicop_62	=.																
    gen hh_hexp_coicop_63	=.															
    gen hh_hexp_coicop_64	=.															
	
																					// </_hexp_>
																					
* WELFARE AGGREGATE																	** <_exp_>
	ren expense hh_exp	// Total annual household expenditure or Total Annual income
																					// </_exp_>


* Food / non-food expenditure (annual)												** <_fexp_>
	ren food hh_fexp																	// Annual total household food expenditures
	gen hh_nfexp = hh_exp-hh_fexp													
	count if hh_nfexp<0	 // 0 
																					// </_fexp_>
																																								
* survey variables																	** <_svy_>
	ren familysize hh_size	
	ren subpopulation hh_strata 
	ren countyid hh_psu																		// search also for clusterm enumerating area ea groupement
	
	ren provcd hh_region															
	gen  hh_region_rep =1 	// 25 out of 31 regions, covered 95% of national population													

	******************************************************** 2urban: urban12 urbancomm;  4 weight: fswt_natcs12 fswt_rescs12 fswt_natpn1012 fswt_respn1012
	ren urbancomm hh_urban
	ren fswt_natcs12 hh_sampleweight  														
	gen popweight = int(hh_size*hh_sampleweight)
																					// </_svy_>
																				
*spec
	gen spec = "Cc"												// first capital letter: C or I: either consumption or income aggregate. Iat = Income_after_tax. Ibt= Income_before_tax
																// second small letter: health exp comes from h=health_section  c=consumption_section m=mix_of_section  d=diary

	gen int  IP_recall = .														// in days
	gen 	 IP_level = ""														// "hh" or "ind"
	gen byte IP_itemN = .														// number of items
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

For China Rural 2012
------------------------- Distributional Estimation --------------------
                                         Gini index(%): 39.5441
                         median income(or expenditure): 118.114883079999
                                             MLD index: 0.265068
                                 polarization index(%): 33.3343
                           distribution corrected mean: 25.8714(PPP$)
            mean income/expenditure of the poorest 50%: 20.5451(PPP$)
                                       estimate median: 31.9565(PPP$)
------------------------------------------------------------------------
For China Urban 2012

------------------------- Distributional Estimation --------------------
                                         Gini index(%): 35.3534
                         median income(or expenditure): 277.332206317783
                                             MLD index: 0.208454
                                 polarization index(%): 29.4875
                           distribution corrected mean: 60.7276(PPP$)
            mean income/expenditure of the poorest 50%: 49.6649(PPP$)
                                       estimate median: 75.0335(PPP$)
------------------------------------------------------------------------

*/

