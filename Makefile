.PHONY: publish serve deploy

publish:
	emacs --batch -l publish.el --eval '(org-publish "site" t)'

serve:
	python3 -m http.server 8000

deploy: publish
	git add -A && git commit -m "publish" && git push
