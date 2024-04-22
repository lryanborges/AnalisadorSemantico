#include "PropRule.h"
#include <iostream>

PropRule::PropRule(std::string n, types t, int l) {
    name = n;
    type = t;
    line = l;
}

void PropRule::setType(types t){
    type = t;
}

std::string PropRule::getName(){
    return name;
}

types PropRule::getType() {
    return type;
}

string PropRule::getCategory(){
    switch (type)
    {
    case OBJPROP:
        return "Object Propriety";
    case DATAPROP:
        return "Data Propriety";
    default:
        return "";
    }
}

string PropRule::getLine(){
    return std::to_string(line);
}