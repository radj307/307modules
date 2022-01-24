###########################################
#              Autoversion 2              #
###########################################
cmake_minimum_required(VERSION 3.20)

set(AUTOVERSION_2_REGEX_VALIDTAGCHARACTERS "[0-9A-Za-z]+" CACHE STRING "Regular expression used by the AV2 functions to retrieve all contiguous words/numbers from the current git tag. This should include letters.")

#### GET_GIT_TAG(<REPO_DIR> <OUT_VAR>) ####
# @brief				Call "git describe --tags" from the given directory, and set ${_out_var} to the result.
# @param _working_dir	The root repository directory to call the git describe command in.
# @param _out_var		The name of a variable to set with the result of the command.
macro(AV2_GET_GIT_TAG _working_dir _out_var)
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

#### IS_GIT_REPOSITORY(<OUT_BOOL> <REPOSITORY_ROOT_DIRECTORY>) ####
# @brief	Checks if the given directory contains a ".git" subdirectory.
function(AV2_IS_GIT_REPOSITORY _out_var _path)
	if (EXISTS "${_path}/.git")
		set(${_out_var} TRUE CACHE BOOL "" FORCE)
	else()
		set(${_out_var} FALSE CACHE BOOL "" FORCE)
	endif()
	message(STATUS "IS_GIT_REPOSITORY: ${${_out_var}}")
endfunction()

#### AV2_PARSE_TAG(<OUT_LIST> <GIT_TAG>) ####
# @brief	Retrieve all contiguous valid C-locale word characters as a list of strings.
macro(AV2_PARSE_TAG _out_list _tag)
	message(STATUS "AV2_PARSE_TAG():  \$\{_tag\} = \"${_tag}\"")
	if ("${_tag}" STREQUAL "")
		message(FATAL_ERROR "AV2_PARSE_TAG() [ERROR]:  Received empty git tag!")
	endif()
	string(REGEX MATCHALL "${AUTOVERSION_2_REGEX_VALIDTAGCHARACTERS}" "${_out_list}" "${_tag}")
	message(STATUS "AV2_PARSE_TAG():  \$\{_out_list\} = \"${${_out_list}}\"")
	set("${_out_list}" "${${_out_list}}" PARENT_SCOPE)
endmacro()

#### AV2_GET_VERSION(<ROOT_REPO_DIR> <OUT_VERSION> [OUT_GROUP1] [OUT_GROUP2] ...) ####
function(AV2_GET_VERSION _working_dir _out_fullversion)
	AV2_GET_GIT_TAG("${_working_dir}" _tmp)
	
	message(STATUS "AV2_GET_VERSION():  Git tag = \"${_tmp}\"")

	AV2_PARSE_TAG(_split_tag "${_tmp}")

	message(STATUS "AV2_GET_VERSION():  Split tag = \"${_split_tag}\"")

	# Remove all alpha characters
	string(REGEX REPLACE "[\\-\\.]*[A-Za-z]+[\\-\\.]*" "" _tmp ${_tmp})
	string(REGEX REPLACE "(^[0-9]+[\\-\\.][0-9]+[\\-\\.][0-9]+[\\-\\. ])(.+)" "\\1" _tmp "${_tmp}")

	list(GET _split_tag 0 _fst)
	list(GET _split_tag 1 _snd)
	list(GET _split_tag 2 _thr)


	#set("${_out_fullversion}" "${_tmp}")
	set("${_out_fullversion}" "${_fst}.${_snd}.${_thr}")
	set("${_out_fullversion}" "${${_out_fullversion}}" CACHE STRING "" FORCE)

	message(STATUS "AV2_GET_VERSION():  \$\{${_out_fullversion}\} = \"${${_out_fullversion}}\"")

	# Return early if there aren't any additional args
	if (${ARGC} EQUAL 2)
		return()
	endif()

	# Iterate through all additional arguments
	math(EXPR _i "0")
	foreach(_out_group IN LISTS ARGN)
		list(GET _split_tag ${_i} _tag_group)
		set("${_out_group}" "${_tag_group}" CACHE STRING "" FORCE)
		math(EXPR _i "${_i} + 1")
	endforeach()
