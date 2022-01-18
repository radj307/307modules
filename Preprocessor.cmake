# 307modules/Preprocessor.cmake
cmake_minimum_required(VERSION 3.20)

macro(UNSET_CONFIGURE_INPUTS)
	unset(IN_NAME CACHE)
	unset(IN_VALUE CACHE)
endmacro()

macro(CONFIGURE_STRING _out_var _string)
	string(CONFIGURE "${_string}" "${_out_var}" ${ARGN})
endmacro()

function(MAKE_HEADER _name)
	# Calculate the maximum index
	math(EXPR _max "${ARGC} - 1")

	if (${_max} EQUAL 0)
		message(FATAL_ERROR " MAKE_HEADER:  No valid arguments!")
	endif()

	# Create file if it doesn't exist
	file(TOUCH "${_name}")
	message(STATUS " MAKE_HEADER:  Created \"${_name}\"")

	# Set the definition string for configure_string
	set(_definition "\n#define @IN_NAME@ @IN_VALUE@\n")
	message(STATUS " MAKE_HEADER:  Using definition string: \"${_definition}\"")

	message(STATUS " MAKE_HEADER:  Iterating through arguments 0 to ${_max}")

	foreach (_index RANGE 0 ${_max} 0)
		# Get the next index
		math(EXPR _index_next "${_index} + 1")
		if (${_index} GREATER_EQUAL ${_max})
			break()
		elseif(${_index_next} GREATER_EQUAL ${_max})
			list(GET ARGN ${_index} _n)
			set(IN_NAME "${_n}" CACHE STRING "" FORCE)
			set(IN_VALUE "" CACHE STRING "" FORCE)
			CONFIGURE_STRING(_content "${_definition}" @ONLY)
			
			message(STATUS
				" Appending \"${_content}\" to the header."
			)

			file(APPEND "${_name}" "${_content}")
			return()
		endif()

		# Get the strings at the current index & next index
		list(GET ARGN ${_index} _n)
		list(GET ARGN ${_index_next} _v)

		# Set the input variables
		set(IN_NAME "${_n}" CACHE STRING "" FORCE)
		set(IN_VALUE "${_v}" CACHE STRING "" FORCE)

		# Configure the definition string with the input variables
		CONFIGURE_STRING(_content "${_definition}" @ONLY)
		
		message(STATUS
			" Appending \"${_content}\" to the header."
		)

		# Append the configured string to the file
		file(APPEND "${_name}" "${_content}")
		
		# Cleanup the input variables
		UNSET_CONFIGURE_INPUTS()
	endforeach()
endfunction()
