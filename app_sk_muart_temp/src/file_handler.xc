/*
 * file_handler.xc
 *
 *  Created on: Jun 4, 2013
 *      Author: sandeep
 */
#include <xs1.h>
#include <syscall.h>
#include <print.h>
#include <stdlib.h>
#include <stdio.h>
void write_to_file(unsigned char file_name[], unsigned char buffer[], unsigned int buf_size)
{	int fd1;
	 /*writing in to the file*/
	        fd1 = _open(file_name, O_WRONLY | O_CREAT | O_TRUNC, S_IREAD | S_IWRITE);
	         if (fd1 == -1) {
	           printstrln("Error: _open failed");
	           exit(1);
	         }

	         /** An open file can be written using the *_write* system call
	          **/
	         if (_write(fd1, buffer, buf_size) != buf_size) {
	           printstrln("Error: _write failed");
	           exit(1);
	         }

	         /** We can then close an open file using the *_close* system call
	          **/
	         if (_close(fd1) != 0) {
	           printstrln("Error: _close failed.");
	           exit(1);
	         }
}
void read_from_file(unsigned char file_name[], unsigned char buffer[], unsigned int buf_size)
{
    int fd = _open(file_name, O_RDONLY, 0);
    	     if (fd == -1) {
    	       printstrln("Error: _open failed");
    	       exit(1);
    	     }
    	     _read(fd, buffer, buf_size);

    	     if (_close(fd) != 0) {
    	       printstrln("Error: _close failed.");
    	       exit(1);
    	     }

}


