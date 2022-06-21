message(STATUS "Including qt.cmake")

macro(LinKIn_QtInit)
  message(STATUS "----------")
  cmake_parse_arguments(ARG "" "" "COMPONENTS" ${ARGN})
  LinKIn_Print(TITLE "Qt Components" PREFIX "  - " STRS ${ARG_COMPONENTS})
  find_package(Qt5 REQUIRED COMPONENTS ${ARG_COMPONENTS})
  message(STATUS "----------")
endmacro()

function(LinKIn_QtBegin)
  set(CMAKE_AUTOMOC ON PARENT_SCOPE)
  set(CMAKE_AUTOUIC ON PARENT_SCOPE)
  set(CMAKE_AUTORCC ON PARENT_SCOPE)
endfunction()

function(LinKIn_QtEnd)
  set(CMAKE_AUTOMOC OFF PARENT_SCOPE)
  set(CMAKE_AUTOUIC OFF PARENT_SCOPE)
  set(CMAKE_AUTORCC OFF PARENT_SCOPE)
endfunction()

message(STATUS "Including qt.cmake - done")