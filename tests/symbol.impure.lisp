;;;; miscellaneous impure tests of SYMBOL-related stuff

;;;; This software is part of the SBCL system. See the README file for
;;;; more information.
;;;;
;;;; While most of SBCL is derived from the CMU CL system, the test
;;;; files (like this one) were written from scratch after the fork
;;;; from CMU CL.
;;;;
;;;; This software is in the public domain and is provided with
;;;; absolutely no warranty. See the COPYING and CREDITS files for
;;;; more information.

(in-package "CL-USER")

(declaim (type (simple-array fixnum (*)) *foo*))
(with-test (:name :defvar-type-error)
  (assert (eq :ok
              (handler-case
                  (eval `(defvar *foo* (make-array 10 :element-type '(unsigned-byte 60)
                                                   :initial-element 0)))
                (type-error (e)
                  (when (and (typep e 'type-error)
                             (equal '(simple-array fixnum (*))
                                    (type-error-expected-type e)))
                    ;; Check that it prints without an error.
                    (let ((string (princ-to-string e)))
                      (assert (not (sequence:emptyp string)))
                      :ok)))))))

;;; This enforces the rules given in CLHS 11.1.2.1.1 Constraints on
;;; the COMMON-LISP Package for Conforming Implementations.

(defun classify-symbol (symbol)
  (let ((result 0)
        (position 0))
    (flet ((flip (value)
             (when value
               (setf (ldb (byte 1 position) result) 1))
             (incf position)))
      (flip (boundp symbol))
      (flip (fboundp symbol))
      (flip (eq (sb-int:info :variable :kind symbol) :constant))
      (flip (and (sb-int:info :type :kind symbol) t)))
    result))

(defun describe-symbol-classification (classification)
  (let ((position -1))
    (flet ((check (key)
             (incf position)
             (if (logbitp position classification)
                 key
                 (values))))
      (multiple-value-call #'list
        (check :bound)
        (check :fbound)
        (check :constant)
        (check :type)))))

(defparameter *cl-classification*
  '(&ALLOW-OTHER-KEYS 0 &AUX 0 &BODY 0 &ENVIRONMENT 0 &KEY 0 &OPTIONAL 0 &REST 0
    &WHOLE 0 * 11 ** 1 *** 1 *BREAK-ON-SIGNALS* 1 *COMPILE-FILE-PATHNAME* 1
    *COMPILE-FILE-TRUENAME* 1 *COMPILE-PRINT* 1 *COMPILE-VERBOSE* 1 *DEBUG-IO* 1
    *DEBUGGER-HOOK* 1 *DEFAULT-PATHNAME-DEFAULTS* 1 *ERROR-OUTPUT* 1 *FEATURES* 1
    *GENSYM-COUNTER* 1 *LOAD-PATHNAME* 1 *LOAD-PRINT* 1 *LOAD-TRUENAME* 1
    *LOAD-VERBOSE* 1 *MACROEXPAND-HOOK* 1 *MODULES* 1 *PACKAGE* 1 *PRINT-ARRAY* 1
    *PRINT-BASE* 1 *PRINT-CASE* 1 *PRINT-CIRCLE* 1 *PRINT-ESCAPE* 1 *PRINT-GENSYM*
    1 *PRINT-LENGTH* 1 *PRINT-LEVEL* 1 *PRINT-LINES* 1 *PRINT-MISER-WIDTH* 1
    *PRINT-PPRINT-DISPATCH* 1 *PRINT-PRETTY* 1 *PRINT-RADIX* 1 *PRINT-READABLY* 1
    *PRINT-RIGHT-MARGIN* 1 *QUERY-IO* 1 *RANDOM-STATE* 1 *READ-BASE* 1
    *READ-DEFAULT-FLOAT-FORMAT* 1 *READ-EVAL* 1 *READ-SUPPRESS* 1 *READTABLE* 1
    *STANDARD-INPUT* 1 *STANDARD-OUTPUT* 1 *TERMINAL-IO* 1 *TRACE-OUTPUT* 1 + 3 ++
    1 +++ 1 - 3 / 3 // 1 /// 1 /= 2 1+ 2 1- 2 < 2 <= 2 = 2 > 2 >= 2 ABORT 2 ABS 2
    ACONS 2 ACOS 2 ACOSH 2 ADD-METHOD 2 ADJOIN 2 ADJUST-ARRAY 2 ADJUSTABLE-ARRAY-P
    2 ALLOCATE-INSTANCE 2 ALPHA-CHAR-P 2 ALPHANUMERICP 2 AND 2 APPEND 2 APPLY 2
    APROPOS 2 APROPOS-LIST 2 AREF 2 ARITHMETIC-ERROR 8 ARITHMETIC-ERROR-OPERANDS 2
    ARITHMETIC-ERROR-OPERATION 2 ARRAY 8 ARRAY-DIMENSION 2 ARRAY-DIMENSION-LIMIT 5
    ARRAY-DIMENSIONS 2 ARRAY-DISPLACEMENT 2 ARRAY-ELEMENT-TYPE 2
    ARRAY-HAS-FILL-POINTER-P 2 ARRAY-IN-BOUNDS-P 2 ARRAY-RANK 10 ARRAY-RANK-LIMIT
    5 ARRAY-ROW-MAJOR-INDEX 2 ARRAY-TOTAL-SIZE 10 ARRAY-TOTAL-SIZE-LIMIT 5 ARRAYP
    2 ASH 2 ASIN 2 ASINH 2 ASSERT 2 ASSOC 2 ASSOC-IF 2 ASSOC-IF-NOT 2 ATAN 2 ATANH
    2 ATOM 10 BASE-CHAR 8 BASE-STRING 8 BIGNUM 8 BIT 10 BIT-AND 2 BIT-ANDC1 2
    BIT-ANDC2 2 BIT-EQV 2 BIT-IOR 2 BIT-NAND 2 BIT-NOR 2 BIT-NOT 2 BIT-ORC1 2
    BIT-ORC2 2 BIT-VECTOR 8 BIT-VECTOR-P 2 BIT-XOR 2 BLOCK 2 BOOLE 2 BOOLE-1 5
    BOOLE-2 5 BOOLE-AND 5 BOOLE-ANDC1 5 BOOLE-ANDC2 5 BOOLE-C1 5 BOOLE-C2 5
    BOOLE-CLR 5 BOOLE-EQV 5 BOOLE-IOR 5 BOOLE-NAND 5 BOOLE-NOR 5 BOOLE-ORC1 5
    BOOLE-ORC2 5 BOOLE-SET 5 BOOLE-XOR 5 BOOLEAN 8 BOTH-CASE-P 2 BOUNDP 2 BREAK 2
    BROADCAST-STREAM 8 BROADCAST-STREAM-STREAMS 2 BUILT-IN-CLASS 8 BUTLAST 2 BYTE
    2 BYTE-POSITION 2 BYTE-SIZE 2 CAAAAR 2 CAAADR 2 CAAAR 2 CAADAR 2 CAADDR 2
    CAADR 2 CAAR 2 CADAAR 2 CADADR 2 CADAR 2 CADDAR 2 CADDDR 2 CADDR 2 CADR 2
    CALL-ARGUMENTS-LIMIT 5 CALL-METHOD 2 CALL-NEXT-METHOD 0 CAR 2 CASE 2 CATCH 2
    CCASE 2 CDAAAR 2 CDAADR 2 CDAAR 2 CDADAR 2 CDADDR 2 CDADR 2 CDAR 2 CDDAAR 2
    CDDADR 2 CDDAR 2 CDDDAR 2 CDDDDR 2 CDDDR 2 CDDR 2 CDR 2 CEILING 2 CELL-ERROR 8
    CELL-ERROR-NAME 2 CERROR 2 CHANGE-CLASS 2 CHAR 2 CHAR-CODE 10 CHAR-CODE-LIMIT
    5 CHAR-DOWNCASE 2 CHAR-EQUAL 2 CHAR-GREATERP 2 CHAR-INT 2 CHAR-LESSP 2
    CHAR-NAME 2 CHAR-NOT-EQUAL 2 CHAR-NOT-GREATERP 2 CHAR-NOT-LESSP 2 CHAR-UPCASE
    2 CHAR/= 2 CHAR< 2 CHAR<= 2 CHAR= 2 CHAR> 2 CHAR>= 2 CHARACTER 10 CHARACTERP 2
    CHECK-TYPE 2 CIS 2 CLASS 8 CLASS-NAME 2 CLASS-OF 2 CLEAR-INPUT 2 CLEAR-OUTPUT
    2 CLOSE 2 CLRHASH 2 CODE-CHAR 2 COERCE 2 COMPILATION-SPEED 0 COMPILE 2
    COMPILE-FILE 2 COMPILE-FILE-PATHNAME 2 COMPILED-FUNCTION 8 COMPILED-FUNCTION-P
    2 COMPILER-MACRO 0 COMPILER-MACRO-FUNCTION 2 COMPLEMENT 2 COMPLEX 10 COMPLEXP
    2 COMPUTE-APPLICABLE-METHODS 2 COMPUTE-RESTARTS 2 CONCATENATE 2
    CONCATENATED-STREAM 8 CONCATENATED-STREAM-STREAMS 2 COND 2 CONDITION 8
    CONJUGATE 2 CONS 10 CONSP 2 CONSTANTLY 2 CONSTANTP 2 CONTINUE 2 CONTROL-ERROR
    8 COPY-ALIST 2 COPY-LIST 2 COPY-PPRINT-DISPATCH 2 COPY-READTABLE 2 COPY-SEQ 2
    COPY-STRUCTURE 2 COPY-SYMBOL 2 COPY-TREE 2 COS 2 COSH 2 COUNT 2 COUNT-IF 2
    COUNT-IF-NOT 2 CTYPECASE 2 DEBUG 0 DECF 2 DECLAIM 2 DECLARATION 0 DECLARE 0
    DECODE-FLOAT 2 DECODE-UNIVERSAL-TIME 2 DEFCLASS 2 DEFCONSTANT 2 DEFGENERIC 2
    DEFINE-COMPILER-MACRO 2 DEFINE-CONDITION 2 DEFINE-METHOD-COMBINATION 2
    DEFINE-MODIFY-MACRO 2 DEFINE-SETF-EXPANDER 2 DEFINE-SYMBOL-MACRO 2 DEFMACRO 2
    DEFMETHOD 2 DEFPACKAGE 2 DEFPARAMETER 2 DEFSETF 2 DEFSTRUCT 2 DEFTYPE 2 DEFUN
    2 DEFVAR 2 DELETE 2 DELETE-DUPLICATES 2 DELETE-FILE 2 DELETE-IF 2
    DELETE-IF-NOT 2 DELETE-PACKAGE 2 DENOMINATOR 2 DEPOSIT-FIELD 2 DESCRIBE 2
    DESCRIBE-OBJECT 2 DESTRUCTURING-BIND 2 DIGIT-CHAR 2 DIGIT-CHAR-P 2 DIRECTORY 2
    DIRECTORY-NAMESTRING 2 DISASSEMBLE 2 DIVISION-BY-ZERO 8 DO 2 DO* 2
    DO-ALL-SYMBOLS 2 DO-EXTERNAL-SYMBOLS 2 DO-SYMBOLS 2 DOCUMENTATION 2 DOLIST 2
    DOTIMES 2 DOUBLE-FLOAT 8 DOUBLE-FLOAT-EPSILON 5 DOUBLE-FLOAT-NEGATIVE-EPSILON
    5 DPB 2 DRIBBLE 2 DYNAMIC-EXTENT 0 ECASE 2 ECHO-STREAM 8
    ECHO-STREAM-INPUT-STREAM 2 ECHO-STREAM-OUTPUT-STREAM 2 ED 2 EIGHTH 2 ELT 2
    ENCODE-UNIVERSAL-TIME 2 END-OF-FILE 8 ENDP 2 ENOUGH-NAMESTRING 2
    ENSURE-DIRECTORIES-EXIST 2 ENSURE-GENERIC-FUNCTION 2 EQ 2 EQL 10 EQUAL 2
    EQUALP 2 ERROR 10 ETYPECASE 2 EVAL 2 EVAL-WHEN 2 EVENP 2 EVERY 2 EXP 2 EXPORT
    2 EXPT 2 EXTENDED-CHAR 8 FBOUNDP 2 FCEILING 2 FDEFINITION 2 FFLOOR 2 FIFTH 2
    FILE-AUTHOR 2 FILE-ERROR 8 FILE-ERROR-PATHNAME 2 FILE-LENGTH 2 FILE-NAMESTRING
    2 FILE-POSITION 2 FILE-STREAM 8 FILE-STRING-LENGTH 2 FILE-WRITE-DATE 2 FILL 2
    FILL-POINTER 2 FIND 2 FIND-ALL-SYMBOLS 2 FIND-CLASS 2 FIND-IF 2 FIND-IF-NOT 2
    FIND-METHOD 2 FIND-PACKAGE 2 FIND-RESTART 2 FIND-SYMBOL 2 FINISH-OUTPUT 2
    FIRST 2 FIXNUM 8 FLET 2 FLOAT 10 FLOAT-DIGITS 10 FLOAT-PRECISION 2 FLOAT-RADIX
    10 FLOAT-SIGN 2 FLOATING-POINT-INEXACT 8 FLOATING-POINT-INVALID-OPERATION 8
    FLOATING-POINT-OVERFLOW 8 FLOATING-POINT-UNDERFLOW 8 FLOATP 2 FLOOR 2
    FMAKUNBOUND 2 FORCE-OUTPUT 2 FORMAT 2 FORMATTER 2 FOURTH 2 FRESH-LINE 2 FROUND
    2 FTRUNCATE 2 FTYPE 0 FUNCALL 2 FUNCTION 10 FUNCTION-KEYWORDS 2
    FUNCTION-LAMBDA-EXPRESSION 2 FUNCTIONP 2 GCD 2 GENERIC-FUNCTION 8 GENSYM 2
    GENTEMP 2 GET 2 GET-DECODED-TIME 2 GET-DISPATCH-MACRO-CHARACTER 2
    GET-INTERNAL-REAL-TIME 2 GET-INTERNAL-RUN-TIME 2 GET-MACRO-CHARACTER 2
    GET-OUTPUT-STREAM-STRING 2 GET-PROPERTIES 2 GET-SETF-EXPANSION 2
    GET-UNIVERSAL-TIME 2 GETF 2 GETHASH 2 GO 2 GRAPHIC-CHAR-P 2 HANDLER-BIND 2
    HANDLER-CASE 2 HASH-TABLE 8 HASH-TABLE-COUNT 2 HASH-TABLE-P 2
    HASH-TABLE-REHASH-SIZE 2 HASH-TABLE-REHASH-THRESHOLD 2 HASH-TABLE-SIZE 2
    HASH-TABLE-TEST 2 HOST-NAMESTRING 2 IDENTITY 2 IF 2 IGNORABLE 0 IGNORE 0
    IGNORE-ERRORS 2 IMAGPART 2 IMPORT 2 IN-PACKAGE 2 INCF 2 INITIALIZE-INSTANCE 2
    INLINE 0 INPUT-STREAM-P 2 INSPECT 2 INTEGER 8 INTEGER-DECODE-FLOAT 2
    INTEGER-LENGTH 2 INTEGERP 2 INTERACTIVE-STREAM-P 2 INTERN 2
    INTERNAL-TIME-UNITS-PER-SECOND 5 INTERSECTION 2 INVALID-METHOD-ERROR 2
    INVOKE-DEBUGGER 2 INVOKE-RESTART 2 INVOKE-RESTART-INTERACTIVELY 2 ISQRT 2
    KEYWORD 8 KEYWORDP 2 LABELS 2 LAMBDA 2 LAMBDA-LIST-KEYWORDS 5
    LAMBDA-PARAMETERS-LIMIT 5 LAST 2 LCM 2 LDB 2 LDB-TEST 2 LDIFF 2
    LEAST-NEGATIVE-DOUBLE-FLOAT 5 LEAST-NEGATIVE-LONG-FLOAT 5
    LEAST-NEGATIVE-NORMALIZED-DOUBLE-FLOAT 5 LEAST-NEGATIVE-NORMALIZED-LONG-FLOAT
    5 LEAST-NEGATIVE-NORMALIZED-SHORT-FLOAT 5
    LEAST-NEGATIVE-NORMALIZED-SINGLE-FLOAT 5 LEAST-NEGATIVE-SHORT-FLOAT 5
    LEAST-NEGATIVE-SINGLE-FLOAT 5 LEAST-POSITIVE-DOUBLE-FLOAT 5
    LEAST-POSITIVE-LONG-FLOAT 5 LEAST-POSITIVE-NORMALIZED-DOUBLE-FLOAT 5
    LEAST-POSITIVE-NORMALIZED-LONG-FLOAT 5 LEAST-POSITIVE-NORMALIZED-SHORT-FLOAT 5
    LEAST-POSITIVE-NORMALIZED-SINGLE-FLOAT 5 LEAST-POSITIVE-SHORT-FLOAT 5
    LEAST-POSITIVE-SINGLE-FLOAT 5 LENGTH 2 LET 2 LET* 2 LISP-IMPLEMENTATION-TYPE 2
    LISP-IMPLEMENTATION-VERSION 2 LIST 10 LIST* 2 LIST-ALL-PACKAGES 2 LIST-LENGTH
    2 LISTEN 2 LISTP 2 LOAD 2 LOAD-LOGICAL-PATHNAME-TRANSLATIONS 2 LOAD-TIME-VALUE
    2 LOCALLY 2 LOG 2 LOGAND 2 LOGANDC1 2 LOGANDC2 2 LOGBITP 2 LOGCOUNT 2 LOGEQV 2
    LOGICAL-PATHNAME 10 LOGICAL-PATHNAME-TRANSLATIONS 2 LOGIOR 2 LOGNAND 2 LOGNOR
    2 LOGNOT 2 LOGORC1 2 LOGORC2 2 LOGTEST 2 LOGXOR 2 LONG-FLOAT 8
    LONG-FLOAT-EPSILON 5 LONG-FLOAT-NEGATIVE-EPSILON 5 LONG-SITE-NAME 2 LOOP 2
    LOOP-FINISH 2 LOWER-CASE-P 2 MACHINE-INSTANCE 2 MACHINE-TYPE 2 MACHINE-VERSION
    2 MACRO-FUNCTION 2 MACROEXPAND 2 MACROEXPAND-1 2 MACROLET 2 MAKE-ARRAY 2
    MAKE-BROADCAST-STREAM 2 MAKE-CONCATENATED-STREAM 2 MAKE-CONDITION 2
    MAKE-DISPATCH-MACRO-CHARACTER 2 MAKE-ECHO-STREAM 2 MAKE-HASH-TABLE 2
    MAKE-INSTANCE 2 MAKE-INSTANCES-OBSOLETE 2 MAKE-LIST 2 MAKE-LOAD-FORM 2
    MAKE-LOAD-FORM-SAVING-SLOTS 2 MAKE-METHOD 0 MAKE-PACKAGE 2 MAKE-PATHNAME 2
    MAKE-RANDOM-STATE 2 MAKE-SEQUENCE 2 MAKE-STRING 2 MAKE-STRING-INPUT-STREAM 2
    MAKE-STRING-OUTPUT-STREAM 2 MAKE-SYMBOL 2 MAKE-SYNONYM-STREAM 2
    MAKE-TWO-WAY-STREAM 2 MAKUNBOUND 2 MAP 2 MAP-INTO 2 MAPC 2 MAPCAN 2 MAPCAR 2
    MAPCON 2 MAPHASH 2 MAPL 2 MAPLIST 2 MASK-FIELD 2 MAX 2 MEMBER 2 MEMBER-IF 2
    MEMBER-IF-NOT 2 MERGE 2 MERGE-PATHNAMES 2 METHOD 8 METHOD-COMBINATION 8
    METHOD-COMBINATION-ERROR 2 METHOD-QUALIFIERS 2 MIN 2 MINUSP 2 MISMATCH 2 MOD
    10 MOST-NEGATIVE-DOUBLE-FLOAT 5 MOST-NEGATIVE-FIXNUM 5
    MOST-NEGATIVE-LONG-FLOAT 5 MOST-NEGATIVE-SHORT-FLOAT 5
    MOST-NEGATIVE-SINGLE-FLOAT 5 MOST-POSITIVE-DOUBLE-FLOAT 5 MOST-POSITIVE-FIXNUM
    5 MOST-POSITIVE-LONG-FLOAT 5 MOST-POSITIVE-SHORT-FLOAT 5
    MOST-POSITIVE-SINGLE-FLOAT 5 MUFFLE-WARNING 2 MULTIPLE-VALUE-BIND 2
    MULTIPLE-VALUE-CALL 2 MULTIPLE-VALUE-LIST 2 MULTIPLE-VALUE-PROG1 2
    MULTIPLE-VALUE-SETQ 2 MULTIPLE-VALUES-LIMIT 5 NAME-CHAR 2 NAMESTRING 2
    NBUTLAST 2 NCONC 2 NEXT-METHOD-P 0 NIL 13 NINTERSECTION 2 NINTH 2
    NO-APPLICABLE-METHOD 2 NO-NEXT-METHOD 2 NOT 2 NOTANY 2 NOTEVERY 2 NOTINLINE 0
    NRECONC 2 NREVERSE 2 NSET-DIFFERENCE 2 NSET-EXCLUSIVE-OR 2 NSTRING-CAPITALIZE
    2 NSTRING-DOWNCASE 2 NSTRING-UPCASE 2 NSUBLIS 2 NSUBST 2 NSUBST-IF 2
    NSUBST-IF-NOT 2 NSUBSTITUTE 2 NSUBSTITUTE-IF 2 NSUBSTITUTE-IF-NOT 2 NTH 2
    NTH-VALUE 2 NTHCDR 2 NULL 10 NUMBER 8 NUMBERP 2 NUMERATOR 2 NUNION 2 ODDP 2
    OPEN 2 OPEN-STREAM-P 2 OPTIMIZE 0 OR 2 OTHERWISE 0 OUTPUT-STREAM-P 2 PACKAGE 8
    PACKAGE-ERROR 8 PACKAGE-ERROR-PACKAGE 2 PACKAGE-NAME 2 PACKAGE-NICKNAMES 2
    PACKAGE-SHADOWING-SYMBOLS 2 PACKAGE-USE-LIST 2 PACKAGE-USED-BY-LIST 2 PACKAGEP
    2 PAIRLIS 2 PARSE-ERROR 8 PARSE-INTEGER 2 PARSE-NAMESTRING 2 PATHNAME 10
    PATHNAME-DEVICE 10 PATHNAME-DIRECTORY 10 PATHNAME-HOST 10 PATHNAME-MATCH-P 2
    PATHNAME-NAME 10 PATHNAME-TYPE 10 PATHNAME-VERSION 10 PATHNAMEP 2 PEEK-CHAR 2
    PHASE 2 PI 5 PLUSP 2 POP 2 POSITION 2 POSITION-IF 2 POSITION-IF-NOT 2 PPRINT 2
    PPRINT-DISPATCH 2 PPRINT-EXIT-IF-LIST-EXHAUSTED 2))

(defun check-symbols (classification)
  (loop for (symbol expected) on classification by #'cddr
        for current = (classify-symbol symbol)
        do
        (when (/= expected current)
          (error "Symbol ~s is ~s; expected to be ~s"
                 symbol
                 (describe-symbol-classification current)
                 (describe-symbol-classification expected)))))

(with-test (:name :check-cl-symbols)
  (check-symbols *cl-classification*))

(with-test (:name :makunbound-constant)
  (let ((name (gensym)))
    (eval `(defconstant ,name 32))
    (handler-bind ((error #'continue))
      (makunbound name))
    (eval `(defvar ,name 33))
    (assert (= (symbol-value name) 33))))

(with-test (:name (:defvar :no-eval-of-docstring))
  (assert-error (defvar #.(gensym) 10 (print "docstring"))))

(with-test (:name (:defparameter :no-eval-of-docstring))
  (assert-error (defparameter #.(gensym) 10 (print "docstring"))))

(with-test (:name (:defconstant :no-eval-of-docstring))
  (assert-error (defconstant #.(gensym) 10 (print "docstring"))))

(defvar *always-bound* 10)
(declaim (sb-ext:always-bound *always-bound*))

(with-test (:name :progv-unbind-always-bound)
  (checked-compile-and-assert
   ()
   '(lambda (vars vals)
     (progv vars vals))
   (('(*always-bound*) nil) (condition 'error))))
