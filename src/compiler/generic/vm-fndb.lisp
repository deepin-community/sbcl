;;;; signatures of machine-specific functions

;;;; This software is part of the SBCL system. See the README file for
;;;; more information.
;;;;
;;;; This software is derived from the CMU CL system, which was
;;;; written at Carnegie Mellon University and released into the
;;;; public domain. The software is in the public domain and is
;;;; provided with absolutely no warranty. See the COPYING and CREDITS
;;;; files for more information.

(in-package "SB-C")

;;;; internal type predicates

;;; Simple TYPEP uses that don't have any standard predicate are
;;; translated into non-standard unary predicates.
(defknown (fixnump bignump ratiop
           short-float-p single-float-p double-float-p long-float-p
           complex-rational-p complex-float-p complex-single-float-p
           complex-double-float-p #+long-float complex-long-float-p
           complex-vector-p
           #+sb-unicode base-char-p
           %standard-char-p %instancep
           base-string-p simple-base-string-p
           #+sb-unicode character-string-p
           #+sb-unicode simple-character-string-p
           array-header-p
           simple-array-header-p
           sequencep extended-sequence-p
           simple-array-p simple-array-nil-p
           simple-array-unsigned-byte-2-p
           simple-array-unsigned-byte-4-p simple-array-unsigned-byte-7-p
           simple-array-unsigned-byte-8-p simple-array-unsigned-byte-15-p
           simple-array-unsigned-byte-16-p

           simple-array-unsigned-fixnum-p

           simple-array-unsigned-byte-31-p
           simple-array-unsigned-byte-32-p
           #+64-bit
           simple-array-unsigned-byte-63-p
           #+64-bit
           simple-array-unsigned-byte-64-p
           simple-array-signed-byte-8-p simple-array-signed-byte-16-p

           simple-array-fixnum-p

           simple-array-signed-byte-32-p
           #+64-bit
           simple-array-signed-byte-64-p
           simple-array-single-float-p simple-array-double-float-p
           #+long-float simple-array-long-float-p
           simple-array-complex-single-float-p
           simple-array-complex-double-float-p
           #+long-float simple-array-complex-long-float-p
           simple-rank-1-array-*-p
           system-area-pointer-p realp
           ;; #-64-bit
           unsigned-byte-32-p
           ;; #-64-bit
           signed-byte-32-p
           #+64-bit
           unsigned-byte-64-p
           #+64-bit
           signed-byte-64-p
           weak-pointer-p code-component-p lra-p
           sb-int:unbound-marker-p
           pointerp
           simple-fun-p
           closurep
           funcallable-instance-p
           function-with-layout-p
           non-null-symbol-p)
    (t) boolean (movable foldable flushable))

(defknown #.(loop for (name) in *vector-without-complex-typecode-infos*
                  collect name)
    (t) boolean (movable foldable flushable))

(defknown %other-pointer-p (t) boolean
  (movable foldable flushable always-translatable))

;; Return T if the first arg is an other-pointer and its widetag
;; is in the collection specified by the second arg.
(defknown %other-pointer-subtype-p (t list) boolean
  (movable foldable flushable always-translatable))

;;; Predicates that don't accept T for the first argument type
(defknown (float-infinity-p float-nan-p float-infinity-or-nan-p)
  (float) boolean (movable foldable flushable))

;;;; miscellaneous "sub-primitives"

(defknown pointer-hash (t) fixnum (flushable))

(defknown %sp-string-compare
  (simple-string index (or null index) simple-string index (or null index))
  (values index fixnum)
  (foldable flushable))

(defknown sb-impl::number-sxhash (number) hash-code (foldable flushable))
(defknown %sxhash-string (string) hash-code (foldable flushable))
(defknown %sxhash-simple-string (simple-string) hash-code (foldable flushable))

(defknown (%sxhash-simple-substring) (simple-string index index) hash-code
  (foldable flushable))
(defknown sb-impl::compute-symbol-hash (simple-string index) hash-code
  (foldable flushable))

(defknown (symbol-hash ensure-symbol-hash) (symbol) hash-code
  (flushable movable))
