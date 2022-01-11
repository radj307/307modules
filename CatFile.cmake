# 307modules/CatFile.cmake
cmake_minimum_required(VERSION 3.15)

#### CAT_FILE(<OUT_PATH> <IN_PATH>) ####
# @brief				Concatenates the contents of <IN_PATH> to <OUT_PATH> if it exists, otherwise creates <OUT_PATH> with the contents of <IN_PATH>
# @param _out_filepath	Output path
# @param _in_filepath	Input path
function(CAT_FILE _out_filepath _in_filepath)
	FILE(READ "${_in_filepath}" FILE_CONTENTS) # Read the contents of the input file to a variable
	FILE(TOUCH "${_out_filepath}") # Create the file if it doesn't exist, otherwise do nothing
	FILE(APPEND "${_out_filepath}" "${FILE_CONTENTS}") # Append the contents of the input file to the output file
	UNSET(FILE_CONTENTS CACHE) # Cleanup
endfunction()
