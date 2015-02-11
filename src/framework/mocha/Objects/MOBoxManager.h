//
//  MOBox.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>


@class Mocha;
@class MOBox;

@interface MOBoxManager : NSObject

- (id)initWithRuntime:(Mocha*)runtime context:(JSContextRef)context;

@property (weak, readonly) Mocha *runtime;

- (JSObjectRef)jsObjectForObject:(id)object classProvider:(JSClassRef (^)(id object))classProvider;
- (void)removeBox:(MOBox*)box;
- (void)removeBoxForObject:(id)object;

@end
