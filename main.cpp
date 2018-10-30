#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include "CL/opencl.h"
#include "AOCL_Utils.h"

using namespace aocl_utils;

// OpenCL runtime configuration
cl_platform_id platform = NULL;
unsigned num_devices = 0;
cl_device_id *device; 
cl_context context = NULL;
cl_command_queue queue; 
cl_program program = NULL;
cl_kernel kernel; 
cl_mem output_buf; 
cl_mem input_buf;

// Problem data.
int N; // problem size
char input_a; 
char *output;
char ref_output;
bool test;

// Function prototypes
bool init_opencl();
void init_problem();
void run();
void cleanup();

char *inputs;
char **output_codes;

// Entry point.
int main(int argc, char **argv) {
	test = false;
  	if(argc == 1){
		printf("Entering interactive mode.  Please follow prompts and type 'q' to quit.\n");	
		printf("Use the option '-t' flag to enter a test mode.\n");
  	}

	if(argc == 2){
		if(argv[1][0] == '-' && argv[1][1] == 't'){
			printf("Entering test mode\n");
			test = true;	
		}
	}

  	// Initialize the problem data.
  	init_problem();

  	// Initialize OpenCL.
  	if(!init_opencl()) {
    		return -1;
  	}

  	// Run the kernel.
  	run();

  	// Free the resources allocated
  	cleanup();

  	return 0;
}

/////// HELPER FUNCTIONS ///////

// Initializes the OpenCL objects.
bool init_opencl() {
  	cl_int status;

  	//printf("Initializing OpenCL\n");

  	if(!setCwdToExeDir()) {
    		return false;
  	}

  	// Get the OpenCL platform.
  	platform = findPlatform("Altera");
  	if(platform == NULL) {
    		printf("ERROR: Unable to find Altera OpenCL platform.\n");
    		return false;
  	}

  	// Query the available OpenCL device.
  	device = getDevices(platform, CL_DEVICE_TYPE_ALL, &num_devices);
  	//printf("Platform: %s\n", getPlatformName(platform).c_str());
  	//printf("Using %d device(s)\n", num_devices);
  	//printf("  %s\n", getDeviceName(*device).c_str());

  	// Create the context.
  	context = clCreateContext(NULL, num_devices, device, NULL, NULL, &status);
  	checkError(status, "Failed to create context");

  	// Create the program for all device. Use the first device as the
  	// representative device (assuming all device are of the same type).
  	std::string binary_file = getBoardBinaryFile("tennis", *device);
  	//printf("Using AOCX: %s\n", binary_file.c_str());
  	program = createProgramFromBinary(context, binary_file.c_str(), device, num_devices);

  	// Build the program that was just created.
  	status = clBuildProgram(program, 0, NULL, "", NULL, NULL);
  	checkError(status, "Failed to build program");

  	// Command queue.
  	queue = clCreateCommandQueue(context, *device, CL_QUEUE_PROFILING_ENABLE, &status);
  	checkError(status, "Failed to create command queue");

  	// Kernel.
  	const char *kernel_name = "tennis_kernel";
  	kernel = clCreateKernel(program, kernel_name, &status);
  	checkError(status, "Failed to create kernel");

	//Input buffer.
	input_buf = clCreateBuffer(context, CL_MEM_READ_ONLY, 
			sizeof(char) * 51, NULL, &status);
	checkError(status, "Failed to create buffer for input");

  	// Output buffer.
  	output_buf = clCreateBuffer(context, CL_MEM_WRITE_ONLY, 
        		sizeof(char) * 51, NULL, &status);
  	checkError(status, "Failed to create buffer for output");

  	return true;
}

