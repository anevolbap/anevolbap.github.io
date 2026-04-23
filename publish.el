;;; -*- lexical-binding: t; -*-
(require 'ox-publish)

(defvar site-root (file-name-directory (or load-file-name buffer-file-name)))

(setq org-publish-project-alist
  `(("site-pages"
     :base-directory ,(concat site-root "org")
     :publishing-directory ,site-root
     :publishing-function org-html-publish-to-html
     :recursive t
     :with-toc nil
     :section-numbers nil
     :with-author nil
     :with-timestamps nil
     :html-head-include-default-style nil
     :html-head-include-scripts nil
     :html-head "<link rel='stylesheet' href='/style.css'>"
     :html-preamble "<nav><a href='/'>Home</a> · <a href='/resume.html'>Resume</a> · <a href='/posts/'>Posts</a></nav>"
     :html-postamble nil)
    ("site-static"
     :base-directory ,(concat site-root "org/static")
     :publishing-directory ,site-root
     :base-extension "css\\|pdf\\|png\\|jpg"
     :publishing-function org-publish-attachment)
    ("site" :components ("site-pages" "site-static"))))
