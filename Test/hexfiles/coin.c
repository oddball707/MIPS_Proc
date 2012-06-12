/***********************************************************************/
/*                                                                     */
/* This program is free to copy !                                      */
/*                                                                     */
/* Program: coin.c                                                     */
/*                                                                     */
/* Description:                                                        */
/*                                                                     */
/* Take a pile of n coins, all with the same side upp. Then turn the   */
/* uppermost coin, the 2 uppermost coins, the 3 uppermost coins and    */
/* so on. When you have turned all n coins you start to turn the       */
/* uppermost coin again and so on.                                     */
/*                                                                     */
/* The question is: How many turns are nedded before all coins have    */
/* the same side upp again ?                                           */
/*                                                                     */
/* Answer: Run the program !                                           */
/*                                                                     */
/* Algorithm and program by: Stefan Spaennare, Lund October 1994       */
/* Email:                    stefans@astro.lu.se                       */
/* Latest update:            98-06-22                                  */
/*                                                                     */
/* Benchmark:                                                          */
/*                                                                     */
/* nmin=1, nmax=200                                                    */
/*                                                                     */
/* Processor:             CPU-time (s):            Compilation:        */
/*                                                                     */
/* Pentium 180 MHz           10.66                    gcc -O3          */ 
/*                                                                     */
/***********************************************************************/

/*****************************************************************************/
/*                                                                           */
/* Notice:                                                                   */
/* =======                                                                   */
/*                                                                           */
/* I make no warranties that this program is (1) free of error, (2) con-     */
/* sistent with any standard merchantability, or (3) meeting the require-    */
/* ments of a particular application.  This software shall not, partly or    */
/* as a whole, participate in a process, whose outcome can result in injury  */
/* to a person or loss of property. It is solely designed for analytical     */
/* work.  Permission to use, copy, and distribute is hereby granted without  */
/* fee, providing that the header above including this notice appears in     */
/* all copies.                                                               */
/*                                                                           */
/*                                                         Stefan Spaennare  */
/*                                                                           */
/*****************************************************************************/

#include "cse148.h"


   int correctvalues[11] = {8099, 5460, 1655, 3720, 1692,
			    9025, 4607, 1164, 9603, 9801,
			    3299};


int begin(argc,argv)
int argc;
char *argv[];
{

   int i,j,k,sum,n,m,s,t,nmin,nmax,m2,temp;

   int v[1021];

   int found = 0;

   nmin = 90;
   nmax = 100;

   for (i=1; i<=nmax; i++) {
      v[i]=1;
   } /* for i */

   for (k=nmin; k<=nmax; k++) {

      s=0;
      m=1;

      do {

	 m2=m>>1;

	 for (i=1; i<=m2; i++) {
	    temp=v[i];
	    v[i]=-v[m-i+1];
	    v[m-i+1]=-temp;
	 } /* for i */

	 if ((m % 2) == 1) {
	    v[m2+1]=-v[m2+1];
	 } /* if */

	 sum=0;

	 for (i=1; i<=k; i++) {
	    sum=sum+v[i];
	 } /* for i */

	 m++;
	 s++;

	 if (m > k) {
	    m=1;
	 } /* if */

      } while (sum != k);

      //      printf("%d\n", s);

      if (correctvalues[found++] == s)
      	PASS(found);
      else
      	FAIL(found);

   } /* for k */

   DONE(found);

} /* end */
