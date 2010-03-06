class InductionMailer < ActionMailer::Base
  default :from => "info@oneclickor.gs"
  
  def notify_agenda(options={})
    @member = options[:member]
    @organisation_name = options[:organisation_name]
    @founding_meeting_location = options[:founding_meeting_location]
    @founding_meeting_date = options[:founding_meeting_date]
    @founding_meeting_time = options[:founding_meeting_time]
    @founding_member_name = options[:founding_member_name]
    @members = options[:members]
    # TODO Should complain if required options aren't present
    
    mail(:to => @member.email, :subject => "Agenda for '#{@organisation_name}' founding meeting")
  end
end
