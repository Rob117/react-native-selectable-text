#import "RNSelectableTextView.h"
#import <React/RCTTextAttributes.h>
#import <React/RCTUtils.h>
#import <React/RCTUITextView.h>
#import <React/RCTTextSelection.h>

NSString *const SELECTOR_CUSTOM = @"_SELECTOR_CUSTOM_";

@implementation RNSelectableTextView {
    RCTUITextView *_backedTextInputView;
    NSString *_value;
    UITextPosition *selectionStart;
    UITextPosition *beginning;
    NSMutableArray<NSValue *> *_highlightRanges;
}

- (instancetype)initWithBridge:(RCTBridge *)bridge {
    if (self = [super initWithBridge:bridge]) {
        _backedTextInputView = [[RCTUITextView alloc] initWithFrame:self.bounds];
        _backedTextInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backedTextInputView.backgroundColor = [UIColor clearColor];
        _backedTextInputView.textColor = [UIColor blackColor];
        _backedTextInputView.font = [UIFont systemFontOfSize:16];
        _backedTextInputView.textContainer.lineFragmentPadding = 0;
        _backedTextInputView.textContainerInset = UIEdgeInsetsZero;
        _backedTextInputView.scrollEnabled = NO;
        _backedTextInputView.textInputDelegate = self;
        _backedTextInputView.editable = NO;
        _backedTextInputView.selectable = YES;
        _backedTextInputView.contextMenuHidden = YES;
        
        beginning = _backedTextInputView.beginningOfDocument;
        _highlightColor = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.5];
        _highlightRanges = [NSMutableArray array];

        for (UIGestureRecognizer *gesture in [_backedTextInputView gestureRecognizers]) {
            if (![gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
                gesture.enabled = NO;
            }
        }

        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleLongPress:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleTap:)];
        tapGesture.numberOfTapsRequired = 2;
        
        UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]
            initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapGesture.numberOfTapsRequired = 1;

        [_backedTextInputView addGestureRecognizer:longPressGesture];
        [_backedTextInputView addGestureRecognizer:tapGesture];
        [_backedTextInputView addGestureRecognizer:singleTapGesture];
        
        [self addSubview:_backedTextInputView];
    }
    return self;
}

#pragma mark - Properties

- (void)setValue:(NSString *)value {
    _value = [value copy];
    [self updateAttributedText];
}

- (void)setTextAttributes:(RCTTextAttributes *)textAttributes {
    [super setTextAttributes:textAttributes];
    [self updateAttributedText];
}

- (void)setHighlights:(NSArray<NSDictionary *> *)highlights {
    [_highlightRanges removeAllObjects];
    
    for (NSDictionary *highlight in highlights) {
        NSInteger start = [highlight[@"start"] integerValue];
        NSInteger end = [highlight[@"end"] integerValue];
        if (start >= 0 && end > start) {
            [_highlightRanges addObject:[NSValue valueWithRange:NSMakeRange(start, end - start)]];
        }
    }
    
    [self updateAttributedText];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    [self updateAttributedText];
}

#pragma mark - Text Rendering

- (void)updateAttributedText {
    if (!_value) return;
    
    NSDictionary<NSAttributedStringKey,id> *effectiveTextAttributes = self.textAttributes.effectiveTextAttributes;
    NSMutableDictionary *mutableAttributes = [effectiveTextAttributes mutableCopy];
    if (!mutableAttributes[NSForegroundColorAttributeName]) {
        mutableAttributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
        initWithString:_value
        attributes:mutableAttributes];
    
    for (NSValue *rangeValue in _highlightRanges) {
        NSRange range = [rangeValue rangeValue];
        if (range.location + range.length <= attributedString.length) {
            [attributedString addAttribute:NSBackgroundColorAttributeName
                                    value:self.highlightColor
                                    range:range];
        }
    }
    
    [_backedTextInputView setAttributedText:attributedString];
}

#pragma mark - Gesture Handling

