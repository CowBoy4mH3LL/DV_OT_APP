#include "common.h"
#include <stdio.h>

//NOTE Input is fixed to 8 bytes, its the info within the input that matters

//region CAN
#pragma region CAN
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <linux/can.h>
#include <linux/can/raw.h>

int init_CAN(char *iface){
	int sock=-1;
	int i; 
	struct sockaddr_can addr;
	struct ifreq ifr;
	if ((sock = socket(PF_CAN, SOCK_RAW, CAN_RAW)) < 0) {
		perror("Socket");
		exit(255);
	}
	strcpy(ifr.ifr_name, iface );
	ioctl(sock, SIOCGIFINDEX, &ifr);
	memset(&addr, 0, sizeof(addr));
	addr.can_family = AF_CAN;
	addr.can_ifindex = ifr.ifr_ifindex;
	if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("Bind");
		return -1;
	}
	return sock;
}

void finish_CAN(int sock){
	close(sock);
}

int nbytes;
struct can_frame frame;
void get_data_CAN(int sock, char *buf){
	while (1){
		nbytes = read(sock, &frame, sizeof(struct can_frame));
		if (nbytes < 0) {
			perror("Read error :(");
			continue;
		}
		printf ("Recvd packet with ID 0x%03X len: %d\n", frame.can_id, frame.can_dlc);
		//CAN does not regulate 8 bytes data, but if you insist
		// if (frame.can_dlc != 8) {
		// 	perror("Small data frame :( ");
		// 	continue;
		// }
		memset(buf,0,8);
		memcpy(buf,frame.data,8);
		break;
	}
}

#pragma endregion

//region STDIN
#pragma region STDIN

void get_data_STDIN(char *buf){
	memset(buf,0,8);
    scanf("%llx",(long long *)buf);
}

#pragma endregion

