# os-release

写了一段非常Naive的Common Lisp代码来读取`/etc/os-release`文件：

```lisp

#|
OS-RELEASE

author: Song Wei (leo_songwei@outlook.com)

Read the /etc/os-release file naively.

Check page: https://www.freedesktop.org/software/systemd/man/os-release.html

License: this program is released in public domain, use at your own risks.
|#

(defpackage :os-release
  (:use :cl :cl-user)
  (:export read-os-release))

(in-package :os-release)

(defmacro while (test &rest body)
  `(do ()
     ((not ,test))
     ,@body))

(defun make-dynamic-string ()
  (make-array 0 :adjustable t
              :fill-pointer 0
              :element-type 'character))

;; (let ((s (make-dynamic-string)))
;;   (vector-push-extend #\a s)
;;   (vector-push-extend #\b s)
;;   s)

(defun readline (file-stream)
  (multiple-value-bind (line file-end-p)
      (read-line file-stream nil nil)
    (if (= 0 (length line))
        (values nil file-end-p)
        (let ((field (make-dynamic-string))
              (value (make-dynamic-string))
              (reading-value-flag nil)
              (with-quote-p nil))
          (block :reading-loop
            (dotimes (i (length line))
              (let ((c (aref line i)))
                (cond ((char= c #\=)
                       (setf reading-value-flag t))
                      ((and reading-value-flag (not with-quote-p) (char= c #\"))
                       (setf with-quote-p t))
                      ((and reading-value-flag with-quote-p (char= c #\"))
                       (return-from :reading-loop))
                      (t
                       (vector-push-extend
                        c (if (not reading-value-flag) field value)))))))
          (values (list (intern field "KEYWORD") value) file-end-p)))))


(defun read-os-release ()
  (with-open-file (file-stream #p"/etc/os-release" :direction :input)
    (let ((content nil)
          (not-end t))
      (while not-end
        (multiple-value-bind (field ended) (readline file-stream)
            (if ended
                (setf not-end nil))
          (if field
              (setf content (concatenate 'list content field)))))
      content)))

;; (getf (read-os-release) :name) => "Arch Linux"


```
