# 307modules/CopyrightMaker.cmake
cmake_minimum_required(VERSION 3.22)

# GET_CURRENT_YEAR(<OUT_VAR>)
#   Gets the current year by calling string(TIMESTAMP ...).
# PARAMETERS:
#   _out			The name of the output variable.
macro(GET_CURRENT_YEAR _out)
	string(TIMESTAMP "${_out}" "%Y")
endmacro()

# MAKE_COPYRIGHT_NOTICE_WITH_PREFIX(<OUT_VAR> <PREFIX> <AUTHOR> [YEAR])
#   Creates a copyright notice with the specified parameters.
# PARAMETERS:
#   _out			The name of the output variable
#   _prefix			The prefix string to prepend to the notice.
#                    Usually, this would be "Copyright"
#   _author			The name(s) of the copyright holder(s)
#   _year			The year that the copyrighted work was released.
#					 If this isn't specified, the current year is used.
function(MAKE_COPYRIGHT_NOTICE_WITH_PREFIX _out _prefix _author)
	# Get the year
	list(LENGTH ARGN _argn_length)
	if (${_argn_length} EQUAL 0)
		# No year was specified, use the current year
		GET_CURRENT_YEAR(_year)
	elseif(${_argn_length} GREATER_EQUAL 1)
		# A year was explicitly specified
		list(GET ARGN 0 _year)
		if (${_argn_length} GREATER 1)
			math(EXPR _ignoredArgsCount "${_argn_length} - 1")
			message(AUTHOR_WARNING "MAKE_COPYRIGHT_NOTICE_WITH_PREFIX():  Ignoring ${_ignoredArgsCount} extra arguments.")
		endif()
	endif()

	message(STATUS "MAKE_COPYRIGHT_NOTICE_WITH_PREFIX():\n"
		"   _out	= ${_out}\n"
		"   _prefix = \"${_prefix}\"\n"
		"   _author = \"${_author}\"\n"
		"   _year	= \"${_year}\""
	)

	# Format the notice type
	if (NOT "${_prefix}" STREQUAL "")
		if (NOT "${_prefix}" MATCHES ".+ ")
			# Append a space to the notice prefix
			set(_notice_prefix "${_prefix} " CACHE INTERNAL "")
		else()
			# Use the notice prefix as written
			set(_notice_prefix "${_prefix}" CACHE INTERNAL "")
		endif()
	endif()

	set(_notice "${_notice_prefix}© ${_year} by ${_author}" CACHE INTERNAL "")
	set("${_out}" "${_notice}" PARENT_SCOPE)
	message(STATUS "MAKE_COPYRIGHT_NOTICE_WITH_PREFIX():  Created copyright notice: \"${_notice}\"")
endfunction()

# MAKE_COPYRIGHT_NOTICE(<OUT_VAR> <AUTHOR> [YEAR])
#   Creates a copyright notice with the specified parameters.
# PARAMETERS:
#   _out			The name of the output variable
#   _author			The name(s) of the copyright holder(s)
#   _year			The year that the copyrighted work was released.
#					 If this isn't specified, the current year is used.
function(MAKE_COPYRIGHT_NOTICE _out _author)
	# Get the year
	list(LENGTH ARGN _argn_length)
	if (${_argn_length} EQUAL 0)
		# No year was specified, use the current year
		GET_CURRENT_YEAR(_year)
	elseif(${_argn_length} GREATER_EQUAL 1)
		# A year was explicitly specified
		list(GET ARGN 0 _year)
		if (${_argn_length} GREATER 1)
			math(EXPR _ignoredArgsCount "${_argn_length} - 1")
			message(AUTHOR_WARNING "MAKE_COPYRIGHT_NOTICE():  Ignoring ${_ignoredArgsCount} extra arguments.")
		endif()
	endif()

	message(STATUS "MAKE_COPYRIGHT_NOTICE():\n"
		"   _out	= ${_out}\n"
		"   _author = \"${_author}\"\n"
		"   _year	= \"${_year}\""
	)

	set(_notice "Copyright © ${_year} by ${_author}" CACHE INTERNAL "")
	set("${_out}" "${_notice}" PARENT_SCOPE)
	message(STATUS "MAKE_COPYRIGHT_NOTICE:  Created copyright notice: \"${_notice}\"")
endfunction()

# MAKE_COPYLEFT_NOTICE(<OUT_VAR> <AUTHOR> [YEAR])
#   Creates a copyleft notice with the specified parameters.
# PARAMETERS:
#   _out			The name of the output variable
#   _author			The name(s) of the copyright holder(s)
#   _year			The year that the copyrighted work was released.
#					 If this isn't specified, the current year is used.
function(MAKE_COPYLEFT_NOTICE _out _author)
	# Get the year
	list(LENGTH ARGN _argn_length)
	if (${_argn_length} EQUAL 0)
		# No year was specified, use the current year
		GET_CURRENT_YEAR(_year)
	elseif(${_argn_length} GREATER_EQUAL 1)
		# A year was explicitly specified
		list(GET ARGN 0 _year)
		if (${_argn_length} GREATER 1)
			math(EXPR _ignoredArgsCount "${_argn_length} - 1")
			message(AUTHOR_WARNING "MAKE_COPYLEFT_NOTICE():  Ignoring ${_ignoredArgsCount} extra arguments.")
		endif()
	endif()
	
	message(STATUS "MAKE_COPYLEFT_NOTICE():\n"
		"   _out	= ${_out}\n"
		"   _author = \"${_author}\"\n"
		"   _year	= \"${_year}\""
	)
	
	set(_notice "Copyleft ${_year} by ${_author}" CACHE INTERNAL "")
	set("${_out}" "${_notice}" PARENT_SCOPE)
	message(STATUS "MAKE_COPYLEFT_NOTICE:  Created copyleft notice: \"${_notice}\"")
endfunction()

function(MAKE_COPYRIGHT_HEADER_FROM_NOTICE _out_header IN_PROJECT IN_NOTICE)
	message(STATUS "MAKE_COPYRIGHT_HEADER_FROM_NOTICE():\n"
		"   _out_header			= \"${_out_header}\"\n"
		"   Copyright Notice	= \"${IN_NOTICE}\""
	)

	# Remove the file if it already exists
	file(REMOVE "${_out_header}")
	
	# Create any missing parent directories:
	cmake_path(GET _out_header PARENT_PATH _make_copyright_header_out_header_directory)
	file(MAKE_DIRECTORY "${_make_copyright_header_out_header_directory}")

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

	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/copyright_long.h.in" "${_out_header}" USE_SOURCE_PERMISSIONS @ONLY)
endfunction()

