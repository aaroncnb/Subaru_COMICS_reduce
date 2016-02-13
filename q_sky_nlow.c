/*=======================================================================*/
/*  q_sky_nlow                                                           */
/*     COMICS N ÄãÊ¬»¶€Îsky²èÁü€«€éÇÈÄ¹³ÓÀµŒ°€òµá€á€ë                    */
/*                                                        Version 3
   $Log$
                                                                         */
/*=======================================================================*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "q_lib.h"

#define  DETX   500    /* ž¡œÐŽïxŒŽÊýžþŒè°·ºÇÂçÃÍ */
#define  DEBUG     0       /* ¥Ç¥Ð¥Ã¥°ÍÑ€ÎÊÑ¿ô(Ÿò·ï¥³¥ó¥Ñ¥€¥ë€Ë»ÈÍÑ) */

#define  LOOPNUMA   100  /* 200 */
#define  LOOPNUMB   400  /* 500 */
#define  ABIN      0.000005
#define  BBIN      0.001
#define  DEFA      0.0199
#define  DEFB      7.650

/*=======================================================================*/
/*   ¹œÂ€ÂÎ€ÎÀëžÀ                                                             */
/*   ÇÈÄ¹³ÓÀµŒ°€Î¥Ñ¥é¥á¡Œ¥¿                                                   */
typedef struct {
   double a;   /* fit parameter a */
   double b;   /* fit parameter b */
   double cr;  /* correlation coefficient */
   int32_t slit;  /* slit width */
} WAVE_FIT_PAR;

