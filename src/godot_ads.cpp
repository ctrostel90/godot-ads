#include "godot_ads.h"

#include <stddef.h>
#include <../include/TcAdsDll/TcAdsAPI.h>
#include <../include/TcAdsDll/TcAdsDef.h>

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GodotADS::_bind_methods(){
    ClassDB::bind_method(D_METHOD("try_connect"),&GodotADS::try_connect);
}

int GodotADS::try_connect(){
    int nErr, nPort;
    AmsAddr Addr;
    PAmsAddr pAddr = &Addr;
    int32_t dwData;
    // Open communication port on the ADS router
    nPort = AdsPortOpen();
    nErr = AdsGetLocalAddress(pAddr);
    return nErr;
}

GodotADS::GodotADS(){

}

