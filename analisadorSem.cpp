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
        string error = "(Linha " + std::to_string(currentLine) + ") \"" + sobrou + "\" não foi declarada antes de ser fechada.\n";
        semanticErrors.push_back(error);
        qntdErrors++;
    }
}

void analisadorSem::operPrecedenceChecker(string currentOper, int currentLine) {
    string error = "(Linha " + std::to_string(currentLine - 3) + ") \"" + currentOper + "\" não foi declarada no lugar correto.\n";
    semanticErrors.push_back(error);
    qntdErrors++;
}

void analisadorSem::coercionChecker(string currentDtype, string num, int currentLine){

    vector<std::string> dtype;
    size_t start = 0, end = 0;
    while ((end = currentDtype.find(':', start)) != string::npos) {
        dtype.push_back(currentDtype.substr(start, end - start));
        start = end + 1;
    }
    dtype.push_back(currentDtype.substr(start));

    if(atoi(num.c_str()) <= 0){
        //string error = "(Linha " + std::to_string(currentLine) + ") \"" + std::to_string(num) + "\" não pode ser atribuído ao tipo \"" + dtype.back() + "\".\n";
        string error = "(Linha " + std::to_string(currentLine) + ") Não pode ser atribuído \"" + num + "\" ao quantificador de \"" + dtype.back() + "\".\n";
        semanticErrors.push_back(error);
        qntdErrors++;
    }

    if(dtype.back() == "string" || dtype.back() == " string") {

    } else if(dtype.back() == "integer" || dtype.back() == " integer") {
        if(num.find('.') != string::npos){ // verifica se é float
            string error = "(Linha " + std::to_string(currentLine) + ") \"" + num + "\" não pode ser atribuído ao tipo \"" + dtype.back() + "\".\n";   
            semanticErrors.push_back(error);
            qntdErrors++;
        }
    } else if(dtype.back() == "float" || dtype.back() == " float" || dtype.back() == "double" || dtype.back() == " double"){
        if(num.find('.') == string::npos){ // verifica se é inteiro
            string error = "(Linha " + std::to_string(currentLine) + ") \"" + num + "\" não pode ser atribuído ao tipo \"" + dtype.back() + "\".\n";
            semanticErrors.push_back(error);
            qntdErrors++;
        }
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
            string error = "(Linha " + PropRule::propRules[i]->getLine() + ") \"" + propriety + "\" foi usada como \"" + PropRule::propRules[i]->getCategory() + "\" mas já estava definida como \"" + correctRules[propriety] + "\"\n";
            semanticErrors.push_back(error);
            qntdErrors++;
        }
    }
}