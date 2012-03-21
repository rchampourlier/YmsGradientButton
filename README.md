# YmsGradientButton

Forked from <https://github.com/kickingvegas/YmsGradientButton>

## License

### Original license

Copyright 2012 Yummy Melon Software LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.

You may obtain a copy of the License at <http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

See the License for the specific language governing permissions and limitations under the License.

Author: Charles Y. Choi <charles.choi@yummymelon.com>

### Addendum

Original license applies.

Author of the fork: Romain Champourlier <romain@softr.li>

## Description

iOS UIButton subclass featuring plist configured bitmap-free gradients.

## Quickstart

* Copy YmsGradientButton.[hm], YmsStyleSheet.h and YmsGradientButton.plist to 
  your project.
* Add the QuartzCore.framework to your project.
* Instantiate a UIButton in Interface Builder. With the identity inspector, 
  set the custom class to YmsGradientButton.
* Configure the gradients of the button for the different UIControlStates 
  normal, highlighted, and disabled in the file YmsGradientButton.plist.
  The settings map to the properties defined in CAGradientLayer.
* You can subclass YmsGradientButton and create a plist with the subclass
  name to create your own custom button.
* YmsGradientButton can also be instantiated programmatically.

## Documentation

### Configuration

A `YmsGradientButton` instance is configured through the use of a [plist file](https://github.com/kickingvegas/YmsGradientButton/blob/master/YmsGradientButtonDemo/YmsGradientButton.plist). This file name of the plist is typically (though not necessarily) uses the classname of the `YmsGradientButton` instance which references it. The default plist is called `YmsGradientButton.plist`. 

In the demo, there is a subclass of `YmsGradientButton` called `YourButton` which has a corresponding plist configuration file named `YourButton.plist`.

### Specification
The contents of the configuration plist are as follows:

* **normal** Dictionary<br/>Configuration for `UIControlStateNormal`.
  - **borderWidth** Number *float*<br/>Sets the border width of the button.
  - **cornerRadius** Number *float*<br/>Sets the corner radius of the button.
  - **borderColor** Number *integer*<br/>Sets the border color of the button. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **textColor** Number *integer*<br/>Sets the text color of the button. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **colors** Array *integer*<br/>Array defining the color of each gradient stop. Each element is an integer representing a 32-bit color value (0xAARRGGBB).
  - **locations** Array *float*<br/>Array defining the location of each gradient stop. The gradient stops are specified as values between 0 and 1. The values must be monotonically increasing. If nil, the stops are spread uniformly across the range.
  - **startPoint** Array *float*<br/>The start point of the gradient when drawn in coordinate space of the button. There can only be two elements specified whose values can only range between 0.0 and 1.0. Element 0 is the X normalization factor and should by default be set to 0.5. Element 1 is the Y normalization factor and should be default be set to 0.0.
  - **endPoint** Array *float*<br/>The end point of the gradient when drawn in coordinate space of the button. There can only be two elements specified whose values can only range between 0.0 and 1.0. Element 0 is the X normalization factor and should by default be set to 0.5. Element 1 is the Y normalization factor and should be default be set to 1.0.

* **highlighted** Dictionary<br/>Configuration for `UIControlStateHighlighted`.
  - **borderWidth** Number *float*<br/>Sets the border width of the button.
  - **cornerRadius** Number *float*<br/>Sets the corner radius of the button.
  - **borderColor** Number *integer*<br/>Sets the border color of the button. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **textColor** Number *integer*<br/>Sets the text color of the button. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **colors** Array *integer*<br/>Array defining the color of each gradient stop. Each element is an integer representing a 32-bit color value (0xAARRGGBB).
  - **locations** Array *float*<br/>Array defining the location of each gradient stop. The gradient stops are specified as values between 0 and 1. The values must be monotonically increasing. If nil, the stops are spread uniformly across the range.
  - **startPoint** Array *float*<br/>The start point of the gradient when drawn in coordinate space of the button. There can only be two elements specified whose values can only range between 0.0 and 1.0. Element 0 is the X normalization factor and should by default be set to 0.5. Element 1 is the Y normalization factor and should be default be set to 0.0.
  - **endPoint** Array *float*<br/>The end point of the gradient when drawn in coordinate space of the button. There can only be two elements specified whose values can only range between 0.0 and 1.0. Element 0 is the X normalization factor and should by default be set to 0.5. Element 1 is the Y normalization factor and should be default be set to 1.0.

* **disabled** Dictionary<br/>Configuration for `UIControlStateDisabled`.
  - **borderWidth** Number *float*<br/>Sets the border width of the button.
  - **cornerRadius** Number *float*<br/>Sets the corner radius of the button.
  - **borderColor** Number *integer*<br/>Sets the border color of the button. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **textColor** Number *integer*<br/>Sets the text color of the button. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **colors** Array *integer*<br/>Array defining the color of each gradient stop. Each element is an integer representing a 32-bit color value (0xAARRGGBB).
  - **locations** Array *float*<br/>Array defining the location of each gradient stop. The gradient stops are specified as values between 0 and 1. The values must be monotonically increasing. If nil, the stops are spread uniformly across the range.
  - **startPoint** Array *float*<br/>The start point of the gradient when drawn in coordinate space of the button. There can only be two elements specified whose values can only range between 0.0 and 1.0. Element 0 is the X normalization factor and should by default be set to 0.5. Element 1 is the Y normalization factor and should be default be set to 0.0.
  - **endPoint** Array *float*<br/>The end point of the gradient when drawn in coordinate space of the button. There can only be two elements specified whose values can only range between 0.0 and 1.0. Element 0 is the X normalization factor and should by default be set to 0.5. Element 1 is the Y normalization factor and should be default be set to 1.0.


* **shadow** Dictionary
  - **enable** Boolean<br/>If set to YES then a shadow effect for the button is rendered.
  - **shadowOffset** Array *float*Array of two float elements mapping to a point to offset the shadow. Element 0 is X, Element 1 is Y.
  - **shadowOpacity** Number *float*<br/>Level of opacity for the shadow.
  - **shadowColor** Number *integer*<br/>Color of shadow. The color is specified using a 32-bit integer (0xAARRGGBB).
  - **shadowRadius** Number *float*<br/>Radius size of shadow.
  - **anchorPoint** Array *float*Array of two float elements mapping to a point to anchor the shadow. Element 0 is X, Element 1 is Y.
   

## Notes
* This code is written using ARC. 
* Please read [the project wiki](https://github.com/kickingvegas/YmsGradientButton/wiki/Configuration) on GitHub for more information.