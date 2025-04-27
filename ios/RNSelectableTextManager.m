#import "RNSelectableTextView.h"
#import "RNSelectableTextManager.h"

@implementation RNSelectableTextManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[RNSelectableTextView alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(value, NSString)
RCT_EXPORT_VIEW_PROPERTY(onSelection, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(menuItems, NSArray)
RCT_EXPORT_VIEW_PROPERTY(highlights, NSArray)
RCT_EXPORT_VIEW_PROPERTY(highlightColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(onHighlightPress, RCTDirectEventBlock)

#if !TARGET_OS_TV
RCT_REMAP_VIEW_PROPERTY(dataDetectorTypes, backedTextInputView.dataDetectorTypes, UIDataDetectorTypes)
#endif

@end
