//
// Named Color Constants
//
sym black    = rgb(  0,   0,   0);
sym blue     = rgb(  0,   0, 255);
sym darkGrey = rgb(169, 169, 169);
sym green    = rgb(  0, 128,   0);
sym orange   = rgb(255, 165,   0);
sym red      = rgb(255,   0,   0);
sym white    = rgb(255, 255, 255);
sym yellow   = rgb(255, 255,   0);

//
// Color Functions
//

//
// Create an 'rgba' object using the specified values. The red, green, and blue
// values are expected to be integers in the closed interval [0,255]. The alpha
// channel is set to 1.0.
//
func rgb(red, green, blue) {
  {
    type: 'rgba',
    red: red,
    green: green,
    blue: blue,
    alpha: 1.0
  };
}

//
// Create an 'rgba' object using the specified values. The red, green, and blue
// values are expected to be integers in the closed interval [0,255]. The alpha
// value is expected to be a double in the closed interval [0,1].
func rgba(red, green, blue, alpha) {
  {
    type: 'rgba',
    red: red,
    green: green,
    blue: blue,
    alpha: alpha
  };
}

//
// Create an 'hsla' object using the specified values. The hue value is expected to
// be an angle in degrees. Saturation, and lightness values are expected to be
// doubles in the closed interval [0,1]. The alpha channel is set to 1.0.
//
func hsl(hue, saturation, lightness) {
  {
    type: 'hsla',
    hue: hue,
    saturation: saturation,
    lightness: lightness,
    alpha: 1.0
  };
}

//
// Create an 'hsla' object using the specified values. The hue value is expected to
// be an angle in degrees. Saturation, lightness, and alpha values are expected to
// be doubles in the closed interval [0,1]
//
func hsla(hue, saturation, lightness, alpha) {
  {
    type: 'hsla',
    hue: hue,
    saturation: saturation,
    lightness: lightness,
    alpha: alpha
  };
}

//
// Create an 'hsba' object using the specified values. The hue value is expected to
// be an angle in degrees. Saturation, and brightness values are expected to be
// doubles in the closed interval [0,1]. The alpha channel is set to 1.0.
//
func hsb(hue, saturation, brightness) {
  {
    type: 'hsba',
    hue: hue,
    saturation: saturation,
    brightness: brightness,
    alpha: 1.0
  };
}

//
// Create an 'hsba' object using the specified values. The hue value is expected to
// be an angle in degrees. Saturation, brightness, and alpha values are expected to
// be doubles in the closed interval [0,1]
//
func hsba(hue, saturation, brightness, alpha) {
  {
    type: 'hsba',
    hue: hue,
    saturation: saturation,
    brightness: brightness,
    alpha: alpha
  };
}
