;;;; linkage information for standard static functions, and random vops

;;;; This software is part of the SBCL system. See the README file for
;;;; more information.
;;;;
;;;; This software is derived from the CMU CL system, which was
;;;; written at Carnegie Mellon University and released into the
;;;; public domain. The software is in the public domain and is
;;;; provided with absolutely no warranty. See the COPYING and CREDITS
;;;; files for more information.

(in-package "SB-VM")

;;;; LENGTH
(define-vop (length/list)
  (:translate length)
  (:args (object :scs (descriptor-reg) :target ptr))
  (:arg-types list)
  (:temporary (:scs (descriptor-reg) :from (:argument 0)) ptr)
  (:temporary (:scs (non-descriptor-reg)) temp)
  (:temporary (:scs (any-reg) :to (:result 0) :target result)
              count)
  (:results (result :scs (any-reg descriptor-reg)))
  (:policy :fast-safe)
  (:vop-var vop)
  (:save-p :compute-only)
  (:generator 50
    (let ((done (gen-label))
          (loop (gen-label))
          (not-list (generate-error-code vop 'object-not-list-error ptr)))
      (move ptr object)

      (inst cmp ptr null-tn)
      (inst b :eq done)
      (move count zero-tn)

      (emit-label loop)

      (test-type ptr temp not-list t (list-pointer-lowtag))

      (loadw ptr ptr cons-cdr-slot list-pointer-lowtag)

      (inst cmp ptr null-tn)
      (inst b :ne loop)
      (inst add count count (fixnumize 1))

      (emit-label done)
      (move result count))))
