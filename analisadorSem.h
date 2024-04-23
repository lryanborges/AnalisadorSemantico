#include <iostream>
#include <vector>
#include <map>
#include <cmath>
#include <cstdlib>
#include "PropRule.cpp"
using std::vector;
using std::string;
using std::cout;
using std::endl;

class analisadorSem {
  private:

  public:
    int qntdRules = 0;
    vector<string> precAux;
    vector<string> onlyAppeareds;
    vector<string> semanticErrors;
    vector<string> coercionAppeareds;

    analisadorSem();
    ~analisadorSem();

    void precedenceChecker(string currentOper, int currentLine);
    void coercionChecker(string currentDtype, string num, int currentLine);
    void overloadChecker();
};