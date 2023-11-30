#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <errno.h>
#include <assert.h>
#include "inode.h"
#include <string.h>
#define uint unsigned int

//-create is like making a new "tool box" (IMAGE FILE), and putting your first tool ina specific part of the box (ike inode in block D at position I)
//you want to put a new tool (-FILE) into the tool box (N blocks)
//some compartments in the tool box are reserved for inodes (M inode blocks)
//if the tools are too big for one (data) block, you will need hidden inode blocks to store the other parts
//the -insert command lets you add more tools to your toolbox, you're basically syaing heres a new FILE, i want to add it to IMAGE FILE, at this positon, and it belongs to this ID.
//-extract also uses UID and GID to find and take out the tool you want
//the tools can be from different paths (PDF, JPEG, etc.), and you must put them in a speicif room (PATH)
//as you find each tool you keep track of its inode location (where it was found), and how big the tool was (file size)
//you are also looking through the tool box (-extract) and making note of every block that is empty
//you write down all of these tools in a sepcial notebook (UNUSED_BLOCKS), so you know where you can put other tools in the future
 

uint INODE_BLOCKS;
uint DATA_BLOCKS;
uint TOTAL_BLOCKS;
int free_blocks;
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

void write_block(int pos, unsigned char *val, size_t sizen)
{
  if (pos < 0 || pos >= TOTAL_BLOCKS * BLOCK_SZ) {
        fprintf(stderr, "Invalid position: %d\n", pos);
        exit(-1);
    }

    if (sizen > BLOCK_SZ || pos + sizen > TOTAL_BLOCKS * BLOCK_SZ) {
        fprintf(stderr, "Data size exceeds block size or goes beyond filesystem bounds\n");
        exit(-1);
    }

    // Copying data to the specified position
    memcpy(&rawdata[pos], val, sizen);
}


/*
void read_int(int pos)
{
  int *ptr = (uint*)&rawdata[pos];

}
*/
//do I need a write and read for iblock, i2block, and i3block?