endfunction()


#### GET_VERSION_2(<PROJECT_PREFIX> <ROOT_REPO_DIR> [GROUP1_SUFFIX] [GROUP2_SUFFIX] ...) ####
# @brief					Creates version variables for the given project name.
# @param _project_prefix	The prefix to insert before each version variable name.
# @param _repository_path	The root directory of the target repository.
# @param ...				Suffixes to append to: "${_project_prefix}_VERSION"
function(GET_VERSION_2 _project_prefix _repository_path)
	# Check if this is a git repository
	AV2_IS_GIT_REPOSITORY(USE_AUTOVERSION ${_repository_path})

	# If this is a git repository
	if (USE_AUTOVERSION)
		include(PrependEach)
		message(STATUS "GET_VERSION_2():  \$\{ARGN\} = \"${ARGN}\"")
		PREPEND_EACH(_version_groups "${ARGN}" "${_project_prefix}_VERSION_")
		set(_version_groups "${_version_groups}" PARENT_SCOPE)
		AV2_GET_VERSION("${_repository_path}" "${_project_prefix}_VERSION" ${_version_groups})
		if (${_project_prefix}_VERSION STREQUAL "")
			set(_use_env TRUE)
			message(STATUS "GET_VERSION_2():  Version string is blank, falling back to environment variable.")
		else()
			set(_use_env FALSE)
		endif()
	endif()

	# If this isn't a git repository, or if the version variable is empty
	if(NOT USE_AUTOVERSION OR _use_env)
		set(_env_var_name "${_project_prefix}_VERSION")
		message(WARNING
			" > AutoVersion2 couldn't find a usable git tag, and is falling back to AutoVersion1 behaviour!\n"
			" Attempting to fallback to environment variable: \"${_env_var_name}\"\n"
		)
		set(${_version_prefix}_VERSION "$ENV{${_env_var_name}}" PARENT_SCOPE)
		AV_PARSE_TAG("${${_env_var_name}}" ${_env_var_name}_MAJOR ${_env_var_name}_MINOR ${_env_var_name}_PATCH)
	endif()
endfunction()


#### CREATE_VERSION_HEADER(<FILEPATH> <MAJOR> <MINOR> <PATCH>) ####
# @brief				Creates a copy of the version.h.in header in the caller's source directory.
#\n						You can optionally include the path to the input version header.
# @param _out_header	The name & location of the output file.
# @param _major			Major version number
# @param _minor			Minor version number
# @param _patch			Patch version number
function(CREATE_VERSION_HEADER_2 _out_header _PROJECT _MAJOR _MINOR _PATCH _EXTRA)
	# Remove previous
	file(REMOVE "${_out_header}")

	message(STATUS "CREATE_VERSION_HEADER_2():  Project = \"${_PROJECT}\"")
	message(STATUS "CREATE_VERSION_HEADER_2():  Major = \"${_MAJOR}\"")
	message(STATUS "CREATE_VERSION_HEADER_2():  Minor = \"${_MINOR}\"")
	message(STATUS "CREATE_VERSION_HEADER_2():  Patch = \"${_PATCH}\"")
	message(STATUS "CREATE_VERSION_HEADER_2():  Extra = \"${_EXTRA}\"")

	set(_PROJECT "${_PROJECT}" CACHE STRING "" FORCE)
	set(_MAJOR "${_MAJOR}" CACHE STRING "" FORCE)
	set(_MINOR "${_MINOR}" CACHE STRING "" FORCE)
	set(_PATCH "${_PATCH}" CACHE STRING "" FORCE)
	set(_EXTRA "${_EXTRA}" CACHE STRING "" FORCE)

	# Configure file
	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/version.h_2.in" "${_out_header}")
endfunction()