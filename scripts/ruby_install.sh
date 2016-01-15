## remove existing installation
export RUBY_VERSION=2.1.4

## install ruby installer, rvm
install_ruby() {
 log_function $FUNCNAME
 gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
 curl -L get.rvm.io | bash -s stable
 /usr/local/rvm/bin/rvm install ruby-${RUBY_VERSION}
 /usr/local/rvm/bin/rvm pkg install zlib
 /usr/local/rvm/bin/rvm reinstall all --force
}

source_ruby() {
 log_function $FUNCNAME
 [[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm
 rvm use ${RUBY_VERSION} --default
}

install_ruby
source_ruby