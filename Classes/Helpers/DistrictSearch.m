//
//  DistrictSearchOperation.m
//  Created by Gregory Combs on 9/1/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "DistrictSearch.h"
#import "SLFDataModels.h"
#import "SLFRestKitManager.h"
#import "JSONKit.h"
#import "SLFReachable.h"
#import "APIKeys.h"

@interface DistrictSearch()
@property (assign) CLLocationCoordinate2D searchCoordinate;
@property (nonatomic,copy) DistrictSearchSuccessWithResultsBlock onSuccessWithResults;
@property (nonatomic,copy) DistrictSearchFailureWithMessageAndFailOptionBlock onFailureWithMessageAndFailOption;
- (NSArray *)boundaryIDsFromSearchResults:(id)results;
@end

@implementation DistrictSearch
@synthesize searchCoordinate;
@synthesize onSuccessWithResults = _onSuccessWithResults;
@synthesize onFailureWithMessageAndFailOption = _onFailureWithMessageAndFailOption;

- (void)searchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    self.onSuccessWithResults = successBlock;
    self.onFailureWithMessageAndFailOption = failureBlock;
    searchCoordinate = aCoordinate;

    RKClient * client = [[SLFRestKitManager sharedRestKit] openStatesClient];
    if (NO == [client isNetworkReachable]) {
        if (failureBlock)
            failureBlock(NSLocalizedString(@"Cannot geolocate legislative districts because Internet service is unavailable.", @""), DistrictSearchShowAlert);
        return;
    }
    
    NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys: SUNLIGHT_APIKEY, @"apikey", [NSNumber numberWithDouble:aCoordinate.longitude], @"long", [NSNumber numberWithDouble:aCoordinate.latitude], @"lat", @"boundary_id,district,chamber,state", @"fields", nil];
    [client get:@"/legislators/geo" queryParams:queryParams delegate:self];
}

+ (DistrictSearch *)districtSearchForCoordinate:(CLLocationCoordinate2D)aCoordinate successBlock:(DistrictSearchSuccessWithResultsBlock)successBlock failureBlock:(DistrictSearchFailureWithMessageAndFailOptionBlock)failureBlock {
    DistrictSearch *op = [[[DistrictSearch alloc] init] autorelease];
    [op searchForCoordinate:aCoordinate successBlock:successBlock failureBlock:failureBlock];
    return op;
}

- (void) dealloc {
    RKClient *client = [[SLFRestKitManager sharedRestKit] openStatesClient];
    [client.requestQueue cancelRequestsWithDelegate:self];
    Block_release(_onSuccessWithResults);
    Block_release(_onFailureWithMessageAndFailOption);
    [super dealloc];
}

- (void)setOnSuccessWithResults:(DistrictSearchSuccessWithResultsBlock)onSuccessWithResults {
    if (_onSuccessWithResults) {
        Block_release(_onSuccessWithResults);
        _onSuccessWithResults = nil;
    }
    _onSuccessWithResults = Block_copy(onSuccessWithResults);
}

- (void)setOnFailureWithMessageAndFailOption:(DistrictSearchFailureWithMessageAndFailOptionBlock)onFailureWithMessageAndFailOption {
    if (_onFailureWithMessageAndFailOption) {
        Block_release(_onFailureWithMessageAndFailOption);
        _onFailureWithMessageAndFailOption = nil;
    }
    _onFailureWithMessageAndFailOption = Block_copy(onFailureWithMessageAndFailOption);
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    BOOL success = NO;
    NSArray *foundIDs = nil;
    if (response && [response isOK]) {  
        id results = [response.body objectFromJSONData];
        @try {
            foundIDs = [self boundaryIDsFromSearchResults:results];
            success = !IsEmpty(foundIDs);
        }
        @catch (NSException *exception) {
            RKLogError(@"%@: %@", [exception name], [exception reason]);
        }
    }
    
    if (!success) {
        RKLogError(@"Request = %@", request);
        RKLogError(@"Response = %@", response);
        if (_onFailureWithMessageAndFailOption)
            _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchFailOptionLog);
        return;
    }
    if (_onSuccessWithResults)
        _onSuccessWithResults(foundIDs);
}

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    if (error && request) {
        RKLogError(@"Error loading search results from %@: %@", [request description], [error localizedDescription]);
    }    
    if (_onFailureWithMessageAndFailOption)
        _onFailureWithMessageAndFailOption(@"Could not find a district map with those coordinates.", DistrictSearchFailOptionLog);
}


- (NSArray *)boundaryIDsFromSearchResults:(id)results {
    NSMutableArray *foundIDs = [NSMutableArray array];
    NSMutableArray *boundaryList = nil;
    if ([results isKindOfClass:[NSMutableArray class]])
        boundaryList = results;
    else if ([results isKindOfClass:[NSMutableDictionary class]])
        boundaryList = [NSMutableArray arrayWithObject:results];
    for (NSMutableDictionary *boundary in boundaryList) {
        NSString *boundaryID = [boundary objectForKey:@"boundary_id"];
        if (IsEmpty(boundaryID))
            continue;
        [foundIDs addObject:boundaryID];
    }
    return foundIDs;
}

@end
