#import "ABI30_0_0RNSVGGlyphContext.h"
#import <ReactABI30_0_0/ABI30_0_0RCTFont.h>
#import "ABI30_0_0RNSVGNode.h"
#import "ABI30_0_0RNSVGPropHelper.h"
#import "ABI30_0_0RNSVGFontData.h"
#import "ABI30_0_0RNSVGText.h"

// https://www.w3.org/TR/SVG/text.html#TSpanElement
@interface ABI30_0_0RNSVGGlyphContext () {
@public
    // Current stack (one per node push/pop)
    NSMutableArray *mFontContext_;

    // Unique input attribute lists (only added if node sets a value)
    NSMutableArray *mXsContext_;
    NSMutableArray *mYsContext_;
    NSMutableArray *mDXsContext_;
    NSMutableArray *mDYsContext_;
    NSMutableArray *mRsContext_;

    // Unique index into attribute list (one per unique list)
    NSMutableArray *mXIndices_;
    NSMutableArray *mYIndices_;
    NSMutableArray *mDXIndices_;
    NSMutableArray *mDYIndices_;
    NSMutableArray *mRIndices_;

    // Index of unique context used (one per node push/pop)
    NSMutableArray *mXsIndices_;
    NSMutableArray *mYsIndices_;
    NSMutableArray *mDXsIndices_;
    NSMutableArray *mDYsIndices_;
    NSMutableArray *mRsIndices_;

    // Calculated on push context, percentage and em length depends on parent font size
    double mFontSize_;
    ABI30_0_0RNSVGFontData *topFont_;

    // Current accumulated values
    // https://www.w3.org/TR/SVG/types.html#DataTypeCoordinate
    // <coordinate> syntax is the same as that for <length>
    double mX_;
    double mY_;

    // https://www.w3.org/TR/SVG/types.html#Length
    double mDX_;
    double mDY_;

    // Current <list-of-coordinates> SVGLengthList
    // https://www.w3.org/TR/SVG/types.html#InterfaceSVGLengthList
    // https://www.w3.org/TR/SVG/types.html#DataTypeCoordinates

    // https://www.w3.org/TR/SVG/text.html#TSpanElementXAttribute
    NSArray *mXs_;

    // https://www.w3.org/TR/SVG/text.html#TSpanElementYAttribute
    NSArray *mYs_;

    // Current <list-of-lengths> SVGLengthList
    // https://www.w3.org/TR/SVG/types.html#DataTypeLengths

    // https://www.w3.org/TR/SVG/text.html#TSpanElementDXAttribute
    NSArray *mDXs_;

    // https://www.w3.org/TR/SVG/text.html#TSpanElementDYAttribute
    NSArray *mDYs_;

    // Current <list-of-numbers> SVGLengthList
    // https://www.w3.org/TR/SVG/types.html#DataTypeNumbers

    // https://www.w3.org/TR/SVG/text.html#TSpanElementRotateAttribute
    NSArray *mRs_;

    // Current attribute list index
    long mXsIndex_;
    long mYsIndex_;
    long mDXsIndex_;
    long mDYsIndex_;
    long mRsIndex_;

    // Current value index in current attribute list
    long mXIndex_;
    long mYIndex_;
    long mDXIndex_;
    long mDYIndex_;
    long mRIndex_;

    // Top index of stack
    long mTop_;

    // Constructor parameters
    float mScale_;
    float mWidth_;
    float mHeight_;
}

- (void)pushContext:(ABI30_0_0RNSVGText *)node
               font:(NSDictionary *)font
                  x:(NSArray*)x
                  y:(NSArray*)y
             deltaX:(NSArray*)deltaX
             deltaY:(NSArray*)deltaY
             rotate:(NSArray*)rotate;

- (void)pushContext:(ABI30_0_0RNSVGGroup*)node
               font:(NSDictionary *)font;
@end

@implementation ABI30_0_0RNSVGGlyphContext


