#import <React/RCTBaseTextInputView.h>
#import <React/RCTViewManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNSelectableTextView : RCTBaseTextInputView

@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nonatomic, copy) NSArray<NSDictionary *> *highlights;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, copy) RCTDirectEventBlock onHighlightPress;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;

@end


NS_ASSUME_NONNULL_END
