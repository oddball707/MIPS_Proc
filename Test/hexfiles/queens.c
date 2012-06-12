/*EightQueens Program using two Stacks , Stacks are implemented using arrays */
#include "cse148.h"

#define print_port 0x3ff0
#define print_char_port 0x3ff1
#define print_int_port 0x3ff2
#define print_long_port 0x3ff4

#define uart_port               0x03ffc //for 16KRAM
#define uart_wport uart_port
#define uart_rport uart_port
#define int_set_address 0x03ff8 //for 16KRAM

void print_uart(unsigned char* ptr)//
{
       unsigned int uport;
       #define WRITE_BUSY 0x0100


       while (*ptr) {

               do {
                 uport=*(volatile unsigned*)   uart_port;
               } while (uport & WRITE_BUSY);
               *(volatile unsigned char*)uart_wport=*(ptr++);
       }
}

void putc_uart(unsigned char c)//
{
       unsigned int uport;


       do {
                 uport=*(volatile unsigned*)   uart_port;
       } while (uport & WRITE_BUSY);
       *(volatile unsigned char*)uart_wport=c;

}


void print(unsigned char* ptr)//Verilog Test Bench Use
{
       while (*ptr) {*(volatile unsigned char*)print_port=*(ptr++);}

       *(volatile unsigned char*)print_port=0x00;//Write Done
}

void print_char(unsigned char val)//Little Endian write out 16bit number
{
       *(volatile unsigned char*)print_port=(unsigned char)val ;

}

void print_num(unsigned long num)
{
  unsigned long digit,offset;
  for(offset=1000;offset;offset/=10) {
     digit=num/offset;
       putc_uart(digit+'0');
     num-=digit*offset;
  }
}


//      *********************************************

#define NUMQUEENS 9

typedef struct
{
       int x,y;
} position;

void SolveProblem(int n);
int N=0;
int begin (void)
{
       N = NUMQUEENS;
       SolveProblem(N);

       return 0;
}

position head1[NUMQUEENS*NUMQUEENS];
int stack2[NUMQUEENS];

void SolveProblem(int n)
{
       int counter1,counter2=-1,counter3=-1, i,j;
       int counter=0;
       int d[100][3];
       position Position1,Position2,Position3;
       for (i=0;i<100;i++)
       for (j=0;j<3;j++)
               d[i][j] = 0;

       for(counter1=n-1;counter1>=0;counter1--)
       {
               Position1.x=0;
               Position1.y=counter1;
               head1[++counter2]=Position1;
       }

       while(counter2>=0)
       {
               Position1=head1[counter2--];
               while(counter3>=0 && Position1.x<=counter3)
               {
                       Position2.x=counter3;
                       Position2.y=stack2[counter3--];
                       d[Position2.y][0]=0;
                       d[Position2.x+Position2.y][1]=0;
                       d[Position2.x-Position2.y+n][2]=0;
               }

               stack2[++counter3]=Position1.y;
               d[Position1.y][0]=1;
               d[Position1.x+Position1.y][1]=1;
               d[Position1.x-Position1.y+n][2]=1;

               if(counter3==n-1)
               {
                       counter++;
                       PASS(counter);
//                      printf("\nSOLUTION # %d:",counter);
                       for(counter1=0;counter1<=counter3;counter1++)
//                      printf("(%d,%d) " ,counter1+1, stack2[counter1]+1);
                       Position2.x=counter3;
                       Position2.y=stack2[counter3--];
                       d[Position2.y][0]=0;
                       d[Position2.x+Position2.y][1]=0;
                       d[Position2.x-Position2.y+n][2]=0;
               }
               else
               {
                       for(counter1=n-1;counter1>=0;counter1--)
                       if(d[counter1][0]==0 && d[Position1.x+1+counter1][1]==0 && d[n+Position1.x+1-counter1][2]==0)
                       {
                               Position3.x=Position1.x+1;
                               Position3.y=counter1;
                               head1[++counter2]=Position3;
                       }
               }
       }

//      printf("\n\nFinished!  Found %d solutions.\n", counter);
//      print_uart("\n Done.\n");
       DONE(counter);

}