- (CTFontRef)getGlyphFont
{
    NSString *fontFamily = topFont_->fontFamily;
    NSNumber * fontSize = [NSNumber numberWithDouble:topFont_->fontSize];

    NSString * fontWeight = [ABI30_0_0RNSVGFontWeightToString(topFont_->fontWeight) lowercaseString];
    NSString * fontStyle = ABI30_0_0RNSVGFontStyleStrings[topFont_->fontStyle];

    BOOL fontFamilyFound = NO;
    NSArray *supportedFontFamilyNames = [UIFont familyNames];

    if ([supportedFontFamilyNames containsObject:fontFamily]) {
        fontFamilyFound = YES;
    } else {
        for (NSString *fontFamilyName in supportedFontFamilyNames) {
            if ([[UIFont fontNamesForFamilyName: fontFamilyName] containsObject:fontFamily]) {
                fontFamilyFound = YES;
                break;
            }
        }
    }
    fontFamily = fontFamilyFound ? fontFamily : nil;

    return (__bridge CTFontRef)[ABI30_0_0RCTFont updateFont:nil
                                        withFamily:fontFamily
                                              size:fontSize
                                            weight:fontWeight
                                             style:fontStyle
                                           variant:nil
                                   scaleMultiplier:1.0];
}

void ABI30_0_0pushIndices(ABI30_0_0RNSVGGlyphContext *self) {
    [self->mXsIndices_ addObject:[NSNumber numberWithLong:self->mXsIndex_]];
    [self->mYsIndices_ addObject:[NSNumber numberWithLong:self->mYsIndex_]];
    [self->mDXsIndices_ addObject:[NSNumber numberWithLong:self->mDXsIndex_]];
    [self->mDYsIndices_ addObject:[NSNumber numberWithLong:self->mDYsIndex_]];
    [self->mRsIndices_ addObject:[NSNumber numberWithLong:self->mRsIndex_]];
}

- (instancetype)initWithScale:(float)scale_
                        width:(float)width
                       height:(float)height {
    self->mFontContext_ = [[NSMutableArray alloc]init];
    self->mXsContext_ = [[NSMutableArray alloc]init];
    self->mYsContext_ = [[NSMutableArray alloc]init];
    self->mDXsContext_ = [[NSMutableArray alloc]init];
    self->mDYsContext_ = [[NSMutableArray alloc]init];
    self->mRsContext_ = [[NSMutableArray alloc]init];

    self->mXIndices_ = [[NSMutableArray alloc]init];
    self->mYIndices_ = [[NSMutableArray alloc]init];
    self->mDXIndices_ = [[NSMutableArray alloc]init];
    self->mDYIndices_ = [[NSMutableArray alloc]init];
    self->mRIndices_ = [[NSMutableArray alloc]init];

    self->mXsIndices_ = [[NSMutableArray alloc]init];
    self->mYsIndices_ = [[NSMutableArray alloc]init];
    self->mDXsIndices_ = [[NSMutableArray alloc]init];
    self->mDYsIndices_ = [[NSMutableArray alloc]init];
    self->mRsIndices_ = [[NSMutableArray alloc]init];

    self->mFontSize_ = ABI30_0_0RNSVGFontData_DEFAULT_FONT_SIZE;
    self->topFont_ = [ABI30_0_0RNSVGFontData Defaults];

    self->mXs_ = [[NSArray alloc]init];
    self->mYs_ = [[NSArray alloc]init];
    self->mDXs_ = [[NSArray alloc]init];
    self->mDYs_ = [[NSArray alloc]init];
    self->mRs_ = [[NSArray alloc]initWithObjects:@0, nil];

    self->mXIndex_ = -1;
    self->mYIndex_ = -1;
    self->mDXIndex_ = -1;
    self->mDYIndex_ = -1;
    self->mRIndex_ = -1;

    self->mScale_ = scale_;
    self->mWidth_ = width;
    self->mHeight_ = height;

    [self->mXsContext_ addObject:self->mXs_];
    [self->mYsContext_ addObject:self->mYs_];
    [self->mDXsContext_ addObject:self->mDXs_];
    [self->mDYsContext_ addObject:self->mDYs_];
    [self->mRsContext_ addObject:self->mRs_];

    [self->mXIndices_ addObject:[NSNumber numberWithLong:self->mXIndex_]];
    [self->mYIndices_ addObject:[NSNumber numberWithLong:self->mYIndex_]];
    [self->mDXIndices_ addObject:[NSNumber numberWithLong:self->mDXIndex_]];
    [self->mDYIndices_ addObject:[NSNumber numberWithLong:self->mDYIndex_]];
    [self->mRIndices_ addObject:[NSNumber numberWithLong:self->mRIndex_]];

    [self->mFontContext_ addObject:self->topFont_];
    ABI30_0_0pushIndices(self);
    return self;
}

