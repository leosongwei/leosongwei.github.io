(in-package :cl-user)
(ql:quickload :s-xml)
(ql:quickload :cl-ppcre)

(defpackage :rssgen
  (:use :cl :cl-user :s-xml :cl-ppcre)
  (:export output-rss
           build-readme))
(in-package :rssgen)

(defparameter *log-stream* *standard-output*)

(defun logging (place level msg)
  (format *log-stream*
          (concatenate
           'string
           (with-output-to-string (space)
             (dotimes (i level) (princ "    " space)))
           (format nil "~A: " place)
           msg (string #\Newline))))
;;;;(logging #'logging 1 "test")

(defparameter *timezone* +8)

(defmacro concstr (&rest strings)
  `(concatenate 'string ,@strings))

(defun println-strs (strings)
  (if (consp strings)
      (concatenate 'string (car strings)
                   (string #\Newline)
                   (println-strs (cdr strings)))
      nil))

(defun make-output-string ()
  (make-array '(0) :element-type 'character
              :fill-pointer 0 :adjustable t))

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

(defun build-date-format (format y m d hh mm ss)
  (let ((date-output (make-output-string))
        (input-str  (format nil
                            "~A-~A-~A ~A:~A:~A ~A"
                            y m d hh mm ss
                            (if (>= *timezone* 0)
                                (format nil "+~A" *timezone*)
                                (format nil "~A" *timezone*)))))
    (with-output-to-string (out date-output)
      (if (= 0
             (sb-ext:process-exit-code
              (sb-ext:run-program
               "/bin/date"
               `("-d" ,input-str
                      ,(concatenate 'string "+" format))
               :output out)))
          nil (error "build-date-now-format: `date' error")))
    (with-output-to-string (output)
      (with-input-from-string (in date-output)
        (princ (read-line in nil nil) output)))))
;;;; (build-date-format "%Y-%m-%d %H:%M" 2015 03 20 15 48 26)

(defun build-date-format-lisp (format lisp-date)
  (multiple-value-bind
	(second minute hour date month year)
      (decode-universal-time lisp-date)
    (build-date-format format year month date hour minute second)))
;;;; (build-date-format-lisp "%Y-%m-%d %H:%M" (get-universal-time))

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

(defun string-begin-with (match string)
  (let ((len (length match)))
    (and (>= (length string) len)
         (string= match
                  (subseq string 0 len)))))

(defun list-articles ()
  (let* ((all-files (directory "./*.md"))
         (file+cldate-lst (mapcar (lambda (x)
                                    (make-file+cldate
                                     :file x
                                     :cldate (file-write-date x)))
                                  all-files)))
    (remove-if (lambda (x)
                 (string-begin-with "README"
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

(defun extract-body (file+cldate)
  (let ((file (file+cldate-file file+cldate))
        (mkd (make-output-string))
        (xml (make-output-string)))
    (with-output-to-string (s mkd)
      (with-open-file (in file)
        (if (not (and (read-line in nil nil)
                      (read-line in nil nil)))
            (error (format nil "EXTRACT-BODY: file too short: ~A~%"
                           file)))
        (do ((line (read-line in nil)
                   (read-line in nil)))
            ((null line))
          (format s "~A~%" line))))
    (with-output-to-string (s xml)
      (with-input-from-string (in mkd)
        (if (= 0
               (sb-ext:process-exit-code
                (sb-ext:run-program
                 "/usr/bin/pandoc"
                 `("-f" "markdown"
                        "-t" "html")
                 :input in :output s)))
            nil (error (format nil "EXTRACT-BODY: pandoc error")))))
    (regex-replace-all "<img src=\"." xml "<img src=\"https://raw.githubusercontent.com/leosongwei/blog/master")))

;;;;(extract-body (car (list-articles)))

(defun item-sexp (file+cldate)
  (logging #'item-sexp 1 (format nil "Processing: ~A"
                                 (file+cldate-file file+cldate)))
  (handler-case
      (progn

        (let* ((title   (extract-title file+cldate))
               (body    (extract-body file+cldate))
               (link    (concatenate 'string
                                     *home*
                                     (file-namestring
                                      (file+cldate-file file+cldate))))
               (pubdate (build-date-lisp (file+cldate-cldate
                                          file+cldate)))
               (guid    (concatenate 'string link
                                     (format nil "~A" (file+cldate-cldate
                                                       file+cldate)))))
          `(:|item|
             (:|title| ,title)
             (:|link| ,link)
             (:|description| ,body)
             (:|pubDate| ,pubdate)
             (:|guid| ,guid))))
    (condition (e) (progn (logging #'item-sexp 2
                                   (format nil "~S, Abort!" e))
                          nil))))
;;;; (item-sexp (car (list-articles)))

(defun rss-sexp ()
  (let ((title "凉拌茶叶的博客")
        (link "https://github.com/leosongwei/blog/blob/master/README.md")
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
         ,@(remove-if (lambda (x) (eq x nil))
                      (mapcar #'item-sexp (list-articles)))))))

(defun output-rss ()
  (logging #'output-rss 0 "Output RSS.....")
  (handler-case
      (progn
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
    (condition (e) (logging #'output-rss 0 (format nil "~S" e)))))

(defun build-readme-line (file+cldate stream)
  (logging #'build-readme-line 1
           (format nil "Processing: ~A" (file+cldate-file file+cldate)))
  (handler-case
      (let ((title  (extract-title file+cldate))
            (mdlink (concatenate 'string
                                 "./"
                                 (file-namestring
                                  (file+cldate-file file+cldate)))))
        (format
         stream
         #.(println-strs '("<tr><td>"
                           "<a href=\"~A\">"
                           "<b>~A</b>"
                           "</a></td>"
                           "<td><code>~A</code></td>"
                           "</tr>"))
         mdlink title
         (build-date-format-lisp
          "%Y年%m月%d日 %H:%M"
          (file+cldate-cldate file+cldate))))
    (condition (e)
      (logging #'build-readme-line 2 (format nil "~S" e)))))

(defun build-readme ()
  (logging #'build-readme 0 "Building......")
  (handler-case
      (progn
        (with-open-file (in #p"./README_human.md")
          (with-open-file (out #p"README.md"
                               :direction :output
                               :if-exists :supersede)
            (do ((line (read-line in nil)
                       (read-line in nil)))
                ((null line))
              (format out "~A~%" line))
            (let ((articles (list-articles)))
              (format out "<table><tbody>~%")
              (format out "<tr><td>文章</td><td>更新日期</td></tr>~%")
              (mapcar
               (lambda (a)
                 (build-readme-line a out))
               articles)
              (format out "</tbody></table>")))))
    (condition (e) (logging #'build-readme 0 (format nil "~S" e)))))

(in-package :cl-user)

(rssgen:build-readme)
(rssgen:output-rss)
(format t "Done")

(if (find-package :swank) ;; check if in dev mode
    nil
    (sb-ext:exit))

