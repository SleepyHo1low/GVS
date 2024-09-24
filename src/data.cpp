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
	//конструктор/
	Data(string path) {
		ifstream in;
		in.open(path);
		if (!in.is_open()) {
			in.close();
			writeFile(path);
		}
		else {
			in.close();
			readFile(path);
		}
	}

	//деструктор
	~Data() {
		delete[] dataA, dataB;
		cout << "\nDelete dataA & dataB\n";
	}

	void make_arrays() {
		dataA = new float[n];
		dataB = new float[n];
	}
	void readFile(string path) {
		ifstream in;
		in.open(path);
		if (!in.is_open()) {
			cout << "\nFile not open";
			return;
		}
		cout << "\nFile open for read";
		in >> n;
		cout << "\nnum of elements in array: " << n << endl;
		if (n == 0) {
			cout << "\nrewrite file...";
			in.close();
			writeFile(path);
		}
		else {
			make_arrays();
			for (int i = 0; i < n; i++) {
				in >> dataA[i] >> dataB[i];
			}
			in.close();
			cout << "\nfile read is complete\n";
		}
		return;
	}

	void fillArrays()
	{
		srand(time(NULL));
		for (int i = 0; i < n; ++i)
		{
			dataA[i] = (float)(rand()) / (float)(RAND_MAX);
			dataB[i] = (float)(rand()) / (float)(RAND_MAX);
		}
	}

	void writeFile(string path) {
		ofstream out;
		out.open(path);
		if (!out.is_open()) {
			cout << "\nFile not open";
			return;
		}
		cout << "\nFile open for write data\ninsert N: ";
		cin >> n;
		make_arrays();
		fillArrays();

		out << n;
		out << "\n";
		for (int i = 0; i < n; i++) {
			out << dataA[i] << " " << dataB[i] << "\n";
		}

		cout << "\nFile wrote is complete\n";
		out.close();
		return;
	}
};