- (ABI30_0_0RNSVGFontData *)getFont {
    return topFont_;
}

ABI30_0_0RNSVGFontData *ABI30_0_0getTopOrParentFont(ABI30_0_0RNSVGGlyphContext *self, ABI30_0_0RNSVGGroup* child) {
    if (self->mTop_ > 0) {
        return self->topFont_;
    } else {
        ABI30_0_0RNSVGGroup* parentRoot = [child getParentTextRoot];
        ABI30_0_0RNSVGFontData* Defaults = [ABI30_0_0RNSVGFontData Defaults];
        while (parentRoot != nil) {
            ABI30_0_0RNSVGFontData *map = [[parentRoot getGlyphContext] getFont];
            if (map != Defaults) {
                return map;
            }
            parentRoot = [parentRoot getParentTextRoot];
        }
        return Defaults;
    }
}

void ABI30_0_0pushNodeAndFont(ABI30_0_0RNSVGGlyphContext *self, ABI30_0_0RNSVGGroup* node, NSDictionary* font) {
    ABI30_0_0RNSVGFontData *parent = ABI30_0_0getTopOrParentFont(self, node);
    self->mTop_++;
    if (font == nil) {
        [self->mFontContext_ addObject:parent];
        return;
    }
    ABI30_0_0RNSVGFontData *data = [ABI30_0_0RNSVGFontData initWithNSDictionary:font
                                                 parent:parent
                                                  scale:self->mScale_];
    self->mFontSize_ = data->fontSize;
    [self->mFontContext_ addObject:data];
    self->topFont_ = data;
}

- (void)pushContext:(ABI30_0_0RNSVGGroup*)node
               font:(NSDictionary*)font {
    ABI30_0_0pushNodeAndFont(self, node, font);
    ABI30_0_0pushIndices(self);
}

- (void)pushContext:(ABI30_0_0RNSVGText*)node
               font:(NSDictionary*)font
                  x:(NSArray*)x
                  y:(NSArray*)y
             deltaX:(NSArray*)deltaX
             deltaY:(NSArray*)deltaY
             rotate:(NSArray*)rotate {
    ABI30_0_0pushNodeAndFont(self, (ABI30_0_0RNSVGGroup*)node, font);
    if (x != nil && [x count] != 0) {
        mXsIndex_++;
        mXIndex_ = -1;
        [mXIndices_ addObject:[NSNumber numberWithLong:mXIndex_]];
        mXs_ = x;
        [mXsContext_ addObject:mXs_];
    }
    if (y != nil && [y count] != 0) {
        mYsIndex_++;
        mYIndex_ = -1;
        [mYIndices_ addObject:[NSNumber numberWithLong:mYIndex_]];
        mYs_ = y;
        [mYsContext_ addObject:mYs_];
    }
    if (deltaX != nil && [deltaX count] != 0) {
        mDXsIndex_++;
        mDXIndex_ = -1;
        [mDXIndices_ addObject:[NSNumber numberWithLong:mDXIndex_]];
        mDXs_ = deltaX;
        [mDXsContext_ addObject:mDXs_];
    }
    if (deltaY != nil && [deltaY count] != 0) {
        mDYsIndex_++;
        mDYIndex_ = -1;
        [mDYIndices_ addObject:[NSNumber numberWithLong:mDYIndex_]];
        mDYs_ = deltaY;
        [mDYsContext_ addObject:mDYs_];
    }
    if (rotate != nil && [rotate count] != 0) {
        mRsIndex_++;
        mRIndex_ = -1;
        [mRIndices_ addObject:[NSNumber numberWithLong:mRIndex_]];
        mRs_ = [rotate valueForKeyPath:@"self.doubleValue"];
        [mRsContext_ addObject:mRs_];
    }
    ABI30_0_0pushIndices(self);
}

