Clarification on the VHDL files

the files titled "tennis.vhd" and "tennis_machine.vhd" are the modified files from the tarball that were used for OpenCl

the files "Lab2.vhd" and "Lab2.vht" are the files originally made for part 1 on quartus including the testbench and the 
entity used to use I/O(hex display, switch, keys) from the FPGA board.

Both have the same code for the state machine, but the openCL versions leave out the second entity to map out to the hex displays etc. Because they are unneeded for that part.