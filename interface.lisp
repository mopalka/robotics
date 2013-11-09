(defpackage :interface 
  (:use :cl :qt)
  (:export :main))

(in-package :interface)
(named-readtables:in-readtable :qt)

(defclass canva ()
  ((if-hit :accessor if-hit :initform nil)
  (rec-ang :accessor rec-ang :initform 0)
  (rec-pos :accessor rec-pos :initform (#_new QPoint 100 100)))
  (:metaclass qt-class)
  (:qt-superclass "QWidget")
  (:override ("paintEvent" paint-event)
	     ("mousePressEvent" mouse-press-event)
	     ("mouseReleaseEvent" mouse-release-event)
	     ("mouseMoveEvent" mouse-move-event)))


(defmethod mouse-press-event ((can canva) event)
  (setf (if-hit can) (#_button event)))

(defmethod mouse-release-event ((can canva) event)
  (setf (if-hit can) nil))

(defmethod mouse-move-event ((can canva) event) 
 (if (enum= (if-hit can) (#_LeftButton "Qt"))
      (progn
	(#_setX (rec-pos can) (#_rx (#_pos event)))
	(#_setY (rec-pos can) (#_ry (#_pos event)))

	(format t "in: (~A,~A)~%" (#_rx (#_pos event)) (#_ry (#_pos event))))
      (progn
	(let ((radians (atan (- (float (#_bottom (#_rect can)) 1.0d0)
				(#_y (#_pos event)))
			     (#_x (#_pos event)))))
	  (setf (rec-ang can)
		(round (* radians (/ 180 pi)))))))
	(#_update can))  


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
  (#_setPen painter (#_NoPen "Qt"))
  (with-objects ((brush (#_new QBrush (#_blue "Qt") (#_SolidPattern "Qt"))))
    (#_setBrush painter brush)
    (let ((point (rec-pos can)))
      (#_save painter)
      (#_translate painter  (#_rx point)  (#_ry point))
      (#_rotate painter (rec-ang can))
      (with-objects ((rect (#_new QRect -25 -25 50 50)))   
	(#_drawRect painter rect)
	(#_restore painter)))))

(defmethod paint-event ((can canva) paint-event)
  (with-objects ((painter (#_new QPainter can)))
    (#_setPen painter (#_black "Qt"))
    (paint-base can painter)
    (with-objects ((rect (#_new QRect 0 0 50 50)))   
      (#_drawRect painter rect))    
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
