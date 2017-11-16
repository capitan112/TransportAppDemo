//
//  NetworkConnect.m
//  DigiCodeTask
//
//  Created by Капитан on 16.11.16.
//

#import "NetworkConnect.h"
#import "AFNetworking.h"
#import "DigiCodeTask-Swift.h"

@implementation NetworkConnect

+ (void)getJSONfromURL: (NSString *)url completionHandler:CompletionHandler {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:CompletionHandler]
    ;
    [dataTask resume];
}
    
@end
