#ifndef GODOT_ADS_H
#define GODOT_ADS_H

#include <stddef.h>
#include <../include/TcAdsDll/TcAdsAPI.h>
#include <../include/TcAdsDll/TcAdsDef.h>

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/tree.hpp>
#include <godot_cpp/classes/tree_item.hpp>

namespace godot {
    class GodotADS : public Node3D {
        GDCLASS(GodotADS, Node3D);
    
        int port;
        long adsPort;
        AmsAddr Addr;
        bool connected;
        PAmsAddr pAddr = &Addr;
        
        bool position_reading_active;
        char axisVarNames[4][150] = {
            {"MAIN.fbMachineKinematic.ScaraKinematic.KinematicComponent_HMI.Status.ActPosition.ACS[1]"},
            {"MAIN.fbMachineKinematic.ScaraKinematic.KinematicComponent_HMI.Status.ActPosition.ACS[2]"},
            {"MAIN.fbMachineKinematic.ScaraKinematic.KinematicComponent_HMI.Status.ActPosition.ACS[3]"},
            {"MAIN.fbMachineKinematic.ScaraKinematic.KinematicComponent_HMI.Status.ActPosition.ACS[4]"}};
        long axisAddresses[3];
        double axisData[3];

        double update_time = 0.2;

    protected:
        static void _bind_methods();
    
    public:
        int try_connect();
        double read_var();
        void get_var_list(Tree *tree);
        
        void start_pos_read();
        void end_pos_read();

        void _ready() override;
        void _process(double) override;
        
        void build_nested_dict(godot::Dictionary list,godot::String variable_name, PAdsSymbolEntry);
        void populate_tree(Tree *tree, TreeItem *parent_item, const Dictionary &dict);
        void cell_select(Tree *tree);

        double get_q1();
        double get_q2();
        double get_q3();
        double get_q4();
        GodotADS();
    };
};
#endif