;;; This unusual accessor will read the word at SYMBOL-HASH-SLOT in any
;;; object, not only symbols. The result is meaningful only if the object
;;; is a symbol. The second argument indicates a predicate that the first
;;; argument is known to satisfy, if any.
;;; There is one more case, but an uninteresting one: the object is known
;;; to be anything except NIL. That predicate would be IDENTITY,
;;; which is not terribly helpful from a code generation stance.
(defknown symbol-hash* (t (member nil symbolp non-null-symbol-p))
  hash-code (flushable movable always-translatable))

(defknown %set-symbol-hash (symbol hash-code)
  t ())

(defknown symbol-info-vector (symbol) (or null simple-vector))

(defknown initialize-vector ((simple-array * (*)) &rest t)
  (simple-array * (*))
  (always-translatable flushable)
  :result-arg 0)

(defknown (vector-fill* vector-fill/t) (t t t t) vector
  ()
  :result-arg 0)

;;; Return the length of VECTOR.
;;; Ordinary code should prefer to use (LENGTH (THE VECTOR FOO)) instead.
(defknown vector-length (vector) index (flushable dx-safe))

(defknown vector-sap ((simple-unboxed-array (*))) system-area-pointer
  (flushable))

#+gencgc
(defknown generation-of (t) (or (signed-byte 8) null) (flushable))

