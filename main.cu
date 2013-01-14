/*
 * Russell Taylor(rtaylor)
 * Matt Crusse(macrusse)
 * CPE458-01 Lab 1 Winter 2013 
 */

#include <sys/stat.h>
#include <sys/mman.h> 
#include <errno.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>


/*Compile-Time Declaration on double or float usage*/
#ifdef DOUBLE
#define TYPEUSE double

#else
#define TYPEUSE float

#endif


/*Reads Input File and Returns Buffer of Contents*/
char* read_file(const char * file_name) 
{
  size_t size;
  char *buffer;
  FILE *fp;
  
  fp = fopen(file_name,"r");
  if(!fp) {
    fprintf (stderr, "Error opening input file.\n");
    exit (EXIT_FAILURE);    
  }

  fseek (fp, 0, SEEK_END);
  size = ftell(fp);
  rewind (fp);
  
  buffer = (char*) malloc (sizeof(char)*size);
  fread (buffer, 1, size, fp);
  fclose(fp);
  return buffer;
}

/*Calculate the Resultant Matrix from Multiplication*/
void calc_matrix(TYPEUSE **A, TYPEUSE **B, TYPEUSE **C, int Arow, int Acol, int Brow, int Bcol)
{
  int i, j, k;
  TYPEUSE sum = 0;
  for(i = 0; i < Arow; i++)//Iterate through Matrix B columnwise
  {
    for(j = 0; j < Bcol; j++)//Iterate through Matrix A rowwise
    {
        for(k = 0; k < Acol; k++)//Acol = Brow on valid Matrices
        {
            sum+= A[i][k] * B[k][j];
        }
        C[i][j] = sum;
        sum = 0;
    }
  }
}

/* Print matrix values to a file outputfile */
void output_matrix(const char * outputfile, TYPEUSE **matrix, int row, int col) 
{
  int i, j;

  FILE *ofp = fopen(outputfile, "w");
  if(!ofp){
    fprintf (stderr, "Error opening output file.\n");
    exit (EXIT_FAILURE);    
  }

  for(i = 0; i < row; i++) {
    for(j = 0; j < col; j++) {
      fprintf(ofp, "%.2f ",matrix[i][j]);
    }  
    if(i < row-1){
      fprintf(ofp, "\n");
    }
  }
  fclose(ofp);
}

void print_matrix(const char * outputfile, TYPEUSE **matrix, int row, int col) 
{
  int i, j;

  /*FILE *ofp = fopen(outputfile, "w");
  if(!ofp){
    fprintf (stderr, "Error opening output file.\n");
    exit (EXIT_FAILURE);    
  }*/

  for(i = 0; i < row; i++) {
    for(j = 0; j < col; j++) {
      printf("%.2f ",matrix[i][j]);
    }  
    if(i < row-1){
      printf("\n");
    }
  }
  //fclose(ofp);
}

/*Created a Matrix based on Buffered Input Information*/
TYPEUSE ** read_matrix(int * rowCnt, int * colCnt, char * mapped)
{
  TYPEUSE value;  
  const char *delim_space = " ";
  char *token = NULL;  
  char *unconverted;
  int i, j, len;
  TYPEUSE **matrix;
  long bigiter;
  *colCnt = 0;
  *rowCnt = 0;

  
  /* Determine Col Count */
  i = 0;
  while(mapped[i] != '\n'){
    if(mapped[i] == '.') {
     (*colCnt)++;
    }
    i++;
  }  

  /* Determine Row Count */
  bigiter = 0;//For large file sizes, an int is too small to iterate through
  len = strlen(mapped);
  while(bigiter < len && mapped[bigiter] != '\0'){
    if((mapped[bigiter] == '\n') && (mapped[bigiter+1] != '\0') ) {
     (*rowCnt)++;
    }
    bigiter+=1;
  }
  (*rowCnt)++;

  /* Malloc the Matrix */
  if (( matrix = (TYPEUSE**) malloc((*rowCnt) * sizeof(TYPEUSE*))) == NULL ) {
    printf("malloc issue");
  }
  for(i = 0; i < (*rowCnt); i++) {
    if (( matrix[i] = (TYPEUSE*) malloc((*colCnt) * sizeof(TYPEUSE))) == NULL ) {
      printf("inside malloc issue");
    }
  }
    
  /* Read values into matrix */
  i = 0; j = 0;
  for (token = strtok(mapped, delim_space); token != NULL; token = strtok(NULL, delim_space)) {
    value = strtod(token, &unconverted);
    matrix[i][j] = value;
    j++;
    if(j == (*colCnt)) {
      j = 0;
      if(++i == (*rowCnt))
	break;
    }
  }
  return matrix;

}
/*Frees 2D Matrices*/
void free_matrix(TYPEUSE ** matrix, int row)
{
  int i;

  for(i = 0; i < row; i++) 
  {
    free(matrix[i]);
  }
  
  free(matrix);
}
int main (int argc, const char * argv[])
{

  const char * Cfile = "result.out";
  TYPEUSE ** Amatrix, ** Bmatrix, ** Cmatrix;

  int Arow, Acol, Brow, Bcol;
  int i;

  char * Amapped, * Bmapped;

  if(argc != 3)
  { 
    fprintf(stderr, "Usage: [Matrix A] [Matrix B]\n");
    exit(EXIT_FAILURE);
  }

  Amapped = read_file(argv[1]);
  Bmapped = read_file(argv[2]);

  Amatrix = read_matrix(&Arow, &Acol, Amapped); 
  Bmatrix = read_matrix(&Brow, &Bcol, Bmapped);
  
  if(Acol != Brow)
  {
    fprintf(stderr, "Matrices are not a compatible size to be multipliedi\n");
    exit(EXIT_FAILURE);
  }
  
  /* Malloc a New Matrix */
  if (( Cmatrix = (TYPEUSE**)malloc((Arow) * sizeof(TYPEUSE*))) == NULL ) {
    printf("malloc issue");
  }
  for(i = 0; i < Arow; i++) {
    if (( Cmatrix[i] = (TYPEUSE*)malloc((Bcol) * sizeof(TYPEUSE))) == NULL ) {
      printf("inside malloc issue");
    }
  }

  calc_matrix(Amatrix, Bmatrix, Cmatrix, Arow, Acol, Brow, Bcol);

  output_matrix(Cfile, Cmatrix, Arow, Bcol);
  
  /* Free Stuff */
  free_matrix(Amatrix, Arow);
  free_matrix(Bmatrix, Brow);
  free_matrix(Cmatrix, Arow);
  free(Amapped);
  free(Bmapped);

  return 0;
}
