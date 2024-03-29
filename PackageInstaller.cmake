# 307lib/cmake/modules/PackageInstaller.cmake
# Contains functions for creating packaging files & installing libraries.
cmake_minimum_required(VERSION 3.19)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)
include(GenerateExportHeader)

#### GENERATE_PACKAGING ####
# @brief				Generates an export header for the target library, and creates a Config.cmake file. Must be called from the 
# @param _target		The name of the target library. This must be a direct subdirectory of CMAKE_SOURCE_DIR, and the name of the library target.
function(GENERATE_PACKAGING _target)
	# Export Targets
	file(REMOVE "${CMAKE_CURRENT_BINARY_DIR}/export.h") # remove any existing export header
	generate_export_header(${_target} EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/export.h")
	target_compile_definitions(${_target} PUBLIC
		"$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:${_target}_STATIC_DEFINE>"
	)
	target_include_directories(${_target} PUBLIC
		"$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>"
	)
	# Create <name>Config.cmake from the template
	set(PACKAGING_TARGET_NAME "${_target}" CACHE STRING "Temporary variable used by the GENERATE_PACKAGING function." FORCE)
	set(PACKAGING_TARGET_CONF "${CMAKE_CURRENT_BINARY_DIR}/${_target}Config.cmake")

	file(REMOVE ${PACKAGING_TARGET_CONF}) # remove any existing package config

	configure_file("${CMAKE_CURRENT_FUNCTION_LIST_DIR}/input/libConfig.cmake.in" "${PACKAGING_TARGET_CONF}" @ONLY)
	message(STATUS "Successfully generated ${PACKAGING_TARGET_CONF}")
	unset(PACKAGING_TARGET_NAME CACHE)
endfunction()

#### WRITE_VERSION_FILE() ####
# @brief				Creates a ConfigVersion file for the given library name.
# @param _target		The name of the target library. This must be a direct subdirectory of CMAKE_SOURCE_DIR, and the name of the library target.
# @param _compat_mode	The compatibility mode to use in the version file.
function(WRITE_VERSION_FILE _target)
	if (${ARGC} GREATER 1)
		list(GET ARGN 0 compat_mode)
	else()
		set(compat_mode "SameMajorVersion")
	endif()
	write_basic_package_version_file("${CMAKE_CURRENT_BINARY_DIR}/${_target}ConfigVersion.cmake" COMPATIBILITY ${compat_mode})
endfunction()

#### CREATE_PACKAGE ####
# @brief				Calls the GENERATE_PACKAGING & WRITE_VERSION_FILE functions.
# @param _target		The name of the target library. This must be a direct subdirectory of CMAKE_SOURCE_DIR, and the name of the library target.
# @param _compat_mode	The compatibility mode to use in the version file.
function(CREATE_PACKAGE _target _compat_mode)
	GENERATE_PACKAGING(${_target})
	WRITE_VERSION_FILE(${_target} ${_compat_mode})
endfunction()

#### INSTALL_PACKAGE(<target> [<NAMESPACE> <ns>] [[GENERATE] [COMPAT_MODE]]) ####
# @brief				Creates an installation target for the specified package.
#						If "GENERATE" is included as the 2nd argument, the function will call the `CREATE_PACKAGE` function first.
#						If "GENERATE" was included, the package compatibility mode can be specified as the 3rd argument. If left blank, "SameMajorVersion" is used.
# @param _target		The name of the target library. This must be a direct subdirectory of CMAKE_SOURCE_DIR, and the name of the library target.
# @param ns				The name of the namespace to export with the target. This MUST end with '::' if you want the namespace specifier to be included!
function(INSTALL_PACKAGE _target)
	set(options GENERATE)
	set(oneValueArgs NAMESPACE COMPAT_MODE)
	cmake_parse_arguments(PARSE_ARGV 1 INSTALL_PACKAGE "${options}" "${oneValueArgs}" "")

	if (INSTALL_PACKAGE_GENERATE)
		if ("${INSTALL_PACKAGE_COMPAT_MODE}" STREQUAL "")
			set(INSTALL_PACKAGE_COMPAT_MODE "SameMajorVersion")
		endif()

		CREATE_PACKAGE("${_target}" "${INSTALL_PACKAGE_COMPAT_MODE}")
	endif()

	# Set "${_target}_INSTALL_DIR" to the target installation directory
	set("${_target}_CONFIG_INSTALL_DIR" "${CMAKE_INSTALL_LIBDIR}/cmake/${_target}" CACHE STRING "Path to ${_target} packaging configs.")

	message(STATUS "Installing ${_target}")
		
	install( # Install targets to CMAKE_INSTALL_INCLUDEDIR
		TARGETS ${_target}
		EXPORT "${_target}_Targets"
		RUNTIME COMPONENT "${_target}_Runtime"
		LIBRARY COMPONENT "${_target}_Runtime"
		NAMELINK_COMPONENT "${_target}_Development"
		ARCHIVE COMPONENT "${_target}_Development"
		INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
	)

	# Install package config files
	install(
		FILES # If "${_target}ConfigVersion.cmake" exists, install it and "${_target}Config.cmake", else install only "${_target}Config.cmake".
			"$<IF:$<BOOL:EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${_target}ConfigVersion.cmake>,${CMAKE_CURRENT_BINARY_DIR}/${_target}Config.cmake;${CMAKE_CURRENT_BINARY_DIR}/${_target}ConfigVersion.cmake,${CMAKE_CURRENT_BINARY_DIR}/${_target}Config.cmake>"
		DESTINATION "${${_target}_CONFIG_INSTALL_DIR}"
		COMPONENT "${_target}_Development"
	)

	# Install associated include directory
	install(
		DIRECTORY "include/"
		TYPE INCLUDE
		COMPONENT "${_target}_Development"
	)

	# Install the library targets.
	install(
		EXPORT "${_target}_Targets"
		DESTINATION "${${_target}_CONFIG_INSTALL_DIR}"
		NAMESPACE "${INSTALL_PACKAGE_NAMESPACE}"
		FILE "${_target}-targets.cmake"
		COMPONENT "${_target}_Development"
	)

	# Set the <name>_ROOT environment variable
	set(ENV{${_target}_ROOT} "${${_target}_CONFIG_INSTALL_DIR}")
endfunction()

function(INSTALL_EXECUTABLE _target _destination)
	message(STATUS 
		" INSTALL_EXECUTABLE():  Created installation target successfully."
	    "   Target Executable:  \"${_target}\""
		"   Target Destination: \"${_destination}\""
	)
	install(
		TARGETS ${_target}
		RUNTIME
		DESTINATION "${_destination}"
	)
endfunction()
