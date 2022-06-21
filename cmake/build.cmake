message(STATUS "Including build.cmake")

set(scopes "PUBLIC;INTERFACE;PRIVATE")
set(lib_types "debug;optimized;general")

# LinKIn_AddSubdirectories: add subdirectories recursively with CMakeLists.txt
# dir: relative directory to ${CMAKE_CURRENT_SOURCE_DIR}
function(LinKIn_AddSubdirectories rel_dir)
  file(GLOB_RECURSE subpaths LIST_DIRECTORIES true "${CMAKE_CURRENT_SOURCE_DIR}/${rel_dir}/*")
  list(APPEND subpaths "${CMAKE_CURRENT_SOURCE_DIR}/${rel_dir}")
  foreach(subpath ${subpaths})
    if(IS_DIRECTORY "${subpath}" AND EXISTS "${subpath}/CMakeLists.txt")
      cmake_path(RELATIVE_PATH subpath BASE_DIRECTORY ${CMAKE_SOURCE_DIR}/src OUTPUT_VARIABLE target_name)
      string(REPLACE "/" "_" target_name ${target_name})
      set(target_name "${PROJECT_NAME}_${target_name}")
      if(NOT TARGET ${target_name})
        add_subdirectory("${subpath}")
      endif()
    endif()
  endforeach()
endfunction()

# LinKIn_GourpSources: gourp sources
# abs_files_var: variable of absolute files
function(LinKIn_GourpSources abs_files_var)
  foreach(abs_file ${${abs_files_var}})
    cmake_path(GET abs_file PARENT_PATH abs_dir)
    if(abs_dir MATCHES "^${CMAKE_CURRENT_SOURCE_DIR}.*$")
      # if ${abs_file} is under build tree, put it to the relative path
      cmake_path(RELATIVE_PATH abs_dir OUTPUT_VARIABLE rel_dir)
      if(rel_dir STREQUAL ".")
        set(rel_dir "")
      endif()
      source_group("${rel_dir}" FILES "${abs_file}")
    else()
      # if ${abs_file} is out of build tree, put it to the external folder
      source_group("external" FILES "${abs_file}")
    endif()
  endforeach()
endfunction()

# LinKIn_AddSources: add sources
# target_name: target name
# paths_var: variable of absolute or relative files and directories to ${CMAKE_CURRENT_SOURCE_DIR}
# scope: PUBLIC / INTERFACE / PRIVATE
function(LinKIn_AddSources target_name paths_var scope)
  list(FIND scopes ${scope} scope_idx)
  if(scope_idx STREQUAL "-1")
    message(FATAL_ERROR "Scope ${scope} is not supported")
  endif()
  foreach(path ${${paths_var}})
    # if not absolute, make it absolute
    cmake_path(ABSOLUTE_PATH path NORMALIZE OUTPUT_VARIABLE abs_path)
    if(EXISTS "${abs_path}")
      if(IS_DIRECTORY "${abs_path}")
        # if being directory, add files with certain suffixes
        file(GLOB_RECURSE abs_target_files
          # header files
          "${abs_path}/*.h"
          "${abs_path}/*.hpp"
          "${abs_path}/*.inl"
          # source files
          "${abs_path}/*.c"
          "${abs_path}/*.cpp"
          # qt files
          "${abs_path}/*.qrc"
          "${abs_path}/*.ui"
        )
      else()
        # if not being directory, just add the given files without verifying suffix
        set(abs_target_files "${abs_path}")
      endif()
      LinKIn_GourpSources(abs_target_files)
      target_sources(${target_name} ${scope} ${abs_target_files})
      list(APPEND target_srcs ${abs_target_files})
    endif()
  endforeach()
  set(${paths_var} ${target_srcs} PARENT_SCOPE)
endfunction()

# LinKIn_IncludeDirectories: include directories
# target_name: target name
# dirs_var: variable of absolute or relative directories to **********${CMAKE_SOURCE_DIR}**********
# scope: PUBLIC / INTERFACE / PRIVATE
function(LinKIn_IncludeDirectories target_name dirs_var scope)
  list(FIND scopes ${scope} scope_idx)
  if(scope_idx STREQUAL "-1")
    message(FATAL_ERROR "Scope ${scope} is not supported")
  endif()
  foreach(dir ${${dirs_var}})
    # if not absolute, make it absolute
    # notice that the base directory is ${CMAKE_SOURCE_DIR}
    cmake_path(ABSOLUTE_PATH dir NORMALIZE BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE abs_dir)
    if(EXISTS "${abs_dir}" AND IS_DIRECTORY "${abs_dir}")
      target_include_directories(${target_name} ${scope} $<BUILD_INTERFACE:${abs_dir}>)
      list(APPEND target_inlcude_dirs "${abs_dir}")
    endif()
  endforeach()
  set(${dirs_var} ${target_inlcude_dirs} PARENT_SCOPE)
