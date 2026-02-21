// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import HelloController from "controllers/hello_controller"
import UploadFormController from "controllers/upload_form_controller"

application.register("hello", HelloController)
application.register("upload-form", UploadFormController)
