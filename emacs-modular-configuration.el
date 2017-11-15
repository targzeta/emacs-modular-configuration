;;; emacs-modular-configuration.el --- making modular your config file
;;
;; Copyright (C) 2014 Emanuele Tomasi <targzeta@gmail.com>
;;
;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.
;;
;; This file is NOT part of GNU Emacs.
;;
;; Author: Emanuele Tomasi <targzeta@gmail.com>
;; Version: 1.0
;; URL: https://github.com/targzeta/emacs-modular-configuration
;; Maintainer: Emanuele Tomasi <targzeta@gmail.com>
;; Keywords: modular, config
;;
;;; Commentary:
;;
;; Emacs Modular Configuration lets you split your emacs configuration within
;; of a (configurable) "~/.emacs.d/config" directory. When you're ready,
;; simply call `emc-merge-config-files' and all the ".el" files under that
;; directory tree will merge on a (configurable) "~/.emacs.d/config.el".
;; Lastly, this file will be byte compiled, so all you need to write on your
;; Emacs initalization file (e.g. "~/.emacs" or "~/.emacs.d/init.el") is:
;;
;; (load "~/.emacs.d/config")
;;
;; Note: the directory tree ~/.emacs.d/config will be visited recursively using
;; the BFS algorithm and in alphabetical order.
;;
;;; Installation:
;;
;; Copy this file in a directory which is in the Emacs `load-path', so add this
;; to your Emacs initalization file (e.g. "~/.emacs" or "~/.emacs.d/init.el"):
;; (require 'modular-configuration)
;; (load ~/.emacs.d/config t)
;;
;;; Usage:
;;
;; Write a bit of ".el" files within "~/.emacs.d/config" directory tree and
;; then run M-x emc-merge-config-files.
;;
;; Next time you start Emacs, you'll load the "~/.emacs.d/config.elc" file.
;; That's all.
;;
;; Customization:
;;
;; M-x customize-group and then "modular-configuration"
;;
;;; Code:

;; Definitions
(defgroup add-ons nil
  "External add-ons."
  :group 'emacs)

(defgroup modular-configuration nil
  "Making modular your config file."
  :group 'add-ons
  :version "1.0"
  :prefix "emc")

(defvar emc-version "1.0")

;; Customization
(defcustom emc-config-directory "~/.emacs.d/config"
  "Directory tree that contains all your configuration files."
  :type 'directory
  :group 'modular-configuration)

(defcustom emc-config-file "~/.emacs.d/config.el"
  "File where all your configuration files will be merged."
  :type 'file
  :group 'modular-configuration)

;; Functions
(defun emc-recursive-directory (directory function)
  "Execute FUNCTION for every files under DIRECTORY tree."
  (let (dirs-list (list))
    (dolist (element (directory-files-and-attributes directory))
      (let* ((path (car element))
             (fullpath (concat directory "/" path))
             (isdir (car (cdr element)))
             (ignore-dir (or (string= path ".") (string= path ".."))))
        (cond
         ((and (eq isdir t) (not ignore-dir))
          (push fullpath dirs-list))
         ((eq isdir nil)
          (funcall function fullpath)))))
    (dolist (dir dirs-list)
      (emc-recursive-directory dir function))))

;;;###autoload
(defun emc-merge-config-files ()
  "Merge all `.el' files under `emc-config-directory' on `emc-config-file'.
Whereupon, the `emc-config-file' will also byte-compiled"
  (interactive)
  (let ((files_list)
        (header (concat
                 ";; -*- eval: (read-only-mode 1) -*-\n\n"
                 ";; " emc-config-file " -- Emacs configurations\n\n"
                 ";; Generated by Emacs Modular Configuration version "
                 emc-version "\n"
                 ";; DO NOT EDIT THIS FILE.\n"
                 ";; Edit the files under '" emc-config-directory
                 "' directory tree,\n"
                 ";; then run within emacs"
                 " 'M-x emc-merge-config-files'\n\n"))
        (footer (concat
                 ";; " emc-config-file " ends here"))
        (separator (concat ";; " (make-string 76 ?#))))

    (emc-recursive-directory emc-config-directory
                             (lambda (filename)
                               (if (string= (substring filename -3) ".el")
                                   (push filename files_list))))
    (with-temp-buffer
      (insert header)
      (dolist (filename (reverse files_list))
        (message "%s" (concat "[emc] Merging " filename))
        (insert (concat separator "\n;; Config file: " filename "\n"))
        (insert-file-contents filename)
        (goto-char (point-max))
        (insert (concat separator "\n\n\n")))
      (insert footer)
      (write-file emc-config-file))
    (byte-compile-file emc-config-file)))

(provide 'emacs-modular-configuration)

;;; emacs-modular-configuration.el ends here
