********************************************************************************
********************************* Death ************************************
********************************************************************************
use "${OUT}/append_covariances.dta",clear	
	drop *_b*
	replace id = 21009398 if id == 21009300

	gen a = 1  if (id_year ==wave) | (inlist(id_year,8,9) & wave==8) |(id_year == 12 & wave ==11)|(inlist(id_year,18,19) & wave ==18) 
	replace a = 1 if id == 22005502 & wave == 5
	replace a = 1 if id == 32056002 & wave == 8
	replace a = 1 if id == 32073900 & wave == 5
	replace a = 1 if id == 44026502 & wave == 5
	replace a = 1 if id == 44026505 & wave == 8
	replace a = 1 if id == 44052100 & wave == 8
	replace a = 1 if id == 44058602 & wave == 5
	
	codebook id // 44,619   individual
	
	keep if a == 1
	duplicates drop	

********************** deal with string in d14 ******************
	foreach var in d14income d14wpayot d14fullda d14medcos d14pcgday d14bedday d14drkmch d14pocket d14carcst{
			replace `var' = "" if !regexm(`var',"^[0-9]*$")		
	}
	destring d14*,replace	
	
********************** socialecon ******************
	* married
	foreach k in 0 2 5 8 11 14 18 {
		gen maritaltemp_`k'=d`k'marry if dth`k' == 1  & !inlist(d`k'marry,-9,-8,-7,-6,8,9) 
		recode maritaltemp_`k' (1 = 1 "currently married and living with spous") (2 3 5 = 2 "separted, divorced or never married") (4 = 3 "widowed" ),gen(marital_`k') label(marital_`k')
		drop maritaltemp_`k'
	}	
	
	* living arrangement 
	foreach k in 0 2 5 8 11 14 18 {
		gen Dlivarrtemp_`k'=d`k'livarr if dth`k' == 1  & !inlist(d`k'livarr,-9,-8,-7,-1,8,9) 
	}	

	foreach k in 0 2 5 8{
		recode  Dlivarrtemp_`k' (0 = 1 "institution") (1 2 = 2 "Alone") (3/7 = 3 "With Families"),gen(Dlivarr_`k') label( Dlivarr_`k')
		drop Dlivarrtemp_`k'
	}		
	
	foreach k in 11 14 18 {
		recode  Dlivarrtemp_`k' (1 = 1 "institution") (2 3 = 2 "Alone") (4/7 = 3 "With Families"),gen(Dlivarr_`k') label( Dlivarr_`k')
		drop Dlivarrtemp_`k'
	}		
	
	* place of residence of death
	foreach k in 0 2 5 8 11 {
		generate residencetemp_`k'=d`k'resid  if dth`k' == 1 & !inlist(d`k'resid,8,9) 
		recode residencetemp_`k' ( 1 2 = 1 "urban (city or town)")  (3 = 2 "rural"),gen(residence_`k') label("residence_`k'")
		drop residencetemp_`k'
	}			
	
	* place of province
	foreach k in 0 2   {
		cap ren d`k'provin d`k'provid
		generate prov_`k'=d`k'provid  if dth`k' == 1 
	}			

********************** health institute ******************
	* doctor
	foreach k in 0 2 5 8 11 14 18{
		gen Dhavedoc_`k'=d`k'doctor if dth`k' == 1  & !inlist(d`k'doctor,-1,8,9,999) 		
	}	
	* doctor with licence 
	foreach k in 0 2 5 8 11 14 18{
		gen Dhavedoclic_`k'=d`k'licdoc if dth`k' == 1  & !inlist(d`k'licdoc,-1,8,9,999) 		
	}		

********************** finance & hh condition******************		
	* hhsize
	foreach k in 0 2 5 8 11 14 {
		gen hhsize_`k'=d`k'person+1 if dth`k' == 1  & !inlist(d`k'person,-1,88,98,99,888) 
	}		
	* hhgener
	foreach k in 2 5 8 11 14 {
		gen Dhhgener_`k'=d`k'gener if dth`k' == 1  & !inlist(d`k'gener,-1,8,9,888) 
	}	
	
	* income
	foreach k in 0 2 5 18{
			generate hhIncomepercap_`k'=d`k'income  if dth`k' == 1 & !inlist(d`k'income,88888,99999)
			replace hhIncomepercap_`k' =100000  if d`k'income == 99998
	}	
	
	foreach k in 8 11 14{
			generate hhIncome_`k'=d`k'income  if dth`k' == 1 & !inlist(d`k'income,99,888,88888,99999) 
			replace hhIncome_`k'=100000  if d`k'income == 99998
			generate hhIncomepercap_`k'=hhIncome_`k'/hhsize_`k'
	}

**# Bookmark #3
	* Insurance
	cap ren d11insur d11d22
	
	foreach k in 11 14 18{
		ren d`k'd22 insuranceRetire_`k'
	}
	
	recode insuranceRetire* (-9/-1 8 9 = .)
	
	* retirement
	foreach k in 11 {
		recode d`k'retire (-9/-1 9 = .) (1 2 = 1 "Yes") (3= 0 "No" ),gen(retiredWPension_`k') label("retired_`k'")
		recode d`k'retyr (9999 8888 -9/-1= .),gen(retiredYear_`k')
		destring d`k'retpen ,replace
		recode d`k'retpen (9999 8888 -9/-1= .),gen(pensionYearly_`k')
		replace pensionYearly_`k' = pensionYearly_`k'*12  // 居然有0 怎么办？		
	}	
	
********************** death cost & care ******************
	* medicine cost
	foreach k in 0 2 5 8 11 14 18{
			gen hexpFampaid_`k'=d`k'medcos if dth`k' == 1  & !inlist(d`k'medcos,888,99,88,88888,99999) 
			replace hexpFampaid_`k'=100000  if d`k'medcos == 99998
	}		

	* OOP
	foreach k in 5 8 11 14 18{
			gen DOOPhexp_`k'=d`k'pocket if dth`k' == 1  & !inlist(d`k'pocket,88888,99,88,99999) 
			replace DOOPhexp_`k'=100000  if d`k'pocket == 99998				
	}	
	
	* daily care fee
	foreach k in 5 8 11 14 18{
		gen DcarehexpD_`k'=d`k'carcst if dth`k' == 1  & !inlist(d`k'carcst,88888,99999) 
		replace DcarehexpD_`k'=100000  if d`k'carcst == 99998			
	}	
	
	* payer for health exp
	foreach k in 0 2 5 8 11 14 18{
		gen hexpPayer_`k'=d`k'whopay if dth`k' == 1  & !inlist(d`k'whopay,88,98,99) 	
	}	

	* payer for care services
	foreach k in 5 8 11 14 18{
		gen Dpayercare_`k'=d`k'carpay if dth`k' == 1  & !inlist(d`k'carpay,88,98,99) 		
	}	

	* monthly direct care fee
	foreach k in 5 8 11 14 {
		gen DcarehexpM_`k'=d`k'dircst if dth`k' == 1  & !inlist(d`k'dircst,888,88888,99999) 
		replace DcarehexpM_`k'=100000  if d`k'dircst == 99998			
	}	
	foreach k in  18{
		gen DcarehexpM_`k'=d`k'dircst1 if dth`k' == 1  & !inlist(d`k'dircst1,888,88888,99999) 
		replace DcarehexpM_`k'=100000  if d`k'dircst1 == 99998			
	}		
	* monthly care daies given
	foreach k in 5 8 11 14 18{
			gen DcaredayM_`k'=d`k'pcgday if dth`k' == 1  & !inlist(d`k'pcgday,88,99,98) 		
	}	
	
	* care daies required
	foreach k in 5 8 11 14 18{
		//cap replace d14fullda = ""  if d14fullda >"365" & d14fullda<"4015"
		//destring d14fullda,replace
		gen Dcaredayneede_`k'=d`k'fullda if dth`k' == 1  & !inlist(d`k'fullda,88,98,99,8888,9999) 
		replace Dcaredayneede_`k'=10000  if d`k'fullda == 9998		
	}			
	
********************** deathrelated ***********
	* place of death
	foreach k in 0 2 5 8 11 14 18{
		gen Dplace_`k'=d`k'dplace if dth`k' == 1  & !inlist(d`k'dplace,8,9) 		
	}		

	* cause of death
	foreach k in 0 2 5  18{
			gen Dcause_`k'=d`k'cause if dth`k' == 1  & !inlist(d`k'cause,66,88,99) 
	}		
	
	* first caregiver or main caregiver
	foreach k in 0 2 5 8 11 14 18{
		gen Dcargiv_`k'=d`k'cargiv if dth`k' == 1  & !inlist(d`k'cargiv,8,9,99) 	
	}		
	
	
	* bed bidden
	foreach k in 0 2 5 8 11 14 18{
			gen Dbedri_`k'=d`k'bedrid if dth`k' == 1  & !inlist(d`k'bedrid,8,9) 		
	}		
	
	* bed bidden day
	foreach k in 0 2 5 8 11 14 18{
		gen Dbedday_`k'=d`k'bedday if dth`k' == 1  & !inlist(d`k'bedday,-1,888,999,998,9999,8888,9998) 		
	}		
	
	* dage adjustment
	replace dage = d0vdage if  dage==. &  d0vdage>0 & d0vdage<150

********************** health condition but befire dying ***********	
	****************************** disease
	foreach k in 0 2 8 11 14 {
			foreach disease in hypert diabet heart cvd pneum tuberc glauco prosta gastri parkin bedsor dement neuros arthri others{
				gen `disease'_`k'=d`k'`disease' if dth`k' == 1  & !inlist(d`k'`disease',-1,8,9,4,5) 
		}
	}
	foreach k in 18{
			foreach disease in hypert diabet heart cvd pneum tuberc glauco prosta gastri parkin bedsor dement   arthri {
				gen `disease'_`k'=d`k'`disease' if dth`k' == 1  & !inlist(d`k'`disease',-1,8,9,4,5) 
		}
	}	
	foreach k in 0 2 8 11 14 18{
				ren  (hypert_`k' diabet_`k' heart_`k' cvd_`k' pneum_`k' tuberc_`k' glauco_`k' prosta_`k' gastri_`k' parkin_`k' bedsor_`k' dement_`k' arthri_`k' )	(hypertension_`k'  diabetes_`k' heartdisea_`k' strokecvd_`k' copd_`k' tb_`k' glaucoma_`k' prostatetumor_`k' ulcer_`k' parkinson_`k' bedsore_`k' dementia_`k' arthritis_`k')
	}

	foreach k in  8 11 14 18{
			foreach disease in  cancer{
				gen `disease'_`k'=d`k'`disease' if dth`k' == 1  & !inlist(d`k'`disease',-1,8,9,4,5) 
		}		
	}	
	foreach k in  8 11 14{
			foreach disease in  gyneco{
				gen `disease'_`k'=d`k'`disease' if dth`k' == 1  & !inlist(d`k'`disease',-1,8,9,4,5) 
		}		
	}	
		
	****************************** ADL
	foreach k in 0 2 5 8 11 14 18{
			recode d`k'bathfu  d`k'dresfu d`k'toilfu d`k'movefu d`k'contfu d`k'feedfu  (1 = 0 "do not need help") (2 3 = 1 "need help") (-1 -8 -7 -9 8 9 = .),gen(bathing_`k' dressing_`k' toileting_`k' transferring_`k' continence_`k' feeding_`k') label(adl_row_`k')
			
			egen adlMiss_`k'= rowmiss(bathing_`k' dressing_`k' toileting_`k' transferring_`k' continence_`k' feeding_`k')
			egen adlSum_`k' = rowtotal(bathing_`k' dressing_`k' toileting_`k' transferring_`k' continence_`k' feeding_`k')
			
			replace adlSum_`k' = . if adlMiss_`k' > 1 
			
			gen adl_`k' = (adlSum_`k' > 0) if adlSum_`k' != .
			label define adl_`k' 0"0:without ADL" 1"1:with ADL"
			label value adl_`k' adl_`k'				
	}	
	
	****************************** lifestyle 
	foreach k in 0 2 5 8 11 14 18{
			* Smoking
			recode d`k'smoke  (-8 -9 -7 -1 -1 8 9 = .)
			recode d`k'smktim (-8 -9 -7 -1 88 99 = .)
			gen smkl_`k' = 1 if !inlist(d`k'smoke,1,.)			// choose to code smk missing if r_smkl_pres is missing
			replace smkl_`k' = 2 if d`k'smoke == 1 & (d`k'smktim * 1.4) >= 0 & (d`k'smktim * 1.4) < 20
			replace smkl_`k' = 3 if d`k'smoke == 1 & (d`k'smktim * 1.4) >= 20 & (d`k'smktim * 1.4) <= 50
			label define smkl_`k' 1 "never" 3"light" 4 "heavy"
			label value smkl_`k'  smkl_`k' 
			
			* Drinking alchol
			recode d`k'drkmch (-1 88 99 = .)
			recode  d`k'drink d`k'knddrk (-1 8 9 = .)  
			gen alcohol_`k' = . 

				replace alcohol_`k' = d`k'smktim * 50 * 0.53 if d`k'knddrk == 1
				replace alcohol_`k' = d`k'smktim * 50 * 0.38 if d`k'knddrk == 2
				replace alcohol_`k' = d`k'smktim * 50 * 0.12 if d`k'knddrk == 3
				replace alcohol_`k' = d`k'smktim * 50 * 0.15 if d`k'knddrk == 4
				replace alcohol_`k' = d`k'smktim * 50 * 0.04 if d`k'knddrk == 5
				replace alcohol_`k' = d`k'smktim * 50 * 0.244 if d`k'knddrk == 6
			
			generate dril_`k'=.
			replace dril_`k'=1 if d`k'drink==2 
			replace dril_`k'=2 if gender==1 & d`k'drink==1 & inrange(alcohol_`k',0, 25)
			replace dril_`k'=2 if gender==0 & d`k'drink==1 & inrange(alcohol_`k',0, 15)
			replace dril_`k'=3 if gender==1 & d`k'drink==1 & (alcohol_`k' > 25 & alcohol_`k' < . )  // & not |
			replace dril_`k'=3 if gender==0 & d`k'drink==1 & (alcohol_`k' > 15 & alcohol_`k' < . )
			label define dril_`k' 1 "never" 3 "current & light" 4 "current & heavy"
			label value dril_`k' dril_`k'
	}

	
	keep if dthdate !=. 
	
	replace wave = 0 if dth0 == 1 
	replace wave = 2 if dth2 == 1 
	replace wave = 5 if dth5 == 1 
	replace wave = 8 if dth8 == 1 
	replace wave = 11 if dth11 == 1 
	replace wave = 14 if dth14 == 1 
	replace wave = 18 if dth18 == 1 

	
	foreach k in 0 2 5 8 11 14 18{
			drop if dth`k' == -9 
			//replace temp_keep = 1 if dth`k' == -8 | dth`k' == 1
			gen dth_`k' = dth`k'
	}
		//keep if temp_keep == 1
		//drop temp_keep

	foreach var of varlist *_2{
		local b = subinstr("`var'","_2","",.)
		ren `b'_2   `b'__3
	}	
	foreach var of varlist *_0{
		local b = subinstr("`var'","_0","",.)
		ren `b'_0   `b'__2
	}

	foreach var of varlist *_5{
		local b = subinstr("`var'","_5","",.)
		ren `b'_5   `b'__4
	}
	foreach var of varlist *_8{
		local b = subinstr("`var'","_8","",.)
		ren `b'_8   `b'__5
	}
	foreach var of varlist *_11{
		local b = subinstr("`var'","_11","",.)
		ren `b'_11   `b'__6
	}
	foreach var of varlist *_14{
		local b = subinstr("`var'","_14","",.)
		ren `b'_14   `b'__7
	}
	foreach var of varlist *_18{
		local b = subinstr("`var'","_18","",.)
		ren `b'_18   `b'__8
	}	

	gen death = 1 
	duplicates drop
	format dthdate %tdYMD
	
	gen year = year(dthdate)
	
	
	gen wave_alt = 2 if wave == 0
	replace wave_alt = 3 if wave == 2
	replace wave_alt = 4 if wave == 5
	replace wave_alt = 5 if wave == 8
	replace wave_alt = 6 if wave == 11
	replace wave_alt = 7 if wave == 14
	replace wave_alt = 8 if wave == 18
	
	sort id wave_alt
	
	replace wave = 2000 if wave == 0
	replace wave = 2002 if wave == 2
	replace wave = 2005 if wave == 5
	replace wave = 2008 if wave == 8
	replace wave = 2011 if wave == 11
	replace wave = 2014 if wave == 14
	replace wave = 2018 if wave == 18

	keep marital_* Dlivarr_* residence_* prov_* Dhavedoc* Dhavedoclic* hhsize* Dhhgener* hh* insurance* pension* retired* *hexp* Dpayercare* Dcare* Dplace_* Dcause_* Dcargiv_* Dbedri_* Dbedday_* hypertension_*  diabetes_* heartdisea_* strokecvd_* copd_* tb_* glaucoma_* prostatetumor_* ulcer_* parkinson_* bedsore_* dementia_* arthritis_* cancer_* bathing_* dressing_* toileting_* transferring* continence_* feeding_* adl_* smkl_* dril_* dth_*  id	dthdate	adl* Dpayercare__* DcaredayM__* Dcaredayneede__* adlSum__* dage edug occu ethnicity gender  wave

	gen dthyear = year(dthdate)
	drop if dthdate ==.
	recode dth__* ( 0 -8 -9 = .)
	
	duplicates drop
	
	gen death = 1 
	reshape long 	marital__ Dlivarr__ residence__ prov__ Dhavedoc__ Dhavedoclic__ hhsize__ Dhhgener__ hhIncomepercap__ hhIncome__  insuranceRetire__ pensionYearly__ retiredWPension__  hexpFampaid__ DOOPhexp__ DcarehexpD__ hexpPayer__ DcarehexpM__  Dplace__ Dcause__ Dcargiv__ Dbedri__ Dbedday__ hypertension__  diabetes__ heartdisea__ strokecvd__ copd__ tb__ glaucoma__ prostatetumor__ ulcer__ parkinson__ bedsore__ dementia__ arthritis__ cancer__ bathing__ dressing__ toileting__ transferring__ continence__ feeding__ adl__ smkl__ dril__ dth__  adlMiss__ retiredYear__ Dpayercare__ DcaredayM__ Dcaredayneede__ adlSum__ ,  i(id) j(followup) 	
	keep if dth__==1 
	
	
	foreach var of varlist *__{
		local a = subinstr("`var'","__","",.)
		ren `a'__ `a'
	}	

save "${OUT}/append_covariances_tempdeath.dta",replace	
