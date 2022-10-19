;;;; Find out the FASL version of this SBCL release and dump it to the
;;;; debian/sbcl.substvars variable, so it can be used in
;;;; debian/control
;;;;
;;;; Packages that want to provide binary SBCL FASLs can then depend
;;;; on sbcl-fasl-XX
;;;;
;;;;  -- René van Bevern <rvb@pro-linux.de>, Sat Sep  3 19:23:20 2005

(with-open-file (substvars "debian/sbcl.substvars"
                           :direction :output
                           :if-exists :append
                           :if-does-not-exist :create)
  (format substvars "~&sbcl:fasl-version=sbcl-fasl-loader-~A~%"
          sb-fasl:+fasl-file-version+))

(sb-ext:quit)

