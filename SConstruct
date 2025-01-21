#!/usr/bin/env python
import os
import sys

env = SConscript("godot-cpp/SConstruct")

# For reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=["src/","include/TcAdsDll"])
#env.Append(LIBS=["TcAdsDll.lib"])
env.Append(LIBPATH=["lib/"])
env.Append(LINKFLAGS=["TcAdsDll" + Environment()['LIBSUFFIX']])
#env.Append(LIBS=[File('lib/TcAdsDll.lib')])


sources = Glob("src/*.cpp")

if env["platform"] == "macos":
    library = env.SharedLibrary(
        "demo/bin/libgdexample.{}.{}.framework/libgdexample.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
elif env["platform"] == "ios":
    if env["ios_simulator"]:
        library = env.StaticLibrary(
            "demo/bin/libgdexample.{}.{}.simulator.a".format(env["platform"], env["target"]),
            source=sources,
        )
    else:
        library = env.StaticLibrary(
            "demo/bin/godot-ads.{}.{}.a".format(env["platform"], env["target"]),
            source=sources,
        )
else:
    # dlls = [
    #     "lib/TcAdsDll.lib"
    # ]
    # for dll in dlls:
    #     env.Command(
    #         target=os.path.join("demo/bin/", os.path.basename(dll)),
    #         source=dll,
    #         action=Copy("$TARGET", "$SOURCE")
    #     )
    library = env.SharedLibrary(
        "demo/bin/godot-ads{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

Default(library)
