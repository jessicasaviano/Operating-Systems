#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#include <errno.h>
#include <assert.h>
#include "inode.h"
#include <string.h>
#include <linux/limits.h>

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
 


uint DATA_BLOCKS;
uint TOTAL_BLOCKS;
uint INODE_BLOCKS;

int free_blocks;
#define INODE_SIZE sizeof(struct inode)
#define INODES_PER_BLOCK (BLOCK_SZ / INODE_SIZE)


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
void create_disk_image(uint total_blocks, uint block_size) {
    rawdata = (unsigned char *)calloc(total_blocks, block_size);
    if (!rawdata) {
        perror("Failed to allocate memory for rawdata");
        exit(-1);
    }
    
    bitmap = (char *)calloc(total_blocks, sizeof(char));
    for (int i = 0; i < INODE_BLOCKS; i++) {
        bitmap[i] = 1;
    }
    if (!bitmap) {
        perror("Failed to allocate memory for bitmap");
        free(rawdata);
        exit(-1);
    }

}


void place_file(char *file, int uid, int gid, uint block_pos_inode, uint inode_position)
{
 int blockno;
  int i;
  //nbytes = 0;
  //int i2block_index, i3block_index;
  struct inode *ip = (struct inode *)&rawdata[block_pos_inode * BLOCK_SZ + inode_position * INODE_SIZE];
  //printf("uid = %d\n", block_pos_inode);
  //printf("guid = %d\n", inode_position);
   //printf("Placing inode at block %u, position %u\n", block_pos_inode, inode_position);

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

void load_disk_image(const char *image_filename) {
  

    //memset(bitmap, 0, TOTAL_BLOCKS * sizeof(char));
     

    // Logic to reconstruct the bitmap based on the loaded disk image
    

    // Update bitmap based on inode information
    for (uint blockno = 0; blockno < INODE_BLOCKS; blockno++) {
        struct inode *ip = (struct inode *)&rawdata[blockno * BLOCK_SZ];
        for (uint i = 0; i < INODES_PER_BLOCK; i++) {
            if (ip[i].size > 0) {
                // Mark the blocks used by this inode as used in the bitmap
                // This includes direct blocks, indirect blocks, etc.
                // For each block used by the file, do something like:
                bitmap[i] = 1;
            }
        }
    }


    FILE *image_fptr = fopen(image_filename, "rb");
    if (!image_fptr) {
        perror("Error opening image file for reading");
        exit(-1);
    }

    // Determine the file size
    fseek(image_fptr, 0, SEEK_END);
    long file_size = ftell(image_fptr);
    fseek(image_fptr, 0, SEEK_SET);

    // Ensure that the file size is a multiple of BLOCK_SZ
    if (file_size % BLOCK_SZ != 0) {
        fprintf(stderr, "Disk image file size is not a multiple of BLOCK_SZ\n");
        fclose(image_fptr);
        exit(-1);
    }

    TOTAL_BLOCKS = file_size / BLOCK_SZ;

    // Allocate memory according to the file size
    if (rawdata != NULL) {
        free(rawdata);  // Free any previously allocated memory
    }
    rawdata = (unsigned char *)malloc(file_size);
    if (!rawdata) {
        perror("Memory allocation failed for rawdata");
        fclose(image_fptr);
        exit(-1);
    }

    // Read the file into rawdata
    size_t result = fread(rawdata, 1, file_size, image_fptr);
    if (result != file_size) {
        perror("Error reading image file");
        fclose(image_fptr);
        free(rawdata);
        exit(-1);
    }

    fclose(image_fptr);
     // Initialize or update bitmap here
    if (bitmap != NULL) {
        free(bitmap);  // Free any previously allocated memory for bitmap
    }
    bitmap = (char *)calloc(TOTAL_BLOCKS, sizeof(char));
    if (!bitmap) {
        perror("Memory allocation failed for bitmap");
        free(rawdata);
        exit(-1);
    }


   
}

 
void extract_file_data(struct inode *ip, FILE *outfile) {
    unsigned char buf[BLOCK_SZ];
    size_t bytes_to_write;
    size_t remaining_size = ip->size;

    // Handle direct blocks
    for (int i = 0; i < N_DBLOCKS && remaining_size > 0; i++) {
        bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
        memcpy(buf, &rawdata[ip->dblocks[i] * BLOCK_SZ], bytes_to_write);
        fwrite(buf, 1, bytes_to_write, outfile);
        remaining_size -= bytes_to_write;
    }

    // Handle single indirect blocks
    for (int i = 0; i < N_IBLOCKS && remaining_size > 0; i++) {
        int *iblock = (int *)&rawdata[ip->iblocks[i] * BLOCK_SZ];
        for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
            bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
            memcpy(buf, &rawdata[iblock[j] * BLOCK_SZ], bytes_to_write);
            fwrite(buf, 1, bytes_to_write, outfile);
            remaining_size -= bytes_to_write;
        }
    }

    // Handle double indirect blocks
    if (remaining_size > 0 && ip->i2block != 0) {
        int *i2block = (int *)&rawdata[ip->i2block * BLOCK_SZ];
        for (int i = 0; i < BLOCK_SZ / sizeof(int) && remaining_size > 0; i++) {
            int *ind_block = (int *)&rawdata[i2block[i] * BLOCK_SZ];
            for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
                bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                memcpy(buf, &rawdata[ind_block[j] * BLOCK_SZ], bytes_to_write);
                fwrite(buf, 1, bytes_to_write, outfile);
                remaining_size -= bytes_to_write;
            }
        }
    }

    // Handle triple indirect blocks
    if (remaining_size > 0 && ip->i3block != 0) {
        int *i3block = (int *)&rawdata[ip->i3block * BLOCK_SZ];
        for (int i = 0; i < BLOCK_SZ / sizeof(int) && remaining_size > 0; i++) {
            int *i2block = (int *)&rawdata[i3block[i] * BLOCK_SZ];
            for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
                int *ind_block = (int *)&rawdata[i2block[j] * BLOCK_SZ];
                for (int k = 0; k < BLOCK_SZ / sizeof(int) && remaining_size > 0; k++) {
                    bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                    memcpy(buf, &rawdata[ind_block[k] * BLOCK_SZ], bytes_to_write);
                    fwrite(buf, 1, bytes_to_write, outfile);
                    remaining_size -= bytes_to_write;
                }
            }
        }
    }
}


