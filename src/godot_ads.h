#pragma once

#include <godot_cpp/classes/object.hpp>

namespace godot {
    class GodotADS : public Object {
        GDCLASS(GodotADS, Object);
    
        int port;
    
    protected:
        static void _bind_methods();
    
    public:
        int try_connect();

        GodotADS();
    };
};
