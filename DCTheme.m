
@import UIKit;

#import "DCTheme.h"

NSString* kTypeface       =       @"typeface";
NSString* kSize           =       @"size";
NSString* kFont           =       @"font";
NSString* kHeading        =       @"heading";
NSString* kSubheading     =       @"subheading";
NSString* kBody           =       @"body";
NSString* kSecBody        =       @"secondary_body";

NSString* kColors         =       @"colors";

#pragma standard theme keys
NSString* const kPrimary        =       @"primary";
NSString* const kSecondary      =       @"secondary";
NSString* const kTernary        =       @"ternary";

static NSDictionary* sTheme;
// Key: Color name define in theme. Value: UIColor instance
static NSMutableDictionary* sCachedColors;

@implementation DCTheme

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

+ (void)initialize {
    NSString* themeFileName = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"json"];
    NSData* themeData = [NSData dataWithContentsOfFile:themeFileName];
    NSError* err;
    sTheme = [NSJSONSerialization JSONObjectWithData:themeData options:NSJSONReadingAllowFragments error:&err];
    sCachedColors = [[NSMutableDictionary alloc] init];
    if(err) {
        @throw [NSException exceptionWithName:@"Cannot load theme" reason:err.description userInfo:nil];
    } 
}

+ (UIFont*)fontForStyle:(NSString*)style {
    NSDictionary* typeface = sTheme[kTypeface];
    NSString* fontName = (typeface[style][kFont]) ? (typeface[style][kFont]) : (typeface[kFont]);
    NSNumber* size = typeface[style][kSize];
    if(fontName)
        return [UIFont fontWithName:fontName size:size.floatValue];
    else
        return [UIFont systemFontOfSize:size.floatValue];
}

+ (UIFont*)fontForHeading {
    return [self fontForStyle:kHeading];
}

+ (UIFont*)fontForSubheading {
    return [self fontForStyle:kSubheading];
}

+ (UIFont*)fontForBody {
    return [self fontForStyle:kBody];
}

+ (UIFont*)fontForSecondaryBody {
    return [self fontForStyle:kSecBody];
}

+ (UIColor*)colorWithName:(NSString*)colorName {
    if(sCachedColors[colorName]) {
        return sCachedColors[colorName];
    }
    
    NSString* colorStr = sTheme[kColors][colorName];
    if([colorStr rangeOfString:@","].location != NSNotFound) {
        // Create from RGBA
        NSArray* colorArray = [colorStr componentsSeparatedByString:@","];
        CGFloat alpha = 1;
        if(colorArray.count == 4)
            alpha = [((NSString*) [colorArray lastObject]) floatValue];
        
        CGFloat red = [colorArray[0] floatValue];
        CGFloat green = [colorArray[1] floatValue];
        CGFloat blue = [colorArray[2] floatValue];
        UIColor* color = [UIColor colorWithRed:red/255
                               green:green/255
                                blue:blue/255
                               alpha:alpha];
        [sCachedColors setValue:color forKey:colorName];
        return color;
    } else if([colorStr rangeOfString:@"#"].location != NSNotFound){
        // Create from hex
        UIColor* color = [DCTheme colorwithHexString:colorStr];
        [sCachedColors setValue:color forKey:colorName];
        return color;
    } else {
        NSString* errDesc = [NSString stringWithFormat:@"Invalid color %@ for color name %@",colorStr, colorName];
        @throw [NSException exceptionWithName:@"Cannot load color"
                                       reason:errDesc
                                     userInfo:nil];
    }
    
    return [UIColor blackColor];
}

+ (UIColor*)primaryColor {
    return [DCTheme colorWithName:kPrimary];
}

+ (UIColor*)secondaryColor {
    return [DCTheme colorWithName:kSecondary];
}

+ (UIColor*)ternaryColor {
    return [DCTheme colorWithName:kTernary];
}

+ (UIColor *)colorwithHexString:(NSString *)hexStr {

    // # RRGGBBAA
    //-----------------------------------------
    // Convert hex string to an integer
    //-----------------------------------------
    unsigned int hexint = 0;
    
    // Create scanner
    NSScanner *scanner = [NSScanner scannerWithString:hexStr];
    
    // Tell scanner to skip the # character
    [scanner setCharactersToBeSkipped:[NSCharacterSet
                                       characterSetWithCharactersInString:@"#"]];
    [scanner scanHexInt:&hexint];
    
    //-----------------------------------------
    // Create color object, specifying alpha
    //-----------------------------------------
    UIColor *color;
    if(hexStr.length <= 7) {
        color = [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF0000) >> 16))/255
                        green:((CGFloat) ((hexint & 0xFF00) >> 8))/255
                         blue:((CGFloat) (hexint & 0xFF))/255
                        alpha:1];
    } else {
        color = [UIColor colorWithRed:((CGFloat) ((hexint & 0xFF000000) >> 16))/255
                                green:((CGFloat) ((hexint & 0xFF0000) >> 8))/255
                                 blue:((CGFloat) (hexint & 0xFF00))/255
                                alpha:((CGFloat) (hexint & 0xFF))/255];
    }
    
    return color;
}
@end
