# 307modules/PrependEach.cmake
cmake_minimum_required(VERSION 3.15)

#### STRIP_STRING(<STRING>) ####
# @brief	Inline function that removes trailing newlines and leading/trailing spaces.
macro(STRIP_STRING _string)
	message(STATUS "STRIP_STRING():  \$\{_string\} = \"${_string}\"")
	string(REGEX REPLACE "\n$" "" _string "${_string}")
	string(STRIP "${_string}" _string)
	string(REGEX REPLACE "\n$" "" _string "${_string}")
	message(STATUS "STRIP_STRING():  \$\{_string\} = \"${_string}\"")
endmacro()

#### PREPEND_EACH(<OUT_LIST_NAME> <IN_LIST> <PREPEND_STRING>) ####
# @brief			Prepend each element in a list with a given string.
#					Most useful for converting a list of relative paths to absolute paths. (target_sources)
# @param _out_list	Output List Name
# @param _in_list	Input List
# @param _prepend	The string to prepend to each element in ${_in_list}. (FOR FILEPATHS, USE A TRAILING SLASH!)
function(PREPEND_EACH _out _in_list _prepend)
	set(${_out})
	message(STATUS "PREPEND_EACH():  \$\{_in_list\} = \"${_in_list}\"")
	foreach(_target_path IN LISTS _in_list)
		set(_tmp "${_prepend}${_target_path}")
		list(APPEND ${_out} "${_tmp}")
		message(STATUS "PREPEND_EACH():  Appended \"${_tmp}\" to \"\$\{${_out}\}\".")
	endforeach()
	list(JOIN "${tmp_list}" ";" _tmp)
	set("${_out}" ${_tmp} PARENT_SCOPE)
	message(STATUS "PREPEND_EACH():  \$\{_out\} = \"${${_out}}\"")
endfunction()
