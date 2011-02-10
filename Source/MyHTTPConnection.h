//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"


@interface MyHTTPConnection : HTTPConnection
{
@private
	NSMutableArray* RaMultipartData;
	int MiDataStartIndex;
	BOOL MbPostHeaderOK;
}

- (BOOL)isBrowseable:(NSString *)path;
- (NSString *)createBrowseableIndex:(NSString *)path;
- (NSString *)postResponseOK;
- (NSString *)postResponseNG:(NSString *)zError;

- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength;

@end