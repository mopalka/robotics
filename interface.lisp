(defpackage :interface 
  (:use :cl :qt)
  (:export :main))

(in-package :interface)
(named-readtables:in-readtable :qt)

(defclass canva ()
  ()
  (:metaclass qt-class)
  (:qt-superclass "QWidget")
  (:override ("paintEvent" paint-event)
	     ("mousePressEvent" mouse-press-event)))


(defmethod mouse-press-event ((can canva) event)
             (format t "~A" (#_pos event)))


(defmethod initialize-instance :after ((can canva) &key parent)
  (if parent
      (progn 
	(new can parent)
	(format t "father"))
      (new can))
  (with-objects ((col (#_new QColor 250 250 200))
                 (pal (#_new QPalette col)))
    (#_setPalette can pal))
  (#_setGeometry can 2 2 396 396)    
  (#_setAutoFillBackground can t)
  (format t "created...")
  (#_update can))


(defun paint-base (can painter)
  (with-objects ((rect (#_new QRect 100 100 50 50)))
    (#_drawRect painter rect)))

(defmethod paint-event ((can canva) paint-event)
  (with-objects ((painter (#_new QPainter can)))
    (#_setPen painter (#_black "Qt"))
    (with-objects ((font (#_new QFont "Courier" 48 (#_Bold "QFont"))))
      (#_setFont painter font))
    ;;  (#_drawText painter (#_new QRect 0 0 400 400)
    ;;		(#_AlignCenter "Qt") "Game Over") 
    (format t "painting...")
    (paint-base can painter)
    (#_end painter)))

(defclass main-window ()
  ((info :initform "hello" :accessor info)
   (can :accessor can))
  (:metaclass qt-class)
  (:qt-superclass "QWidget")
  (:slots ("ok-slot()" ok-slot)))


(defmethod ok-slot ((win main-window))
  (format t "ok clicked"))

(defmethod  initialize-instance :after ((win main-window) &key parent)
  (if parent
      (new win parent)
      (new win))
  (let* ((quit (#_new QPushButton "&Quit"))
	(ok (#_new QPushButton "&OK"))
	 (can-box (#_new QFrame))
	 (canv (make-instance 'canva :parent can-box)))
    (#_setFrameStyle can-box
		     (logior (primitive-value (#_WinPanel "QFrame"))
			     (primitive-value (#_Sunken "QFrame"))))
    (setf (can win) canv)
    (#_connect "QObject"
	       quit
	       (QSIGNAL "clicked()")
	       (#_QCoreApplication::instance)
	       (QSLOT "quit()"))
    (#_connect "QObject"
	       ok
	       (QSIGNAL "clicked()")
	       win
	       (QSLOT "ok-slot()")) 
    (let ((left-layout (#_new QVBoxLayout)))
      (#_addWidget left-layout quit)
      (#_show quit)
      (#_addWidget left-layout ok)
      (#_show ok)      
      (#_addWidget left-layout can-box)
      (#_setLayout win left-layout))))

(defun main()
  (let* ((app (make-qapplication))
	 (win (make-instance 'main-window)))
    (#_setFixedSize win  400 400)    
    (#_show win)
    (unwind-protect
	 (#_exec (#_new QEventLoop))
      (#_hide win)
      (#_delete app))))

;(main)
