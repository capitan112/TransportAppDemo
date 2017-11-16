//
//  NetworkConnect.h
//  DigiCodeTask
//
//  Created by Капитан on 16.11.16.
//

#import <Foundation/Foundation.h>

typedef void(^CompletionHandler)(void (^)(NSURLResponse *response, id responseObject, NSError *error));

@interface NetworkConnect : NSObject

+ (void)getJSONfromURL: (NSString *)url completionHandler:CompletionHandler;
    
@end
