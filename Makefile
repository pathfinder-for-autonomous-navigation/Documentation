SPHINXOPTS    ?= -n -W         # Be nitpicky, treat all warnings as errors
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

PORT = 8080 				   #  Port at which live HTML starts its server

livehtml: Makefile
	@sphinx-autobuild $(SOURCEDIR) $(BUILDDIR)/html -p $(PORT) $(SPHINXOPTS) $(O)

%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
