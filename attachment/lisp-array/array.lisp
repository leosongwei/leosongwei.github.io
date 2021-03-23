(require :cffi)
(require :cffi-grovel)

(defun full-gc ()
  (sb-ext:gc :full t))

(defmacro timing (timed-body)
  (let ((start (gensym))
        (end (gensym)))
    `(let ((,start (get-internal-real-time)))
       (progn ,timed-body)
       (let ((,end (get-internal-real-time)))
         (float (/ (- ,end ,start) internal-time-units-per-second))))))
;; (timing (sleep 2.3))

(defparameter +random-array+
  (let ((array (make-array (* 1000 1000) :element-type '(unsigned-byte 32))))
    (dotimes (i (* 1000 1000))
      (setf (aref array i) (random 256)))
    array))

;;;; Make Array

(defun test-make-array-1d ()
  (let (arrays)
    (dotimes (_ 1000)
      (push (make-array (* 1000 1000) :element-type '(unsigned-byte 32)) arrays))
    arrays))

(defun test-make-array-2d ()
  (let (arrays)
    (dotimes (_ 1000)
      (push (make-array '(1000 1000) :element-type '(unsigned-byte 32)) arrays))
    arrays))

(progn (full-gc)
       (print 'test-make-array-1d)
       (time (length (test-make-array-1d)))

       (full-gc)
       (print 'test-make-array-2d)
       (time (length (test-make-array-2d))))

;;;; Fill Array

(defun fill-arrays-1d (array)
  (declare (type (simple-array (unsigned-byte 32) (*)) array))
  (dotimes (j 1000)
    (dotimes (k 1000)
      (setf (aref array (+ (* 1000 j) k)) #xAAAA))))

;; (disassemble #'fill-arrays-1d)

(defun test-fill-arrays-1d ()
  (let ((arrays (test-make-array-1d)))
    (timing
     (dolist (a arrays)
       (fill-arrays-1d a)))))

(defun fill-arrays-2d (array)
  (declare (type (simple-array (unsigned-byte 32) (* *)) array))
  (dotimes (j 1000)
    (dotimes (k 1000)
      (setf (aref array j k) #xAAAA))))

(defun test-fill-arrays-2d ()
  (let ((arrays (test-make-array-2d)))
    (timing
     (dolist (a arrays)
       (fill-arrays-2d a)))))

(progn (full-gc)
       (print 'test-fill-arrays-1d)
       (print (test-fill-arrays-1d))

       (full-gc)
       (print 'test-fill-arrays-2d)
       (print (test-fill-arrays-2d)))

;;;; Copy Array

(defun copy-array-1d (source target)
  (declare (type (simple-array (unsigned-byte 32) (*)) source target))
  (dotimes (i 1000)
    (dotimes (j 1000)
      (let ((offset (+ j (* i 1000))))
        (setf (aref target offset) (aref source offset))))))

(defun test-copy-array-1d ()
  (let ((arrays (test-make-array-1d)))
    (time
     (dolist (array arrays)
       (copy-array-1d +random-array+ array)))))

(progn (full-gc)
       (print 'test-copy-array-1d)
       (test-copy-array-1d))

(defun copy-array-byte (source target)
  (declare (type (simple-array (unsigned-byte 8) (*)) source target))
  (dotimes (i (* 4 1000 1000))
    (setf (aref target i) (aref source i))))
;; (disassemble #'copy-array-byte)

(defun test-copy-array-byte ()
  (let ((arrays (loop repeat 1000 collect (make-array (* 4 1000 1000) :element-type '(unsigned-byte 8))))
        (source (let ((a (make-array (* 4 1000 1000) :element-type '(unsigned-byte 8))))
                  (dotimes (i (length a))
                    (setf (aref a i) (random 256)))
                  a)))
    (time
     (dolist (array arrays)
       (copy-array-byte source array)))))

(progn (full-gc)
       (print 'test-copy-array-byte)
       (test-copy-array-byte))

;;;; Displaced Array

;; fill-arrays-1d won't compile, type-error:
;; (VECTOR (UNSIGNED-BYTE 32) 810000) vs (SIMPLE-ARRAY (UNSIGNED-BYTE 32) (*))
(defun fill-arrays-1d-no-declaration (array)
  (dotimes (j 900)
    (dotimes (k 900)
      (setf (aref array (+ (* 900 j) k)) #xFFFF))))

;; although displaced array doesn't allow gap
(defun test-fill-displaced-array-1d ()
  (let ((arrays (test-make-array-1d)))
    (timing
     (dotimes (i 1000)
       (let* ((a (nth i arrays))
              (a-displaced (make-array (* 900 900) :element-type '(unsigned-byte 32)
                                       :displaced-to a
                                       :displaced-index-offset 100)))
         (fill-arrays-1d-no-declaration a-displaced))))))

(progn (full-gc)
       (print 'test-fill-displaced-array-1d)
       (time (test-fill-displaced-array-1d)))

;;;; -------------------------- CFFI --------------------------------------

;;;; Allocate Array

(defun test-make-array-c ()
  (let (arrays)
    (dotimes (_ 1000)
      (push (cffi:foreign-alloc :uint32 :count (* 1000 1000)) arrays))
    arrays))

(progn (full-gc)
       (dolist (array (time (test-make-array-c)))
         (cffi:foreign-free array)))

;;;; Fill Array

(load (cffi-grovel:process-grovel-file "array-grovel.lisp" "/tmp/_array-grovel.o"))

(cffi:defcfun ("memset" memset) :pointer
  (s :pointer) (c :int) (n size_t))

(defun fill-array-c (ptr)
  (memset ptr #xA (* 4 1000 1000)))

(defun test-fill-array-c ()
  (let ((arrays (test-make-array-c)))
    (time
     (dolist (a arrays)
       (fill-array-c a)))
    (dolist (a arrays)
      (cffi:foreign-free a))))

(progn (full-gc)
       (print 'test-fill-array-c)
       (test-fill-array-c))

;;;; copy array

(defparameter +random-array-c+
  (let ((array (cffi:foreign-alloc :uint32 :count (* 1000 1000))))
    (dotimes (i (* 1000 1000))
      (setf (cffi:mem-aref array :uint32 i) (random 256)))
    array))

(cffi:defcfun ("memcpy" memcpy) :pointer
  (dest :pointer) (src :pointer) (n size_t))

(defun test-copy-array-c ()
  (let ((arrays (test-make-array-c)))
    (time
     (dolist (array arrays)
       (memcpy array +random-array-c+ (* 1000 1000 4))))
    (dolist (array arrays)
      (cffi:foreign-free array))))

(progn (full-gc)
       (print 'test-copy-array-c)
       (test-copy-array-c))