- (void)popContext {
    [mFontContext_ removeLastObject];
    [mXsIndices_ removeLastObject];
    [mYsIndices_ removeLastObject];
    [mDXsIndices_ removeLastObject];
    [mDYsIndices_ removeLastObject];
    [mRsIndices_ removeLastObject];

    mTop_--;

    long x = mXsIndex_;
    long y = mYsIndex_;
    long dx = mDXsIndex_;
    long dy = mDYsIndex_;
    long r = mRsIndex_;

    topFont_ = [mFontContext_ lastObject];

    mXsIndex_ = [[mXsIndices_ lastObject] longValue];
    mYsIndex_ = [[mYsIndices_ lastObject] longValue];
    mDXsIndex_ = [[mDXsIndices_ lastObject] longValue];
    mDYsIndex_ = [[mDYsIndices_ lastObject] longValue];
    mRsIndex_ = [[mRsIndices_ lastObject] longValue];

    if (x != mXsIndex_) {
        [mXsContext_ removeObjectAtIndex:x];
        mXs_ = [mXsContext_ objectAtIndex:mXsIndex_];
        mXIndex_ = [[mXIndices_ objectAtIndex:mXsIndex_] longValue];
    }
    if (y != mYsIndex_) {
        [mYsContext_ removeObjectAtIndex:y];
        mYs_ = [mYsContext_ objectAtIndex:mYsIndex_];
        mYIndex_ = [[mYIndices_ objectAtIndex:mYsIndex_] longValue];
    }
    if (dx != mDXsIndex_) {
        [mDXsContext_ removeObjectAtIndex:dx];
        mDXs_ = [mDXsContext_ objectAtIndex:mDXsIndex_];
        mDXIndex_ = [[mDXIndices_ objectAtIndex:mDXsIndex_] longValue];
    }
    if (dy != mDYsIndex_) {
        [mDYsContext_ removeObjectAtIndex:dy];
        mDYs_ = [mDYsContext_ objectAtIndex:mDYsIndex_];
        mDYIndex_ = [[mDYIndices_ objectAtIndex:mDYsIndex_] longValue];
    }
    if (r != mRsIndex_) {
        [mRsContext_ removeObjectAtIndex:r];
        mRs_ = [mRsContext_ objectAtIndex:mRsIndex_];
        mRIndex_ = [[mRIndices_ objectAtIndex:mRsIndex_] longValue];
    }
}

void ABI30_0_0incrementIndices(NSMutableArray *indices, long topIndex) {
    for (long index = topIndex; index >= 0; index--) {
        long xIndex = [[indices  objectAtIndex:index] longValue];
        [indices setObject:[NSNumber numberWithLong:xIndex + 1] atIndexedSubscript:index];
    }
}

// https://www.w3.org/TR/SVG11/text.html#FontSizeProperty

