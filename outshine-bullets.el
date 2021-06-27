;;; outshine-bullets.el --- Show bullets in outshine-mode as UTF-8 characters

;; Version: 0.3.0
;; Package-Version: 2021.1111
;; Author: Peter 11111000000, sabof, D. Williams
;; 
;; Homepage: https://github.com/11111000000/outshine-bullets

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Show outshine-mode bullets as UTF-8 characters.

;; This is a legacy package maintained with a focus on preservation.
;; It has an unofficial successor package (outshine-superstar).  This means
;; that new features will no longer be added, and backwards
;; compatibility will be preserved.

;; It's unofficial successor package is available on MELPA.  You can
;; also find it on GitHub:
;; https://github.com/integral-dw/outshine-superstar-mode

;;; Code:

(require 'outshine)

(defgroup outshine-bullets nil
  "Display bullets as UTF-8 characters."
  :group 'outshine-appearance)

;; A nice collection of unicode bullets:
;; http://nadeausoftware.com/articles/2007/11/latency_friendly_customized_bullets_using_unicode_characters
(defcustom outshine-bullets-bullet-list
  '(;;; Large
    "►"        
    ;; ♥ ● ◇ ✚ ✜ ☯ ◆ ♠ ♣ ♦ ☢ ❀ ◆ ◖ ▶
    ;;; Small
    ;; ► • ★ ▸
    )
  "List of bullets used in Org headings.
It can contain any number of symbols, which will be repeated."
  :group 'outshine-bullets
  :type '(repeat (string :tag "Bullet character")))

(defcustom outshine-bullets-face-name nil
  "Face used for bullets in Org mode headings.
If set to the name of a face, that face is used.
Otherwise the face of the heading level is used."
  :group 'outshine-bullets
  :type 'symbol)

(defvar outshine-bullets-bullet-map (make-sparse-keymap))

(defun outshine-bullets-level-char (level)
  "Return the desired bullet for the given heading LEVEL."
  (string-to-char
   (nth (mod (/ (1- level) 1)
             (length outshine-bullets-bullet-list))
        outshine-bullets-bullet-list)))

(defvar outshine-bullets--keywords
  `(("^\\(;;\\|//\\)[ ]?\\([;]+\\|[*]+\\) "
     (0 (let* ((level (- (match-end 2) (match-beginning 2) 0)))
          (compose-region (- (match-end 0) 2)
                          (- (match-end 0) 1)
                          (outshine-bullets-level-char level))
          
          ;; (when (facep outshine-bullets-face-name)
          ;;   (put-text-property (- (match-end 0)
          ;;                         (if is-inline-task 3 2))
          ;;                      (- (match-end 0) 1)
          ;;                      'face
          ;;                      outshine-bullets-face-name))
          (put-text-property (match-beginning 0)
                             (- (match-end 0) 2)
                             'face 'org-hide)
          ;; (put-text-property (match-beginning 0)
          ;;                    (match-end 0)
          ;;                    'keymap
          ;;                    outshine-bullets-bullet-map)
          nil)))

    ("^\\(;;\\|//\\)[ ][^*]"
     (0 (let* ()                             
          (put-text-property (match-beginning 1)
                             (match-end 1)
                             'face 'org-hide)          
          nil)))
    ))

;;;###autoload
(define-minor-mode outshine-bullets-mode
  "Use UTF8 bullets in Org mode headings."
  nil nil nil
  (if outshine-bullets-mode
      (progn
        (font-lock-add-keywords nil outshine-bullets--keywords)
        (outshine-bullets--fontify-buffer))
    (save-excursion
      (goto-char (point-min))
      (font-lock-remove-keywords nil outshine-bullets--keywords)
      (while (re-search-forward "^\\(;;\\|//\\)\\(;+\\|\s-\\*+\\)\\?\s-" nil t)
        (decompose-region (match-beginning 0) (match-end 0)))
      (outshine-bullets--fontify-buffer))))

(defun outshine-bullets--fontify-buffer ()
  "Fontify the current buffer."
  (when font-lock-mode
    (if (and (fboundp 'font-lock-flush)
             (fboundp 'font-lock-ensure))
        (save-restriction
          (widen)
          (font-lock-flush)
          (font-lock-ensure))
      (with-no-warnings
        (font-lock-fontify-buffer)))))

(provide 'outshine-bullets)
;; Local Variables:
;; indent-tabs-mode: nil
;; End:
;;; outshine-bullets.el ends here
