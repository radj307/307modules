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

set(AUTOVERSION_REGEX_PREFIX "[vV]" CACHE STRING "Characters to ignore at the start of the git tag string.")
set(AUTOVERSION_REGEX_SEPARATOR "[\.]" CACHE STRING "Character to use as the separator for each version number.")
set(AUTOVERSION_REGEX_NUMBER "[0-9]+" CACHE STRING "Regex to detect each version number")

set(AUTOVERSION_PARSE_REGEX 
	"^${AUTOVERSION_REGEX_PREFIX}*((${AUTOVERSION_REGEX_NUMBER})${AUTOVERSION_REGEX_SEPARATOR}*)+.*"
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

#### REGEX_PARSE_VERSION(<GIT_TAG> <OUT_VAR>[...])
# @brief			Parses a git tag into any number of version number sections.
#					At least one output variable name is required.
#					Any number of output vars can be included, example:
#                   REGEX_PARSE_VERSION("1.2.3" major minor patch)
#						major = 1
#						minor = 2
#						patch = 3
# @param _tag_raw	The raw git tag string to parse.
function(GET_VERSION _tag_raw)
	if (${ARGC} LESS_EQUAL 1)
		message(FATAL_ERROR "No output variables specified for AV_PARSE_VERSION()!\nARGN: \"${ARGN}\"")
	endif()
	math(EXPR index "0")
	foreach(_out_var IN LISTS ARGN)
		math(EXPR index "${index} + 1")
		string(REGEX REPLACE "${AUTOVERSION_PARSE_REGEX}" "\\${index}" "${_out_var}" "${_tag_raw}")
	endforeach()
endfunction()

#### GET_VERSION ####
# @brief				Retrieve and parse the result of calling `git describe --tags`
# @param _out_major		Variable name to store the major version number
# @param _out_minor		Variable name to store the minor version number
# @param _out_patch		Variable name to store the patch version number
#function(GET_VERSION _working_dir _out_major _out_minor _out_patch)
	# set the "VERSION_TAG" cache variable to the result of `git describe ${AUTOVERSION_GIT_DESCRIBE_ARGS}` in CMAKE_SOURCE_DIR
#	AV_GET_GIT_TAG("${_working_dir}" "VERSION_TAG")

#	if ("${VERSION_TAG}" STREQUAL "") # Don't use ${} expansion here, if statements work without them and this may cause a comparison failure
#		message(WARNING "No git tags found, skipping AutoVersioning.")
#		return()
#	endif()

#	AV_PARSE_VERSION("${VERSION_TAG}" _MAJOR _MINOR _PATCH)

	# Print a status message showing the parsed values
#	message(STATUS "Successfully parsed version number from git tags.")
#	message(STATUS "  MAJOR: ${_MAJOR}")
#	message(STATUS "  MAJOR: ${_MINOR}")
#	message(STATUS "  MAJOR: ${_PATCH}")

	# Set the provided output variable names to the parsed version numbers
#	set(${_out_major} "${_MAJOR}" CACHE STRING "(SEMVER) Major Version portion of the current git tag" FORCE)
#	set(${_out_minor} "${_MINOR}" CACHE STRING "(SEMVER) Minor Version portion of the current git tag" FORCE)
#	set(${_out_patch} "${_PATCH}" CACHE STRING "(SEMVER) Patch Version portion of the current git tag" FORCE)
	
	# Cleanup
#	unset(_MAJOR CACHE)
#	unset(_MINOR CACHE)
#	unset(_PATCH CACHE)
#endfunction()

#### MAKE_VERSION ####
# @brief			Concatenate version strings into a single version string in the format "${MAJOR}.${MINOR}.${PATCH}${EXTRA}"
# @param _out_var	Name of the variable to use for output.
# @param _major		Major version number
# @param _minor		Minor version number
# @param _patch		Patch version number
function(MAKE_VERSION _out_var)
	list(JOIN "${ARGN}" "." ${_out_var})
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
