;;; emacs-modular-configuration.el --- making modular your config file
;;
;; Copyright (C) 2014-2017 Emanuele Tomasi <targzeta@gmail.com>
;;
;; Author: Emanuele Tomasi <targzeta@gmail.com>
;; URL: https://github.com/targzeta/emacs-modular-configuration
;; Maintainer: Emanuele Tomasi <targzeta@gmail.com>
;; Keywords: modular, config
;; Version: 2.0
;;
;; This file is NOT part of GNU Emacs.
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
;;; Commentary:
;;
;; Emacs Modular Configuration lets you split your Emacs configuration within
;; of a (configurable) "~/.config/emacs/emc/config" directory. When you're ready,
;; simply call `emc-merge-config-files' and all the ".el" files under that
;; directory tree will merge on a (configurable)
;; "~/.config/emacs/emc/emc-config.el".  Lastly, this file will be byte compiled, so
;; all you need to write on your Emacs initalization file (e.g. "~/.emacs" or
;; "~/.config/emacs/init.el") is:
;;
;; (load "~/.config/emacs/emc/emc-config")
;;
;; Note: the directory tree ~/.config/emacs/emc/config will be visited recursively
;; using the BFS algorithm and in alphabetical order.
;;
;;; Installation:
;;
;; Copy this file in a directory which is in the Emacs `load-path', so add this
;; to your Emacs initalization file (e.g. "~/.emacs" or "~/.config/emacs/init.el"):
;; (require 'emacs-modular-configuration)
;; (load ~/.config/emacs/emc/emc-config t)
;;
;;; Usage:
;;
;; Write a bit of ".el" files within "~/.config/emacs/emc/config" directory tree and
;; then run M-x emc-merge-config-files.
;;
;; Next time you start Emacs, you'll load the "~/.config/emacs/emc/emc-config.elc"
;; file. That's all.
;;
;; Customization:
;;
;; M-x customize-group and then "modular-configuration"
;;
;;; Code:
(require 'cl-lib)

;; Definitions
(defgroup add-ons nil
  "External add-ons."
  :group 'emacs)

(defgroup modular-configuration nil
  "Making modular your config file."
  :group 'add-ons
  :version "2.0"
  :prefix "emc")

(defvar emc-version "2.0")

;; Customization
(defcustom emc-config-directory "~/.config/emacs/emc/config"
  "Directory tree that contains all your configuration files."
  :type 'directory
  :group 'modular-configuration)

(defcustom emc-config-file "~/.config/emacs/emc/emc-config.el"
  "File where all your configuration files will be merged."
  :type 'file
  :group 'modular-configuration)

;; Functions
(defun emc-recursive-directory (nodes function)
  "Executes FUNCTION for every '.el' file under the DIRECTORY tree.

The DIRECTORY will be visited recursively using the Breadth First
algorithm with every level in alphabetical order.

\n(fn DIRECTORY FUNCTION)"
  (unless (listp nodes) (setq nodes (list nodes)))
  (let ((directory (pop nodes)))
    (when directory
      (dolist (element (directory-files-and-attributes directory))
        (let* ((path (car element))
               (fullpath (concat directory path))
               (isdir (car (cdr element)))
               (ignore-dir (or (string= path ".") (string= path ".."))))
          (cond
           ((and (eq isdir t) (not ignore-dir))
            (push (file-name-as-directory fullpath) nodes))
           ((and (string= (file-name-extension path) "el") (not (eq isdir t)))
            (funcall function fullpath)))))
      (emc-recursive-directory (reverse nodes) function))))

(defun emc--merge-file (filename)
  (message (format "[emc] Merging %s" filename))
  (insert (format "\n;;; Config file: %s\n" filename))
  (insert-file-contents filename)
  (goto-char (point-max))
  (insert ";;;***\n"))

(defun emc--merge-files-and-compile (src-dir dest-file header footer)
  (with-temp-file dest-file
    (insert header)
    (emc-recursive-directory (file-name-as-directory src-dir) 'emc--merge-file)
    (insert footer))
  (byte-compile-file dest-file))

;;;###autoload
(cl-defun emc-merge-config-files ()
  "Merges all `.el' files under `emc-config-directory' on `emc-config-file'.
Whereupon, the `emc-config-file' will also byte-compiled"
  (interactive)
  (unless (file-exists-p emc-config-directory)
    (message (format "[emc] %s not found. Nothing to do!"
                     emc-config-directory))
    (cl-return-from emc-merge-config-files))

  ; Ensuring destination directory
  (mkdir (file-name-directory emc-config-file) t)

  (message (format "[emc] Config file will merge into %s" emc-config-file))
  (let ((header (concat
                 ";; -*- eval: (read-only-mode 1) -*-\n\n"
                 ";;; " emc-config-file " -- Emacs configurations\n\n"
                 ";; Generated by Emacs Modular Configuration version "
                 emc-version "\n"
                 ";; DO NOT EDIT THIS FILE.\n"
                 ";; Edit the files under '" emc-config-directory
                 "' directory tree,\n"
                 ";; then run within emacs"
                 " 'M-x emc-merge-config-files'\n\n"
                 ";;; Code:\n\n"))
        (footer (format ";;; %s ends here" emc-config-file)))

    (emc--merge-files-and-compile emc-config-directory emc-config-file
                                  header footer)))

(provide 'emacs-modular-configuration)

;;; emacs-modular-configuration.el ends here
