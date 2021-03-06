cvk  1/2008 ------------------------------------------------------------------
cvk  1/2008 Added option to normalize soil moisture
cvk  1/2008 To select this option, change the statement in the subr. header to
cvk  1/2008         PARAMETER (NORMALIZED = 1)
cvk  1/2008 Default not normalized option is
cvk  1/2008         PARAMETER (NORMALIZED = 0)
cvk  1/2008 ------------------------------------------------------------------

C MEMBER FLAND2
C  (from old member FCFLAND1)
C
      SUBROUTINE FLAND2(PXV,EDMND,TA,DT,SACST,FRZST,SACPAR,
     +     FRZPAR,NSOIL,NUPL,NSAC,IVERS,SURF,GRND,TCI,TET,
     +     SMC,SH2O,SACST_PRV,id,prflag)

CBL Removed all the snow and frozen soil stuff from the former subroutine
CBL FLAND1, since this is done within the Noah portion of the code in ULM
CBL and hence this subroutine was renamed to avoid confusion FLAND2.
cvk  1/2008  Introduced option to generate normalized SM
cvk  1/2008  To select this option, change the next parameter from 0 to 1
cvk  1/2008
cvk Normalized soil moisture content
cc      PARAMETER (NORMALIZE = 1)
cvk Not normalized soil moisture content
cc      PARAMETER (NORMALIZE = 0)

c  DT is in days here
C  DTFRZ IN SEC., IDTFRZ IS # FRZ_STEPS
C.......................................
C     THIS SUBROUTINE EXECUTES THE 'SAC-SMA ' OPERATION FOR ONE TIME
C         PERIOD.
C.......................................
C     SUBROUTINE INITIALLY WRITTEN BY. . .
C            ERIC ANDERSON - HRL     APRIL 1979     VERSION 1
C.......................................

CVK  FROZEN GROUND CHANGES
CVK  UZTWC,UZFWC,LZTWC,LZFSC,LZFPC ARE TOTAL WATER STORAGES
CVK  UZTWH,UZFWH,LZTWH,LZFSH,LZFPH ARE UNFROZEN WATER STORAGES

      PARAMETER (T0 = 273.16)
      REAL SACPAR(*),FRZPAR(*),SACST(*),FRZST(*),SACST_PRV(*)
      real smc(*),sh2o(*)
c SACPAR() is array of original SAC parameters, and FRZPAR() is array
c of frozen ground parameters and calculated constants
c SACST() and FRZST() same for states
        
c  delited real FGCO(6),ZSOIL(6),TSOIL(8),FGPM(11)      
      REAL LZTWM,LZFSM,LZFPM,LZSK,LZPK,LZTWC,LZFSC,LZFPC
      REAL LZTWH,LZFSH,LZFPH
      INTEGER PRFLAG

CVK----------------------------------------------------------------
CVK_02  NEW COMMON STATEMENT FOR DESIRED SOIL LAYERS
CVK     THIS VERSION HAS HARD CODED OUTPUT SOIL LAYERS
CVK     LATER ON IT SHOULD BE CHANGED TO MAKE THEM VARIABLE 
c      INTEGER NINT/5/,NINTW/5/
CBL      INTEGER NDSINT,NDINTW, NORMALIZE
CBL      REAL TSINT(*),SWINT(*),SWHINT(*)
ck      REAL DSINT(10)/0.075,0.15,0.35,0.75,1.5,0.0,0.0,0.,0.,0./
c      REAL DSINT(10)/0.10,0.40,0.6,0.75,1.5,0.0,0.0,0.,0.,0./      
ck      REAL DSINTW(10)/0.075,0.15,0.35,0.75,1.5,0.0,0.0,0.,0.,0./
CBL      REAL DSINT(*), DSINTW(*)
c      REAL DSINTW(10)/0.10,0.40,0.6,0.75,1.5,0.0,0.0,0.,0.,0./
CBL      REAL TSTMP(10),DSMOD(10),SWTMP(10),SWHTMP(10)
c      SAVE DSINT,DSINTW,NINT,NINTW
CVK----------------------------------------------------------------      

cc      DIMENSION EPDIST(24)
C     COMMON BLOCKS
cc      COMMON/FSMPM1/UZTWM,UZFWM,UZK,PCTIM,ADIMP,RIVA,ZPERC,REXP,LZTWM,
cc     1              LZFSM,LZFPM,LZSK,LZPK,PFREE,SIDE,SAVED,PAREA
CVK
CVK      COMMON/FPMFG1/FGPM(10)
c--      COMMON/FPMFG1/itta,FGPM(15),ivers,ifrze      

CVK_02  NEW COMMON BLOCK FOR INTERPOLATED SOIL TEMP AND SOIL PARAMETERS
c--      COMMON/TSLINT/TSINT(10),NINT,SWINT(10),SWHINT(10),NINTW
c--      COMMON/FRDSTFG/SMAX,PSISAT,BRT,SWLT,QUARTZ,STYPE,NUPL,NSAC,
c--     +               RTUZ,RTLZ,DZUP,DZLOW      
cc      COMMON/FRZCNST/ FRST_FACT,CKSOIL,ZBOT
c--      COMMON/FRZCNST/ FRST_FACT,ZBOT      
      
