//
//  MOBox.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOBoxManager.h"
#import "MOBox.h"

@implementation MOBoxManager
{
    NSMapTable *_objectsToBoxes;
    JSContextRef _context;
}

- (id)initWithRuntime:(Mocha *)runtime context:(JSContextRef)context {
    self = [super init];
    if (self) {
        _runtime = runtime;
        _context = context;
        _objectsToBoxes = [NSMapTable weakToStrongObjectsMapTable];
    }
    
    return self;
}

- (JSObjectRef)jsObjectForObject:(id)object classProvider:(JSClassRef (^)(id object))classProvider {
    JSObjectRef result = nil;
    MOBox* box = [_objectsToBoxes objectForKey:object];
    if (box != nil) {
        result = [box JSObject];
    } else {
        box = [[MOBox alloc] initWithRuntime:_runtime];
        JSClassRef jsClass = classProvider(object);
        result = JSObjectMake(_context, jsClass, (__bridge void *)(box));
        [box associateObject:object jsObject:result context:_context];
        [_objectsToBoxes setObject:box forKey:object];
    }
    
    return result;
}

- (void)removeBox:(MOBox *)box {
    [self removeBoxForObject:box.representedObject];
}

- (void)removeBoxForObject:(id)object {
    MOBox* box = [_objectsToBoxes objectForKey:object];
    if (box) {
        [box disassociateObjectInContext:_context];
        [_objectsToBoxes removeObjectForKey:object];
    }
}

@end
