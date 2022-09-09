;;; This shows an example echo server that writes everything it receives on port
;;; 5000 back to the connected client. A ctrl-c exits the server.

(ql:quickload :cl-async)

(defun echo-server ()
  (as:tcp-server nil 5000
    (lambda (sock data)
      ;; echo data back to client
      (as:write-socket-data sock data))
    :event-cb
    (lambda (ev)
      (format t "ev: ~a~%" ev)))
  (as:signal-handler as:+sigint+
    (lambda (sig)
      (declare (ignore sig))
      (as:exit-event-loop))))

;; To make this example self sufficient on CI
(let* ((sh (format NIL
                   "set -euo pipefail -x
                   sleep 1
                   echo \"Hi, you are $PPID\" | nc localhost 5000
                   kill -INT $PPID"))
       (proc (uiop:launch-program `("bash" "-c" ,sh)
                                  :output :interactive
                                  :error-output :interactive)))
  (as:start-event-loop #'echo-server)
  (uiop:quit (uiop:wait-process proc)))
