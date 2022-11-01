# 307modules/ResourceMaker.cmake
cmake_minimum_required(VERSION 3.20)

set(RCM_ICON_RESOURCE "IDI_ICON1               ICON                    \"@_icon_filepath@\"" CACHE STRING "The content of an icon resource file, before using string(CONFIGURE) on it.")

#### MAKE_FILES([filenames]...) ####
# @brief					Create any number of files.
#							If this function is called with blank arguments, or no arguments, a warning message is printed to the log.
# @param	filenames...	Any number of filenames to create in the specified location.
function(MAKE_FILES)
	if (${ARGC} EQUAL 0 OR "${ARGN}" STREQUAL "")
		message(WARNING "MAKE_FILE():  !![WARNING]!! Function was called without any valid arguments, something is wrong!")
	else()
		file(TOUCH "${ARGN}")
	endif()
endfunction(MAKE_FILES)

#### MAKE_STRINGRC_ICON(<OUT_STRINGRC> <ICON_FILEPATH>) ####
# @brief					Creates a string cache variable containing an icon entry formatted for a .rc file. 
#							Pass the returned string to the MAKE_RESOURCE() function.
# @param _out_string		The name of a cache variable to save the configured string as.
# @param _icon_filepath		The filepath of the icon file on the system. 
function(MAKE_STRINGRC_ICON _out_string _icon_filepath)
	string(CONFIGURE
		"${RCM_ICON_RESOURCE}"
		_stringrc
		@ONLY
	)
	set("${_out_string}" "${_stringrc}" CACHE STRING "[String Resource] RC icon saved as a string." FORCE)
endfunction(MAKE_STRINGRC_ICON)

#### MAKE_STRINGRC_VERSIONINFO_LONG(<OUT_STRINGRC> ...) ####
# @brief	Long-form versioninfo maker that accepts additional fields over the regular function.
function(MAKE_STRINGRC_VERSIONINFO_LONG
	_out_string
	_fileVersion
	_legalCopyright
	_companyName
	_productName
	_fileDescription
	_internalName
	_version_product
	_originalFilename
)
	# Set input variables
	## Parse version numbers
	include (VersionTag)

	PARSE_TAG("${_fileVersion}" __RCMKR_FV1 __RCMKR_FV2 __RCMKR_FV3 __RCMKR_FV4)
	
	if ("${__RCMKR_FV1}" STREQUAL "")
		set(__RCMKR_FV1 "0")
	endif()
	if ("${__RCMKR_FV2}" STREQUAL "")
		set(__RCMKR_FV2 "0")
	endif()
	if ("${__RCMKR_FV3}" STREQUAL "")
		set(__RCMKR_FV3 "0")
	endif()
	if ("${__RCMKR_FV4}" STREQUAL "")
		set(__RCMKR_FV4 "0")
	endif()

	PARSE_TAG("${_version_product}" __RCMKR_PV1 __RCMKR_PV2 __RCMKR_PV3 __RCMKR_PV4)
	
	if ("${__RCMKR_PV1}" STREQUAL "")
		set(__RCMKR_PV1 "0")
	endif()
	if ("${__RCMKR_PV2}" STREQUAL "")
		set(__RCMKR_PV2 "0")
	endif()
	if ("${__RCMKR_PV3}" STREQUAL "")
		set(__RCMKR_PV3 "0")
	endif()
	if ("${__RCMKR_PV4}" STREQUAL "")
		set(__RCMKR_PV4 "0")
	endif()

	# Read & configure the string resource
	file(READ "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/versioninfo.rc.in" _stringrc)
	string(CONFIGURE
		"${_stringrc}"
		_out_stringrc
		@ONLY
	)

	# Set the output variable
	set("${_out_string}" "${_out_stringrc}" PARENT_SCOPE)
endfunction(MAKE_STRINGRC_VERSIONINFO_LONG)

