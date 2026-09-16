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

;; Resume PDF: keep the LaTeX packages to what texlive-latex-base and
;; lmodern ship, so CI installs little.
(setq org-latex-compiler "pdflatex"
      org-latex-pdf-process
      '("pdflatex -interaction nonstopmode -output-directory %o %f"
        "pdflatex -interaction nonstopmode -output-directory %o %f")
      org-latex-default-packages-alist
      '(("utf8" "inputenc" t) ("T1" "fontenc" t) ("" "lmodern" nil)
        ("margin=2cm" "geometry" nil)
        ("colorlinks=true,urlcolor={[rgb]{0.1,0.25,0.55}}" "hyperref" nil))
      org-latex-packages-alist nil
      ;; Keep the log when the build fails; site-remove-tex cleans up after success.
      org-latex-remove-logfiles nil
      org-latex-title-command "\\begin{center}{\\LARGE\\bfseries %t}\\end{center}")

(defun site-remove-tex (_project)
  "Remove the LaTeX build files that org leaves next to resume.org."
  (dolist (f '("resume.tex" "resume.pdf" "resume.log" "resume.aux" "resume.out"))
    (let ((path (concat site-root "org/" f)))
      (when (file-exists-p path) (delete-file path)))))

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
    ("site-pdf"
     :base-directory ,(concat site-root "org")
     :publishing-directory ,site-out
     :exclude ".*"
     :include ("resume.org")
     :publishing-function org-latex-publish-to-pdf
     :completion-function site-remove-tex
     :latex-header "\\setlength{\\parindent}{0pt}\\setlength{\\parskip}{4pt}\\let\\siteitemize\\itemize\\renewcommand{\\itemize}{\\siteitemize\\setlength{\\itemsep}{1pt}\\setlength{\\parskip}{0pt}}"
     :with-toc nil
     :section-numbers nil
     :with-author nil
     :with-date nil)
    ("site" :components ("site-pages" "site-static" "site-pdf"))))
