#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "image.h"
extern void spread_tiles(ImageInfo* imgInfo, u_int32_t n, u_int32_t m);
int main(int argc, char *argv[])
{
    srand(time(NULL));
    char* ifname = "source.bmp";
    char* ofname = "result.bmp";
    if(argc < 3)
    {
        printf("Too little arguments. Expected: ./main [n] [m]\n");
        return 0;
    }
    u_int32_t n = atoi(argv[1]);
    u_int32_t m = atoi(argv[2]);
    ImageInfo* imgInfo = readBmp(ifname);
    if(imgInfo == NULL)
    {
        return 2;
    }
    spread_tiles(imgInfo, n, m);
    if(saveBmp(ofname, imgInfo) != 0)
    {
        printf("Error saving BMP");
        return 2;
    }
    freeImage(imgInfo);
};