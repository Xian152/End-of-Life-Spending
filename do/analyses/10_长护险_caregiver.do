	gen caregiverfamily = 1 if caregiverSon==1 | caregiverDaughter==1 | caregiverDinL==1 |  caregiverSinL==1 | caregiverChild==1 | caregiverGrandC==1 | caregiverOthFamily==1 		
	replace caregiverfamily = 0 if caregiverSon==0 & caregiverDaughter==0 & caregiverDinL==0 &  caregiverSinL==0 & caregiverChild==0 & caregiverGrandC==0 & caregiverOthFamily==0 
	
	gen caregivernonfamilygovern = 1  if caregiverFriend==1 |  caregiverSocial==1 |  caregiverCaregiver==1 
	replace caregivernonfamilygovern = 0  if caregiverFriend==0 &  caregiverSocial==0 &  caregiverCaregiver==0 


	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		xtreg caregiverSpouse treated_id i.yearin i.市代码 , r
		outreg2 using "${OUT}/care_basepanel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) keep(treated_id)    
	restore
	
	
	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		xtreg `k' treated_id i.yearin i.市代码   , r
		outreg2 using "${OUT}/care_basepanel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  keep(treated_id)
	restore
	}		
xx
	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		xtreg caregiverSpouse treated_id i.wave i.市代码 age gender   , r
		outreg2 using "${OUT}/care_covpanel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   keep(treated_id)  
	restore	

	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		xtreg `k' treated_id i.wave i.市代码 age gender  , r	
		outreg2 using "${OUT}/care_covpanel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)   keep(treated_id)
	restore
	}		
		
	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		xtreg caregiverSpouse treated_id i.wave i.市代码 age gender ,  cluster(市代码)  
		outreg2 using "${OUT}/care_cov_fixedpanel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)     keep(treated_id)
	restore			
	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		xtreg `k' treated_id i.wave i.市代码 age gender ,  cluster(市代码)  
		outreg2 using "${OUT}/care_cov_fixedpanel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)     keep(treated_id)
	restore	
	}
	
	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		xtreg caregiverSpouse treated_id i.year_id i.treated age gender coresidence residence [aw=w], absorb(id yearin )    vce(robust)
		outreg2 using "${OUT}/care_cov2_fixedpanel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore			
	
	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		xtreg `k' treated_id i.year_id i.treated age gender coresidence residence [aw=w], absorb(id yearin)    vce(robust)
		outreg2 using "${OUT}/care_cov2_fixedpanel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
	
	
	
	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		xtreg caregiverSpouse treated_id i.year_id i.treated age gender coresidence residence [aw=w], absorb(市 yearin )    vce(robust)
		outreg2 using "${OUT}/care_cov2_fixed2panel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore			
	
	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		xtreg `k' treated_id i.year_id i.treated age gender coresidence residence [aw=w], absorb(市 yearin)    vce(robust)
		outreg2 using "${OUT}/care_cov2_fixed2panel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
		
		
	
	preserve
		drop if caregiverSpouse== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		xtreg caregiverSpouse treated_id i.year_id i.treated age gender coresidence residence [aw=w], absorb(市 wave)  cluster(市)   
		outreg2 using "${OUT}/care_cov2_fixed3panel.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore			
	
	foreach k in  caregiverSon caregiverDaughter caregiverDinL  caregiverSinL caregiverChild caregiverGrandC caregiverOthFamily caregiverFriend caregiverSocial caregiverCaregiver caregiverNobody caregivermale caregiverfemale caregiverfamily caregivernonfamilygovern{
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		xtreg `k' treated_id i.year_id i.treated age gender coresidence residence [aw=w], absorb(市 wave)   cluster(市)   
		outreg2 using "${OUT}/care_cov2_fixed3panel.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)    
	restore	
	}
					