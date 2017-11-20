/********* EquilSmartPen.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "EquilSmartPen.h"

@implementation EquilSmartPen

@synthesize penController;
@synthesize penSleepView;
@synthesize sections;
@synthesize items;

@synthesize status, rawPt, convPt, pressure, temperature, aliveSec, smFlag;
@synthesize position, smProperties;
@synthesize penColor;

- (void)pluginInitialize
{
    penController = [[PNFPenController alloc] init];
    [penController setProjectiveLevel:4];
    
    CGPoint calScalePoint[4];
    calScalePoint[0] = CGPointMake(2651, 458);
    calScalePoint[1] = CGPointMake(2651,3058);
    calScalePoint[2] = CGPointMake(4646,3058);
    calScalePoint[3] = CGPointMake(4646,458);
    
    [penController setCalibrationData: CGRectMake(0.0, 0.0, 300.0, 400.0 )
                          GuideMargin:0
                           CalibPoint:calScalePoint];
    [penController startPen];
    
    [penController setRetObj:self];
    [penController setRetObjForEnv:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FreeLogMsg:) name:@"PNF_LOG_MSG" object:nil];
    if (self.penController.bConnected) {
        m_penConntectedStatus = YES;
        [self ReadThreadStart];
    }
    else {
        m_penConntectedStatus = NO;
        [self ReadThreadOff];
    }
}

- (void)start:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}


-(void) ReadThreadStart {
    if (readThread == nil) {
        readThread = [[NSThread alloc] initWithTarget:self
                                             selector:@selector(runReadThread) object:self];
        readThreadStop=NO;
        readThreadPause=NO;
        [readThread start];
        
    }
    if (penController) {
        [penController StartReadQ];
    }
}
-(void) runReadThread {
    @autoreleasepool {
        while (1) {
            if (readThreadStop) {
                break;
            }
            
            if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
                [NSThread sleepForTimeInterval:0.02];
                continue;
            }
            
            NSDictionary* dic = [penController ReadQ];
            if(dic) {
                [self performSelectorOnMainThread:@selector(PenHandlerWithDictionary:) withObject:dic waitUntilDone:YES];
                [penController RemoveQ];
            }
            else {
                [NSThread sleepForTimeInterval:0.02];
            }
        }
    }
}
-(void) ReadThreadOff {
    readThreadStop = YES;
    [NSThread sleepForTimeInterval:0.2];
    if (readThread) {
        [readThread cancel];
        readThread = nil;
    }
    if (penController) {
        [penController EndReadQ];
    }
}
-(void) PenHandlerWithMsg:(NSNotification*) note {
    NSDictionary* dic = [note object];
    if ([penController getRetObj] != self)
        return;
    [self PenHandlerWithDictionary:dic];
}
-(void) PenHandlerWithDictionary:(NSDictionary*) dic {
    int PenStatus  = [[dic objectForKey:@"PenStatus"] intValue];
    CGPoint ptRaw = [[dic objectForKey:@"ptRaw"] CGPointValue];
    CGPoint ptConv = [[dic objectForKey:@"ptConv"] CGPointValue];
    int Temperature = [[dic objectForKey:@"Temperature"] intValue];
    int modelCode = [[dic objectForKey:@"modelCode"] intValue];
    int SMPenFlag = [[dic objectForKey:@"SMPenFlag"] intValue];
    int SMPenState = [[dic objectForKey:@"SMPenState"] intValue];
    int press = [[dic objectForKey:@"pressure"] intValue];
    [self PenHandlerWithArgs:ptRaw
                      ptConv:ptConv
                   PenStatus:PenStatus
                 Temperature:Temperature
                   ModelCode:modelCode
                   SMPenFlag:SMPenFlag
                  SMPenState:SMPenState
                    Pressure:press];
}
-(void) PenHandlerWithArgs:(CGPoint) Arg_ptRaw ptConv:(CGPoint) Arg_ptConv PenStatus:(int) Arg_PenStatus
               Temperature:(int) Arg_Temperature ModelCode:(int) Arg_modelCode
                SMPenFlag :(int) Arg_SMPenFlag SMPenState:(int) Arg_SMPenState
                  Pressure:(int) Arg_pressure {
    isRecvEnvDataFirst = YES;
    [self penIdleTimerStop];
    [self closePenSleepView];
    
    if (penController == nil) {
        return;
    }
    
    packetCnt++;
    status = Arg_PenStatus;
    temperature = Arg_Temperature;
    rawPt = Arg_ptRaw;
    convPt = Arg_ptConv;
    [self sendMessageCallback:[NSString stringWithFormat:@"[%i,%f,%f,%f,%f]",Arg_PenStatus,cordX,cordY,convPt.x,convPt.y]];
    cordX = convPt.x;
    cordY = convPt.y;
}

- (void)sendMessageCallback:(NSString*) parameter
{
    
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.plugins.EquilSmartPen.onDataReceived(%@)",parameter]];
}

- (void) FreeLogMsg:(NSNotification *) note
{
    NSString * szs = (NSString *)[note object];
    int penStatus = 0;
    if([szs isEqualToString:@"INVALID_PROTOCOL"]){
        penStatus = 11;
    }else if([szs isEqualToString:@"FAIL_LISTENING"]){
        penStatus = 12;
    }else if([szs isEqualToString:@"CONNECTED"]){
        penStatus = 15;
    }else if([szs isEqualToString:@"PEN_RMD_ERROR"]){
        penStatus = 16;
    }else if([szs isEqualToString:@"FIRST_DATA_RECV"]){
        penStatus = 17;
    }else if([szs isEqualToString:@"SESSION_CLOSED"]){
        penStatus = 32;
    }else if([szs isEqualToString:@"Gesture Circle Clockwise"]){
        penStatus = 102;
    }else if([szs isEqualToString:@"Gesture Circle CounterClockwise"]){
        penStatus = 103;
    }else if([szs isEqualToString:@"CLICK"]){
        penStatus = 105;
    }else if([szs isEqualToString:@"DOUBLE_CLICK"]){
        penStatus = 106;
    }
    [self sendEventCallback:[NSString stringWithFormat:@"%i",penStatus]];
}

- (void)sendEventCallback:(NSString*) parameter
{
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"window.plugins.EquilSmartPen.onEventReceived(%@)",parameter]];
}

-(void) penIdleTimerStop {
    if(penSleepCheckTimer != nil){
        [penSleepCheckTimer invalidate];
        penSleepCheckTimer = nil;
    }
}
-(void) closePenSleepView {
    if (penSleepView) {
        [penSleepView dismissWithClickedButtonIndex:0 animated:NO];
        penSleepView = nil;
    }
}
-(void) showPenSleepView {
    penSleepView = [[UIAlertView alloc] initWithTitle:@""
                                              message:@"Press Pen power button once to use as the pen is on sleep mode."
                                             delegate:nil
                                    cancelButtonTitle:@"Ok"
                                    otherButtonTitles:nil];
    [penSleepView show];
}


@end
