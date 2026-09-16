;;; -*- lexical-binding: t; -*-
(require 'ox-publish)

(defvar site-root (file-name-directory (or load-file-name buffer-file-name)))
;; CI sets SITE_OUT to build into a separate folder.
(defvar site-out (file-name-as-directory (or (getenv "SITE_OUT") site-root)))

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
     :html-preamble "<nav><a href='/'>Home</a> · <a href='/resume.html'>Resume</a></nav>"
     :html-postamble nil)
    ("site-static"
     :base-directory ,(concat site-root "org/static")
     :publishing-directory ,site-out
     :base-extension "css\\|pdf\\|png\\|jpg"
     :publishing-function org-publish-attachment)
    ("site" :components ("site-pages" "site-static"))))
