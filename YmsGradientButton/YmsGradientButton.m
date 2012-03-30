// 
// Copyright 2012 Yummy Melon Software LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  Author: Charles Y. Choi <charles.choi@yummymelon.com>
//

#import "YmsGradientButton.h"


@implementation YmsGradientButton
@synthesize resourceName;


- (void)awakeFromNib {
  [super awakeFromNib];
  [self renderGradients];
}

- (void)renderGradients {
  self.layer.masksToBounds = NO;
  
  if (self.resourceName == nil) {
    self.resourceName = NSStringFromClass([self class]);
  }
  
  NSString *path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
  
  if (path == nil) {
    NSLog(@"WARNING: resource %@.plist does not exist. Using default resource YmsGradientButton.plist.", self.resourceName);
    self.resourceName = @"YmsGradientButton";
    path = [[NSBundle mainBundle] pathForResource:self.resourceName ofType:@"plist"];
  }
  
  NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
  
  if ([self validateConfiguration:buttonConfig]) {
    [self configureShadow:buttonConfig];
    [self genGradientsForState:UIControlStateNormal withConfig:buttonConfig];        
    [self genGradientsForState:UIControlStateHighlighted withConfig:buttonConfig];        
    [self genGradientsForState:UIControlStateDisabled withConfig:buttonConfig];        
    
    [self.layer setNeedsDisplay];
  }
  else {
    [NSException raise:@"Invalid YmsGradientButton Configuration" 
                format:@"Please revise the file %@.plist to confirm that it has legal values.", self.resourceName];
  }
}


- (void)renderGradientsWithResourceName:(NSString *)name {
  self.resourceName = name;
  [self renderGradients];
}

- (void)genGradientsForState:(UIControlState)aState withConfig:(NSDictionary *)buttonConfig {
  UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 2.0); // using a 2.0 scale enables high-quality rendering for Retina displays
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  [self gradientsImplementationForState:aState withConfig:buttonConfig forContext:context];
  
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
	
  [self setBackgroundImage:image forState:aState];
}

- (void)gradientsImplementationForState:(UIControlState)aState 
                            withConfig:(NSDictionary *)buttonConfig 
                            forContext:(CGContextRef)context {
  
  /*
   * This method can be overridden if you want to implement your own gradient styling, 
   * provided you maintain compliance with the plist specification.
   */
  
  NSString *stateName;
  
  if (aState == UIControlStateNormal) {
    stateName = @"normal";
  }
	
  else if (aState == UIControlStateHighlighted) {
    stateName = @"highlighted";
  }
	
  else if (aState == UIControlStateDisabled) {
    stateName = @"disabled";
  }
  
  NSArray *gradients = (NSArray *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"gradients"];
  
  NSNumber *textColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"textColor"];
  NSNumber *cornerRadius = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"cornerRadius"];
  NSNumber *borderColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderColor"];
  NSNumber *borderWidth = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderWidth"];
  
  // Configure Text Color
  int textColorValue = [textColor integerValue];
  [self setTitleColor:ARGBCSS(textColorValue) forState:aState];
  
  float cornerRadiusValue = [cornerRadius floatValue];
  int borderColorValue = [borderColor integerValue];
  float borderWidthValue = [borderWidth floatValue];
  
  float roundBorderMargin = cornerRadiusValue > 0 ? 1 : 0;
  // Render path and set clipping region
  UIBezierPath *bPath = [UIBezierPath bezierPathWithRoundedRect:
                         CGRectMake(roundBorderMargin, 
                                    roundBorderMargin, 
                                    self.bounds.size.width - 2 * roundBorderMargin, 
                                    self.bounds.size.height - 2 * roundBorderMargin)
                                                   cornerRadius:cornerRadiusValue];
  // Making the path a little smaller or we'll get some artifacts on the border.
  
  [ARGBCSS(borderColorValue) setStroke];
  [[UIColor clearColor] setFill];
  bPath.lineWidth = borderWidthValue;
  [bPath fill];
  [bPath stroke];
  
  CGContextAddPath(context, bPath.CGPath);
  CGContextClip(context);
  
  // Render gradients

  CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
  for (NSDictionary *gradient in gradients) {
    NSArray *colorArray = (NSArray *)[gradient objectForKey:@"colors"];
    NSArray *locationsArray = (NSArray *)[gradient objectForKey:@"locations"];
    NSArray *startPointArray = (NSArray *)[gradient objectForKey:@"startPoint"];
    NSArray *endPointArray = (NSArray *)[gradient objectForKey:@"endPoint"];

    CGGradientRef stateGradient;
        
    CGFloat *locations = malloc(sizeof(CGFloat) * locationsArray.count);
    
    for (int i = 0; i < locationsArray.count; i++) {
      NSNumber *e = (NSNumber *)[locationsArray objectAtIndex:i];
      
      CGFloat val = [e floatValue];
      
      locations[i] = val;
    }
    
    size_t numLocations = locationsArray.count;
    
    CGFloat *components = malloc(sizeof(CGFloat) * colorArray.count * 4);
    
    for (int i=0;  i < colorArray.count; i++) {
      NSNumber *e = (NSNumber *)[colorArray objectAtIndex:i];
      int rgb = [e integerValue];
      
      double r = (rgb >> 16 & 0xFF)/255.0;
      double g = (rgb >> 8 & 0xFF)/255.0;
      double b = (rgb & 0xFF)/255.0;
      double a = (rgb >> 24 & 0xFF)/255.0;
      
      components[i * 4] = r;
      components[(i * 4) + 1] = g;
      components[(i * 4) + 2] = b;
      components[(i * 4) + 3] = a;
    }
    
    stateGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, numLocations);
    
    CGRect currentBounds = self.bounds;
    
    float startPointNormalizeX = [(NSNumber *)[startPointArray objectAtIndex:0] floatValue];
    float startPointNormalizeY = [(NSNumber *)[startPointArray objectAtIndex:1] floatValue];
    float endPointNormalizeX = [(NSNumber *)[endPointArray objectAtIndex:0] floatValue];
    float endPointNormalizeY = [(NSNumber *)[endPointArray objectAtIndex:1] floatValue];
    
    CGPoint startPoint = CGPointMake(CGRectGetMaxX(currentBounds) * startPointNormalizeX, CGRectGetMaxY(currentBounds) * startPointNormalizeY);
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(currentBounds) * endPointNormalizeX, CGRectGetMaxY(currentBounds) * endPointNormalizeY);
    CGContextDrawLinearGradient(context, stateGradient, startPoint, endPoint, 0);
    
    CGGradientRelease(stateGradient);
    
    free(locations);
    free(components);
  }
  CGColorSpaceRelease(rgbColorspace); 
  
  [self addGraphicsForState:aState forContext:context withOffset:cornerRadiusValue];
  
}