#### MAKE_STRINGRC_VERSIONINFO() ####
# @brief
function(MAKE_STRINGRC_VERSIONINFO
	 _out_string
	_fileVersion
	_legalCopyright
	_companyName
	_productName
	_fileDescription
)
	# Set input variables

	set(_internalName "${_productName}")
	set(_originalFilename "${_productName}")

	## Parse version numbers
	include (VersionTag)

	PARSE_TAG("${_fileVersion}" __RCMKR_FV1 __RCMKR_FV2 __RCMKR_FV3 __RCMKR_FV4)

	if ("${__RCMKR_FV1}" STREQUAL "")
		set(__RCMKR_FV1 "0")
	endif()
	if ("${__RCMKR_FV2}" STREQUAL "")
		set(__RCMKR_FV2 "0")
	endif()
	if ("${__RCMKR_FV3}" STREQUAL "")
		set(__RCMKR_FV3 "0")
	endif()
	if ("${__RCMKR_FV4}" STREQUAL "")
		set(__RCMKR_FV4 "0")
	endif()

	set(__RCMKR_PV1 "${__RCMKR_FV1}")
	set(__RCMKR_PV2 "${__RCMKR_FV2}")
	set(__RCMKR_PV3 "${__RCMKR_FV3}")
	set(__RCMKR_PV4 "${__RCMKR_FV4}")

	# Read & configure the string resource
	file(READ "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/versioninfo.rc.in" _stringrc)
	string(CONFIGURE
		"${_stringrc}"
		_out_stringrc
		@ONLY
	)

	# Set the output variable
	set("${_out_string}" "${_out_stringrc}" PARENT_SCOPE)
endfunction(MAKE_STRINGRC_VERSIONINFO)

#### MAKE_STRINGRC_VERSIONINFO_SHORT() ####
# Requires a "${_project}_VERSION" variable already having been set by VersionTag or manually.
function(MAKE_STRINGRC_VERSIONINFO_SHORT
	_out_string
	_project
	# [_legalCopyright]
	# [_companyName]
	# [_productName]
	# [_fileDescription]
)
	# Set input variables
	foreach(_i RANGE 4)
		math(EXPR _index "${_i} + 2")
		if ("${_index}" GREATER_EQUAL "${ARGC}")
			break()
		elseif ("${_i}" EQUAL 0)
			list(GET "${ARGN}" "${_index}" _legalCopyright)
		elseif("${_i}" EQUAL 1)
			list(GET "${ARGN}" "${_index}" _companyName)
		elseif("${_i}" EQUAL 2)
			list(GET "${ARGN}" "${_index}" _productName)
		elseif("${_i}" EQUAL 3)
			list(GET "${ARGN}" "${_index}" _fileDescription)
		endif()
	endforeach()

	set(_internalName "${_project}")
	set(_originalFilename "${_project}")

	## Parse version numbers
	include (VersionTag)

	PARSE_TAG("${${_project}_VERSION}" __RCMKR_FV1 __RCMKR_FV2 __RCMKR_FV3 __RCMKR_FV4)
	
	if ("${__RCMKR_FV1}" STREQUAL "")
		set(__RCMKR_FV1 "0")
	endif()
	if ("${__RCMKR_FV2}" STREQUAL "")
		set(__RCMKR_FV2 "0")
	endif()
	if ("${__RCMKR_FV3}" STREQUAL "")
		set(__RCMKR_FV3 "0")
	endif()
	if ("${__RCMKR_FV4}" STREQUAL "")
		set(__RCMKR_FV4 "0")
	endif()

	set(__RCMKR_PV1 "${__RCMKR_FV1}")
	set(__RCMKR_PV2 "${__RCMKR_FV2}")
	set(__RCMKR_PV3 "${__RCMKR_FV3}")
	set(__RCMKR_PV4 "${__RCMKR_FV4}")

	# Read & configure the string resource
	file(READ "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/versioninfo.rc.in" _stringrc)
	string(CONFIGURE
		"${_stringrc}"
		_out_stringrc
		@ONLY
	)

	unset(__RCMKR_FV1 CACHE)
	unset(__RCMKR_FV2 CACHE)
	unset(__RCMKR_FV3 CACHE)
	unset(__RCMKR_FV4 CACHE)

	unset(__RCMKR_PV1 CACHE)
	unset(__RCMKR_PV2 CACHE)
	unset(__RCMKR_PV3 CACHE)
	unset(__RCMKR_PV4 CACHE)

	# Set the output variable
	set("${_out_string}" "${_out_stringrc}" PARENT_SCOPE)
endfunction(MAKE_STRINGRC_VERSIONINFO_SHORT)

