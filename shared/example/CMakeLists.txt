cmake_minimum_required(VERSION 3.2)

project(Example)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE CACHE BOOL "")

find_package(ParaView REQUIRED)
include(${ParaView_USE_FILE})

add_paraview_plugin(ExamplePlugin 1.0
    SERVER_MANAGER_XML ExamplePlugin.xml
    SERVER_MANAGER_SOURCES "ExamplePlugin.cpp")
