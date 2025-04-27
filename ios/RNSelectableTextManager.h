#import <React/RCTBaseTextInputViewManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNSelectableTextManager : RCTBaseTextInputViewManager

// Properties
@property (nonnull, nonatomic, copy) NSString *value;
@property (nonatomic, copy) RCTDirectEventBlock onSelection;
@property (nullable, nonatomic, copy) NSArray<NSString *> *menuItems;
@property (nonatomic, copy) RCTDirectEventBlock onHighlightPress;
@property (nonatomic, copy) NSArray *highlights;  // Add highlights property
@property (nonatomic, strong) UIColor *highlightColor;  // Add highlightColor property

@end

NS_ASSUME_NONNULL_END
