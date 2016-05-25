#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

int main( const int argc, const char **argv)
{
   FILE *ifile1 = fopen( argv[1], "rb");
   FILE *ifile2 = fopen( argv[2], "rb");
   size_t bytes_read1, bytes_read2, loc = 0;
   const size_t buffsize = 32768;
   unsigned char *ibuff1 = (unsigned char *)malloc( buffsize * 2);
   unsigned char *ibuff2 = ibuff1 + buffsize;

   assert( ifile1);
   assert( ifile2);
   assert( ibuff1);
   while( (bytes_read1 = fread( ibuff1, 1, buffsize, ifile1)) != 0 &&
          (bytes_read2 = fread( ibuff2, 1, buffsize, ifile2)) != 0)
      {
      size_t i;

      assert( bytes_read1 == bytes_read2);
      if( memcmp( ibuff1, ibuff2, bytes_read1))
         for( i = 0; i < bytes_read1; i++)
            if( ibuff1[i] != ibuff2[i])
               printf( "%8lx: %02x %02x %zd\n",
                           loc + i, ibuff1[i], ibuff2[i], loc + i);
      loc += bytes_read1;
      }
   return( 0);
}
