;;; qrcode.el --- qrcode for Emacs -*- lexical-binding: t; -*-

;; Copyright (C) 2014 by Syohei YOSHIDA

;; Author: Syohei YOSHIDA <syohex@gmail.com>
;; URL: https://github.com/syohex/
;; Version: 0.01
;; Package-Requires: ((emacs "24") (cl-lib "0.5"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; Code:

(require 'cl-lib)

(defvar qrcode--program
  (concat (if load-file-name
              (file-name-directory load-file-name)
            default-directory) "qrcode.go"))

(defun qrcode--convert-output (proc-buf)
  (with-current-buffer proc-buf
    (cl-loop initially (goto-char (point-min))
             with black = (propertize "  " 'face '((:background "black")))
             with white = (propertize "  " 'face '((:background "white")))
             while (not (eobp))
             for line = (buffer-substring-no-properties
                         (line-beginning-position) (line-end-position))
             collect
             (cl-loop for c across line
                      if (= c ?1)
                      collect black
                      else
                      collect white) into colors
             do
             (forward-line 1)

             finally return colors)))

(defun qrcode--start-process (text)
  (let* ((proc-buf (get-buffer-create " *qrcode-proc*"))
         (qr-buf (get-buffer-create "*qrcode*"))
         (process (start-process "qrcode" proc-buf "go" "run" qrcode--program text)))
    (with-current-buffer qr-buf
      (setq buffer-read-only nil)
      (erase-buffer))
    (set-process-sentinel
     process
     (lambda (proc _event)
       (when (eq (process-status proc) 'exit)
         (let ((color-lines (qrcode--convert-output proc-buf)))
           (kill-buffer proc-buf)
           (with-current-buffer qr-buf
             (cl-loop for line in color-lines
                      do
                      (cl-loop for color in line
                               do
                               (insert color)
                               finally
                               (insert "\n")))
             (goto-char (point-min))
             (setq buffer-read-only t)
             (pop-to-buffer (current-buffer)))))))))

;;;###autoload
(defun qrcode-region (start end)
  (interactive "r")
  (qrcode (buffer-substring-no-properties start end)))

;;;###autoload
(defun qrcode (text)
  (interactive
   (list (read-string "QRCode Text: ")))
  (when (string= text "")
    (error "Error input text is empty string"))
  (qrcode--start-process text))

(provide 'qrcode)

;;; qrcode.el ends here
