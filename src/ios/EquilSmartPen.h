#import <Cordova/CDV.h>
#import "PNFPenLib.h"

@class PNFPenController;
@interface custom : CDVPlugin{
    PNFPenController *penController;
    NSThread* readThread;
    BOOL      readThreadPause;
    BOOL      readThreadStop;
    
    // H/W Info
    int status;
    CGPoint rawPt;
    CGPoint convPt;
    int pressure;
    int temperature;
    int aliveSec;
    
    
    
    // Smartmarker
    NSString* position;
    int smFlag;
    NSString* smProperties;
    
    
    // Count
    int downCnt;
    int moveCnt;
    int upCnt;
    
    // Packet
    int errCntX;
    int errCntY;
    int packetCnt;
    
    BOOL m_penConntectedStatus;
    int temperatureCnt;
    int penErrorCnt;
    float beforeRawX;
    float beforeRawY;
    int btPosition;
    
    //coordinates
    float cordX;
    float cordY;
    
    
    
    
    NSTimer* penSleepCheckTimer;
    long savePenSleepRemainingTime;
    int savePenAliveSec;
    BOOL isRecvEnvDataFirst;
    BOOL isFirstPenSleepOldDevice;
    UIAlertView* penSleepView;
    
}


@property (retain) PNFPenController *penController;
@property (retain) UIAlertView* penSleepView;
@property (retain) NSMutableArray* sections;
@property (retain) NSMutableDictionary* items;
@property (retain) NSString* position;
@property (retain) NSString* smProperties;
@property (retain) UIColor* penColor;

@property (readwrite) int status;
@property (readwrite) CGPoint rawPt;
@property (readwrite) CGPoint convPt;
@property (readwrite) int pressure;
@property (readwrite) int temperature;
@property (readwrite) int smFlag;
@property (readwrite) int aliveSec;


- (void) start:(CDVInvokedUrlCommand*)command;
- (void) PenHandler:(id)sender;
- (void) PenHandlerEnv:(NSArray*)info;


@end
