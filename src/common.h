#ifndef COMMON_H
#define COMMON_H

//region data structures
typedef struct comm{
    char dma_code;
    long dma_loc;
    short dma_data;
}comm;

//region dma
void use_message_data(char *data);

//region comm
int init_CAN(char *iface); // -> sock number 
void finish_CAN(int sock);
void get_data_CAN(int sock, char *buf);

void get_data_STDIN(char *buf);

#endif