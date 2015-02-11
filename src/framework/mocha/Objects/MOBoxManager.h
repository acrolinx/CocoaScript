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

+ (id)privateForJSObject:(JSObjectRef)jsObject isBox:(BOOL*)isBox;
+ (MOBox*)boxForJSObject:(JSObjectRef)jsObject;
+ (id)boxedForJSObject:(JSObjectRef)jsObject;
+ (Class)classForJSObject:(JSObjectRef)jsObject;

+ (void)assertBoxValidForJSObject:(JSObjectRef)jsObject representsObject:(id)object;

@end
