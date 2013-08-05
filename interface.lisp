(defpackage :interface 
  (:use :cl :qt)
  (:export :main))

(in-package :interface)
(named-readtables:in-readtable :qt)

(defclass main-window ()
  ((info :initform "hello" :accessor info))
  (:metaclass qt-class)
  (:qt-superclass "QWidget"))

(defmethod  initialize-instance :after ((win main-window) &key parent)
  (if parent
      (new win parent)
      (new win))
  (let ((quit (#_new QPushButton "&Quit")))
    (#_connect "QObject"
	       quit
	       (QSIGNAL "clicked()")
	       (#_QCoreApplication::instance)
	       (QSLOT "quit()")) 
    (let ((left-layout (#_new QVBoxLayout)))
      (#_addWidget left-layout quit)
      (#_show quit)
      (#_setLayout win left-layout))))

(defun main()
  (let* ((app (make-qapplication))
	 (win (make-instance 'main-window)))
      (#_show win)
      (unwind-protect
	   (#_exec (#_new QEventLoop))
        (#_hide win))))

;(main)