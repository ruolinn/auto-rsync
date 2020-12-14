;;; auto-rsync/auto-rsync.el -*- lexical-binding: t; -*-

;;
;; Author: @l3msh0
;;

;;; Example
;;
;; (require 'auto-rsync)
;; (auto-rsync-mode t)
;; (setq auto-rsync-dir-alist
;;       (("/path/to/src1/" . "/path/to/dest1/")
;;        ("/path/to/src2/" . "username@hostname:/path/to/dest2/")))


;;; Customize
;;
(defgroup auto-rsync nil "Auto rsync")
(defcustom auto-rsync-command "rsync" "rsync command path" :group 'auto-rsync)
(defcustom auto-rsync-command-option "-avzq" "rsync command option" :group 'auto-rsync)


;;; TODO
;;
;; open remote counterpart
;;

(defvar auto-rsync-dir-alist nil "Pair of rsync source and destination dir")
(defvar auto-rsync-normalized-alist nil)

;;; Code

(defun auto-rsync-exec-rsync (name)
  "execute rsync if editing file path matches src dir"
  (interactive "sEnter project name: ")

  (let* ((normalized-alist (mapcar (lambda (x) (cons (file-name-as-directory (expand-file-name (car x)))
                                                     (file-name-as-directory (cdr x))))
                                   auto-rsync-dir-alist))
         ;;(sync-pair (assoc-if (lambda (key) (string-match key buffer-file-name)) normalized-alist)))
         (sync-pair (cl-assoc-if (lambda (key) (string-match-p name key)) normalized-alist)))
    (or sync-pair
        (message "project %s not exists" name)
        (message "%s" (car sync-pair))
        )
    (when sync-pair
      (save-window-excursion
        ;; avoid annoying shell comannd window
        (shell-command (format "%s %s %s %s&" auto-rsync-command auto-rsync-command-option (car sync-pair) (cdr sync-pair)) nil)))))

(defun auto-rsync-exec-rsync-file ()
  "execute rsync if editing file path matches src dir"
  (interactive)

  (let* ((normalized-alist (mapcar (lambda (x) (cons (file-name-as-directory (expand-file-name (car x)))
                                                     (file-name-as-directory (cdr x))))
                                   auto-rsync-dir-alist))
         (sync-pair (cl-assoc-if (lambda (key) (string-match key buffer-file-name)) normalized-alist)))
    (when sync-pair
      (let* ((file (substring buffer-file-name (length (car sync-pair))))
             (local (concat (car sync-pair) file))
             (remote (concat (cdr sync-pair) file)))
        (save-window-excursion
          ;; avoid annoying shell comannd window
          (shell-command (format "%s %s %s %s&" auto-rsync-command auto-rsync-command-option local remote) nil))
        ))))

(define-minor-mode auto-rsync-mode
  "automatically execute rsync when editing file's path matches `auto-rsync-dir-alist`"
  :lighter " rsync"
  ;:global t
  (cond (auto-rsync-mode
         (add-hook 'after-save-hook 'auto-rsync-exec-rsync-file))
        (t
         (remove-hook 'after-save-hook 'auto-rsync-exec-rsync-file))))

(provide 'auto-rsync)
