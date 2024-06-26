%{
    
    #include <iostream>
    #include <stdio.h>
    #include <map>
    #include <vector>
    #include "analisadorSem.cpp"
    using std::vector;
    using std::string;
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
    int unknownClass = 0;
    int numErrors = 0;

    bool isSubclassOf = false;
    string currentClass;
    string currentOper;
    string precedenceAux;
    string coercionAux;
    string currentNum = "";

    vector<string> sintatico;
    vector<string> sintaticErrors;
    string sintClass = "";

    std::string currentProp;

    // pra sobrecarga de operadores
    PropRule** PropRule::propRules = new PropRule*[300];

    // analisador semântico
    analisadorSem * semantico = new analisadorSem();

    extern char *yytext;
    extern int yylineno; 

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
    | operPrecedenceAux classe  { unknownClass++; numbClasses++; }
    | error classe              
    | 
    ;

rclass: RCLASS CLASS { currentClass = yytext; semantico->precAux.clear(); semantico->onlyAppeareds.clear(); sintClass = ""; }
    ;

classeComum: classeComumProbs   { sintClass += "Classe Comum -> " + currentClass + "\n"; sintatico.push_back(sintClass); }
    ;

classeComumProbs: rclass disjoint individuals 
    | rclass disjoint
    | rclass individuals
    | rclass
    ;

classePrimitiva: classePrimitivaProbs   { sintClass += "Classe Primitiva -> " + currentClass + "\n"; sintatico.push_back(sintClass); }
    ;

classePrimitivaProbs: rclass subclass disjoint individuals 
    | rclass subclass disjoint
    | rclass subclass individuals
    | rclass subclass
    ;

classeDefinida: classeDefinidaProbs { sintClass += "Classe Definida -> " + currentClass + "\n"; sintatico.push_back(sintClass); } 
    ;

classeDefinidaProbs: rclass equivalent disjoint individuals 
    | rclass equivalent disjoint
    | rclass equivalent individuals
    | rclass equivalent
    | rclass equivalent subclass disjoint individuals
    | rclass equivalent subclass disjoint
    | rclass equivalent subclass individuals
    | rclass equivalent subclass
    ;

operPrecedenceAux: operPrecedenceAuxProbs   { sintClass += "Classe Desconhecida -> " + currentClass + "\n"; sintatico.push_back(sintClass); semantico->operPrecedenceChecker(currentOper, yylineno); }
    ;

// várias possibilidades de erro semantico p se aceitar no sintatico
operPrecedenceAuxProbs: rclass subclass equivalent
    | rclass subclass equivalent disjoint individuals
    | rclass subclass equivalent individuals disjoint
    | rclass subclass equivalent individuals
    | rclass subclass equivalent disjoint
    | rclass subclass individuals disjoint
    | rclass equivalent individuals disjoint
    | rclass individuals equivalent subclass disjoint
    | rclass disjoint equivalent subclass individuals
    | rclass individuals equivalent subclass
    | rclass disjoint equivalent subclass
    | rclass individuals subclass
    | rclass individuals equivalent
    | rclass disjoint subclass
    | rclass disjoint equivalent
    ;

equivalent: requivalent CLASS equivProbs
    | requivalent instancies  { sintClass += "Classe enumerada, "; }
    ;

subclass: rsubclass CLASS
    | rsubclass seqProp
    | rsubclass CLASS connect seqProp
    | rsubclass CLASS ',' seqProp
    ;         

individuals: rindividuals instancies
    ;

disjoint: rdisjoint seqClasses
    ;    

requivalent: REQUIVALENT    { currentOper = yytext; isSubclassOf = false; }
    ;

rsubclass: RSUBCLASS        { currentOper = yytext; isSubclassOf = true; }
    ;        

rindividuals: RINDIVIDUALS  { currentOper = yytext; }
    ;    

rdisjoint: RDISJOINT        { currentOper = yytext; }
    ;                            

equivProbs: ',' seqProp
    | connect seqProp
    | connect multClasses { sintClass += "Classe coberta, "; }
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
    | propName only        { sintClass += "Axioma de fechamento, "; semantico->precedenceChecker(currentProp, yylineno); }
    | propName value
    | propName qntd
    | propName exactly
    | propName all
    | '(' seqProp ')'
    ;

propName: PROPRIETY         { currentProp = yytext;}
    ;

only: ONLY auxOnlyClass                    
    | ONLY '(' onlyMultClasses ')'
    ;

onlyMultClasses: auxOnlyClass
    | auxOnlyClass connect onlyMultClasses 
    ;

auxOnlyClass: CLASS             { if(isSubclassOf) semantico->onlyAppeareds.push_back(yytext); }
    ;

multClasses: className  
    | className connect multClasses 
    ;

className: CLASS            { precedenceAux = yytext; coercionAux = yytext; }
    ;

some: SOME CLASS       { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, OBJPROP, yylineno);  semantico->precAux.push_back(yytext); }
    | SOME '(' multClasses ')' { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, OBJPROP, yylineno);  semantico->precAux.push_back(precedenceAux); precedenceAux = ""; }
    | SOME dtype especificardtype { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, DATAPROP, yylineno); }
    | SOME prop             { sintClass += "Descrição aninhada, "; }
    //| error                 { std::cout << "Esperava CLASS, DTYPE, PROPRIETY\n"; }
    ;