/*=======================================================================*/
void print_usage(char *);
int check_command_line(int,char **,char **,SPECIFIED_DATA *,WAVE_FIT_PAR *);
int skyline_data_nlow(double *) ;
double correlate(int32_t,double *,double *) ;
int q_skyfit_nlow(int32_t *,double *,int32_t,WAVE_FIT_PAR *) ;
int check_call_list_stat(SPECIFIED_DATA *) ;
int q_call_list_1list(SPECIFIED_DATA *,int32_t *,double *,int32_t *);
int q_list_stat_1list_func(SPECIFIED_DATA *,int32_t *,double *,int32_t *);
/*=======================================================================*/
void print_usage(char *s)
{
char *ss;

  ss=strip_name(s);
  fprintf(stdout,
"NAME\n"
"       %s - COMICS N ÄãÊ¬»¶€Îsky²èÁü€«€éÇÈÄ¹³ÓÀµŒ°€òµá€á€ë\n\n"
"SYNOPSIS\n"
"       %s fits_file w x_region default  z slit\n"
"       %s fits_file w x_region y        z slit\n"
"       %s fits_file w x_region y_region z slit\n\n"
"       %s fits_file w x_region default  z slit init_a init_b\n"
"       %s fits_file w x_region y        z slit init_a init_b\n"
"       %s fits_file w x_region y_region z slit init_a init_b\n\n"
"DESCRIPTION\n"
"       %s €Ï fits_file €ÇÍ¿€š€é€ì€¿²èÁü¥Õ¥¡¥€¥ë€ò²£Êýžþ€ËÀÚ€Ã€Æ¡¢\n"
"       €œ€Î¥Ô¡Œ¥¯€òsky€ÎÊüŒÍµ±Àþ€ÈÈæ³Ó€·€ÆN ÄãÊ¬»¶€ÎÇÈÄ¹³ÓÀµŒ°€òµá€á€ë\n"
"       €¿€á€Î€â€Î€Ç€¹¡£€œ€Î€¿€á¡¢ÆþÎÏ²èÁüfits_file€Ïsky€Î²èÁü(Àž²èÁü€«€é\n"
"       ¥À¡Œ¥¯€ò°ú€­¡¢€µ€é€Ë€Ê€ë€Ù€¯€Ê€é¥Õ¥é¥Ã¥È€Ç³ä€Ã€¿€â€Î)€ò»È€Š€Ù€­\n"
"       €Ç€¹¡£€Þ€¿¡¢€³€Î¥×¥í¥°¥é¥à€Ç€Ï N ÃæÊ¬»¶¡¢N ¹âÊ¬»¶¡¢ Q ÃæÊ¬»¶€Ë€Ï\n"
"       ÂÐ±þ€·€Æ€€€Þ€»€ó¡£\n\n"
"       °ì€Ä€á€ÎœñŒ°(4€Ä€á€Î°ú¿ô(y€ÎÈÏ°Ï»ØÄê)€Ë'default'€È€¢€ëŸì¹ç)\n"
"       €Ç€Ï¡¢ÇÈÄ¹³ÓÀµŒ°€Ï¡¢¥Ç¥Õ¥©¥ë¥È€Îy€ÎÃÍ€Ë€Ä€€€ÆÀÚ€êœÐ€·\n"
"       €Æ¥Õ¥£¥Ã¥È€·€¿·ë²Ì€òœÐÎÏ€·€Þ€¹¡£žœºß€Î¥Ç¥Õ¥©¥ë¥ÈÃÍ€Ï¡¢\n"
"               y=30,40,50,60,70,80,90,100,110,120,130,140,150,160,\n"
"                 180,190,200,210,220 \n"
"       €Î20²Õœê€Ë€Ê€Ã€Æ€€€Þ€¹¡£\n\n"
"       €¢€ëÆÃÄê€Îy€Ë€Ä€€€ÆÀÚ€êœÐ€·€Æ¥Õ¥£¥Ã¥È€ò¹Ô€€€¿€€Ÿì¹ç€Ë€Ï¡¢2€Ä€á\n"
"       €Ê€€€·3€Ä€á€ÎœñŒ°€òÍÑ€€€Æ¡¢€œ€Îy(€¢€ë€€€Ïy€ÎÈÏ°Ï)€ò»ØÄê€·€Þ€¹¡£\n"
"       y€ÏÈÏ°Ï€Ç»ØÄê€¹€ë€³€È€¬µö€µ€ì€Æ€€€Þ€¹€¬¡¢ŒÂºÝ€Î¥Õ¥£¥Ã¥È€ÏSN€¬\n"
"       ÎÉ€€žÂ€ê¡¢€Ê€ë€Ù€¯Ÿ¯€Ê€€yÈÏ°Ï€Ë€Ä€€€Æ¹Ô€ï€Ê€€€È¡¢µ±Àþ€¬€Ê€Þ€Ã€Æ\n"
"       ¥Õ¥£¥Ã¥È€¬€Š€Þ€¯€€€«€Ê€¯€Ê€ë²ÄÇœÀ­€¬€¢€ê€Þ€¹¡£\n\n"
"       €€€º€ì€ÎœñŒ°€Ç€â¡¢ÈÏ°Ï»ØÄê€Î»ÅÊý€Ïq_list_stat€È€ª€Ê€žœñŒ°€ËœŸ€€\n"
"       €Þ€¹¡£€Ê€ªw,z€Ï°ìÅÀ¡¢x€ÏÈÏ°Ï(€·€«€âa-b€Î·ÁŒ°)€Ç€¢€ëÉ¬Í×€¬€¢€ê€Þ€¹¡£\n\n"
"       slit€Ï¡¢ŽÑÂ¬»þ€Ë»ÈÍÑ€·€¿¥¹¥ê¥Ã¥È€Î¥µ¥€¥º€Ç€¹¡£pixÁêÅöÃ±°Ì€Ç\n"
"       ÆþÎÏ€·¡¢N¥Ð¥ó¥ÉÄãÊ¬»¶€ÎŸì¹ç¡¢2,3,4,6€ÎÃæ€«€é°ì€ÄÁª€ó€ÇÆþÎÏ€·€Þ€¹¡£\n\n"
"       1-3€Ä€á€ÎœñŒ°€Ç€Ï¡¢¥Õ¥£¥Ã¥È€¹€ë¥Ñ¥é¥á¡Œ¥¿a€ª€è€Ób€ÎÈÏ°Ï€Ï¡¢\n"
"       ¥×¥í¥°¥é¥à€Î¥Ç¥Õ¥©¥ë¥ÈÃÍ€ò»È€€€Þ€¹¡£žœºß€Î¥Ç¥Õ¥©¥ë¥ÈÃÍ€Ï\n"
"            a .... %8.5e - %8.5e      b .... %8.5e - %8.5e\n"
"       €Ë€Ê€Ã€Æ€€€Þ€¹¡£\n"
"       a€ª€è€Ób€ÎÈÏ°Ï€òÀßÄê€·€¿€€Ÿì¹ç€Ë€Ï4-6€Ä€á€ÎœñŒ°€òÍÑ€€€Þ€¹¡£\n"
"       €³€ÎŸì¹ç¡¢ºÇÅ¬¥Ñ¥é¥á¡Œ¥¿€Ï\n"
"            a .... [ init_a - %f , init_a + %f ]\n"
"            b .... [ init_b - %f , init_b + %f ]\n"
"       €ÎÈÏ°Ï€ÇÃµ€µ€ì€Þ€¹¡£\n\n"
"       ÆþÎÏ²èÁü€ÎŒ¡žµ€Ï¡¢NAXIS=3€Þ€¿€Ï4€Î€ßÂÐ±þ€·€Þ€¹¡£NAXIS4€ÎÃÍ€Ï€€€¯€Ä€Ç€â\n"
"       €«€Þ€€€Þ€»€ó€¬¡¢±é»»€Ïw=w€ÎÉôÊ¬€Ë€Ä€€€Æ¹Ô€€€Þ€¹¡£€Þ€¿¡¢NAXIS3€ÎÃÍ€â\n"
"       €€€¯€Ä€Ç€â€«€Þ€€€Þ€»€ó€¬¡¢COMA²èÁü€ÎÊ£¿ô€Îz€¬»Ä€Ã€Æ€€€ë²èÁü€ËÂÐ€·€Æ\n"
"       ¹Ô€Š€Î€Ï¡¢ÄÌŸï¡¢»þŽÖ€¬ÌµÂÌ€Ë€Ê€ë€È»×€ï€ì€Þ€¹¡£(Ã»€€»þŽÖ€Ç€ÎÇÈÄ¹ÊÑ²œ\n"
"       €òž«€¿€€€È€­€Ï€â€Á€í€óŒÂ¹Ô€·€Æ°ÕÌ£€¬€¢€ê€Þ€¹€¬)\n"
"       NAXIS1€ª€è€ÓNAXIS2€Ï¡¢ž·Ì©€ËCOMICS€Îž¡œÐŽï€Îx,y¿ô€Ë°ìÃ×€·€Æ€€€ëÉ¬Í×\n"
"       €Ï€¢€ê€Þ€»€ó¡£€³€Î€¿€á¡¢²èÁü€Î€æ€¬€ßÊäÀµ€Ê€É€Ç¡¢x,y¿ô€¬ÊÑ²œ€·€¿²èÁü\n"
"       €Ë€âÂÐ±þ€Ç€­€Þ€¹€¬¡¢ÂçÉý€ËCOMICSž¡œÐŽï€Î¥Õ¥©¡Œ¥Þ¥Ã¥È€«€é€º€ì€ë€È¡¢\n"
"       Âçµ€µ±Àþ¥Õ¥£¥Ã¥È€¬€Ç€­€Ê€¯€Ê€ê€Þ€¹¡£€³€ì€Ï¡¢žœºß€³€Î¥×¥í¥°¥é¥à€Ç€Ï¡¢\n"
"       ¥Õ¥£¥Ã¥È¥Ñ¥é¥á¡Œ¥¿€ò€¢€ë°ìÄê€ÎÈÏ°ÏÆâ€ÇÊÑ²œ€µ€»€Ê€¬€é¡¢€â€Ã€È€âÁêŽØ\n"
"       ·ž¿ô€Î¹â€¯€Ê€ëŸìœê€òÃµ€·€Æ€€€ë€¿€á€Ç€¹¡£\n\n"
	  ,ss,ss,ss,ss,ss,ss,ss,ss,DEFA-ABIN*LOOPNUMA/2,DEFA+ABIN*LOOPNUMA/2,
	  DEFB-BBIN*LOOPNUMB/2,DEFB+BBIN*LOOPNUMB/2,
	  ABIN*LOOPNUMA/2,ABIN*LOOPNUMA/2,BBIN*LOOPNUMB/2,BBIN*LOOPNUMB/2);
}
/*=======================================================================*/
int main(int argc, char ** argv)
{
char *ifile;
SPECIFIED_DATA spd;
static int x[DETX];
int32_t data_num ;
static double v[DETX];
int32_t j;
char buf[WORD_LEN];
WAVE_FIT_PAR fitpar ;

/* Check command line */
  if(check_command_line(argc,argv,&ifile,&spd,&fitpar)!=0) {
    fprintf(stdout,"Error @ check_command_line\n");exit(1);}

/* Open input file and out put files */
  if((spd.data.fp=fopen(ifile,"r"))==NULL){
    fprintf(stdout,"Cannot open %s\n",ifile);exit(1);}

/* Check NAIXISs */
  if(read_head(&(spd.data))!=0){
     fprintf(stdout,"Error @ read_fits_data 1 \n");return(-1);}
  if(spd.data.nax==3) {
     if(atoi(argv[2])!=1) {
        fprintf(stdout,"NAXIS=3. Then w must be 1.\n") ;
        exit(1) ;
     }
  } else if (spd.data.nax!=4) {
     fprintf(stdout,"NAXIS must be 3 or 4.\n") ;
     exit(1) ;
  }

/* Operation */
  if(spd.yr!=-1) {  /* »ØÄêy(1²Õœê)€Ç¥Õ¥£¥Ã¥È */
     /* q_list_stat €ÎžÆœÐ€·Ÿò·ï€Î¥Á¥§¥Ã¥¯ */
     if(check_call_list_stat(&spd)!=0) {
        fprintf(stdout,"Error @ check_call_list_stat\n");exit(1);}
     if(q_call_list_1list(&spd,x,v,&data_num)!=0){
        fprintf(stdout,"Error @ q_call_list_1list \n");exit(1);
     }
/*   for(i=0;i<data_num;i++) { fprintf(stdout,"%d   %e\n",x[i],v[i]) ; } */
     if(q_skyfit_nlow(x,v,data_num,&fitpar)!=0){
         fprintf(stdout,"Error @ q_sky_nlow \n");exit(1);
     }
     fprintf(stdout,"%s  y= %s : a= %8.5e  b= %8.5e  corr= %8.5e\n",ifile,argv[4],fitpar.a,fitpar.b,fitpar.cr) ;
  } else {  /* ¥Ç¥Õ¥©¥ë¥È€Îy€Ç¥Õ¥£¥Ã¥È */
     for(j=40;j<=220;j+=10) { /* Setting j=40, since data are missing at pixels where Y > 40*/
        sprintf(buf,"%d",j) ;
        region_input(buf,&(spd.y0),&(spd.y1),&(spd.yr));
        /* q_list_stat €ÎžÆœÐ€·Ÿò·ï€Î¥Á¥§¥Ã¥¯ */
        if(check_call_list_stat(&spd)!=0) {
           fprintf(stdout,"Error @ check_call_list_stat\n");exit(1);}
        if(q_call_list_1list(&spd,x,v,&data_num)!=0){
           fprintf(stdout,"Error @ q_call_list_1list\n");exit(1);
        }
/*      for(i=0;i<data_num;i++) { fprintf(stdout,"y=%d: %d   %e\n",j,x[i],v[i]) ; } */
        if(q_skyfit_nlow(x,v,data_num,&fitpar)!=0){
            fprintf(stdout,"Error @ q_skyfit_nlow \n");exit(1);
        }
        fprintf(stdout,"%s  y= %d : a= %8.5e  b= %8.5e  corr= %8.5e\n",ifile,j,fitpar.a,fitpar.b,fitpar.cr) ;
     }
  }
        
/* Close */
  fclose(spd.data.fp);
  exit(0);
}
/*=======================================================================*/
int check_command_line(int argc,char ** argv ,char **ifile,
                       SPECIFIED_DATA *spd,WAVE_FIT_PAR *fitpar)
{
int32_t  x;

  if(argc==1){/* This is normal usage query  */
     print_usage(argv[0]);exit(0);}

  if(argc==7 || argc==9) {
     *ifile = argv[1] ;
     region_input(argv[2],&(spd->w0),&(spd->w1),&(spd->wr));
     region_input(argv[3],&(spd->x0),&(spd->x1),&(spd->xr));
     if(strcmp("default",argv[4])==0) {
        spd->yr=-1 ;
     } else { region_input(argv[4],&(spd->y0),&(spd->y1),&(spd->yr)); }
     region_input(argv[5],&(spd->z0),&(spd->z1),&(spd->zr));
     x=atoi(argv[6]) ;
     if(x==2 || x==3 || x==4 || x==6) { fitpar->slit=x ;}
     else {
        fprintf(stdout,"Bad slit width. Choose from 2,3,4 and 6.\n") ;
        return(-1) ;
     }
     if(argc==9) {
        fitpar->a=(double)atof(argv[7]) ;
        fitpar->b=(double)atof(argv[8]) ;
     } else {
        fitpar->a=DEFA ;
        fitpar->b=DEFB ;
     }
  } else {
     print_usage(argv[0]) ; return(-1) ;
  }

  return(0) ;
}
/*=======================================================================*/
int skyline_data_nlow(double *x)
/* Âçµ€ÊüŒÍ€Îµ±Àþ°ÌÃÖŸðÊó€òÍ¿€š€ë
   x ....... Âçµ€ÊüŒÍ€Îµ±Àþ€ÎÇÈÄ¹ (micron)
             (R¡Á250€Çatran€Ç·×»»€·€¿€È€­€ÎÊüŒÍÎš(¡á£±¡ŒÆ©²áÎš)€Î¶ËÂç¡£
             ¥µ¥ó¥×¥ëÅÀ€ÏR¡Á1250ÄøÅÙ€ÎºÙ€«€µ)
*/
{
   x[0]=7.03200 ; x[1]=7.16000 ; x[2]=7.28000 ; x[3]=7.33600 ;
   x[4]=7.46400 ; x[5]=7.59200 ; x[6]=7.67200 ; x[7]=7.76000 ;
   x[8]=7.87200 ; x[9]=8.03200 ; x[10]=8.16800 ; x[11]=8.24800 ;
   x[12]=8.34400 ; x[13]=8.42400 ; x[14]=8.51200 ; x[15]=8.58400 ;
   x[16]=8.68800 ; x[17]=8.80000 ; x[18]=8.92000 ; x[19]=9.00000 ;
   x[20]=9.03200 ; x[21]=9.08000 ; x[22]=9.16800 ; x[23]=9.25600 ;
   x[24]=9.31200 ; x[25]=9.49600 ; x[26]=9.63200 ; x[27]=9.72000 ;
   x[28]=10.26400 ; x[29]=10.48000 ; x[30]=10.54400 ; x[31]=10.8240 ;
   x[32]=11.0000 ; x[33]=11.1440 ; x[34]=11.2720 ; x[35]=11.3760 ;
   x[36]=11.4800 ; x[37]=11.5600 ; x[38]=11.7280 ; x[39]=11.9040 ;
   x[40]=11.9680 ; x[41]=12.0880 ; x[42]=12.2800 ; x[43]=12.3760 ;
   x[44]=12.4480 ; x[45]=12.5280 ; x[46]=12.6240 ; x[47]=12.7440 ;
   x[48]=12.8800 ; x[49]=13.0000 ; x[50]=13.2640 ; x[51]=13.4880 ;
   x[52]=13.6960 ; x[53]=13.8880 ;
   return(54) ;
}
/*=======================================================================*/
double correlate(int32_t n,double *f, double *g)
/* ¥Ç¡Œ¥¿Îóf€Èg€ÎÁêžßÁêŽØ·ž¿ô€ò·×»»€¹€ë
   n .... f,g€ÎŽÞ€à¥Ç¡Œ¥¿¿ô
   f .... ¥Ç¡Œ¥¿Îó1  f(t)    (ŒÂž³ÃÍ€òÁÛÄê)
   g .... ¥Ç¡Œ¥¿Îó2  g(t-ŠÓ) (Èæ³ÓÍÑ€òÁÛÄê)
   €³€ÎŽØ¿ô€Ç€Ï€¿€ÀÃ±€Ë¡¢ÃÙ€ì€Ê€·€Ç€ÎÁêžßÁêŽØ€ò·×»»€¹€ë€À€±€Ê€Î€Ç¡¢
   ÃÙ€ìŠÓ€Ï€³€ÎŽØ¿ô€òžÆ€ÖÁ°€ËÀßÄê€·€Æf,g€òf(t),g(t-ŠÓ)€È€·€Æ·×»»
   €·€Æ€³€ÎŽØ¿ô€ËÍ¿€š€ë€³€È
          f[i]=f(t) , g[i]=g(t-ŠÓ)
   f,g€ÏÆ±€ž¥Ç¡Œ¥¿¿ô€ò»ý€Ä€³€È
   ÊÖ€êÃÍ¡§ ÁêžßÁêŽØ·ž¿ô(r)
*/
{
   int32_t  i ;
   double sum,fsum,gsum ;
   double r ;

   sum=0 ; fsum=0 ; gsum=0 ;
   for(i=0;i<n;i++) { sum+=f[i]*g[i] ; fsum+=f[i]*f[i] ; gsum+=g[i]*g[i] ; }
   r=sum/sqrt(fsum)/sqrt(gsum) ;

   return(r) ;
}
/*=======================================================================*/
int q_skyfit_nlow(int32_t *x1,double *y1,int32_t n,WAVE_FIT_PAR *fitpar)
/* ¥Ç¡Œ¥¿Îó(x1,y1)=(pixel,count)€ËÂÐ€·€ÆÂçµ€µ±Àþ€ò¥Õ¥£¥Ã¥È€·€ÆÇÈÄ¹³ÓÀµŒ°€ò
   µá€á€ë
      x1 ........... ¥Ç¡Œ¥¿ÎóxŒŽ(¥Ô¥¯¥»¥ë€ËÂÐ±þ)
      y1 ........... ¥Ç¡Œ¥¿ÎóyŒŽ(x1€Ç€Î¥«¥Š¥ó¥È€ËÂÐ±þ)
      n ............ ¥Ç¡Œ¥¿Îó€Î»ý€Ä¥Ç¡Œ¥¿¿ô( (x1,y1)€ÎÁÈ€Î¿ô)
      fitpar.a ..... ÇÈÄ¹³ÓÀµŒ°¥Ñ¥é¥á¡Œ¥¿a
      fitpar.b ..... ÇÈÄ¹³ÓÀµŒ°¥Ñ¥é¥á¡Œ¥¿b
      fitpar.corr .. ÇÈÄ¹³ÓÀµŒ°¥Ñ¥é¥á¡Œ¥¿corr

    cf. ÇÈÄ¹³ÓÀµŒ° : ŠË[micron] = a * x[pix] + b
*/
{
   int32_t i,j,k,p ;
   static double x2[DETX] ; /* reference data */
   static double x[DETX],y[DETX] ;    /* 2-value sky */
   static double xr[DETX],yr[DETX] ;   /* 2-value model */
   double xrp ;
   int32_t rn ;       /* data¥Õ¥¡¥€¥ëÃæ€Î¥Ç¡Œ¥¿¿ô */
   double corr ; /* ÁêžßÁêŽØ·ž¿ô */
   double a,b,afit,bfit,a0,b0 ;
   double max, div ;

   a0=fitpar->a ; b0=fitpar->b ;

   /* ¥Ç¡Œ¥¿Îó€¬Ÿ¯€Ê€¹€®€ë€È¥Õ¥£¥Ã¥È€Ç€­€Ê€€ */
   if(n<20) {
      fprintf(stderr,"Too small number of data in datafile.\n") ;
      return(-1) ;
   }

   /* ¥Ç¡Œ¥¿€Î¶ËÂçÃÍÃµ€·€È£²ÃÍ¥¹¥Ú¥¯¥È¥ë€ÎºîÀ® */
   /* œéŽü²œ */
   for(i=0;i<=n;i++) { y[i]=0; }
   /* ÆþÎÏ¥Ç¡Œ¥¿€ËÂÐ€·€Æ¡¢slitÉý€Îµ¬³Ê²œ€·€¿¥¬¥Š¥·¥¢¥ó€Î¶¯ÅÙÊ¬ÉÛ€ò */
   /* ¶ËÂç€òÃæ¿Ž€È€·€ÆÂåÆþ€·€Æ¡¢¥Ô¡Œ¥¯Ê¬ÉÛ€Ë€Ê€ª€¹                 */
   /* slitÉý2pix€Î€È€­                                             */
   if(fitpar->slit==2) {
      x[0]=x1[0] ; xr[0]=x1[0] ;
      for(i=1;i<(n-1);i++) {
         x[i]=x1[i] ; xr[i]=x1[i] ;
         if(y1[i]>y1[i-1] && y1[i]>y1[i+1]) { /* ¶ËÂç */
            y[i]+=1 ;
            y[i-1]+=0.382546 ; y[i+1]+=0.382546 ;
            /* y[i-2]+=0.021416 ; y[i+2]+=0.021416 ; */
         }
      }
      x[n-1]=x1[n-1] ; xr[n-1]=x1[n-1] ;
   } else {
      fprintf(stdout,"slit=%d is not supported.\n",fitpar->slit) ;
      return(-1) ;
   }

   /* ¥Ç¡Œ¥¿ÆÉ€ß¹þ€ß 2: reference (g€ËÁêÅö) */
   rn=skyline_data_nlow(x2) ;

   /* slitÉý€¬2pix€ÎŸì¹ç */
   if(fitpar->slit==2) {
      div=2.*0.721347*0.721347 ;
   } else {
      fprintf(stdout,"slit=%d is not supported.\n",fitpar->slit) ;
      return(-1) ;
   }

   /* ¥Õ¥£¥Ã¥È */
   /* Œ°€Î¥Ñ¥é¥á¡Œ¥¿€¬a,b€Î€È€­€Ëreference€Ë€¢€ë¥Ô¡Œ¥¯ÇÈÄ¹€ò¡¢¥Ç¡Œ¥¿Îó€Îx€Ë */
   /* ÊÑŽ¹€·€Æ¡¢sky€Î¥â¥Ç¥ë¶¯ÅÙÊ¬ÉÛ(¥Ô¡Œ¥¯Ê¬ÉÛ)€òºîÀ®€·¡¢ÎŸŒÔ€òÈæ³Ó¡£       */
   /* ÁêžßÁêŽØ·ž¿ô€ÎºÇ€â¹â€€€È€³€í€Ç¥Õ¥£¥Ã¥È€È€ß€Ê€¹                        */
   max=0 ; afit=0 ; bfit=0 ;
   for(i=0;i<=LOOPNUMA;i++) {
      a=a0+(i-LOOPNUMA/2.)*ABIN ;
      for(j=0;j<=LOOPNUMB;j++) {
         b=b0+(j-LOOPNUMB/2.)*BBIN ;
         for(k=0;k<n;k++) { yr[k]=0 ; }
         /* ŠË = a * x + b <--> x = ( ŠË - b ) / a */
         for(k=0;k<rn;k++) {
            xrp=(x2[k]-b)/a ;
            if(xrp>xr[2] && xrp<xr[n-3]) { /* ¥Ç¡Œ¥¿€Î€¢€ëÈÏ°Ï€Îreference€Ë€Ä€€€Æ */
               p=n-1 ;
               while(xrp<xr[p]) {
                  p-- ;
                  if(p>(n-2)) { break ; }
               } /* €³€ì€¬œª€Ã€¿»þÅÀ€Ç xrp>xr[p]€Ë€Ê€ë */
               yr[p]+=exp(-(xr[p]-xrp)*(xr[p]-xrp)/div) ;
               yr[p+1]+=exp(-(xr[p+1]-xrp)*(xr[p+1]-xrp)/div) ;
               yr[p-1]+=exp(-(xr[p-1]-xrp)*(xr[p-1]-xrp)/div) ;
               yr[p+2]+=exp(-(xr[p+2]-xrp)*(xr[p+2]-xrp)/div) ;
               /*
               yr[p-2]+=exp(-(xr[p-2]-xrp)*(xr[p-2]-xrp)/div) ;
               yr[p+3]+=exp(-(xr[p+3]-xrp)*(xr[p+3]-xrp)/div) ;
               */
            }
         }
         corr=correlate(n,y,yr) ;
         if(max<corr) { max=corr ; afit=a ; bfit=b ; }
      }
   }
   if(afit==a0-LOOPNUMA/2*ABIN || afit==a0+LOOPNUMA/2*ABIN ||
      bfit==b0-LOOPNUMA/2*ABIN || bfit==b0+LOOPNUMA/2*ABIN ) {
      fprintf(stdout,"Best correlation at the end of the search range.\n") ;
      return(-1) ;
   }
   fitpar->a=afit ;
   fitpar->b=bfit ;
   fitpar->cr=max ;

   return(0) ;
}

