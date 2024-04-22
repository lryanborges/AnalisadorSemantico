#include <string>

enum types{
    OBJPROP,
    DATAPROP
};

class PropRule {

private:
    std::string name;
    types type;

public:
    static PropRule** propRules;

    PropRule(std::string n, types t);
    ~PropRule();
    void setType(types t);
    std::string getName();
    types getType();

};