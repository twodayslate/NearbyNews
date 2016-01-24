#import "CydiaSubstrate.h"

@interface SPUISearchViewController
- (BOOL)_hasResults;
+ (id)sharedInstance;
@property (assign, nonatomic) BOOL isActuallyPullDownSpotlight;
@property (assign, nonatomic) int actualSearchMode;
- (BOOL)_isPullDownSpotlight;
- (BOOL)isZKWSearchMode;
- (BOOL)_hasNoQuery;
- (void)dismiss;
@end

@interface SPUISearchModel 
+ (id)sharedInstance;
+ (id)sharedFullZWKInstance;
+ (id)sharedGeneralInstance;
+ (id)sharedPartialZKWInstance;
- (void)addSections:(NSMutableArray *)arg1;
@property (nonatomic, retain) NSArray *searchDomains;
@property (readonly, copy) NSString *debugDescription;
@property (nonatomic, retain) id queryProcessor;
@property (nonatomic) int options;
-(void)searchDaemonQuery:(id)arg1 addedResults:(id)arg2;
@end

@interface SPSearchResultSection
@property (nonatomic, retain) NSString *displayIdentifier;
@property (nonatomic) unsigned int domain;
@property (nonatomic, retain) NSString *category;
@end

@interface SPUISearchHeader
- (void)setCancelButtonHidden:(BOOL)arg1 animated:(BOOL)arg2;
@end

// This works too but there are some annoying bugs that are too hard to fix correctly so I don't do this.
//static BOOL canDeclare = NO;
//%hook SPUISearchModel 
// + (id)sharedPartialZKWInstance {
// 	if(canDeclare) {
// 		return [self sharedFullZWKInstance];
// 	}
// 	canDeclare = YES;
// 	return %orig;	
// }
//%end

%hook SPUISearchViewController
%property (assign, nonatomic) BOOL isActuallyPullDownSpotlight;
- (BOOL)_isPullDownSpotlight {
	%log;
	self.isActuallyPullDownSpotlight = %orig;

	HBLogDebug(@"orig = %d", self.isActuallyPullDownSpotlight );
	return NO;
}
- (BOOL)_allowSwipeToDismiss {
	%log;
	return %orig;
}

// This will disable to swipe up to dismiss gesture. 
- (void)_setDismissGestureRecognizersEnabled:(BOOL)arg1 {
	%log;
	%orig;
}
- (void)_triggerDismissForGesture:(id)arg1 {
	%log;
	%orig;
}
- (void)_updateGestureRecognizerEnabledStatus {
	%log;
	%orig;
}
- (void)setPresentsFromEdge:(unsigned int)arg1 {
	%log;
	%orig;
}

%property (assign, nonatomic) int actualSearchMode;
- (void)setSearchMode:(int)arg1 {
	%log;
	// Search Modes
	// 0 = left
	// 1 = top
	// 2 = search
	self.actualSearchMode = arg1;
	%orig( (self.actualSearchMode == 1) ? 0 : self.actualSearchMode );
}
- (BOOL)_showKeyboardOnPresentation {
	%log;
	return NO;
}

- (void)_didFinishPresenting {
	%log;
	%orig;
	if(self.isActuallyPullDownSpotlight ) {
		SPUISearchHeader *searchHeader = MSHookIvar<SPUISearchHeader *>(self, "_searchHeader");
		[searchHeader setCancelButtonHidden:NO animated:YES];
	}
}

- (void)cancelButtonPressed {
	%log;
	%orig;
	if(self.isActuallyPullDownSpotlight) {
		[self dismiss];
	}
}
%end

%hook SPUISearchHeader
- (void)setCancelButtonHidden:(BOOL)arg1 animated:(BOOL)arg2 {
	%log;
	SPUISearchViewController *vc = [%c(SPUISearchViewController) sharedInstance];
	if(!vc.isActuallyPullDownSpotlight) {
		return %orig;
	}

	if(vc.isActuallyPullDownSpotlight && !arg1) {
		return %orig;
	}
}
%end