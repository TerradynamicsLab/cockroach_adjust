:: Text box params -  shows video filename by default
:: (xtext,ytext) - Position of textbox from top-left corner of video 
:: tbcolor / tbalpha - textbox fill color / transparency value


set xtext=20
set ytext=20
set "textcol=yellow"
set "tbcolor=white"
set tbalpha=0
set tbfontsize=36




set qFactor=2


set "parentDir=D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\f2_raw_videos_36"
set "targetDir=D:\Dropbox (Terradynamics Lab)\Yaqing\1-Cockroach_adjust_experiment\p3_selected\f3_stack_36"

::echo %targetDir%
md "%targetDir%"
setlocal EnableDelayedExpansion
echo 1
for /L %%A in (1,1,42) do (	
	echo 1
	set "x=Trial_%%A"	

	ffmpeg  -i "%parentDir%\!x:~0!_Cam_1.avi"  -i "%parentDir%\!x:~0!_Cam_2.avi" -i "%parentDir%\!x:~0!_Cam_3.avi" -i "%parentDir%\!x:~0!_Cam_4.avi" -i "%parentDir%\!x:~0!_Cam_5.avi" -i "%parentDir%\!x:~0!_Cam_6.avi" -i "%parentDir%\!x:~0!_Cam_7.avi" -i "%parentDir%\!x:~0!_Cam_8.avi" -filter_complex "[0:v]scale=648:512[v0];[1:v]scale=648:512[v1];[2:v]scale=648:512[v2];[3:v]scale=648:512[v3];[4:v]scale=648:512[v4];[5:v]scale=648:512[v5];[6:v]scale=648:512[v6];[7:v]scale=648:512[v7];[v0][v1]hstack[v01];[v2][v3]hstack[v23];[v01][v23]hstack[v0123];[v4][v5]hstack[v45];[v6][v7]hstack[v67];[v45][v67]hstack[v4567];[v0123][v4567]vstack[v]" -map "[v]" -vcodec libxvid -q:v %qFactor% -y "%targetDir%\!x:~0!.avi"
)
