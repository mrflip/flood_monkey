require 'fileutils'
::MYSPACE_URL_BASE = '/endpoint/myspace'
::WORK_DIR         = ROOT_DIR + '/work'
::HOSTNAME         =`hostname`.chomp.gsub(/\..*/, "")
