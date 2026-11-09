cmake_minimum_required(VERSION 3.15)
project(yoga)

set(YOGA_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/yoga")
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS
    "${YOGA_ROOT}/yoga/*.cpp")

set(OUT_DIR "${CMAKE_BINARY_DIR}/out")

# shared library, used by JIT apps via runtimes/<rid>/native
add_library(yoga SHARED ${SOURCES})

target_include_directories(yoga PRIVATE "${YOGA_ROOT}")

set_target_properties(yoga PROPERTIES
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    WINDOWS_EXPORT_ALL_SYMBOLS OFF
    RUNTIME_OUTPUT_DIRECTORY         "${OUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUT_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${OUT_DIR}"
    LIBRARY_OUTPUT_DIRECTORY         "${OUT_DIR}"
    LIBRARY_OUTPUT_DIRECTORY_RELEASE "${OUT_DIR}"
    LIBRARY_OUTPUT_DIRECTORY_DEBUG   "${OUT_DIR}"
)

# static library, linked into Native AOT apps via DirectPInvoke
# (separate target, not an OBJECT lib: on MSVC YG_EXPORT depends on _WINDLL,
# which is only defined for the DLL project)
add_library(yoga_static STATIC ${SOURCES})

target_include_directories(yoga_static PRIVATE "${YOGA_ROOT}")

set_target_properties(yoga_static PROPERTIES
    OUTPUT_NAME yoga_static
    POSITION_INDEPENDENT_CODE ON
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN ON
    ARCHIVE_OUTPUT_DIRECTORY         "${OUT_DIR}"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${OUT_DIR}"
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG   "${OUT_DIR}"
)

if(MSVC)
    target_compile_options(yoga PRIVATE /wd4251)
    target_compile_options(yoga_static PRIVATE /wd4251)
    # Native AOT uses the static VC runtime + dynamic UCRT ("hybrid CRT") -> /MT
    set_target_properties(yoga_static PROPERTIES
        MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
elseif(APPLE)
    target_link_options(yoga PRIVATE -install_name @rpath/libyoga.dylib)
elseif(UNIX)
    # linux - nothing extra usually needed
endif()
