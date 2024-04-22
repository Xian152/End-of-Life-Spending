/**
可以以dat00_18F.dta为例熟悉这些code和定义。
*/
********************** Lifestyle ******************
	* smoking
	ren	(d71_c d72_c d73_c d74_c d75_c) (r_smkl_pres r_smkl_past r_smkl_start r_smkl_quit r_smkl_freq)

	* drinking	
	ren (d81_c d82_c d83_c d84_c d85_c d86_c) (r_dril_pres r_dril_past r_dril_start r_dril_quit r_dril_type r_dril_freq)
	* physical activity
	ren (d91_c d92_c d93_c d94_c) (r_pa_pres r_pa_past r_pa_start r_pa_quit)

	* Smoking
	recode r_smkl_pres r_smkl_past  (-1 8 9 = .)
	recode r_smkl_freq (-1 88 99 = .)
	recode r_smkl_start r_smkl_quit (-1 888 999 = .)
	gen smkl = 1 if r_smkl_pres == 2 & r_smkl_past == 2
	replace smkl = 2 if !inlist(r_smkl_pres,1,.) & r_smkl_past == 1				// choose to code smk missing if r_smkl_pres is missing
	replace smkl = 3 if r_smkl_pres == 1 & (r_smkl_freq * 1.4) >= 0 & (r_smkl_freq * 1.4) < 20
	replace smkl = 4 if r_smkl_pres == 1 & (r_smkl_freq * 1.4) >= 20 & (r_smkl_freq * 1.4) <= 50
	label define smkl 1 "never" 2 "former" 3 "light current" 4 "heavy current"
	label value smkl smkl 

	gen smkl_year = r_smkl_quit - r_smkl_start
	
	* Drinking alchol
	recode r_dril_freq (-1 88 99 = .)
	recode r_dril_pres r_dril_past r_dril_type (-1 8 9 = .)  
	gen alcohol = . 

		replace alcohol = r_dril_freq * 50 * 0.53 if r_dril_type == 1
		replace alcohol = r_dril_freq * 50 * 0.38 if r_dril_type == 2
		replace alcohol = r_dril_freq * 50 * 0.12 if r_dril_type == 3
		replace alcohol = r_dril_freq * 50 * 0.15 if r_dril_type == 4
		replace alcohol = r_dril_freq * 50 * 0.04 if r_dril_type == 5
		replace alcohol = r_dril_freq * 50 * 0.244 if r_dril_type == 6
	
	
	generate dril=.
	replace dril=1 if r_dril_pres==2 & r_dril_past==2
	replace dril=2 if !inlist(r_dril_pres,1) & r_dril_past==1  				// choose to code dril missing if r_dril_pres is missing
	replace dril=3 if gender==1 & r_dril_pres==1 & inrange(alcohol,0, 25)
	replace dril=3 if gender==0 & r_dril_pres==1 & inrange(alcohol,0, 15)
	replace dril=4 if gender==1 & r_dril_pres==1 & (alcohol > 25 & alcohol < . )  // & not |
	replace dril=4 if gender==0 & r_dril_pres==1 & (alcohol > 15 & alcohol < . )
	label define dril 1 "never" 2 "former" 3 "current & light" 4 "current & heavy"
	label value dril dril
	
	* Physical Activity
	recode r_pa_pres r_pa_past (-1 8 9 = .)
	recode r_pa_start (-1 888 999 = .)
	gen pa = 1 if r_pa_pres == 1 & r_pa_start < 50
	replace pa = 2 if r_pa_pres == 1 & r_pa_start >= 50 & r_pa_start < . // choose to code pa missing if r_pa_pres is missing
	replace pa = 3 if r_pa_pres != 1 & r_pa_past == 1 
	replace pa = 4 if r_pa_pres == 2 & r_pa_past == 2 
	label define pa 1 "current & start < 50" 2 "current & start >=50" 3 "former" 4 "never"
	label value pa pa 

********* ADL: activity of daily living *********
	recode e1 e2 e3 e4 e5 e6  (1 = 0 "do not need help") (2 3 = 1 "need help") (-1 8 9 = .),gen(bathing dressing toileting transferring continence feeding) label(adl_row)
	
	egen adl_miss= rowmiss(bathing dressing toileting transferring continence feeding)
	egen adl_sum = rowtotal(bathing dressing toileting transferring continence feeding) 
	
	replace adl_sum = . if adl_miss > 1 
	
	gen adl = (adl_sum > 0) if adl_sum != .
	label define adl 0"0:without ADL" 1"1:with ADL"
	label value adl adl	
	
********* ADL: activity of daily living *********	
	foreach k in a b c d e f g h i j k l m n {
			gen disease_`k' = 0 if g15`k'1==1
			replace disease_`k' = 1  if g15`k'1==1 & g15`k'3 == 1
			replace disease_`k' = 2  if g15`k'1==1 & g15`k'3 != 1	// here Yaxi did deduction for missing value "8" "9"
			replace disease_`k' = 3  if g15`k'1==2 
			//replace disease_`k' = . if inlist(g15`k'3,8,9)
			label value  disease_`k' disease
	}

		ren disease_a hypertension
		ren disease_b diabetes
		ren disease_c heartdisea
		ren disease_d strokecvd
		ren disease_e copd
		ren disease_f tb
		ren disease_g cataract
		ren disease_h glaucoma
		ren disease_i cancer
		ren disease_j prostatetumor
		ren disease_k ulcer
		ren disease_l parkinson
		ren disease_m bedsore
		ren disease_n arthritis
		//ren disease_o dementia
	
	
