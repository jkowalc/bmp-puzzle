#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

int main(int argc, char *argv[])
{
    srand(time(NULL));
    char* ifname = "source.bmp";
    char* ofname = "result.bmp";
    u_int32_t n = atoi(argv[1]);
    u_int32_t m = atoi(argv[2]);
    FILE* ifstream = fopen(ifname, "rb");
    if(!ifstream)
    {
        printf("Can't open source file\n");
        return 0;
    }

    // read bmp
    spread_tiles(n, m);
    // save bmp
};