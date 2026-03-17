cmake_minimum_required(VERSION 3.10)
project(yoga)

set(YOGA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/yoga")
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
    "${YOGA_ROOT}/yoga/*.cpp")

add_library(yoga SHARED ${SOURCES})

target_include_directories(yoga PRIVATE "${YOGA_ROOT}")

set_target_properties(yoga PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    WINDOWS_EXPORT_ALL_SYMBOLS OFF
    RUNTIME_OUTPUT_DIRECTORY         "${CMAKE_BINARY_DIR}/out"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/out"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_BINARY_DIR}/out"
    LIBRARY_OUTPUT_DIRECTORY         "${CMAKE_BINARY_DIR}/out"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/out"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG   "${CMAKE_BINARY_DIR}/out"

#    OUTPUT_NAME yoga
#    PREFIX ""
)

if(MSVC)
    target_compile_options(yoga PRIVATE /wd4251)
elseif(APPLE)
    target_link_options(yoga PRIVATE -install_name @rpath/libvoga.dylib)
elseif(UNIX)
    # linux - nothing extra usually needed
endif()
