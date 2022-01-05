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
cmake_minimum_required(VERSION 3.19)

set(AUTOVERSION_PARSE_REGEX "^[vV]*([0-9]+)\.([0-9]+)\.([0-9]+).+" CACHE STRING "Used by the AutoVersion PARSE_VERSION_STRING function to parse a git tag into a library version, by using capture groups. (1: Major Version ; 2: Minor Version ; 3: Patch Version ; 4: SHA1). All groups except for group 1 should be optional." FORCE)

#### GET_VERSION ####
# @brief				Retrieve and parse the result of calling `git describe --tags --dirty=-d`
# @param _out_major		Variable name to store the major version number
# @param _out_minor		Variable name to store the minor version number
# @param _out_patch		Variable name to store the patch version number
function(GET_VERSION _working_dir _out_major _out_minor _out_patch)
	# set the "VERSION_TAG" cache variable to the result of `git describe ${AUTOVERSION_GIT_DESCRIBE_ARGS}` in CMAKE_SOURCE_DIR
	execute_process(
		COMMAND 
			"git" 
			"describe" 
			"--tags"
		WORKING_DIRECTORY "${_working_dir}"
		OUTPUT_VARIABLE VERSION_TAG
	)

	if (VERSION_TAG STREQUAL "") # Don't use ${} expansion here, if statements work without them and this may cause a comparison failure
		message(STATUS "No git tags found, skipping AutoVersioning.")
		return()
	endif()

	# Parse the version string using the provided regular expression
	string(REGEX REPLACE ${AUTOVERSION_PARSE_REGEX} "\\1" _MAJOR ${VERSION_TAG}) # get Major
	string(REGEX REPLACE ${AUTOVERSION_PARSE_REGEX} "\\2" _MINOR ${VERSION_TAG}) # get Minor
	string(REGEX REPLACE ${AUTOVERSION_PARSE_REGEX} "\\3" _PATCH ${VERSION_TAG}) # get Patch

	# Print a status message showing the parsed values
	message(STATUS "Successfully parsed version number from git tags.")
	message(STATUS "  MAJOR: ${_MAJOR}")
	message(STATUS "  MAJOR: ${_MINOR}")
	message(STATUS "  MAJOR: ${_PATCH}")

	# Set the provided output variable names to the parsed version numbers
	set(${_out_major} "${_MAJOR}" CACHE STRING "(SEMVER) Major Version portion of the current git tag" FORCE)
	set(${_out_minor} "${_MINOR}" CACHE STRING "(SEMVER) Minor Version portion of the current git tag" FORCE)
	set(${_out_patch} "${_PATCH}" CACHE STRING "(SEMVER) Patch Version portion of the current git tag" FORCE)
	
	# Cleanup
	unset(_MAJOR CACHE)
	unset(_MINOR CACHE)
	unset(_PATCH CACHE)
endfunction()

#### MAKE_VERSION ####
# @brief			Concatenate version strings into a single version string in the format "${MAJOR}.${MINOR}.${PATCH}${EXTRA}"
# @param _out_var	Name of the variable to use for output.
# @param _major		Major version number
# @param _minor		Minor version number
# @param _patch		Patch version number
function(MAKE_VERSION _out_var _major _minor _patch)
	set(${_out_var} "${_major}.${_minor}.${_patch}" CACHE STRING "Full version string." FORCE)
endfunction()

#### CREATE_VERSION_HEADER ####
# @brief				Creates a copy of the version.h.in header in the caller's source directory.
#\n						You can optionally include the path to the input version header.
# @param _name			The name of the library
# @param _major			Major version number
# @param _minor			Minor version number
# @param _patch			Patch version number
function(CREATE_VERSION_HEADER _name _major _minor _patch)
	set(IN_NAME ${_name} CACHE STRING "" FORCE)
	set(IN_MAJOR ${_major} CACHE STRING "" FORCE)
	set(IN_MINOR ${_minor} CACHE STRING "" FORCE)
	set(IN_PATCH ${_patch} CACHE STRING "" FORCE)
	file(REMOVE "${CMAKE_CURRENT_SOURCE_DIR}/version.h")
	if (${ARGC} GREATER 4)
		foreach(version_file_path IN LISTS ARGN)
			if (EXISTS "${version_file_path}")
				set(VERSION_IN_PATH "${version_file_path}")
				break()
			endif()
		endforeach()
	elseif(EXISTS "${CMAKE_SOURCE_DIR}/cmake/307modules/version.h.in")
		set(VERSION_IN_PATH "${CMAKE_SOURCE_DIR}/cmake/307modules/input/version.h.in")
	elseif(EXISTS "${CMAKE_SOURCE_DIR}/307modules/input/version.h.in")
		set(VERSION_IN_PATH "${CMAKE_SOURCE_DIR}/307modules/input/version.h.in")
	elseif(EXISTS "${CMAKE_SOURCE_DIR}/cmake/modules/version.h.in")
		set(VERSION_IN_PATH "${CMAKE_SOURCE_DIR}/cmake/modules/version.h.in")
	elseif(EXISTS "${CMAKE_SOURCE_DIR}/cmake/input/version.h.in")
		set(VERSION_IN_PATH "${CMAKE_SOURCE_DIR}/cmake/input/version.h.in")
	else()
		message(FATAL_ERROR "AutoVersion.cmake cannot locate a valid version.h.in template file! You can specify the path to the target file as an additional parameter to CREATE_VERSION_HEADER if it isn't located at the default path.")
	endif()
	configure_file("${VERSION_IN_PATH}" "${CMAKE_CURRENT_SOURCE_DIR}/version.h")
	# Unset temporary cache variables
	unset(IN_NAME CACHE)
	unset(IN_MAJOR CACHE)
	unset(IN_MINOR CACHE)
	unset(IN_PATCH CACHE)
endfunction()
