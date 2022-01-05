# 307modules/InputFinder.cmake
cmake_minimum_required(VERSION 3.20)

#### FIND_INPUT_FILE(<OUT_VAR> <FILENAME> [REQUIRED] [Possible-Path-To-Filename...]) ####
# @brief			Find a specified file in the input directory. This is used internally by 307modules to locate input files.
#					You can also include override paths as additional arguments. 
#					(They must contain ${_filename} at the end) 
#					The first one that exists will be returned.
# @param _out_path	Name of the cache variable to store the output path in.
# @param _filename	Name of the file to search for.
function(FIND_INPUT_FILE _out_path _filename)
	# Check additional arguments
	if (${ARGC} GREATER 2)
		# check if the first additional argument is the "REQUIRED" modifier
		list(GET ARGN 0 FST_ARG)					# Get first argument
		string(TOUPPER "${FST_ARG}" FST_ARG_UPPER)	# Convert to uppercase
		if ("${FST_ARG_UPPER}" STREQUAL "REQUIRED")	# Compare to "REQUIRED"
			set(is_required YES)					# Set is_required to true
			list(POP_FRONT ARGN)					# Pop the first argument from the list
		endif()

		# find the first optional argument that contains a filename component equal to ${_filename}, AND that it exists in the filesystem
		foreach(ARG IN LISTS ARGN)
			string(TOUPPER "${ARG}" ARG_UPPER)
			if ("${ARG_UPPER}" STREQUAL "REQUIRED")
				set(is_required ON)
			else()
				cmake_path(GET "${ARG}" FILENAME TARGET_FILENAME_COMPONENT)
				if ("${TARGET_FILENAME_COMPONENT}" STREQUAL "${_filename}" AND EXISTS "${ARG}")
					set(${_out_path} "${ARG}" CACHE STRING "" FORCE)
					return()
				endif()
			endif()
		endforeach()
	endif()
	# Search each directory in the CMAKE_MODULE_PATH list for "input/${_filename}"
	foreach(TARGET_PATH IN LISTS CMAKE_MODULE_PATH)
		if (EXISTS "${TARGET_PATH}/input/${_filename}")
			set(${_out_path} "${TARGET_PATH}/input/${_filename}" CACHE STRING "" FORCE)
			return()
		endif()
	endforeach()
	# If REQUIRED was specified, throw a fatal error if the file wasn't found.
	if (${is_required})
		message(FATAL_ERROR "Failed to locate required input file: ${_filename}!")
	endif()
endfunction()
