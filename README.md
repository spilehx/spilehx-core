# spilehx-core










## section on Logging system


  GlobalLoggingSettings.settings.verbose = true;
   GlobalLoggingSettings.settings.toFile = true;

		LOG("message"); - verbose required
		LOG_INFO("info message");- verbose required
		LOG_WARN("warning message");- verbose required
		LOG_ERROR("error message");- verbose required

        LOG_OBJECT(obj)- verbose required


        USER_MESSAGE("user message");
        USER_MESSAGE_INFO("user info message");
        USER_MESSAGE_WARN("user warning message");
        USER_MESSAGE_ERROR("user error message");

Note on how import.hx is added with imports for convenience on build