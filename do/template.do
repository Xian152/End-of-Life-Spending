******template
*table 1
table1, by(wave) vars(age contn\ gender cat\ coresidence cat\ residence cat\ hexpFampaid conts\  hexpFampaidOP conts\  hexpFampaidIP  conts\  hexpIndpaid conts\  hexpIndpaidOP  conts\ hexpIndpaidIP conts\ hexpFampaid contn\  hexpFampaidOP contn\  hexpFampaidIP  contn\  hexpIndpaid contn\  hexpIndpaidOP  contn\ hexpIndpaidIP contn\  )  one mis saving("${OUT}/Table1 hexp.xls", replace) 


*figure template
	twoway connected Treated  Controled year, title("Panel C: The Third Batch(2014)") ytitle("Past-month drinking rate" ) xtitle(Year)  xline(2014) legend(ring(0) pos(2)) ylabel(20(4)35,nogrid) xlabel(2006(2)2018,nogrid) ylabel(,nogrid)
	
	graph save "Graph_drinking30_1.gph",   replace	

	twoway connected reated  Controled year, title("Panel D: The Total ") ytitle("Past-month drinking rate" ) xtitle(Year)  legend(ring(0) pos(2))  xlabel(2006(2)2018,nogrid) ylabel(,nogrid)
	
	graph save "Graph_drinking30_2.gph",    replace	

	graph combine "Graph_drinking30_1.gph" "Graph_drinking30_2.gph",title("Trend of past-month drinking rate") rows(3)  cols(1) iscale(.7273) ysize(12)  graphregion(margin(zero))
	graph export "Graph_drinking30.gph", replace

* 轨迹 需要安装包traj

// 参考：https://www.andrew.cmu.edu/user/bjones/traj

* 分组
去掉死亡的时间和第一次受访时间发生在同一年

adl dementia gender marital  residence hhIncome(10000) srh
