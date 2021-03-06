// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SIServerMetadataMO.h instead.

#import <CoreData/CoreData.h>
#import "SIDownloadableObject.h"

extern const struct SIServerMetadataMOAttributes {
	__unsafe_unretained NSString *metadataFileContents;
} SIServerMetadataMOAttributes;

extern const struct SIServerMetadataMORelationships {
	__unsafe_unretained NSString *product;
} SIServerMetadataMORelationships;

extern const struct SIServerMetadataMOFetchedProperties {
} SIServerMetadataMOFetchedProperties;

@class SIProductMO;



@interface SIServerMetadataMOID : NSManagedObjectID {}
@end

@interface _SIServerMetadataMO : SIDownloadableObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SIServerMetadataMOID*)objectID;





@property (nonatomic, strong) NSString* metadataFileContents;



//- (BOOL)validateMetadataFileContents:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) SIProductMO *product;

//- (BOOL)validateProduct:(id*)value_ error:(NSError**)error_;





@end

@interface _SIServerMetadataMO (CoreDataGeneratedAccessors)

@end

@interface _SIServerMetadataMO (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMetadataFileContents;
- (void)setPrimitiveMetadataFileContents:(NSString*)value;





- (SIProductMO*)primitiveProduct;
- (void)setPrimitiveProduct:(SIProductMO*)value;


@end
