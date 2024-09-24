#include <iostream>
#include <string>
#include <fstream>
#include <random>

using namespace std;

class Data {
public:
    int n;
    float* dataA;
    float* dataB;

    // Constructor 
    Data(string path) {

        ifstream inFile(path, std::ios::binary);
        if (!inFile.is_open()) {

            inFile.close();
            writeArrayToBinaryFile(path);
        }
        else {
            inFile.close();
            readArrayFromBinaryFile(path);
        }
    }

    // Destructor 
    ~Data() {
        delete[] dataA;
        delete[] dataB;
        //cout << "\nDelete dataA & dataB\n";
    }

    // Allocate memory for data arrays 
    void allocateData() {
        dataA = new float[n];
        dataB = new float[n];
    }

    // Generate random data for arrays 
    void generateData() {
        srand(time(NULL));
        for (int i = 0; i < n; ++i) {
            dataA[i] = (float)(rand()) / (float)(RAND_MAX);
            dataB[i] = (float)(rand()) / (float)(RAND_MAX);
        }
        cout << "\nData generation complete\n";
    }

    bool isFileEmpty(const std::string& filename) {
        std::ifstream file(filename, std::ios::binary);
        char ch;
        return file.is_open() && !file.get(ch);
    }

    void readArrayFromBinaryFile(string path) {

        ifstream inFile(path, std::ios::binary);

        if (isFileEmpty(path)) {
            cout << "\nFile is empty. Generating data...\n";
            inFile.close();
            writeArrayToBinaryFile(path);
            return;
        }

        // Считываем размер массива из начала файла
        inFile.read(reinterpret_cast<char*>(&n), sizeof(int));

        //выделяем память
        allocateData();

        // Считываем сам массив
        inFile.read(reinterpret_cast<char*>(dataA), n * sizeof(float));
        inFile.read(reinterpret_cast<char*>(dataB), n * sizeof(float));
        inFile.close();
        cout << "Read file complete: " << path << endl;

    }

    void writeArrayToBinaryFile(string path) {
        ofstream outFile(path, std::ios::binary);

        if (!outFile.is_open()) {
            cout << "\nFile not open: " << path << endl;
            return;
        }
        cout << "\nFile open for write data\ninsert N: ";
        cin >> n;
        allocateData();
        generateData();
        // Записываем размер массива в начале файла
        outFile.write(reinterpret_cast<const char*>(&n), sizeof(int));

        // Записываем сам массив
        outFile.write(reinterpret_cast<char*>(dataA), n * sizeof(float));
        outFile.write(reinterpret_cast<char*>(dataB), n * sizeof(float));

        outFile.close();
        cout << "Write data complete: " << path << endl;
    }
};