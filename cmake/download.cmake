message(STATUS "Including download.cmake")

# LinKIn_CheckDownload: check file existence and hash value
# file_path: download file path
# hash_type: hash type
# hash_value: hash value
# need_var: variable of need
function(LinKIn_CheckDownload file_path hash_type hash_value need_var)
  if(EXISTS "${file_path}")
    file(${hash_type} "${file_path}" existed_hash_value)
    string(TOLOWER ${hash_value} lower_hash_value)
    string(TOLOWER ${existed_hash_value} existed_lower_hash_value)
    if(lower_hash_value STREQUAL existed_lower_hash_value)
      set(${need_var} FALSE PARENT_SCOPE)
      return()
    endif()
  endif()
  set(${need_var} TRUE PARENT_SCOPE)
endfunction()

# LinKIn_CheckDownload: download file
# file_url: file url
# file_path: download file path
# hash_type: hash type
# hash_value: hash value
function(LinKIn_DownloadFile file_url file_path hash_type hash_value)
  LinKIn_CheckDownload(${file_path} ${hash_type} ${hash_value} need)
  if(NOT need)
    message(STATUS "Found file: ${file_path}")
    return()
  endif()
  message(STATUS "Downloading file")
  message(STATUS "- ulr: ${file_url}")
  message(STATUS "- file name: ${file_path}")
  file(DOWNLOAD ${file_url} "${file_path}"
    SHOW_PROGRESS EXPECTED_HASH ${hash_type}=${hash_value} TLS_VERIFY ON
  )
  message(STATUS "Downloading file - done")
endfunction()

# LinKIn_DownloadAndExtractZip: download zip file and unzip
# zip_url: zip file url
# zip_name: save name, under ${CMAKE_BINARY_DIR}/download
# unzip_dir: directory of unzip
# hash_type: hash type
# hash_value: hash value
function(LinKIn_DownloadAndExtractZip zip_url zip_name unzip_dir hash_type hash_value)
  set(zip_path "${CMAKE_BINARY_DIR}/download/${zip_name}")
  LinKIn_CheckDownload("${zip_path}" ${hash_type} ${hash_value} need)
  if(NOT need)
    message(STATUS "Found File: ${zip_path}")
  else()
    LinKIn_DownloadFile(${zip_url} "${zip_path}" ${hash_type} ${hash_value})
  endif()
  message(STATUS "Extracting zip: ${zip_name} to ${unzip_dir}")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar x ${zip_path} WORKING_DIRECTORY ${unzip_dir})
  message(STATUS "Extracting zip: ${zip_name} - done")
endfunction()

# LinKIn_DownloadAndExtractZipToCurrent: download zip file and unzip to ${CMAKE_CURRENT_SOURCE_DIR}
# zip_url: zip file url
# zip_name: save name, under ${CMAKE_BINARY_DIR}/download
# hash_type: hash type
# hash_value: hash value
function(LinKIn_DownloadAndExtractZipToCurrent zip_url zip_name hash_type hash_value)
  LinKIn_DownloadAndExtractZip(${zip_url} ${zip_name} "${CMAKE_CURRENT_SOURCE_DIR}" ${hash_type} ${hash_value})
endfunction()

message(STATUS "Including download.cmake - done")