#### MAKE_RESOURCE(<OUT_FILE> [STRINGRC]...) ####
# @brief	Create a .rc resource file in the local filesystem.
# @param _out_file
function(MAKE_RESOURCE _out_file)
	# Get the filename without extensions & write the file with the named header
	get_filename_component(_out_filename "${_out_file}" NAME CACHE)
	file(WRITE "${_out_file}" "1 TYPELIB \"${_out_filename}\"")
	message(STATUS "MAKE_RESOURCE():  Created resource file \"${_out_file}\" using filename component \"${_out_filename}\"")
	unset(_out_filename CACHE) # Delete cache variable to prevent potential pollution

	foreach (_stringrc IN LISTS ARGN)
		file(APPEND "${_out_file}" "\n${_stringrc}")
		message(STATUS "MAKE_RESOURCE():  Writing String Resource to File: \"${_stringrc}\"")
	endforeach()
	message(STATUS "MAKE_RESOURCE():  Resource file written successfully.")
endfunction(MAKE_RESOURCE)

# MAKE_COPYRIGHT_HEADER(<OUT_FILE> <PROJECT_NAME> <COPYRIGHT_YEAR> <COPYRIGHT_HOLDER>)
#	Creates a header file containing copyright notices as preprocessor definitions.
#	This is intended for POSIX-based systems as an alternative to the VERSIONINFO resource on Windows.
# PARAMETERS:
#	_out_header			The output header file.
#	_project_name		The name of the project. This determines the names of the processor definitions.
#	_copyright_year		The year that the copyright notice was last updated.
#	_copyright_holder	The holder of the copyright notice.
# PREPROCESSOR DEFINITIONS:
#	${_project_name}_COPYRIGHT_YEAR		The year that the copyright notice was last updated.
#	${_project_name}_COPYRIGHT_HOLDER	The owner of the copyright.
#	${_project_name}_COPYRIGHT			The full copyright notice as a string.
function(MAKE_COPYRIGHT_HEADER _out_header _project_name _copyright_year _copyright_holder)
	set(IN_PROJECT "${_project_name}" CACHE INTERNAL "")
	set(IN_YEAR "${_copyright_year}" CACHE INTERNAL "")
	set(IN_HOLDER "${_copyright_holder}" CACHE INTERNAL "")
	set(IN_NOTICE "Copyright © ${_copyright_year} by ${_copyright_holder}")

	message(STATUS
		" MAKE_COPYRIGHT_HEADER():	_out_header			= \"${_out_header}\"\n"
		" MAKE_COPYRIGHT_HEADER():	_project_name		= \"${_project_name}\"\n"
		" MAKE_COPYRIGHT_HEADER():	_copyright_year		= \"${_copyright_year}\"\n"
		" MAKE_COPYRIGHT_HEADER():	_copyright_holder	= \"${_copyright_holder}\"\n"
		" MAKE_COPYRIGHT_HEADER():	Copyright Notice	= \"${IN_NOTICE}\""
	)

	file(REMOVE "${_out_header}")

	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/copyright.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)
endfunction()


#############################################################################
#                     ResourceMaker Legacy Functions						#
#############################################################################


macro(SETCACHE _name _value)
	set("${_name}" "${_value}" CACHE STRING "" FORCE)
endmacro()
function(CREATE_FILE _out_file)
	file(WRITE "${_out_file}" ${ARGN})
endfunction()
function(APPEND_FILE _out_file)
	file(APPEND "${_out_file}" ${ARGN})
endfunction()

#### CREATE_RESOURCE(<OUT_FILEPATH> [CONTENT...]) ####
function(CREATE_RESOURCE _out_rc_file)
	file(REMOVE "${_out_rc_file}")
	file(WRITE "${_out_rc_file}" ${ARGN})
endfunction()

#### CREATE_VERSION_RESOURCE(<OUT_FILE> <MAJOR> <MINOR> <PATCH> <COMPANY_NAME> <DESCRIPTION> <INTERNAL_NAME> <COPYRIGHT> <ORIGINAL_FILENAME> <PRODUCT_NAME>) ####
# @brief					Creates a versioninfo.rc file in the given directory.
#			!![NOTE]!!		This function is deprecated, use the "MAKE_STRINGRC_VERSIONINFO" & "MAKE_RESOURCE()" functions instead!
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
