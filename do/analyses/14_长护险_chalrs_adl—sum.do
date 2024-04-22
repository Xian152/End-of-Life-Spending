*******************************
************ 分析 *************
*******************************
drop if count 
*********** ADL base **************
	ivreghdfe adl_sum_ age_ gender marital_ urban_nbs hukou_ exphh_ (pm25_36m pm25_1d= thermal_inv12_36m thermal_inv12_1d)  moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  [aw= wtrespb_]   , absorb(wave 市)  cluster(市)  r 	
	outreg2 using "/Users/x152/Desktop/IV charls/charls_basic_panel_ADL_60.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_36m pm25_1d)
	
foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum_  age_ gender  marital_ urban_nbs hukou_ exphh_ (pm25_`k' pm25_1d =  thermal_inv12_`k' thermal_inv12_1d) moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'     [aw= wtrespb_]  , absorb(wave  市)   cluster(市)  r 
	outreg2 using "/Users/x152/Desktop/IV charls/charls_basic_panel_ADL_60.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))  keep(pm25_`k' pm25_1d age gender)
}	


****** ADL bin
cls
	ivreghdfe adl_sum_ age_ gender marital_ urban_nbs hukou_ exphh_ ( pm25_2039_36m pm25_4059_36m pm25_6079_36m pm25_80100_36m pm25_100over_36m  =  thermal_inv12_2_36m thermal_inv12_3_36m thermal_inv12_4_36m thermal_inv12_5_36m thermal_inv12_6_36m) moister_36m sunshine_36m precipitation_36m temperture_36m windspeed_36m  [aw= wtrespb_]   , absorb(wave 市)  cluster(市)  r 	
	outreg2 using "/Users/x152/Desktop/IV charls/charls_bin_panel_ADL_60.xls",replace stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   

foreach k in 24m 12m 6m 90d 30d 7d{
	ivreghdfe adl_sum_  age_ gender  marital_  urban_nbs hukou_ exphh_ ( pm25_2039_`k' pm25_4059_`k' pm25_6079_`k' pm25_80100_`k' pm25_100over_`k'  =  thermal_inv12_2_`k' thermal_inv12_3_`k' thermal_inv12_4_`k' thermal_inv12_5_`k' thermal_inv12_6_`k') moister_`k' sunshine_`k' precipitation_`k' temperture_`k' windspeed_`k'     [aw= wtrespb_]  , absorb(wave  市)   cluster(市)  r 
	outreg2 using "/Users/x152/Desktop/IV charls/charls_bin_panel_ADL_60.xls",append stats(coef pval) dec(3) alpha(0.01,0.05,0.1) symbol(***,**,*)  addstat(KP F-statistics,e(widstat))   
	}
	