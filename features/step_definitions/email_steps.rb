require 'uri'

def last_email
  ActionMailer::Base.deliveries.last
end

Given /^I have received an email inviting me to become a founding member$/ do
  Given "I have been invited to become a founding member"
  @email = last_email
end

Given /^I have received an email inviting me to become a member$/ do
  Given "I have been invited to join the organisation"
  @email = last_email
end

When /^I click the link in the email$/ do
  @email ||= last_email
  uri = URI.parse(@email.body.match(/(http:\/\/\S*)/)[1])
  subdomain = uri.host.split('.')[0]
  path = uri.path
  Given %Q{the subdomain is "#{subdomain}"}
  visit(path)
end

When /^I follow the invitation link in the email$/ do
  When "I click the link in the email"
end

Then /^I should receive a welcome email$/ do
  @email = last_email
  @email.to.should == [(@user ||= Member.last).email]
  @email.body.should =~ /created a draft constitution/
end

Then /^a founding member invitation email should be sent to "([^"]*)"$/ do |email_address|
  @email = last_email
  @email.to.should == [email_address]
  @email.body.should =~ /You've been invited by .* to become a founding member/
end

Then /^everyone should receive an email saying that the founding vote has started$/ do
  @organisation.members.each do |member|
    email = ActionMailer::Base.deliveries.select{|mail| mail.to.first == member.email}.first
    email.body.should =~ /has initiated a Founding Vote/
  end
end

Then /^everyone should receive an email saying the founding vote has passed$/ do
  @organisation.members.each do |member|
    email = ActionMailer::Base.deliveries.reverse.select{|mail| mail.to.first == member.email}.first
    email.body.should =~ /The Association has therefore been formed/
  end
end

Then /^everyone should receive an email notifying them of the proposal$/ do
  @proposal ||= Proposal.last
  @organisation.members.each do |member|
    email = ActionMailer::Base.deliveries.reverse.select{|mail| mail.to.first == member.email}.first
    email.body.should =~ Regexp.new(@proposal.title)
  end
end

Then /^I should receive an email notifying me of the new minutes$/ do
  @email = ActionMailer::Base.deliveries.reverse.select{|mail| mail.to.first == @user.email}.first
  @email.should be_present
  
  @company ||= Company.last
  @meeting ||= @company.meetings.last
  
  @email.subject.should include("minutes")
  @email.body.should include(@meeting.minutes)
end

Then /^I should see a link to the minutes in the email$/ do
  @email ||= last_email
  
  @meeting ||= Meeting.last
  
  @email.body.should include("#{@meeting.organisation.domain}/meetings/#{@meeting.to_param}")
end
