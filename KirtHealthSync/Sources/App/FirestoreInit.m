// FirestoreInit.m
// Safe Firestore initialization that catches ObjC exceptions thrown by
// the Firebase SDK when the project is suspended.
#import <Foundation/Foundation.h>
#import <Firebase.h>

__attribute__((__visibility__("default")))
@interface FIRSafeInit : NSObject
+ (FIRFirestore * _Nullable)safeFirestore;
@end

@implementation FIRSafeInit

+ (FIRFirestore * _Nullable)safeFirestore {
    @try {
        return [FIRFirestore firestore];
    } @catch (NSException *exception) {
        NSLog(@"[FIRSafeInit] Caught Firebase exception: %@ - %@", exception.name, exception.reason);
        return nil;
    }
}

@end
