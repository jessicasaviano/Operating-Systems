#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <errno.h>
#include <assert.h>
#include "inode.h"
#define uint unsigned int


uint INODE_BLOCKS;
uint DATA_BLOCKS;
uint TOTAL_BLOCKS;

#define INODE_SIZE sizeof(struct inode)
#define INODES_PER_BLOCK (BLOCK_SZ / INODE_SIZE)
#define TOTAL_INODES (INODE_BLOCKS * INODES_PER_BLOCK)

static unsigned char *rawdata;
static char *bitmap;
uint data_block_filled = 0;

int get_free_block()
{
  for (int blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
        if (bitmap[blockno] == 0) {  
            bitmap[blockno] = 1;  
              // Mark the block as used
              data_block_filled++;
            return blockno;         
        }
    }

    perror("\nERROR:\n all data blocks in use!!!!\n");
    exit(-1);
  // fill in here
  //assert(blockno < TOTAL_BLOCKS);
  //assert(bitmap[blockno]);
  //return blockno;
}

void write_int(int pos, uint val)
{
  int *ptr = (uint*)&rawdata[pos];
  *ptr = val;
}
void read_int(int pos)
{
  int *ptr = (uint*)&rawdata[pos];

}
//do I need a write and read for iblock, i2block, and i3block?



void place_file(char *file, int uid, int gid, uint inode_position, uint block_pos_inode)
{
 int blockno;
  int i, nbytes = 0;
  int i2block_index, i3block_index;
  struct inode *ip = (struct inode *)&rawdata[block_pos_inode * BLOCK_SZ + inode_position * INODE_SIZE];;
  FILE *fpr;
  unsigned char buf[BLOCK_SZ];
  ip->mode = 0;
  ip->nlink = 1;
  ip->uid = uid;
  ip->gid = gid;
  ip->ctime = 1; //?
  ip->mtime = 1; //?
  ip->atime = 1; //?

  fpr = fopen(file, "rb");
  if (!fpr) {
    perror(file);
    exit(-1);
  }


  //HANDLE DIRECT BLOCKS
  for (i = 0; i < N_DBLOCKS && !feof(fpr); i++) {
    blockno = get_free_block();
        if (blockno == -1) {
            fclose(fpr);
            return;
        }
    ip->dblocks[i] = blockno;
    // fill in here
    size_t bytes_read = fread(buf, 1, BLOCK_SZ, fpr);
    write_block(blockno, buf, bytes_read);
    ip->size += bytes_read;
  }

  // fill in here if IBLOCKS needed
  // if so, you will first need to get an empty block to use for your IBLOCK

 //IF THE FILE SIZE EXCEEDS THE CAPACITY OF THE DIRECT BLOCKS, THEN WE HAVE TO USE INDIRECT!
  for (int i = 0; i < N_IBLOCKS && !feof(fpr); i++) {
        int iblock_no = get_free_block();
        if (iblock_no == -1) {
            fclose(fpr);
            return;
        }
        ip->iblocks[i] = iblock_no;
        int *iblock = (int *)&rawdata[iblock_no * BLOCK_SZ];

        for (int j = 0; j < BLOCK_SZ / sizeof(int) && !feof(fpr); j++) {
            blockno = get_free_block();
            if (blockno == -1) {
                fclose(fpr);
                return;
            }
            iblock[j] = blockno;
            size_t bytes_read = fread(buf, 1, BLOCK_SZ, fpr);
            write_block(blockno, buf, bytes_read);
            ip->size += bytes_read;
        }
    }

    //HANDLE DOUBLE INDIRECT!!!!!
    if (!feof(fpr)) {
        int i2block_no = get_free_block();
        if (i2block_no == -1) {
            fclose(fpr);
            return;
        }
        ip->i2block = i2block_no;
        int *i2block = (int *)&rawdata[i2block_no * BLOCK_SZ];

        for (int i = 0; i < BLOCK_SZ / sizeof(int) && !feof(fpr); i++) {
            int ind_blockno = get_free_block();
            if (ind_blockno == -1) {
                fclose(fpr);
                return;
            }
            i2block[i] = ind_blockno;
            int *ind_block = (int *)&rawdata[ind_blockno * BLOCK_SZ];

            for (int j = 0; j < BLOCK_SZ / sizeof(int) && !feof(fpr); j++) {
                blockno = get_free_block();
                if (blockno == -1) {
                    fclose(fpr);
                    return;
                }
                ind_block[j] = blockno;
                size_t bytes_read = fread(buf, 1, BLOCK_SZ, fpr);
                write_block(blockno, buf, bytes_read);
                ip->size += bytes_read;
            }
        }
    }

    // HANDLE TRIPLE INDIRECT!!!!
    if (!feof(fpr)) {
        int i3block_no = get_free_block();
        if (i3block_no == -1) {
            fclose(fpr);
            return;
        }
        ip->i3block = i3block_no;
        int *i3block = (int *)&rawdata[i3block_no * BLOCK_SZ];

        for (int i = 0; i < BLOCK_SZ / sizeof(int) && !feof(fpr); i++) {
            int i2block_no = get_free_block();
            if (i2block_no == -1) {
                fclose(fpr);
                return;
            }
            i3block[i] = i2block_no;
            int *i2block = (int *)&rawdata[i2block_no * BLOCK_SZ];

            for (int j = 0; j < BLOCK_SZ / sizeof(int) && !feof(fpr); j++) {
                int ind_blockno = get_free_block();
                if (ind_blockno == -1) {
                    fclose(fpr);
                    return;
                }
                i2block[j] = ind_blockno;
                int *ind_block = (int *)&rawdata[ind_blockno * BLOCK_SZ];

                for (int k = 0; k < BLOCK_SZ / sizeof(int) && !feof(fpr); k++) {
                    blockno = get_free_block();
                    if (blockno == -1) {
                        fclose(fpr);
                        return;
                    }
                    ind_block[k] = blockno;
                    size_t bytes_read = fread(buf, 1, BLOCK_SZ, fpr);
                    write_block(blockno, buf, bytes_read);
                    ip->size += bytes_read;
                }
            }
        }
    }

    fclose(fpr);
    printf("Successfully wrote %d bytes of file %s\n", ip->size, file);
}