/**
 * Get font size from context.
 * <p>
 * ‘font-size’
 * Value:       < absolute-size > | < relative-size > | < length > | < percentage > | inherit
 * Initial:     medium
 * Applies to:  text content elements
 * Inherited:   yes, the computed value is inherited
 * Percentages: refer to parent element's font size
 * Media:       visual
 * Animatable:  yes
 * <p>
 * This property refers to the size of the font from baseline to
 * baseline when multiple lines of text are set solid in a multiline
 * layout environment.
 * <p>
 * For SVG, if a < length > is provided without a unit identifier
 * (e.g., an unqualified number such as 128), the SVG user agent
 * processes the < length > as a height value in the current user
 * coordinate system.
 * <p>
 * If a < length > is provided with one of the unit identifiers
 * (e.g., 12pt or 10%), then the SVG user agent converts the
 * < length > into a corresponding value in the current user
 * coordinate system by applying the rules described in Units.
 * <p>
 * Except for any additional information provided in this specification,
 * the normative definition of the property is in CSS2 ([CSS2], section 15.2.4).
 */
- (double)getFontSize {
    return mFontSize_;
}

- (double)nextXWithDouble:(double)advance {
    ABI30_0_0incrementIndices(mXIndices_, mXsIndex_);
    long nextIndex = mXIndex_ + 1;
    if (nextIndex < [mXs_ count]) {
        mDX_ = 0;
        mXIndex_ = nextIndex;
        NSString *string = [mXs_ objectAtIndex:nextIndex];
        mX_ = [ABI30_0_0RNSVGPropHelper fromRelativeWithNSString:string
                                            relative:mWidth_
                                              offset:0
                                               scale:mScale_
                                            fontSize:mFontSize_];
    }
    mX_ += advance;
    return mX_;
}

- (double)nextY {
    ABI30_0_0incrementIndices(mYIndices_, mYsIndex_);
    long nextIndex = mYIndex_ + 1;
    if (nextIndex < [mYs_ count]) {
        mDY_ = 0;
        mYIndex_ = nextIndex;
        NSString *string = [mYs_ objectAtIndex:nextIndex];
        mY_ = [ABI30_0_0RNSVGPropHelper fromRelativeWithNSString:string
                                            relative:mHeight_
                                              offset:0
                                               scale:mScale_
                                            fontSize:mFontSize_];
    }
    return mY_;
}

- (double)nextDeltaX {
    ABI30_0_0incrementIndices(mDXIndices_, mDXsIndex_);
    long nextIndex = mDXIndex_ + 1;
    if (nextIndex < [mDXs_ count]) {
        mDXIndex_ = nextIndex;
        NSString *string = [mDXs_ objectAtIndex:nextIndex];
        double val = [ABI30_0_0RNSVGPropHelper fromRelativeWithNSString:string
                                                   relative:mWidth_
                                                     offset:0
                                                      scale:mScale_
                                                   fontSize:mFontSize_];
        mDX_ += val;
    }
    return mDX_;
}

- (double)nextDeltaY {
    ABI30_0_0incrementIndices(mDYIndices_, mDYsIndex_);
    long nextIndex = mDYIndex_ + 1;
    if (nextIndex < [mDYs_ count]) {
        mDYIndex_ = nextIndex;
        NSString *string = [mDYs_ objectAtIndex:nextIndex];
        double val = [ABI30_0_0RNSVGPropHelper fromRelativeWithNSString:string
                                                   relative:mHeight_
                                                     offset:0
                                                      scale:mScale_
                                                   fontSize:mFontSize_];
        mDY_ += val;
    }
    return mDY_;
}

- (NSNumber*)nextRotation {
    ABI30_0_0incrementIndices(mRIndices_, mRsIndex_);
    long nextIndex = mRIndex_ + 1;
    long count = [mRs_ count];
    if (nextIndex < count) {
        mRIndex_ = nextIndex;
    } else {
        mRIndex_ = count - 1;
    }
    return mRs_[mRIndex_];
}

- (float)getWidth {
    return mWidth_;
}

- (float)getHeight {
    return mHeight_;
}
@end
