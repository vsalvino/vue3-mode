;;; vue3-mode.el --- Syntax highlighting for modern Vue.js 3 -*- lexical-binding: t; -*-

;; Copyright (C) 2023, Vince Salvino

;; Author: Vince Salvino <mvsalvino@gmail.com>
;; Keywords: languages, vue
;; Package-Requires: ((polymode) (vue-html-mode))
;; URL: https://github.com/vsalvino/vue3-mode
;; Version: 1.0

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

;; Vue.js syntax highlighting for Emacs. Inspired by `vue-mode' with
;; support for Vue 3 syntax, based on `polymode' which provides more
;; accurate syntax highlighting and parsing.

;;; Code:

(require 'polymode)
(require 'vue-html-mode)

(defvar vue3-initialized nil
  "If false, `vue3-mode' still needs to prepare `polymode' before being activated.")

(defconst vue3--not-lang-key
  (concat
   "\\(?:"
   "\\w*[^l]\\w\\w\\w=" ; Anything not starting with a lowercase l, or
   "\\|"
   "\\w*[^a]\\w\\w=" ; Anything without a in the second position, or
   "\\|"
   "\\w*[^n]\\w=" ; Anything without n in the third position, or
   "\\|"
   "\\w*[^g]=" ; Anything not ending with g, or
   "\\|"
   "g=" ; Just g, or
   "\\|"
   "\\w\\{5,\\}=" ; A 5+-character word
   "\\)")
  "Matches anything but 'lang'. See `vue3--tag-nolang-regex'.")

(defconst vue3--tag-lang-regex
  (concat "<%s"                               ; The tag name
          "\\(?:"                             ; Zero of more of...
          "\\(?:\\s-+\\w+=[\"'].*?[\"']\\)"   ; Any optional key-value pairs like type="foo/bar"
          "\\|\\(?:\\s-\\w++\\)"              ; Any optional key-only attribute
          "\\)*"
          "\\(?:\\s-+lang=[\"']%s[\"']\\)"    ; The language specifier (required)
          "\\(?:"                             ; Zero of more of...
          "\\(?:\\s-+\\w+=[\"'].*?[\"']\\)"   ; Any optional key-value pairs like type="foo/bar"
          "\\|\\(?:\\s-+\\w+\\)"              ; Any optional key-only attribute
          "\\)*"
          " *>\n")                            ; The end of the tag
  "A regular expression for the starting tags of template areas with languages.
To be formatted with the tag name, and the language.")

(defconst vue3--tag-nolang-regex
  (concat "<%s"                        ; The tag name
          "\\(?:"                      ; Zero of more of...
          "\\(?:\\s-+" vue3--not-lang-key "[\"'][^\"']*?[\"']\\)" ; Any optional key-value pairs like type="foo/bar".
          ;; ^ Disallow "lang" in k/v pairs to avoid matching regions with non-default languages
          "\\|\\(?:\\s-+\\w+\\)"       ; Any optional key-only attribute
          "\\)*"
          "\\s-*>\n")                  ; The end of the tag
  "A regular expression for the starting tags of template areas.
To be formatted with the tag name.")

(defun vue3--setup ()
  "Add hooks to plymode for doing multiple major modes in a .vue file."
  ;; Default mode is vue-html-mode. So we don't need to explictly
  ;; create innermodes for most <template> tags.
  (define-hostmode poly-vue3-hostmode
    :mode 'vue-html-mode)
  ;; <i18n> without lang specified.
  (define-innermode vue3-i18n-innermode
    :mode 'json-mode
    :head-matcher (format vue3--tag-nolang-regex "i18n")
    :tail-matcher "</i18n *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <i18n lang="json">
  (define-innermode vue3-i18n-json-innermode
    :mode 'json-mode
    :head-matcher (format vue3--tag-lang-regex "i18n" "json")
    :tail-matcher "</i18n *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <i18n lang="yaml">
  (define-innermode vue3-i18n-yaml-innermode
    :mode 'yaml-mode
    :head-matcher (format vue3--tag-lang-regex "i18n" "yaml")
    :tail-matcher "</i18n *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script> without lang specified.
  (define-innermode vue3-script-innermode
    :mode 'js-mode
    :head-matcher (format vue3--tag-nolang-regex "script")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script lang="es6">
  (define-innermode vue3-script-es6-innermode
    :mode 'js-mode
    :head-matcher (format vue3--tag-lang-regex "script" "es6")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script lang="js">
  (define-innermode vue3-script-js-innermode
    :mode 'js-mode
    :head-matcher (format vue3--tag-lang-regex "script" "js")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
    ;; <script lang="javascript">
  (define-innermode vue3-script-js-innermode
    :mode 'js-mode
    :head-matcher (format vue3--tag-lang-regex "script" "js")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script lang="javascript">
  (define-innermode vue3-script-javascript-innermode
    :mode 'js-mode
    :head-matcher (format vue3--tag-lang-regex "script" "javascript")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script lang="ts">
  (define-innermode vue3-script-ts-innermode
    :mode 'typescript-mode
    :head-matcher (format vue3--tag-lang-regex "script" "ts")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script lang="tsx">
  (define-innermode vue3-script-tsx-innermode
    :mode 'typescript-tsx-mode
    :head-matcher (format vue3--tag-lang-regex "script" "tsx")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <script lang="typescript">
  (define-innermode vue3-script-typescript-innermode
    :mode 'typescript-mode
    :head-matcher (format vue3--tag-lang-regex "script" "typescript")
    :tail-matcher "</script *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <style> without lang specified.
  (define-innermode vue3-style-innermode
    :mode 'css-mode
    :head-matcher (format vue3--tag-nolang-regex "style")
    :tail-matcher "</style *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <style lang="css">
  (define-innermode vue3-style-css-innermode
    :mode 'css-mode
    :head-matcher (format vue3--tag-lang-regex "style" "css")
    :tail-matcher "</style *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <style lang="less">
  (define-innermode vue3-style-less-innermode
    :mode 'less-css-mode
    :head-matcher (format vue3--tag-lang-regex "style" "less")
    :tail-matcher "</style *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <style lang="scss">
  (define-innermode vue3-style-scss-innermode
    :mode 'scss-mode
    :head-matcher (format vue3--tag-lang-regex "style" "scss")
    :tail-matcher "</style *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <template lang="jade">
  (define-innermode vue3-template-jade-innermode
    :mode 'jade-mode
    :head-matcher (format vue3--tag-lang-regex "template" "jade")
    :tail-matcher "</template *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <template lang="pug">
  (define-innermode vue3-template-pug-innermode
    :mode 'pug-mode
    :head-matcher (format vue3--tag-lang-regex "template" "pug")
    :tail-matcher "</template *>"
    :head-mode 'host
    :tail-mode 'host)
  ;; <template lang="sl[i]m">
  (define-innermode vue3-template-slim-innermode
    :mode 'slim-mode
    :head-matcher (format vue3--tag-lang-regex "template" "sli*m")
    :tail-matcher "</template *>"
    :head-mode 'host
    :tail-mode 'host)
;; Define vue3-mode as a composite of all modes above.
  (define-polymode vue3-mode
    :hostmode 'poly-vue3-hostmode
    :innermodes '(vue3-i18n-innermode
                  vue3-i18n-json-innermode
                  vue3-i18n-yaml-innermode
                  vue3-script-innermode
                  vue3-script-js-innermode
                  vue3-script-javascript-innermode
                  vue3-script-ts-innermode
                  vue3-script-tsx-innermode
                  vue3-script-typescript-innermode
                  vue3-style-innermode
                  vue3-style-css-innermode
                  vue3-style-less-innermode
                  vue3-style-scss-innermode
                  vue3-template-jade-innermode
                  vue3-template-pug-innermode
                  vue3-template-slim-innermode))
  ;; Done.
  (setq vue3-initialized t))

;;;###autoload
(when (not vue3-initialized)
  (vue3--setup))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.vue" . vue3-mode))

(provide 'vue3-mode)
;;; vue3-mode.el ends here
