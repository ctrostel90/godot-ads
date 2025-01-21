#include "godot_ads.h"

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/tree.hpp>
#include <godot_cpp/classes/tree_item.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;


void GodotADS::_bind_methods(){
    
    ClassDB::bind_method(D_METHOD("try_connect"),&GodotADS::try_connect);
    ClassDB::bind_method(D_METHOD("read_var"),&GodotADS::read_var);
    ClassDB::bind_method(D_METHOD("get_var_list","tree"),&GodotADS::get_var_list);

    ClassDB::bind_method(D_METHOD("start_pos_read"),&GodotADS::start_pos_read);
    ClassDB::bind_method(D_METHOD("end_pos_read"),&GodotADS::end_pos_read);

    ClassDB::bind_method(D_METHOD("cell_select"),&GodotADS::cell_select);

    ClassDB::bind_method(D_METHOD("get_q1"),&GodotADS::get_q1);
    ClassDB::bind_method(D_METHOD("get_q2"),&GodotADS::get_q2);
    ClassDB::bind_method(D_METHOD("get_q3"),&GodotADS::get_q3);
    ClassDB::bind_method(D_METHOD("get_q4"),&GodotADS::get_q4);

}

void GodotADS::_ready() {
    long status;
    adsPort = AdsPortOpen();
    //UtilityFunctions::print("Ads Port opened:" + adsPort);
    status = AdsGetLocalAddress(pAddr);
    pAddr->port = 851;

    if (status == 0) {
        connected = true;
        UtilityFunctions::print("ADS setup succesfully");
    }
    else{
        UtilityFunctions::print_rich(vformat("[b][color=RED]Error opening ADS: [/b]{} %x [color=#ffffff]",status));
    }
    position_reading_active = false;
}

int GodotADS::try_connect(){
    int nTemp;
    AdsVersion* pDLLVersion;
    
    nTemp = AdsGetDllVersion();
    pDLLVersion = (AdsVersion*)&nTemp;
    return nTemp;
}

void GodotADS::start_pos_read(){
    long status[3];
    status[0] = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(axisAddresses[0]), &axisAddresses[0], sizeof(axisVarNames[0]), axisVarNames[0]);
    status[1] = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(axisAddresses[1]), &axisAddresses[1], sizeof(axisVarNames[1]), axisVarNames[1]);
    status[2] = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(axisAddresses[2]), &axisAddresses[2], sizeof(axisVarNames[2]), axisVarNames[2]);
    UtilityFunctions::print(vformat("%d,%d,%d",status[0],status[1],status[2]));
    position_reading_active = true;
    UtilityFunctions::print("Starting to read variables");
}
void GodotADS::end_pos_read(){
    AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(axisAddresses[0]), &axisAddresses[0]); 
    AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(axisAddresses[0]), &axisAddresses[1]); 
    AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(axisAddresses[0]), &axisAddresses[2]); 
    position_reading_active = false;
    UtilityFunctions::print("Ending Variable Read");
}

void GodotADS::_process(double delta){
    if (position_reading_active){
            if(update_time <= 0){
                long status[3];
                status[0] = AdsSyncReadReq( pAddr, ADSIGRP_SYM_VALBYHND, axisAddresses[0], sizeof(axisData[0]), &axisData[0] ); 
                status[1] = AdsSyncReadReq( pAddr, ADSIGRP_SYM_VALBYHND, axisAddresses[1], sizeof(axisData[1]), &axisData[1] ); 
                status[2] = AdsSyncReadReq( pAddr, ADSIGRP_SYM_VALBYHND, axisAddresses[2], sizeof(axisData[2]), &axisData[2] ); 
                
                Vector3 new_pos = Vector3(
                    axisData[0] / 1000.0,
                    axisData[1] / 1000.0,
                    axisData[2] / 1000.0
                );
                //set_position(new_pos);

                update_time = 0.05;
            }
            else{
                update_time -= delta;
            }
    }
}

double GodotADS::get_q1(){
    return axisData[0];
}
double GodotADS::get_q2(){
    return axisData[1];
}
double GodotADS::get_q3(){
    return axisData[2];
}
double GodotADS::get_q4(){
    return axisData[3];
}

double GodotADS::read_var(){
    long status, adsPort;
    AmsAddr Addr; 
    PAmsAddr pAddr = &Addr;
    
    unsigned long lHdlVar; 
    double nData = 0;
    char szVar [] = {"MAIN.TcpPos[0]"}; 
    
    adsPort = AdsPortOpen();
    UtilityFunctions::print("Ads Port:" + adsPort);
    status = AdsGetLocalAddress(pAddr);
    UtilityFunctions::print("Local Address:" + status);

    pAddr->port = 851;
    
    status = AdsSyncReadWriteReq(pAddr, ADSIGRP_SYM_HNDBYNAME, 0x0, sizeof(lHdlVar), &lHdlVar, sizeof(szVar), szVar);
    UtilityFunctions::print("Read Sync:" + status);
    status = AdsSyncReadReq( pAddr, ADSIGRP_SYM_VALBYHND, lHdlVar, sizeof(nData), &nData ); 
    status = AdsSyncWriteReq(pAddr, ADSIGRP_SYM_RELEASEHND, 0, sizeof(lHdlVar), &lHdlVar); 
    AdsPortClose();
    return (double)nData;
}