especificardtype: '[' SSYMBOL num ']'   { semantico->coercionChecker(coercionAux, currentNum, yylineno); }
    |
    ;

qntd: MIN num dtype   { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, DATAPROP, yylineno); semantico->precAux.push_back(yytext); semantico->coercionChecker(coercionAux, currentNum, yylineno); }
    | MAX num dtype   { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, DATAPROP, yylineno); semantico->precAux.push_back(yytext); semantico->coercionChecker(coercionAux, currentNum, yylineno); }
    | MIN num className   { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, OBJPROP, yylineno);  semantico->precAux.push_back(yytext); semantico->coercionChecker(coercionAux, currentNum, yylineno); }
    | MAX num className   { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, OBJPROP, yylineno);  semantico->precAux.push_back(yytext); semantico->coercionChecker(coercionAux, currentNum, yylineno); }
    ;

num: CARDINALIDADE      { currentNum = yytext; }
    ;

dtype: DTYPE            { coercionAux = yytext; }
    ;

value: VALUE CLASS      { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, OBJPROP, yylineno);  semantico->precAux.push_back(yytext); }
    | VALUE INSTANCY    { PropRule::propRules[semantico->qntdRules++] = new PropRule(currentProp, OBJPROP, yylineno);  semantico->precAux.push_back(yytext); }
    | VALUE dtype especificardtype
    ;

exactly: EXACTLY num className      { semantico->coercionChecker(coercionAux, currentNum, yylineno); }
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
    semantico->overloadChecker();

    cout << "Arquivo lido: " << argv[1] << endl;

    int opc = 0;
    do {
        cout << "----------------------------------" << std::endl;
        cout << "\t\tAnálise" << endl;
        cout << "----------------------------------" << std::endl;
        cout << "[1] - Visualizar especificações das classes\n";
        cout << "[2] - Visualizar contagens de classes\n";
        cout << "[3] - Visualizar erros semânticos\n";
        cout << "[4] - Visualizar erros sintáticos\n";
        cout << "[5] - Encerrar a análise\n";
        cout << "----------------------------------" << std::endl;
        cout << "Opção: ";
        std::cin >> opc;  

        switch(opc){
        case 1:
            cout << "-------------------------------------------------------------------------------" << std::endl;
            cout << "\t\t\t\t ANÁLISE" << std::endl;
            cout << "-------------------------------------------------------------------------------" << std::endl;
            for(string c : sintatico) {
                cout << c;
            }
        break;
        case 2:
            cout << "-------------------------------------------------------------------------------" << std::endl;
            cout << "\t\t\t\t CONTAGEM" << std::endl;
            cout << "-------------------------------------------------------------------------------" << std::endl;
            cout << "Classes comuns: \t" << comumClass << std::endl;
            cout << "Classes primitivas: \t" << primitiveClass << std::endl;
            cout << "Classes definidas: \t" << definedClass << std::endl;
            cout << "Classes desconhecidas: \t" << unknownClass << std::endl;
            cout << "Erros encontrados: \t" << numErrors + semantico->qntdErrors << std::endl;
            cout << "Número de classes: \t" << numbClasses << std::endl;
            cout << "-------------------------------------------------------------------------------" << std::endl;
        break;
        case 3:
            cout << "-------------------------------------------------------------------------------" << std::endl;
            cout << "\t\t\t\t ERROS SEMÂNTICOS" << std::endl;
            cout << "-------------------------------------------------------------------------------" << std::endl;
            for(string e : semantico->semanticErrors){
                cout << "ERRO SEMÂNTICO: " << e;
            }  
            if(semantico->semanticErrors.size() == 0){
                cout << "Nenhum erro semântico encontrado. Verifique os sintáticos.\n";
            }
        break;
        case 4:
            cout << "-------------------------------------------------------------------------------" << std::endl;
            cout << "\t\t\t\t ERROS SINTÁTICOS" << std::endl;
            cout << "-------------------------------------------------------------------------------" << std::endl;
            for(string e: sintaticErrors){
                cout << e;
            }
            if(sintaticErrors.size() == 0){
                cout << "Nenhum erro sintático encontrado.\n";
            }
        break;
        default:
        break;
        }
    } while(opc != 5);

    cout << "Análise Encerrada." << endl;

}

void yyerror(const char * s)
{
	/* variáveis definidas no analisador léxico */   
	extern char * yytext;   

    numErrors++;
    string aux = "";

    aux += "ERRO SINTÁTICO: símbolo \"" + std::string(yytext) + "\" (linha " + std::to_string(yylineno) + " do arquivo)\n";
    aux += "NA PROPRIEDADE: \"" + currentOper + "\" DA CLASSE " + currentClass + "\n";

    sintaticErrors.push_back(aux);
    aux = "";
}