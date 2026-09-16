;;; -*- lexical-binding: t; -*-
(require 'ox-publish)

(defvar site-root (file-name-directory (or load-file-name buffer-file-name)))
;; Build output, not tracked. SITE_OUT overrides it.
(defvar site-out (file-name-as-directory (or (getenv "SITE_OUT") (concat site-root "_site"))))

(defun site-preamble (info)
  "No nav on the home page, it lists the sections. A link back home elsewhere."
  (if (file-equal-p (plist-get info :input-file) (concat site-root "org/index.org"))
      ""
    "<nav><a href='/'>← Pablo Vena</a></nav>"))

(setq org-publish-project-alist
  `(("site-pages"
     :base-directory ,(concat site-root "org")
     :publishing-directory ,site-out
     :publishing-function org-html-publish-to-html
     :recursive t
     ;; Posts are disabled until the first one lands.
     :exclude "^posts/"
     :with-toc nil
     :section-numbers nil
     :with-author nil
     :with-timestamps nil
     :html-head-include-default-style nil
     :html-head-include-scripts nil
     :html-head "<link rel='stylesheet' href='/style.css'>"
     ;; :html-preamble "<nav><a href='/'>Home</a> · <a href='/resume.html'>Resume</a> · <a href='/posts/'>Posts</a></nav>"
     ;; :html-preamble "<nav><a href='/'>Home</a> · <a href='/open-source.html'>Open Source</a> · <a href='/projects.html'>Projects</a> · <a href='/research.html'>Research</a> · <a href='/resume.html'>Resume</a></nav>"
     :html-preamble site-preamble
     :html-postamble nil)
    ("site-static"
     :base-directory ,(concat site-root "org/static")
     :publishing-directory ,site-out
     :base-extension "css\\|pdf\\|png\\|jpg"
     :publishing-function org-publish-attachment)
    ("site" :components ("site-pages" "site-static"))))
