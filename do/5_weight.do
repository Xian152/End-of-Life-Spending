	use "${INT}/dat98_18_renamed.dta",clear
		keep w_* id wave
		ren w_1998 w 
		tempfile t98
	save `t98',replace
		
		
	foreach year in  00 02 05 08 11 14 18 {  
		use "${INT}/dat`year'_18_renamed.dta",clear
		keep w_* id wave
		ren w_20`year' w
		tempfile t`year'
		save `t`year'',replace
	}	
	
	use `t98',clear
		append using `t00' `t02' `t05' `t08' `t11' `t14'  `t18' 
		duplicates drop
		drop if w==.
		recode wave(98 = 1998) (0 =2000)  (2 =2002)  (5 =2005)  (8 =2008)  (11 =2011)  (14 =2014)  (18 =2018) 
	save 	"${INT}/weight.dta",replace
