# 307modules/OptionalArgs.cmake
cmake_minimum_required(VERSION 3.15)

#### GET_ARG(<list> <index> <out_var> [TOLOWER|TOUPPER]) ####
# @brief			Retrieve an optional argument from a list, and optionally convert it to lowercase or uppercase.
#					To convert the argument's case, include "TOLOWER" or "TOUPPER" as the 4th argument.
# @param _list		Optional Argument List. (Must be passed with ${})
# @param _index		Index of the argument to retrieve.
# @param _out_var	Output variable name.
function(GET_ARG _list _index _out_var)
	# Get the target argument from the list
	list(GET _list "${_index}" arg_raw)

	# Check for additional arguments
	if (${ARGC} GREATER 3)
		# get & string-compare additional arguments to "tolower"/"toupper" (case-insensitive)
		list(GET ARGN 0 optarg_raw)
		string(TOUPPER "${optarg_raw}" optarg)
		if ("${optarg}" STREQUAL "TOLOWER")
			string(TOLOWER "${arg_raw}" arg)
		elseif("${optarg}" STREQUAL "TOUPPER")
			string(TOUPPER "${arg_raw}" arg)
		else()
			message(WARNING "Invalid optional argument for GET_ARG: \"${optarg_raw}\" Valid arguments are [TOLOWER|TOUPPER]")
			set(arg "${arg_raw}")
		endif()
		# Set output to formatted arg
		set(${_out_var} "${arg}" CACHE STRING "" FORCE)
		return()
	endif()

	# Set output to raw arg
	set(${_out_var} "${arg_raw}" CACHE STRING "" FORCE)
endfunction()
