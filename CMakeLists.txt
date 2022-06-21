cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

include(${CMAKE_SOURCE_DIR}/cmake/init.cmake)

LinKIn_InitVcpkg(
  ROOT D:/vcpkg)

project (LCMake VERSION 0.1.0)
message(STATUS "[Project] ${PROJECT_NAME} ${PROJECT_VERSION}")

LinKIn_InitProject()

LinKIn_AddSubdirectories("test/lib")
LinKIn_AddSubdirectories("test/exe")

LinKIn_Export(
  DIRECTORIES
    "cmake"
)