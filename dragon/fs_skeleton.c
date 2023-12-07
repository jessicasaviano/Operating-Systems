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

//int free_blocks;
#define INODE_SIZE sizeof(struct inode)
#define INODES_PER_BLOCK (BLOCK_SZ / INODE_SIZE)


static unsigned char *rawdata;
static char *bitmap;


int get_free_block()
{
    for (int blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
        if (bitmap[blockno] == 0) {  
            bitmap[blockno] = 1;  // Mark the block as used
            //printf("Allocating block number: %d\n", blockno);
            return blockno;         
        }
    }

    return -1;  // Return -1 to indicate no free block is available
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
  
    memcpy(&rawdata[pos], val, sizen);
   
}

void create_disk_image(uint total_blocks, uint block_size) {
    rawdata = (unsigned char *)calloc(total_blocks, block_size);
    if (!rawdata) {
        perror("Failed to allocate memory for rawdata");
        exit(-1);
    }
   bitmap = (char *)calloc(total_blocks, sizeof(char));
    memset(bitmap, 0, total_blocks * sizeof(char));

    //bitmap = (char *)(rawdata + INODE_BLOCKS * block_size);
    //memset(bitmap, 0, total_blocks * sizeof(char));   // Pointing to the section in rawdata allocated for bitmap
    /*
    for (int i = 0; i < INODE_BLOCKS; i++) {
        bitmap[i] = 1;
    }
*/
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
  
  struct inode *ip = (struct inode *)&rawdata[block_pos_inode * BLOCK_SZ + inode_position * INODE_SIZE];

  if (ip->nlink > 0 || ip->size > 0 || ip->uid != 0 || ip->gid != 0) {
    fprintf(stderr, "Error!!!! Inode position at the block number %u, position %u is already in use\n", block_pos_inode, inode_position);
    free(rawdata);
    free(bitmap);
    exit(-1);
}

  FILE *fpr;
  unsigned char buf[BLOCK_SZ];
  ip->mode = 0;
  ip->nlink = 1;
  ip->uid = uid;
  ip->gid = gid;
  //printf("uid = %d\n", uid);
  //printf("guid = %d\n", gid);
  ip->ctime = 1; //?
  ip->mtime = 1; //?
  ip->atime = 1; //?


  fpr = fopen(file, "rb");
  if (!fpr) {
    perror(file);
    free(rawdata);
    free(bitmap);
    exit(-1);
  }

  //HANDLE DIRECT BLOCKS

  for (i = 0; i < N_DBLOCKS && !feof(fpr); i++) {
    blockno = get_free_block();
    //printf("blockno: %d\n", blockno);
        if (blockno == -1) {
            fclose(fpr);
            return;
        }
        
    ip->dblocks[i] = blockno;
   
    bitmap[blockno] = 1;
        //printf("%d\n", bitmap[blockno]);
    
    
    size_t bytes_read = fread(buf, 1, BLOCK_SZ, fpr);
     //printf("int: %ld\n",bytes_read);

    write_block(blockno * BLOCK_SZ, buf, bytes_read);
    ip->size += bytes_read;
  }

 //IF THE FILE SIZE EXCEEDS THE CAPACITY OF THE DIRECT BLOCKS, THEN WE HAVE TO USE INDIRECT!
  for (int i = 0; i < N_IBLOCKS && !feof(fpr); i++) {
       
        int iblock_no = get_free_block();
        if (iblock_no == -1) {
            fclose(fpr);
            return;
        }
        ip->iblocks[i] = iblock_no;  //pointers to indirect blocks
        bitmap[iblock_no] = 1;
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
        bitmap[i2block_no] = 1;
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
        bitmap[i3block_no] = 1;
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
    
}

 
void extract_file_data(struct inode *ip, FILE *outfile) {
    unsigned char buf[BLOCK_SZ];
    size_t bytes_to_write;
   
 size_t remaining_size = (ip->size);

    // Handle direct blocks
    for (int i = 0; i <(N_DBLOCKS) && remaining_size > 0; i++) {
   
        bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
        memcpy(buf, &rawdata[ip->dblocks[i] * BLOCK_SZ], bytes_to_write);
        fwrite(buf, 1, bytes_to_write, outfile);
        remaining_size -= bytes_to_write;
    }

    // Handle single indirect blocks!!!!
    for (int i = 0; i < N_IBLOCKS && remaining_size > 0; i++) {
        if (rawdata[i] == 00){
            continue;
         }
        int *iblock = (int *)&rawdata[ip->iblocks[i] * BLOCK_SZ];
        for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
            bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
            memcpy(buf, &rawdata[iblock[j] * BLOCK_SZ], bytes_to_write);
            fwrite(buf, 1, bytes_to_write, outfile);
            remaining_size -= bytes_to_write;
        }}
    // Handle double indirect blocks!!!!
    if (remaining_size > 0 && ip->i2block != 0) {
        int *i2block = (int *)&rawdata[ip->i2block * BLOCK_SZ];
        for (int i = 0; i < BLOCK_SZ / sizeof(int) && remaining_size > 0; i++) {
            int *ind_block = (int *)&rawdata[i2block[i] * BLOCK_SZ];
            for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
                bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                memcpy(buf, &rawdata[ind_block[j] * BLOCK_SZ], bytes_to_write);
                fwrite(buf, 1, bytes_to_write, outfile);
                remaining_size -= bytes_to_write;
            }}}
    // Handle triple indirect blocks!!!!!!
    if (remaining_size > 0 && ip->i3block != 0) {     
        int *i3block = (int *)&rawdata[ip->i3block * BLOCK_SZ];
        for (int i = 0; i < BLOCK_SZ / sizeof(int) && remaining_size > 0; i++) {
            int *i2block = (int *)&rawdata[i3block[i] * BLOCK_SZ];
              // Handle triple indirect blocks,equation for all indirect block from slides
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
/*
void write_unused_blocks(const char *output_path) {
    char filepath[PATH_MAX];
    snprintf(filepath, sizeof(filepath), "%s/UNUSED_BLOCKS", output_path);

    FILE *unused_blocks_file = fopen(filepath, "w");
    if (!unused_blocks_file) {
        perror("Failed to open UNUSED_BLOCKS file for writing");
        return;
    }

    for (uint blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
         //printf("blockno: %d\n", bitmap[blockno]);
        
        if (bitmap[blockno] == 0) {
            fprintf(unused_blocks_file, "%u\n", blockno);
        }
    }

    fclose(unused_blocks_file);
}

*/

void extraction(uint uid, uint gid, const char *output_path) {
    for (uint blockno = 0; blockno < TOTAL_BLOCKS; blockno++) {
        struct inode *ip = (struct inode *)&rawdata[blockno * BLOCK_SZ];

        for (uint i = 0; i < INODES_PER_BLOCK; i++) {
            if (ip[i].uid == uid && ip[i].gid == gid ) {

                char filepath[PATH_MAX];
                snprintf(filepath, sizeof(filepath), "%s/extracted%d-%d", output_path, blockno, i);

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
                //printf("HEY! FILE FOUND! at inode in block %u and file size %d\n", blockno, ip[i].size);
            }
        }
    }
    
   // write_unused_blocks(output_path);
}

/*


void scan_disk_image(unsigned char *disk_image, char *bitmap) {

   
    size_t bytes_to_write;

    for (uint blockno = 0; blockno < INODE_BLOCKS; blockno++) {
        struct inode *inodes = (struct inode *)&disk_image[blockno * BLOCK_SZ];

        for (uint i = 0; i < INODES_PER_BLOCK; i++) {
            struct inode *ip = &inodes[i];
            size_t remaining_size = ip->size;

            if (ip->nlink != 0) {
                // Mark direct blocks as used
                for (int k = 0; k < N_DBLOCKS && remaining_size > 0; k++) {
                    bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                    bitmap[ip->dblocks[k]] = 1;
                    remaining_size -= bytes_to_write;
                }

                // Handle single indirect blocks
                for (int j = 0; j < N_IBLOCKS && remaining_size > 0; j++) {
                    if (ip->iblocks[j] != 0) {
                        int *iblock = (int *)&disk_image[ip->iblocks[j] * BLOCK_SZ];
                        for (int l = 0; l < BLOCK_SZ / sizeof(int) && remaining_size > 0; l++) {
                            if (iblock[l] != 0) {
                                bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                                bitmap[iblock[l]] = 1;
                                remaining_size -= bytes_to_write;
                            }
                        }
                    }
                }

                // Handle double indirect blocks
                if (remaining_size > 0 && ip->i2block != 0) {
                    int *i2block = (int *)&disk_image[ip->i2block * BLOCK_SZ];
                    for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
                        if (i2block[j] != 0) {
                            int *ind_block = (int *)&disk_image[i2block[j] * BLOCK_SZ];
                            for (int l = 0; l < BLOCK_SZ / sizeof(int) && remaining_size > 0; l++) {
                                if (ind_block[l] != 0) {
                                    bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                                    bitmap[ind_block[l]] = 1;
                                    remaining_size -= bytes_to_write;
                                }
                            }
                        }
                    }
                }

                // Handle triple indirect blocks
                if (remaining_size > 0 && ip->i3block != 0) {
                    int *i3block = (int *)&disk_image[ip->i3block * BLOCK_SZ];
                    for (int j = 0; j < BLOCK_SZ / sizeof(int) && remaining_size > 0; j++) {
                        if (i3block[j] != 0) {
                            int *i2block = (int *)&disk_image[i3block[j] * BLOCK_SZ];
                            for (int m = 0; m < BLOCK_SZ / sizeof(int) && remaining_size > 0; m++) {
                                if (i2block[m] != 0) {
                                    int *ind_block = (int *)&disk_image[i2block[m] * BLOCK_SZ];
                                    for (int l = 0; l < BLOCK_SZ / sizeof(int) && remaining_size > 0; l++) {
                                        if (ind_block[l] != 0) {
                                            bytes_to_write = (remaining_size < BLOCK_SZ) ? remaining_size : BLOCK_SZ;
                                            bitmap[ind_block[l]] = 1;
                                            remaining_size -= bytes_to_write;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
*/

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, " Usage\n");
        exit(-1);
    }

    const char *image_filename;
    int N, M, D, I, UID, GID;
    const char *in_filename;
    

    if (strcmp(argv[1], "-create") == 0) {
        if (argc != 18) {
            fprintf(stderr, "problem with -create ...\n");
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

/*
       printf("Bitmap status: ");
    for (int i = 0; i < TOTAL_BLOCKS; i++) {
        printf("%d", bitmap[i]);
    }
    printf("\n");
    */

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
        

        //create first byte of every block
        /*
        printf("Bitmap status: ");
    for (int i = 0; i < TOTAL_BLOCKS; i++) {
        printf("%d", bitmap[i]);
    }
    printf("\n");
    */
   

        fclose(outfile);
        free(rawdata);
        free(bitmap);
       
    } 


    else if (strcmp(argv[1], "-insert") == 0) {
        if (argc != 18) {
            fprintf(stderr, "disk_image -insert ...\n");
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

       FILE *image_fptr = fopen(image_filename, "rb");
    if (!image_fptr) {
        perror("Error opening image file to read");
        exit(-1);
    }
    //printf("%s\n", image_fptr);
    // Determine the file size
    fseek(image_fptr, 0, SEEK_END);
    long file_size = ftell(image_fptr);
    fseek(image_fptr, 0, SEEK_SET);
    //printf("%ld\n", file_size);
    // Ensure file size is a multiple of BLOCK_SZ
    if (file_size % BLOCK_SZ != 0) {
        fprintf(stderr, "Disk image file size isn't a multiple of BLOCK_SZ\n");
        fclose(image_fptr);
        exit(-1);
    }

    // Allocate memory according to the file size
    if (rawdata != NULL) {
        free(rawdata);  // Free any previously allocated memory
    }
    rawdata = (unsigned char *)malloc(file_size);
 

    // Read the file into rawdata
    size_t result = fread(rawdata, 1, file_size, image_fptr);
    if (result != file_size) {
        perror("Error reading image file");
        fclose(image_fptr);
        free(rawdata);
        exit(-1);
    }

    bitmap = (char *)malloc(TOTAL_BLOCKS * sizeof(char));
    memset(bitmap, 0, TOTAL_BLOCKS * sizeof(char));
   
   //add here
   /*
    for (int i = 0; i < INODE_BLOCKS; i++) {
        bitmap[i] = 1;
    }
    */
    // Scan the disk image and update bitmap for used blocks
    // Assuming you have a function scan_disk_image that updates bitmap
    

       
    
    fclose(image_fptr);
    

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
           
            exit(-1);
        }

        fclose(outfile);
        free(rawdata);
        free(bitmap);
       
    }

   if (strcmp(argv[1], "-extract") == 0) {
    if (argc != 10) {
        fprintf(stderr, "problem with -extract\n");
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
        fprintf(stderr, "Missing or wrong arguments for -extract\n");
        exit(-1);
    }

    
       FILE *image_fptr1 = fopen(image_filename, "rb");
    if (!image_fptr1) {
        perror("Error opening image file to read");
        exit(-1);
    }


    fseek(image_fptr1, 0, SEEK_END);
    long file_size = ftell(image_fptr1);
    fseek(image_fptr1, 0, SEEK_SET);

    
    if (file_size % BLOCK_SZ != 0) {
        fprintf(stderr, "Disk image file size isn't a multiple of BLOCK_SZ\n");
        fclose(image_fptr1);
        exit(-1);
    }

    rawdata = (unsigned char *)malloc(file_size);
   
    // Read the file into rawdata
    size_t result = fread(rawdata, 1, file_size, image_fptr1);
    if (result != file_size) {
        perror("Error reading image file");
        fclose(image_fptr1);
        free(rawdata);
        exit(-1);
    }

       
     TOTAL_BLOCKS = file_size / BLOCK_SZ;
 
     
   
    bitmap = (char *)malloc(TOTAL_BLOCKS * sizeof(char));
    memset(bitmap, 0, TOTAL_BLOCKS * sizeof(char));
   
     //printf("%x\n", INODE_BLOCKS);

    //scan_disk_image(rawdata, bitmap);
/*
    printf("Bitma22p status:\n");
    for (uint i = 0; i < TOTAL_BLOCKS; i++) {
        printf("%d",bitmap[i]);
    }
    printf("\n");

*/
    
    fclose(image_fptr1);

    extraction(UID, GID, PATH);
    
  

        free(rawdata);
        free(bitmap);
          
}

       
    printf("Done.\n");
    return 0;
}
