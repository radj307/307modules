# 307modules/VersioninfoMaker.cmake
cmake_minimum_required(VERSION 3.20)

#### CREATE_VERSION_RESOURCE ####
# @brief					Creates a versioninfo.rc file in the given directory.
# @param _working_dir		Directory to place versioninfo.rc in.
# @param _version_major		Major version number
# @param _version_minor		Minor version number
# @param _version_patch		Patch version number
# @param _company_name		Value to fill in for "CompanyName"
# @param _file_description	Value to fill in for "FileDescription"
# @param _internal_name		Value to fill in for "InternalName"
# @param _legal_copyright	Value to fill in for "LegalCopyright"
# @param _original_filename	Value to fill in for "OriginalFilename"
# @param _product_name		Value to fill in for "ProductName"
# 
function(CREATE_VERSION_RESOURCE
	_working_dir 
	# Version Numbers:
	_version_major 
	_version_minor 
	_version_patch 
	# Names/Description/Copyright
	_company_name 
	_file_description
	_internal_name
	_legal_copyright
	_original_filename
	_product_name
)
	# Set input variables
	set(IN_VERSION_MAJOR "${_version_major}" CACHE STRING "" FORCE)
	set(IN_VERSION_MINOR "${_version_minor}" CACHE STRING "" FORCE)
	set(IN_VERSION_PATCH "${_version_patch}" CACHE STRING "" FORCE)
	set(IN_COMPANYNAME "${_company_name}" CACHE STRING "" FORCE)
	set(IN_FILEDESCRIPTION "${_file_description}" CACHE STRING "" FORCE)
	set(IN_INTERNALNAME "${_internal_name}" CACHE STRING "" FORCE)
	set(IN_LEGALCOPYRIGHT "${_legal_copyright}" CACHE STRING "" FORCE)
	set(IN_ORIGINALFILENAME "${_original_filename}" CACHE STRING "" FORCE)
	set(IN_PRODUCTNAME "${_product_name}" CACHE STRING "" FORCE)
	# Copy & Configure File
	file(REMOVE "${_working_dir}/versioninfo.rc")
	include(InputFinder)
	FIND_INPUT_FILE(TEMPLATE_FILEPATH "versioninfo.rc.in" REQUIRED)
	configure_file("${TEMPLATE_FILEPATH}" "${_working_dir}/versioninfo.rc" @ONLY)
	# Cleanup
	unset(IN_VERSION_MAJOR CACHE)
	unset(IN_VERSION_MINOR CACHE)
	unset(IN_VERSION_PATCH CACHE)
	unset(IN_COMPANYNAME CACHE)
	unset(IN_FILEDESCRIPTION CACHE)
	unset(IN_INTERNALNAME CACHE)
	unset(IN_LEGALCOPYRIGHT CACHE)
	unset(IN_ORIGINALFILENAME CACHE)
	unset(IN_PRODUCTNAME CACHE)
endfunction()
