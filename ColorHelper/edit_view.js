// Calculations and conversions

function componentDecimalToHex(component) {
	var value = component == '' ? 'N/D' : parseInt(component).toString(16);
	if (value.length < 2) value = '0' + value;
	return value.toUpperCase();
}

function componentAlphaFloatToHex(component) {
	var value = component == '' ? 'N/D' : Math.round((parseFloat(component) * 255)).toString(16);
	if (value.length < 2) value = '0' + value;
	return value.toUpperCase();
}

function componentAlphaHexToFloatDecimal(component) {
	return parseInt('0x' + component) / 255.0;
}

function componentHexToDecimal(component) {
	return parseInt('0x' + component);
}

// Converts an object with red, green, blue attributes to 
// the hexadecimal color representation RGB.
function rgbDecimalComponentsToHex(components) {
	var hex = "";
	$(['red', 'green', 'blue']).each(function(index) {
		hex += componentDecimalToHex(components[this]);
	})
	return hex;
}

function rgbHexToDecimalComponents(hex) {
	var components = {};
	$(['red', 'green', 'blue']).each(function(index) {
		components[this] = componentHexToDecimal(hex.substring(index*2, index*2 + 2));
	})
	return components;
}

function rgbaDecimalComponentsToArgbIntegerDecimal(components) {
	return parseInt('0x' + componentAlphaFloatToHex(components.alpha) + rgbDecimalComponentsToHex(components));
}

function rgbaDecimalComponentsToCssRgbaRepresentation(components) {
	return "rgba(" + [components.red, components.green, components.blue, components.alpha].join(',') + ")";
}

// Manipulate fields

function getRgbaComponentsDecimal() {
	var components = {
		red: 		$('form .rgba.decimal .red')[0].value,
		green:	$('form .rgba.decimal .green')[0].value,
		blue:		$('form .rgba.decimal .blue')[0].value,
		alpha:	$('form .rgba.decimal .alpha')[0].value
	}
	return components;
}

function setRgbaComponentsDecimalInputFromRgbaDecimalComponents(components) {
	$.each(components, function(name, value) {
		$('form .rgba.decimal .' + name)[0].value = value;
	})
}

function setRgbaHexaInputFromRgbaDecimalComponents(components) {
	$('form .rgba.hexa .rgb')[0].value = rgbDecimalComponentsToHex(components);
	$('form .rgba.hexa .alpha')[0].value = $('form .rgba.decimal .alpha')[0].value;
}

function setArgbDecimalIntegerInputFromRgbaDecimalComponents(components) {
	$('form .argb.decimal.integer .argb')[0].value = rgbaDecimalComponentsToIntegerDecimal(components);
}

function setArgbIntegerDecimalInputFromRgbaDecimalComponents(components) {
	$('form .argb.decimal.integer .argb')[0].value = rgbaDecimalComponentsToArgbIntegerDecimal(components);
}

function setRgbaHexaInputFromArgbDecimalInteger(integer) {
	var hex = parseInt(integer).toString(16);
	$('form .rgba.hexa .alpha')[0].value = componentAlphaHexToFloatDecimal(hex.substring(0, 2));
	$('form .rgba.hexa .rgb')[0].value = hex.substring(2, 8);
}

function updateFromRgbaComponentsDecimal(event) {
	var rgbaComponentsDecimal = getRgbaComponentsDecimal();
	setRgbaHexaInputFromRgbaDecimalComponents(rgbaComponentsDecimal);
	setArgbIntegerDecimalInputFromRgbaDecimalComponents(rgbaComponentsDecimal);
	updatePreview();
}

function updateFromRgbaHexa(event) {
	var components = rgbHexToDecimalComponents($('form .rgba.hexa .rgb')[0].value);
	components['alpha'] = $('form .rgba.hexa .alpha')[0].value;
	setRgbaComponentsDecimalInputFromRgbaDecimalComponents(components);
	updateFromRgbaComponentsDecimal(event);
}

function updateFromArgbDecimalInteger(event) {
	setRgbaHexaInputFromArgbDecimalInteger($('form .argb.decimal.integer .argb')[0].value);
	updateFromRgbaHexa(event);
}

function updatePreview() {
	$('#color-preview').css('background-color', rgbaDecimalComponentsToCssRgbaRepresentation(getRgbaComponentsDecimal()));
}

$(function() {
	
	$(['red', 'green', 'blue', 'alpha']).each(function(index) {
		$('form .rgba.decimal .' + this).change(updateFromRgbaComponentsDecimal).keyup(updateFromRgbaComponentsDecimal);
	});
	$(['rgb', 'alpha']).each(function(index) {
		$('form .rgba.hexa .' + this).change(updateFromRgbaHexa);
	});
	$('form .argb.decimal.integer .argb').change(updateFromArgbDecimalInteger);
	
	updatePreview();
});