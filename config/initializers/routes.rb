require 'fileutils'
::MYSPACE_URL_BASE = '/endpoint/myspace'
::MYSPACE_PUB_BASE = '/endpoint/foo'
::WORK_DIR         = ROOT_DIR + '/work'
::HOSTNAME         =`hostname`.chomp.gsub(/\..*/, "")
