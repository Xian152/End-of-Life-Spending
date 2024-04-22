use "${OUT}/analyses.dta",clear		
	drop if deathstatus==1
	keep if inlist(wave,2011,2014,2018)
	keep if age >=65
	* adjust for disable person
		* disease disable 
		gen disable_disase = .
		foreach k in hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis{
			replace disable_disase = 1 if `k' == 1
		}
		egen diseasemiss = rowmiss(hypertension diabetes heartdisea strokecvd copd tb cataract glaucoma cancer prostatetumor ulcer parkinson bedsore arthritis)
		replace disable_disase = . if diseasemiss == 14
		recode disable_disase  (.=0)

		* disease disable 
		gen disable_ADL = adlSum >0  if adlSum!=.
		gen disable_IADL = iadlSum >0  if iadlSum!=.
		
		* disable ci
		gen disable_ci = ciBi 
		replace disable_ci  = . if ciMissing >= 2	
	
		** disable general
		gen disable = disable_ci==1 | disable_ADL==1 |disable_IADL ==1 |disable_disase == 1 if disable_ci!=.  & disable_ADL!=.  & disable_IADL!=.  & disable_disase !=.  
	
		* 调整成处理前的全人群
		bysort id: egen sumdisable_ADL = sum(disable_ADL) 	
		keep if	sumdisable_ADL >0 
		
		foreach k in disable_disase disable_ci disable_IADL disable_ADL disable {
			gen `k'_2014 = `k' if wave ==2014 |wave ==2011
			bysort id: egen `k'_pre = sum(`k'_2014)
		}
		* 调整treatement 
		replace treated = 0 if disable_ADL_pre ==0
		replace treated = 0 if disable_ADL_pre ==0
	
	* 调整成平衡panel
	/*cap drop count
	bysort id: gen count = _N
	keep if count ==2
	codebook id  //   3,353
	gen year_id = wave==2018
	*/
	
	bysort id : egen treatedtemp = max(treated)
	replace treated= treatedtemp
	drop treatedtemp
	
	gen treated_id = treated * year_id

		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540		
*********************************************************
**************** health expenditure	**************
*********************************************************
/*preserve
	sort treated wave
	egen av_dk = mean(hexpFampaid), by (treated wave)
	duplicates drop treated wave, force
	keep av_dk treated wave
	reshape wide av_dk, i(wave) j(treated)
	ren (av_dk1 av_dk0) (Treated Controled )
	label variable Treated "Treated"
	label variable Controled  "Controled"
	
	twoway connected Treated  Controled wave, ytitle("PM 2.5" ) xtitle(Year) xline(2014) ylabel(,nogrid)
restore	
*/

cls		
	preserve
		drop if hexpFampaid== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reg hexpFampaid treated_id i.year_id i.treated age gender  coresidence residence marital edug , cluster(市)
	outreg2 using "${OUT}/hexp_cov_fixed.xls",replace stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore
	foreach k in hexpFampaidOP hexpFampaidIP hexpIndpaid hexpIndpaidOP hexpIndpaidIP  ADLhexpcare{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reg `k' treated_id i.year_id i.treated age gender  coresidence residence marital edug , cluster(市)
		outreg2 using "${OUT}/hexp_cov_fixed.xls",append stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore
	}

*********************************************************
**************** disease caregiver	********
*********************************************************	
	gen caregiverfamily = caregiverSon==1 | caregiverDaughter==1 | caregiverDinL==1 |  caregiverSinL==1 | caregiverChild==1 | caregiverGrandC==1 | caregiverOthFamily==1 		if caregiverSon!=.
	
	gen caregivernonfamilygovern = caregiverSocial==1 |  caregiverCaregiver==1  if  caregiverSocial!=.
	
	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==2
		codebook id  //   5,540
	reg caregiverSpouse treated_id i.year_id i.treated age gender  coresidence residence marital edug  , cluster(市)
	//xtreg caregiverSpouse treated_id i.yearin i.市代码 , r
	outreg2 using "${OUT}/care_basepanel.xls",replace stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) keep(treated_id)    
	restore
	
	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==2
		codebook id  //   5,540
		reg `k' treated_id i.year_id i.treated age gender  coresidence residence marital edug  , cluster(市)
		//xtreg `k' treated_id i.yearin i.市代码   , r
		outreg2 using "${OUT}/care_basepanel.xls",append stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  keep(treated_id)
	restore
	}		
	
*********************************************************
**************** ADL caregiver	********
*********************************************************	
	gen ADLcaregiverfamily = ADLcaregiverSon==1 | ADLcaregiverDaughter==1 | ADLcaregiverDinL==1 |  ADLcaregiverSinL==1 | ADLcaregiverChild==1 | ADLcaregiverGrandC==1 | ADLcaregiverOthFamily==1 		 	if ADLcaregiverSon!=.
	
	gen ADLcaregivernonfamilygovern = ADLcaregiverSocial==1 | ADLcaregiverhousekeeper==1  if ADLcaregiverSocial!=.

**** reghdfe

	reg ADLcaregiverSpouse treated_id i.year_id i.treated age gender  coresidence residence marital edug  , cluster(市)
	outreg2 using "${OUT}/ADLcare_base.xls",replace stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	
	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale ADLcaregiverfamily ADLcaregivernonfamilygovern{
		reg `k' treated_id i.year_id i.treated age gender  coresidence residence marital edug  , cluster(市) 
		outreg2 using "${OUT}/ADLcare_base.xls",append stats(coef se) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	}		
xx
**** reghdfe
	preserve
		drop if ADLcaregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==2
		codebook id  //   5,540
	
		reghdfe ADLcaregiverSpouse treated_id i.year_id i.treated age gender  coresidence residence, absorb(省 wave )   vce(robust)
		outreg2 using "${OUT}/ADLcare_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore
	
	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale ADLcaregiverfamily ADLcaregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==2
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender  coresidence residence, absorb(省 wave )   vce(robust)
		outreg2 using "${OUT}/ADLcare_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}			
