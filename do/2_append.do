use  "${OUT}/Full_dat98_18_covariances.dta",clear	
	foreach year in 98 00 02 05 08 11 14 18{ //
		append using "${OUT}/Full_dat`year'_18_covariances.dta" ,force
	}
save	"${OUT}/append_covariances.dta",replace
