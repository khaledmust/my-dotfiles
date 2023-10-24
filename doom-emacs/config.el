;; -*- lexical-binding: t -*-

(setq user-full-name "Khaled Mustafa"
      user-mail-address "khaled.mustafa.elsayed@outlook.com")

(setq doom-theme 'doom-one)

(setq doom-font (font-spec :family "JetBrains Mono NL" :size 12 :weight 'semibold)
      doom-variable-pitch-font (font-spec :family "Ubuntu Mono" :size 12 :weight 'regular)
      doom-unicode-font (font-spec :family "Arabic Typesetting" :size 30 :weight 'regular))

;; Hides the markers for bold and italic.
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))

;; Changes the face of comments and programming language keywords.
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))

(set-default-coding-systems 'utf-8)

(setq display-line-numbers-type t)

;; Setting my picture for the dashboard.
(setq fancy-splash-image "/home/khaled/Pictures/MyPic.png")

;; Set the sound after the expiration of the timer.
(setq org-clock-sound "/home/khaled/Music/classic-alarm.wav")
;; Key-bindings to set the timer.
(global-set-key (kbd "C-c C-x ;") 'org-timer-set-timer)

(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))

(defun km/my-org-insert-time ()
"Inserts current time."
(interactive)
    (insert (format-time-string "<%a %I:%M %p>")))

(map! :leader
      :prefix "i"
      :desc "Current time" "t" #'km/my-org-insert-time)

(defun km/my-org-insert-date ()
"Insert current date"
(interactive)
    (insert (format-time-string "<%F %a %I:%M>")))

(map! :leader
      :prefix "i"
      :desc "Current date" "d" #'km/my-org-insert-date)

(defun efs/org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "d:/my-code-database/my-emacs/my-doom-emacs-config.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package! org-download
  :init
  (setq-default org-download-image-dir "/home/khaled/House-of-Wisdom/Roam-Notes/Roam/assets/images")) ; Specify the location where the images is saved.

(use-package! org-roam
    :ensure t
    :init
    (map! :leader
      :prefix "n"
      :desc "org-roam" "l" #'org-roam-buffer-toggle
      :desc "org-roam-node-find" "f" #'org-roam-node-find
      :desc "org-roam-node-insert-immediate" "i" #'org-roam-node-insert-immediate
      :desc "org-roam-capture-inbox" "b" #'my/org-roam-capture-inbox
      :desc "my/org-roam-find-project" "p" #'my/org-roam-find-project
      :desc "my/org-roam-capture-task" "t" #'my/org-roam-capture-task
      :desc "org-roam-tag-add" "T" #'org-roam-tag-add
      (:prefix-map ("d")
      :desc "org-roam-dailies-capture-today" "n" #'org-roam-dailies-capture-today
      :desc "org-roam-dailies-goto-today" "d" #'org-roam-dailies-goto-today
      :desc "org-roam-dailies-capture-yesterday" "Y" #'org-roam-dailies-capture-yesterday
      :desc "org-roam-dailies-capture-tomorrow" "T" #'org-roam-dailies-capture-tomorrow))
    :custom
    (org-roam-directory "/home/khaled/House-of-Wisdom/Roam-Notes")
    (org-roam-completion-everywhere t)
    (org-roam-capture-templates
     ;; Roam Note Templates.
     '(("p" "permanent-note" plain "%?"
        :if-new (file+head "slipbox/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
        :unnarrowed t)
       ("l" "literature-note" plain "%?"
        :if-new
        (file+head "literature-notes/${title}.org" "#+title: ${title}\n#+filetags: :literatureNotes:\n")
        :immediate-finish t
        :unnarrowed t)
       ("P" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
          :if-new (file+head "slipbox/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: Project")
          :unnarrowed t)
       ("a" "article" plain "%?"
        :if-new
        (file+head "articles/${title}.org" "#+title: ${title}\n#+filetags: :articles:\n")
        :immediate-finish t
        :unnarrowed t)
       ("t" "technical-note" plain "%?"
        :if-new
        (file+head "technical-notes/${title}.org" "#+title: ${title}\n#+filetags: :technicalNotes:\n")
        :immediate-finish t
        :unnarrowed t)))
    (org-roam-dailies-capture-templates
     '(
       ("d" "default" entry
        "* %<%I:%M %p>: %? :FleetingThoughts:"
        :target (file+datetree "/home/khaled/House-of-Wisdom/Roam-Notes/daily/journal.org" week))
       ;; ("d" "default" entry "* %<%I:%M %p>: %?"
       ;;  :if-new (file+head "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n"))
       ("j" "Journal Entry" entry
        (file "/home/khaled/House-of-Wisdom/Roam-Notes/templates/journal.org")
        :target (file+datetree "/home/khaled/House-of-Wisdom/Roam-Notes/daily/journal.org" week)
        (:unnarrowed t))))
    :config
    (require 'org-roam-dailies)
    (org-roam-db-autosync-mode)

    ;; Inspired from https://jethrokuan.github.io/org-roam-
    ;; Create the property type on my nodes.
    (cl-defmethod org-roam-node-type ((node org-roam-node))
      "Return the TYPE of NODE."
      (condition-case nil
          (file-name-nondirectory
           (directory-file-name
            (file-name-directory
             (file-relative-name (org-roam-node-file node) org-roam-directory))))
        (error "")))

    ;; Modify the display template to show the node type.
    (setq org-roam-node-display-template
          (concat "${type:15} ${title:*} " (propertize "${tags:10}" 'face 'org-tag)))

    ;; Here starts System Crafter's Org-roam Hacks configuraion.
    (defun org-roam-node-insert-immediate (arg &rest args)
      (interactive "P")
      (let ((args (push arg args))
            (org-roam-capture-templates (list (append (car org-roam-capture-templates)
                                                      '(:immediate-finish t)))))
        (apply #'org-roam-node-insert args)))

    (defun my/org-roam-filter-by-tag (tag-name)
      (lambda (node)
        (member tag-name (org-roam-node-tags node))))

    (defun my/org-roam-list-notes-by-tag (tag-name)
      (mapcar #'org-roam-node-file
              (seq-filter
               (my/org-roam-filter-by-tag tag-name)
               (org-roam-node-list))))

    (defun my/org-roam-refresh-agenda-list ()
      (interactive)
      (setq org-agenda-files (my/org-roam-list-notes-by-tag "Project")))

    ;; Build the agenda list the first time for the session
    (my/org-roam-refresh-agenda-list)

    (defun my/org-roam-project-finalize-hook ()
      "Adds the captured project file to `org-agenda-files' if the
capture was not aborted."
      ;; Remove the hook since it was added temporarily
      (remove-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

      ;; Add project file to the agenda list if the capture was confirmed
      (unless org-note-abort
        (with-current-buffer (org-capture-get :buffer)
          (add-to-list 'org-agenda-files (buffer-file-name)))))

    (defun my/org-roam-find-project ()
      (interactive)
      ;; Add the project file to the agenda after capture is finished
      (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

      ;; Select a project file to open, creating it if necessary
      (org-roam-node-find
       nil
       nil
       (my/org-roam-filter-by-tag "Project")
       :templates
       '(("p" "project" plain "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Dates\n\n"
          :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: ${title}\n#+filetags: Project")
          :unnarrowed t))))

    (defun my/org-roam-capture-inbox ()
      (interactive)
      (org-roam-capture- :node (org-roam-node-create)
                         :templates '(("i" "inbox" plain "* %?"
                                       :if-new (file+head "Inbox.org" "#+title: Inbox\n")))))

    (defun my/org-roam-capture-task ()
      (interactive)
      ;; Add the project file to the agenda after capture is finished
      (add-hook 'org-capture-after-finalize-hook #'my/org-roam-project-finalize-hook)

      ;; Capture the new task, creating the project file if necessary
      (org-roam-capture- :node (org-roam-node-read
                                nil
                                (my/org-roam-filter-by-tag "Project"))
                         :templates '(("p" "project" plain "** TODO %?"
                                       :if-new (file+head+olp "%<%Y%m%d%H%M%S>-${slug}.org"
                                                              "#+title: ${title}\n#+category: ${title}\n#+filetags: Project"
                                                              ("Tasks"))))))

    (defun my/org-roam-copy-todo-to-today ()
      (interactive)
      (let ((org-refile-keep t) ;; Set this to nil to delete the original!
            (org-roam-dailies-capture-templates
             '(("t" "tasks" entry "%?"
                :if-new (file+head+olp "%<%Y-%m-%d>.org" "#+title: %<%Y-%m-%d>\n" ("Tasks")))))
            (org-after-refile-insert-hook #'save-buffer)
            today-file
            pos)
        (save-window-excursion
          (org-roam-dailies--capture (current-time) t)
          (setq today-file (buffer-file-name))
          (setq pos (point)))

        ;; Only refile if the target file is different than the current file
        (unless (equal (file-truename today-file)
                       (file-truename (buffer-file-name)))
          (org-refile nil nil (list "Tasks" today-file nil pos)))))

    (add-to-list 'org-after-todo-state-change-hook
                 (lambda ()
                   (when (equal org-state "DONE")
                     (my/org-roam-copy-todo-to-today))))

)

;; According to the documentation Doom Emacs starts the server automatically.
;; Look at this link: https://discourse.doomemacs.org/t/common-config-anti-patterns/119
;;(server-start)
(add-to-list 'load-path "/home/khaled/.config/emacs/.local/straight/repos/org-protocol/org-protocol.el")
(require 'org-roam-protocol)

;; A function that directly calls my slipbox capture template.
(defun km/org-capture-slipbox ()
  (interactive)
  (org-capture nil "s"))

;;(load-file "C:/Users/khale/AppData/Roaming/.emacs.d/lisp/org-protocol-check-filename/+org-protocol-check-filename-for-protocol.el")
;;(advice-add 'org-protocol-check-filename-for-protocol :override '+org-protocol-check-filename-for-protocol)
(defun km/set-org-protocol-template ()
  (interactive)
  ;; This templates were taken from https://stackoverflow.com/a/47662534.
  (setq org-capture-templates `(
                                ("p" "Protocol" entry (file+headline "/home/khaled/House-of-Wisdom/Roam-Notes/myBookmarks.org" "Inbox")
                                 "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
                                ("L" "Protocol Link" entry (file+headline "/home/khaled/House-of-Wisdom/Roam-Notes/myBookmarks.org" "Bookmarks")
                                 "* %? [[%:link][%:description]] \nCaptured On: %U"))))

;; (use-package! klp
;;   :init (setq klp/static-notes-dir "/home/khaled/My Notes/Roam/troubleshooting"))
  
;; (defun km/open-tools ()
;; "Macro to use `klp/open-note' to open all `notes_tool_title.org' files."
;;   (interactive)
;;   (klp/open-note "tool" '("TITLE")))

(setq my-org-agenda-files '("/home/khaled/House-of-Wisdom/Roam-Notes/daily/journal.org"
                            "d:/House-of-Wisdom/my-calendar.org"
                            "c:/Users/khale/Dropbox/Documents/MySchedule/todo.org"))
(setq org-agenda-files (append org-agenda-files my-org-agenda-files))

(add-hook 'org-timer-done-hook 'org-clock-out)

(use-package! deft
  :custom
  (deft-recursive t)
  (deft-default-extension "org")
  (deft-directory "/home/khaled/House-of-Wisdom/Roam-Notes")
  )

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp .t)
   ))

;;(setq deft-directory "~/My Notes")

;; (load! "/home/khaled/.config/emacs/.local/straight/repos/org-roam-ql/org-roam-ql.el")
;; (load! "/home/khaled/.config/emacs/.local/straight/repos/org-roam-ql/org-roam-ql-ql.el")

(use-package! org-roam-ql
  :after(org-roam))

(use-package! org-roam-ql-ql
  :after (org-ql org-roam-ql)
  :config(org-roam-ql-ql-init))

(require 'org-similarity)
(setq org-similarity-directory "/home/khaled/House-of-Wisdom/Roam-Notes")

;; Customize the font for term-mode
;; (defun set-font-for-term-mode ()
;;   (interactive)
;;   (face-remap-add-relative 'default :family "Terminess Nerd Font" :height 100))

;; (add-hook 'term-mode-hook 'set-font-for-term-mode)

(defun set-font-for-term-mode ()
  (interactive)
  (when (eq major-mode 'term-mode)
    (face-remap-add-relative 'default :family "Terminess Nerd Font" :height 100)))

(add-hook 'term-exec-hook #'set-font-for-term-mode)


;; This configuration was taken from the following blog post:
;; https://andreyor.st/posts/2022-10-16-my-blogging-setup-with-emacs-and-org-mode/
(use-package! blog
  :commands (blog-publish-file
             blog-generate-file-name
             blog-read-list-items)
  :preface
  (defvar blog-capture-template
    "#+hugo_base_dir: /home/khaled/projects/personal-blog
#+hugo_section: posts
#+hugo_auto_set_lastmod: t
#+options: tex:dvisvgm
#+macro: kbd @@html:<kbd>$1</kbd>@@

#+title: %(format \"%s\" blog--current-post-name)
#+date: %(format-time-string \"%Y-%m-%d %h %H:%M\")
#+hugo_tags: %(blog-read-list-items \"Select tags: \" 'blog-tags)
#+hugo_categories: %(blog-read-list-items \"Select categories: \" 'blog-categories)
#+hugo_custom_front_matter: :license %(format \"%S\" blog-license)

%?"
    "Org-capture template for blog posts.")
  (defcustom blog-tags nil
    "A list of tags used for posts."
    :type '(repeat string)
    :group 'blog)
  (defcustom blog-categories nil
    "A list of tags used for posts."
    :type '(repeat string)
    :group 'blog)
  (defcustom blog-directory "~/projects/personal-blog"
    "Location of the blog directory for org-capture."
    :type 'string
    :group 'blog)
  (defcustom blog-license ""
    "Blog license string."
    :type 'string
    :group 'blog)
  (defvar blog--current-post-name nil
    "Current post name for org-capture template.")
  (defun blog-read-list-items (prompt var)
    "Completing read items with the PROMPT from the VAR.

VAR must be a quoted custom variable, which will be saved if new
items were read by the `completing-read' function."
    (let ((items (eval var)) item result)
      (while (not (string-empty-p item))
        (setq item (string-trim (or (completing-read prompt items) "")))
        (unless (string-empty-p item)
          (push item result)
          (setq items (remove item items))
          (unless (member item (eval var))
            (customize-save-variable var (sort (cons item (eval var)) #'string<)))))
      (string-join result " ")))
  (defun blog-title-to-fname (title)
    (thread-last
      title
      (replace-regexp-in-string "[[:space:]]" "-")
      (replace-regexp-in-string "-+" "-")
      (replace-regexp-in-string "[^[:alnum:]-]+" "")
      downcase))
  (defun blog-generate-file-name (&rest _)
    (let ((title (read-string "Title: ")))
      (setq blog--current-post-name title)
      (find-file
       (file-name-concat
        (expand-file-name blog-directory)
        "posts"
        (format "%s-%s.org"
                (format-time-string "%Y-%m-%d")
                (blog-title-to-fname title))))))
  (defun blog-publish-file ()
    "Update '#+date:' tag, and rename the currently visited file.
File name is updated to include the same date and current title."
    (interactive)
    (save-match-data
      (let ((today (format-time-string "%Y-%m-%d"))
            (now (format-time-string "%h %H:%M")))
        (save-excursion
          (goto-char (point-min))
          (re-search-forward "^#\\+date:.*$")
          (replace-match (format "#+date: %s %s" today now)))
        (let* ((file-name (save-excursion
                            (goto-char (point-min))
                            (re-search-forward "^#\\+title:[[:space:]]*\\(.*\\)$")
                            (blog-title-to-fname (match-string 1)))))
          (condition-case nil
              (rename-visited-file
               (format "%s-%s.org" today
                       (if (string-match
                            "^[[:digit:]]\\{4\\}-[[:digit:]]\\{2\\}-[[:digit:]]\\{2\\}-\\(.*\\)$"
                            file-name)
                           (match-string 1 file-name)
                         file-name)))
            (file-already-exists nil))
          (save-buffer)))))
  (provide 'blog))

(use-package! org-capture
  :defer t
  :custom
  (org-directory blog-directory)
  (org-capture-templates `(("p" "Post" plain
                            (function blog-generate-file-name)
                            ,blog-capture-template
                            :jump-to-captured t
                            :immediate-finish t))))

;; Searching my notes directory using ripgrep
;; This code snippet was taken from
;; https://www.reddit.com/r/emacs/comments/15lrso7/comment/jvd5jkg/?utm_source=share&utm_medium=web2x&context=3
(defun km-org/search ()
  (interactive)
  (let ((default-directory "/home/khaled/House-of-Wisdom/Roam-Notes/Roam/slipbox"))
    (consult-ripgrep)))

(use-package org-roam-review
  :commands (org-roam-review
             org-roam-review-list-by-maturity
             org-roam-review-list-recently-added)

  ;; keybindings for applying Evergreen note properties.
  :general
  (:keymaps 'org-mode-map
  "C-c r r" '(org-roam-review-accept :wk "accept")
  "C-c r u" '(org-roam-review-bury :wk "bury")
  "C-c r x" '(org-roam-review-set-excluded :wk "set excluded")
  "C-c r b" '(org-roam-review-set-budding :wk "set budding")
  "C-c r s" '(org-roam-review-set-seedling :wk "set seedling")
  "C-c r e" '(org-roam-review-set-evergreen :wk "set evergreen"))
  )

;; Langauge tool implementation
(setq langtool-language-tool-jar "/home/khaled/LanguageTool-6.2/languagetool-commandline.jar")
(require 'langtool)

(require 'org-protocol)
(setq org-capture-templates
      `(("p" "Protocol" entry (file+headline ,(expand-file-name "~/House-of-Wisdom/Roam-Notes/myBookmarks.org") "Inbox")
         "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?")
        ("L" "Protocol Link" entry (file+headline ,(expand-file-name "~/House-of-Wisdom/Roam-Notes/myBookmarks.org") "Bookmarks")
        "* [[%:link][%:description]] %^g \nCaptured On: %U")
        ("s" "Slipbox" entry (file+headline ,(expand-file-name "~/House-of-Wisdom/Roam-Notes/slipbox.org") "Inbox")
        "* %?")))

(after! dap-mode
  (require 'dap-cpptools))
(with-eval-after-load 'dap-mode
  (setq dap-default-terminal-kind "integrated") ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
  (dap-auto-configure-mode +1))


(with-eval-after-load 'ox-latex
(add-to-list 'org-latex-classes
             '("org-plain-latex"
               "\\documentclass{article}
           [NO-DEFAULT-PACKAGES]
           [PACKAGES]
           [EXTRA]"
               ("\\section{%s}" . "\\section*{%s}")
               ("\\subsection{%s}" . "\\subsection*{%s}")
               ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
               ("\\paragraph{%s}" . "\\paragraph*{%s}")
               ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))


;; Godot configuration
(setq gdscript-godot-executable "/snap/bin/godot-4")

;;; Supressing the "unknown notification" by LSP
(defun lsp--gdscript-ignore-errors (original-function &rest args)
  "Ignore the error message resulting from Godot not replying to the `JSONRPC' request."
  (if (string-equal major-mode "gdscript-mode")
      (let ((json-data (nth 0 args)))
        (if (and (string= (gethash "jsonrpc" json-data "") "2.0")
                 (not (gethash "id" json-data nil))
                 (not (gethash "method" json-data nil)))
            nil ; (message "Method not found")
          (apply original-function args)))
    (apply original-function args)))
;; Runs the function `lsp--gdscript-ignore-errors` around `lsp--get-message-type` to suppress unknown notification errors.
(advice-add #'lsp--get-message-type :around #'lsp--gdscript-ignore-errors)
