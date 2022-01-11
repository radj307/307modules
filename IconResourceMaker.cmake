# 307modules/IconResourceMaker.cmake
cmake_minimum_required(VERSION 3.15)

function(APPEND_ICON_RESOURCE _rc_file _icon_file)
	include(InputFinder)
	FIND_INPUT_FILE(TEMPLATE_FILE "icon.rc.in" REQUIRED)

	set(IN_ICON_FILE "${_icon_file}" CACHE STRING "" FORCE)
	configure_file("${TEMPLATE_FILE}" "${CMAKE_CURRENT_BINARY_DIR}/icon.rc.tmp" @ONLY)

	include(CatFile)
	CAT_FILE("${_rc_file}" "${CMAKE_CURRENT_BINARY_DIR}/icon.rc.tmp")

	# Cleanup
	unset(IN_ICON_FILE CACHE)
	unset(TEMPLATE_FILE CACHE)
endfunction()

function(CREATE_ICON_RESOURCE _rc_file _icon_file)
	# remove file if it already exists
	file(REMOVE "${_rc_file}")

	# Find the template file
	include(InputFinder)
	FIND_INPUT_FILE(TEMPLATE_FILE "icon.rc.in" REQUIRED)

	# set variables
	set(IN_ICON_FILE "${_icon_file}" CACHE STRING "" FORCE)

	# configure file
	configure_file("${TEMPLATE_FILE}" "${_rc_file}" @ONLY)

	# cleanup
	unset(IN_ICON_FILE CACHE)
	unset(TEMPLATE_FILE CACHE)
endfunction()
