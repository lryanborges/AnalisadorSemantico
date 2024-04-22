#include <iostream>
#include <vector>
#include <map>
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

    analisadorSem();
    ~analisadorSem();

    void precedenceChecker(string currentOper, int currentLine);
    void overloadChecker();
};