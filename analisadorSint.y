%{
    
    #include <iostream>
    #include <stdio.h>
    #include <cstdlib>
    #include <cstring>
    #include <map>
    #include <vector>
    #include "PropRule.cpp"
    using std::cout;
    using std::endl;

    int yylex(void);
    int yyparse(void);
    void yyerror(const char *);

    double variables[26];

    int numbClasses = 0;
    int comumClass = 0;
    int primitiveClass = 0;
    int definedClass = 0;
    int numErrors = 0;

    char currentClass[100];
    char currentOper[100];

    std::string currentProp;

    // pra sobrecarga de operadores
    PropRule** PropRule::propRules = new PropRule*[300];
    int qntdRules = 0;

    // pra precedencia de operadores
    std::vector<std::string> precAux;
    std::vector<std::string> onlyAppeareds;

    extern char *yytext;

%}

%union {
	double num;
	int ind;
}

%token SOME ALL VALUE MIN MAX EXACTLY THAT NOT OR AND ONLY INVERSE CLASS PROPRIETY INSTANCY SSYMBOL DTYPE CARDINALIDADE 
%token RCLASS RSUBCLASS REQUIVALENT RINDIVIDUALS RDISJOINT '[' ']' '(' ')' ',' '{' '}'

%%

classe: classeDefinida classe   { definedClass++; numbClasses++; }
    | classePrimitiva classe    { primitiveClass++; numbClasses++; }
    | classeComum classe        { comumClass++; numbClasses++; }
    | classeDesconhecida classe { definedClass++; numbClasses++; }
    | error classe              
    | 
    ;

rclass: RCLASS CLASS { strcpy(currentClass, yytext); precAux.clear(); onlyAppeareds.clear(); }
    ;

classeComum: rclass disjoint individuals { std::cout << "Classe Comum"; std::cout << " -> " << currentClass << std::endl; }
    ;

classePrimitiva: rclass subclass disjoint individuals { std::cout << "Classe Primitiva"; std::cout << " -> " << currentClass << std::endl; }
    ;

classeDefinida: rclass equivalent disjoint individuals { std::cout << "Classe Definida"; std::cout << " -> " << currentClass << std::endl; } 
    ;

classeDesconhecida: rclass equivalent subclass disjoint individuals { std::cout << "Classe Definida"; std::cout << " -> " << currentClass << std::endl; }
    ;

equivalent: requivalent CLASS equivProbs
    | requivalent instancies  { std::cout << "Classe enumerada, "; }
    ;

subclass: rsubclass CLASS
    | rsubclass seqProp
    | rsubclass CLASS connect seqProp
    | rsubclass CLASS ',' seqProp
    ;         

individuals: rindividuals instancies
    |
    ;

disjoint: rdisjoint seqClasses
    |
    ;    

requivalent: REQUIVALENT    { strcpy(currentOper, yytext); }
    ;

rsubclass: RSUBCLASS        { strcpy(currentOper, yytext); }
    ;        

rindividuals: RINDIVIDUALS  { strcpy(currentOper, yytext); }
    ;    

rdisjoint: RDISJOINT        { strcpy(currentOper, yytext); }
    ;                            

equivProbs: ',' seqProp
    | connect seqProp
    | connect multClasses { std::cout << "Classe coberta, "; }
    | '(' equivProbs ')'
    ;

seqClasses: CLASS
    | CLASS ',' seqClasses
    | '(' seqClasses ')' 
    ;

instancies: INSTANCY
    | INSTANCY ',' instancies
    | '{' instancies '}'
    ;    

connect: OR
    | AND
    ;

seqProp: prop      
    | prop connect seqProp         
    | prop ',' seqProp
    | INVERSE prop
    | INVERSE prop connect seqProp
    | INVERSE prop ',' seqProp
    ;

prop: propName some 
    | propName only        { std::cout << "Axioma de fechamento, \n"; 
                            int tam = precAux.size();
                            for(int i = 0; i < tam; i++) {
                                for(int j = 0; j < onlyAppeareds.size(); j++) { 
                                    std::string aux = precAux[i];
                                    if(!(aux.compare(onlyAppeareds[j]))) {
                                        onlyAppeareds.erase(onlyAppeareds.begin() + j);
                                    }
                                }
                            }
                            for(std::string sobrou : onlyAppeareds){
                                cout << "Precedência: " << sobrou << " não declarada antes de ser fechada. " << endl;
                            }
                            }
    | propName value
    | propName qntd
    | propName exactly
    | propName all
    | '(' seqProp ')'
    ;

propName: PROPRIETY         { currentProp = yytext;}
    ;

only: ONLY CLASS                    
    | ONLY '(' onlyMultClasses ')'
    ;