;;; WIDETAG-OF needs extra code to handle LIST and FUNCTION lowtags.
;;; When dealing with known other-pointers (dispatching on array
;;; element type for example), %OTHER-POINTER-WIDETAG is faster.
(defknown (widetag-of %other-pointer-widetag) (t)
  (unsigned-byte #.sb-vm:n-widetag-bits)
  (flushable movable))

;;; Return the data from the header of an OTHER-POINTER object.
(defknown (get-header-data) (t)
    (unsigned-byte #.(- sb-vm:n-word-bits sb-vm:n-widetag-bits))
  (flushable))
(defknown (function-header-word) (function) sb-vm:word (flushable))
(defknown (instance-header-word) (instance) sb-vm:word (flushable))

(defknown set-header-data
    (t (unsigned-byte #.(- sb-vm:n-word-bits sb-vm:n-widetag-bits))) (values))
;;; Like SET-HEADER-DATA, but instead of writing the entire header,
;;; LOGIOR of the specified value into the "data" portion of the word.
;;; Returns the first argument, *not* the modified header data.
(defknown logior-header-bits (t (unsigned-byte 16)) t
    (#+x86-64 always-translatable))
;;; ASSIGN-VECTOR-FLAGSS assign all and only the flags byte.
;;; RESET- performs LOGANDC2 and returns no value.
(defknown (assign-vector-flags reset-header-bits)
  (t (unsigned-byte 8)) (values)
  (#+x86-64 always-translatable))
(defknown (test-header-bit)
  (t (unsigned-byte #.(- sb-vm:n-word-bits sb-vm:n-widetag-bits))) (boolean)
  (flushable))

(defknown %array-dimension (array index) index
  (flushable))
(defknown %set-array-dimension (array index index) (values)
  ())
(defknown %array-rank (array) array-rank
  (flushable))

#+(or x86 x86-64)
(defknown (%array-rank= widetag=) (t t) boolean
  (flushable))

(defknown sb-kernel::check-array-shape (simple-array list)
  (simple-array)
  (flushable)
  :result-arg 0)

(defknown %make-instance (index) instance
  (flushable))
(defknown %make-structure-instance (defstruct-description list &rest t) instance
  (flushable always-translatable))
(defknown (%copy-instance %copy-instance-slots) (instance instance) instance
  () :result-arg 0)
(defknown %instance-layout (instance) sb-vm:layout (foldable flushable))
(defknown %instance-wrapper (instance) wrapper (foldable flushable))
;;; %FUN-LAYOUT is to %INSTANCE-LAYOUT as FUN-POINTER-LOWTAG is to INSTANCE-POINTER-LOWTAG
(defknown %fun-layout (#-compact-instance-header funcallable-instance
                       #+compact-instance-header function)
  sb-vm:layout (foldable flushable))
(defknown %fun-wrapper (#-compact-instance-header funcallable-instance
                        #+compact-instance-header function)
  wrapper
  (foldable flushable))
(defknown %set-instance-layout (instance sb-vm:layout) (values) ())
;;; %SET-FUN-LAYOUT should only called on FUNCALLABLE-INSTANCE
;;; (but %set-funcallable-instance-layout is too long a name)
(defknown %set-fun-layout (funcallable-instance sb-vm:layout) (values) ())
;;; Layout getter that accepts any object, and if it has INSTANCE- or FUN-
;;; POINTER-LOWTAG returns the layout, otherwise some agreed-upon layout.
(defknown %instanceoid-layout (t) sb-vm:layout (flushable))
(defknown layout-eq ((or instance function) t (mod 16)) boolean (flushable))
;;; Caution: This is not exactly the same as instance_length() in C.
;;; The C one is the same as SB-VM::INSTANCE-LENGTH.
(defknown %instance-length (instance) (unsigned-byte 14) (foldable flushable))
(defknown %instance-cas (instance index t t) t ())
(defknown %instance-ref (instance index) t
  (flushable always-translatable))
(defknown (%instance-ref-eq) (instance index t) boolean
  (flushable always-translatable))
(defknown %instance-set (instance index t) (values) (always-translatable))
(defknown update-object-layout (t) sb-vm:layout)

#+(or arm64 ppc ppc64 riscv x86 x86-64)
(defknown %raw-instance-cas/word (instance index sb-vm:word sb-vm:word)
  sb-vm:word ())
#+riscv
(defknown %raw-instance-cas/signed-word (instance index sb-vm:signed-word sb-vm:signed-word)
  sb-vm:signed-word ())
(defknown %raw-instance-xchg/word (instance index sb-vm:word) sb-vm:word ())

#.`(progn
     ,@(map 'list
            (lambda (rsd)
              (let* ((reader (sb-kernel::raw-slot-data-reader-name rsd))
                     (writer (sb-kernel::raw-slot-data-writer-name rsd))
                     (type (sb-kernel::raw-slot-data-raw-type rsd)))
                `(progn
                   (defknown ,reader (instance index) ,type
                     (flushable always-translatable))
                   (defknown ,writer (instance index ,type) (values)
                     (always-translatable)))))
            sb-kernel::*raw-slot-data*))

#+compare-and-swap-vops
(defknown %raw-instance-atomic-incf/word (instance index sb-vm:word) sb-vm:word
    (always-translatable))
#+compare-and-swap-vops
(defknown %array-atomic-incf/word (t index sb-vm:word) sb-vm:word
  (always-translatable))

;;; These two are mostly used for bit-bashing operations.
(defknown %vector-raw-bits (t index) sb-vm:word
  (flushable))
(defknown (%set-vector-raw-bits) (t index sb-vm:word) sb-vm:word
  ())


;;; Allocate an unboxed, non-fancy vector with type code TYPE, length LENGTH,
;;; and WORDS words long. Note: it is your responsibility to ensure that the
;;; relation between LENGTH and WORDS is correct.
;;; The extra bit beyond N_WIDETAG_BITS is for the vector weakness flag.
;;; Note that in almost all situations the first argument is a constant.
;;; There are only 3 places that it can be non-constant, and not at all
;;; after self-build is complete. The three non-constant places are from:
;;;  - ALLOCATE-VECTOR-WITH-WIDETAG in src/code/array
;;;  - ALLOCATE-VECTOR (which is basically a stub) in src/code/array
;;;  - FOP-SPEC-VECTOR which calls allocate-vector
;;; Apart from those, user code that does not have a compile-time-determined
;;; vector type will usuallly end up calling allocate-vector-with-widetag
;;; via %MAKE-ARRAY.
(defknown allocate-vector (#+ubsan boolean
                           (unsigned-byte 9) index
                           ;; The number of words is later converted
                           ;; to bytes, make sure it fits.
                           (and index
                                (mod #.(- (expt 2
                                                (- sb-vm:n-word-bits
                                                   sb-vm:word-shift
                                                   ;; all the allocation routines expect a signed word
                                                   1))
                                          ;; The size is double-word aligned, which is done by adding
                                          ;; (1- (/ sb-vm:n-word-bits 2)) and then masking.
                                          ;; Make sure addition doesn't overflow.
                                          3))))
    (simple-array * (*))
    (flushable movable))

;;; Allocate an array header with type code TYPE and rank RANK.
(defknown make-array-header ((unsigned-byte 8) (mod #.array-rank-limit)) array
  (flushable movable))

(defknown make-array-header* (&rest t) array (flushable movable))

(defknown make-weak-pointer (t) weak-pointer
  (flushable))

(defknown make-weak-vector (index &key (:initial-element t)
                                       (:initial-contents t))
  simple-vector (flushable)
  :derive-type (lambda (call)
                 (derive-make-array-type (first (combination-args call))
                                         't nil nil nil call)))

(defknown %make-complex (real real) complex
  (flushable movable))
(defknown %make-ratio (integer integer) ratio
  (flushable movable))
(defknown make-value-cell (t) t
  (flushable movable))

#+sb-simd-pack
(progn
  (defknown simd-pack-p (t) boolean (foldable movable flushable))
  (defknown %simd-pack-tag (simd-pack) fixnum (movable flushable))
  (defknown %make-simd-pack (fixnum (unsigned-byte 64) (unsigned-byte 64))
      simd-pack
      (flushable movable foldable))
  (defknown %make-simd-pack-double (double-float double-float)
      (simd-pack double-float)
      (flushable movable foldable))
  (defknown %make-simd-pack-single (single-float single-float
                                    single-float single-float)
      (simd-pack single-float)
      (flushable movable foldable))
  (defknown %make-simd-pack-ub32 ((unsigned-byte 32) (unsigned-byte 32)
                                  (unsigned-byte 32) (unsigned-byte 32))
      (simd-pack integer)
      (flushable movable foldable))
  (defknown %make-simd-pack-ub64 ((unsigned-byte 64) (unsigned-byte 64))
      (simd-pack integer)
      (flushable movable foldable))
  (defknown (%simd-pack-low %simd-pack-high) (simd-pack)
      (unsigned-byte 64)
      (flushable movable foldable))
  (defknown %simd-pack-ub32s (simd-pack)
      (values (unsigned-byte 32) (unsigned-byte 32)
              (unsigned-byte 32) (unsigned-byte 32))
      (flushable movable foldable))
  (defknown %simd-pack-ub64s (simd-pack)
      (values (unsigned-byte 64) (unsigned-byte 64))
      (flushable movable foldable))
  (defknown %simd-pack-singles (simd-pack)
      (values single-float single-float single-float single-float)
      (flushable movable foldable))
  (defknown %simd-pack-doubles (simd-pack)
      (values double-float double-float)
      (flushable movable foldable)))

#+sb-simd-pack-256
(progn
  (defknown simd-pack-256-p (t) boolean (foldable movable flushable))
  (defknown %simd-pack-256-tag (simd-pack-256) fixnum (movable flushable))
  (defknown %make-simd-pack-256 (fixnum (unsigned-byte 64) (unsigned-byte 64)
                                        (unsigned-byte 64) (unsigned-byte 64))
      simd-pack-256
      (flushable movable foldable))
  (defknown %make-simd-pack-256-double (double-float double-float double-float double-float)
      (simd-pack-256 double-float)
      (flushable movable foldable))
  (defknown %make-simd-pack-256-single (single-float single-float single-float single-float
                                        single-float single-float single-float single-float)
      (simd-pack-256 single-float)
      (flushable movable foldable))
  (defknown %make-simd-pack-256-ub32 ((unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32)
                                      (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32))
      (simd-pack-256 integer)
      (flushable movable foldable))
  (defknown %make-simd-pack-256-ub64 ((unsigned-byte 64) (unsigned-byte 64) (unsigned-byte 64) (unsigned-byte 64))
      (simd-pack-256 integer)
      (flushable movable foldable))
  (defknown (%simd-pack-256-0 %simd-pack-256-1 %simd-pack-256-2 %simd-pack-256-3) (simd-pack-256)
      (unsigned-byte 64)
      (flushable movable foldable))
  (defknown %simd-pack-256-ub32s (simd-pack-256)
      (values (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32)
              (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32) (unsigned-byte 32))
      (flushable movable foldable))
  (defknown %simd-pack-256-ub64s (simd-pack-256)
      (values (unsigned-byte 64) (unsigned-byte 64) (unsigned-byte 64) (unsigned-byte 64))
      (flushable movable foldable))
  (defknown %simd-pack-256-singles (simd-pack-256)
      (values single-float single-float single-float single-float
              single-float single-float single-float single-float)
      (flushable movable foldable))
  (defknown %simd-pack-256-doubles (simd-pack-256)
      (values double-float double-float double-float double-float)
      (flushable movable foldable)))

;;;; threading

(defknown (dynamic-space-free-pointer binding-stack-pointer-sap
                                      control-stack-pointer-sap)  ()
    system-area-pointer
    (flushable))

#+sb-thread
(progn (defknown ensure-symbol-tls-index (symbol)
         (and fixnum unsigned-byte)) ; not flushable
       (defknown symbol-tls-index (symbol)
         (and fixnum unsigned-byte) (flushable)))

;;;; debugger support

(defknown sb-vm::current-thread-offset-sap (fixnum)
  system-area-pointer (flushable))
(defknown (current-sp current-fp) () system-area-pointer (flushable))
(defknown current-fp-fixnum () fixnum (flushable))
;; STACK-REF is pretty nearly just SAP-REF-LISPOBJ except that
;; it takes a word index, not a byte displacement from the SAP.
(defknown stack-ref (system-area-pointer index) t (flushable))
(defknown %set-stack-ref (system-area-pointer index t) (values) ())
(defknown lra-code-header (t) t (movable flushable))
;; FUN-CODE-HEADER returns NIL for assembly routines that have a simple-fun header
;; with 0 as the data value. We should probably ensure that assembly routines
;; referenced by tagged pointers have correct code backpointers.
(defknown fun-code-header (simple-fun) (or code-component null)
  (movable flushable))
(defknown %make-lisp-obj (sb-vm:word) t (movable flushable))
(defknown get-lisp-obj-address (t) sb-vm:word (flushable))

;;;; 32-bit logical operations

(defknown word-logical-not (sb-vm:word) sb-vm:word
  (foldable flushable movable))

(defknown (word-logical-and word-logical-nand
           word-logical-or word-logical-nor
           word-logical-xor word-logical-eqv
           word-logical-andc1 word-logical-andc2
           word-logical-orc1 word-logical-orc2)
          (sb-vm:word sb-vm:word) sb-vm:word
  (foldable flushable movable))

(defknown (shift-towards-start shift-towards-end) (sb-vm:word fixnum)
  sb-vm:word
  (foldable flushable movable))

;;;; bignum operations

(defknown %allocate-bignum (bignum-length) bignum
  (flushable #-bignum-assertions always-translatable))

(defknown %bignum-length (bignum) bignum-length
  (foldable flushable always-translatable))

;;; Change the length of bignum to be newlen. Newlen must be the same or
;;; smaller than the old length, and any elements beyond newlen must be zeroed.
(defknown %bignum-set-length (bignum bignum-length) (values)
  (always-translatable))

(defknown %bignum-ref (bignum bignum-index) bignum-element-type
  (flushable #-bignum-assertions always-translatable))
#+(or x86 x86-64)
(defknown %bignum-ref-with-offset (bignum fixnum (signed-byte 24))
  bignum-element-type (flushable always-translatable))

(defknown (%bignum-set #+bignum-assertions %%bignum-set) (bignum bignum-index bignum-element-type)
  (values)
  (#-bignum-assertions always-translatable))

;;; Return T if digit is positive, or NIL if negative.
(defknown %digit-0-or-plusp (bignum-element-type) boolean
  (foldable flushable movable always-translatable))

;;; %ADD-WITH-CARRY returns a bignum digit and a carry resulting from adding
;;; together a, b, and an incoming carry.
;;; %SUBTRACT-WITH-BOROW returns a bignum digit and a borrow resulting from
;;; subtracting b from a, and subtracting a possible incoming borrow.
(defknown (%add-with-carry %subtract-with-borrow)
          (bignum-element-type bignum-element-type (mod 2))
  (values bignum-element-type (mod 2))
  (foldable flushable movable always-translatable))

;;; This multiplies x-digit and y-digit, producing high and low digits
;;; manifesting the result. Then it adds the low digit, res-digit, and
;;; carry-in-digit. Any carries (note, you still have to add two digits
;;; at a time possibly producing two carries) from adding these three
;;; digits get added to the high digit from the multiply, producing the
;;; next carry digit.  Res-digit is optional since two uses of this
;;; primitive multiplies a single digit bignum by a multiple digit
;;; bignum, and in this situation there is no need for a result buffer
;;; accumulating partial results which is where the res-digit comes
;;; from.
(defknown %multiply-and-add
          (bignum-element-type bignum-element-type bignum-element-type
                               &optional bignum-element-type)
  (values bignum-element-type bignum-element-type)
  (foldable flushable movable always-translatable))

;;; Multiply two digit-size numbers, returning a 2*digit-size result
;;; split into two digit-size quantities.
(defknown %multiply (bignum-element-type bignum-element-type)
  (values bignum-element-type bignum-element-type)
  (foldable flushable movable always-translatable))

(defknown %lognot (bignum-element-type) bignum-element-type
  (foldable flushable movable always-translatable))

(defknown (%logand %logior %logxor) (bignum-element-type bignum-element-type)
  bignum-element-type
  (foldable flushable movable))

(defknown %fixnum-to-digit (fixnum) bignum-element-type
  (foldable flushable movable #-(or arm arm64) always-translatable))

;;; This takes three digits and returns the FLOOR'ed result of
;;; dividing the first two as a 2*digit-size integer by the third.
(defknown %bigfloor (bignum-element-type bignum-element-type bignum-element-type)
  (values bignum-element-type bignum-element-type)
  (foldable flushable movable always-translatable))

;;; Convert the input, a BIGNUM-ELEMENT-TYPE, to a signed word.
;;; FIXME: considering that both the input and output have N-WORD-BITS significant bits,
;;; this is really a bad name for the operation.
(defknown %fixnum-digit-with-correct-sign (bignum-element-type) sb-vm:signed-word
  (foldable flushable movable always-translatable))

;;; %ASHR- take a digit-size quantity and shift it to the left,
;;; returning a digit-size quantity.
;;; %ASHR- Do an arithmetic shift right of data even though bignum-element-type is
;;; unsigned.
(defknown (%ashl %ashr %digit-logical-shift-right)
          (bignum-element-type (mod #.sb-vm:n-word-bits)) bignum-element-type
  (foldable flushable movable always-translatable))

;;;; bit-bashing routines

;;; FIXME: there's some ugly duplication between the (INTERN (FORMAT ...))
;;; magic here and the same magic in src/code/bit-bash.lisp.  I don't know
;;; of any good way to clean it up, but it's definitely violating OAOO.
(macrolet ((define-known-copiers (&aux (pkg (find-package "SB-KERNEL")))
            `(progn
              ,@(loop for i = 1 then (* i 2)
                      collect `(defknown ,(intern (format nil "UB~D-BASH-COPY" i) pkg)
                                ((simple-unboxed-array (*)) index (simple-unboxed-array (*)) index index)
                                (values)
                                ())
                      collect `(defknown ,(intern (format nil "SYSTEM-AREA-UB~D-COPY" i) pkg)
                                (system-area-pointer index system-area-pointer index index)
                                (values)
                                ())
                      collect `(defknown ,(intern (format nil "COPY-UB~D-TO-SYSTEM-AREA" i) pkg)
                                ((simple-unboxed-array (*)) index system-area-pointer index index)
                                (values)
                                ())
                      collect `(defknown ,(intern (format nil "COPY-UB~D-FROM-SYSTEM-AREA" i) pkg)
                                (system-area-pointer index (simple-unboxed-array (*)) index index)
                                (values)
                                ())
                      until (= i sb-vm:n-word-bits)))))
  (define-known-copiers))

;;; (not really a bit-bashing routine, but starting to take over from
;;; bit-bashing routines in byte-sized copies as of sbcl-0.6.12.29:)
(defknown %byte-blt
  ((or (simple-unboxed-array (*)) system-area-pointer) index
   (or (simple-unboxed-array (*)) system-area-pointer) index index)
  (values)
  ())

;;;; code/function/fdefn object manipulation routines

;;; Return a SAP pointing to the instructions part of CODE-OBJ.
(defknown code-instructions (code-component) system-area-pointer (flushable movable))
;;; Extract the INDEXth element from the header of CODE-OBJ. Can be
;;; set with SETF.
(defknown code-header-ref (code-component index) t (flushable))
(defknown code-header-set (code-component index t) (values) ())
;;; Extract a 4-byte element relative to the end of CODE-OBJ.
;;; The index should be strictly negative and a multiple of 4.
(defknown code-trailer-ref (code-component fixnum) (unsigned-byte 32)
  (flushable #-(or sparc ppc64) always-translatable))

(defknown %fun-pointer-widetag (function) (member . #.sb-vm::+function-widetags+)
  (flushable))

(defknown make-fdefn (t) fdefn (flushable movable))
(defknown fdefn-p (t) boolean (movable foldable flushable))
(defknown fdefn-name (fdefn) t (foldable flushable))
(defknown fdefn-fun (fdefn) (or function null) (flushable))
(defknown (setf fdefn-fun) (function fdefn) t ())
(defknown fdefn-makunbound (fdefn) (values) ())
;;; FDEFN -> FUNCTION, trapping if not FBOUNDP
(defknown safe-fdefn-fun (fdefn) function ())

(defknown %simple-fun-type (function) t (flushable))

#+(or x86 x86-64) (defknown sb-vm::%closure-callee (function) fixnum (flushable))
(defknown %closure-fun (function) function (flushable))

(defknown %closure-index-ref (function index) t
  (flushable))

;; T argument is for the 'fun' slot.
(defknown sb-vm::%alloc-closure (index t) function (flushable))

(defknown %fun-fun (function) simple-fun (flushable recursive))

(defknown %make-funcallable-instance (index) function
  ())

(defknown %funcallable-instance-info (function index) t (flushable))
(defknown %set-funcallable-instance-info (function index t) t ())

#+sb-fasteval
(defknown sb-interpreter:fun-proto-fn (interpreted-function)
  sb-interpreter::interpreted-fun-prototype (flushable))


(defknown %data-vector-and-index (array index)
                                 (values (simple-array * (*)) index)
                                 (foldable flushable))

(defknown restart-point (t) t ())

;;; formerly in 'float-tran'

(defknown %single-float (real) single-float (movable foldable))
(defknown %double-float (real) double-float (movable foldable))

(defknown make-single-float ((signed-byte 32)) single-float
  (movable flushable))

(defknown make-double-float ((signed-byte 32) (unsigned-byte 32)) double-float
  (movable flushable))

(defknown single-float-bits (single-float) (signed-byte 32)
  (movable foldable flushable))

#+64-bit
(progn
(defknown %make-double-float ((signed-byte 64)) double-float
  (movable flushable))
(defknown double-float-bits (double-float) (signed-byte 64)
  (movable foldable flushable)))

(defknown double-float-high-bits (double-float) (signed-byte 32)
  (movable foldable flushable))

(defknown double-float-low-bits (double-float) (unsigned-byte 32)
  (movable foldable flushable))

(defknown (%tan %sinh %asinh %atanh %log %logb %log10 %tan-quick)
          (double-float) double-float
  (movable foldable flushable))

(defknown (%sin %cos %tanh %sin-quick %cos-quick)
  (double-float) (double-float $-1.0d0 $1.0d0)
  (movable foldable flushable))

(defknown (%asin %atan)
  (double-float)
  (double-float #.(coerce (sb-xc:- (sb-xc:/ pi 2)) 'double-float)
                #.(coerce (sb-xc:/ pi 2) 'double-float))
  (movable foldable flushable))

(defknown (%acos)
  (double-float) (double-float $0.0d0 #.(coerce pi 'double-float))
  (movable foldable flushable))

(defknown (%cosh)
  (double-float) (double-float $1.0d0)
  (movable foldable flushable))

(defknown (%acosh %exp %sqrt)
  (double-float) (double-float $0.0d0)
  (movable foldable flushable))

(defknown %expm1
  (double-float) (double-float $-1d0)
  (movable foldable flushable))

(defknown (%hypot)
  (double-float double-float) (double-float $0d0)
  (movable foldable flushable))

(defknown (%pow)
  (double-float double-float) double-float
  (movable foldable flushable))

(defknown (%atan2)
  (double-float double-float)
  (double-float #.(coerce (sb-xc:- pi) 'double-float)
                #.(coerce pi 'double-float))
  (movable foldable flushable))

(defknown (%scalb)
  (double-float double-float) double-float
  (movable foldable flushable))

(defknown (%scalbn)
  (double-float (signed-byte 32)) double-float
  (movable foldable flushable))

(defknown (%log1p)
  (double-float) double-float
  (movable foldable flushable))

(defknown (%unary-truncate %unary-round) (real) integer
  (movable foldable flushable))
