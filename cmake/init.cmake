message(STATUS "Including init.cmake")

# include *.cmake files
include(FetchContent)
include("${CMAKE_CURRENT_LIST_DIR}/build.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/download.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/package.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/qt.cmake")

# LinKIn_InitVcpkg: initialize vcpkg
# [one value keywords]
# ROOT: vckpg root path
# TRIPLET: vcpkg target triplet, x64-windows is the default
function(LinKIn_InitVcpkg)
  cmake_parse_arguments(ARG "" "ROOT;TRIPLET" "" ${ARGN})

  if(NOT CMAKE_TOOLCHAIN_FILE)
    if(ARG_ROOT)
      set(CMAKE_TOOLCHAIN_FILE "${ARG_ROOT}/scripts/buildsystems/vcpkg.cmake" 
        CACHE FILEPATH "CMake toolchain file"
      )
    elseif(ENV{VCPKG_ROOT})
      set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" 
        CACHE FILEPATH "CMake toolchain file"
      )
    else()
      message(FATAL_ERROR "Neither ROOT argument nor VCPKG_ROOT enviroment variable specifies.")
    endif()
  endif()
  if(NOT VCPKG_TARGET_TRIPLET)
    if(ARG_TRIPLET)
      set(VCPKG_TARGET_TRIPLET ${ARG_TRIPLET} CACHE STRING "vcpkg target triplet")
    elseif(ENV{VCPKG_DEFAULT_TRIPLET})
      set(VCPKG_TARGET_TRIPLET $ENV{VCPKG_DEFAULT_TRIPLET} CACHE STRING "vcpkg target triplet")
    else()
      set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "vcpkg target triplet")
    endif()
  endif()
endfunction()

# LinKIn_InitProject: initialize project
# [one value keywords]
# BUILD_TYPE: Debug / Release(default) / MinSizeRel / RelWithDebInfo
# CXX_STANDARD: 98 / 11 / 14 / 17(default) / 20 / 23
macro(LinKIn_InitProject)
  cmake_parse_arguments(ARG "" "BUILD_TYPE;CXX_STANDARD" "" ${ARGN})

  # verify the C/C++ compiler type and version
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # use Clang
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10")
      message(FATAL_ERROR "Clang (< 10) is not supported")
    endif()
  elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # use GCC(GNU Compiler Collection)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10")
      message(FATAL_ERROR "GCC (< 10) is not supported")
    endif()
  elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    # use MSVC(Microsoft Visual C++)
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "19.26")
      message(FATAL_ERROR "MSVC (< 19.26) is not supported")
    endif()
  else()
    message(FATAL_ERROR "Unknown C/CXX compiler: ${CMAKE_CXX_COMPILER_ID}")
  endif()
  message(STATUS "The C/CXX compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
  
  # set build type, release is the default
  # CMAKE_BUILD_TYPE specifies build type on single-configuration generators
  # CMAKE_CONFIGURATION_TYPES specifies available build types on multi-configuration generators
  if(NOT CMAKE_BUILD_TYPE)
    if(NOT ARG_BUILD_TYPE MATCHES "^(Debug|Release|MinSizeRel|RelWithDebInfo)$")
      set(ARG_BUILD_TYPE "Release")
    endif()
    set(CMAKE_BUILD_TYPE ${ARG_BUILD_TYPE} 
      CACHE STRING "build type, only supports Debug, Release(default), MinSizeRel, and RelWithDebInfo."
    )
  endif()

  # set global C++ standard
  set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
  if(NOT CMAKE_CXX_STANDARD)
    if(NOT ARG_CXX_STANDARD MATCHES "^(98|11|14|17|20|23)$")
      # default global C++ standard 17
      set(ARG_CXX_STANDARD "17")
    endif()
    set(CMAKE_CXX_STANDARD ${ARG_CXX_STANDARD} 
      CACHE STRING "global C++ standard, only supports 98, 11, 14, 71(default), and 20."
    )
  endif()

  # set BUILD_${PROJECT_NAME}_TEST cache
  set(BUILD_${PROJECT_NAME}_TEST FALSE CACHE BOOL "build test for ${PROJECT_NAME}.")

  # set install prefix
  if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "install prefix" FORCE)
  endif()

  # set output directory
  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
  set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

  # set USE_FOLDERS property
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)

  # set flag if vcpkg target triplet is x64-windows-static
  if(VCPKG_TARGET_TRIPLET STREQUAL "x64-windows-static")
    set(flags "/MTd;/MT;/MT;/MT")
    foreach(config_type flag IN ZIP_LISTS CMAKE_CONFIGURATION_TYPES flags)
      string(TOUPPER ${config_type} config_type_upper)
      string(REPLACE "/MD" "/MT" CMAKE_CXX_FLAGS_${config_type_upper} ${CMAKE_CXX_FLAGS_${config_type_upper}})
      string(REPLACE "/MD" "/MT" CMAKE_C_FLAGS_${config_type_upper} ${CMAKE_C_FLAGS_${config_type_upper}})
    endforeach()
  endif()

  # set LCMake configuration type definition
  add_compile_definitions(LCMAKE_CONFIG_$<UPPER_CASE:$<CONFIG>>)

  # set LCMake configuration suffix definition
  set(config_suffixes "d;;msr;rd")
  foreach(config_type config_suffix IN ZIP_LISTS CMAKE_CONFIGURATION_TYPES config_suffixes)
    string(TOUPPER ${config_type} config_type_upper)
    # non-executable target
    set(CMAKE_${config_type_upper}_POSTFIX "${config_suffix}")
    add_compile_definitions($<$<CONFIG:${config_type}>:LCMAKE_CONFIG_POSTFIX="${config_suffix}">)
  endforeach()

  # set variables for other *.cmake files
  set(install_name ${PROJECT_NAME}-${PROJECT_VERSION})
endmacro()

message(STATUS "Including init.cmake - done")