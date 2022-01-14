# 307lib/cmake/modules/AutoVersion.cmake
# Contains functions for automatically setting package versions from git tags
#
## USAGE
# 1.	Add this directory to the CMAKE_MODULE_PATH list by replacing <PATH> in this line:
#			list(APPEND CMAKE_MODULE_PATH "<PATH>")
#
# 2.	Retrieve the current git tag & use ${AUTOVERSION_PARSE_REGEX} to parse the version number from it
#			GET_VERSION("${CMAKE_SOURCE_DIR}" MAJOR_VERSION MINOR_VERSION PATCH_VERSION)
#
# (optional):
#
# 3.	Make a single version variable that is compatible with CMake's VERSION arguments:
#			MAKE_VERSION(FULL_VERSION ${VERSION_MAJOR} ${VERSION_MINOR} ${VERSION_PATCH})
#
# 4.	Create a version header containing C++ preprocessor definitions to support project-wide versioning from a single source.
#			CREATE_VERSION_HEADER(<TARGET>, ${VERSION_MAJOR} ${VERSION_MINOR} ${VERSION_PATCH})
#		(Make sure you add "*/version.h" to your .gitignore)
#		This creates the following preprocessor definitions:
#			TARGET_MAJOR_VERSION
#
cmake_minimum_required(VERSION 3.20)

set(AUTOVERSION_REGEX_PREFIX "[vV]*" CACHE STRING "Regex to match git tag prefixes that aren't part of the version number. (These are discarded)")
set(AUTOVERSION_REGEX_SUFFIX "[\\r\\n\\.]*" CACHE STRING "Regex to match git tag suffixes that aren't part of the version number. (These are discarded)")
set(AUTOVERSION_REGEX_SEPARATOR "[\\.-]*" CACHE STRING "Regex to match version number separators. (These are discarded)")
set(AUTOVERSION_REGEX_NUMBER "[0-9]+" CACHE STRING "Regex to detect each version number.")

set(AUTOVERSION_PARSE_REGEX 
	"^${AUTOVERSION_REGEX_PREFIX}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SEPARATOR}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SEPARATOR}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SUFFIX}"
	CACHE STRING
	"Used by AutoVersion.cmake functions to parse the most recent git tag for a version number."
)

#### GET_GIT_TAG(<REPO_DIR> <OUT_VAR>) ####
# @brief				Call "git describe --tags" from the given directory, and set ${_out_var} to the result.
# @param _working_dir	The root repository directory to call the git describe command in.
# @param _out_var		The name of a variable to set with the result of the command.
macro(AV_GET_GIT_TAG _working_dir _out_var)
	execute_process(
		COMMAND
			"git"
			"describe"
			"--tags"
		WORKING_DIRECTORY "${_working_dir}"
		OUTPUT_VARIABLE ${_out_var}
	)
endmacro()

#### AV_PARSE_TAG(<GIT_TAG> <OUT_VAR>[...])
# @brief			Parses a git tag into any number of version number sections.
#					At least one output variable name is required.
#					Any number of output vars can be included, example:
#                   REGEX_PARSE_VERSION("1.2.3" major minor patch)
#						major = 1
#						minor = 2
#						patch = 3
# @param _tag_raw	The raw git tag string to parse.
function(AV_PARSE_TAG _tag_raw)
	if ("${_tag_raw}" STREQUAL "")
		message(WARNING "AV_PARSE_TAG(${_tag_raw}) failed:  Received empty git tag!")
		return()
	endif()
	if (${ARGC} LESS_EQUAL 1)
		message(FATAL_ERROR "No output variables specified for AV_PARSE_VERSION()!\nARGN: \"${ARGN}\"")
	endif()
	math(EXPR index "0")
	foreach(_out_var IN LISTS ARGN)
		math(EXPR index "${index} + 1")
		string(REGEX REPLACE "${AUTOVERSION_PARSE_REGEX}" "\\${index}" _tmp "${_tag_raw}")
		set(${_out_var} "${_tmp}" CACHE STRING "" FORCE)
		message(STATUS "Set ${_out_var}: \"${${_out_var}}\"")
	endforeach()
endfunction()

function(GET_VERSION _working_dir)
	AV_GET_GIT_TAG("${_working_dir}" TAG)
	message(STATUS "Retrieved git tag: \"${TAG}\"")
	AV_PARSE_TAG("${TAG}" "${ARGN}")
endfunction()

#### MAKE_VERSION ####
# @brief			Concatenate version strings into a single version string in the format "${MAJOR}.${MINOR}.${PATCH}${EXTRA}"
# @param _out_var	Name of the variable to use for output.
# @param _major		Major version number
# @param _minor		Minor version number
# @param _patch		Patch version number
function(MAKE_VERSION _out_var)
	if (${ARGC} EQUAL 1)
		message(FATAL_ERROR "Invalid Version Number List: \"${ARGN}\"")
	endif()
	list(JOIN "${ARGN}" "." ${_out_var})
	message(STATUS "MAKE_VERSION Created Version: \"${${_out_var}}\"")
endfunction()

#### CREATE_VERSION_HEADER ####
# @brief				Creates a copy of the version.h.in header in the caller's source directory.
#\n						You can optionally include the path to the input version header.
# @param _name			The name of the library
# @param _major			Major version number
# @param _minor			Minor version number
# @param _patch			Patch version number
function(CREATE_VERSION_HEADER _name _major _minor _patch)
	# Set temporary variables
	set(IN_NAME ${_name} CACHE STRING "" FORCE)
	set(IN_MAJOR ${_major} CACHE STRING "" FORCE)
	set(IN_MINOR ${_minor} CACHE STRING "" FORCE)
	set(IN_PATCH ${_patch} CACHE STRING "" FORCE)

	# Remove previous
	file(REMOVE "${CMAKE_CURRENT_SOURCE_DIR}/version.h")

	# Configure file
	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/version.h.in" "${CMAKE_CURRENT_SOURCE_DIR}/version.h")

	# Unset temporary cache variables
	unset(IN_NAME CACHE)
	unset(IN_MAJOR CACHE)
	unset(IN_MINOR CACHE)
	unset(IN_PATCH CACHE)
endfunction()
