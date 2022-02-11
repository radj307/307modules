# 307modules/VersionTag.cmake
# 
# This is the culmination of AutoVersion 1 & 2
cmake_minimum_required(VERSION 3.20)

# GET_TAG_FROM(<DIRECTORY> <OUT>)
#   Retrieve the latest git tag from the specified repository.
# PARAMETERS:
#   _working_dir	(VALUE) Working directory when executing "git describe --tags --abbrev=0".
#	_out			(NAME)  Output variable name (CACHE STRING)
macro(GET_TAG_FROM _working_dir _out)
	execute_process(
		COMMAND
			"git"
			"describe"
			"--tags"
			"--abbrev=0"
		WORKING_DIRECTORY "${_working_dir}"
		OUTPUT_VARIABLE _tmp
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	set("${_out}" "${_tmp}" CACHE STRING "Latest git tag retrieved from \"${_working_dir}\"" FORCE)
	message(STATUS "GET_TAG_FROM():  \$\{${_out}\} = ${${_out}}")
endmacro()

# IS_REPOSITORY(<DIRECTORY> <OUT>)
#   Checks if the given directory is a git repository.
# PARAMETERS:
#   _working_dir	(VALUE) Directory to check.
#   _out			(NAME)  Output variable name. (CACHE BOOL)
macro(IS_REPOSITORY _working_dir _out)
	if (EXISTS "${_working_dir}/.git")
		set("${_out}" TRUE CACHE BOOL "Directory \"${_working_dir}\" is a git repository." FORCE)
	else()
		set("${_out}" FALSE CACHE BOOL "Directory \"${_working_dir}\" is not a git repository." FORCE)
	endif()
	message(STATUS "IS_REPOSITORY():  \$\{${_out}\} = ${${_out}}")
endmacro()

# PARSE_TAG(<TAG> <[OUT_NAMES]...>)
#   Parse a git tag into a list of strings matching the regular expression "[0-9A-Za-z]+".
#	Function will fill as many output variables as possible using regex capture groups.
# PARAMETERS:
#   TAG			(VALUE) Input Tag String.
#   OUT_NAMES	(NAME)	Any number of variable names that correspond to regular expression capture groups.
function(PARSE_TAG _tag)
	message(STATUS "PARSE_TAG():  TAG = \"${_tag}\"")
	string(REGEX MATCHALL
		"[0-9A-Za-z]+"
		_groups
		"${_tag}"
	)
	message(STATUS "_groups = ${_groups}")
	math(EXPR index "0")
	foreach(_cap IN LISTS _groups)
		if(${ARGC} GREATER_EQUAL ${index})
			list(GET ARGN ${index} _arg)
			set(${_arg} "${_cap}")
			set(${_arg} "${${_arg}}" CACHE STRING "Version Tag Capture Group ${index}" FORCE)
			message(STATUS "PARSE_TAG():  ${_arg} = \"${${_arg}}\"  [${index}]")
		endif()
		math(EXPR index "${index}+1")
	endforeach()
endfunction()

# GET_VERSION_TAG(<REPOSITORY> <PROJECT>)
#	Retrieve the latest git tag and parse it into a usable version number.
# PARAMETERS:
#	REPOSITORY		The repository directory to use.
#	PROJECT			The prefix name to use for all output variables.
# OUTPUTS:
#	${PROJECT}_VERSION
#	${PROJECT}_VERSION_MAJOR
#	${PROJECT}_VERSION_MINOR
#	${PROJECT}_VERSION_PATCH
#	${PROJECT}_VERSION_EXTRA0
#	${PROJECT}_VERSION_EXTRA...
#	${PROJECT}_VERSION_EXTRA9
function(GET_VERSION_TAG _repository_dir _project_name)
	message(STATUS "GET_VERSION():  REPOSITORY = \"${_repository_dir}\"")
	message(STATUS "GET_VERSION():  PROJECT    = \"${_project_name}\"")

	IS_REPOSITORY("${_repository_dir}" _is_repo)
	if (_is_repo)
		GET_TAG_FROM("${_repository_dir}" _tag)
		if ("${_tag}" STREQUAL "" AND DEFINED ENV{${_project_name}_VERSION})
			message(WARNING "Using fallback version number from environment: \"$ENV{${_project_name}_VERSION}\"")
			set(_tag "$ENV{${_project_name}_VERSION}" CACHE STRING "Fallback version number" FORCE)
		endif()
		PARSE_TAG(
			"${_tag}"
			"${_project_name}_VERSION_MAJOR"
			"${_project_name}_VERSION_MINOR"
			"${_project_name}_VERSION_PATCH"
			"${_project_name}_VERSION_EXTRA0"
			"${_project_name}_VERSION_EXTRA1"
			"${_project_name}_VERSION_EXTRA2"
			"${_project_name}_VERSION_EXTRA3"
			"${_project_name}_VERSION_EXTRA4"
			"${_project_name}_VERSION_EXTRA5"
			"${_project_name}_VERSION_EXTRA6"
			"${_project_name}_VERSION_EXTRA7"
			"${_project_name}_VERSION_EXTRA8"
			"${_project_name}_VERSION_EXTRA9"
		)
		if ("${${_project_name}_VERSION_MAJOR}" STREQUAL "" OR "${${_project_name}_VERSION_MINOR}" STREQUAL "" OR "${${_project_name}_VERSION_PATCH}" STREQUAL "")
			message(
				FATAL_ERROR
				"               ########### FATAL ERROR ###########\n"
				" Function:     GET_VERSION()\n"
				" Reason:       Failed to retrieve a valid 3-part SEMVER version number!\n"
				" Repository:   \"${_repository_dir}\""
				" Git Tag:      \"${_tag}\""
			)
		endif()
		set( # Set the CMake-compatible version number
			"${_project_name}_VERSION" 
			"${${_project_name}_VERSION_MAJOR}.${${_project_name}_VERSION_MINOR}.${${_project_name}_VERSION_PATCH}" 
			CACHE STRING
			"${_project_name} version number parsed from git repository located at \"${_repository_dir}\"."
			FORCE
		)
		message(STATUS "GET_VERSION():  \$\{${_project_name}_VERSION\} = ${${_project_name}_VERSION}")
		return()
	else()
		if(DEFINED ENV{${_project_name}_VERSION}) # If a fallback version number is available from the environment, use that
			message(WARNING "GET_VERSION():  Directory is not a git repository, using fallback version \"$ENV{${_project_name}_VERSION}\"")
			set("${_project_name}_VERSION" "$ENV{${_project_name}_VERSION}" CACHE STRING "Fallback version number for project \"${_project_name}\"" FORCE)
			return()
		else()
			message(FATAL_ERROR "GET_VERSION():  Directory is not a git repository and no fallback version was set!")
			return()
		endif()
	endif()
endfunction()

# MAKE_VERSION_HEADER(<HEADER_FILE> <PROJECT_NAME> <VERSION>)
#	Create a header file with preprocessor definitions for the current project version for use in code.
# PARAMETERS:
#	HEADER_FILE		The path & name of the output file, including filename & extensions.
#	PROJECT_NAME	The name of the current project, which is used as a prefix.
#	VERSION			The full CMake-compatible project version. (Usually ${PROJECT_NAME}_VERSION)
# OVERRIDE WARNINGS:  (This function will delete the following cache variables if they are set):
#	IN_PROJECT | IN_VERSION | IN_MAJOR | IN_MINOR | IN_PATCH | IN_EXTRA1 | IN_EXTRA2 | IN_EXTRA3 | IN_EXTRA4 | IN_EXTRA5 | IN_EXTRA6 | IN_EXTRA7 | IN_EXTRA8 | IN_EXTRA9
function(MAKE_VERSION_HEADER _out_header _project_name _version)
	set(IN_PROJECT "${_project_name}" CACHE STRING "" FORCE)

	set(IN_VERSION "${_version}" CACHE STRING "" FORCE)
	PARSE_TAG("${_version}" IN_MAJOR IN_MINOR IN_PATCH IN_EXTRA1 IN_EXTRA2 IN_EXTRA3 IN_EXTRA4 IN_EXTRA5 IN_EXTRA6 IN_EXTRA7 IN_EXTRA8 IN_EXTRA9)

	# Remove the current version header if it exists
	file(REMOVE "${_out_header}")

	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/version.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)

	# unset cache variables
	unset(IN_PROJECT CACHE)
	unset(IN_VERSION CACHE)
	unset(IN_MAJOR CACHE)
	unset(IN_MINOR CACHE)
	unset(IN_PATCH CACHE)
	unset(IN_EXTRA1 CACHE)
	unset(IN_EXTRA2 CACHE)
	unset(IN_EXTRA3 CACHE)
	unset(IN_EXTRA4 CACHE)
	unset(IN_EXTRA5 CACHE)
	unset(IN_EXTRA6 CACHE)
	unset(IN_EXTRA7 CACHE)
	unset(IN_EXTRA8 CACHE)
	unset(IN_EXTRA9 CACHE)
endfunction()