void write_unused_blocks(const char *output_path) {
    char filepath[PATH_MAX];
    snprintf(filepath, sizeof(filepath), "%s/UNUSED_BLOCKS", output_path);

    FILE *unused_blocks_file = fopen(filepath, "w");
    if (!unused_blocks_file) {
        perror("Failed to open UNUSED_BLOCKS file for writing");
        return;
    }

    for (uint blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
        if (bitmap[blockno] == 0) {
            fprintf(unused_blocks_file, "%u\n", blockno);
        }
    }

    fclose(unused_blocks_file);
}


void extraction(uint uid, uint gid, const char *output_path) {
    for (uint blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
        struct inode *ip = (struct inode *)&rawdata[blockno * BLOCK_SZ];

        for (uint i = 0; i < INODES_PER_BLOCK; i++) {
            if (ip[i].uid == uid && ip[i].gid == gid && ip[i].size > 0) {
                char filepath[PATH_MAX];
                snprintf(filepath, sizeof(filepath), "%s/extracted_file_%d_%d", output_path, blockno, i);

                FILE *outfile = fopen(filepath, "wb");
                if (!outfile) {
                    perror("Failed to open output file");
                    continue;
                }

                // Extract and write file data
                extract_file_data(&ip[i], outfile);
                fclose(outfile);
                 //printf("Processing inode at block %u\n", blockno);

                // Print the block number where the inode was found and the file size
                printf("file found at inode in block %u, file size %d\n", blockno, ip[i].size);
            }
        }
    }
    write_unused_blocks(output_path);
}





