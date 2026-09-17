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

;;; Resume: one org file, rendered as a web page and as two cv-silver PDFs.

(load (concat site-root "cv/ox-cv-silver.el") nil t)

(defun site--inline-html (s info)
  "Org string S (a property value) as inline HTML, without the <p> wrapper."
  (if (or (null s) (string-empty-p s)) ""
    (replace-regexp-in-string
     "\\`<p>\n?\\|\n?</p>\\'" ""
     (string-trim (org-export-string-as s 'html t (list :with-toc nil
                                                         :html-link-org-files-as-html
                                                         (plist-get info :html-link-org-files-as-html)))))))

(defun site-html-headline (headline contents info)
  "Render the cv-silver tags on the web page; other headlines as usual."
  (let* ((tags (org-element-property :tags headline))
         (title (org-export-data (org-element-property :title headline) info))
         (h (1+ (org-export-get-relative-level headline info)))
         (contents (or contents "")))
    (cond
     ((or (member "web" tags) (member "descript" tags)) contents)
     ((member "oneline" tags)
      (format "<p><strong>%s:</strong> %s</p>\n" title
              (replace-regexp-in-string "</?p>\\|<div[^>]*>\\|</div>" "" (string-trim contents))))
     ((member "job" tags)
      (format "<h%d>%s — %s</h%d>\n<p><em>%s · %s</em></p>\n%s"
              h title (site--inline-html (org-element-property :INSTITUTION headline) info) h
              (org-element-property :DATE headline) (org-element-property :LOCATION headline)
              contents))
     ((member "education" tags)
      (format "<h%d>%s — %s</h%d>\n<p><em>%s</em></p>\n%s"
              h (site--inline-html (org-element-property :MAJOR headline) info) title h
              (org-element-property :DATE headline) contents))
     (t (org-html-headline headline contents info)))))

(org-export-define-derived-backend 'site-html 'html
  :translate-alist '((headline . site-html-headline)))

(defun site-publish-html (plist filename pub-dir)
  (org-publish-org-to 'site-html filename ".html" plist pub-dir))

(defun site--cv-pdf (filename pub-dir variant exclude-tags out)
  "Export FILENAME with cv-silver for VARIANT and copy the PDF to PUB-DIR/OUT.pdf.
The build runs in cv/, next to cv-silver.sty."
  (let* ((dir (concat site-root "cv/"))
         (tex (concat dir out ".tex"))
         (org-cv-silver-active-variant variant)
         (org-latex-remove-logfiles nil))
    (with-current-buffer (find-file-noselect filename)
      (org-export-to-file 'cv-silver tex nil nil nil nil
        (list :exclude-tags exclude-tags)))
    (copy-file (org-cv-silver--compile tex) (concat pub-dir out ".pdf") t)
    (dolist (ext '(".tex" ".pdf" ".log" ".aux" ".out"))
      (let ((f (concat dir out ext)))
        (when (file-exists-p f) (delete-file f))))))

(defun site-publish-cv-full (_plist filename pub-dir)
  (site--cv-pdf filename pub-dir "full" '("noexport" "web") "resume"))

(defun site-publish-cv-onepage (_plist filename pub-dir)
  (site--cv-pdf filename pub-dir "onepage" '("noexport" "web" "full") "resume-1page"))

;; DEPRECATED: pdflatex resume, replaced by the cv-silver PDFs above.
;; Resume PDF: keep the LaTeX packages to what texlive-latex-base,
;; texlive-latex-recommended and lmodern ship, so CI installs little.
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
     :publishing-function site-publish-html
     :recursive t
     :with-tags nil
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
    ("site-cv"
     :base-directory ,(concat site-root "org")
     :publishing-directory ,site-out
     :exclude ".*"
     :include ("resume.org")
     :publishing-function (site-publish-cv-full site-publish-cv-onepage))
    ;; DEPRECATED: pdflatex resume, no longer in "site".
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
    ;; ("site" :components ("site-pages" "site-static" "site-pdf"))
    ("site" :components ("site-pages" "site-static" "site-cv"))))
