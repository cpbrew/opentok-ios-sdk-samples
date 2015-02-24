//
//  ViewController.m
//  Hello-World
//
//  Copyright (c) 2013 TokBox, Inc. All rights reserved.
//

#import "ViewController.h"
#import <OpenTok/OpenTok.h>
#import <mach/mach.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <signal.h>
#import <VideoToolbox/VideoToolbox.h>
static void int3_handler(int signo)
{
    int a = 0;
    int b = 0;
}
extern void set_h264_as_default_codec(bool value);
UITextField *my_pub_dimensions = nil;
UITextField *my_sub_dimensions = nil;

UIView *globalRootView;

#import "TBExampleSubscriber.h"
#import "TBExamplePublisher.h"

bool startSending = false;


@interface OpenTokObjC : NSObject
+ (void)enableH264Codec;
+ (void)enableWebRTCLogs;
+ (void)setLogBlockQueue:(dispatch_queue_t)queue;
+ (void)setLogBlockArgument:(void*)argument;
+ (void)setLogBlock:(void (^)(NSString* message, void* argument))logBlock;
@end

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

@end

@implementation ViewController {
    OTSession* _session;
    TBExamplePublisher* _publisher;
    TBExampleSubscriber* _subscriber;
    NSTimer *_sampleTimer;
    double _cpuTotal;
    double _memTotal;
    double _totalCounter;
    float _initialBatteryLvl;
    
    
}
static double widgetHeight = 240 ;//480 ;//240;
static double widgetWidth = 320;//640;

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"100";
//// Replace with your generated session ID
//static NSString* const kSessionId = @"1_MX4xMDB-MTI3LjAuMC4xflNhdCBBdWcgMDkgMDY6MTI6MjggUERUIDIwMTR-MC45NjUzMzgyfn4";
//// Replace with your generated token
//static NSString* const kToken = @"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9ZjI1YTBiNzI4YjQ1YzMzYzdlNWJiYTliYzIzODU4Y2U1MTNiYWQ4YTpzZXNzaW9uX2lkPTFfTVg0eE1EQi1NVEkzTGpBdU1DNHhmbE5oZENCQmRXY2dNRGtnTURZNk1USTZNamdnVUVSVUlESXdNVFItTUM0NU5qVXpNemd5Zm40JmNyZWF0ZV90aW1lPTE0MDc1OTAyNTUmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQwNzU5MDI1NS4yMTQ5NzgzMjg0NTc3JmV4cGlyZV90aW1lPTE0MTAxODIyNTUmY29ubmVjdGlvbl9kYXRhPVQxJTNEJTNEY0dGeWRHNWxjbDlwWkQweE1EQW1jMlJyWDNabGNuTnBiMjQ5ZEdKd2FIQXRkakF1T1RFdU1qQXhNUzB3Tnkwd05TWnphV2M5T1RSaU56a3dZMk5oTkRFMVpXRm1OalpqTVRVNE0ySTVPR0kzTXpBeVkyUXdaR0V4TkRVME5qcHpaWE56YVc5dVgybGtQVEZmVFZnMGVFMUVRaTFOVkVrelRHcEJkVTFETkhobWJGSnZaRk5DVGxsWVNXZE5SRmxuVFdwSk5rMUVaelpPUkUxblZVWk9WVWxFU1hkTlZGSXRUVU0wTVUxcVFUTk9WRlY2VGxnMEptTnlaV0YwWlY5MGFXMWxQVEV6T1RRME1qTTFNekFtY205c1pUMXRiMlJsY21GMGIzSW1ibTl1WTJVOU1UTTVORFF5TXpVek1DNDRPRFV5TWpVNU16TTBORFF4Sm1WNGNHbHlaVjkwYVcxbFBURXpPVGN3TVRVMU16QSUzRA==";

