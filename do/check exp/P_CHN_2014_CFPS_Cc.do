////////////////////////////////////////////////////////////////////////////////
///////// 			CHN_2014_CFPS                 			///////////////////
////////////////////////////////////////////////////////////////////////////////

/* 
Preparation file for China, 2014
	
	Instrument: P63, p115-118, P156-159, P267,P280 in "CFPS 2014.pdf"; 

	
	hexp sepc: In health module: For ind age >=16, total IP, OOP-IP, total OP, total IPexp on medical treatment, total IPexp on non-medical (food, nursary care, lodging) recall in 12 month. 
								 For ind age <=15, OOP hexp and total hexp recall in 12 month 
		--> for hexp: sum up OOP-IP and total OP for ind age >=16, use OOPhexp for ind age <=15
		--> generate hexp_alt: vary on choice on IP expense (use "total IPexp on medical treatment" replacing "OOP-IP")
			In Expense module: household level OOP health expense recall in 12 months
	
	Wel agg: 2 ready to use expenditure: [fexp] An approximated total annual hh expenditure. [expense] An adjusted sum of expense from expense module. 
		--> For hh missing [expense], generated a wel agg by suming adjusted expense and replace. 
		--> if still missing wel agg, drop. 14 hh dropped.  

	Weight: 4 hh wieght avaliable: 	fswt_natcs14 fswt_rescs14 fswt_natpn1014 fswt_respn1014
		--> use [fswt_natcs14]:  Cross-sectional weight (family level): total sample
		
	70 hh have no wel agg; 278 hh have food expense higher than wel agg --> drop
		
	Gaul Code: 29 out of 31 regions covered				
		
*/

* set up																		
**********
tempfile t1 t2 t3 t4 tpf Gaul
local refid "CHN_2014_CFPS"

*******************************************************************************************
				***   IMPORT AND MERGE FILES AT HH LVL   ***
*******************************************************************************************
																				** <_import_>
																				
*Health Expenditure in health module
* Adult: age >=16 
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2014adult_201906.dta", clear				
	ren fid14	hh_id
	isid 	pid

	* health expense
	gen hexp=metotal
	gen hexp_OOP  = qp512a 
	gen hexp_IP = qp506a
	gen hexp_OP = qp510a 
	replace hexp_OP = qp511a if qp501!=1

	foreach var of varlist hexp* qp510a qp511a{
		replace `var' = 0 if `var'==-2 | `var'==-1 | `var'==. |`var'==-8
	}	
	count if qp510a>qp511a & qp501 != 1 //0. 
	
	collapse (sum) hexp*, by(hh_id)
	sort hh_id
save `t1',replace

* Child: age <=15
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2014child_201906.dta", clear				
	ren fid14	hh_id
	isid 	pid

	* health expense
	gen hexp=metotal
	gen hexp_OOP  = wc701
	gen hexp_IP = wc7a
	gen hexp_OP = wc7b
	replace hexp_OP = wc7c if wc401!=1
	
	foreach var of varlist hexp* wc7b wc7c{
		replace `var' = 0 if `var'==-2 | `var'==-1 | `var'==. |`var'==-8
	}	
	
	count if wc7b>wc7c & wc401!=1 //0

	collapse (sum) hexp*, by(hh_id)

	merge 1:1 hh_id using `t1'
	tab _m
	drop _m
	collapse (sum) hexp*, by(hh_id)
	sort 	hh_id
save `t2',replace

* Gaul
use "${OUT}/Subnational regions.dta",clear
	keep if iso3c=="CHN"
	sort gl_adm1_name gl_adm1_name_alt
