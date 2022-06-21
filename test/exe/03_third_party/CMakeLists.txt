find_package(unofficial-sqlite3 CONFIG REQUIRED)

LinKIn_AddTarget(
  TEST
  MODE EXE
  LIBRARY_PRIVATE
    unofficial::sqlite3::sqlite3
)