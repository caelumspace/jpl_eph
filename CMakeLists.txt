cmake_minimum_required(VERSION 3.10)

# Project name and the language used
project(JplEph VERSION 1.0 LANGUAGES CXX)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)


set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../jpl_eph" CACHE PATH "Default install prefix" FORCE)


# Options for building as a DLL and targeting 32-bit architecture
option(BUILD_AS_DLL "Build the library as a DLL." OFF)
option(TARGET_32_BIT "Target 32-bit architecture." OFF)

# Define output directories based on architecture and build type
if(CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
    set(ARCH_DIR "x64")
else() # 32-bit
    set(ARCH_DIR "x86")
endif()

# Use generator expressions to handle different configurations (Debug, Release, etc.)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ARCH_DIR}/$<CONFIG>/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ARCH_DIR}/$<CONFIG>/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${ARCH_DIR}/$<CONFIG>/bin)


# Compiler flags common to all builds
set(COMMON_FLAGS "-O2 -MT -D_CRT_SECURE_NO_WARNINGS")
if(BUILD_AS_DLL)
    set(COMMON_FLAGS "${COMMON_FLAGS} -EHsc -LD -DNDEBUG")
endif()



# Include directories
include_directories(${PROJECT_SOURCE_DIR}/src ${PROJECT_SOURCE_DIR}/../lunar/src)

# Source files
#file(GLOB LIB_SOURCES "${PROJECT_SOURCE_DIR}/src/*.cpp")

set(LIB_SOURCES
    src/jpleph.cpp
    # Add more source files as needed
)



# Determine the target platform and library names
if(WIN32)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
        set(TARGET_LIB_NAME "jpleph64")
        set(LUNARLIB_NAME "lunar64.lib")
    else() # 32-bit
        set(TARGET_LIB_NAME "jpleph32")
        set(LUNARLIB_NAME "lunar32.lib")
    endif()
    add_definitions(-DJPL_EPH_DLL=1)
else()
    set(TARGET_LIB_NAME "jpleph")
endif()

# Add library target
# add_library(${TARGET_LIB_NAME} SHARED ${SOURCES})
if(BUILD_AS_DLL)
    add_library(${TARGET_LIB_NAME} SHARED ${LIB_SOURCES})
    target_compile_definitions(${TARGET_LIB_NAME} PRIVATE JPLEPHLIB_EXPORTS)
else()
    add_library(${TARGET_LIB_NAME} STATIC ${LIB_SOURCES})
endif()

# Compiler options and definitions for MSVC
if(MSVC)
    target_compile_options(${TARGET_LIB_NAME} PRIVATE /W3 /EHsc /D_CRT_SECURE_NO_WARNINGS /std:c++latest)
    # Separate debug/release options
    target_compile_options(${TARGET_LIB_NAME} PRIVATE "$<$<CONFIG:RELEASE>:/O2>")
else()
    target_compile_options(${TARGET_LIB_NAME} PRIVATE -Wall -Wextra -pedantic)
    # Separate debug/release options
    target_compile_options(${TARGET_LIB_NAME} PRIVATE "$<$<CONFIG:RELEASE>:-O2>")
endif()

# Link with the lunar library if needed
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_SYSTEM_PROCESSOR}/${CMAKE_BUILD_TYPE}/bin)

# Determine the directory name for the architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8) # 64-bit
    set(ARCH_DIR "x64")
else() # 32-bit
    set(ARCH_DIR "x86")
endif()

# Determine the path to the lunar library, incorporating the build type
# Note: This assumes you're calling cmake with `-DCMAKE_BUILD_TYPE=Release` or similar
set(LUNAR_LIB_PATH "${PROJECT_SOURCE_DIR}/../lunar/build/${ARCH_DIR}/${CMAKE_BUILD_TYPE}/lib")

find_library(LUNAR_LIB NAMES ${LUNARLIB_NAME}
             PATHS ${LUNAR_LIB_PATH}
             NO_DEFAULT_PATH)

if(NOT LUNAR_LIB)
    message(FATAL_ERROR "${LUNARLIB_NAME} not found in ${LUNAR_LIB_PATH}. Please check the library path.")
else()
    message(STATUS "Found Lunar Library: ${LUNAR_LIB}")
endif()

target_link_libraries(${TARGET_LIB_NAME} PRIVATE ${LUNAR_LIB})



# Installation rules
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_SOURCE_DIR}/../jpl_eph")

# Specify the installation rules for the target
install(TARGETS ${TARGET_LIB_NAME}
        ARCHIVE DESTINATION build/${ARCH_DIR}/Release/lib
        LIBRARY DESTINATION build/${ARCH_DIR}/Release/lib
        RUNTIME DESTINATION build/${ARCH_DIR}/Release/bin)

# Install headers
install(DIRECTORY ${PROJECT_SOURCE_DIR}/src/ DESTINATION include)


# Compiler and linker options for MSVC and GCC/Clang
if(MSVC)
    target_compile_options(${TARGET_LIB_NAME} PRIVATE /W3)
else()
    target_compile_options(${TARGET_LIB_NAME} PRIVATE -Wall)
endif()
