.PHONY: publish serve

publish:
	emacs --batch -l publish.el --eval '(org-publish "site" t)'

serve:
	python3 -m http.server 8000 -d _site