//Initialize data for the problem.
void init_problem() {
	//Output is a single char, but might not be used here.
	output = (char*)malloc(sizeof(char) * 51);

	int i;

	//Assuming default allocation of 51
	inputs = (char*)malloc(sizeof(char) * 51);	

	if(test){
		//Sets up a simple test that basically follows a script of 3 games
		//Tests all 1 player winning, then all 2 player winning
		//Then tests advantage and deuce cases with alternative scoring.
		//This is NOT an exhaustive test.
		for(i = 0; i < 4; i++)
			inputs[i] = 0;

		for(;i < 8; i++)
			inputs[i] = 1;

		inputs[8] = 0;
		inputs[9] = 1;
		inputs[10] = 1;
		inputs[11] = 0;
		inputs[12] = 0;
		inputs[13] = 1;
		inputs[14] = 1;
		inputs[15] = 1;
		inputs[16] = 'q';
	}else{
		char last_input = '0';		
	
		printf("You will enter all numbers before entering the kernel.\n"
			"This means you will not see the output until you enter q"
			" or you enter 50 characters.\n");
		printf("Enter '0' for Player 1 score, '1' for Player 2 score,"
			" followed by enter.\nRepeat until finished, then type q.\n");

		for(i = 0; i < 50 && last_input != 'q'; i++){
			last_input = getchar();
			getchar();
			if(last_input != '0' & last_input != '1' && last_input != 'q'){
				printf("Please enter only '0', '1', or 'q'\n");
				i--;
			}else{
				if(last_input == '1' || last_input == '0')
					last_input -= 48;
				inputs[i] = last_input;				
			}
		}

		if(i == 50)
			inputs[50] = 'q';
	}
	
	output_codes = (char**)malloc(sizeof(char**) * 13);
	for(i = 0; i < 13; i++){
		output_codes[i] = (char*)malloc(sizeof(char*) * 10);
		
		switch(i){
			
		case 0:
			strcpy(output_codes[i], "Love-Love");
		break;

		case 1:
			strcpy(output_codes[i], "15-0");
		break;

		case 2:
			strcpy(output_codes[i], "0-15");
		break;

		case 3:
			strcpy(output_codes[i], "30-0");
		break;

		case 4:
			strcpy(output_codes[i], "0-30");
		break;

		case 5:
			strcpy(output_codes[i], "15-15");
		break;
			
		case 6:
			strcpy(output_codes[i], "30-15");
		break;
			
		case 7:
			strcpy(output_codes[i], "15-30");
		break;
			
		case 8:
			strcpy(output_codes[i], "DEUCE");
		break;

			
		case 9:
			strcpy(output_codes[i], "Adv-30");
		break;
			
		case 10:
			strcpy(output_codes[i], "30-Adv");
		break;
			
		case 11:
			strcpy(output_codes[i], "Game 1");
		break;
			
		case 12:
			strcpy(output_codes[i], "Game 2");
		break;
		}
		
	}
}

void run() {
	int i;
  	cl_int status;

  	const double start_time = getCurrentTimestamp();

  	// Launch the problem for each device.
  	cl_event kernel_event;
  	cl_event finish_event;
	cl_event write_event;

	status = clEnqueueWriteBuffer(queue, input_buf, CL_FALSE,
			0, sizeof(char) * 51, inputs, 0, NULL, &write_event);
	checkError(status, "Failed to write input buffer");
		

	// Set kernel arguments.
  	unsigned argi = 0;
 	status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &input_buf);
  	checkError(status, "Failed to set argument %d", argi - 1);
  	status = clSetKernelArg(kernel, argi++, sizeof(cl_mem), &output_buf);
	checkError(status, "Failed to set argument %d", argi - 1);

  	// Enqueue kernel.
	// Use a global work size corresponding to the number of elements to add
  	// for this device.
	// 
  	// We don't specify a local work size and let the runtime choose
	// (it'll choose to use one work-group with the same size as the global
 	// work-size).
	//
  	// Events are used to ensure that the kernel is not launched until
	// the writes to the input buffers have completed.
  	const size_t global_work_size = 1;
	//printf("Launching for device %d (%d elements)\n", 0, global_work_size);
  	status = clEnqueueNDRangeKernel(queue, kernel, 1, NULL,
       		&global_work_size, NULL, 1, &write_event, &kernel_event);
  	checkError(status, "Failed to launch kernel");

	clWaitForEvents(num_devices, &kernel_event);
  
  	// Read the result. This the final operation.
	status = clEnqueueReadBuffer(queue, output_buf, CL_FALSE,
       		0, sizeof(char)*51, output, 1, &kernel_event, &finish_event);


  	// Wait for all devices to finish.
	clWaitForEvents(num_devices, &finish_event);

  	const double end_time = getCurrentTimestamp();
	
	if(test){
		printf("Score: Love-Love\n");
	}else{
		printf("Input: X -> Score: Love-Love\n");
	}

	for(i = 0; i < 51; i++){
		
		if(inputs[i] != 'q')
			inputs[i] += 48;

		if(test){
			printf("Score: %s\n", output_codes[output[i]]);
		}else
			printf("Input: %c -> Score: %s\n", inputs[i], output_codes[output[i]]);
		
		if(inputs[i] == 'q')
			i = 51;

	}

	// Wall-clock time taken.
 	//printf("\nTime: %0.3f ms\n", (end_time - start_time) * 1e3);

	// Get kernel times using the OpenCL event profiling API.
  	cl_ulong time_ns = getStartEndTime(kernel_event);
	//printf("Kernel time (device 0): %0.3f ms\n", double(time_ns) * 1e-6);i
	
	// Release all events.
  	clReleaseEvent(kernel_event);
	clReleaseEvent(finish_event);

}

// Free the resources allocated during initialization
void cleanup() {
  	if(kernel) {
    		clReleaseKernel(kernel);
  	}
  	if(queue) {
      		clReleaseCommandQueue(queue);
  	}

  	if(output_buf) {
      		clReleaseMemObject(output_buf);
  	}
  

  	if(program) {
    		clReleaseProgram(program);
  	}
  	if(context) {
    		clReleaseContext(context);
  	}
}