onlyMultClasses: auxOnlyClass
    | auxOnlyClass connect onlyMultClasses 
    ;

auxOnlyClass: CLASS             { onlyAppeareds.push_back(yytext); }
    ;

multClasses: CLASS
    | CLASS connect multClasses 
    ;

some: SOME CLASS        { PropRule* propy = new PropRule(currentProp, OBJPROP); PropRule::propRules[qntdRules++] = propy; precAux.push_back(yytext); }
    | SOME '(' multClasses ')'
    | SOME DTYPE especificardtype { PropRule* propy = new PropRule(currentProp, DATAPROP); PropRule::propRules[qntdRules++] = propy; }
    | SOME prop             { std::cout << "Descrição aninhada, "; }
    //| error                 { std::cout << "Esperava CLASS, DTYPE, PROPRIETY\n"; }
    ;

especificardtype: '[' SSYMBOL num ']'
    |
    ;

qntd: MIN num DTYPE   { PropRule* propy = new PropRule(currentProp, DATAPROP); PropRule::propRules[qntdRules++] = propy; precAux.push_back(yytext); }
    | MAX num DTYPE   { PropRule* propy = new PropRule(currentProp, DATAPROP); PropRule::propRules[qntdRules++] = propy; precAux.push_back(yytext); }
    | MIN num CLASS   { PropRule* propy = new PropRule(currentProp, OBJPROP); PropRule::propRules[qntdRules++] = propy; precAux.push_back(yytext); }
    | MAX num CLASS   { PropRule* propy = new PropRule(currentProp, OBJPROP); PropRule::propRules[qntdRules++] = propy; precAux.push_back(yytext); }
    ;

num: CARDINALIDADE      { int num = atoi(yytext); cout << num << endl; }
    ;

value: VALUE CLASS
    | VALUE INSTANCY
    | VALUE DTYPE especificardtype
    ;

exactly: EXACTLY CARDINALIDADE CLASS
    | EXACTLY '{' instancies '}'
    ;

all: ALL CLASS 
    | ALL '(' multClasses ')'
    ;

%%

/* definido pelo analisador léxico */
extern FILE * yyin;  
int main(int argc, char ** argv)
{

    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "\t\t\t\t ANÁLISE" << std::endl;
    cout << "-------------------------------------------------------------------------------" << std::endl;

    /* se foi passado um nome de arquivo */
	if (argc > 1)
	{
		FILE * file;
		file = fopen(argv[1], "r");
		if (!file)
		{
			cout << "Arquivo " << argv[1] << " não encontrado!\n";
			exit(1);
		}

		/* entrada ajustada para ler do arquivo */
		yyin = file;
	}

	yyparse();

    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "\t\t\t\t RESULTADOS" << std::endl;
    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "Classes comuns: \t" << comumClass << std::endl;
    cout << "Classes primitivas: \t" << primitiveClass << std::endl;
    cout << "Classes definidas: \t" << definedClass << std::endl;
    cout << "Classes com erro: \t" << numErrors << std::endl;
    cout << "Número de classes: \t" << numbClasses << std::endl;
    cout << "-------------------------------------------------------------------------------" << std::endl;

    cout << "-------------------------------------------------------------------------------" << std::endl;
    cout << "\t\t\t\t REGRAS" << std::endl;
    cout << "-------------------------------------------------------------------------------" << std::endl;

    std::map<std::string, int> correctRules;

    // 0 é Object Propriety e 1 é Data Propriety
    for(int i = 0; i < qntdRules; i++){
        std::string propriety = PropRule::propRules[i]->getName();
        cout << propriety << " -> " << PropRule::propRules[i]->getType() << endl;
        if(correctRules.find(propriety) == correctRules.end()) {
            correctRules[PropRule::propRules[i]->getName()] = PropRule::propRules[i]->getType();
        } else if(!(PropRule::propRules[i]->getType() == correctRules[propriety])) {
            cout << "Erro semântico!!! " << propriety << " já foi definida como " << correctRules[propriety] << endl;
        }
    }

    cout << correctRules["hasTopping"] << endl;
    
}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */
	extern int yylineno;    
	extern char * yytext;   

    numErrors++;
    cout << "-------------------------------------------------------------------------------\n";
    cout << "\t\t\t\t ERRO" << std::endl;
	/* mensagem de erro exibe o símbolo que causou erro e o número da linha */
    cout << "-------------------------------------------------------------------------------\n";
    cout << "ERRO SINTÁTICO: símbolo \"" << yytext << "\" (linha " << yylineno << " do arquivo)\n";
    cout << "NA PROPRIEDADE: \"" << currentOper << "\" DA CLASSE " << currentClass << std::endl;
    //cout << "Erro na " << numbClasses++ << "ª classe.\n";
    cout << "-------------------------------------------------------------------------------\n";
}