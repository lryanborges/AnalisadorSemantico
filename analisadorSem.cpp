#include "analisadorSem.h"

analisadorSem::analisadorSem()
{
}

analisadorSem::~analisadorSem()
{
}

void analisadorSem::precedenceChecker(string currentOper, int currentLine)
{
    for (int i = 0; i < precAux.size(); i++)
    {
        for (int j = 0; j < onlyAppeareds.size(); j++)
        {
            std::string aux = precAux[i];
            if (!(aux.compare(onlyAppeareds[j])))
            {
                onlyAppeareds.erase(onlyAppeareds.begin() + j);
            }
        }
    }
    for (std::string sobrou : onlyAppeareds)
    {
        string error = "(Linha " + std::to_string(currentLine) + ") " + sobrou + " não foi declarada antes de ser fechada.\n";
        semanticErrors.push_back(error);
    }
}

void analisadorSem::overloadChecker()
{
    std::map<string, string> correctRules;

    // 0 é Object Propriety e 1 é Data Propriety
    for(int i = 0; i < qntdRules; i++){
        std::string propriety = PropRule::propRules[i]->getName();
        //cout << propriety << " -> " << PropRule::propRules[i]->getCategory() << endl;
        if(correctRules.find(propriety) == correctRules.end()) {
            correctRules[PropRule::propRules[i]->getName()] = PropRule::propRules[i]->getCategory();
        } else if(!(PropRule::propRules[i]->getCategory() == correctRules[propriety])) {
            string error = "(Linha " + PropRule::propRules[i]->getLine() + ") " + propriety + " foi usada como " + PropRule::propRules[i]->getCategory() + " mas já estava definida como " + correctRules[propriety] + "\n";
            semanticErrors.push_back(error);
        }
    }
}