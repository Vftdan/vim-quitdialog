if !quitdialog#get_plugin_setting('no_autocommand', v:false, v:false)
	aug quitdialog
		au!
		au ExitPre * call quitdialog#quit_handler()
	aug END
endif
