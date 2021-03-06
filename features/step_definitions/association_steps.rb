Given /^I have created an association$/ do
  Given "an association has been created"
  @user = @founder
  Given "the subdomain is the organisation's subdomain"
  Given "I have logged in"
end

Given /^an association has been created$/ do
  @organisation = @association = Association.make(:state => 'pending')
  @founder = @organisation.members.make(
    :member_class => @organisation.member_classes.find_by_name("Founder"),
    :inducted_at => nil,
    :state => 'pending'
  )
end

Given /^there are enough members to start the founding vote$/ do
  extra_members_needed = 3 - @organisation.members.count
  if extra_members_needed > 0
    extra_members_needed.times do
      @organisation.members.make(:pending,
        :member_class => @organisation.member_classes.find_by_name("Founding Member")
      )
    end
  end
end

Given /^an association is active$/ do
  @organisation = @association = Association.make(:state => 'active')
  3.times do
    @organisation.members.make(
      :member_class => @organisation.member_classes.find_by_name("Member")
    )
  end
end

Then /^the organisation should be active$/ do
  @organisation.reload.should be_active
end
