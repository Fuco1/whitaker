;;; whitaker.el --- Comint interface for Whitaker's Words

;; Copyright (C) 2014 Matus Goljer

;; Author: Matus Goljer <matus.goljer@gmail.com>
;; Maintainer: Matus Goljer <matus.goljer@gmail.com>
;; Keywords: processes
;; Version: 0.0.2
;; Created: 12th March 2014

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

(require 'dash)
(require 'better-jump)

(require 'comint)
(require 'ring)

(defgroup whitaker ()
  "Comint interface for Whitaker's words."
  :prefix "whitaker-")

(defcustom whitaker-program "words"
  "A shell command that runs Whitaker's words.

The author runs a version compiled for windows with command
  (cd /path/to/words/directory && wine words.exe)

However, the program is free software and you can compile a
version for linux or any other system where ADA compiler is
available."
  :type 'string
  :group 'whitaker)

(defcustom whitaker-buffer-name "*Whitaker*"
  "The name of the buffer where words process runs."
  :type 'string
  :group 'whitaker)

(defvar whitaker-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-e") 'whitaker-switch-to-english)
    (define-key map (kbd "C-c C-l") 'whitaker-switch-to-latin)
    map)
  "Map for whitaker-words.")


;;; interactive

(defun whitaker-switch-to-latin ()
  "Switch to latin-to-english search."
  (interactive)
  (--when-let (get-buffer whitaker-buffer-name)
    (insert "~L")
    (comint-send-input)
    (ring-remove comint-input-ring 0)))

(defun whitaker-switch-to-english ()
  "Switch to english-to-latin search."
  (interactive)
  (--when-let (get-buffer whitaker-buffer-name)
    (insert "~E")
    (comint-send-input)
    (ring-remove comint-input-ring 0)))


;;;###autoload
(defun whitaker (&optional no-select)
  "Start a new whitaker process if it doesn't already exist.

When the process is started, pop to the associated buffer.

If optional argument NO-SELECT is non-nil, only display the
buffer."
  (interactive)
  (let ((buffer (get-buffer-create whitaker-buffer-name)))
    (if no-select
        (display-buffer buffer)
      (pop-to-buffer buffer))
    (with-current-buffer buffer
      (unless (comint-check-proc buffer)
        (let* ((prog (or explicit-shell-file-name
                         shell-file-name)))
          (make-comint-in-buffer "whitaker"
                                 buffer
                                 prog
                                 nil
                                 "-c"
                                 whitaker-program)
          (whitaker-mode))))))

;;;###autoload
(defun whitaker-send-input (word-or-region)
  "Send the WORD under point to the whitaker comint buffer.

If a region is active and `use-region-p' returns non-nil, the
active region is sent instead.

This buffer is recognized by searching for buffer with name
`whitaker-buffer-name'."
  (interactive (list (if (use-region-p)
                         (buffer-substring-no-properties (region-beginning) (region-end))
                       (word-at-point))))
  (-if-let (buffer (get-buffer whitaker-buffer-name))
      (with-current-buffer buffer
        (display-buffer buffer nil t)
        (comint-goto-process-mark)
        (insert word-or-region)
        (comint-send-input))
    (whitaker t)
    (whitaker-send-input word-or-region)))

;;;###autoload
(defun whitaker-jump (char)
  "Jump to location by using `better-jump', then send the word
under point to whitaker buffer."
  (interactive "cHead char: ")
  (bjump-jump char
              :action (bjump-com-at-char-execute
                       (lambda ()
                         (whitaker-send-input (word-at-point))))))


;;; whitaker comint mode
(defun whitaker--watch-for-more-input (original)
  "If we are prompted with

  MORE - hit RETURN/ENTER to continue

automatically send a return to the process and remove the empty lines."
  (when (looking-back "MORE - hit RETURN/ENTER to continue\n")
    (comint-send-input))
  (save-excursion
    (goto-char comint-last-input-start)
    (when (looking-back "MORE - hit RETURN/ENTER to continue\n")
      (delete-char -1)
      (beginning-of-line)
      (kill-line 3)
      (delete-char -1))))

(define-derived-mode whitaker-mode comint-mode "Whitaker-Words"
  "Major mode for the whitaker comint buffer."
  (setq comint-prompt-regexp "=>")
  (setq comint-process-echoes t)
  (use-local-map whitaker-mode-map)
  (add-hook 'comint-output-filter-functions 'whitaker--watch-for-more-input nil t))

(provide 'whitaker)

;;; whitaker.el ends here