int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Usage: disk_image -create or -insert\n");
        exit(-1);
    }

    const char *image_filename;
    int N, M, D, I, UID, GID;
    const char *in_filename;

    if (strcmp(argv[1], "-create") == 0) {
        if (argc != 18) {
            fprintf(stderr, "Usage: disk_image -create ...\n");
            exit(-1);
        }

        for (int i = 2; i < 17; ++i) {
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

        TOTAL_BLOCKS = N;
        INODE_BLOCKS = M;
        DATA_BLOCKS = N - M;
        if (D >= M) {
      perror("\nERROR:\n D must be less than M\n");
      exit(0);
    }
    if (I >= INODES_PER_BLOCK) {
      perror("\nERROR:\n invalid inode position\n");
      exit(0);
    }

        create_disk_image(TOTAL_BLOCKS, BLOCK_SZ);  // Allocate memory

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

        size_t i = fwrite(rawdata, BLOCK_SZ, TOTAL_BLOCKS, outfile);
        if (i != TOTAL_BLOCKS) {
            perror("Failed to write to output file");
            fclose(outfile);
            free(rawdata);
            free(bitmap);
            exit(-1);
        }

        fclose(outfile);
        free(rawdata);
        free(bitmap);
    } 


    else if (strcmp(argv[1], "-insert") == 0) {
        if (argc != 18) {
            fprintf(stderr, "Usage: disk_image -insert ...\n");
            exit(-1);
        }

        for (int i = 2; i < 17; ++i) {
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

        TOTAL_BLOCKS = N;
        INODE_BLOCKS = M;
        DATA_BLOCKS = N - M;
        if (D >= M) {
      perror("\nERROR:\n D must be less than M\n");
      exit(-1);
    }
    if (I >= INODES_PER_BLOCK) {
      perror("\nERROR:\n invalid inode position\n");
      exit(-1);
    }

        load_disk_image(image_filename);  // Load existing disk image

        place_file((char *)in_filename, UID, GID, D, I);

        FILE *outfile = fopen(image_filename, "wb");
        if (!outfile) {
            perror("Failed to open output file");
            free(rawdata);
            free(bitmap);
            exit(-1);
        }

        size_t i = fwrite(rawdata, BLOCK_SZ, TOTAL_BLOCKS, outfile);
        if (i != TOTAL_BLOCKS) {
            perror("Failed to write to output file");
            fclose(outfile);
            free(rawdata);
            free(bitmap);
            exit(-1);
        }

        fclose(outfile);
        free(rawdata);
        free(bitmap);
    }

   if (strcmp(argv[1], "-extract") == 0) {
    if (argc != 10) {
        fprintf(stderr, "Usage: -extract\n");
        exit(-1);
    }

    int UID = 0, GID = 0;
    const char *image_filename, *PATH;
    
    for (int i = 2; i < argc; i += 2) {
        if (strcmp(argv[i], "-image") == 0) {
            image_filename = argv[i + 1];
        } else if (strcmp(argv[i], "-u") == 0) {
            UID = atoi(argv[i + 1]);
        } else if (strcmp(argv[i], "-g") == 0) {
            GID = atoi(argv[i + 1]);
        } else if (strcmp(argv[i], "-o") == 0) {
            PATH = argv[i + 1];
        }
    }

    if (!image_filename || UID == 0 || GID == 0 || !PATH) {
        fprintf(stderr, "Missing or invalid arguments for -extract\n");
        exit(-1);
    }

    load_disk_image(image_filename);  // Load existing disk image
    extraction(UID, GID, PATH);
    free(rawdata);
    free(bitmap);
}
       
  

    printf("Done.\n");
    return 0;
}




  
  
/*
 
  */
  
  