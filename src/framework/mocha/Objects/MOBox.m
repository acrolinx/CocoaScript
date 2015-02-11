//
//  MOBox.m
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import "MOBox.h"
#import "MOMethod.h"
#import "MOBridgeSupportSymbol.h"
#import "MOFunctionArgument.h"
#import "MOClosure.h"
#import "MOBoxManager.h"

@implementation MOBox
{
    MOBoxManager* _manager;
}

- (id)initWithManager:(MOBoxManager *)manager {
    self = [super init];
    if (self) {
        _manager = manager;
    }
    
    return self;
}

- (void)associateObject:(id)object jsObject:(JSObjectRef)jsObject context:(JSContextRef)context {
    _representedObject = object;
    _JSObject = jsObject;
    JSValueProtect(context, jsObject); // TODO: this is a temporary hack. It will fix the script crash, but only at the expense of leaking all JS objects during a script run. Which is not good...
}

- (void)removeFromManager {
    // Give the object a chance to finalize itself
    if ([_representedObject respondsToSelector:@selector(finalizeForMochaScript)]) {
        [_representedObject finalizeForMochaScript];
    }

    //    NSLog(@"disassociated box %p for %p js:%p", self, self.representedObject, self.JSObject);
    //    JSValueUnprotect(context, self.JSObject); // TODO: also a hack
    [_manager removeBox:self];
    _representedObject = nil;
    _JSObject = nil;
}

- (void)dealloc {
    NSAssert(_JSObject == nil, @"should have been cleared");
    NSAssert(_representedObject == nil, @"should have been cleared");
}

@end
