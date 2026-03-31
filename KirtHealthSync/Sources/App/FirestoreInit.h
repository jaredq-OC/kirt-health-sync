// FirestoreInit.h
// Safe Firestore initialization that catches ObjC exceptions thrown by
// the Firebase SDK when the project is suspended.
#import <Foundation/Foundation.h>

@class FIRFirestore;

NS_ASSUME_NONNULL_BEGIN

@interface FIRSafeInit : NSObject
+ (FIRFirestore * _Nullable)safeFirestore;
@end

NS_ASSUME_NONNULL_END
