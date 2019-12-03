PKG=polaris
NAME=Polaris
VERSION=$(shell grep ^VERSION setup.py |cut -d= -f2 |sed "s/[\' ]//g")
RELEASE=$(VERSION)-a
ARCH=all

PYTHON_MODULE='polaris-gslb'
PYTHON=python3.7
PATH=$(PWD)/$(INST_ROOT)/bin:$(shell echo $$PATH)
VENV=$(shell pipenv --venv)
PIP=$(PWD)/$(INST_ROOT)/bin/pip3
PIP_OPTS=--user --upgrade --force-reinstall --ignore-installed --compile --extra-index-url=https://pypi.iway.ch --trusted-host pypi.iway.ch

INIT_SERVICE=$(PKG)

include /opt/pkgtool/lib/Makefile.common

DEPENDS=memcached
RECOMMENTS=pdns, pdns-backend-remote

.PHONY: clean distclean install server requirements.txt


$(INST_ROOT):
	mkdir -p $(INST_ROOT)

$(INST_ROOT)/lib:
	mkdir -p $(INST_ROOT)/lib

get-pip.py:
	wget --no-clobber https://bootstrap.pypa.io/get-pip.py

$(PIP): $(INST_ROOT) $(INST_ROOT)/lib get-pip.py
	PATH=$(PATH) PYTHONPATH="" PYTHONUSERBASE=$(PYTHONUSERBASE) $(PYTHON) get-pip.py pip wheel setuptools $(PIP_OPTS)

.venv:
	mkdir .venv
	pipenv install
	pipenv install --dev 

requirements.txt: 
	pipenv lock -r > requirements.txt

server: .venv
	mkdir -r run
	POLARIS_INSTALL_PREFIX=. ./bin/polaris-health-control start-debug

dist: dist/$(PYTHON_MODULE)-$(VERSION).tar.gz

dist/$(PYTHON_MODULE)-$(VERSION).tar.gz: $(PIP) requirements.txt 
	POLARIS_INSTALL_PREFIX=$(INST_ROOT) $(PYTHON) setup.py sdist

install: dist/$(PYTHON_MODULE)-$(VERSION).tar.gz
	[ -e /etc/default/polaris ] && cp /etc/default/polaris /tmp/polaris.default.backup
	set -e; POLARIS_INSTALL_PREFIX=$(INST_ROOT) PATH=$(PATH) PYTHONPATH="" PYTHONUSERBASE=$(PYTHONUSERBASE) $(PIP) install $(PIP_OPTS) \
		dist/$(PYTHON_MODULE)-${VERSION}.tar.gz || (echo "$(PIP) install dist/$(PYTHON_MODULE)-$(VERSION).tar.gz failed"; exit 1)
	rm -f $(INST_ROOT)/etc/*.yaml $(INST_ROOT)/etc/*.conf
        [ -e /tmp/polaris.default.backup ] && cp /tmp/polaris.default.backup /etc/default/polaris

clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -exec rm -rf {} +
	rm -rf *.egg-info .coverage .eggs

distclean: clean
	rm -rf install dist $(PKG)*.deb $(PKG)-$(RELEASE) get-pip.py .venv requirements.txt requirements-test.txt run build
