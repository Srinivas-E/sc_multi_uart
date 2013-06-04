#ifndef __FILE_HANDLER_H__
#define __FILE_HANDLER_H__
#include <xccompat.h>
void write_to_file(unsigned char file_name[], unsigned char buffer[], unsigned int buf_size);
void read_from_file(unsigned char file_name[], unsigned char buffer[], unsigned int buf_size);
#endif