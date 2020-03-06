#! /bin/bash

detectors=("Ge00" "Ge03" "Ge06" "Ge07" "Ge08" "Ge09" "LABR00" "LABR01" "LABR02" "LABR03")
# echo ${detectors[2]}


rm ./PolyCoe/*

for i in {1..9}
do
    for (( j=0; j<${#detectors[@]}; j++))
    do
        PathName1="/data/ywang/Home/root2txt/txtfile/0${i}_000_${detectors[$j]}"
        PathName2="/data/ywang/Home/root2txt/txtfile/0${i}_*_${detectors[$j]}"
        PeakName_temp="/data/ywang/Home/ShiftTracking/PeakFile/0${i}_${detectors[$j]}.temp"
        CoeName="/data/ywang/Home/ShiftTracking/PolyCoe/0${i}_${detectors[$j]}.txt"
        touch $CoeName

        if [ -f "$PeakName_temp" ]
        then
            
            soco2 shift-tracker $PathName2 -s -10 -p $PeakName_temp -l | head -n -1 | tail -n+5 | awk '{print $1 "\t" $(NF-4) "\t" $(NF-2)}' > $CoeName
        else
            array=( $( ls $PathName2 ) )
            for i_file in "${array[@]}"
            do
                echo -e "$i_file\t0\t1" >> $CoeName
            done
        fi 
        
    done
done

# rm tempfile


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