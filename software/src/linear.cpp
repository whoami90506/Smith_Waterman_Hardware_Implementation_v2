#include<iostream>
#include<fstream>
#include<string>
#include<algorithm>
#include <iomanip>
using namespace std;

const int _match = 6, _mismatch = -1, alpha = 2, beta = 1;

string* readfile(string file, int &len){
    string *result = 0;
    ifstream ifs(file);
    if(!ifs.is_open()){
        cout << "Error: file \"" << file << "\" doesn't exist!\n";
        return result;
    }

    ifs >> len;
    result = new string[len];
    for (int i = 0; i < len; ++i){
        ifs >> result[i];
    }

    ifs.close();
    return result;
}

inline float table(char a, char b) {
    return (a == b) ? _match : _mismatch;
}

float *V    = 0;
float *E    = 0;
float *F    = 0;
float *preV = 0;
float *preF = 0;

float calculate(const string &seqA, const string &seqB){
    float result = 0.0f;

    for (size_t i = 0; i < seqB.size(); ++i){
        preV[i] = 0.0f;
        preF[i] = 0.0f;
    }
    

    for(unsigned i = 0; i < seqA.size(); ++i){
        for(unsigned j = 0; j < seqB.size(); ++j){
            E[j] = j ? max(V[j-1] - alpha, E[j-1] - beta) : 0.0f;
            F[j] = max(preV[j] - alpha, preF[j] - beta);

            //0. new start
            V[j] = 0.0f;

            //1. diagonal 
            float temp = j ? preV[j-1] : 0.0f;
            temp += table(seqA[i], seqB[j]);
            if (temp > V[j] )V[j] = temp;

            //2. gap A
            if(F[j] > V[j])V[j] = F[j];

            //3. gap B
            if(E[j] > V[j])V[j] = E[j];

            //result
            if (V[j] > result){
                result = V[j];
            }
        }

        //swap
        float *temp = 0;
        
        temp = preV;
        preV = V;
        V = temp;

        temp = preF;
        preF = F;
        F = temp;
    }
    
    return result;
}

int main(int argc, char** argv){

    if(argc != 3){
        cout << "Usage: exec [A_file] [B_file]\n";
        return 1;
    }

    //readfile
    int lenA = 0, lenB = 0;
    string *Aarray = readfile(argv[1], lenA);
    string *Barray = readfile(argv[2], lenB);
    if(Aarray == 0 || Barray == 0)return 1;

    unsigned maxB = 0;
    for(int i = 0; i < lenB; ++i){
        if(Barray[i].size() > maxB)maxB = Barray[i].size();
    }
    V    = new float[maxB];
    E    = new float[maxB];
    F    = new float[maxB];
    preV =  new float[maxB];
    preF =  new float[maxB];

    //calculate
    for (int i = 0; i < lenB; i++) {
        for (int j = 0; j < lenA; j++){
            cout << "A[" << j << "], B[" << i << "] : " << calculate(Aarray[j], Barray[i]) << endl;
        }

        cout << "===B[" << i << "]===\n"; 
        
    }

    delete [] Aarray;
    delete [] Barray;
    delete [] V;
    delete [] E;
    delete [] F;
    delete [] preV;
    delete [] preF;
}
