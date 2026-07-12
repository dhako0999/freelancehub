class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch(
    "MAILER_FROM_ADDRESS",
    "notifications@freelancehub.test"
  )

  layout "mailer"
end