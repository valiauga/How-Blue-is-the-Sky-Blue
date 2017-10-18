class CCielab {
  float L;
  float a;
  float b;
 
  CCielab(color rgb) {
 
    // RGB -> XYZ
    float var_R = (red(rgb)   / 255 );
    float var_G = (green(rgb) / 255 );
    float var_B = (blue(rgb)  / 255 );
 
    if ( var_R > 0.04045 ) var_R = pow(( var_R + 0.055 ) / 1.055, 2.4);
    else                   var_R = var_R / 12.92;
    if ( var_G > 0.04045 ) var_G = pow(( var_G + 0.055 ) / 1.055, 2.4);
    else                   var_G = var_G / 12.92;
    if ( var_B > 0.04045 ) var_B = pow(( var_B + 0.055 ) / 1.055, 2.4);
    else                   var_B = var_B / 12.92;
 
    var_R = var_R * 100;
    var_G = var_G * 100;
    var_B = var_B * 100;
 
    float X = var_R * 0.4124 + var_G * 0.3576 + var_B * 0.1805; 
    float Y = var_R * 0.2126 + var_G * 0.7152 + var_B * 0.0722;
    float Z = var_R * 0.0193 + var_G * 0.1192 + var_B * 0.9505;
 
    // XYZ -> CIE-L*ab
 
    float var_X = X / 95.047; 
    float var_Y = Y / 100.000;
    float var_Z = Z / 108.883;
 
    if ( var_X > 0.008856 ) var_X = pow(var_X, 1./3);
    else                    var_X = ( 7.787 * var_X ) + ( 16. / 116. );
    if ( var_Y > 0.008856 ) var_Y = pow(var_Y, 1./3);
    else                    var_Y = ( 7.787 * var_Y ) + ( 16. / 116. );
    if ( var_Z > 0.008856 ) var_Z = pow(var_Z, 1./3);
    else                    var_Z = ( 7.787 * var_Z ) + ( 16. / 116. );
 
    L = ( 116. * var_Y ) - 16;
    a = 500. * ( var_X - var_Y );
    b = 200. * ( var_Y - var_Z );
  }
 
  float deltaE(CCielab col) { 
    float whtl = 1.;  // Weighting factors depending 
    float whtc = 1.;  // on the application (1 = default)
    float whth = 1.;
 
    float xC1 = sqrt( (a*a) + (b*b) );
    float xC2 = sqrt( (col.a*col.a) + (col.b*col.b) );
    float xDL = col.L - L;
    float xDC = xC2 - xC1;
    float xDE = sqrt(((L-col.L)*(L-col.L))
                       +((a-col.a)*(a-col.a))+((b-col.b)*(b-col.b)));
    float xDH = 0;
 
    if (sqrt(xDE)>(sqrt(abs(xDL))+sqrt(abs(xDC)))) {
      xDH = sqrt((xDE*xDE)-(xDL*xDL)-(xDC*xDC));
    }
 
    float xSC = 1 + ( 0.045 * xC1 );
    float xSH = 1 + ( 0.015 * xC1 );
 
    xDL /= whtl;
    xDC /= whtc * xSC;
    xDH /= whth * xSH;
    float Delta_E94 = sqrt(pow(xDL,2) + pow(xDC,2) + pow(xDH,2));
 
    return(Delta_E94);
  }
}