- (void)addGraphicsForState:(UIControlState)aState forContext:(CGContextRef)context withOffset:(CGFloat)offset {
  // Override this method to add more Core Graphics Elements
}



- (BOOL)validateConfiguration:(NSDictionary *)buttonConfig {
  BOOL result = YES;
  
  NSArray *states = [[NSArray alloc] initWithObjects:@"normal", @"highlighted", @"disabled", nil];
  
  for (NSString *stateName in states) {
    NSArray *gradients = (NSArray *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"gradients"];
    
    if ((gradients == nil) || (gradients.count == 0)) {
      NSLog(@"ERROR: gradients array is not defined in the %@ section of %@.plist", stateName, self.resourceName);
      return NO;
    }
    else {
      for (NSDictionary *gradient in gradients) {
        // Processing each gradient defined in the plist
        
        NSArray *colorArray = (NSArray *)[gradient objectForKey:@"colors"];
        NSArray *locations = (NSArray *)[gradient objectForKey:@"locations"];
        NSArray *startPoint = (NSArray *)[gradient objectForKey:@"startPoint"];
        NSArray *endPoint = (NSArray *)[gradient objectForKey:@"endPoint"];
              
        if ((colorArray == nil) || (colorArray.count == 0)) { 
          NSLog(@"ERROR: colors array is not defined in the %@ section of %@.plist", stateName, self.resourceName);
          return NO;
        }
        else {
          if (locations != nil) {
            if (colorArray.count < locations.count)
              NSLog(@"WARNING: colors and locations array count mismatch in the %@ section of %@.plist. " 
                    "They should either be equal or there should be no elements in the locations array.", stateName, self.resourceName);
            
            else if ((colorArray.count > locations.count) && (locations.count > 0)) {
              NSLog(@"ERROR:The size of the array colors and the array locations do not match in the %@ section of %@.plist. "
                    "They should either be equal or there should be no elements in the locations array.", stateName, self.resourceName);
              return NO;
            }
          }
        }
        
        if (startPoint == nil) {
          NSLog(@"ERROR: startPoint is not defined in the %@ section of %@.plist", stateName, self.resourceName);
          return NO;
        }
        else {
          if (startPoint.count != 2) {
            NSLog(@"ERROR: startPoint must have 2 elements (default 0.5, 0.0) in the %@ section of %@.plist", stateName, self.resourceName);
            return NO;
          }
        }
        
        if (endPoint == nil) {
          NSLog(@"ERROR: endPoint is not defined in the %@ section of %@.plist", stateName, self.resourceName);
          return NO;
        } 
        else {
          if (endPoint.count != 2) {
            NSLog(@"ERROR: endPoint must have 2 elements (default 0.5, 1.0) in the %@ section of %@.plist", stateName, self.resourceName);
            return NO;
          }
        }
      }
    }
    
    NSNumber *textColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"textColor"];
    NSNumber *cornerRadius = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"cornerRadius"];
    NSNumber *borderColor = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderColor"];
    NSNumber *borderWidth = (NSNumber *)[(NSDictionary *)[buttonConfig objectForKey:stateName] objectForKey:@"borderWidth"];
    
        
    if (textColor == nil) {
      NSLog(@"ERROR: textColor is not defined in the %@ section of %@.plist", stateName, self.resourceName);
      return NO;
    }
    
    if (cornerRadius == nil) {
      NSLog(@"ERROR: cornerRadius is not defined in the %@ section of %@.plist", stateName, self.resourceName);
      return NO;
    }
    
    if (borderColor == nil) {
      NSLog(@"ERROR: borderColor is not defined in the %@ section of %@.plist", stateName, self.resourceName);
      return NO;
    }
    
    if (borderWidth == nil) {
      NSLog(@"ERROR: borderWidth is not defined in the %@ section of %@.plist", stateName, self.resourceName);
      return NO;
    }
  }
  
  NSDictionary *shadow = (NSDictionary *)[buttonConfig objectForKey:@"shadow"];
  
  if (shadow != nil) {
    NSNumber *enable = (NSNumber *)[shadow objectForKey:@"enable"];
    NSArray *shadowOffset = (NSArray *)[shadow objectForKey:@"shadowOffset"];
    NSArray *anchorPoint = (NSArray *)[shadow objectForKey:@"anchorPoint"];
    NSNumber *shadowOpacity = (NSNumber *)[shadow objectForKey:@"shadowOpacity"];
    NSNumber *shadowColor = (NSNumber *)[shadow objectForKey:@"shadowColor"];
    NSNumber *shadowRadius = (NSNumber *)[shadow objectForKey:@"shadowRadius"];
    
    if (enable == nil) {
      NSLog(@"ERROR: enable is not defined in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    
    if (shadowOffset == nil) {
      NSLog(@"ERROR: shadowOffset is not defined in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    else if (shadowOffset.count < 2) {
      NSLog(@"ERROR: shadowOffset array size must be 2 in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    
    if (anchorPoint == nil) {
      NSLog(@"ERROR: anchorPoint is not defined in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    else if (anchorPoint.count < 2) {
      NSLog(@"ERROR: anchorPoint array size must be 2 in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    
    if (shadowOpacity == nil) {
      NSLog(@"ERROR: shadowOpacity is not defined in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    
    if (shadowColor == nil) {
      NSLog(@"ERROR: shadowColor is not defined in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
    
    if (shadowRadius == nil) {
      NSLog(@"ERROR: shadowRadius is not defined in the shadow section of %@.plist", self.resourceName);
      return NO;
    }
  }
  
  return result;
}


- (void)configureShadow:(NSDictionary *)buttonConfig {
  // Note that self.layer.masksToBounds should be set NO in order for the shadow to render.
  
  NSDictionary *shadow = (NSDictionary *)[buttonConfig objectForKey:@"shadow"];
  
  if (shadow != nil) {
    NSNumber *enable = (NSNumber *)[shadow objectForKey:@"enable"];
    
    if ([enable boolValue]) {
      NSArray *shadowOffset = (NSArray *)[shadow objectForKey:@"shadowOffset"];
      NSArray *anchorPoint = (NSArray *)[shadow objectForKey:@"anchorPoint"];
      NSNumber *shadowOpacity = (NSNumber *)[shadow objectForKey:@"shadowOpacity"];
      NSNumber *shadowColor = (NSNumber *)[shadow objectForKey:@"shadowColor"];
      NSNumber *shadowRadius = (NSNumber *)[shadow objectForKey:@"shadowRadius"];
      
      
      float x, y;
      int c = [shadowColor integerValue];
      
      x = [(NSNumber *)[shadowOffset objectAtIndex:0] floatValue];
      y = [(NSNumber *)[shadowOffset objectAtIndex:1] floatValue];
      self.layer.shadowOffset = CGSizeMake(x, y);
      
      x = [(NSNumber *)[anchorPoint objectAtIndex:0] floatValue];
      y = [(NSNumber *)[anchorPoint objectAtIndex:1] floatValue];
      self.layer.anchorPoint = CGPointMake(x, y);
      
      self.layer.shadowOpacity = [shadowOpacity floatValue];
      self.layer.shadowRadius = [shadowRadius floatValue];
      self.layer.shadowColor = [ARGBCSS(c) CGColor];
    }
  }
  
}



@end