endfunction()

# LinKIn_ClassifyLibraries: classify libraries
# libs_var: variable of library targets and absolute or relative file path
# scope: PUBLIC / INTERFACE / PRIVATE
function(LinKIn_ClassifyLibraries libs_var scope)
  list(FIND scopes ${scope} scope_idx)
  if(scope_idx STREQUAL "-1")
    message(FATAL_ERROR "scope ${scope} is not supported")
  endif()
  foreach(ele ${${libs_var}})
    # check ${ele} in lib_types
    list(FIND lib_types ${ele} ele_idx)
    if(NOT ele_idx STREQUAL "-1")
      set(use_type TRUE)
      string(TOUPPER ${ele} upper_type)
    else()
      if(use_type)
        list(APPEND ARG_LIBRARY_${scope}_${upper_type} ${ele})
      else()
        list(APPEND ARG_LIBRARY_${scope}_GENERAL ${ele})
      endif()
      set(use_type FALSE)
    endif()
  endforeach()
  set(${libs_var} "" PARENT_SCOPE)
  set(ARG_LIBRARY_${scope}_DEBUG ${ARG_LIBRARY_${scope}_DEBUG} PARENT_SCOPE)
  set(ARG_LIBRARY_${scope}_OPTIMIZED ${ARG_LIBRARY_${scope}_OPTIMIZED} PARENT_SCOPE)
  set(ARG_LIBRARY_${scope}_GENERAL ${ARG_LIBRARY_${scope}_GENERAL} PARENT_SCOPE)
endfunction()

# LinKIn_LinkLibraries: link libraries
# target_name: target name
# libs_var: variable of library targets and absolute or relative file path to ${CMAKE_CURRENT_SOURCE_DIR}
# scope: PUBLIC / INTERFACE / PRIVATE
# lib_type: debug / optimized / general
function(LinKIn_LinkLibraries target_name libs_var scope lib_type)
  list(FIND scopes ${scope} scope_idx)
  if(scope_idx STREQUAL "-1")
    message(FATAL_ERROR "scope ${scope} is not supported")
  endif()
  list(FIND lib_types ${lib_type} lib_type_idx)
  if(lib_type_idx STREQUAL "-1")
    message(FATAL_ERROR "Library type ${lib_type} is not supported")
  endif()
  foreach(lib ${${libs_var}})
    if(TARGET ${lib})
      # link ${lib} as a target
      target_link_libraries(${target_name} ${scope} ${lib_type} ${lib})
      list(APPEND target_libraries ${lib})
    else()
      # if not absolute, make it absolute
      cmake_path(ABSOLUTE_PATH lib NORMALIZE OUTPUT_VARIABLE abs_lib)
      if(EXISTS "${abs_lib}" AND NOT IS_DIRECTORY "${abs_lib}")
        # link ${lib} as a file
        target_link_libraries(${target_name} ${scope} ${lib_type} "${abs_lib}")
        list(APPEND target_libraries "${abs_lib}")
      endif()
    endif()
  endforeach()
  set(${libs_var} ${target_libraries} PARENT_SCOPE)
endfunction()

# LinKIn_Print: print infomation
# [one value keywords]
# TITLE: title
# PREFIX: prefix before each string in ${ARG_STRS}
# [multiple value keywords]
# STRS: infomation list
function(LinKIn_Print)
  cmake_parse_arguments(ARG "" "TITLE;PREFIX" "STRS" ${ARGN})

  list(LENGTH ARG_STRS strs_count)
  if(NOT strs_count)
    return()
  endif()
  if(NOT ARG_TITLE STREQUAL "")
    message(STATUS ${ARG_TITLE})
  endif()
  foreach(str ${ARG_STRS})
    message(STATUS ${ARG_PREFIX}${str})
  endforeach()
endfunction()

