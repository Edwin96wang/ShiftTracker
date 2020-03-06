#! /bin/bash


detectors=("Ge00" "Ge03" "Ge06" "Ge07" "Ge08" "Ge09" "LABR00" "LABR01" "LABR02" "LABR03")
# echo ${detectors[2]}

rm ./PeakFile/*
rm ./PolyCoe/*

touch tempfile
for i in {1..9}
do
    echo "analysing run 0$i..."
    for (( j=0; j<${#detectors[@]}; j++))
    do
        PathName1="/data/ywang/Home/root2txt/txtfile/0${i}_000_${detectors[$j]}"
        PathName2="/data/ywang/Home/root2txt/txtfile/0${i}_*_${detectors[$j]}"
        PeakName_temp="/data/ywang/Home/ShiftTracking/PeakFile/0${i}_${detectors[$j]}.temp"
        PeakName="/data/ywang/Home/ShiftTracking/PeakFile/0${i}_${detectors[$j]}.txt"
        CoeName="/data/ywang/Home/ShiftTracking/PolyCoe/0${i}_${detectors[$j]}.txt"
        touch $PeakName_temp
        touch $PeakName
        touch $CoeName
        soco2 shift-tracker $PathName1 -s -10 | awk '{print $2 "\t" $4}' |tr -d \) | head -n -1 | tail -n+3 | sort -k2 -n | head -n 6 | awk '{print $1}' > $PeakName_temp
        soco2 shift-tracker $PathName2 -s -10 -p $PeakName_temp -l | head -n -1 | tail -n+3 > tempfile
        for k in 3 5 7 9 11 13
        do
            df=$(cat tempfile | tail -n+3| awk -v c1=$k '{print $c1}'| sort -n | sed -n '1p;$p' | awk 'NR ==1{a=$1} NR ==2{b=$1; print b-a}')
            if [ $df -le 30 ]; then
                cat tempfile | head -1 | awk -v c1=$k '{print $c1}' >> $PeakName
            else
                echo ""
                echo "-------------------------------------------------------------------------"
                echo "analysis failed at run $i for detector ${detectors[$j]}:"
                cat tempfile| awk -v c1=$k '{print $c1}'| sort -n | xargs
            fi 
        done
        soco2 shift-tracker $PathName2 -s -10 -p $PeakName -l | head -n -1 | tail -n+5 | awk '{print $1 "\t" $(NF-4) "\t" $(NF-2)}' > $CoeName
    done
done

rm tempfile


# for i in {1..1}
# do
#     echo "analysing run 0$i..."
#     for (( j=0; j<${#detectors[@]}; j++))
#     do
#     PathName1="/data/ywang/Home/root2txt/txtfile/0${i}_000_${detectors[$j]}"
#     PathName2="/data/ywang/Home/root2txt/txtfile/0${i}_*_${detectors[$j]}"
#     PeakName="/data/ywang/Home/ShiftTracking/PeakFile/0${i}_${detectors[$j]}.txt"
#     CoeName="/data/ywang/Home/ShiftTracking/PolyCoe/0${i}_${detectors[$j]}.txt"
#     touch $PeakName
#     touch $CoeName
#     echo "creating file 0${i}_${detectors[$j]}.txt"
#     soco2 shift-tracker $PathName1 -s -10 | awk '{print $2 "\t" $4}' |tr -d \) | head -n -1 | tail -n+3 | sort -k2 -n | head -n 6 | awk '{print $1}' > $PeakName
#     soco2 shift-tracker $PathName2 -s -10 -p $PeakName -l | head -n -1 | tail -n+5 | awk '{print $1 "\t" $(NF-4) "\t" $(NF-2)}' > $CoeName
#     done
# done