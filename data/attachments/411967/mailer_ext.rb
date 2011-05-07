class ActionMailer::Base

  def perform_delivery_smtp(mail)
    destinations = mail.destinations
    mail.ready_to_send
    sender = mail['return-path'] || mail.from

    smtp = Net::SMTP.new(smtp_settings[:address], smtp_settings[:port])
    if smtp_settings[:ssl]
      smtp.enable_tls()
    else
      smtp.enable_starttls_auto if smtp_settings[:enable_starttls_auto] && smtp.respond_to?(:enable_starttls_auto)
    end
    smtp.start(smtp_settings[:domain], smtp_settings[:user_name], smtp_settings[:password],
               smtp_settings[:authentication]) do |smtp|
      smtp.sendmail(mail.encoded, sender, destinations)
    end
  end

end
