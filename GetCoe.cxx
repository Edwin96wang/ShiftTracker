#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <array>
#include <map>

using namespace std;

int GetCoe(){
    vector<string> detectors = {"LABR00","LABR01","LABR02","LABR03","Ge00","Ge03","Ge06","Ge07","Ge08","Ge09"};
    map<string, int> detectorID;
    detectorID["Ge00"]      =   0;
    detectorID["Ge03"]      =   1;
    detectorID["Ge06"]      =   2;
    detectorID["Ge07"]      =   3;
    detectorID["Ge08"]      =   4;
    detectorID["Ge09"]      =   5;
    detectorID["LABR00"]    =   16;
    detectorID["LABR01"]    =   17;
    detectorID["LABR02"]    =   18;
    detectorID["LABR03"]    =   19;
    

    int num_run = 9;
    ifstream myfile;
    ofstream outfile;
    ostringstream file_name;
    string num0;
    string num1;
    string num2;
    string word;

    //reading Global coeff:
    using polyCoeff2_c = array<double,2>;
    using det_coeff_c = vector<polyCoeff2_c>;
    using Glo_coeff_c = map<string, det_coeff_c>;
    
    det_coeff_c glo_det(0,{0,0});
    Glo_coeff_c glo_coeff;

    for(int i =0; i < detectors.size(); i++){
        file_name << "/data/ywang/Home/ShiftTracking/Global/" << detectors[i];
        myfile.open(file_name.str());
        file_name.str("");

        while(myfile.good()){
            myfile >> num1;
            myfile >> num2;
            if (glo_det.size() < num_run ){
                glo_det.push_back({stod(num1), stod(num2)});
            }
            
        }
        if(glo_det.size() != num_run) cout << "error occured for the size" << endl;
        myfile.close();
        glo_coeff[detectors[i]]=glo_det;
        glo_det.clear();
    }

    // //show the global coeff:
    // for(map<string, det_coeff_c>::iterator it = glo_coeff.begin(); it != glo_coeff.end(); it++){
    //     cout << it->first <<": " << endl;
    //     for (const auto &i : it->second){
    //         cout << i[0] << "\t" << i[1]<< endl;
    //     }
    // }


    // implementing the calibration factors:
    
    using polyCoeff_c = array<double,3>;
    using subruns_c = vector<polyCoeff_c>;
    using runs_c = vector<subruns_c>;
    using det_runs_c = vector<runs_c>;

    subruns_c subruns(0, {0,0,0});
    runs_c runs;
    det_runs_c data;

    //initialization of data:
    for(size_t i =1; i < num_run+1; i++){
        runs.push_back(subruns);
    }
    for(int j =0; j < detectors.size(); j++){
        data.push_back(runs);
    }
    

    //fill data values:
    
    

    for(int i =0; i < detectors.size(); i++){
        for (int j=1; j <num_run+1; j++){
            file_name << "/data/ywang/Home/ShiftTracking/PolyCoe/" << setfill('0')<<setw(2) <<j <<"_"<<detectors[i] << ".txt";
            myfile.open(file_name.str());
            file_name.str("");

            while(myfile.good()){
                myfile >> word;
                num0 = word.substr(37, 3);
                myfile >> num1;
                myfile >> num2;
                if (subruns.size() > 0 ){
                    if (stod(num0) != subruns[subruns.size()-1][0]){
                        subruns.push_back({stod(num0), stod(num1), stod(num2)});
                    }
                }
                else{
                    subruns.push_back({stod(num0), stod(num1), stod(num2)});
                }
            }
            myfile.close();
            data[i][j-1]=subruns;
            subruns.clear();
        }
    }

    // // show data
    // for (int i = 0; i < data.size(); i++)
    // {
    //     cout << detectors[i] << ": " << endl;
    //     for (int j = 0; j < data[i].size(); j++)
    //     {
    //         cout << "\t" << j + 1 << " run: "<< endl;
    //         for (int k = 0; k < data[i][j].size(); k++)
    //         {
    //             if (j==4) cout << "subruns "<<data[i][j][k][0] << ": "<<  data[i][j][k][1]<< "\t"<< data[i][j][k][2]<< endl;;
    //         }
    //     }
    // }

    //calculate total coefficient
    for (int i = 0; i < data.size(); i++)
    {
        if(data[i].size() != num_run ) cout << "error occured for the size" << endl;
        for (int j = 0; j < data[i].size(); j++)
        {
            for (int k = 0; k < data[i][j].size(); k++)
            {   
                data[i][j][k][1] = glo_coeff[detectors[i]][j][0]+data[i][j][k][1]*glo_coeff[detectors[i]][j][1];
                data[i][j][k][2] = glo_coeff[detectors[i]][j][1]*data[i][j][k][2];
            }
        }
    }

    //output the files

    for(int i=0; i < num_run; i++){
        for(int j=0; j < data[0][i].size();j++){
            if(j == 0){
                //file_name << "/data/ywang/Home/ShiftTracking/shift_poly_coeff/evt_compass_120Sn_ppg_15368keV_Run"<< setfill('0')<<setw(2) << i+1 <<".shifts";
                file_name << "/data/ywang/Home/ShiftTracking/shift_poly_coeff_ohne_evt/compass_120Sn_ppg_15368keV_Run"<< setfill('0')<<setw(2) << i+1 <<".shifts";
            }
            else{
                //file_name << "/data/ywang/Home/ShiftTracking/shift_poly_coeff/evt_compass_120Sn_ppg_15368keV_Run"<< setfill('0')<<setw(2) << i+1 << "_"<<j << ".shifts";
                file_name << "/data/ywang/Home/ShiftTracking/shift_poly_coeff_ohne_evt/compass_120Sn_ppg_15368keV_Run"<< setfill('0')<<setw(2) << i+1 << "_"<<j << ".shifts";
            }
            outfile.open(file_name.str(), fstream::out | fstream::trunc);
            file_name.str("");
            outfile << "#ID" <<"\ts0\ts1" << "\n";
            for(int k=0; k < detectors.size(); k++){
                outfile << detectorID[detectors[k]] <<"\t"<< data[k][i][j][1] << "\t" << data[k][i][j][2] << "\n";
            }
            outfile.close();
            
            
        }
    }


    return 0;
}