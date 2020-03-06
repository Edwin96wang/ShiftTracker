#! /bin/bash

#detector=("LABR00" "LABR01" "LABR02" "LABR03")
detector=("LABR00")
filename="/data/ywang/Home/ShiftTracking/checking/bash_file.bash"
if [ -e "$filename" ]
then
    rm $filename
fi
touch $filename
chmod +777 $filename
echo "cd /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/dump_full_statistics" > $filename
echo "" >> $filename
cd /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/dump_full_statistics

for det in "${detector[@]}"
do
    detID=`cat /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/channel.conf | grep $det |awk '{print $1}'`
    for run_number in {2..2}
    do
        echo ">>>>>>>>>>>Input run0$run_number"
        for i in `find /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/dump_full_statistics | grep Run0${run_number}`; do
            if grep -Fxq "$i" /data/ywang/Home/ShiftTracking/checking/DiscardFiles.txt
            then
                echo "$i discarded"
            else
                echo "root get $i/$det" >> $filename
                subname=$(echo $i | cut -d '_' -f 10)
                subname="subrun$subname"
                echo "s name $subname" >> $filename
                CoeName=`echo $i| cut -d "/" -f 9 | cut -d "." -f 1 | cut -d "_" -f 2-7`
                CoeName="/data/ywang/Home/ShiftTracking/shift_poly_coeff/evt_$CoeName.shifts"
                intercep=`cat $CoeName | grep -w $detID | awk '{print $2}'`
                slope=`cat $CoeName | grep -w $detID | awk '{print $3}'`
                echo -ne "$subname: $intercep    $slope | \t"
                echo "cal po set $intercep $slope" >> $filename
                echo "s s 0" >> $filename
                echo "" >> $filename
            fi
        done
    done
done

hdtv -b $filename