void obtain_inode_for_extraction(const char *image_filename, uint uid, uint gid, const char *output_path){
     FILE *image_file = fopen(image_filename, "rb");
    if (!image_file) {
        perror("Failed to open image file");
        exit(EXIT_FAILURE);
    }

    unsigned char *disk_image = (unsigned char *)malloc(TOTAL_BLOCKS * BLOCK_SZ);
    fread(disk_image, BLOCK_SZ, TOTAL_BLOCKS, image_file);
    fclose(image_file);

    for (int blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
        struct inode *ip = (struct inode *)(disk_image + blockno * BLOCK_SZ);
        for (int i = 0; i < INODES_PER_BLOCK; i++) {
            if (ip[i].uid == uid && ip[i].gid == gid) {
                traversing_inode(&ip[i], output_path, disk_image, blockno);
            }
        }
    }

    free(disk_image);
}



void traversing_inode(struct inode *ip, const char *output_path, unsigned char *disk_image, int inode_byte_position){

}




void main(int argc, char **argv) // add argument handling
{
   int i;
  FILE *outfile;
  if (strcmp(argv[1], "-create") == 0 ) {
  if (argc != 18) {
        fprintf(stderr, "Usage: disk_image -create -image IMAGE_FILE -nblocks N -iblocks M -inputfile FILE -u UID -g GID -block D -inodepos I\n");
        return 1;
    }
    uint N, M, D, I, UID, GID;
    const char *in_filename, *image_filename;
    uint i;
    for (i = 2; i < 17; ++i) {
      if (strcmp(argv[i], "-image") == 0) {
        image_filename = argv[i+1];
      } else if (strcmp(argv[i], "-iblocks") == 0) {
        M = atoi(argv[i+1]);
      } else if (strcmp(argv[i], "-nblocks") == 0) {
        N = atoi(argv[i+1]);
      } else if (strcmp(argv[i], "-inputfile") == 0) {
        in_filename = argv[i+1];
      } else if (strcmp(argv[i], "-u") == 0) {
        UID = atoi(argv[i+1]);
      } else if (strcmp(argv[i], "-g") == 0) {
        GID = atoi(argv[i+1]);
      } else if (strcmp(argv[i], "-block") == 0) {
        D = atoi(argv[i+1]);
      } else if (strcmp(argv[i], "-inodepos") == 0) {
        I = atoi(argv[i+1]);
      } 
    }
         if (D >= M || I >= INODES_PER_BLOCK) {
        fprintf(stderr, "Invalid inode block or position\n");
        return EXIT_FAILURE;
    }

    TOTAL_BLOCKS = N;
    INODE_BLOCKS = M;
    DATA_BLOCKS = N - M;

    rawdata = (unsigned char *)calloc(TOTAL_BLOCKS, BLOCK_SZ);
    bitmap = (char *)calloc(TOTAL_BLOCKS, sizeof(char));

    if (!rawdata || !bitmap) {
        perror("Memory allocation failed");
        return EXIT_FAILURE;
    }

    place_file((char *)in_filename, UID, GID, D, I);

    FILE *outfile = fopen(image_filename, "wb");
    if (!outfile) {
        perror("Failed to open output file");
        free(rawdata);
        free(bitmap);
        return EXIT_FAILURE;
    }

    if (fwrite(rawdata, BLOCK_SZ, TOTAL_BLOCKS, outfile) != TOTAL_BLOCKS) {
        perror("Failed to write to output file");
        fclose(outfile);
        free(rawdata);
        free(bitmap);
        return EXIT_FAILURE;
    }

    fclose(outfile);
    free(rawdata);

  i = fclose(outfile);
  if (i) {
    perror("datafile close");
    exit(-1);
  }

  printf("Done.\n");
  return;
  }
}