save `Gaul',replace

*Wel Agg & hexp in expense module
use "${SOURCE}/WB MICRO DATA/`refid'/Data/ecfps2014famecon_201906.dta", clear
	ren fid14	hh_id
	isid hh_id
	sort hh_id
	
	merge 1:1 hh_id using `t2'
	tab _m
	drop if _m==2 // 178 hh have no wel agg
	foreach var of varlist hexp*{
		replace `var' = 0 if `var'==.
	} // 162 hh have 0 hexp
	drop _m

	* hexp in expense module
	gen hexp_OOPexpense = fp511 // OOP health expense recall in 12 month 
	
	* Generate Wel Agg 
	gen wel = expense // an adjusted sum of expense
	* Wel agg alt 1: sum of adjusted expense
	egen wel_alt1 = rowtotal(daily dress eec eptran epwelf food house med mortage other trco) // sum of adjusted expense
	replace wel = wel_alt1 if wel ==. 
	
	* Not used: Wel agg Alt 2: annualized sum of unadjusted expense, for comparasion. 
	foreach var of varlist fp3* fp4* fp5* fu*{
		replace `var' = 0 if `var'==-2 | `var'==-1 | `var'==. |`var'==-8
	}	
	egen welagg_month = rowtotal(fp3 fp301 fp401 fp402 fp403 fp404 fp405 fp406 fp407 fp408)
	egen welagg_year = rowtotal(fp501 fp509 fp510 fp511 fp512 fp513 fp514 fp515 fp516 fp518 fp519 fp520 fp521 fu101 fu201)
	gen wel_alt2 = welagg_month*12 + welagg_year
	
	* Gaul Code
	label define province 11 "Beijing Shi" 12 "Tianjin Shi" 13 "Hebei Sheng" 14 "Shanxi Sheng" 15 "Nei Mongol Zizhiqu" 21 "Liaoning Sheng" 22 "Jilin Sheng" ///
		23 "Heilongjiang Sheng" 31 "Shanghai Shi" 32"Jiangsu Sheng" 33"Zhejiang Sheng" 34"Anhui Sheng" 35"Fujian Sheng" 36"Jiangxi Sheng" 37"Shandong Sheng" ///
		41 "Henan Sheng" 42"Hubei Sheng" 43 "Hunan Sheng" 44 "Guangdong Sheng" 45 "Guangxi Zhuangzu Zizhiqu" 46 "Hainan Sheng" 50 "Chongqing Shi" 51 "Sichuan Sheng" ///
		52 "Guizhou Sheng" 53 "Yunnan Sheng" 54 "Xizang Zizhiqu"  61 "Shaanxi Sheng" 62 "Gansu Sheng" 63 "Qinghai Sheng" 64 "Ningxia Huizu Zizhiqu" 65 "Xinjiang Uygur Zizhiqu"
	label value provcd14 province
	
	decode provcd14, gen(gl_adm1_name)
	sort gl_adm1_name
	merge m:1 gl_adm1_name using `Gaul'
	tab _m
	
	drop if _m==2 //  2 provinces are not covered in the data 
	drop _m 	

*******************************************************************************************
					***   COMMON VARIABLES   ***
*******************************************************************************************
																			** <_common_vars_>

* Health exp																		** <_hexp_>	
*************
	* Total exp aggregates
	gen hh_hexp = hexp_OOPexpense   // OOP health expense at hh level recall in 12 months from expense module 
	
	gen hh_hexp_coicop_61	=.															
    gen hh_hexp_coicop_62	=.																
    gen hh_hexp_coicop_63	=.															
    gen hh_hexp_coicop_64	=.															
	
																					// </_hexp_>
																					
* WELFARE AGGREGATE																	** <_exp_>
	ren  wel hh_exp	// Total annual household expenditure or Total Annual income
																					// </_exp_>


* Food / non-food expenditure (annual)												** <_fexp_>
	ren food hh_fexp																	// Annual total household food expenditures
	replace hh_fexp = 0 if hh_fexp==.
	gen hh_nfexp = hh_exp-hh_fexp													
	count if hh_nfexp<0	 // 278
	drop if hh_nfexp<0		// 278 dropped																		// </_fexp_>
																																							
* survey variables																	** <_svy_>
	ren familysize hh_size	
	gen hh_strata =subpopulation10
	ren countyid14 hh_psu																		// search also for clusterm enumerating area ea groupement
	
	ren  provcd14 hh_region															
	gen  hh_region_rep = 1	// 9													
	
	gen hh_urban = urban14==1 if inlist(urban14,0,1)
	ren fswt_natcs14 hh_sampleweight  														
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

	
/*																			** </_common_vars_>
cls
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

For China rural 2014
------------------------- Distributional Estimation --------------------
                                         Gini index(%): 33.7564
                         median income(or expenditure): 170.204197766267
                                             MLD index: 0.18929
                                 polarization index(%): 28.2837
                           distribution corrected mean: 37.3435(PPP$)
            mean income/expenditure of the poorest 50%: 30.8312(PPP$)
                                       estimate median: 46.0495(PPP$)
------------------------------------------------------------------------

For China urban 2014

------------------------- Distributional Estimation --------------------
                                         Gini index(%): 36.4915
                         median income(or expenditure): 318.37348059924
                                             MLD index: 0.229848
                                 polarization index(%): 31.8802
                           distribution corrected mean: 68.0701(PPP$)
            mean income/expenditure of the poorest 50%: 54.3397(PPP$)
                                       estimate median: 86.1374(PPP$)
------------------------------------------------------------------------
*/

