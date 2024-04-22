	preserve
		drop if hexpFampaid== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		destring 市代码,replace
		didregress (hexpFampaid) (treated_id) [aw=w], group(市代码) time(yearin)
	restore


*********************************************************
**************** health expenditure	**************
*********************************************************
preserve
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


	preserve
		drop if hexpFampaid== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		didregress (hexpFampaid) (treated_id) [aw=w], group(市代码) time(yearin)
		outreg2 using "${OUT}/hexp_base_did.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 
	restore
	foreach k in hexpFampaidOP hexpFampaidIP hexpIndpaid hexpIndpaidOP hexpIndpaidIP  {
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		didregress (`k') (treated_id) [aw=w], group(市代码) time(yearin)
		outreg2 using "${OUT}/hexp_base_did.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}		
	
	preserve
		drop if hexpFampaid== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
	
		didregress (hexpFampaid age gender ) (treated_id) [aw=w], group(市代码) time(yearin)
		outreg2 using "${OUT}/hexp_cov_did.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*) 
	restore
	
	foreach k in hexpFampaidOP hexpFampaidIP hexpIndpaid hexpIndpaidOP hexpIndpaidIP  {
	preserve
		drop if `k'== .
		cap drop count
		bysort id: gen count = _N
		keep if count ==3
		codebook id  //   5,540
		didregress (`k'  age gender ) (treated_id)  [aw=w] , group(市代码) time(yearin)
		outreg2 using "${OUT}/hexp_cov_did.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  
	restore
	}		
		
	
