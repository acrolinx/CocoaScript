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
    NSMutableArray* _boxesInUseByJavascript;
    JSContextRef _context;
}

- (id)initWithRuntime:(Mocha *)runtime context:(JSContextRef)context {
    self = [super init];
    if (self) {
        _runtime = runtime;
        _context = context;
        _objectsToBoxes = [NSMapTable weakToStrongObjectsMapTable];
        _boxesInUseByJavascript = [NSMutableArray new];
    }
    
    return self;
}

- (JSObjectRef)jsObjectForObject:(id)object classProvider:(JSClassRef (^)(id object))classProvider {
    JSObjectRef result = nil;
    MOBox* box = [_objectsToBoxes objectForKey:object];
    if (box != nil) {
        result = [box JSObject];
    } else {
        box = [[MOBox alloc] initWithManager:self];
        JSClassRef jsClass = classProvider(object);
        result = JSObjectMake(_context, jsClass, (__bridge void *)box);
        [box associateObject:object jsObject:result context:_context];
        [_objectsToBoxes setObject:box forKey:object];
        [_boxesInUseByJavascript addObject:box];
    }
    
    return result;
}

- (void)removeBox:(MOBox *)box {
    JSObjectSetPrivate(box.JSObject, NULL);

    id object = box.representedObject;
    NSAssert([_objectsToBoxes objectForKey:object] != nil, @"box is missing");
    [_objectsToBoxes removeObjectForKey:object];
    [_boxesInUseByJavascript removeObject:box];
}

@end
