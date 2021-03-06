module ControllerSpecHelper
  def stub_app_setup
    controller.stub!(:ensure_set_up)
    Setting.stub!(:[]).with(:single_organisation_mode).and_return(nil)
    Setting.stub!(:[]).with(:base_domain).and_return('oneclickorgs.com')
    Setting.stub!(:[]).with(:signup_domain).and_return('create.oneclickorgs.com')
  end
  
  def stub_company
    @company = @organisation = mock_model(Company)
    Organisation.stub!(:find_by_host).and_return(@company)
  end
  
  def stub_login
    @user = mock_model(Member)
    controller.stub!(:current_user).and_return(@user)
    controller.stub!(:user_logged_in?).and_return(true)
  end
end
