//
//  MOBox.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOBoxManager.h"
#import "MOBox.h"

#define TRACK_JS_IN_USE 0
#define LEAK_STUFF 0
#define LOG_BOXES 0

@implementation MOBoxManager
{
    NSMapTable *_objectsToBoxes;
    NSMutableSet* _boxesInUseByJavascript;
    JSContextRef _context;
    
#if TRACK_JS_IN_USE
    NSMutableArray* _objectsInUseByJavascript;
#endif
}

- (id)initWithRuntime:(Mocha *)runtime context:(JSContextRef)context {
    self = [super init];
    if (self) {
        _runtime = runtime;
        _context = context;
        _objectsToBoxes = [NSMapTable weakToStrongObjectsMapTable];
        _boxesInUseByJavascript = [NSMutableSet new];
#if TRACK_JS_IN_USE
        _objectsInUseByJavascript = [NSMutableArray new];
#endif
    }
    
    return self;
}

#if TRACK_JS_IN_USE
- (BOOL)jsObjectIsInUse:(JSObjectRef)jsObject {
    return [_objectsInUseByJavascript indexOfObject:@((NSInteger)jsObject)] != NSNotFound;
}
#endif

- (JSObjectRef)jsObjectForObject:(id)object classProvider:(JSClassRef (^)(id object))classProvider {
    JSObjectRef result = nil;
    MOBox* box = [_objectsToBoxes objectForKey:object];
    if (box != nil) {
        result = [box JSObject];
    } else {
        box = [[MOBox alloc] initWithManager:self];
        JSClassRef jsClass = classProvider(object);
#if LEAK_STUFF
        result = JSObjectMake(_context, NULL, NULL); // deliberately leaked
        result = JSObjectMake(_context, NULL, NULL); // deliberately leaked
        result = JSObjectMake(_context, NULL, NULL); // deliberately leaked
#endif
        result = JSObjectMake(_context, jsClass, (__bridge void *)box);
        [box associateObject:object jsObject:result context:_context];
        [_objectsToBoxes setObject:box forKey:object];
        [_boxesInUseByJavascript addObject:box];
#if TRACK_JS_IN_USE
        NSAssert(![self jsObjectIsInUse:result], @"js object was already in use");
        [_objectsInUseByJavascript addObject:@((NSInteger)result)];
#endif
        
#if LOG_BOXES
        NSLog(@"new box %p js %p %p (%@)", box, result, object, [box.representedObject class]);
#endif
    }
    
    return result;
}

- (void)removeBox:(MOBox *)box {
#if LOG_BOXES
    NSLog(@"removing box %p for %p %p (%@)", box, box.JSObject, box.representedObject, [box.representedObject class]);
#endif
    
    JSObjectSetPrivate(box.JSObject, NULL);

    id object = box.representedObject;
    NSAssert([_objectsToBoxes objectForKey:object] != nil, @"box for object is missing");
    [_objectsToBoxes removeObjectForKey:object];
    NSAssert([_boxesInUseByJavascript containsObject:box], @"box was not in use");
    [_boxesInUseByJavascript removeObject:box];
#if TRACK_JS_IN_USE
    NSAssert([self jsObjectIsInUse:box.JSObject], @"js object was not in use");
    [_objectsInUseByJavascript removeObject:@((NSInteger)box.JSObject)];
#endif
}

+ (id)privateForJSObject:(JSObjectRef)jsObject isBox:(BOOL*)isBox {
    id private = (__bridge id)(JSObjectGetPrivate(jsObject));
    if (isBox)
        *isBox = [private isKindOfClass:[MOBox class]];
    return private;
}

+ (MOBox*)boxForJSObject:(JSObjectRef)jsObject {
    MOBox *box = (__bridge MOBox *)(JSObjectGetPrivate(jsObject));
    NSAssert([box isKindOfClass:[MOBox class]], @"unexpected associated object");
    return box;
}

+ (id)boxedForJSObject:(JSObjectRef)jsObject {
    MOBox *box = (__bridge MOBox *)(JSObjectGetPrivate(jsObject));
    NSAssert([box isKindOfClass:[MOBox class]], @"unexpected associated object");
    return [box representedObject];
}

+ (Class)classForJSObject:(JSObjectRef)jsObject {
    MOBox *box = (__bridge MOBox *)(JSObjectGetPrivate(jsObject));
    NSAssert([box isKindOfClass:[MOBox class]], @"unexpected associated object");
    return [[box representedObject] class];
}

+ (void)assertBoxValidForJSObject:(JSObjectRef)jsObject representsObject:(id)object {
    MOBox *box = (__bridge MOBox *)(JSObjectGetPrivate(jsObject));
    NSAssert([box representedObject] == object, @"wrong object represented");
}

@end
