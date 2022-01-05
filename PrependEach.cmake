# 307modules/PrependEach.cmake
cmake_minimum_required(VERSION 3.15)

#### PREPEND_EACH ####
# @brief			Prepend each element in a list with a given string.
#					Most useful for converting a list of relative paths to absolute paths. (target_sources)
# @param _out_list	Output List Name
# @param _in_list	Input List
# @param _prepend	The string to prepend to each element in ${_in_list}. (FOR FILEPATHS, USE A TRAILING SLASH!)
function(PREPEND_EACH _out_list _in_list _prepend)
	set(tmp_list "")
	foreach(_target_path IN LISTS ${_in_list})
		list(APPEND tmp_list "${_prepend}${_target_path}")
	endforeach()
	set(${_out_list} "${tmp_list}" CACHE STRING "" FORCE)
endfunction()
