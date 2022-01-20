# 307modules/ResourceMaker.cmake
cmake_minimum_required(VERSION 3.20)

set(RCM_ICON_RESOURCE "IDI_ICON1               ICON                    \"@_icon_filepath@\"" CACHE STRING "The content of an icon resource file, before using string(CONFIGURE) on it.")

macro(SETCACHE _name _value)
	set("${_name}" "${_value}" CACHE STRING "" FORCE)
endmacro()


function(CREATE_FILE _out_file)
	file(WRITE "${_out_file}" ${ARGN})
endfunction()

function(APPEND_FILE _out_file)
	file(APPEND "${_out_file}" ${ARGN})
endfunction()

function(CREATE_FILE_VERSION_HEADER _out_file _name _version)
	include(AutoVersion)
	CREATE_FILE("${_out_file}" 
		"#pragma once\\n"
		"#define ${_name} \"${_version}\"\\n"
	)
endfunction()

#### CREATE_RESOURCE(<OUT_FILEPATH> [CONTENT...]) ####
function(CREATE_RESOURCE _out_rc_file)
	file(REMOVE "${_out_rc_file}")
	file(WRITE "${_out_rc_file}" ${ARGN})
endfunction()

#### CREATE_VERSION_RESOURCE(<OUT_FILE> <MAJOR> <MINOR> <PATCH> <COMPANY_NAME> <DESCRIPTION> <INTERNAL_NAME> <COPYRIGHT> <ORIGINAL_FILENAME> <PRODUCT_NAME>) ####
# @brief					Creates a versioninfo.rc file in the given directory.
# @param _out_rc_file		Output filename & path.
# @param _version_major		Major version number
# @param _version_minor		Minor version number
# @param _version_patch		Patch version number
# @param _company_name		Value to fill in for "CompanyName"
# @param _file_description	Value to fill in for "FileDescription"
# @param _internal_name		Value to fill in for "InternalName"
# @param _legal_copyright	Value to fill in for "LegalCopyright"
# @param _original_filename	Value to fill in for "OriginalFilename"
# @param _product_name		Value to fill in for "ProductName"
# 
function(CREATE_VERSION_RESOURCE
	_out_rc_file 
	# Version Numbers:
	_version_major 
	_version_minor 
	_version_patch 
	# Names/Description/Copyright
	_company_name 
	_file_description
	_internal_name
	_legal_copyright
	_original_filename
	_product_name
)
	# Set input variables
	get_filename_component(IN_MY_FILENAME "${_out_rc_file}" NAME CACHE)
	SETCACHE(IN_VERSION_MAJOR "${_version_major}")
	SETCACHE(IN_VERSION_MINOR "${_version_minor}")
	SETCACHE(IN_VERSION_PATCH "${_version_patch}")
	SETCACHE(IN_COMPANYNAME "${_company_name}")
	SETCACHE(IN_FILEDESCRIPTION "${_file_description}")
	SETCACHE(IN_INTERNALNAME "${_internal_name}")
	SETCACHE(IN_LEGALCOPYRIGHT "${_legal_copyright}")
	SETCACHE(IN_ORIGINALFILENAME "${_original_filename}")
	SETCACHE(IN_PRODUCTNAME "${_product_name}")
	file(REMOVE "${_out_rc_file}")

	set(RESOURCE_INPUT_FILE "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/target.rc.in")

	configure_file("${RESOURCE_INPUT_FILE}" "${CMAKE_CURRENT_BINARY_DIR}/temp.rc" @ONLY) # Configure file

	include(CatFile)
	CAT_FILE("${_out_rc_file}" "${CMAKE_CURRENT_BINARY_DIR}/temp.rc") # Concatenate the contents of temp.rc to the target file
	file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/temp.rc") # Clean up temp.rc
	# Copy & Configure File
	# Cleanup
	unset(IN_MY_FILENAME CACHE)
	unset(IN_VERSION_MAJOR CACHE)
	unset(IN_VERSION_MINOR CACHE)
	unset(IN_VERSION_PATCH CACHE)
	unset(IN_COMPANYNAME CACHE)
	unset(IN_FILEDESCRIPTION CACHE)
	unset(IN_INTERNALNAME CACHE)
	unset(IN_LEGALCOPYRIGHT CACHE)
	unset(IN_ORIGINALFILENAME CACHE)
	unset(IN_PRODUCTNAME CACHE)
endfunction()

function(APPEND_ICON_RESOURCE _out_rc_file _icon_filepath)
	string(CONFIGURE
		"${RCM_ICON_RESOURCE}"
		_content
		@ONLY
	)
	message(STATUS "Configured icon resource file contents \"${_content}\"")
	file(APPEND "${_out_rc_file}" ${_content})
	message(STATUS "Appended to resource file ${_out_rc_file}")
endfunction()

function(CREATE_ICON_RESOURCE _out_rc_file _icon_filepath)
	string(CONFIGURE
		"${RCM_ICON_RESOURCE}"
		_content
		@ONLY
	)
	message(STATUS "Configured icon resource file contents \"${_content}\"")
	file(WRITE "${_out_rc_file}" ${_content})
	message(STATUS "Wrote to resource file ${_out_rc_file}")
endfunction()
