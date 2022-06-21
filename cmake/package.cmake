message(STATUS "Including package.cmake")

set(LinKIn_PACKAGE_INIT "
cmake_path(SET include_dir NORMALIZE \"\${CMAKE_CURRENT_LIST_DIR}/../include\")
include_directories(\"\${include_dir}\")\n"
)

set(${PROJECT_NAME}_dep_authors "")
set(${PROJECT_NAME}_dep_names "")
set(${PROJECT_NAME}_dep_vers "")

# LinKIn_AddGithubDependency: add github project to the current project
# author: github author
# name: github project name
# ver: github project version
function(LinKIn_AddGithubDependency author name ver)
  list(FIND ${PROJECT_NAME}_dep_names ${name} idx)
  if(idx STREQUAL "-1")
    message(STATUS "Add dependency: ${name} ${ver}")
    set(add_dep TRUE)
  else()
    list(GET ${PROJECT_NAME}_dep_vers ${idx} existed_ver)
    if(existed_ver STREQUAL ver)
      set(add_dep FALSE)
    else()
      message(FATAL_ERROR "Two dependencies of ${name} with incompatible version: ${existed_ver} and ${ver}")
    endif()
  endif()
  if(add_dep)
    message(STATUS "Finding package: ${name} ${ver}")
    set(${PROJECT_NAME}_dep_authors ${${PROJECT_NAME}_dep_authors} ${author} PARENT_SCOPE)
    set(${PROJECT_NAME}_dep_names ${${PROJECT_NAME}_dep_names} ${name} PARENT_SCOPE)
    set(${PROJECT_NAME}_dep_vers ${${PROJECT_NAME}_dep_vers} ${ver} PARENT_SCOPE)
    find_package(${name} ${ver} QUIET)
    if({${name}_FOUND)
      message(STATUS "Finding package: ${name} ${ver} - found")
    else()
      message(STATUS "Finding package: ${name} ${ver} - not found")
      set(address "https://github.com/${author}/${name}")
      message(STATUS "Fetching: ${address} with tag ${ver}")
      FetchContent_Declare(${name} GIT_REPOSITORY ${address} GIT_TAG ${ver})
      FetchContent_MakeAvailable(${name})
      message(STATUS "Fetching: ${address} with tag ${ver} - done")
    endif()
  endif()
endfunction()

function(LinKIn_Export)
  cmake_parse_arguments(ARG "TARGET" "" "DIRECTORIES" ${ARGN})

  message(STATUS "Exporting ${install_name}")
  list(LENGTH ${PROJECT_NAME}_dep_names dep_count)
  if(dep_count GREATER 0)
    set(LinKIn_PACKAGE_INIT "${LinKIn_PACKAGE_INIT}
if(NOT FetchContent_FOUND)
  include(FetchContent)
endif()
message(STATUS \"Finding package: LCMake ${LCMake_VERSION}\")
find_package(LCMake ${LCMake_VERSION} EXACT QUIET)
if(LCMake_FOUND)
  message(STATUS \"Finding package: LCMake ${LCMake_VERSION} - found\")
elseif()
  message(STATUS \"Finding package: LCMake ${LCMake_VERSION} - not found\")
  set(LCMake_address \"https://github.com/LinKInLeLe43/LCMake\")
  message(STATUS \"Fetching: \${LCMake_address} with tag ${LCMake_VERSION}\")
  FetchContent_Declare(LCMake GIT_REPOSITORY \${LCMake_address} GIT_TAG ${LCMake_VERSION})
  FetchContent_MakeAvailable(LCMake)
  message(STATUS \"Fetching: \${LCMake_address} with tag ${LCMake_VERSION} - done\")
endif()
\n"
    )
    message(STATUS "[Dependencies]")
    math(EXPR stop "${dep_count}-1")
    foreach(idx RANGE ${_stop})
      list(GET ${PROJECT_NAME}_dep_authors ${idx} author)
      list(GET ${PROJECT_NAME}_dep_names ${idx} name)
      list(GET ${PROJECT_NAME}_dep_vers ${idx} ver)
      message(STATUS "- ${author}/${name} ${ver}")
      string(APPEND LinKIn_PACKAGE_INIT "LinKIn_AddGithubDependency(${author} ${name} ${ver})")
    endforeach()
  endif()

  if(ARG_TARGET)
    # generate the export targets for the build tree
    # needs to be after the install(TARGETS) command
    export(EXPORT ${PROJECT_NAME}Targets
      NAMESPACE LinKIn::
    )
    # install the configuration targets
    install(EXPORT ${PROJECT_NAME}Targets
      FILE ${PROJECT_NAME}Targets.cmake
      NAMESPACE LinKIn::
      DESTINATION "${install_name}/cmake"
    )
  endif()
  include(CMakePackageConfigHelpers)
  # generate the config file that is includes the exports
  configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/config/Config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION "${install_name}/cmake"
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
  )
  # generate the version file for the config file
  write_basic_package_version_file(
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMinorVersion
  )
  # install the configuration file
  install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION "${install_name}/cmake"
  )
  foreach(dir ${ARG_DIRECTORIES})
    cmake_path(GET dir PARENT_PATH parent_dir)
    if(parent_dir)
      install(DIRECTORY "${dir}" DESTINATION "${install_name}/${parent_dir}")
    else()
      install(DIRECTORY "${dir}" DESTINATION "${install_name}")
    endif()
  endforeach()
  message(STATUS "Exporting ${install_name} - done")
endfunction()

message(STATUS "Including package.cmake - done")