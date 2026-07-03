#!/bin/csh 

set log = "rep.log"
if (-f $log) then
    rm -rf $log
endif

touch $log

printf "|-----------------------------------------------------------------------------------------------|\n" >> $log
printf "|%-40s |%-30s |%-20s |\n" " PAT_NAME" " RUN_DATE" " RESULT"                                             >> $log
printf "|-----------------------------------------------------------------------------------------------|\n" >> $log
foreach pat (`cat pat.list | sed '\/\//d'`)
    echo $pat
    set sim_log = "log/${pat}.log"
    set res = ""
    
    if( !(-f $sim_log)) then
        res = "NA"
        echo "can not find $sim_log"
    else
        set tm = `grep "End time" $sim_log | awk -F"[ :,]" '{print $5 ":" $6 ":" $7 " " $9 " " $10 " " $11}'`
        set res = `grep "Test_result" $sim_log | awk '{print $3}'`
        #echo "DBG $tm $res"
        printf "|%-40s |%-30s |%-20s |\n" " $pat" " $tm" " $res"                                             >> $log
        printf "|-----------------------------------------------------------------------------------------------|\n" >> $log
    endif
end

cat $log
