set (libs "")
if(MSVC)
  #
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
  list(APPEND libs "dl")
elseif("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
  list(APPEND libs "dl")
endif()

LinKIn_AddTarget(
  TEST
  MODE EXE
  LIBRARY_PRIVATE
    ${libs}
)