#include "PropRule.h"
#include <iostream>

PropRule::PropRule(std::string n, types t) {
    name = n;
    type = t;
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