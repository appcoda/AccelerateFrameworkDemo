/*:
 # Introduction to the Accelerate Framework
 */
import Cocoa
import Accelerate
import simd
/*:
## BLAS (Basic Linear Algebra Subroutines)
 
 ### Example 1: Ax + y
 - Note: **s** = float function, **axpy** = abbreviation for "a times x plus y"\
 Here we will find **10 * x + y** for a 3 element array.
 */
var x:[Float] = [ 1, 2, 3 ]
var y:[Float] = [ 3, 4, 5 ]

// 10 * x + y
cblas_saxpy(3, 10, &x, 1, &y, 1)

y
//:### Example 2: Dot Product of vectors ∑ a[i] * b[i]
//: - Note: Since the original value of **y** was overwritten by **cblas_saxpy** above, we reset it here. It's important when using values in multiple places to check and see if they were mutated by preceding functions.
y = [ 3, 4, 5 ]

// x • y == (1 * 3) + (2 * 4) + (3 * 5)
cblas_sdot( 3, &x, 1, &y, 1 )
/*:
## LAPACK (Linear Algebra Package)
 
 ### Example : Solving Simultaneous Equations
 - Note: Equations:
	
    7x+5y-3z = 16\
    3x-5y+2z	= -8\
    5x+3y-7z	= 0\
    Question: What are the values of x, y, and z?
 
 */

typealias LAInt = __CLPK_integer // = Int32
var A:[Float] = [
    7, 3, 5,
    5, -5, 3,
    -3, 2, -7
]

var b:[Float] = [ 16, -8, 0 ]

let equations = 3

var numberOfEquations:LAInt = 3
var columnsInA:       LAInt = 3
var elementsInB:      LAInt = 3
var bSolutionCount:   LAInt = 1

var outputOk: LAInt = 0
var pivot = [LAInt](repeating: 0, count: equations)

sgesv_( &numberOfEquations, &bSolutionCount, &A, &columnsInA, &pivot, &b, &elementsInB, &outputOk)

// If outputOK = 0, then everything went ok
outputOk

// Answer
b
/*:
 ## simd (Single Instruction, Multiple Data)
 
 ### Example:
 - Note: Remember in the first example when you had to solve 10 * x + y? With simd, there's a much easier way to do it. To avoid overlaps of the same variables, let's change x & y to p & q.
 */
let p = double3(1, 2, 3)
let q = double3(3, 4, 5)

10 * p + q
/*:
 - Note: simd is especially useful in vector math and calculations involving matricies. However, since that is outside the scope of this tutorial, it won't be covered.
 */
/*:
 ## vecLib (Vector Library)
 */
func floats(_ n: Int32)->[Float] {
    return [Float](repeating:0, count:Int(n))
}
/*:
 ### Example 1: Absolute values
 - Note: "count" needs to be Int32, not just Int
 */
var count: Int32 = 4
var aAbsolute = floats(count)
var a:[Float] = [-3, -2, -5, -10]

vvfabsf(&aAbsolute, &a, &count )
aAbsolute
/*:
 ### Example 2: Integers from Floats
*/
count = 3
var f:[Float] = [3.3796, 1.8036, -2.1205]
var bInt = floats(count)

vvintf(&bInt, &f, &count)
bInt
//:### Example 3: Square Roots
count = 4
var c:[Float] = [16,9,4,1]
var cSquareRoots = floats(count)

vvsqrtf(&cSquareRoots, &c, &count)
cSquareRoots
//:### Example 4: Taking Inverses
count = 4
var d:[Float] = [1/3, 2/5, 1/8, -3/1]
var dFlipped = floats(count)

vvrecf( &dFlipped, &d, &count )

dFlipped
/*:
 ## vDSP (C and Swift APIs for performing common routines on a single vector)
 
 ### Example: Distances Along A 2D Path
 - Note: Let's say you have a set of points describing a path. How far are we from the origin at each step? It's very easy to solve this with vDSP because we have several distance functions in the vDSP library! A few lines of set-up code and then a one-liner, and we get each leg's distance as an array.
 */
var points:[CGPoint] = [
    CGPoint(x: 0, y: 0),
    CGPoint(x: 0, y: 10),
    CGPoint(x: 0, y: 20),
    CGPoint(x: 0, y: 30),
    CGPoint(x: 0, y: 40),
    CGPoint(x: 0, y: 50),
    CGPoint(x: 0, y: 60),
    CGPoint(x: 0, y: 70),
    CGPoint(x: 0, y: 80)
]

let path = NSBezierPath()
path.move(to: points[0])
for i in 1..<points.count {
    path.line(to: points[i])
}

var xs = points.flatMap { Float($0.x) }
var ys = points.flatMap { Float($0.y) }
var distance = [Float](repeating: 0, count: points.count)

vDSP_vdist(&xs, 1, &ys, 1, &distance, 1, vDSP_Length(points.count))
distance.map { $0 }

// Total distance
distance.reduce(0, +)