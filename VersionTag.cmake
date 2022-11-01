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
		"[0-9]+|[A-Za-z]+"
		_groups
		"${_tag}"
	)
	list(LENGTH ARGN _argn_length)
	math(EXPR index "0")
	foreach(_cap IN LISTS _groups)
		if(${index} LESS ${ARGC} AND ${index} LESS ${_argn_length})
			list(GET ARGN ${index} _arg)
			set(${_arg} "${_cap}")
			set(${_arg} "${${_arg}}" CACHE INTERNAL "Version Tag Capture Group ${index}")
			message(STATUS "PARSE_TAG():  ${_arg} = \"${${_arg}}\"  [${index}]")
		endif()
		math(EXPR index "${index}+1")
	endforeach()
endfunction()

# GET_VERSION_TAG(<PROJECT>)
#	Retrieve the "${PROJECT}_VERSION" environment variable and parse it into a usable version number.
#   Output is set via CACHE INTERNAL and is available anywhere.
# PARAMETERS:
#	REPOSITORY		The repository directory to use.
#	PROJECT			The prefix name to use for all output variables.
# OUTPUTS:
#	${PROJECT}_VERSION				3-part semver version number.
#	${PROJECT}_VERSION_MAJOR		The 1st part of the semver tag.
#	${PROJECT}_VERSION_MINOR		The 2nd part of the semver tag.
#	${PROJECT}_VERSION_PATCH		The 3rd part of the semver tag.
#	${PROJECT}_VERSION_EXTRA0		Extra parts of the semver tag.
#	${PROJECT}_VERSION_EXTRA...		Extra parts of the semver tag.
#	${PROJECT}_VERSION_EXTRA9		Extra parts of the semver tag.
#	${PROJECT}_VERSION_EXTENDED		The exact tag retrieved from git.
function(GET_VERSION_ENV _project_name)
	if (DEFINED "ENV{${_project_name}_VERSION}")
		set(_value "$ENV{${_project_name}_VERSION}")

		message(STATUS "GET_VERSION_ENV():  \"${_project_name}_VERSION\" = \"${_value}\"")

		PARSE_TAG(
			"${_value}"
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
		set( # Set the CMake-compatible version number
			"${_project_name}_VERSION" 
			"${${_project_name}_VERSION_MAJOR}.${${_project_name}_VERSION_MINOR}.${${_project_name}_VERSION_PATCH}" 
			CACHE INTERNAL
			"${_project_name} version number parsed from git repository located at \"${_repository_dir}\"."
		)
	else()
		message(WARNING "GET_VERSION_ENV():  No environment variable named '${_project_name}_VERSION' was found, a default version number is not available!")
	endif()
endfunction()

# GET_VERSION_TAG(<REPOSITORY> <PROJECT>)
#	Retrieve the latest git tag and parse it into a usable version number.
# PARAMETERS:
#	REPOSITORY		The repository directory to use.
#	PROJECT			The prefix name to use for all output variables.
# OUTPUTS:
#	${PROJECT}_VERSION				3-part semver version number.
#	${PROJECT}_VERSION_MAJOR		The 1st part of the semver tag.
#	${PROJECT}_VERSION_MINOR		The 2nd part of the semver tag.
#	${PROJECT}_VERSION_PATCH		The 3rd part of the semver tag.
#	${PROJECT}_VERSION_EXTRA0		Extra parts of the semver tag.
#	${PROJECT}_VERSION_EXTRA...		Extra parts of the semver tag.
#	${PROJECT}_VERSION_EXTRA9		Extra parts of the semver tag.
#	${PROJECT}_VERSION_EXTENDED		The exact tag retrieved from git.
function(GET_VERSION_TAG _repository_dir _project_name)
	message(STATUS "GET_VERSION_TAG():  REPOSITORY = \"${_repository_dir}\"")
	message(STATUS "GET_VERSION_TAG():  PROJECT    = \"${_project_name}\"")

	IS_REPOSITORY("${_repository_dir}" _is_repo)
	if (_is_repo) # if the target dir is a git repository:
		GET_TAG_FROM("${_repository_dir}" _tag)
		if ("${_tag}" STREQUAL "")
			message(WARNING "GET_VERSION_TAG():  Using fallback version number from environment: \"$ENV{${_project_name}_VERSION}\"")
			set(_tag "$ENV{${_project_name}_VERSION}" CACHE INTERNAL "Fallback version number")
		endif()
		set("${_project_name}_VERSION_EXTENDED" "${_tag}" CACHE INTERNAL "The exact tag retrieved from the git repository.")
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

		# Valid version number:
		if("${${_project_name}_VERSION_MAJOR}" MATCHES "[0-9]+" AND "${${_project_name}_VERSION_MINOR}" MATCHES "[0-9]+" AND "${${_project_name}_VERSION_PATCH}" MATCHES "[0-9]+")
			set( # Set the CMake-compatible version number
				"${_project_name}_VERSION" 
				"${${_project_name}_VERSION_MAJOR}.${${_project_name}_VERSION_MINOR}.${${_project_name}_VERSION_PATCH}" 
				CACHE INTERNAL
				"${_project_name} version number parsed from git repository located at \"${_repository_dir}\"."
			)

		# Invalid version number, BUT environment variable IS defined:
		elseif(DEFINED "ENV{${_project_name}_VERSION}")
			message(WARNING "GET_VERSION_TAG():  Parsing git tag \"${_tag}\" failed to produce a usable version number!")
			message(STATUS "GET_VERSION_TAG():  Falling back to environment variable \"${_project_name}_VERSION\"")
			GET_VERSION_ENV("${_project_name}")

		# Invalid version number, environment variable is NOT defined:
		else()
			message(
				FATAL_ERROR
				"                  ########### FATAL ERROR ###########\n"
				" Function:        GET_VERSION_TAG()\n"
				" Reason:          Failed to retrieve a valid 3-part SEMVER version number from GIT TAG: \"${_tag}\"!\n"
				" Repository Dir:  \"${_repository_dir}\"\n"
				"                  You can resolve this by specifying a default version number-\n"
				"                  -as an environment variable named \"${_project_name}_VERSION\""
			)
		endif()

		message(STATUS "GET_VERSION_TAG():  \$\{${_project_name}_VERSION\} = ${${_project_name}_VERSION}")

	# This is NOT a git repository, but a default version number is available:
	elseif(DEFINED "ENV{${_project_name}_VERSION}")
		message(STATUS "GET_VERSION_TAG():  Falling back to environment variable \"${_project_name}_VERSION\"")
		GET_VERSION_ENV("${_project_name}")

	# This is NOT a git repository & no default version is set:
	else()
		message(
			FATAL_ERROR
			"                  ########### FATAL ERROR ###########\n"
			" Function:        GET_VERSION_TAG()\n"
			" Reason:          Failed to retrieve a valid 3-part SEMVER version number from GIT TAG: \"${_tag}\"!\n"
			" Repository Dir:  \"${_repository_dir}\"\n"
			"                  You can resolve this by specifying a default version number-\n"
			"                  -as an environment variable named \"${_project_name}_VERSION\""
		)

	endif()
endfunction()


# MAKE_VERSION_HEADER_LONG(<HEADER_FILE> <PROJECT_NAME> <MAJOR> <MINOR> <PATCH> <EXTRA>)
#	This is an alternative to the MAKE_VERSION_HEADER function that accepts the version number as individual components.
#	
#	_out_header			The filepath of the header file that will be created. Any current file located at this path will be deleted.
#	_project_name		This is the prefix to give each preprocessor definition
#	IN_MAJOR			Major Version
#	IN_MINOR			Minor Version
#	IN_PATCH			Patch Version
#	IN_EXTRA			Extra Version Number Components, such as revision or pre-release number.
function(MAKE_VERSION_HEADER_LONG _out_header _project_name IN_MAJOR IN_MINOR IN_PATCH IN_EXTRA)
	message(STATUS
		" MAKE_VERSION_HEADER_LONG():  _out_header   = \"${_out_header}\"\n"
		" MAKE_VERSION_HEADER_LONG():  _project_name = \"${_project_name}\"\n"
		" MAKE_VERSION_HEADER_LONG():  IN_MAJOR      = \"${IN_MAJOR}\"\n"
		" MAKE_VERSION_HEADER_LONG():  IN_MINOR      = \"${IN_MINOR}\"\n"
		" MAKE_VERSION_HEADER_LONG():  IN_PATCH      = \"${IN_PATCH}\"\n"
		" MAKE_VERSION_HEADER_LONG():  IN_EXTRA      = \"${IN_EXTRA}\""
	)
	
	# Set the separator character if necessary
	if("${IN_EXTRA}" STREQUAL "")
		set(SEP_EXTRA "")
	else()
		set(SEP_EXTRA "-")
	endif()

	# Remove the current version header if it exists
	file(REMOVE "${_out_header}")

	# Use configure_file to create the output file from a template
	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/version.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)
