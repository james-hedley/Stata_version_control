* Programs to help with version control
* Created by: James Hedley
* Date Created: 16th December 2019
* Last Updated: 25th August 2020



* Find out which is the latest version of a file - Updated version
capture program drop current_version
program define current_version, rclass
	syntax anything(name=filenamestub) [, EXTension(string) Format(string) DIRectory(string) SEParator(passthru) PLaceholder(string) Version(numlist max=1)]

	quietly {
		
		* Default values
		if "`format'"=="" local format="%tdCCYYNNDD"
		if strlower("`format'")=="redcap" local format="%tcCCYY-NN-DD!_HHMM"
		if "`version'"=="" local version=1
		if `"`separator'"'=="" local sep="_"
		if `"`separator'"'!="" local sep=substr(`"`separator'"',12,strlen(`"`separator'"')-14+1)
		local separator="`sep'"
		
		* Remove quotes from inputs
		local filenamestub `filenamestub'
		local extension `extension'
		local format `format'
		local separator `separator'
		local placeholder `placeholder'
		local directory `directory'
		local version `version'
		
		
		* Clean specified format
		local format_regex="`format'"
		local format_regex=subinstr("`format_regex'","+","",.) // remove plus signs
		
		if "`format_regex'"=="%tC" local format_regex="%tCDDmonCCYY_HH:MM:SS" // substitute in implied formats
		if "`format_regex'"=="%tc" local format_regex="%tcDDmonCCYY_HH:MM:SS"
		if "`format_regex'"=="%td" local format_regex="%tdDDmonCCYY"
		if "`format_regex'"=="%tw" local format_regex="%twCCYY!www"
		if "`format_regex'"=="%tm" local format_regex="%tmCCYY!mnn"
		if "`format_regex'"=="%tq" local format_regex="%tqCCYY!qq"
		if "`format_regex'"=="%th" local format_regex="%thCCYY!hh"
		if "`format_regex'"=="%ty" local format_regex="%tyCCYY"
		
		local format_regex=ustrregexra("`format_regex'","(?-i)%(t[cCdwmqhy]){0,1}","") // remove '%tx' from beginning
		
		* Add escape characters
		local format_regex=subinstr("`format_regex'","\","\\",.) // add escape characters to seprator symbols
		local format_regex=subinstr("`format_regex'",".","\.",.) 
		local format_regex=subinstr("`format_regex'",",","\,",.)
		local format_regex=subinstr("`format_regex'",":","\:",.)
		local format_regex=subinstr("`format_regex'","-","\-",.)
		local format_regex=subinstr("`format_regex'","/","\/",.)
		local format_regex=subinstr("`format_regex'","!_","\%underscore%",.)
		local format_regex=subinstr("`format_regex'","_","\s",.) // underscore is STATA's version of a space
		local format_regex=subinstr("`format_regex'","%underscore%","_",.)
		local format_regex=subinstr("`format_regex'","!","\",.) // exclamation marks are STATA's escape character
		
		* Add month regex
		local format_regex=subinstr("`format_regex'","Month","(January|February|March|April|May|June|July|August|September|October|November|December)",.)
		local format_regex=subinstr("`format_regex'","month","(january|february|march|april|may|june|july|august|september|october|november|december)",.)
		local format_regex=subinstr("`format_regex'","Mon","(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)",.)
		local format_regex=subinstr("`format_regex'","mon","(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)",.)
		local format_regex=subinstr("`format_regex'","NN","(01|02|03|04|05|06|07|08|09|10|11|12)",.)
		local format_regex=subinstr("`format_regex'","nn","(10|11|12|1|2|3|4|5|6|7|8|9)",.)
		
		* Add day regex
		local format_regex=subinstr("`format_regex'","DAYNAME","(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)",.)
		local format_regex=subinstr("`format_regex'","Dayname","(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)",.)
		local format_regex=subinstr("`format_regex'","dayname","(monday|tuesday|wednesday|thursday|friday|saturday|sunday)",.)
		local format_regex=subinstr("`format_regex'","Day","(Mon|Tue|Wed|Thu|Fri|Sat|Sun)",.)
		local format_regex=subinstr("`format_regex'","day","(mon|tue|wed|thu|fri|sat|sun)",.)
		local format_regex=subinstr("`format_regex'","Da","(Mo|Tu|We|Th|Fr|Sa|Su)",.)
		local format_regex=subinstr("`format_regex'","da","(mo|tu|we|th|fr|sa|su)",.)
		local format_regex=subinstr("`format_regex'","DD","(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31)",.)
		local format_regex=subinstr("`format_regex'","dd","(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|1|2|3|4|5|6|7|8|9)",.)
		
		* Add century regex
		local format_regex=subinstr("`format_regex'","CC","(01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99)",.)
		local format_regex=subinstr("`format_regex'","cc","(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|1|2|3|4|5|6|7|8|9)",.)
		
		* Add year regex
		local format_regex=subinstr("`format_regex'","YY","(00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99)",.)
		local format_regex=subinstr("`format_regex'","yy","(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79|80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96|97|98|99|0|1|2|3|4|5|6|7|8|9)",.)
		
		* Add hour regex
		local format_regex=subinstr("`format_regex'","HH","(00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23)",.)
		local format_regex=subinstr("`format_regex'","Hh","(00|01|02|03|04|05|06|07|08|09|10|11|12)",.)
		local format_regex=subinstr("`format_regex'","hH","(10|11|12|13|14|15|16|17|18|19|20|21|22|23|0|1|2|3|4|5|6|7|8|9)",.)
		local format_regex=subinstr("`format_regex'","hh","(10|11|12|0|1|2|3|4|5|6|7|8|9)",.)
		
		* Add minute regex
		local format_regex=subinstr("`format_regex'","MM","(00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59)",.)
		local format_regex=subinstr("`format_regex'","mm","(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|0|1|2|3|4|5|6|7|8|9)",.)
		
		* Add second regex
		local format_regex=subinstr("`format_regex'","SS","(00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60)",.)
		local format_regex=subinstr("`format_regex'","ss","(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37|38|39|40|41|42|43|44|45|46|47|48|49|50|51|52|53|54|55|56|57|58|59|60|0|1|2|3|4|5|6|7|8|9)",.)
		local format_regex=subinstr("`format_regex'",".s","(\.\d{1})",.)
		local format_regex=subinstr("`format_regex'",".ss","(\.\d{2})",.)
		local format_regex=subinstr("`format_regex'",".sss","(\.\d{3})",.)
		
		* Add am/pm regex
		local format_regex=subinstr("`format_regex'","A.M.","(A\.M\.|P\.M\.)",.)
		local format_regex=subinstr("`format_regex'","a.m.","(a\.m\.|p\.m\.)",.)
		local format_regex=subinstr("`format_regex'","AM","(AM|PM)",.)
		local format_regex=subinstr("`format_regex'","am","(am|pm)",.)
		

	
		* Build the directory regex	
		if "`extension'"=="" local extension_regex="\..*"
		if "`extension'"!="" local extension_regex=subinstr("`extension'",".","\.",.)
		
		if "`placeholder'"=="" local regex="`filenamestub'`separator'`format_regex'`extension_regex'"
		if "`placeholder'"!="" local regex=subinstr("`filenamestub'`extension_regex'","`placeholder'","`format_regex'",.)

		
		* Determine order within format that each date component appears
		if ustrregexm("`format'","DD|dd")==1 local day_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","Month|month|Mon|mon|NN|nn")==1 local month_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","CC|cc")==1 local century_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","YY|yy")==1 local year_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","HH|Hh|hH|hh")==1 local hour_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","MM|mm")==1 local minute_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","\.sss|\.ss|\.s|SS|ss")==1 local second_pos=strpos("`format'",ustrregexs(0))
		if ustrregexm("`format'","A\.M\.|a\.m\.|AM|am")==1 local ampm_pos=strpos("`format'",ustrregexs(0))
		
		preserve
			clear
			set obs 8
			
			gen format=""
			replace format="day" in 1
			replace format="month" in 2
			replace format="year" in 3
			replace format="hour" in 4
			replace format="minute" in 5
			replace format="second" in 6
			
			gen stata_format=""
			replace stata_format="D" in 1
			replace stata_format="M" in 2
			replace stata_format="Y" in 3
			replace stata_format="h" in 4
			replace stata_format="m" in 5
			replace stata_format="s" in 6		
			
			gen position=.
			capture replace position=`day_pos' in 1
			capture replace position=`month_pos' in 2
			capture replace position=`year_pos' in 3
			capture replace position=`century_pos' if `century_pos'<`year_pos' in 3
			capture replace position=`hour_pos' in 4
			capture replace position=`minute_pos' in 5
			capture replace position=`second_pos' in 6
			
			drop if position==.
			sort position
			
			local dateformat=""
			count
			forvalues i=1/`r(N)' {
				local stata_format=stata_format[`i']
				local dateformat="`dateformat'`stata_format'"
			}
		restore
			
			
		* Search current directory for files matching the specified filenamestub, date format, and file extension
		local file_search=subinstr("`filenamestub'","`placeholder'","*",.)+"`separator'*`extension'"
		local filelist: dir "`directory'" files "`file_search'", respectcase
		if `"`filelist'"'=="" error 601
		
		preserve
			clear
			gen file=""
			gen datestr=""
			gen double date=.
			format date %tc
			foreach file in `filelist' {
				if ustrregexm("`file'","`regex'")==1 {
					display "`file'"
					count
					local newobs=`r(N)'+1
					set obs `newobs'
					replace file="`file'" in `newobs'
					if ustrregexm("`file'","`format_regex'")==1 replace datestr=ustrregexs(0) in `newobs'
				}
			}
			
			replace date=clock(datestr,"`dateformat'")
			gsort -date
			
			local current_version_filename=file[`version']
			local current_version_date=date[`version']
			local current_version_date: display %tc `current_version_date'
			local current_version=datestr[`version']
			
			local all_versions=""
			local all_versions_filenames=""
			local all_versions_dates=""
			count
			forvalues i=1/`r(N)' {
				local version=datestr[`i']
				local filename=file[`i']
				local date=date[`i']
				local date: display %tc `date'
				
				if `i'==1 {
					local all_versions="`version'"
					local all_versions_filenames="`filename'"
					local all_versions_dates="`date'"
				}
				if `i'!=1 {
					local all_versions="`all_versions' `version'"
					local all_versions_filenames="`all_versions_filenames' `filename'"
					local all_versions_dates="`all_versions_dates' `date'"	
				}
			}
		restore
		
		return local all_versions "`all_versions'"
		return local all_versions_dates "`all_versions_dates'"
		return local all_versions_filenames `"`all_versions_filenames'"'
		return local current_version "`current_version'"
		return local current_version_date "`current_version_date'"
		return local current_version_filename "`current_version_filename'"
	}
