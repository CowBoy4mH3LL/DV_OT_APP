#include "common.h"
#include <stdio.h>
#include <stdlib.h>

void process_CAN_data(int can_sock){
	char buf[8]; // This will not crash because input is fixed to 8 bytes
	//~ Process CAN data
	get_data_CAN(can_sock,buf);
	puts ("Recieved message");
	use_message_data(buf);
	puts ("Done processing");
}

int main(){
	//~ Init networking
    int can_sock = init_CAN("vcan0");
	if (can_sock == -1){
		puts("CAN initiation failed :(");
		exit(255);
	}

	#ifdef WHILE
	while (1){
	#endif
		process_CAN_data(can_sock);
	#ifdef WHILE
	}
	#endif
    finish_CAN(can_sock);
    puts ("End of DV_OT_APP!!");
	return 0;
}