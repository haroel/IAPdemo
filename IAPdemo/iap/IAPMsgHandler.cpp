//
//  IAPMsgHandler.cpp
//  IAPdemo
//
//  Created by Howe on 09/09/2017.
//  Copyright © 2017 Howe. All rights reserved.
//

#include "IAPMsgHandler.h"

static IAPMsgHandler * _instance = nullptr;

IAPMsgHandler::IAPMsgHandler(){
    this->_callBack = nullptr;
}
IAPMsgHandler::~IAPMsgHandler(){
    this->_callBack = nullptr;
}

IAPMsgHandler * IAPMsgHandler::getInstance(){
    if (_instance == nullptr){
        _instance = new IAPMsgHandler();
    }
    return _instance;
}

void IAPMsgHandler::registerCallback( const IAPCallback &callback){
    this->_callBack =callback;
}

void IAPMsgHandler::handlerData(int code, const char* msg){
    if (this->_callBack){
        this->_callBack(code,msg);
    }
}