CVK
CVK  NEW FG VERSION PARAMETERS & SOIL LAYER DEFINITION:
CVK          FGPM(1) - SOIL TEXTURE CLASS
CVK          FGPM(2) - OPTIONAL, SOIL TEMPERATURE AT THE 3M DEPTH
CVK          FGPM(3) - OPTIONAL, POROSITY OF RESIDUE LAYER
CVK          PAR(18) [if no calb=FGPM(4)] - RUNOFF REDUCTION PARAMETER 1
CVK          PAR(19) [if no calb=FGPM(5)] - RUNOFF REDUCTION PARAMETER 2
CVK          PAR(20) [if no calb=FGPM(6)] - RUNOFF REDUCTION PARAMETER 3
CVK          FGPM(6) - RUNOFF REDUCTION PARAMETER 3 (FOR ERIC'S VERSION ONLY)
CVK          FGPM(7) - NUMBER OF SOIL LAYERS 
CVK          FGPM(8)-FGPM(15) - DEPTHS OF SOIL LAYERS (M), NEGATIVE.
CVK                             FIRST LAYER (RESIDUE) DEPTH=-0.03M

c--      COMMON/FSMCO1/UZTWC,UZFWC,LZTWC,LZFSC,LZFPC,ADIMC,FGCO(6),RSUM(7),
c--     1   PPE,PSC,PTA,PWE,PSH,TSOIL(8)     

c--      COMMON/FSUMS1/SROT,SIMPVT,SRODT,SROST,SINTFT,SGWFP,SGWFS,SRECHT,
c--     1              SETT,SE1,SE3,SE4,SE5

C
C    ================================= RCS keyword statements ==========
c--      CHARACTER*68     RCSKW1,RCSKW2
c--      DATA             RCSKW1,RCSKW2 /                                 '
c--     .$Source: /fs/hsmb5/hydro/CVS_root/gorms/sac/fland1.f,v $
c--     . $',                                                             '
c--     .$Id: fland1.f,v 2.5 2008/05/14 15:48:02 zcui Exp $
c--     . $' /
C    ===================================================================

CVK  ADDITION FOR FROZEN DEPTH ESTIMATION
c--      SAVE IIPREV,FRSTPREV,FRZPREV
c--      IF(FGCO(1) .EQ. 0.) THEN
c--       IIPREV=0
c--       FRSTPREV=0.
c--       FRZPREV=0.
c--      ENDIF
CVK--------------------------------------
       
C       write(*,*) ' FRZPAR:',(frzpar(ii),ii=1,6)
c define major parameters from the arra
      if (prflag == 1) then
         WRITE(*,*) 'FLAND2: SACST: ', (SACST(i), i=1, 6 )
         WRITE(*,*) 'FLAND2: FRZST: ', (FRZST(i), i= 6, 10 )
         WRITE(*,*) 'FLAND2: SACST_PRV: ', (SACST_PRV(i), i=1, 6 )
         WRITE(*,*) 'FLAND2: SACPAR: ', (SACPAR(i), i=1, 16)
         WRITE(*,*) 'FLAND2: FRZPAR: ', (FRZPAR(i), i=1, 13)
      endif

      UZTWM=SACPAR(1)
      UZFWM=SACPAR(2)
      if(prflag==2) write(*,*)'L 133 uzfwm',uzfwm
      ADIMP=SACPAR(5)
      LZTWM=SACPAR(9)
      LZFSM=SACPAR(10)
      LZFPM=SACPAR(11)
      PAREA=1.0-SACPAR(4)-ADIMP
      IF(IVERS .NE. 0) CKSL=FRZPAR(4)


c define states from the array
      UZTWC=SACST(1)
      UZFWC=SACST(2)
      if(prflag==2) write(*,*)'L 145 uzfwc',uzfwc
      LZTWC=SACST(3)
      if(prflag==1) write(*,*)'L 148 lztwc',lztwc
      LZFSC=SACST(4)
      LZFPC=SACST(5)
      ADIMC=SACST(6)

      if(prflag==1) then
         write(*,*)'UZTW',UZTWH,UZTWC,UZTWM
         write(*,*)'UZFW',UZFWH,UZFWC,UZFWM
         write(*,*)'LZTW',LZTWH,LZTWC,LZTWM
         write(*,*)'LZFP',LZFPH,LZFPC,LZFPM
         write(*,*)'LZFS',LZFSH,LZFSC,LZFSM
      endif
      if(prflag==2) then
      write(*,*) 'pars - ',UZTWM,UZFWM,SACPAR(3),SACPAR(4),SACPAR(5),
     &        SACPAR(6),SACPAR(7),SACPAR(8),LZTWM,LZFSM,LZFPM,
     &        SACPAR(12),SACPAR(13),SACPAR(14),SACPAR(15),SACPAR(16)
      write(*,*) 'start sac1 - states ', UZTWC,UZFWC,LZTWC,LZFSC,LZFPC,
     &           ADIMC
      write(*,*) '           - runoff ', ROIMP,SDRO,SSUR,SIF,BFS,BFP
      write(*,*) '           - ET ', E1,E2,E3,E4,E5,TET
      endif
c      WRITE(*,*) 'FLAND2: UZFWC= ', UZFWC
      IF(IVERS .EQ. 0) THEN
CVK  OLD FROZEN GROUND VERSION: KEEP UNFROZEN WATER = TOTAL
C--       RUZICE=UZK
C--       RLZICE=LZSK
C--       RUZPERC=1.0
       UZTWH=UZTWC
       UZFWH=UZFWC
       if(prflag==2) write(*,*)'L 168 uzfwh',uzfwh
       LZTWH=LZTWC
      if(prflag==1) write(*,*)'L 179 lztwh',lztwh
       LZFSH=LZFSC
       LZFPH=LZFPC
      ELSE        
CVK  NEW FROZEN GROUND VERSION: USE ESTIMATED UNFROZEN WATER
CVK  REDEFINE UNFROZEN WATER VARIABLES IF THEY ARE NEGATIVE
C       
       UZTWH=FRZST(6)
       IF(UZTWH .LT. 0.) UZTWH=0.
       UZFWH=FRZST(7)
       IF(UZFWH .LT. 0.) UZFWH=0.
       if(prflag==2) write(*,*)'L 180 uzfwh',uzfwh
       LZTWH=FRZST(8)
       if(prflag==1) write(*,*)'L 192 lztwh',lztwh
       IF(LZTWH .LT. 0.) LZTWH=0.
       if(prflag==1) write(*,*)'L 194 lztwh',lztwh
       LZFSH=FRZST(9)
       IF(LZFSH .LT. 0.) LZFSH=0.
       LZFPH=FRZST(10)
       IF(LZFPH .LT. 0.) LZFPH=0.
CVK  RUZICE & RLZICE ARE REDUCTION OF FREE WATER MOVEMENT 
CVK  BASED ON KULIK'S THEORY: Kfrz = Kunfrz/(1+FGPM(4)*ICE)**2 
       ZUP=FRZPAR(9+NUPL)
CBL    ZLW=FRZPAR(9+NSAC) 
CBL    Changed NSAC to NSOIL since these are not equal here
       ZLW=FRZPAR(9+NSOIL)
CBL       RUZICE=0.001*FRZPAR(6)*(UZTWC-UZTWH+UZFWC-UZFWH)/
CBL     +        (FRZPAR(10)-ZUP)
CBL  Changed FRZPAR(10) to 0 since surface layer not ignored here
       RUZICE=0.001*FRZPAR(6)*(UZTWC-UZTWH+UZFWC-UZFWH)/
     +        (0.0-ZUP)
       RLZICE=0.001*FRZPAR(7)*(LZTWC-LZTWH+LZFSC-LZFSH)/
     +        (ZUP-ZLW)
       RUZPERC=1.0
       IF(RUZICE .EQ. 0.) THEN
        RUZICE = SACPAR(3)
       ELSE 
        RUZPERC=1.0/((1.+CKSL*RUZICE)**2)
        RUZICE=1.-EXP(LOG(1.-SACPAR(3))*RUZPERC)
       ENDIF
       IF(RLZICE .EQ. 0.) THEN
        RLZICE = SACPAR(12)
       ELSE  
        RLZICE=1.0/((1.+CKSL*RLZICE)**2)
        RLZICE=1.-EXP(LOG(1.-SACPAR(12))*RLZICE)
       ENDIF 
      ENDIF
c      if(uztwc .ne. uztwh) WRITE(*,*) 'ST1=',uztwc,uztwh
c      if(uzfwc .ne. uzfwh) WRITE(*,*) 'ST2=',uzfwc,uzfwh
c      if(lztwc .ne. lztwh) WRITE(*,*) 'ST3=',lztwc,lztwh
c      if(lzfsc .ne. lzfsh) WRITE(*,*) 'ST4=',lzfsc,lzfsh
c      if(lzfpc .ne. lzfph) WRITE(*,*) 'ST5=',lzfpc,lzfph

C.......................................
C     COMPUTE EVAPOTRANSPIRATION LOSS FOR THE TIME INTERVAL.
C        EDMND IS THE ET-DEMAND FOR THE TIME INTERVAL
cc      EDMND=EP*EPDIST(KINT)
cVK ADJUST EDMND FOR EFFECT OF SNOW & FOREST COVER.
c from EX1 OFS subroutine
CBL    Removed the adjustment of PET for snow and forest cover
CBL    since these are handled elsewhere in the model
CBL      EDMND=(1.-(1.0-SACPAR(17))*AESC)*EDMND
C
C     COMPUTE ET FROM UPPER ZONE.
CVK      E1=EDMND*(UZTWC/UZTWM)
CVK  ONLY UNFROZEN WATER CAN BE EVAPORATED
      E1=EDMND*(UZTWH/UZTWM)

      RED=EDMND-E1
C     RED IS RESIDUAL EVAP DEMAND
CVK      UZTWC=UZTWC-E1
      UZTWH=UZTWH-E1

      E2=0.0
CV.K      IF(UZTWC.GE.0.) THEN
      IF(UZTWH.GE.0.) THEN
CV.K    SUBTRACT ET FROM TOTAL WATER STORAGE
       UZTWC=UZTWC-E1
       GO TO 220
      ENDIF 

C     E1 CAN NOT EXCEED UZTWC
CV.K      E1=E1+UZTWC
CV.K      UZTWC=0.0
      E1=E1+UZTWH
      UZTWH=0.0
CV.K   REDUCE TOTAL TENSION WATER BY ACTUAL E1
      UZTWC=UZTWC-E1
      IF(UZTWC .LT. 0.0) UZTWC=0.0
            
      RED=EDMND-E1
CV.K      IF(UZFWC.GE.RED) GO TO 221
      IF(UZFWH.GE.RED) GO TO 221

C     E2 IS EVAP FROM UZFWC.
CV.K      E2=UZFWC
CV.K      UZFWC=0.0
      E2=UZFWH
      UZFWH=0.0
      if(prflag==2) write(*,*)'L 266 uzfwh',uzfwh
CV.K   REDUCE TOTAL FREE WATER BY ACTUAL E2
      UZFWC=UZFWC-E2
      if(prflag==2) write(*,*)'L 269 uzfwc',uzfwc
      IF(UZFWC .LT. 0.0) UZFWC=0.0          
      RED=RED-E2
      GO TO 225
  221 E2=RED
CVK   SUBTRACT E2 FROM TOTAL & UNFROZEN FREE WATER STORAGES
      UZFWC=UZFWC-E2
      UZFWH=UZFWH-E2
      if(prflag==2) write(*,*)'L 277 uzfwc',uzfwc
      if(prflag==2) write(*,*)'L 278 uzfwh',uzfwh
      RED=0.0
  220 IF((UZTWC/UZTWM).GE.(UZFWC/UZFWM)) GO TO 225
C     UPPER ZONE FREE WATER RATIO EXCEEDS UPPER ZONE
C     TENSION WATER RATIO, THUS TRANSFER FREE WATER TO TENSION
      UZRAT=(UZTWC+UZFWC)/(UZTWM+UZFWM)

CV.K  ACCOUNT FOR RATIO OF UNFROZEN WATER ONLY
CV.K  AND ADJUST FOUR SOIL STATES 
CV.K      UZTWC=UZTWM*UZRAT
CV.K      UZFWC=UZFWM*UZRAT
      DUZTWC=UZTWM*UZRAT-UZTWC
      IF(DUZTWC .GT. UZFWH) DUZTWC=UZFWH 
CV.K  TRANSFERED WATER CAN NOT EXCEED UNFROZEN FREE WATER
      UZTWC=UZTWC+DUZTWC
      UZTWH=UZTWH+DUZTWC
      UZFWC=UZFWC-DUZTWC
      UZFWH=UZFWH-DUZTWC
      if(prflag==2) write(*,*)'L 296 uzfwc',uzfwc
      if(prflag==2) write(*,*)'L 297 uzfwh',uzfwh
CV.K  CHECK UNFROZEN WATER STORAGES TOO
  225 IF (UZTWC.LT.0.00001) THEN
       UZTWC=0.0
       UZTWH=0.0
      ENDIF 
      IF (UZFWC.LT.0.00001) THEN
       UZFWC=0.0
       UZFWH=0.0
      if(prflag==2) write(*,*)'L 306 uzfwc',uzfwc
      if(prflag==2) write(*,*)'L 307 uzfwh',uzfwh
      ENDIF 
C
C     COMPUTE ET FROM THE LOWER ZONE.
C     COMPUTE ET FROM LZTWC (E3)
CV.K      E3=RED*(LZTWC/(UZTWM+LZTWM))
CV.K      LZTWC=LZTWC-E3
CV.K      IF(LZTWC.GE.0.0) THEN
CV.K  ONLY UNFROZEN WATER CAN BE EVAPORATED
cbl do not allow soil moisture to be removed from lower zone
cbl via 'direct soil' evaporation. Rather, this 'deep' soil
cbl moisture will be removed via root water uptake from
cbl transpiration.
cbl     E3=RED*(LZTWH/(UZTWM+LZTWM))
      E3=0.0
      LZTWH=LZTWH-E3
      if(prflag==1) write(*,*)'L 335 lztwh',lztwh
      IF(LZTWH.GE.0.0) THEN
       LZTWC=LZTWC-E3
      if(prflag==1) write(*,*)'L 338 lztwh',lztwh
       GO TO 226
      ENDIF
       
C     E3 CAN NOT EXCEED LZTWC
CV.K      E3=E3+LZTWC
CV.K      LZTWC=0.0
      E3=E3+LZTWH
      LZTWH=0.0
      if(prflag==1) write(*,*)'L 347 lztwh',lztwh
CV.K   REDUCE TOTAL TENSION WATER BY E3
       LZTWC=LZTWC-E3
       if(prflag==1) write(*,*)'L 350 lztwc',lztwc  
  226 RATLZT=LZTWC/LZTWM
      RATLZ=(LZTWC+LZFPC+LZFSC-SACPAR(16))/(LZTWM+LZFPM+LZFSM
     +       -SACPAR(16))
      IF(RATLZT.GE.RATLZ) GO TO 230
C     RESUPPLY LOWER ZONE TENSION WATER FROM LOWER
C     ZONE FREE WATER IF MORE WATER AVAILABLE THERE.
      DEL=(RATLZ-RATLZT)*LZTWM
CV.K  ONLY UNFROZEN WATER CAN BE TRANSFERED
c       if(lzfsc .ne. lzfsh) write(*,*) 'BST4=',lzfsc,lzfsh
      SFH=LZFSH+LZFPH
      IF(DEL .GT. SFH) DEL=SFH
      LZFSH=LZFSH-DEL
      IF(LZFSH .GE. 0.0) THEN
C     TRANSFER FROM LZFSC TO LZTWC.      
       LZFSC=LZFSC-DEL
c         if(lzfsc .lt. lzfsh) then
c          write(*,*) ' lzfsc1: ',lzfsc,lzfsh,del
c          stop
c         endif 
      ELSE
C     IF TRANSFER EXCEEDS LZFSC THEN REMAINDER COMES FROM LZFPC
       LZFPC=LZFPC+LZFSH
       LZFPH=LZFPH+LZFSH
       xx=LZFSH+DEL
       LZFSC=LZFSC-xx
c         if(lzfsc .lt. lzfsh) then
c          write(*,*) ' lzfsc2: ',lzfsc,lzfsh,del,xx
c          stop
c         endif 
       LZFSH=0.0
      ENDIF
      LZTWC=LZTWC+DEL
      if(prflag==1) write(*,*)'L 383 lztwc',lztwc
      LZTWH=LZTWH+DEL
      if(prflag==1) write(*,*)'L 385 lztwh',lztwh

CV.K      LZTWC=LZTWC+DEL
CV.K      LZFSC=LZFSC-DEL
CV.K      IF(LZFSC.GE.0.0) GO TO 230
CV.K      LZFPC=LZFPC+LZFSC
CV.K      LZFSC=0.0

CV.K  CHECK UNFROZEN WATER STORAGE
  230 IF (LZTWC.LT.0.00001) THEN
       LZTWC=0.0
       LZTWH=0.0 
       if(prflag==1) write(*,*)'L 397 lztwc lztwh',lztwc,lztwh
      ENDIF 
C
C     COMPUTE ET FROM ADIMP AREA.-E5
      E5=E1+(RED+E2)*((ADIMC-E1-UZTWC)/(UZTWM+LZTWM))
C      ADJUST ADIMC,ADDITIONAL IMPERVIOUS AREA STORAGE, FOR EVAPORATION.
      ADIMC=ADIMC-E5
      IF(ADIMC.GE.0.0) GO TO 231
C     E5 CAN NOT EXCEED ADIMC.
      E5=E5+ADIMC
      ADIMC=0.0
  231 E5=E5*ADIMP
C     E5 IS ET FROM THE AREA ADIMP.
C.......................................
C     COMPUTE PERCOLATION AND RUNOFF AMOUNTS.
      TWX=PXV+UZTWC-UZTWM       
C     TWX IS THE TIME INTERVAL AVAILABLE MOISTURE IN EXCESS
C     OF UZTW REQUIREMENTS.
      IF(TWX.GE.0.0) GO TO 232
C     ALL MOISTURE HELD IN UZTW--NO EXCESS.
      UZTWC=UZTWC+PXV
CV.K  ADJUST UNFROZEN TENSION WATER
      UZTWH=UZTWH+PXV      

      TWX=0.0
      GO TO 233
C      MOISTURE AVAILABLE IN EXCESS OF UZTWC STORAGE.
CV.K  232 UZTWC=UZTWM
  232 UZTWH=UZTWH+(UZTWM-UZTWC)
      UZTWC=UZTWM
      
  233 ADIMC=ADIMC+PXV-TWX
C
C     COMPUTE IMPERVIOUS AREA RUNOFF.
      ROIMP=PXV*SACPAR(4)
C      ROIMP IS RUNOFF FROM THE MINIMUM IMPERVIOUS AREA.
      SIMPVT=SIMPVT+ROIMP
C
C     INITIALIZE TIME INTERVAL SUMS.
      SBF=0.0
      SSUR=0.0
      SIF=0.0
      SPERC=0.0
      SDRO=0.0
      SPBF=0.0
C
C     DETERMINE COMPUTATIONAL TIME INCREMENTS FOR THE BASIC TIME
C     INTERVAL
CV.K      NINC=1.0+0.2*(UZFWC+TWX)
CV.K  PERCOLATE UNFROZEN WATER ONLY
      NINC=1.0+0.2*(UZFWH+TWX)
C     NINC=NUMBER OF TIME INCREMENTS THAT THE TIME INTERVAL
C     IS DIVIDED INTO FOR FURTHER
C     SOIL-MOISTURE ACCOUNTING.  NO ONE INCREMENT
C     WILL EXCEED 5.0 MILLIMETERS OF UZFWC+PAV
      DINC=(1.0/NINC)*DT
C     DINC=LENGTH OF EACH INCREMENT IN DAYS.
      PINC=TWX/NINC
C     PINC=AMOUNT OF AVAILABLE MOISTURE FOR EACH INCREMENT.
C      COMPUTE FREE WATER DEPLETION FRACTIONS FOR
C     THE TIME INCREMENT BEING USED-BASIC DEPLETIONS
C      ARE FOR ONE DAY
CVK INTRODUCED REDUCTION (RUZICE & RLZICE) DUE FROZEN GROUND
CVK HOWEVER, PRIMARY RUNOFF IS UNCHANGED
CVK      DUZ=1.0-((1.0-UZK)**DINC)
CVK      DLZS=1.0-((1.0-LZSK)**DINC)
CVK  Linear transformation for frozen ground
cc      DUZ=1.0-((1.0-UZK*RUZICE)**DINC)
cc      DLZS=1.0-((1.0-LZSK*RLZICE)**DINC)
CVK  Non-linear (correct) transformation for frozen ground
      IF(IVERS .EQ. 0) THEN
       DUZ =1.0-((1.0-SACPAR(3))**DINC)
       DLZS=1.0-((1.0-SACPAR(12))**DINC)
      ELSE        
       DUZ=1.0-((1.0-RUZICE)**DINC)
       DLZS=1.0-((1.0-RLZICE)**DINC)
      ENDIF 
      DLZP=1.0-((1.0-SACPAR(13))**DINC)
c      write(*,*)'dlzp lzpk dinc',dlzp,sacpar(13),dinc
C
C CVK  ADJUSTMENT TO DEPLETIONS DUE TO FROZEN WATER
         
C.......................................
C     START INCREMENTAL DO LOOP FOR THE TIME INTERVAL.
      DO 240 I=1,NINC
      ADSUR=0.0
C     COMPUTE DIRECT RUNOFF (FROM ADIMP AREA).
      RATIO=(ADIMC-UZTWC)/LZTWM
      IF (RATIO.LT.0.0) RATIO=0.0
      ADDRO=PINC*(RATIO**2)
C     ADDRO IS THE AMOUNT OF DIRECT RUNOFF FROM THE AREA ADIMP.
C
C     COMPUTE BASEFLOW AND KEEP TRACK OF TIME INTERVAL SUM.
CV.K      BF=LZFPC*DLZP
CV.K      LZFPC=LZFPC-BF
CV.K      IF (LZFPC.GT.0.0001) GO TO 234
CV.K      BF=BF+LZFPC
CV.K      LZFPC=0.0
CV.K  BASEFLOW FROM UNFROZEN WATER ONLY   
      BF=LZFPH*DLZP
      LZFPH=LZFPH-BF
      IF (LZFPH.GT.0.0001) THEN
       LZFPC=LZFPC-BF
       GO TO 234
      ENDIF
      BF=BF+LZFPH
      LZFPH=0.0
      LZFPC=LZFPC-BF
      IF(LZFPC .LE. 0.0001) LZFPC=0.0
CV.K-------------------------------------
C      
  234 SBF=SBF+BF
      SPBF=SPBF+BF
CV.K  SUPPLAMENTAL FLOW FROM UNFROZEN WATER ONLY (NOTE, DLZS
CV.K  NOTE, DLZS IS REDUCED DUE FROZEN GROUND
CV.K      BF=LZFSC*DLZS
CV.K      LZFSC=LZFSC-BF
CV.K      IF(LZFSC.GT.0.0001) GO TO 235
CV.K      BF=BF+LZFSC
CV.K      LZFSC=0.0
      BF=LZFSH*DLZS
      LZFSH=LZFSH-BF
      IF(LZFSH.GT.0.0001) THEN
cc?      IF(LZFSH.GT.0.0) THEN      
       LZFSC=LZFSC-BF
c         if(abs(lzfsc-lzfsh) .gt. 0.000001) then
c         if(abs(lzfsc-lzfsh) .gt. 0.000001) then
c          write(*,*) ' lzfsc3: ',lzfsc,lzfsh,bf
c         endif 
       GO TO 235
      ENDIF
      BF=BF+LZFSH
      LZFSH=0.0
      LZFSC=LZFSC-BF
      IF(LZFSC .LE. 0.0001) LZFSC=0.0   
CV.K--------------------------------------------
C       
  235 SBF=SBF+BF
C
C      COMPUTE PERCOLATION-IF NO WATER AVAILABLE THEN SKIP
ccvk      IF((PINC+UZFWC).GT.0.01) GO TO 251
      xx1=PINC+UZFWH
      IF(xx1.GT.0.01) GO TO 251
      UZFWC=UZFWC+PINC
      if(prflag==2) write(*,*)'L 518 uzfwc',uzfwc
CV.K  ADD TO UNFROZEN WATER ALSO
      UZFWH=UZFWH+PINC
      if(prflag==2) write(*,*)'L 521 uzfwh',uzfwh
      GO TO 249
  251 PERCM=LZFPM*DLZP+LZFSM*DLZS
c      write(*,*)'percm lzfpm',percm,lzfpm
c      write(*,*)'dlzp lzfsm dlzs',dlzp,lzfsm,dlzs
CVK      PERC=PERCM*(UZFWC/UZFWM)
CV.K  USE ONLY UNFROZEN WATER RATIOS 
ccvk  new change: PERCOLATION REDUCED BY RUZPERC 
CC       PERC=PERCM*(UZFWH/UZFWM)*RUZICE
      PERC=PERCM*(UZFWH/UZFWM)
c      write(*,*)'perc uzfwc uzfwm',perc,uzfwc,uzfwm
      IF(IVERS .NE. 0) PERC=PERC*RUZPERC
C--      PERC=PERCM*(UZFWH/UZFWM)*RUZPERC
c      write(*,*)'perc ruzperc',perc,ruzperc
CV.K      DEFR=1.0-((LZTWC+LZFPC+LZFSC)/(LZTWM+LZFPM+LZFSM))
cvk 6/22/00      DEFR=1.0-((LZTWH+LZFPH+LZFSH)/(LZTWM+LZFPM+LZFSM))
cvk  better to keep original definition of DEFR using total water
      DEFR=1.0-((LZTWC+LZFPC+LZFSC)/(LZTWM+LZFPM+LZFSM))
c      write(*,*)'defr',defr      
C     DEFR IS THE LOWER ZONE MOISTURE DEFICIENCY RATIO
c--      FR=1.0
C     FR IS THE CHANGE IN PERCOLATION WITHDRAWAL DUE TO FROZEN GROUND.
c--      FI=1.0
C     FI IS THE CHANGE IN INTERFLOW WITHDRAWAL DUE TO FROZEN GROUND.
c--      IF (IFRZE.EQ.0) GO TO 239
c--       UZDEFR=1.0-((UZTWC+UZFWC)/(UZTWM+UZFWM))
CVK
CVK     CALL FGFR1(DEFR,FR,UZDEFR,FI)
CVK      IF( IVERS .EQ. 1) THEN
CVK  IF IVERS=1, OLD VERSION; IF IVERS=2, NEW VERS. FROST INDEX,
CVK  BUT OLD VERS. OF PERCOLAT. AND INTERFLOW REDUCTION
c--      IF( IVERS .LE. 2) CALL FGFR1(DEFR,FR,UZDEFR,FI)
      
c--      IF(IVERS .EQ. 3 .AND. FGPM(5) .GT. 0.) THEN
CVK  OPTIONAL VERSION TO ACCOUNT FOR ADDITIONAL IMPERVIOUS
CVK  AREAS EFFECTS DUE FROZEN GROUND
c--       FR=1-SURFRZ1(FGCO(1),FGPM(6),FGPM(5))
c--       FI=FR
c--      ENDIF 
      
c--  239 PERC=PERC*(1.0+ZPERC*(DEFR**REXP))*FR
  239 PERC=PERC*(1.0+SACPAR(7)*(DEFR**SACPAR(8)))
C     NOTE...PERCOLATION OCCURS FROM UZFWC BEFORE PAV IS ADDED.
CV.K      IF(PERC.LT.UZFWC) GO TO 241
      IF(PERC.LT.UZFWH) GO TO 241
C      PERCOLATION RATE EXCEEDS UZFWH.
CV.K      PERC=UZFWC
      PERC=UZFWH
C     PERCOLATION RATE IS LESS THAN UZFWH.
  241 UZFWC=UZFWC-PERC
      if(prflag==2) write(*,*)'L 571 uzfwc',uzfwc
CV.K  ADJUST UNFROZEN STORAGE ALSO  
      UZFWH=UZFWH-PERC    
      if(prflag==2) write(*,*)'L 574 uzfwh',uzfwh

C     CHECK TO SEE IF PERCOLATION EXCEEDS LOWER ZONE DEFICIENCY.
      CHECK=LZTWC+LZFPC+LZFSC+PERC-LZTWM-LZFPM-LZFSM
      IF(CHECK.LE.0.0) GO TO 242
      PERC=PERC-CHECK
      UZFWC=UZFWC+CHECK
      if(prflag==2) write(*,*)'L 581 uzfwc',uzfwc
CV.K  ADJUST UNFROZEN STARAGE ALSO
      UZFWH=UZFWH+CHECK        
      if(prflag==2) write(*,*)'L 584 uzfwh',uzfwh
  242 SPERC=SPERC+PERC
C     SPERC IS THE TIME INTERVAL SUMMATION OF PERC
C
C     COMPUTE INTERFLOW AND KEEP TRACK OF TIME INTERVAL SUM.
C     NOTE...PINC HAS NOT YET BEEN ADDED
CV.K      DEL=UZFWC*DUZ*FI
CVK  INTERFLOW ALSO REDUCED DUE FROFEN GROUND (DUZ REDUCED BY RUZICE)
CVK  ADDITIONAL REDUCTION DUE IMPERVIOUS FROZEN AREAS (FI) IS OPTIONAL
CVK  IN THE NEW VERSION. BASIC OPTION IS FI=1
c--      DEL=UZFWH*DUZ*FI
      DEL=UZFWH*DUZ
      SIF=SIF+DEL
      UZFWC=UZFWC-DEL
      if(prflag==2) write(*,*)'L 598 uzfwc',uzfwc
CV.K  ADJUST UNFROZEN STORAGE ALSO
      UZFWH=UZFWH-DEL      
      if(prflag==2) write(*,*)'L 601 uzfwh',uzfwh
C     DISTRIBE PERCOLATED WATER INTO THE LOWER ZONES
C     TENSION WATER MUST BE FILLED FIRST EXCEPT FOR THE PFREE AREA.
C     PERCT IS PERCOLATION TO TENSION WATER AND PERCF IS PERCOLATION
C         GOING TO FREE WATER.
      PERCT=PERC*(1.0-SACPAR(14))
      xx1=PERCT+LZTWC
      IF (xx1.GT.LZTWM) GO TO 243
      LZTWC=LZTWC+PERCT
      if(prflag==1) write(*,*)'L 633 lztwc',lztwc
CV.K  ADJUST UNFROZEN STORAGE ALSO
      LZTWH=LZTWH+PERCT      
      if(prflag==1) write(*,*)'L 636 lztwh',lztwh
      PERCF=0.0
      GO TO 244
  243 PERCF=PERCT+LZTWC-LZTWM
CV.K  CHANGE UNFROZEN WATER STORAGE
      LZTWH=LZTWH+LZTWM-LZTWC  
      if(prflag==1) write(*,*)'L 642 lztwh',lztwh
      LZTWC=LZTWM
      if(prflag==1) write(*,*)'L 644 lztwc',lztwc
C
C      DISTRIBUTE PERCOLATION IN EXCESS OF TENSION
C      REQUIREMENTS AMONG THE FREE WATER STORAGES.
  244 PERCF=PERCF+PERC*SACPAR(14)
      IF(PERCF.EQ.0.0) GO TO 245
      HPL=LZFPM/(LZFPM+LZFSM)
C     HPL IS THE RELATIVE SIZE OF THE PRIMARY STORAGE
C     AS COMPARED WITH TOTAL LOWER ZONE FREE WATER STORAGE.

c VK changed to account for ZERO MAX storage
      if(LZFPM .ne. 0.) then
       RATLP=LZFPC/LZFPM
      else
       RATLP = 1.
      endif
      if(LZFSM .ne. 0.) then
       RATLS=LZFSC/LZFSM
      else
       RATLS = 1.
      endif
        
C     RATLP AND RATLS ARE CONTENT TO CAPACITY RATIOS, OR
C     IN OTHER WORDS, THE RELATIVE FULLNESS OF EACH STORAGE
      FRACP=(HPL*2.0*(1.0-RATLP))/((1.0-RATLP)+(1.0-RATLS))
C     FRACP IS THE FRACTION GOING TO PRIMARY.
      IF (FRACP.GT.1.0) FRACP=1.0
      PERCP=PERCF*FRACP
      PERCS=PERCF-PERCP
C     PERCP AND PERCS ARE THE AMOUNT OF THE EXCESS
C     PERCOLATION GOING TO PRIMARY AND SUPPLEMENTAL
C      STORGES,RESPECTIVELY.
      LZFSC=LZFSC+PERCS
CV.K      IF(LZFSC.LE.LZFSM) GO TO 246
      IF(LZFSC.LE.LZFSM) THEN
       LZFSH=LZFSH+PERCS
       GO TO 246
      ENDIF
       
      PERCS=PERCS-LZFSC+LZFSM
CV.K  ADJUST UNFROZEN STORAGE ALSO
      LZFSH=LZFSH+PERCS
            
      LZFSC=LZFSM
  246 LZFPC=LZFPC+(PERCF-PERCS)
C     CHECK TO MAKE SURE LZFPC DOES NOT EXCEED LZFPM.
CV.K      IF (LZFPC.LE.LZFPM) GO TO 245
      IF (LZFPC.LE.LZFPM) THEN
       LZFPH=LZFPH+(PERCF-PERCS)
       GO TO 245
      ENDIF
       
      EXCESS=LZFPC-LZFPM
      LZTWC=LZTWC+EXCESS
      if(prflag==1) write(*,*)'L 698 lztwc',lztwc
CV.K  ADJUST UNFROZEN STORAGES ALSO
      LZTWH=LZTWH+EXCESS
      if(prflag==1) write(*,*)'L 701 lztwh',lztwh
      LZFPH=LZFPH+(PERCF-PERCS)-EXCESS
      LZFPC=LZFPM
C
C     DISTRIBUTE PINC BETWEEN UZFWC AND SURFACE RUNOFF.
  245 IF(PINC.EQ.0.0) GO TO 249
C     CHECK IF PINC EXCEEDS UZFWM
      xx1=PINC+UZFWC
      IF(xx1.GT.UZFWM) GO TO 248
C     NO SURFACE RUNOFF
      UZFWC=UZFWC+PINC
      if(prflag==2) write(*,*)'L 683 uzfwc',uzfwc
CV.K  ADJUST UNFROZEN STORAGE ALSO
      UZFWH=UZFWH+PINC
      if(prflag==2) write(*,*)'L 686 uzfwh',uzfwh
      GO TO 249
C
C     COMPUTE SURFACE RUNOFF (SUR) AND KEEP TRACK OF TIME INTERVAL SUM.
  248 SUR=PINC+UZFWC-UZFWM
      UZFWC=UZFWM
      if(prflag==2) write(*,*)'L 692 uzfwc',uzfwc
CV.K  ADJUST UNFROZEN STORAGE ALSO
      UZFWH=UZFWH+PINC-SUR
      if(prflag==2) write(*,*)'L 695 uzfwh',uzfwh
      SSUR=SSUR+SUR*PAREA
      ADSUR=SUR*(1.0-ADDRO/PINC)
C     ADSUR IS THE AMOUNT OF SURFACE RUNOFF WHICH COMES
C     FROM THAT PORTION OF ADIMP WHICH IS NOT
C     CURRENTLY GENERATING DIRECT RUNOFF.  ADDRO/PINC
C     IS THE FRACTION OF ADIMP CURRENTLY GENERATING
C     DIRECT RUNOFF.
      SSUR=SSUR+ADSUR*ADIMP
C
C     ADIMP AREA WATER BALANCE -- SDRO IS THE 6 HR SUM OF
C          DIRECT RUNOFF.
  249 ADIMC=ADIMC+PINC-ADDRO-ADSUR  
      xx1=UZTWM+LZTWM
      IF (ADIMC.LE.xx1) GO TO 247
      ADDRO=ADDRO+ADIMC-xx1
      ADIMC=xx1
  247 SDRO=SDRO+ADDRO*ADIMP
      IF (ADIMC.LT.0.00001) ADIMC=0.0
  240 CONTINUE

C.......................................
C     END OF INCREMENTAL DO LOOP.
C.......................................

C     COMPUTE SUMS AND ADJUST RUNOFF AMOUNTS BY THE AREA OVER
C     WHICH THEY ARE GENERATED.
      EUSED=E1+E2+E3
      if(prflag==1)write(*,*)'eused',eused,e1,e2,e3
C     EUSED IS THE ET FROM PAREA WHICH IS 1.0-ADIMP-PCTIM
      SIF=SIF*PAREA
C
C     SEPARATE CHANNEL COMPONENT OF BASEFLOW
C     FROM THE NON-CHANNEL COMPONENT
      TBF=SBF*PAREA
C     TBF IS TOTAL BASEFLOW
      BFCC=TBF*(1.0/(1.0+SACPAR(15)))
C     BFCC IS BASEFLOW, CHANNEL COMPONENT
      BFP=SPBF*PAREA/(1.0+SACPAR(15))
      BFS=BFCC-BFP
      IF(BFS.LT.0.0)BFS=0.0
      BFNCC=TBF-BFCC
C     BFNCC IS BASEFLOW,NON-CHANNEL COMPONENT
C
C     ADD TO MONTHLY SUMS.
c--      SINTFT=SINTFT+SIF
c--      SGWFP=SGWFP+BFP
c--      SGWFS=SGWFS+BFS
c--      SRECHT=SRECHT+BFNCC
c--      SROST=SROST+SSUR
c--      SRODT=SRODT+SDRO
C
C     COMPUTE TOTAL CHANNEL INFLOW FOR THE TIME INTERVAL.
      TCI=ROIMP+SDRO+SSUR+SIF+BFCC
        GRND = SIF + BFCC   ! interflow is part of ground flow
CC	GRND = BFCC         ! interflow is part of surface flow
	SURF = TCI - GRND
C
C     COMPUTE E4-ET FROM RIPARIAN VEGETATION.
	E4=(EDMND-EUSED)*SACPAR(6)
C
C     SUBTRACT E4 FROM CHANNEL INFLOW
	TCI=TCI-E4
	IF(TCI.GE.0.0) GO TO 250
	E4=E4+TCI
	TCI=0.0
cc  250 SROT=SROT+TCI
250	CONTINUE
	GRND = GRND - E4
	IF (GRND .LT. 0.) THEN
	   SURF = SURF + GRND
	   GRND = 0.
	 IF (SURF .LT. 0.) SURF = 0.
	END IF
C
C     COMPUTE TOTAL EVAPOTRANSPIRATION-TET
      EUSED=EUSED*PAREA
      TET=EUSED+E5+E4
c--      SETT=SETT+TET
c--      SE1=SE1+E1*PAREA
c--      SE3=SE3+E3*PAREA
c--      SE4=SE4+E4
c--      SE5=SE5+E5
C     CHECK THAT ADIMC.GE.UZTWC
      IF (ADIMC.LT.UZTWC) ADIMC=UZTWC
C
c  Return back SAC states
      SACST(1)=UZTWC
      SACST(2)=UZFWC      
      SACST(3)=LZTWC
      if(prflag==1) write(*,*)'L 814 sacst3 lztwc',lztwc
      SACST(4)=LZFSC
      SACST(5)=LZFPC
      SACST(6)=ADIMC

c new change: check negative states
      do i=1,6
       if(sacst(i) .lt. -1.0) then
        write(*,*) ' SAC state#',i,'<-1.',sacst(i)
        stop
       endif
       if(sacst(i) .lt. 0.0) sacst(i)=0.0
      enddo
      if(uztwh .lt. 0.0) uztwh=0.0
      if(uzfwh .lt. 0.0) uzfwh=0.0
      if(lztwh .lt. 0.0) lztwh=0.0
      if(prflag==1) write(*,*)'L 830 lztwh',lztwh
      if(lzfsh .lt. 0.0) lzfsh=0.0
      if(lzfph .lt. 0.0) lzfph=0.0
      if(sacst(1) .lt. uztwh) uztwh=sacst(1)
      if(sacst(2) .lt. uzfwh) uzfwh=sacst(2)
      if(sacst(3) .lt. lztwh) lztwh=sacst(3)
      if(prflag==1) write(*,*)'L 836 sacst3 lztwh',lztwh
      if(sacst(4) .lt. lzfsh) lzfsh=sacst(4)
      if(sacst(5) .lt. lzfph) lzfph=sacst(5)
c new change        
       
c      WRITE(*,*) 'FLAND2: end, UZFWC = ', UZFWC
CVK  NEW VERSION OF FROST INDEX  ------------------------------
       IF (IVERS .NE. 0) THEN
        IF(FRZST(6) .LT. 0.) THEN
         FRZST(6)=FRZST(6)+UZTWH
        ELSE
         FRZST(6)=UZTWH
        ENDIF
        IF(FRZST(7) .LT. 0.) THEN
         FRZST(7)=FRZST(7)+UZFWH
        ELSE
         FRZST(7)=UZFWH
        ENDIF
        IF(FRZST(8) .LT. 0.) THEN
         FRZST(8)=FRZST(8)+LZTWH
         if(prflag==1) write(*,*)'L 856 frzst8 lztwh',lztwh
        ELSE
         FRZST(8)=LZTWH
         if(prflag==1) write(*,*)'L 859 frzst8 lztwh',lztwh
        ENDIF
        IF(FRZST(9) .LT. 0.) THEN
         FRZST(9)=FRZST(9)+LZFSH
        ELSE
         FRZST(9)=LZFSH
        ENDIF
        IF(FRZST(10) .LT. 0.) THEN
         FRZST(10)=FRZST(10)+LZFPH
        ELSE
         FRZST(10)=LZFPH
        ENDIF
CBL Need to look at the above "IF" statement and may wish to include
CBL above code, since frozen ground is being considered, just not here
      END IF

      if(prflag==1) then
         write(*,*)'UZTW',UZTWH,UZTWC,UZTWM
         write(*,*)'UZFW',UZFWH,UZFWC,UZFWM
         write(*,*)'LZTW',LZTWH,LZTWC,LZTWM
         write(*,*)'LZFP',LZFPH,LZFPC,LZFPM
         write(*,*)'LZFS',LZFSH,LZFSC,LZFSM
      endif

CBL        CALL FROST2_1(PXV,TA,WE,AESC,SH,FRZPAR,SACPAR,FRZST,SACST,
CBL     +        SACST_PRV,SMC,SH2O,DTFRZ,IDTFRZ,NSOIL,NUPL,NSAC,IVERS,
CBL     +        FRZDUP,FRZDBT,FROST, SMAX)
CBL
CBLCVK_02  NEW OPTION TO INTERPOLATE MODEL SOIL LAYER TEMP. INTO DESIRED LAYERS
CBL      NMOD=NSOIL+1
CBL      DSMOD(1)=0.
CBL      DSMOD(1)=-0.5*FRZPAR(10)
CBL      TSTMP(1)=FRZCBLST(1)
CBL      SWTMP(1CBLCBL)=SMC(2)
CBL      SWHTMP(1)=SH2O(2)
CBL      DSMOD(NMOD)=-FRZPAR(CBL5)
CBL      TSTMP(NMOD)=FRZPAR(2)-T0
CBL      SWTMP(NMOD)=SMAX
CBL      SWHTMP(NMOD)=SMAX
CBL      do i=2,nmod-1
CBL       DSMOD(I)=-0.5*(FRZPAR(I+8)+FRZPAR(I+9))
CBL       TSTMP(I)=FRZST(I)
CBL       SWTMP(I)=SMC(I)
CBL       SWHTMP(I)=SH2O(I)
CBL      ENDDO 
CBLcc-      do ii = 1, nmod
CBLcc-        WRITE(*,*) SWTMP(ii), SWHTMP(ii), DSMOD(ii)
CBLcc-      ENDDO
CBL
CBL      CALL SOIL_INT1(TSTMP,NMOD,DSMOD,DSINT,NDSINT,TSINT)
CBL      CALL SOIL_INT1(SWTMP,NMOD,DSMOD,DSINTW,NDINTW,SWINT)
CBL      CALL SOIL_INT1(SWHTMP,NMOD,DSMOD,DSINTW,NDINTW,SWHINT)
CBL
CBLcvk  1/2008 Option to generate normalized soil moisture content (SR)
CBL      if(NORMALIZE .eq. 1) then
CBL       DO I=1,NDINTW
CBL        SWINT(I) =  (SWINT(I) -  FRZPAR(9))/(SMAX-FRZPAR(9))
CBL        SWHINT(I) = (SWHINT(I) - FRZPAR(9))/(SMAX-FRZPAR(9CBL))
CBL       ENDDO
CBL     endif 
CBLcvk  1/2008  end soil moisture normalization
CBL       
CBLC--      DO I=1,NINTW
CBLC--       IF(I .EQ. 1) THEN
CBLC--        SWINT(I)=SWINT(I)*DSINTW(I)*1000.
CBLC--        SWHINT(I)=SWHINT(I)*DSINTW(I)*1000
CBLC--       ELSE	
CBLC--        SWINT(I)=SWINT(I)*(DSINTW(I)-DSINTW(I-1))*1000.
CBLC--        SWHINT(I)=SWHINT(I)*(DSINTW(I)-DSINTW(I-1))*1000
CBLC--       ENDIF
CBLC--      ENDDO 	
CBL
CBLc        WRITE (*,905) (sacst(ii),ii=1,6),
CBLc     1  SPERC,ROIMP,SDRO,SSUR,SIF,BFS,BFP,TCI,
CBLc     2  EDMND,TET,PXV,(frzst(II),II=6,10),WE,SH,AESC,TA,frost,
CBLc     3  (frzst(II),II=1,nsoil),frzdup,frzdbt             
CBLc        write(*,977) smax,(swint(ii),swhint(ii),tstmp(ii),ii=1,nintw)
CBL       ELSE
CBLcc        WRITE (*,977) (sacst(ii),ii=1,6),
CBLcc     1  SPERC,ROIMP,SDRO,SSUR,SIF,BFS,BFP,TCI,
CBLcc     2  EDMND,TET,PXV,UZTWH,UZFWH,LZTWH,LZFSH,LZFPH,WE,SH,AESC,TA
CBL      ENDIF
CBL  905 FORMAT (1H ,14x,F7.2,F7.3,F7.2,F7.3,2F7.2,7F7.3,2F8.3,F7.3,
CBL     +        F9.4,5f7.2,2f6.1,F6.3,F9.4,f7.2,8f7.2,20F7.1)
CBL  977 FORMAT (1H ,14x,f7.2,6(3F7.2))
CBLc             ,F7.3,F7.2,F7.3,2F7.2,7F7.3,2F8.3,F7.3,
CBLc     +        F9.4,5F7.2,2f6.1,F6.3,F9.4,8f7.2,20F7.1)
CBL
C.......................................

      RETURN
      END
