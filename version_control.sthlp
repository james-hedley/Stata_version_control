{smcl}
{cmd:help version_control}
{hline}

{title:Title}

{p2col :{hi:version_control_commands} {hline 2}}Commands to assist with version control, and to add dates to the end of file names{p_end}


{title:Syntax}

{phang}{cmd:current_version} {it:filename_stub} [, {opt sep:arator(string)}|{opt pl:aceholder(string)} {opt e:xtension(string)} {opt f:ormat(string)} {opt dir:ectory(string)} {opt v:ersion(positive integer)}]

{phang}{cmd:use_current_version} [, {opt cl:ear} {opt sep:arator(string)}|{opt pl:aceholder(string)} {opt f:ormat(string)} {opt dir:ectory(string)} {opt v:ersion(positive integer)}]
  
{phang}{cmd:do_current_version} [, {opt sep:arator(string)}|{opt pl:aceholder(string)} {opt f:ormat(string)} {opt dir:ectory(string)} {opt v:ersion(positive integer)}]
  
{phang}{cmd:move_old_versions} [, {opt replace:} {opt erase:} {opt sep:arator(string)}|{opt pl:aceholder(string)} {opt a:rchive(string)} {opt e:xtension(string)} {opt k:eepcurrent} {opt f:ormat(string)} {opt dir:ectory(string)} {opt v:ersion(positive integer)}]
 
{phang}{cmd:save_current_version} [, {opt replace:} {opt sep:arator(string)}|{opt pl:aceholder(string)} {opt d:ofile} {opt m:oveold} {opt a:rchive(string)} {opt erase:} {opt f:ormat(string)} {opt v:ersion(positive integer)}]


{title:Description}

{phang}{cmd:current_version} determines the most recent version of a file, based on the date appended to the end of the filename

{phang}{cmd:use_current_version} opens the most recent version of a Stata dataset

{phang}{cmd:do_current_version} runs the most recent version of a Stata do-file

{phang}{cmd:move_old_version} moves all previous versions of a file to an archive folder

{phang}{cmd:save_current_version} saves the current data in memory as a Stata dataset with the current data appended to the filename


{title:Options}

{phang}{it:filename_stub} is the name of the file you want to find/save the current version of without the date or separator, e.g. "filename_stub_20200115.dta"

{phang}{opt separator(string)} is the character used in the filename to separate the filename_stub from the date, e.g. the second "_" in "filename_stub_20200115.dta". If not specified, the default is an underscore: sep("_")

{phang}{opt placeholder(string)} is an alternative way of specifying where the date will appear in the filename, where you provide a character that serves as a placeholder in the filename_stub for where the date can be found. E.g. "filename_stub_20200115.dta" could be specified as filename_stub="filename_stub_@", placeholder("@"), where "@" means 'replace @ with a date'

{phang}{opt extension(string)} is used to specify the file extension (e.g. ".dta"). You don't need to include the extension unless there are multiple files that share the filename_stub with different extensions.

{phang}{opt format(string)} is used to specify the format that the date component of the filename will take. The default is %tdCCYYMMDD, e.g. 15th January 2020 would be formatted as 20200115. You can also specify the format "redcap", which includes the date and time using the standard REDCap format (%tcCCYY-NN-DD!_HHMM), e.g. 15th January 2020 at 1:23pm would appear as 2020-01-15_1323

{phang}{opt directory(string)} is the directory where the file can be found/saved

{phang}{opt version(positive integer)} is the version number of the file you want to open/save. The most recent version is the default (1), the second most recent would be (2), etc. 

{phang}{opt clear} clears current data from memory

{phang}{opt replace} overwrites any previous file with the same filename

{phang}{opt erase} deletes previous versions of the file from the current working directory (the copies in the archive folder are not deleted)

{phang}{opt archive(string)} is the directory where previous versions of a file are saved. The default is a subfolder in the current working directory called "Previous versions"

{phang}{opt keepcurrent} specifies that you want to keep the current version in place

{phang}{opt dofile} specifies you are saving a do-file, in which case the current version (with no date in the filename) is saved in an archive folder with the current date. This means you only need to keep one version of your do-file, and you can save today's version in an archive folder to refer back to if you need it. 

{phang}{opt moveold} moves all previous versions of the file to an archive folder


{title:Examples}

Imagine today is the 15th January 2020
You have a Stata dataset you are working with "data.dta"
You are making some changes to/analysing this data in a do-file "dofile.do"

You open your do-file "dofile.do"
Instead of manually saving a copy of this do-file with today's date, you can use a command within your do-file:
	save_current_version "dofile", dofile

You could open your dataset with: 
	use "data.dta", clear

You might then make some changes to the data

You could then save this new dataset with today's date (to help keep track of changes you might make over time)
	save_current_version "data", replace
	
This will save the new dataset as "data20200115.dta"

You now want to open the new dataset. Instead of typing out the date, you can just use:
	use_current_version "data", clear
	
This will open "data20200115.dta" since it is the most recent version

You open a new dataset, and want to merge it with "data20200115.dta" (using the key variable 'id'). To do this:
	current_version "data"
	merge 1:1 id using "`r(current_version_filename)'"
	
Imagine you have another version of your data from 16th January 2020 "data20200116.dta"
You want to look at the data from 15th January to check something that has changed.
To open the 2nd most recent version:
	use_current_version "data", clear version(2)
	

{title:Stored results}

All current_version commands except for save_current_version store the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(all_versions)}} All version dates in YYYYMMDD format{p_end}
{synopt:{cmd:r(all_versions_dates)}} All version dates in %td format{p_end}
{synopt:{cmd:r(all_versions_filenames)}} All version filenames{p_end}
{synopt:{cmd:r(current_version)}} The current version date in YYYYMMDD format{p_end}
{synopt:{cmd:r(current_version_date)}} The current version date in %td format{p_end}
{synopt:{cmd:r(current_version_filename)}} The current version filename{p_end}

{title:Author}

{pstd}James Hedley{p_end}
{pstd}Murdoch Children's Research Institute{p_end}
{pstd}Melbourne, VIC, Australia{p_end}
{pstd}{browse "mailto:james.hedley@mcri.edu.au":james.hedley@mcri.edu.au}