endfunction()

# MAKE_VERSION_HEADER(<HEADER_FILE> <PROJECT_NAME> <VERSION>)
#	Create a header file with preprocessor definitions for the current project version for use in code.
# PARAMETERS:
#	HEADER_FILE		The path & name of the output file, including filename & extensions.
#	PROJECT_NAME	The name of the current project, which is used as a prefix.
#	VERSION			The full CMake-compatible project version. (Usually ${PROJECT_NAME}_VERSION)
# OVERRIDE WARNINGS:  (This function will delete the following cache variables if they are set):
#	IN_PROJECT | IN_VERSION | IN_MAJOR | IN_MINOR | IN_PATCH | IN_EXTRA
function(MAKE_VERSION_HEADER _out_header _project_name _version)
	message(STATUS
		" MAKE_VERSION_HEADER():  _out_header   = \"${_out_header}\"\n"
		" MAKE_VERSION_HEADER():  _project_name = \"${_project_name}\"\n"
		" MAKE_VERSION_HEADER():  _version      = \"${_version}\""
	)
	set(IN_PROJECT "${_project_name}" CACHE INTERNAL "")

	# Parse the given version number
	PARSE_TAG("${_version}"
		IN_MAJOR
		IN_MINOR
		IN_PATCH
	)
	set(IN_EXTENDED "${_version}")

	# Remove the current version header if it exists
	file(REMOVE "${_out_header}")

	# Use configure_file to create the output file from a template
	# NOTE:
	#  The configure_file function creates missing parent directories, so don't do that externally!
	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/version.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)
endfunction()