- (void)_handleGesture {
    if (!_backedTextInputView.isFirstResponder) {
        [_backedTextInputView becomeFirstResponder];
    }

    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) return;

    UITextRange *selectedRange = _backedTextInputView.selectedTextRange;
    if ([_backedTextInputView offsetFromPosition:selectedRange.start toPosition:selectedRange.end] == 0) {
        return;
    }

    NSMutableArray *menuControllerItems = [NSMutableArray arrayWithCapacity:self.menuItems.count];
    for (NSString *menuItemName in self.menuItems) {
        NSString *sel = [NSString stringWithFormat:@"%@%@", SELECTOR_CUSTOM, menuItemName];
        UIMenuItem *item = [[UIMenuItem alloc]
            initWithTitle:menuItemName
            action:NSSelectorFromString(sel)];
        [menuControllerItems addObject:item];
    }

    menuController.menuItems = menuControllerItems;
    [menuController setTargetRect:self.bounds inView:self];
    [menuController setMenuVisible:YES animated:YES];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gesture {
    CGPoint pos = [gesture locationInView:_backedTextInputView];
    pos.y += _backedTextInputView.contentOffset.y;

    UITextPosition *tapPos = [_backedTextInputView closestPositionToPoint:pos];
    NSInteger tapOffset = [_backedTextInputView offsetFromPosition:beginning toPosition:tapPos];
    
    for (NSDictionary *highlight in self.highlights) {
        NSInteger start = [highlight[@"start"] integerValue];
        NSInteger end = [highlight[@"end"] integerValue];
        NSString *highlightId = highlight[@"id"];
        
        if (tapOffset >= start && tapOffset <= end && highlightId) {
            self.onHighlightPress(@{@"id": highlightId});
            return;
        }
    }
    
    UITextRange *word = [_backedTextInputView.tokenizer
        rangeEnclosingPosition:tapPos
        withGranularity:UITextGranularityWord
        inDirection:UITextLayoutDirectionRight];

    if (!word) return;

    NSInteger location = [_backedTextInputView
        offsetFromPosition:_backedTextInputView.beginningOfDocument
        toPosition:word.start];
    NSInteger length = [_backedTextInputView
        offsetFromPosition:word.start
        toPosition:word.end];

    [_backedTextInputView setSelectedRange:NSMakeRange(location, length)];
    [self _handleGesture];
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    CGPoint pos = [gesture locationInView:_backedTextInputView];
    pos.y += _backedTextInputView.contentOffset.y;

    UITextPosition *tapPos = [_backedTextInputView closestPositionToPoint:pos];
    UITextRange *word = [_backedTextInputView.tokenizer
        rangeEnclosingPosition:tapPos
        withGranularity:UITextGranularityWord
        inDirection:UITextWritingDirectionNatural];

    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if (_backedTextInputView.selectedTextRange != nil) return;
            selectionStart = word.start;
            break;
            
        case UIGestureRecognizerStateEnded:
            selectionStart = nil;
            [self _handleGesture];
            return;
            
        default:
            break;
    }

    UITextPosition *selectionEnd = word.end;
    NSInteger location = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger endLocation = [_backedTextInputView offsetFromPosition:beginning toPosition:selectionEnd];

    if (location > endLocation) {
        NSInteger temp = location;
        location = endLocation;
        endLocation = temp;
    }
    if (location == 0 && endLocation == 0) return;

    [_backedTextInputView setSelectedRange:NSMakeRange(location, endLocation - location)];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [_backedTextInputView select:self];
    [_backedTextInputView selectAll:self];
    [self _handleGesture];
}

#pragma mark - Menu Item Handling

- (void)tappedMenuItem:(NSString *)eventType {
    RCTTextSelection *selection = self.selection;
    NSUInteger start = selection.start;
    NSUInteger end = selection.end - selection.start;

    self.onSelection(@{
        @"content": [[self.attributedText string] substringWithRange:NSMakeRange(start, end)],
        @"eventType": eventType,
        @"selectionStart": @(start),
        @"selectionEnd": @(selection.end)
    });

    [_backedTextInputView setSelectedTextRange:nil notifyDelegate:NO];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([super methodSignatureForSelector:sel]) {
        return [super methodSignatureForSelector:sel];
    }
    return [super methodSignatureForSelector:@selector(tappedMenuItem:)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSString *sel = NSStringFromSelector([invocation selector]);
    NSRange match = [sel rangeOfString:SELECTOR_CUSTOM];
    if (match.location == 0) {
        [self tappedMenuItem:[sel substringFromIndex:17]];
    } else {
        [super forwardInvocation:invocation];
    }
}

#pragma mark - Responder Chain

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (selectionStart != nil) return NO;
    NSString *sel = NSStringFromSelector(action);
    NSRange match = [sel rangeOfString:SELECTOR_CUSTOM];
    return (match.location == 0);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (![_backedTextInputView isDescendantOfView:hitView] && _backedTextInputView.isFirstResponder) {
        [_backedTextInputView setSelectedTextRange:nil notifyDelegate:YES];
    }
    return hitView;
}

#pragma mark - Required Overrides

- (id<RCTBackedTextInputViewProtocol>)backedTextInputView {
    return _backedTextInputView;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    if (self.value) {
        [self updateAttributedText];
    } else {
        [super setAttributedText:attributedText];
    }
}

@end

