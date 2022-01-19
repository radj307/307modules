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
set(AUTOVERSION_REGEX_SUFFIX ".*" CACHE STRING "Regex to match git tag suffixes that aren't part of the version number. (These are discarded)")
set(AUTOVERSION_REGEX_SEPARATOR "[\\.-]*" CACHE STRING "Regex to match version number separators. (These are discarded)")
set(AUTOVERSION_REGEX_NUMBER "[0-9]+" CACHE STRING "Regex to detect each version number.")

set(AUTOVERSION_PARSE_REGEX 
	"^${AUTOVERSION_REGEX_PREFIX}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SEPARATOR}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SEPARATOR}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SEPARATOR}(${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SUFFIX}"
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
		OUTPUT_VARIABLE _tmp
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	set(${_out_var} "${_tmp}" CACHE STRING "" FORCE)
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
	message(STATUS "AV_PARSE_TAG(${_tag_raw})")
	if ("${_tag_raw}" STREQUAL "")
		message(WARNING "AV_PARSE_TAG() failed:  Received empty git tag! \"${_tag_raw}\"")
		return()
	endif()
	if (${ARGC} LESS_EQUAL 1)
		message(FATAL_ERROR "No output variables specified for AV_PARSE_VERSION()!\nARGN: \"${ARGN}\"")
	endif()
	math(EXPR index "0")
	foreach(_out_var IN LISTS ARGN)
		math(EXPR index "${index}+1")
		string(REGEX REPLACE "${AUTOVERSION_PARSE_REGEX}" "\\${index}" "_tmp" ${_tag_raw})
		set(${_out_var} "${_tmp}" CACHE STRING "" FORCE)
		message(STATUS "Parsed ${_out_var}: ${${_out_var}}")
	endforeach()
endfunction()

#### AV_GET_VERSION(<REPO_ROOT_DIR> <OUT_FULL_GIT_TAG> [OUT_MAJOR] [OUT_MINOR] [OUT_PATCH] ...) ####
function(AV_GET_VERSION _working_dir _out_tag)
	AV_GET_GIT_TAG("${_working_dir}" _tmp)
	message(STATUS "Retrieved git tag: ${_tmp}")
	# Remove any extra characters
	string(REGEX REPLACE "-.+" "" _tmp "${_tmp}")
	set(${_out_tag} "${_tmp}" CACHE STRING "" FORCE)
	message(STATUS "Parsed version number: ${${_out_tag}}")
	AV_PARSE_TAG("${${_out_tag}}" ${ARGN})
endfunction()

#### CREATE_VERSION_HEADER(<FILEPATH> <MAJOR> <MINOR> <PATCH>) ####
# @brief				Creates a copy of the version.h.in header in the caller's source directory.
#\n						You can optionally include the path to the input version header.
# @param _out_header	The name & location of the output file.
# @param _major			Major version number
# @param _minor			Minor version number
# @param _patch			Patch version number
function(CREATE_VERSION_HEADER _out_header _major _minor _patch)
	# Set temporary variables
	set(IN_NAME "${_name}" CACHE STRING "" FORCE)
	set(IN_MAJOR "${_major}" CACHE STRING "" FORCE)
	set(IN_MINOR "${_minor}" CACHE STRING "" FORCE)
	set(IN_PATCH "${_patch}" CACHE STRING "" FORCE)

	# Remove previous
	file(REMOVE "${_out_header}")

	# Configure file
	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/version.h.in" "${_out_header}")

	# Unset temporary cache variables
	unset(IN_NAME CACHE)
	unset(IN_MAJOR CACHE)
	unset(IN_MINOR CACHE)
	unset(IN_PATCH CACHE)
endfunction()

#### IS_GIT_REPOSITORY(<OUT_BOOL> <REPOSITORY_ROOT_DIRECTORY>) ####
# @brief	Checks if the given directory contains a ".git" subdirectory.
function(IS_GIT_REPOSITORY _out_var _path)
	if (EXISTS "${_path}/.git")
		set(${_out_var} TRUE CACHE BOOL "" FORCE)
	else()
		set(${_out_var} FALSE CACHE BOOL "" FORCE)
	endif()
	message(STATUS "IS_GIT_REPOSITORY: ${${_out_var}}")
endfunction()

#### GET_VERSION
function(GET_VERSION _version_prefix _repository_path)
	if (${ARGC} GREATER 2)
		message(FATAL_ERROR 
			" #####################################################################################################\n"
			" You're using the old GET_VERSION method that has been replaced, to fix this error:\n"
			" 1.  Remove all arguments from the function call.\n"
			" 2.  Use only the \"..._VERSION\" prefix as the first argument.\n"
			" 3.  Use the target repository directory as the second argument. (Usually CMAKE_CURRENT_SOURCE_DIR)\n"
			" The arguments in question are: ${ARGN}"
			" #####################################################################################################"
		)
	endif()

	# Check if this is a git repository
	IS_GIT_REPOSITORY(USE_AUTOVERSION ${_repository_path})

	if (USE_AUTOVERSION)
		AV_GET_VERSION("${_repository_path}" ${_version_prefix}_VERSION ${_version_prefix}_VERSION_MAJOR ${_version_prefix}_VERSION_MINOR ${_version_prefix}_VERSION_PATCH)
		if (${_version_prefix}_VERSION STREQUAL "")
			set(_use_env TRUE)
		else()
			set(_use_env FALSE)
		endif()
	endif()

	if(NOT USE_AUTOVERSION OR _use_env)
		set(_env_var_name "${_version_prefix}_VERSION")
		message(WARNING
			" > AutoVersion couldn't find a usable git tag!\n"
			" Attempting to fallback to environment variable: \"${_env_var_name}\"\n"
		)
		set(${_version_prefix}_VERSION "$ENV{${_env_var_name}}" CACHE STRING "" FORCE)
		AV_PARSE_TAG("${${_env_var_name}}" ${_env_var_name}_MAJOR ${_env_var_name}_MINOR ${_env_var_name}_PATCH)
	endif()


	# Cleanup variables
	unset(_path)
	unset(USE_AUTOVERSION CACHE)
	unset(_use_env)
endfunction()
