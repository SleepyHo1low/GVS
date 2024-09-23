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
		cout << "\nУдалены массивы dataA и dataB\n";
	}

	void make_arrays() {
		dataA = new float[n];
		dataB = new float[n];
	}
	void readFile(string path) {
		ifstream in;
		in.open(path);
		if (!in.is_open()) {
			cout << "\nФайл не открыт";
			return;
		}
		cout << "\nФайл открыт для чтения данных";
		in >> n;
		cout << "\nкол - во элементов массивов: " << n << endl;
		if (n == 0) {
			cout << "\nПерезаписываю файл...";
			in.close();
			writeFile(path);
		}
		else {
			make_arrays();
			for (int i = 0; i < n; i++) {
				in >> dataA[i];
				in >> dataB[i];
			}
			in.close();
			cout << "\nФайл считан";
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
			cout << "\nФайл не открыт";
			return;
		}
		cout << "\nФайл открыт для записи данных\nВведите N: ";
		cin >> n;
		make_arrays();
		fillArrays();

		out << n;
		out << "\n";
		for (int i = 0; i < n; i++) {
			out << dataA[i];
			out << " ";
			out << dataB[i];
			out << "\n";
		}

		cout << "\nФайл записан";
		out.close();
		return;
	}
};