end


* Open the latest version of a dataset
capture program drop use_current_version
program define use_current_version
	syntax anything(name=filename) [, CLear SEParator(passthru) Format(string) Version(numlist max=1) DIRectory(string)]
	
	if "`format'"=="" local format="%tdCCYYNNDD"
	if "`version'"=="" local version=1
	if `"`separator'"'=="" local sep="_"
	if `"`separator'"'!="" local sep=substr(`"`separator'"',12,strlen(`"`separator'"')-14+1)
	local separator="`sep'"
	
	local filename `filename' // remove quotes
	local separator `separator' // remove quotes
	local format `format' // remove quotes
	local version `version' // remove quotes
	local directory `directory' // remove quotes 
	
	current_version "`filename'", sep("`separator'") ext(".dta") format("`format'") version(`version') directory("`directory'")
	
	if "`clear'"=="" use "`r(current_version_filename)'"
	if "`clear'"!="" use "`r(current_version_filename)'", clear
end


* Run the latest version of a do-file
capture program drop do_current_version
program define do_current_version
	syntax anything(name=filename) [, SEParator(passthru) Format(string) PLaceholder(string) Version(numlist max=1) DIRectory(string)]

	if "`format'"=="" local format="%tdCCYYNNDD"
	if "`version'"=="" local version=1
	if `"`separator'"'=="" local sep="_"
	if `"`separator'"'!="" local sep=substr(`"`separator'"',12,strlen(`"`separator'"')-14+1)
	local separator="`sep'"
	
	local filename `filename' // remove quotes
	local separator `separator' // remove quotes
	local placeholder `placeholder' // remove quotes
	local format `format' // remove quotes
	local version `version' // remove quotes
	local directory `directory' // remove quotes 
	
	current_version "`filename'", sep("`separator'") format("`format'") placeholder("`placeholder'") extension(".do") version(`version') directory("`directory'")
	do "`r(current_version_filename)'"

end



* Move older versions of a file to a different folder
capture program drop move_old_versions
program define move_old_versions
	syntax anything(name=filename) [, REPLACE ERASE SEParator(passthru) Archive(string) Extension(string) Keepcurrent Format(string) PLaceholder(string) Version(numlist max=1) DIRectory(string)]

	if "`format'"=="" local format="%tdCCYYNNDD"
	if "`version'"=="" local version=1
	if `"`separator'"'=="" local sep="_"
	if `"`separator'"'!="" local sep=substr(`"`separator'"',12,strlen(`"`separator'"')-14+1)
	local separator="`sep'"
	
	local filename `filename' // remove quotes
	local extension `extension' // remove quotes
	local replace `replace' // remove quotes
	local erase `erase' // remove quotes
	local separator `separator' // remove quotes
	local keepcurrent `keepcurrent' // remove quotes
	local placeholder `placeholder' // remove quotes
	local format `format' // remove quotes
	local version `version' // remove quotes
	local directory `directory' // remove quotes 
	
	local current_directory : pwd
	if "`archive'"=="" local archive_directory "`current_directory'\\Previous versions"
	if "`archive'"!="" local archive_directory "`archive'"
	
	
	if "`directory'"!="" cd "`directory'"
	current_version "`filename'", separator("`separator'") format("`format'") placeholder("`placeholder'") extension("`extension'") version(`version')
	
	local i=0
	foreach filename in `all_versions_filenames' {
		local i=`i'+1
		copy "`filename'" `"`archive_directory'\\`filename'"', `replace'
		if "`erase'"!="" & ("`keepcurrent'"=="" | ("`keepcurrent'"!="" & `i'!=`version')) erase "`filename'"
	}
	
	cd `"`current_directory'"'
	
end


* Save the latest version of a Stata dataset or do-file
capture program drop save_current_version
program define save_current_version
	syntax anything(name=filename) [, REPLACE SEParator(passthru) Format(string) Dofile Archive(string) Moveold ERASE Version(numlist max=1)]
	
	local filename `filename' // remove quotes
	local replace `replace' // remove quotes
	local dofile `dofile' // remove quotes
	local separator `separator' // remove quotes
	local format `format' // remove quotes
	local version `version' // remove quotes
			
	if "`format'"=="" local format="%tdCCYYNNDD"
	if "`version'"=="" local version=1
	if `"`separator'"'=="" local sep="_"
	if `"`separator'"'!="" local sep=substr(`"`separator'"',12,strlen(`"`separator'"')-14+1)
	local separator="`sep'"
	
	local current_date : display `format' date("`c(current_date)'","DMY")
	
	local current_directory : pwd
	if "`archive'"=="" local archive_directory "`current_directory'\\Previous versions"
	if "`archive'"!="" local archive_directory "`archive'"
	
	if "`dofile'"=="" save "`filename'`separator'`current_date'", `replace'
	if "`dofile'"!="" copy "`current_directory'\\`filename'.do" "`archive_directory'\\`filename'`separator'`current_date'.do", `replace'
	
	if "`moveold'"!="" {
		if "`dofile'"=="" local extension ".dta"
		if "`dofile'"!="" local extension ".do"
		move_old_versions "`filename'", `replace' `erase' separator("`separator'") archive("`archive'") extension("`extension'") keepcurrent version(`version') format("`format'")
	}
end

