(require 's)

(defgroup dired-filter ()
  "Ibuffer-like filtering for dired."
  :group 'processes
  :prefix "dired-filter-")

(defgroup whitaker ()
  "Comint interface to Whitaker's words."
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


;;; interactive

;;;###autoload
(defun whitaker (&optional no-select)
  "Docs"
  (interactive)
  (let ((buffer (get-buffer-create whitaker-buffer-name)))
    (if no-select
        (display-buffer buffer)
      (pop-to-buffer buffer))
    (with-current-buffer buffer
      (unless (comint-check-proc buffer)
        (let* ((prog (or explicit-shell-file-name
                         (getenv "ESHELL")
                         shell-file-name)))
          (make-comint-in-buffer "whitaker"
                                 buffer
                                 prog
                                 nil
                                 "-c"
                                 whitaker-program)
          (whitaker-mode))))))

;;;###autoload
(defun whitaker-send-word (word)
  "Docs"
  (interactive (list (word-at-point)))
  (-if-let (buffer (get-buffer whitaker-buffer-name))
      (with-current-buffer buffer
        (display-buffer buffer nil t)
        (comint-goto-process-mark)
        (insert word)
        (comint-send-input))
    (whitaker t)
    (whitaker-send-word word)))


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
  "Docs"
  (setq comint-prompt-regexp "=>")
  (setq comint-prompt-echoes t)
  (add-hook 'comint-output-filter-functions 'whitaker--watch-for-more-input nil t))

(provide 'whitaker)
