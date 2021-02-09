/**
 * Values obtained from wolframalpha.
 * Wolfram Alpha LLC. 2009. Wolfram|Alpha. https://www.wolframalpha.com/input/?i=e+in+base+16 (access Feb 8, 2021).
 * Each value was simplified to the notation of 1.XXXx2<sup>n</sup> in hex.
 */
module taurus.math.constants;

enum real E =      0x1.5bf0a8b1457695355fb8ac404e7a79e4p+1L; /** e = 2.718281... */
enum real LOG2T =  0x1.a934f0979a3715fc9257edfe9b5fb69ap+1L; /** log<sub>2</sub>(10) = 3.321928... */
enum real LOG2E =  0x1.71547652b82fe1777d0ffda0d23a7d12p+0L; /** log<sub>2</sub>(e) = 1.442695... */
enum real LOG2 =   0x1.34413509f79fef311f12b35816f922f0p-2L; /** log<sub>10</sub>(2) = 0.301029... */
enum real LOGE =   0x1.bcb7b1526e50e32a6ab7555f5a67b864p-2L; /** log<sub>10</sub>(e) = 0.434294... */
enum real LN2 =    0x1.62e42fefa39ef35793c7673007e5ed5fp-1L; /** ln(2) = 0.693147... */
enum real LN10 =   0x1.26bb1bbb5551582dd4adac5705a61452p+1L; /** ln(10) = 2.302585... */
enum real PI =     0x1.921fb54442d18469898cc51701b839a3p+1L; /** &pi; = 3.141592... */
enum real SQRT2 =  0x1.6a09e667f3bcc908b2fb1366ea957d3ep+0L; /** &radic;2 = 1.414213... */
enum real SQRT3 =  0x1.bb67ae8584caa73b25742d7078b83b89p+0L; /** &radic;3 = 1.732050... */
enum real SQRT5 =  0x1.1e3779b97f4a7c15f39cc0605cedc834p+1L; /** &radic;5 = 2.236067... */
enum real SQRTPI = 0x1.c5bf891b4ef6aa79c3b0520d5db93840p+0L; /** &radic;&pi; = 1.772453... */
enum real CBRT2 =  0x1.428a2f98d728ae223ddab715be250d0cp+0L; /** <sup>3</sup>&radic;2 = 1.259921... */
enum real CBRT3 =  0x1.7137449123ef65cdde7f16c56e3267c1p+0L; /** <sup>3</sup>&radic;3 = 1.442249... */

enum real PI_2 =       PI/2L;     /** &pi;/2 = 1.570796... */
enum real PI_4 =       PI/4L;     /** &pi;/4 = 0.785398... */
enum real SQRT1_2 =    SQRT2/2L;  /** &radic;&frac12; = 0.707106... */
enum real M_1_PI =     1L/PI;     /** 1/&pi; = 0.318309... */
enum real M_2_PI =     2L/PI;     /** 2/&pi; = 0.636619... */
enum real M_1_SQRTPI = 1L/SQRTPI; /** 1/&radic;&pi; = 0.564189... */
enum real M_2_SQRTPI = 2L/SQRTPI; /** 2/&radic;&pi; = 1.128379... */