/*=======================================================================*/
/* q_list_stat €ÎžÆœÐ€·Ÿò·ï€Î¥Á¥§¥Ã¥¯                                         */
int check_call_list_stat(SPECIFIED_DATA *spd)
{
  if(spd->wr!=REG_POINT || spd->zr!=REG_POINT){ /* w,z€Ï°ìÅÀ€Î€ß */
    fprintf(stdout,"w_region or z_region error - w and z must be a point.\n");
    return(-1);
  }
  if(spd->xr!=REG_LIST) { /* x€Ï¥ê¥¹¥È */
    fprintf(stdout,"x_region error - x must be a list.\n") ;
    return(-1);
  }
  if(spd->yr!=REG_POINT && spd->yr!=REG_REGION) {
    fprintf(stdout,"y_region error - y  must be a point or a region.\n") ;
    return(-1);
  }

  return(0) ;
}
/*=======================================================================*/
int q_call_list_1list(SPECIFIED_DATA *spd,int32_t *xx,double *yy,int32_t *data_num)
{
FITS_DATA *data;
int32_t b;

/* q_list_stat €ÎžÆœÐ€·Ÿò·ï€Î¥Á¥§¥Ã¥¯ */
/* €³€ì€Ï¡¢Ÿì¹ç€Ë€è€ë€Î€Ç¡¢€³€ÎŽØ¿ô€òžÆ€ÖŽØ¿ô€Ç¹Ô€Š
  if(spd->wr!=REG_POINT || spd->zr!=REG_POINT){
    fprintf(stdout,"w_region or z_region error - w and z must be a point.\n");
    return(-1);
  }
  if(spd->xr!=REG_LIST) {
    fprintf(stdout,"x_region error - x must be a list.\n") ;
    return(-1);
  }
  if(spd->yr!=REG_POINT && spd->yr!=REG_REGION) {
    fprintf(stdout,"y_region error - y  must be a point or a region.\n") ;
    return(-1);
  }
*/

/* ÈÏ°Ï»ØÄê¥Ñ¥é¥á¡Œ¥¿€ÎÄŽÀ° */
/* Read header of the input file  */
  data = &(spd->data);
  if(read_head(data)!=0){
     fprintf(stdout,"Error @ q_list_stat (read_head) \n");return(-1);}
/* Set region */
/* Z dim  */
  if(spd->z1<spd->z0) {b=spd->z0;spd->z0=spd->z1;spd->z1=b;}
  if(spd->z0==REG_MIN) spd->z0=1; if(spd->z1==REG_MIN) spd->z1=1;
  if(spd->z0==REG_MAX) spd->z0=data->nz; if(spd->z1==REG_MAX) spd->z1=data->nz;
  if( spd->z0<1 || spd->z1>data->nz ) {
     fprintf(stdout,"NAXIS3=%"PRId32" z0=%"PRId32" z1=%"PRId32"\n",data->nz,spd->z0,spd->z1);
     return(-1);
  }
/* X dim */
  if(spd->x1<spd->x0) {b=spd->x0;spd->x0=spd->x1;spd->x1=b;}
  if(spd->x0==REG_MIN) spd->x0=1; if(spd->x1==REG_MIN) spd->x1=1;
  if(spd->x0==REG_MAX) spd->x0=data->nx; if(spd->x1==REG_MAX) spd->x1=data->nx;
  if( spd->x0<1 || spd->x1>data->nx ) {
    fprintf(stdout,"NAXIS1=%"PRId32" x0=%"PRId32" x1=%"PRId32"\n",data->nx,spd->x0,spd->x1);
    return(-1);
  }
/* Y dim */
  if(spd->y1<spd->y0) {b=spd->y0;spd->y0=spd->y1;spd->y1=b;}
  if(spd->y0==REG_MIN) spd->y0=1; if(spd->y1==REG_MIN) spd->y1=1;
  if(spd->y0==REG_MAX) spd->y0=data->ny;if(spd->y1==REG_MAX) spd->y1=data->ny;
  if( spd->y0<1 || spd->y1>data->ny ) {
    fprintf(stdout,"NAXIS2=%"PRId32" y0=%"PRId32" y1=%"PRId32"\n",data->ny,spd->y0,spd->y1);
    return(-1);
  }
/* W dim */
  if(spd->w1<spd->w0) {b=spd->w0;spd->w0=spd->w1;spd->w1=b;}
  if(spd->w0==REG_MIN) spd->w0=1; if(spd->w1==REG_MIN) spd->w1=1;
  if(spd->w0==REG_MAX) spd->w0=data->nw; if(spd->w1==REG_MAX) spd->w1=data->nw;
  if( spd->w0<1 || spd->w1>data->nw ) {
    fprintf(stdout,"NAXIS4=%"PRId32" w0=%"PRId32" w1=%"PRId32"\n",data->nw,spd->w0,spd->w1);
    return(-1);
  }

/* Allocate memory for data */
  if(alloc_memory_for_data(data)!=0){
    fprintf(stdout,"data1 allocation\n"); return(-1) ;}

/* Case 1 : List of 1(x,y,z) axis or no list */
  q_list_stat_1list_func(spd,xx,yy,data_num);

  free(data->data);
  return(0);
}
/*=======================================================================*/
/* q_list_stat €Ç 1Êýžþ(x,y,z)€Î¥ê¥¹¥È €Þ€¿€Ï¥ê¥¹¥È€Ê€·                  */
/*     FITS¥Ç¡Œ¥¿»ØÄêÈÏ°Ï(1ŒŽ¥ê¥¹¥È)€Î¥Ç¡Œ¥¿€ÈÅÀ¿ô€ò°ú¿ô€È€·€ÆÊÖ€¹       */

