use "${OUT}/analyses.dta",clear

	drop if deathstatus == 1 
	ren yearin intdate_year
	merge m:1 intdate_year using "${SOURCE}/CPI.dta"
	drop if _m == 2
	drop _m
	
	foreach k in hhIncomepercap hhIncome{
		replace  `k' = (`k' / cpi) * 100
	}
	
	foreach k in hhIncomepercap hhIncome{
		bysort wave: egen `k'mean  = mean(`k')
		bysort wave: egen `k'sd = sd(`k')
		gen meanupper`k'  = `k'mean +`k'sd*1.5 
		gen meanlower`k'  = `k'mean -`k'sd*1.5 
		bysort wave: egen `k'median  = median(`k')
		bysort wave: egen `k'75 = pctile (`k'),p(75)
		bysort wave: egen `k'25 = pctile (`k'),p(25)
	}	
	
	keep hhIncome25 hhIncome75 hhIncomemean hhIncomemedian hhIncomepercap25 hhIncomepercap75 hhIncomepercapmean hhIncomepercapmedian hhIncomepercapsd hhIncomesd meanlowerhhIncome meanlowerhhIncomepercap meanupperhhIncome meanupperhhIncomepercap wave
	duplicates drop
	
	graph twoway (line  hhIncomemedian wave )  (rcap hhIncome25 hhIncome75  wave),title("hhincome median") xtitle("wave") legend(ring(0) pos(2))
	graph twoway (line  hhIncomepercapmedian wave )  (rcap hhIncomepercap25 hhIncomepercap75  wave),title("hhincome percap median") xtitle("wave") legend(ring(0) pos(2))
	
	graph twoway (line  hhIncomepercapmean wave )  (rcap meanupperhhIncomepercap meanlowerhhIncomepercap  wave),title("hhincome percapita mean") xtitle("wave") legend(ring(0) pos(2))
	graph twoway (line  hhIncomemean wave )  (rcap meanupperhhIncome meanlowerhhIncome  wave),title("hhincome percap mean") xtitle("wave") legend(ring(0) pos(2))
	
	( hhIncome25  wave ) ( hhIncome75 wave )
