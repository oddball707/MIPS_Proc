/******************************************************/
/*                                                    */
/* This program is free to copy !                     */
/*                                                    */
/* Program: esift2.c                                  */
/*                                                    */
/* This program calculates the number of prime        */
/* numbers below n using Erathostenes sifter.         */
/*                                                    */
/* Author: Stefan Spaennare, July 1996                */
/* Email:  stefans@astro.lu.se                        */ 
/*                                                    */
/* Memory requirement: 0.065*n byte.                  */
/*                                                    */
/* Benchmarking:                                      */
/*                                                    */
/* n = 10000000 = 10^7                                */
/*                                                    */
/* Computer:       CPU-time (s):      Compilation:    */
/*                                                    */
/* HP 735 99 MHz       7.41             cc  +O3       */
/* Pentium 150 MHz     9.69             gcc -O4       */
/*                                                    */ 
/******************************************************/

#include "cse148.h"

int begin(argc,argv)
int argc;
char *argv[];
{
   unsigned long i,j,k,n,ns,m,i2,j2;
   unsigned long hh,ll,n8,sum;
   unsigned long bit,temp;

   unsigned long p[3128]; //n8+1

   n= 200000;

   n8= 3127; //  n8 = n/(2*32)+2;

   //p=(unsigned long *)calloc(n8+1,sizeof(unsigned long));

   for (i=0; i<=n8; i++) {
      p[i]=0;
   } /* for i */

   ns = 449; //ns=(int)(sqrt((double)(n)))+1;


   for (i=3; i<=ns; i=i+2) {
      i2=i<<1;
      for (j=i2; j<=n; j=j+i) {
         if ((j % 2) != 0) {
            j2=j>>1;
            hh=(j2>>5) + 1;
            ll=j2 % 32;
            bit= 1 << ll;
            p[hh]=p[hh] | bit;
         } /* if */
      } /* for j */
   } /* for i */

   sum=1;

   for (i=3; i<=n; i=i+2) {
      i2=i>>1;
      hh=(i2>>5) + 1;
      ll=i2 % 32;
      bit=1 << ll;
      temp=p[hh] & bit;
      if (temp == 0) {
         sum++;
      } /* if */
   } /* for i */
   
   //printf("%12d\n\n",sum);
   if (sum == 17984)
     DONE(1); 
   else
     FAIL(1);

} /* End */
