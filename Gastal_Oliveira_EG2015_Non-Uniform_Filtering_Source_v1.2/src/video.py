#
#  The core equations of our method are implemented in the file
#  'our_method.jl'.  Please see the README.txt file for instructions.
#

#  This code is part of the reference implementation of the paper
#
#    "High-Order Recursive Filtering of Non-uniformly Sampled Signals
#     for Image and Video Processing"
#    Eduardo S. L. Gastal  and  Manuel M. Oliveira
#    Computer Graphics Forum. Volume 34 (2015), Number 2.
#    Proceedings of Eurographics 2015, pp. 81-93.
# 
#  Please refer to the publication above if you use this software. For an
#  up-to-date version go to:
#  
#            http://inf.ufrgs.br/~eslgastal/NonUniformFiltering/
#
#
#  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY EXPRESSED OR IMPLIED WARRANTIES
#  OF ANY KIND, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THIS SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THIS SOFTWARE.
#
#  Version 1.0 - May 2015.

import cv
import cv2

class InOutVideo:
    def __init__(self, filename):
        self.cap = cv2.VideoCapture(filename)
        self.num_frames = self.cap.get( cv.CV_CAP_PROP_FRAME_COUNT )
        self.fps = self.cap.get( cv.CV_CAP_PROP_FPS )
        self.h   = int(self.cap.get( cv.CV_CAP_PROP_FRAME_HEIGHT ))
        self.w   = int(self.cap.get( cv.CV_CAP_PROP_FRAME_WIDTH ))
        MJPG = cv.CV_FOURCC( *'MJPG' )

    def isOpened(self):
        return self.cap.isOpened()

    def read(self):
        ret, frame = self.cap.read()
        return frame

    def release(self):
        self.cap.release()
