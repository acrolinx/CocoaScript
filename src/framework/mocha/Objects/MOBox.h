//
//  MOBox.h
//  Mocha
//
//  Created by Logan Collins on 5/12/12.
//  Copyright (c) 2012 Sunflower Softworks. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol MOBoxProtocol <NSObject>
@optional

/*!
 * @method finalizeForMochaScript
 * @abstract Invoked before the object is dereferenced in the runtime
 *
 * @discussion
 * This method allows objects to clear internal caches and data tied to
 * other runtime information in preparation for being remove from the runtime.
 */

- (void)finalizeForMochaScript;
@end

@class MOBoxManager;


/*!
 * @class MOBox
 * @abstract A boxed Objective-C object
 */
@interface MOBox : NSObject

- (id)initWithManager:(MOBoxManager*)manager;
- (void)associateObject:(id)object value:(JSManagedValue*)value;
- (void)removeFromManager;

/*!
 * @property representedObject
 * @abstract The boxed Objective-C object
 *
 * @result An object
 */
@property (strong, readonly) id representedObject;

/*!
 * @property JSObject
 * @abstract The JSObject representation of the box
 *
 * @result A JSObjectRef value
 */
@property (strong, readonly) JSManagedValue *value;

- (JSObjectRef)JSObject;

@end
