(ql:quickload :s-xml)
(ql:quickload :cl-ppcre)

(defpackage :rssgen
  (:use :cl :cl-user :s-xml)
  (:export output-rss
           build-readme))
(in-package :rssgen)

(defparameter *timezone* +8)

(defun build-date (y m d hh mm ss)
  (let ((date-input-str
         (format nil
                 "~A-~A-~A ~A:~A:~A ~A"
                 y m d hh mm ss
                 (if (>= *timezone* 0)
                     (format nil "+~A" *timezone*)
                     (format nil "~A" *timezone*))))
        (rfc-2822 nil))
    (setf rfc-2822
          (with-output-to-string (out)
           (if (= 0
                   (sb-ext:process-exit-code
                    (sb-ext:run-program
                     "/bin/date"
                     `("-R"
                       "-u"
                       "-d" ,date-input-str)
                     :output out)))
                nil (error "build-date: Invalide date!"))))
    (let (new-line-point)
      (dotimes (i (length rfc-2822))
        (if (equal #\Newline
                   (char rfc-2822 i))
            (progn (setf new-line-point i)
                   (return))))
      (setf rfc-2822 (subseq rfc-2822 0 new-line-point)))
    rfc-2822))

(defun build-date-lisp (lisp-date)
  (multiple-value-bind
	(second minute hour date month year)
      (decode-universal-time lisp-date)
    (build-date year month date hour minute second)))

(defun build-date-now ()
  (build-date-lisp (get-universal-time)))
;;;;(build-date-now)

(defun build-date-file (path)
  (build-date-lisp (file-write-date path)))
;;;;(build-date-file "README.md")

(defstruct file+cldate
  file
  cldate)

(defun list-articles ()
  (let* ((all-files (directory "./*.md"))
         (file+cldate-lst (mapcar (lambda (x)
                                    (make-file+cldate
                                     :file x
                                     :cldate (file-write-date x)))
                                  all-files)))
    (remove-if (lambda (x)
                 (string= "README.md"
                          (file-namestring
                           (file+cldate-file x))))
               (sort file+cldate-lst #'> :key #'file+cldate-cldate))))
;;;; (list-articles)


(defparameter *home*
  "https://github.com/leosongwei/blog/blob/master/")

(defun build-link (filepath)
  (concatenate 'string
               *home*
               (file-namestring filepath)))

(defun extract-title (file+cldate)
  (let ((file (file+cldate-file file+cldate)))
    (with-open-file (in file)
      (read-line in))))
;;;; (extract-title (car (list-articles)))

(defun convert-html-entity (x output-stream)
  (princ
   (case x
     ;; (#\& "&amp;")
     ;; (#\" "&quot;")
     ;; (#\< "&lt;")
     ;; (#\> "&gt;")
     (#\Tab "&nbsp;&nbsp;&nbsp;&nbsp;")
     (#\Space "&nbsp;")
     (#\Newline "<br/>")
     (otherwise x))
   output-stream))
;;;; (convert-html-entity #\Newline *standard-output*)
;;;; (convert-html-entity #\a *standard-output*)

(defun make-output-string ()
  (make-array '(0) :element-type 'character
              :fill-pointer 0 :adjustable t))

(defun extract-body (file+cldate)
  (let ((file (file+cldate-file file+cldate))
        (body (make-output-string)))
    (with-output-to-string (s body)
      (with-open-file (in file)
        (read-line in)
        (read-line in)
        (do ((line (read-line in nil)
                   (read-line in nil)))
            ((null line))
          (format s "<p>~A</p>" line))))
    (let ((output (make-output-string))
          (len    (length body)))
      (with-output-to-string (s output)
        (dotimes (i len)
          (convert-html-entity (char body i) s))
      output))))
;;;;(extract-body (car (list-articles)))

(defun item-sexp (file+cldate)
  (let ((title (extract-title file+cldate))
        (body (extract-body file+cldate))
        (link (concatenate 'string
                           *home*
                           (file-namestring
                            (file+cldate-file file+cldate))))
        (pubdate (build-date-lisp (file+cldate-cldate
                                   file+cldate))))
    `(:|item|
       (:|title| ,title)
       (:|link| ,link)
       (:|description| ,body)
       (:|pubDate| ,pubdate)
       (:|guid| ,link))))
;;;; (item-sexp (car (list-articles)))

(defun rss-sexp ()
  (let ((title "凉拌茶叶的博客")
        (link "https://github.com/leosongwei/blog")
        (description "就是一个博客……")
        (rss-file (concatenate 'string *home* "rss.xml")))
    `(:|rss| (:@ (:|version| "2.0")
                 (:|xmlns:atom| "http://www.w3.org/2005/Atom"))
       (:|channel|
         (:|title| ,title)
         (:|link| ,link)
         (:|description| ,description)
         (:|lastBuildDate| ,(build-date-now))
         (:|language| "zh-cn")
         (:|docs| ,rss-file)
         ,@(mapcar #'item-sexp (list-articles))))))

(defun output-rss ()
  (with-open-file
      (out #p"./rss.xml"
           :direction :output
           :external-format :utf-8
           :if-exists :supersede)
    (let ((string1 (make-output-string)))
      (with-output-to-string (s string1)
        (format s
                "<?xml version=\"1.0\" encoding=\"utf-8\" standalone=\"yes\" ?>~%")
        (print-xml (rss-sexp) :stream s
                   :input-type :sxml)
        (let ((len (length string1)))
          (dotimes (i len)
            (princ (funcall (lambda (x)
                              (if (equal x #\>)
                                  (format nil ">~%")
                                  x))
                            (char string1 i))
                   out)))))))

(defun build-readme ()
  (with-open-file (in #p"./README.md.human")
    (with-open-file (out #p"README.md"
                         :direction :output
                         :if-exists :supersede)
      (do ((line (read-line in nil)
                 (read-line in nil)))
          ((null line))
        (format out "~A~%" line))
      (format out "~%文章列表~%")
      (format out "--------~%~%")
      (format out "（按修改时间排列）~%~%")
      (let ((articles (list-articles)))
        (mapcar (lambda (a)
                  (let ((title (extract-title a))
                        (mdlink (concatenate 'string
                                             "./"
                                             (file-namestring
                                              (file+cldate-file a)))))
                    (format out
                            "* [~A](~A)~%"
                            title mdlink)))
                articles)))))

(in-package :cl-user)

(rssgen:build-readme)
(rssgen:output-rss)
(format t "Done")
(sb-ext:exit)
