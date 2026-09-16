.PHONY: publish serve deploy

publish:
	emacs --batch -l publish.el --eval '(org-publish "site" t)'

serve:
	python3 -m http.server 8000

# DEPRECATED: CI builds and deploys on push to main. Remove once the
# Pages source is GitHub Actions and the committed HTML is gone.
deploy: publish
	git add -A && git commit -m "publish" && git push