void GodotADS::get_var_list(Tree *tree){
    long         nErr, nPort; 
    char         *pchSymbols = NULL; 
    unsigned int   uiIndex; 
    AmsAddr     Addr; 
    PAmsAddr     pAddr = &Addr; 
    AdsSymbolUploadInfo tAdsSymbolUploadInfo; 
    PAdsSymbolEntry pAdsSymbolEntry; 

    Dictionary variables;

    variables["test"] = {}; 

    // Open communication port on the ADS router
    nPort = AdsPortOpen();
    nErr = AdsGetLocalAddress(pAddr);
    
    // Select Port: TwinCAT 3 PLC1 = 851
    pAddr->port = 851;

    // Read the length of the variable declaration
    nErr = AdsSyncReadReq(pAddr, ADSIGRP_SYM_UPLOADINFO, 0x0, sizeof(tAdsSymbolUploadInfo), &tAdsSymbolUploadInfo);
    pchSymbols = new char[tAdsSymbolUploadInfo.nSymSize]; 

    // Read information about the PLC variables 
    nErr = AdsSyncReadReq(pAddr, ADSIGRP_SYM_UPLOAD, 0, tAdsSymbolUploadInfo.nSymSize, pchSymbols); 
    
    // Output information about the PLC variables 
    pAdsSymbolEntry = (PAdsSymbolEntry)pchSymbols; 

    std::string::size_type start = 0;
    std::string::size_type end = 0;
    godot::String full_variable_name = "MAIN.fbMachineKinematic.KinematicAxis.AcsAxis[1].NcToPlc";
    Dictionary varList;
    for (uiIndex = 0; uiIndex < tAdsSymbolUploadInfo.nSymbols; uiIndex++){ 
        build_nested_dict(varList,PADSSYMBOLNAME(pAdsSymbolEntry), pAdsSymbolEntry);
        //UtilityFunctions::print(varList);
        //UtilityFunctions::print(vformat("%s:%s",PADSSYMBOLNAME(pAdsSymbolEntry),PADSSYMBOLTYPE(pAdsSymbolEntry)));
        pAdsSymbolEntry = PADSNEXTSYMBOLENTRY(pAdsSymbolEntry); 
    }
    
    TreeItem *root = tree->create_item();
    populate_tree(tree,root,varList);
    tree->connect("cell_selected",Callable(this,"cell_select").bind(tree));
    AdsPortClose();
}

void GodotADS::populate_tree(Tree *tree, TreeItem *parent_item, const Dictionary &dict) {
    Array keys = dict.keys(); // Retrieve all keys as an Array
    for (int i = 0; i < keys.size(); ++i) {
        Variant key = keys[i];
        // Create a new TreeItem for each key
        TreeItem *new_item = tree->create_item(parent_item);
        new_item->set_collapsed(true);
        new_item->set_text(0, key.operator String());

        Variant val = dict[key];
        // Check if the value is a nested Dictionary
        if (val.get_type() == Variant::DICTIONARY) {
            populate_tree(tree, new_item, dict[key]); // Recursive call for nested Dictionary
        }
        else{
            Array value = dict[key];
            new_item->set_text(1, value[0]);
            //new_item->set_text(1, value[1]);
            new_item->set_metadata(0,value[1]);
            new_item->set_metadata(1,value[2]);
        }
    }
}
void GodotADS::cell_select(Tree *tree){
    unsigned int group = tree->get_selected()->get_metadata(0);
    unsigned int offset = tree->get_selected()->get_metadata(1);
    double val = 0.0;
    long status;
    status = AdsSyncReadReq( pAddr, group, offset, sizeof(val), &val ); 
    UtilityFunctions::print(vformat("%d : %f",val, val));
}
void GodotADS::build_nested_dict(godot::Dictionary list,godot::String variable_name, PAdsSymbolEntry symbol){
    godot::PackedStringArray split_name = variable_name.split(".");
    UtilityFunctions::print(split_name.size());
    Dictionary current_dict = list;
    for (int i = 0; i < split_name.size(); i++){
        if(!current_dict.has(split_name[i])){
            //Key hasn't been found, go ahead and add it
            if(i == split_name.size() - 1){
                Array symbol_data;
                symbol_data.append(PADSSYMBOLTYPE(symbol));
                symbol_data.append((unsigned int)(symbol->iGroup));
                symbol_data.append((unsigned int)(symbol->iOffs));
                current_dict[split_name[i]] = symbol_data;
            }
            else{
                current_dict[split_name[i]] = Dictionary();
                current_dict = current_dict[split_name[i]];
            }
        }
        else{
            current_dict = current_dict[split_name[i]];
        }
    }
}
GodotADS::GodotADS(){

}