int q_list_stat_1list_func(SPECIFIED_DATA *spd,int32_t *xx,double *yy,int32_t *data_num)
{
int32_t n,d,x,y,z,i;
float * data;
FITS_DATA *data1;
fpos_t pos;
double w;
int32_t axis ;

  data1 = &(spd->data);
  if(spd->xr == REG_LIST) axis=1;
  else if(spd->yr == REG_LIST) axis=2;
  else if(spd->zr == REG_LIST) axis=3;
  else { axis=0 ; }

  if(axis==1){
    *data_num = spd->x1 - spd->x0 + 1 ;
  }else if(axis==2){

    *data_num = spd->y1 - spd->y0 + 1 ;
  }else if(axis==3){
    *data_num = spd->z1 - spd->z0 + 1 ;
  }else {
    *data_num = 1 ;
  }

/* Allocate memory for data */
  if( (data = (float *)malloc(*data_num*sizeof(float)))==NULL ){
    fprintf(stdout,"malloc error [q_list_stat_1list data]\n");return(-1);}

  for(n=0;n<*data_num;n++){ 
    *(yy+n)=0.00;
  }

/* Skip detecter */
  for(d=0;d<spd->w0-1;++d){
    for(z=0;z<data1->nz;++z) {
      if(read_2d_data(data1)!=0) return(-1) ;
    }
  }
/* Calculation */
  n=0;
  fgetpos(data1->fp,&pos);
  for(z=0;z<spd->z0-1;++z) { if(read_2d_data(data1)!=0) return(-1) ; }
  for(z=spd->z0-1;z<=spd->z1-1;++z) {
    if(read_2d_data(data1)!=0) return(-1) ;
    for(y=spd->y0-1;y<=spd->y1-1;++y){
    for(x=spd->x0-1;x<=spd->x1-1;++x){
      i = x+y*data1->nx ;
      if(axis==1) { *(xx+(x-(spd->x0-1)))=x+1; }
      else if(axis==2) { *(xx+(y-(spd->y0-1)))=y+1; }
      else if(axis==3) { *(xx+(z-(spd->z0-1)))=z+1; }
      else  { *(xx+(x-(spd->x0-1)))=x+1; }
      if(data1->bp == LONG_DATA){
        w = (double)(((long *)data1->data)[i]);
      }else if(data1->bp == SHORT_DATA){
        w = (double)(((short *)data1->data)[i]);
      }else if(data1->bp == CHAR_DATA){
        w = (double)(((unsigned char *)data1->data)[i]);
      }else if(data1->bp == DOUBLE_DATA){
        w = (double)(((double *)data1->data)[i]);
      }else {fprintf(stdout,"Internal error\n");return(-1); }
      if(axis==1){        *(yy+(x-(spd->x0-1))) += w ;
      }else if(axis==2) { *(yy+(y-(spd->y0-1))) += w ;
      }else if(axis==3) { *(yy+(z-(spd->z0-1))) += w ;
      }else             { *yy += w ; 
      }
      n++;
    }}
  }
  n /= *data_num ;
  for(i=0;i<*data_num;i++){
    *(yy+i) /= (double)n;
  }
  free(data);
  return(0);
}
