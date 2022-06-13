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
    u_int32_t n = 4;
    u_int32_t m = 3;
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