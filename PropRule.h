#include <string>
using std::string;

enum types{
    OBJPROP,
    DATAPROP
};

class PropRule {

private:
    string name;
    types type;
    string category;
    int line;

public:
    static PropRule** propRules;

    PropRule(std::string n, types t, int l);
    
    void setType(types t);
    string getName();
    types getType();
    string getCategory();
    string getLine();
};