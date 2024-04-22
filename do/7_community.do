**************baseline merge with co
use "${OUT}/append all_fin.dta",clear
	preserve 
		use "${SOURCE}/CLHLS区县编码-白晨2018_alt.dta",clear
			append using  "${SOURCE}/CLHLS区县编码-白晨2014_alt.dta" "${SOURCE}/CLHLS区县编码-白晨2008.dta"  "${SOURCE}/CLHLS区县编码-白晨2011.dta"  "${SOURCE}/CLHLS区县编码-白晨2005.dta"
			keep id gbcode wave
			replace wave = 2014 if wave ==14
			replace wave = 2011 if wave ==11
			replace wave = 2018 if wave ==18
			replace wave = 2008 if wave ==08
			replace wave = 2005 if wave ==05
			duplicates drop
			tempfile t1
		save `t1',replace
	restore
	merge 1:m id wave using `t1'
	drop if _m ==2 
	drop _m	

	preserve 
		use "${SOURCE}/CLHLS_community_dataset_2005.dta",clear
			append using "${SOURCE}/CLHLS_community_dataset_2011.dta" "${SOURCE}/CLHLS_community_dataset_2014.dta" "${SOURCE}/CLHLS_community_dataset_2008.dta" 
			duplicates drop
			replace wave = 2014 if wave ==14
			replace wave = 2011 if wave ==11
			replace wave = 2018 if wave ==18
			replace wave = 2008 if wave ==08
			replace wave = 2005 if wave ==05
			replace wave = 2002 if wave ==02
			replace wave = 2000 if wave ==0
			replace wave = 1998 if wave ==98
			
			tempfile t1
		save `t1',replace
	restore	
	merge m:1 id wave using `t1'
	drop if _m == 2
	drop _m	
save "${OUT}/Full_CLHLS_covariants_comm.dta",replace	
