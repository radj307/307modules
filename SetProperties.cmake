# 307modules/SetProperties.cmake
cmake_minimum_required(VERSION 3.15)

#### SET_PROPERTIES() ####
# @brief			Wrapper for set_property() that accepts one target name
#					and uses any additional arguments as the property name & value.
# @param _target	Name of the target to set properties for.
function(SET_PROPERTIES _target)
	SET(_props "${ARGN}")
	STRING(REPLACE ";" " " props "${_props}")
	set_property(
		TARGET "${_target}"
		PROPERTY "${props}"
	)
endfunction()
