;;; yafastnav-for-info.el --- yet another fastnav.

;; Copyright (C) 2010 tm8st

;; Author: tm8st <http://twitter.com/tm8st>
;; 注意 @mori_dev(mori.dev.asdf@gmail.com) が改変しています。ここの書き方不明です。
;; Version: 0.1
;; Keywords: convenience, move, fastnav

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

;; GNU General Public License for more details.

;; You should have received a  copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.	If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;  yafastnav.el を以下のように改変しました(@mori_dev)。
;;  o infoのリンクだけを候補とする
;;  o 位置指定のアルファベットや数字を押下することでリンク先へ遷移

;; 設定例

;; (require 'yafastnav-for-info)

;; (add-hook 'Info-mode-hook
;;   (lambda ()
;;      (define-key Info-mode-map "e" 'yafastnav-info-jump-to-current-screen)))

;; e を外した
;; (setq yafastnav-info-shortcut-keys
;;      '(
;;        ?a ?s ?d ?f ?g ?h ?k ?l
;;        ?q ?w ?r ?t ?y ?u ?i ?o ?p
;;        ?z ?x ?c ?v ?b ?n ?m
;;        ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9 ?0
;;        ?, ?. ?: ?- ?^ ?;
;;        ?A ?S ?D ?F ?G ?H ?K ?L
;;        ?Q ?W ?E ?R ?T ?Y ?U ?I ?O ?P
;;        ?Z ?X ?C ?V ?B ?N ?M
;;        ?< ?> ?@ ?\* ?\[ ?\]
;;        ?\\ ?\  ?' ?( ?) ?=
;;        ?~ ?| ?{ ?} ?\_
;;        ?! ?\" ?# ?$ ?% ?&
;;        ))

;;; Code:

;;;-------------------------------
;;; variables
;;;-------------------------------
(defgroup yafastnav nil "yet another fastnav."
  :prefix "yafastnav-info-" :group 'convenience)

(defcustom yafastnav-info-regex
  "\\([一-龠ぁ-んァ-ヶｦ-ﾟー0-9a-zA-Z_?]+[一-龠ぁ-んァ-ヶｦ-ﾟーa-zA-Z0-9_-]+\\)"
  "リストアップする要素の指定用正規表現"
  :type 'regexp
  :group 'yafastnav)

(defcustom yafastnav-info-shortcut-keys
     '(
       ?a ?s ?d ?f ?g ?h ?k ?l
       ?q ?w ?e ?r ?t ?y ?u ?i ?o ?p
       ?z ?x ?c ?v ?b ?n ?m
       ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9 ?0
       ?, ?. ?: ?- ?^ ?;
       ?A ?S ?D ?F ?G ?H ?K ?L
       ?Q ?W ?E ?R ?T ?Y ?U ?I ?O ?P
       ?Z ?X ?C ?V ?B ?N ?M
       ?< ?> ?@ ?\* ?\[ ?\]
       ?\\ ?\  ?' ?( ?) ?=
       ?~ ?| ?{ ?} ?\_
       ?! ?\" ?# ?$ ?% ?&
       )
     "要素の選択用ショートカットキーリスト"
     :type 'string
     :group 'yafastnav)

(defface yafastnav-info-shortcut-key-face-type
  '((((class color)) (:foreground "LightPink" :background "gray15"))
    (t ()))
  "ショートカットキーの表示用フェース型"
  :group 'yafastnav
  )

(defcustom yafastnav-info-shortcut-key-face 'yafastnav-info-shortcut-key-face-type
  "ショートカットキーの表示用フェース"
  :type 'face
  :group 'yafastnav
  )

;;;-------------------------------
;;; functions 
;;;-------------------------------
(defun yafastnav-info-jump-to-current-screen ()
  "現在の画面内の候補へのジャンプ"
  (interactive)
  (let ((top) (bottom))
    (save-excursion
      (move-to-window-line -1)
      (setq bottom (point))
      (move-to-window-line 0)
      (setq top (point)))
    (yafastnav-info-jump-to-between-point top bottom nil)))

(defun yafastnav-info-jump-to-forward ()
  "現在の画面内のカーソル位置の下の候補へのジャンプ"
  (interactive)
  (let ((top) (bottom))
    (save-excursion
      (setq top (point))
      (move-to-window-line -1)
      (setq bottom (point)))
    (yafastnav-info-jump-to-between-point top bottom nil)))

(defun yafastnav-info-jump-to-backward ()
  "現在の画面内のカーソル位置の上の候補へのジャンプ"
  (interactive)
  (let ((top) (bottom))
    (save-excursion
      (setq bottom (point))
      (move-to-window-line 0)
      (setq top (point)))
    (yafastnav-info-jump-to-between-point top bottom nil)))

(defun yafastnav-info-jump-to-between-point (top bottom backward)
  "候補の作成とジャンプの実行"
  (let ((ret)
        (ls nil)
        (ols nil)
        (index 0)
        (start-pos (point)))
    (save-excursion
      (setq inhibit-quit t) ;; C-g で中断されないように
      (goto-char top)
      (while (and
              (if backward
                  (re-search-backward yafastnav-info-regex bottom 1)
                (re-search-forward yafastnav-info-regex bottom 1))
              (nth index yafastnav-info-shortcut-keys)

              (if backward
                  (>= (point) bottom)
                (<= (point) bottom)))
        (save-excursion
          (goto-char (match-beginning 0))
            ;;追加
            (when (and (or
                        (get-text-property (point) 'face)
                        (get-text-property (point) 'face))
                       (or
                        (face-equal 'info-xref-visited (get-text-property (point) 'face))
                        (face-equal 'info-xref (get-text-property (point) 'face))
                        (face-equal 'info-header-xref (get-text-property (point) 'face))))
              (add-to-list 'ls
                           (list
                            (nth index yafastnav-info-shortcut-keys)
                            (point)))
              (let ((ov (make-overlay (point) (1+ (point)))))
                (overlay-put ov 'before-string
                             (propertize
                              (char-to-string
                               (nth index yafastnav-info-shortcut-keys))
                              'face yafastnav-info-shortcut-key-face))
                (overlay-put ov 'window (selected-window))
                (overlay-put ov 'width 1)
                (overlay-put ov 'priority 100)
                (add-to-list 'ols ov))
              (setq index (1+ index)))))
      (goto-char start-pos)
      (when (> index 0)
        (setq ret (assoc (read-event "jump to?:") ls))
        nil))
    (if ret
        (progn
         (goto-char (nth 1 ret))
         (Info-follow-nearest-node)  ;追加
         )
      (message "none candidate."))
    (dolist (o ols)
      (delete-overlay o))))
  
(provide 'yafastnav-for-info)
