#! /bin/bash

det=LABR01
run_number=09
filename="/data/ywang/Home/ShiftTracking/checking/bash_file_$det_$run_number.bash"
if [-e "$filename"]
then
    rm $filename
fi
touch $filename
chmod +777 $filename
detID=`cat /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/channel.conf | grep $det |awk '{print $1}'`
echo "cd /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/dump_full_statistics" > $filename
echo "" >> $filename
cd /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/dump_full_statistics

for i in `find /data/mweinert/experiments/120Sn_pp/2020/eventbuilding/dump_full_statistics | grep Run${run_number}`; do
    echo "root get $i/$det" >> $filename
    subname=$(echo $i | cut -d '_' -f 10)
    subname="subrun$subname"
    echo "s name $subname" >> $filename
    CoeName=`echo $i| cut -d "/" -f 9 | cut -d "." -f 1 | cut -d "_" -f 2-7`
    CoeName="/data/ywang/Home/ShiftTracking/shift_poly_coeff/evt_$CoeName.shifts"
    intercep=`cat $CoeName | grep -w $detID | awk '{print $2}'`
    slope=`cat $CoeName | grep -w $detID | awk '{print $3}'`
    echo "$subname: $intercep    $slope "
    echo "cal po set $intercep $slope" >> $filename
    echo "" >> $filename
done