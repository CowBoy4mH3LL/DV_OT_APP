#include "common.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

// Parse packet
static int v_parse_stack_flow(char *data, comm *comm_ds){
    //Parse data
	int size = (data[0]&0xff);
	if (size > 18){
        printf ("Message of size %u is too big :(\n", size);
        return -1;
    }
    char cdata[7];
    memcpy(cdata,&data[1],size); //crash if input size is between 0x8 and 0x14 bytes, depending on compiler optimization
    printf ("Recieved data of size %u. Data => ", size);
    for (int i = 0; i < size; i++)
		printf("%02X ",(cdata[i]&0xff));
	puts("");

    //Put into comm data structure
    memcpy(comm_ds,cdata,7);
    return 0;
}

// Do fake DMA
static void v_proto_u_free(comm *comm_ds){
    if (comm_ds->dma_code != 0x23){
        printf ("Unidentified DMA code %u :(\n", comm_ds->dma_code);
        return;
    }
    if (comm_ds->dma_loc){free((void *)comm_ds->dma_loc);} //crash if byte 1 is 0x23 and byte 2-5 is non-zero
    comm_ds->dma_loc = (long)malloc(3);
    memcpy((void *)comm_ds->dma_loc,&comm_ds->dma_data, 3);
}

//Main API
void use_message_data(char *data){
    comm comm_ds;
    if (v_parse_stack_flow(data, &comm_ds) == -1){
        puts ("Could not parse data :(");
        return;
    };
    v_proto_u_free(&comm_ds);
}