// P2P session
static NSString* const kSessionId = @"2_MX4xMDB-MTI3LjAuMC4xfjE0MjQyODQxNTI0Nzd-VWRWUzEydG9NZmhBaEMzWExpc2JHUklPflB-";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9MzE5OTE3ODVlMWRhN2ZmZjZlMGNlMGJlNzM0YzlhMDViNGUwZDhiZjpzZXNzaW9uX2lkPTJfTVg0eE1EQi1NVEkzTGpBdU1DNHhmakUwTWpReU9EUXhOVEkwTnpkLVZXUldVekV5ZEc5TlptaEJhRU16V0V4cGMySkhVa2xQZmxCLSZjcmVhdGVfdGltZT0xNDI0MjgzNjk0JnJvbGU9bW9kZXJhdG9yJm5vbmNlPTE0MjQyODM2OTQuMTQ0MTE1OTAwMDc4MjUmZXhwaXJlX3RpbWU9MTQyNjg3NTY5NCZjb25uZWN0aW9uX2RhdGE9VDElM0QlM0RjR0Z5ZEc1bGNsOXBaRDB4TURBbWMyUnJYM1psY25OcGIyNDlkR0p3YUhBdGRqQXVPVEV1TWpBeE1TMHdOeTB3TlNaemFXYzlPVFJpTnprd1kyTmhOREUxWldGbU5qWmpNVFU0TTJJNU9HSTNNekF5WTJRd1pHRXhORFUwTmpwelpYTnphVzl1WDJsa1BURmZUVmcwZUUxRVFpMU5WRWt6VEdwQmRVMUROSGhtYkZKdlpGTkNUbGxZU1dkTlJGbG5UV3BKTmsxRVp6Wk9SRTFuVlVaT1ZVbEVTWGROVkZJdFRVTTBNVTFxUVROT1ZGVjZUbGcwSm1OeVpXRjBaVjkwYVcxbFBURXpPVFEwTWpNMU16QW1jbTlzWlQxdGIyUmxjbUYwYjNJbWJtOXVZMlU5TVRNNU5EUXlNelV6TUM0NE9EVXlNalU1TXpNME5EUXhKbVY0Y0dseVpWOTBhVzFsUFRFek9UY3dNVFUxTXpBJTNE";


