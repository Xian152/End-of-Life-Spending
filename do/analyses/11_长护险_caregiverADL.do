
	preserve
		drop if ADLcaregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		reg  ADLcaregiverSpouse treated_id i.year_id i.treated, r
		outreg2 using "${OUT}/ADLcare_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore
	

	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reg `k' treated_id i.year_id i.treated, r
		outreg2 using "${OUT}/ADLcare_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}		

	preserve
		drop if ADLcaregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		reg ADLcaregiverSpouse treated_id i.year_id i.treated age gender , r
		outreg2 using "${OUT}/ADLcare_cov.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	

	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reg `k' treated_id i.year_id i.treated age gender , r	
		outreg2 using "${OUT}/ADLcare_cov.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}		
		
		
	reghdfe ADLcaregiverSpouse treated_id i.year_id i.treated age gender , absorb(id yearin )    vce(robust)
	outreg2 using "${OUT}/ADLcare_cov_fixed.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender , absorb(id yearin )    vce(robust)
		outreg2 using "${OUT}/ADLcare_cov_fixed.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
	
	
	reghdfe ADLcaregiverSpouse treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin )    vce(robust)
	outreg2 using "${OUT}/ADLcare_cov2_fixed.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
 
	foreach k in  ADLcaregiverSon ADLcaregiverDaughter ADLcaregiverDinL  ADLcaregiverSinL ADLcaregiverChild ADLcaregiverGrandC ADLcaregiverOthFamily ADLcaregiverFriend ADLcaregiverSocial ADLcaregiverhousekeeper ADLcaregiverNobody ADLcaregivermale ADLcaregiverfemale{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin)    vce(robust)
		outreg2 using "${OUT}/ADLcare_cov2_fixed.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
	
	
	
			
	preserve
		drop if adlSum== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		reg  adlSum treated_id i.year_id i.treated   ,r
		outreg2 using "${OUT}/adl_base.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore
	
	replace frailsumver1 = . if frailmissingver1 >=10
	foreach k in  iadlSum frailID  frailsumver1 leisure srhealth phys{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reg  `k' treated_id i.year_id i.treated   ,r
		outreg2 using "${OUT}/adl_base.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}		

	preserve
		drop if adlSum== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reg adlSum treated_id i.year_id i.treated age gender ,r
		outreg2 using "${OUT}/adl_cov.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	

	foreach k in  iadlSum frailID  frailsumver1 leisure srhealth phys{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender , absorb(id yearin )    vce(robust)
		outreg2 using "${OUT}/adl_cov.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}		
		
		
	reghdfe adlSum treated_id i.year_id i.treated age gender , absorb(id yearin )    vce(robust)
	outreg2 using "${OUT}/adl_cov_fixed.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	foreach k in  iadlSum frailID  frailsumver1 leisure srhealth phys{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender , absorb(id yearin )    vce(robust)
		outreg2 using "${OUT}/adl_cov_fixed.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
	
	
	reghdfe adlSum treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin )    vce(robust)
	outreg2 using "${OUT}/adl_cov2_fixed.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
 
	foreach k in  iadlSum frailID  frailsumver1 leisure srhealth phys{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin)    vce(robust)
		outreg2 using "${OUT}/adl_cov2_fixed.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
	

	
	
	

	recode sugar  saltveg (3=1) (1=3) ,gen(sugar_new  saltveg_new)
	
	egen diet = rowtotal(fruit veg  bean egg fish garlic meat sugar_new  saltveg_new  tea )
	egen dietmiss = rowmiss(fruit veg  bean egg fish garlic meat sugar_new  saltveg_new  tea )
	replace diet = . if dietmiss >=1	
	
	recode pa (4 3 =0) ( 1 2 =1 ),gen(pa_bi)
	
	replace ADLhexpcare = ADLhexpcare/12 /4
	
	reghdfe nursingLiving nursingCover treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin )    vce(robust)
	outreg2 using "${OUT}/new results.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
 
	foreach k in  nursingLivingExpect diet pa_bi  ADLcaregiverWilling  ADLcaregtime ADLhexpcare ADLcarepaierChild ADLcarepaierGrandC ADLcarepaierOthers ADLcarepaierSelf ADLcarepaierSocial ADLcarepaierSpose ADLmeet{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender coresidence residence marital edug, absorb(id yearin)    vce(robust)
		outreg2 using "${OUT}/new results.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}	
table1, by(wave) vars(nursingLivingExpect cat\ diet contn\ pa_bi cat\  ADLcaregiverWilling  cat\  ADLcaregtime contn\ ADLhexpcare contn\ ADLcarepaierChild cat\  ADLcarepaierGrandC cat\  ADLcarepaierOthers  cat\ ADLcarepaierSelf cat\  ADLcarepaierSocial cat\  ADLcarepaierSpose cat\  ADLmeet cat\  )  one mis saving("${OUT}/Table1 new.xls", replace) 
	
	
	
gen ADLcarepaierhh = ADLcarepaierChild==1 | ADLcarepaierGrandC==1| ADLcarepaierSelf==1 | ADLcarepaierSpose==1| ADLcarepaierOther==1	if ADLcarepaierChild!=. | ADLcarepaierGrandC!=. | ADLcarepaierSelf!=. | ADLcarepaierSpose!=. | ADLcarepaierOther!=. | ADLcarepaierOther!=.
recode ADLcarepaierhh (1=0)
replace ADLcarepaierhh = 1 if ADLcarepaierSocial==1 


 	
	foreach k in  ADLcarepaierhh{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender coresidence residence marital edug, absorb(id yearin) cluster(city)   vce(robust)
		outreg2 using "${OUT}/new results1.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}		 
	
	foreach k in  ADLcarepaierhh{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender coresidence residence marital edug, absorb(id yearin)    vce(robust)
		outreg2 using "${OUT}/new results1.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}		
	
cls	
	reghdfe hexpFampaid treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin )  cluster(市)   
	outreg2 using "${OUT}/hexp_cov2_fixed.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
 
	foreach k in   hexpFampaidOP hexpFampaidIP hexpIndpaid hexpIndpaidOP hexpIndpaidIP  {
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		reghdfe `k' treated_id i.year_id i.treated age gender coresidence residence, absorb(id yearin) cluster(市)    
		outreg2 using "${OUT}/hexp_cov2_fixed.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}	
	
	
	xx
table1, by(wave) vars(age contn\ gender cat\ coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving("${OUT}/Table1 hexp.xls", replace) 

table1, vars(age contn\ gender cat\ coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving("${OUT}/Table1 hexp_total.xls", replace) 

	