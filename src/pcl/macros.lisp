;;;; macros, global variable definitions, and other miscellaneous support stuff
;;;; used by the rest of the PCL subsystem

;;;; This software is part of the SBCL system. See the README file for
;;;; more information.

;;;; This software is derived from software originally released by Xerox
;;;; Corporation. Copyright and release statements follow. Later modifications
;;;; to the software are in the public domain and are provided with
;;;; absolutely no warranty. See the COPYING and CREDITS files for more
;;;; information.

;;;; copyright information from original PCL sources:
;;;;
;;;; Copyright (c) 1985, 1986, 1987, 1988, 1989, 1990 Xerox Corporation.
;;;; All rights reserved.
;;;;
;;;; Use and copying of this software and preparation of derivative works based
;;;; upon this software are permitted. Any distribution of this software or
;;;; derivative works must comply with all applicable United States export
;;;; control laws.
;;;;
;;;; This software is made available AS IS, and Xerox Corporation makes no
;;;; warranty about the software, its performance or its conformity to any
;;;; specification.

(in-package "SB-PCL")

(defglobal *optimize-speed*
  '(optimize (speed 3) (safety 0) (sb-ext:inhibit-warnings 3) (debug 0)))

(declaim (declaration
          ;; These nonstandard declarations seem to be used privately
          ;; within PCL itself to pass information around, so we can't
          ;; just delete them.
          %class
          %parameter
          ;; This declaration may also be used within PCL to pass
          ;; information around, I'm not sure. -- WHN 2000-12-30
          %variable-rebinding))

(defun get-declaration (name declarations &optional default)
  (dolist (d declarations default)
    (dolist (form (cdr d))
      (when (and (consp form) (eq (car form) name))
        (return-from get-declaration (cdr form))))))

;;;; FIND-CLASS
;;;;
;;;; This is documented in the CLOS specification.

(define-condition illegal-class-name-error (error)
  ((name :initarg :name :reader illegal-class-name-error-name))
  (:default-initargs :name (missing-arg))
  (:report (lambda (condition stream)
             (format stream "~@<~S is not a legal class name.~@:>"
                     (illegal-class-name-error-name condition)))))

(declaim (inline legal-class-name-p check-class-name))
(defun legal-class-name-p (thing)
  (symbolp thing))

(defun check-class-name (thing &optional (allow-nil t))
  ;; Apparently, FIND-CLASS and (SETF FIND-CLASS) accept any symbol,
  ;; but DEFCLASS only accepts non-NIL symbols.
  (if (or (not (legal-class-name-p thing))
          (and (null thing) (not allow-nil)))
      (error 'illegal-class-name-error :name thing)
      thing))

(define-condition class-not-found-error (sb-kernel::cell-error)
  ((sb-kernel::name :type (satisfies legal-class-name-p)))
  (:report (lambda (condition stream)
             (format stream "~@<There is no class named ~
                             ~/sb-ext:print-symbol-with-prefix/.~@:>"
                     (sb-kernel::cell-error-name condition)))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (defvar *create-classes-from-internal-structure-definitions-p* t))
(declaim (always-bound *create-classes-from-internal-structure-definitions-p*))

(declaim (ftype function ensure-non-standard-class))
(defun find-class-from-cell (symbol cell &optional (errorp t))
  (or (when cell
        (or (classoid-cell-pcl-class cell)
            (when *create-classes-from-internal-structure-definitions-p*
              (let ((classoid (classoid-cell-classoid cell)))
                (when (and classoid
                           (or (condition-classoid-p classoid)
                               (defstruct-classoid-p classoid)))
                  (ensure-non-standard-class symbol classoid))))))
      (when errorp
        (check-class-name symbol)
        (error 'class-not-found-error :name symbol))))

(defun find-class (symbol &optional (errorp t) environment)
  (declare (ignore environment) (explicit-check))
  (find-class-from-cell symbol
                        (find-classoid-cell symbol)
                        errorp))


(define-compiler-macro find-class (&whole form
                                   symbol &optional (errorp t) environment)
  (declare (ignore environment))
  (if (and (constantp symbol)
           (legal-class-name-p (setf symbol (constant-form-value symbol)))
           (constantp errorp)
           (member **boot-state** '(braid complete)))
      (let ((errorp (not (null (constant-form-value errorp))))
            (cell (make-symbol "CLASSOID-CELL")))
        `(let ((,cell ,(find-classoid-cell symbol :create t)))
           (or (classoid-cell-pcl-class ,cell)
               ,(if errorp
                    `(find-class-from-cell ',symbol ,cell)
                    `(when (classoid-cell-classoid ,cell)
                       (find-class-from-cell ',symbol ,cell nil))))))
      form))

(declaim (ftype function update-ctors))
(defun (setf find-class) (new-value name &optional errorp environment)
  (declare (ignore errorp environment))
  (check-class-name name)
  (with-single-package-locked-error
      (:symbol name "Using ~A as the class-name argument in ~
                     (SETF FIND-CLASS)"))
  (with-world-lock ()
    (let ((cell (find-classoid-cell name :create new-value)))
      (cond (new-value
             (setf (classoid-cell-pcl-class cell) new-value)
             (when (eq **boot-state** 'complete)
               (let ((classoid (class-classoid new-value)))
                 (setf (find-classoid name) classoid))))
            (cell
             (%clear-classoid name cell)))
      (when (or (eq **boot-state** 'complete)
                (eq **boot-state** 'braid))
        (update-ctors 'setf-find-class :class new-value :name name))
      new-value)))

(flet ((call-gf (gf-nameize object slot-name env &optional newval)
         (aver (constantp slot-name env))
         `(funcall #',(funcall gf-nameize (constant-form-value slot-name env))
                   ,@newval ,object)))
  (defmacro accessor-slot-boundp (object slot-name &environment env)
    (call-gf 'slot-boundp-name object slot-name env))

  (defmacro accessor-slot-value (object slot-name &environment env)
    `(truly-the (values t &optional)
                ,(call-gf 'slot-reader-name object slot-name env)))

  (defmacro accessor-set-slot-value (object slot-name new-value &environment env)
    ;; Expand NEW-VALUE before deciding not to bind a temp var for OBJECT,
    ;; which should be eval'd first. We skip the binding if either new-value
    ;; is constant or a plain variable. This is still subtly wrong if NEW-VALUE
    ;; is a special, because we'll read it more than once.
    (setq new-value (%macroexpand new-value env))
    (let ((bind-object (unless (or (constantp new-value env) (atom new-value))
                         (let* ((object-var (gensym))
                                (bind `((,object-var ,object))))
                           (setf object object-var)
                           bind)))
          ;; What's going on by not assuming that #'(SETF x) returns NEW-VALUE?
          ;; It seems wrong to return anything other than what the SETF fun
          ;; yielded. By analogy, when the SETF macro changes (SETF (F x) v)
          ;; into (funcall #'(setf F) ...), it does not insert any code to
          ;; enforce V as the overall value. So we do we do that here???
          (form `(let ((.new-value. ,new-value))
                   ,(call-gf 'slot-writer-name object slot-name env '(.new-value.))
                   .new-value.)))
      (if bind-object
          `(let ,bind-object ,form)
          form))))
