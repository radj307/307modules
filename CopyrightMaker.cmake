# 307modules/CopyrightMaker.cmake
cmake_minimum_required(VERSION 3.22)


# MAKE_COPYRIGHT_NOTICE(<OUT_VAR> <AUTHOR> <YEAR>)
#	Sets the specified variable to a full copyright notice created from the given parameters.
# PARAMETERS:
#	_out		The name of the output variable
#	_author		The name of the copyright holder
#	_year		The year that the project was last updated
function(MAKE_COPYRIGHT_NOTICE _out _author _year)
	set("${_out}" "Copyright © ${_year} by ${_author}" PARENT_SCOPE)
endfunction()

function(MAKE_COPYRIGHT_HEADER_FROM_NOTICE _out_header IN_NOTICE)
	message(STATUS
		" MAKE_COPYRIGHT_HEADER_FROM_NOTICE():	_out_header			= \"${_out_header}\"\n"
		" MAKE_COPYRIGHT_HEADER_FROM_NOTICE():	Copyright Notice	= \"${IN_NOTICE}\""
	)

	file(REMOVE "${_out_header}")
	
	# Create any missing parent directories:
	cmake_path(GET _out_header PARENT_PATH _make_version_header_out_header_directory)
	file(MAKE_DIRECTORY "${_make_version_header_out_header_directory}")

	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/copyright.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)
endfunction()

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
	
	MAKE_COPYRIGHT_NOTICE(IN_NOTICE "${_copyright_holder}" "${_copyright_year}")
	
	message(STATUS
		" MAKE_COPYRIGHT_HEADER():	_out_header			= \"${_out_header}\"\n"
		" MAKE_COPYRIGHT_HEADER():	_project_name		= \"${_project_name}\"\n"
		" MAKE_COPYRIGHT_HEADER():	_copyright_year		= \"${_copyright_year}\"\n"
		" MAKE_COPYRIGHT_HEADER():	_copyright_holder	= \"${_copyright_holder}\"\n"
		" MAKE_COPYRIGHT_HEADER():	Copyright Notice	= \"${IN_NOTICE}\""
	)

	file(REMOVE "${_out_header}")
	
	# Create any missing parent directories:
	cmake_path(GET _out_header PARENT_PATH _make_version_header_out_header_directory)
	file(MAKE_DIRECTORY "${_make_version_header_out_header_directory}")

	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/copyright.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)
endfunction()