# LinKIn_AddTarget: add target
# [options]
# TEST: if BUILD_${PROJECT_NAME}_TEST is not checked, the test target will be skipped
# Qt: automatically deal with Qt-related files
# ----------
# [one value keywords]
# MODE: EXE / STATIC / SHARED / INTERFACE
# ADD_CURRENT_TO: PUBLIC / INTERFACE / PRIVATE (default) / NONE
# CXX_STANDARD: 98 / 11 / 14 / 17 / 20 / 23, default global C++ standard in LinKIn_ProjectInit()
# OUTPUT_NAME: use the given output name
# RETURN_TARGET_NAME: return the target name in the parent scope
# ----------
# [multiple value keywords](PUBLIC, INTERFACE, PRIVATE): both absolute and relative path are OK.
# SOURCE: directories(recursive), files             | target_sources
# INCLUDE: directories                              | target_include_directories
# LIBRARY: <lib-target>, *.lib                      | target_link_libraries
# (, DEBUG, OPTIMIZED, GENERAL)
# DEFINE: #define ...                               | target_compile_definitions
# COMPILE_OPTION: compile options                   | target_compile_options
# LINK_OPTION: link options                         | target_link_options
# PRECOMPILE_HEADER: precompile headers             | target_precompile_headers
function(LinKIn_AddTarget)
  # add multiple value keywords
  foreach(scope ${scopes})
    list(APPEND multi_value_keywords 
      SOURCE_${scope}
      INCLUDE_${scope}
      LIBRARY_${scope} LIBRARY_${scope}_DEBUG LIBRARY_${scope}_OPTIMIZED LIBRARY_${scope}_GENERAL
      DEFINE_${scope}
      COMPILE_OPTION_${scope}
      LINK_OPTION_${scope}
      PRECOMPILE_HEADER_${scope}
    )
  endforeach()
  cmake_parse_arguments(
    ARG
    "TEST;Qt"
    "MODE;ADD_CURRENT_TO;CXX_STANDARD;OUTPUT_NAME;RETURN_TARGET_NAME"
    "${multi_value_keywords}"
    ${ARGN}
  )

  # if BUILD_${PROJECT_NAME}_TEST is not checked, the test target will be skipped
  if(ARG_TEST AND NOT BUILD_${PROJECT_NAME}_TEST)
    return()
  endif()
  message(STATUS "----------")

  # use LinKIn_QtBegin() if Qt is setted
  if(ARG_Qt)
    LinKIn_QtBegin()
  endif()

  # set ARG_ADD_CURRENT_TO default PRIVATE
  if(NOT ARG_ADD_CURRENT_TO MATCHES "^(PUBLIC|INTERFACE|PRIVATE|NONE)$")
    set(ARG_ADD_CURRENT_TO "PRIVATE")
  endif()

  # if mode is INTERFACE, PUBLIC, PRIVATE -> INTERFACE
  if(ARG_MODE} STREQUAL "INTERFACE")
    list(APPEND ARG_SOURCE_INTERFACE ${ARG_SOURCE_PUBLIC} ${ARG_SOURCE_PRIVATE})
    set(ARG_SOURCE_PUBLIC "")
    set(ARG_SOURCE_PRIVATE "")
    list(APPEND ARG_INCLUDE_INTERFACE ${ARG_INCLUDE_PUBLIC} ${ARG_INCLUDE_PRIVATE})
    set(ARG_INCLUDE_PUBLIC "")
    set(ARG_INCLUDE_PRIVATE "")
    list(APPEND ARG_LIBRARY_INTERFACE ${ARG_LIBRARY_PUBLIC} ${ARG_LIBRARY_PRIVATE})
    set(ARG_LIBRARY_PUBLIC "")
    set(ARG_LIBRARY_PRIVATE "")
    list(APPEND ARG_LIBRARY_INTERFACE_DEBUG ${ARG_LIBRARY_PUBLIC}_DEBUG ${ARG_LIBRARY_PRIVATE}_DEBUG)
    set(ARG_LIBRARY_PUBLIC_DEBUG "")
    set(ARG_LIBRARY_PRIVATE_DEBUG "")
    list(APPEND ARG_LIBRARY_INTERFACE_OPTIMIZED ${ARG_LIBRARY_PUBLIC}_OPTIMIZED ${ARG_LIBRARY_PRIVATE}_OPTIMIZED)
    set(ARG_LIBRARY_PUBLIC_OPTIMIZED "")
    set(ARG_LIBRARY_PRIVATE_OPTIMIZED "")
    list(APPEND ARG_LIBRARY_INTERFACE_GENERAL ${ARG_LIBRARY_PUBLIC}_GENERAL ${ARG_LIBRARY_PRIVATE}_GENERAL)
    set(ARG_LIBRARY_PUBLIC_GENERAL "")
    set(ARG_LIBRARY_PRIVATE_GENERAL "")
    list(APPEND ARG_DEFINE_INTERFACE ${ARG_DEFINE_PUBLIC} ${ARG_DEFINE_PRIVATE})
    set(ARG_DEFINE_PUBLIC "")
    set(ARG_DEFINE_PRIVATE "")
    list(APPEND ARG_COMPILE_OPTION_INTERFACE ${ARG_COMPILE_OPTION_PUBLIC} ${ARG_COMPILE_OPTION_PRIVATE})
    set(ARG_COMPILE_OPTION_PUBLIC "")
    set(ARG_COMPILE_OPTION_PRIVATE "")
    list(APPEND ARG_LINK_OPTION_INTERFACE ${ARG_LINK_OPTION_PUBLIC} ${ARG_LINK_OPTION_PRIVATE})
    set(ARG_LINK_OPTION_PUBLIC "")
    set(ARG_LINK_OPTION_PRIVATE "")
    list(APPEND ARG_PRECOMPILE_HEADER_INTERFACE ${ARG_PRECOMPILE_HEADER_PUBLIC} ${ARG_PRECOMPILE_HEADER_PRIVATE})
    set(ARG_PRECOMPILE_HEADER_PUBLIC "")
    set(ARG_PRECOMPILE_HEADER_PRIVATE "")

    if(NOT ARG_ADD_CURRENT_TO STREQUAL "NONE")
      set(ARG_ADD_CURRENT_TO "INTERFACE")
    endif()
  endif()

  # use ARG_ADD_CURRENT_TO if it makes sense
  list(FIND scopes ${ARG_ADD_CURRENT_TO} scope_idx)
  if(NOT scope_idx STREQUAL "-1")
    if(NOT ARG_ADD_CURRENT_TO STREQUAL "NONE")
      list(APPEND ARG_SOURCE_${ARG_ADD_CURRENT_TO} ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
  else()
    message(FATAL_ERROR "ADD_CURRENT_TO ${ARG_ADD_CURRENT_TO} is not supported")
  endif()

  # set target name
  cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY ${CMAKE_SOURCE_DIR}/src OUTPUT_VARIABLE target_name)
  string(REPLACE "/" "_" target_name ${target_name})
  set(target_name "${PROJECT_NAME}_${target_name}")

  # add target
  if(ARG_MODE STREQUAL "EXE")
    add_executable(${target_name})
    add_executable(LinKIn::${target_name} ALIAS ${target_name})
    if(MSVC)
      # set the debugger working directory for the target with MSVC compiler
      set_target_properties(${target_name} PROPERTIES VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
    endif()
    # set postfixs for different configuration types
    foreach(config_type ${CMAKE_CONFIGURATION_TYPES})
      string(TOUPPER ${config_type} config_type_upper)
      set_target_properties(${target_name} PROPERTIES ${config_type_upper}_POSTFIX "${CMAKE_${config_type_upper}_POSTFIX}")
    endforeach()
  elseif(ARG_MODE STREQUAL "STATIC")
    add_library(${target_name} STATIC)
    add_library(LinKIn::${target_name} ALIAS ${target_name})
  elseif(ARG_MODE STREQUAL "SHARED")
    add_library(${target_name} SHARED)
    add_library(LinKIn::${target_name} ALIAS ${target_name})
    # define shared library export macro
    string(REPLACE "-" "_" exports_macro $<UPPER_CASE:${PROJECT_NAME}>)
    target_compile_definitions(${target_name} PRIVATE ${exports_macro}_EXPORTS)
  elseif(ARG_MODE STREQUAL "INTERFACE")
    add_library(${target_name} INTERFACE)
    add_library(LinKIn::${target_name} ALIAS ${target_name})
  else()
    message(FATAL_ERROR "Mode ${ARG_MODE} is not supported")
    return()
  endif()

  # add sources
  foreach(scope ${scopes})
    LinKIn_AddSources(${target_name} ARG_SOURCE_${scope} ${scope})
  endforeach()

  # include directories
  foreach(scope ${scopes})
    LinKIn_IncludeDirectories(${target_name} ARG_INCLUDE_${scope} ${scope})
  endforeach()
  target_include_directories(${target_name} PUBLIC $<INSTALL_INTERFACE:include>)

  # add libraries
  foreach(scope ${scopes})
    LinKIn_ClassifyLibraries(ARG_LIBRARY_${scope} ${scope})
    LinKIn_LinkLibraries(${target_name} ARG_LIBRARY_${scope}_DEBUG ${scope} debug)
    LinKIn_LinkLibraries(${target_name} ARG_LIBRARY_${scope}_OPTIMIZED ${scope} optimized)
    LinKIn_LinkLibraries(${target_name} ARG_LIBRARY_${scope}_GENERAL ${scope} general)
  endforeach()

  # add compile definitons
  target_compile_definitions(${target_name}
    PUBLIC ${ARG_DEFINE_PUBLIC}
    INTERFACE ${ARG_DEFINE_INTERFACE}
    PRIVATE ${ARG_DEFINE_PRIVATE}
  )

  # add compile options
  target_compile_options(${target_name}
    PUBLIC ${ARG_COMPILE_OPTION_PUBLIC}
    INTERFACE ${ARG_COMPILE_OPTION_INTERFACE}
    PRIVATE ${ARG_COMPILE_OPTION_PRIVATE}
  )

  # add link options
  target_link_options(${target_name}
    PUBLIC ${ARG_LINK_OPTION_PUBLIC}
    INTERFACE ${ARG_LINK_OPTION_INTERFACE}
    PRIVATE ${ARG_LINK_OPTION_PRIVATE}
  )

  # add precompile headers
  target_precompile_headers(${target_name}
    PUBLIC ${ARG_PRECOMPILE_HEADER_PUBLIC}
    INTERFACE ${ARG_PRECOMPILE_HEADER_INTERFACE}
    PRIVATE ${ARG_PRECOMPILE_HEADER_PRIVATE}
  )

  # set target folder
  cmake_path(RELATIVE_PATH CMAKE_CURRENT_SOURCE_DIR BASE_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE target_rel_path)
  set(target_folder "${PROJECT_NAME}/${target_rel_path}")
  if(NOT ARG_MODE STREQUAL "INTERFACE")
    set_target_properties(${target_name} PROPERTIES FOLDER "${target_folder}")
  endif()

  # set target C++ standard
  if(ARG_CXX_STANDARD MATCHES "^(98|11|14|17|20|23)$")
    set_property(TARGET ${target_name} PROPERTY CXX_STANDARD ${ARG_CXX_STANDARD})
  endif()
  get_property(target_cxx_standard TARGET ${target_name} PROPERTY CXX_STANDARD)

  # use output name
  if(ARG_OUTPUT_NAME)
    set_target_properties(${target_name} PROPERTIES OUTPUT_NAME ${ARG_OUTPUT_NAME} CLEAN_DIRECT_OUTPUT 1)
  endif()

  # return target name
  if(ARG_RETURN_TARGET_NAME)
    set(${ARG_RETURN_TARGET_NAME} ${target_name} PARENT_SCOPE)
  endif()

  # install files
  if(NOT ARG_TEST)
    install(TARGETS ${target_name} 
      EXPORT ${PROJECT_NAME}Targets
      RUNTIME DESTINATION "${install_name}/bin"
      LIBRARY DESTINATION "${install_name}/lib"
      ARCHIVE DESTINATION "${install_name}/lib"
    )
    if(ARG_MODE STREQUAL "STATIC")
      foreach(config_type config_suffix IN ZIP_LISTS CMAKE_CONFIGURATION_TYPES config_suffixes)
        install(FILES "${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/${config_type}/${target_name}${config_suffix}.pdb"
          CONFIGURATIONS ${config_type} DESTINATION "${install_name}/lib" OPTIONAL
        )
      endforeach()
    elseif(ARG_MODE STREQUAL "SHARED")
      foreach(config_type config_suffix IN ZIP_LISTS CMAKE_CONFIGURATION_TYPES config_suffixes)
        install(FILES "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${config_type}/${target_name}${config_suffix}.pdb"
          CONFIGURATIONS ${config_type} DESTINATION "${install_name}/bin" OPTIONAL
        )
      endforeach()
    endif()
  endif()
  
  # use LinKIn_QtEnd() if Qt is setted
  if(ARG_Qt)
    LinKIn_QtEnd()
  endif()

  # print information
  message(STATUS "- name: ${target_name}")
  message(STATUS "- folder: ${target_folder}")
  message(STATUS "- mode: ${ARG_MODE}")
  message(STATUS "- standard: C++ ${target_cxx_standard}")
  foreach(multi_value_keyword ${multi_value_keywords})
    string(TOLOWER ${multi_value_keyword} title)
    string(REPLACE "_" " " title ${title})
    LinKIn_Print(STRS ${ARG_${multi_value_keyword}}
    TITLE  "- ${title}:"
    PREFIX "  * ")
  endforeach()
  message(STATUS "----------")
endfunction()

message(STATUS "Including build.cmake - done")