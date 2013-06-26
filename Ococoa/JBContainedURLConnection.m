//
//  JBContainedURLConnection.m
//  
//
//  Created by Jason Brennan on 11-06-19.
//  Public Domain
//

#import "JBContainedURLConnection.h"

@interface JBContainedURLConnection ()

@property (nonatomic, retain) NSURLConnection *internalConnection;
@property (nonatomic, retain) NSMutableData *internalData;
@property (nonatomic, assign) JBContainedURLConnectionType connectionType;
@property (nonatomic, copy) NSString *responseTextEncoding;

-(NSString*) HTTPMethod;


@end


@implementation JBContainedURLConnection
@synthesize delegate	= _delegate;
@synthesize url	= _url;
@synthesize userInfo	= _userInfo;
@synthesize internalConnection = _internalConnection;
@synthesize internalData = _internalData;
@synthesize completionHandler = _completionHandler;
@synthesize requestData = _requestData;
@synthesize connectionType = _connectionType;
@synthesize responseTextEncoding = _responseTextEncoding;


- (void)dealloc {
	[self.internalConnection cancel];
}


- (id)initWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo delegate:(id<JBContainedURLConnectionDelegate>)delegate {
	
	if ((self = [super init])) {
		self.url = url;
		self.userInfo = userInfo;
		_delegate = delegate;
        _connectionType = JBContainedURLConnectionTypeGET;
        self.requestData = [[NSData alloc] init];
		
		
		// Set off the connection
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
		
		self.internalData = [NSMutableData data];
		
		self.internalConnection = [NSURLConnection connectionWithRequest:request delegate:self];
		
		
	}
	
	return self;
	
}


- (id)initWithURL:(NSURL *)url userInfo:(NSDictionary *)userInfo completionHandler:(JBContainedURLConnectionCompletionHandler)handler {
	
	if ((self = [super init])) {
		
		self.url = url;
		self.userInfo = userInfo;
		_completionHandler = [handler copy]; // readonly, no setter!
        _connectionType = JBContainedURLConnectionTypeGET;
        self.requestData = [[NSData alloc] init];
		
		
		// Set off the connection
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
		
		
		self.internalData = [NSMutableData data];
		self.internalConnection = [NSURLConnection connectionWithRequest:request delegate:self];
		
		
	}
	
	return self;
}

-(id)initWithURL:(NSURL *)url forHttpMethod:(JBContainedURLConnectionType)httpMethod withRequestData:(NSData *)requestData userInfo:(NSDictionary *)userInfo andCompletionHandler:(JBContainedURLConnectionCompletionHandler)handler {
   
	NSDictionary *additionalHeaders = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/json", @"Content-Type", nil];
    return [self initWithURL:url forHttpMethod:httpMethod withRequestData:requestData additionalHeaders:additionalHeaders userInfo:userInfo andCompletionHandler:handler];
}


-(id)initWithURL:(NSURL *)url forHttpMethod:(JBContainedURLConnectionType)httpMethod withRequestData:(NSData *)requestData additionalHeaders:(NSDictionary *)headers userInfo:(NSDictionary *)userInfo andCompletionHandler:(JBContainedURLConnectionCompletionHandler)handler {
    
	if ((self = [super init])) {
		
        self.url = url;
        self.userInfo = userInfo;
        _completionHandler = [handler copy];
        _connectionType = httpMethod;
        self.requestData = requestData;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
        [request setHTTPMethod:[self HTTPMethod]];
        [request setHTTPBody:self.requestData];
        
		if (headers != nil) {
            for (NSString *key in [headers allKeys]) {
                [request addValue:[headers objectForKey:key] forHTTPHeaderField:key];
            }
        }
        
        self.internalData = [NSMutableData data];
        self.internalConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
    
    return self;

}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.responseTextEncoding = [response textEncodingName];
	[self.internalData setLength:0];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self.delegate HTTPConnection:self didFailWithError:error];
	
	if (self.completionHandler) {
		self.completionHandler(self, error, self.url, self.userInfo, nil);
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.internalData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self.delegate HTTPConnection:self didCompleteForURL:self.url userInfo:self.userInfo completedData:[NSData dataWithData:self.internalData]];
	
	if (self.completionHandler) {
		self.completionHandler(self, nil, self.url, self.userInfo, [NSData dataWithData:self.internalData]);
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	// Cleanup. Handy if you modify this class to support multiple connections from the same instance.
	self.internalData = nil;
	self.internalConnection = nil;
}

- (NSString *)HTTPMethod {
	
    switch( _connectionType ) {
        case JBContainedURLConnectionTypePOST:
            return @"POST";
        case JBContainedURLConnectionTypePUT:
            return @"PUT";
        case JBContainedURLConnectionTypeDELETE:
            return @"DELETE";
        case JBContainedURLConnectionTypeGET:
        default:
            return @"GET";
    }
}



- (void)cancel {
	
	[self.internalConnection cancel];
	
	self.internalConnection = nil;
	self.internalData = nil;
	
}












@end