// Change to NO to subscribe to streams other than your own.
static bool subscribeToSelf = YES;
NSMutableDictionary *allSubs = nil;
NSMutableArray *allStreams = nil;
#pragma mark - View lifecycle
/*extern "C"*/ uint32_t global_bitrate ;
- (void)viewDidLoad
{
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    
    my_pub_dimensions = self.pubDimensionsTxtFld;
    my_sub_dimensions = self.subDimensionsTxtFld;
    
    globalRootView = self.view;
    allStreams = [[NSMutableArray alloc] init];
    allSubs = [[NSMutableDictionary alloc] init];
    [super viewDidLoad];
    //webrtc::H264Encoder* encoder;// = webrtc::H264Encoder::Create();
    
    void (^logBlock)(NSString* message, void* arg);
    logBlock = ^(NSString* message, void* arg){
        NSLog(@"%@",message);
    };
    
    _totalCounter = 0; _memTotal = 0; _cpuTotal = 0;

    //[OpenTokObjC enableH264Codec];
    
    //    [NSClassFromString(@"OpenTokObjC") performSelector:@selector(setLogBlock:) withObject:logBlock];
    //    [NSClassFromString(@"OpenTokObjC") performSelector:@selector(setLogBlockQueue:) withObject:dispatch_get_main_queue()];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
    
    [self sampleCPUUsage:nil];
    //[self doConnect];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}
#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    
    [_session connectWithToken:kToken error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    //return;
    _publisher = [[TBExamplePublisher alloc] initWithDelegate:self
                                                         name:nil
                                                   audioTrack:NO
                                                   videoTrack:YES];
    // not to resize the screen, perticularly for VP8
    _publisher.videoType = OTPublisherKitVideoTypeScreen;
    //[_publisher setName:[[UIDevice currentDevice] name]];
    
    _publisher.session =_session;
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self.view addSubview:_publisher.view];
    [_publisher.view setFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    //return;
    _subscriber = [[TBExampleSubscriber alloc] initWithStream:stream
                                                     delegate:self];
    _subscriber.fileNameToWriteRawData = @"640_480_HIGH_Decoded.yuv";
    
    [allSubs setObject:_subscriber forKey:stream.streamId];
    [allStreams addObject:stream.streamId];
    _subscriber.subscribeToAudio = NO;
    OTError *error = nil;
    [_session subscribe:_subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 * NB: You do *not* have to call unsubscribe in your controller in response to
 * a streamDestroyed event. Any subscribers (or the publisher) for a stream will
 * be automatically removed from the session during cleanup of the stream.
 */
- (void)cleanupSubscriber
{
    [_subscriber.view removeFromSuperview];
    NSLog(@"Subscriber frames rcvd %ld",[_subscriber totalRcvdFrames]);
    _subscriber = nil;
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    [_sampleTimer invalidate];
    
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
    
    double cpuVal = _cpuTotal / _totalCounter;
    double memVal = _memTotal / _totalCounter;
    
    [self updateBatteryLevel];
    NSLog(@"Final Avg. CPU Usage %.2f, Memory used %.2f",cpuVal,memVal);
    
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);
    
    // Step 3a: (if NO == subscribeToSelf): Begin subscribing to a stream we
    // have seen on the OpenTok session.
    //if (nil == _subscriber && !subscribeToSelf)
    //if (![_publisher.stream.streamId isEqualToString:stream.streamId])
    {
        [self doSubscribe:stream];
    }
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    if ([_subscriber.stream.connection.connectionId
         isEqualToString:connection.connectionId])
    {
        [self cleanupSubscriber];
    }
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    
    _initialBatteryLvl = [UIDevice currentDevice].batteryLevel;
    NSLog(@"Initial Battery Level %f",_initialBatteryLvl);
    
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    
    
    int index = [allStreams indexOfObject:subscriber.stream.streamId];
    int count = floor(index/2.0) ;
    _subscriber = subscriber;
    //    [_subscriber.view setFrame:CGRectMake(((index % 2) == 0) ? 0 : widgetWidth,
    //                                          count * widgetHeight,
    //                                          widgetWidth,
    //                                         widgetHeight)];
    
    [_subscriber.view setFrame:CGRectMake( 0 ,
                                          widgetHeight,
                                          widgetWidth,
                                          widgetHeight)];
    
    [self.view addSubview:_subscriber.view];
    [self startTimer];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
    // all participants in the OpenTok session. We will attempt to subscribe to
    // our own stream. Expect to see a slight delay in the subscriber video and
    // an echo of the audio coming from the device microphone.
    if (nil == _subscriber && subscribeToSelf)
    {
        [self doSubscribe:stream];
    }
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    if ([_subscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}
bool encode = true;
bool decode = true;
bool started_encoding = false;
extern void enable_encode(bool enable);
extern void enable_decode(bool enable);
- (IBAction)sampleCPUUsage:(id)sender {
    encode = !encode;
    decode = !decode;
    
    if (started_encoding)
    {
        [_session disconnect:nil];
        return;
    }
    started_encoding = !started_encoding;
    [self doConnect];
    
}

float cpu_usage()
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}


float getMemoryUsage() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    
    if( kerr == KERN_SUCCESS ) return ((float)info.resident_size/1048576.0f);
    else return 0;
}

- (void)timerIntervalForCPUandMemorySamples
{
    if (startSending == NO && _totalCounter == 1)
        startSending = YES;
    float memVal = getMemoryUsage();
    float cpuVal = cpu_usage();
    self.cpuUsageTxtFld.text = [NSString stringWithFormat:@"%.2f",cpuVal];
    self.memUsageTxtFld.text = [NSString stringWithFormat:@"%.2f",memVal];
    _totalCounter++;
    _memTotal += memVal;
    _cpuTotal += cpuVal;
    NSLog(@"CPU Usage %.2f, Memory used %.2f",cpuVal,memVal);
}

- (void)startTimer
{
    _sampleTimer = [NSTimer timerWithTimeInterval:3
                                           target:self
                                         selector:@selector(timerIntervalForCPUandMemorySamples)
                                         userInfo:nil
                                          repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_sampleTimer
                                 forMode:NSDefaultRunLoopMode];
    
}

- (void)updateBatteryLevel
{
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    NSLog(@"Finished battery level %f",batteryLevel);
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        self.batteryLevel.text = NSLocalizedString(@"Unknown", @"");
    }
    else {
        batteryLevel =  _initialBatteryLvl - batteryLevel;
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        self.batteryLevel.text = [numberFormatter stringFromNumber:levelObj];
        NSLog(@"Consumed Battery Level %@",levelObj);
    }
}
@end