void place_file(char *file, int uid, int gid, uint inode_position, uint block_pos_inode)
{
 int blockno;
  int i;
  //nbytes = 0;
  //int i2block_index, i3block_index;
  struct inode *ip = (struct inode *)&rawdata[block_pos_inode * BLOCK_SZ + inode_position * INODE_SIZE];
  printf("uid = %d\n", block_pos_inode);
  printf("guid = %d\n", inode_position);

  FILE *fpr;
  unsigned char buf[BLOCK_SZ];
  ip->mode = 0;
  ip->nlink = 1;
  ip->uid = uid;
  ip->gid = gid;
  printf("uid = %d\n", uid);
  printf("guid = %d\n", gid);
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
        ip->iblocks[i] = iblock_no;  //pointers to indirect blocks
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

int is_inode_block(int blockno) {
    return blockno < INODE_BLOCKS;
}

void traversing_inode_construct_file(struct inode *ip, const char *output_path, unsigned char *disk_image, int block_num){
   
  FILE *output_file = fopen(output_path, "wb");
    if (!output_file) {
        perror("Failed to open output file");
        exit(EXIT_FAILURE);
    }

     
    // Handle direct blocks
    for (int i = 0; i < N_DBLOCKS; i++) {
        if (ip->dblocks[i] != 0) {
            fwrite(disk_image + ip->dblocks[i] * BLOCK_SZ, BLOCK_SZ, 1, output_file);
        }
    }
   
    fprintf(stderr, "Usage: disk_image -c\n");
printf("file found at inode in block %d, file size %u\n", block_num, ip->size);
 fclose(output_file);
}



void obtain_inode_for_extraction(const char *image_filename, uint uid, uint gid, const char *output_path){
     /*
     FILE *image_file = fopen(image_filename, "rb");
    if (!image_file) {
        perror("Failed to open image file");
        exit(EXIT_FAILURE);
    }

    unsigned char *disk_image = (unsigned char *)malloc(10 * BLOCK_SZ);
    fread(disk_image, BLOCK_SZ, 10, image_file);
    fclose(image_file);
 

    for (int blockno = 0; blockno < 10; blockno++) {
     
        struct inode *ip = (struct inode *)(disk_image + blockno * BLOCK_SZ);
   
        for (int i = 0; i < INODES_PER_BLOCK; i++) {
            printf("iud = %d\n",ip->uid);
            printf("gid = %d\n",ip[i].gid);
            if (ip[i].uid == uid && ip[i].gid == gid) { // looking at every inode and mlink for 0 and not 0
                  fprintf(stderr, "Usage: disk_imagcdcdsc dfvdgdfe -c\n");
                traversing_inode_construct_file(&ip[i], output_path, disk_image, blockno);
                
            }
        }
    }
     
   //fprintf(stderr, "Usage: disk_image -create or -insert\n");
    
    free(disk_image);
    */
      FILE *image_file = fopen(image_filename, "rb");
    if (!image_file) {
        perror("Failed to open image file");
        exit(EXIT_FAILURE);
    }

    // Dynamically determine the size of the file
    fseek(image_file, 0, SEEK_END);
    long file_size = ftell(image_file);
    fseek(image_file, 0, SEEK_SET);

    // Allocate memory for the entire disk image
    unsigned char *disk_image = (unsigned char *)malloc(file_size);
    if (!disk_image) {
        perror("Memory allocation failed");
        fclose(image_file);
        exit(EXIT_FAILURE);
    }

    // Read the entire disk image into memory
    fread(disk_image, 1, file_size, image_file);
    fclose(image_file);

    // Iterate over each block
    for (int blockno = 0; blockno < file_size / BLOCK_SZ; blockno++) {
        printf("iud = %d\n",ip->uid);
        // Assuming a function to check if a block is an inode block
        if (is_inode_block(blockno)) {
            struct inode *ip = (struct inode *)(disk_image + blockno * BLOCK_SZ);
            printf("iud = %d\n",ip->uid);
            printf("gid = %d\n",ip[blockno].gid);
            for (int i = 0; i < INODES_PER_BLOCK; i++) {
                if (ip[i].uid == uid && ip[i].gid == gid) {
                    traversing_inode_construct_file(&ip[i], output_path, disk_image, blockno);
                    printf("file found at inode in block %d, file size %u\n", blockno, ip[i].size);
                }
            }
        }
    }

    free(disk_image);
}







int main(int argc, char **argv) // add argument handling
{
   //int i;
  //FILE *outfile;
  if (strcmp(argv[1], "-create") == 0  || strcmp(argv[1], "-insert") == 0 ) {
    
  if (argc != 18) {
        fprintf(stderr, "Usage: disk_image -create or -insert\n");
        exit(-1);
    }
    int N, M, D, I, UID, GID;
    
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

  
//printf("I = %u\n", I);
//printf("INODES_PER_BLOCK = %lu\n", INODES_PER_BLOCK);
    }
       printf("UID = %x\n", UID);
      printf("GID = %x\n", GID);
         if (D >= M || I >= INODES_PER_BLOCK) {
        fprintf(stderr, "Invalid inode block or position\n");
        exit(-1);
    }

    TOTAL_BLOCKS = N;
    INODE_BLOCKS = M;
    DATA_BLOCKS = N - M;

    rawdata = (unsigned char *)calloc(TOTAL_BLOCKS, BLOCK_SZ); //simulate the actual disk space
    bitmap = (char *)calloc(TOTAL_BLOCKS, sizeof(char)); // keeps track of which blocks are free

    if (!rawdata || !bitmap) {
        perror("Memory allocation failed");
        exit(-1);
    }

    place_file((char *)in_filename, UID, GID, D, I);

    FILE *outfile = fopen(image_filename, "wb");
    if (!outfile) {
        perror("Failed to open output file");
        free(rawdata);
        free(bitmap);
        exit(-1);
    }

    if (fwrite(rawdata, BLOCK_SZ, TOTAL_BLOCKS, outfile) != TOTAL_BLOCKS) {
        perror("Failed to write to output file");
        fclose(outfile);
        free(rawdata);
        free(bitmap);
        exit(-1);
    }

    fclose(outfile);
    free(rawdata);
    printf("Done.\n");
  exit(0);
  }

  if(strcmp(argv[1], "-extract") == 0){
    
     
    if (argc != 10) {
        fprintf(stderr, "Usage: -extract\n");
        exit(-1);
    }

    int UID, GID;
    const char *image_filename, *PATH;
    uint i;
    for (i = 2; i < 9; ++i) {
      if (strcmp(argv[i], "-image") == 0) {
        image_filename = argv[i+1];
        printf("D = %s\n", image_filename);
      
      } else if (strcmp(argv[i], "-u") == 0) {
        UID = atoi(argv[i+1]); 
        printf("D = %x\n", UID);
      } else if (strcmp(argv[i], "-g") == 0) {
        GID = atoi(argv[i+1]);
        printf("D = %x\n", GID);
      }else if (strcmp(argv[i], "-o") == 0) {
        PATH = argv[i+1];
        printf("D = %s\n", PATH);
      }

    }

      if (!image_filename) {
            fprintf(stderr, "Missing required arguments for -extract\n");
            exit(-1);
        }

      obtain_inode_for_extraction(image_filename, UID, GID, (char *)PATH);
   

  }
 
  printf("Done.\n");
  exit(0);
  





}