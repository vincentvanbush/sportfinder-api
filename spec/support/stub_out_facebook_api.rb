module StubOutFacebookApi
  def stub_out_facebook_api!
    setup_facebook_user!
  end

  def facebook_default_attributes
    { "id" => "1238190321",
      "name" => "Carol",
      "locale" => "en_GB",
      "email" => "buszi@suszi.pl" }
  end

  #overridable
  def facebook_attributes
    facebook_default_attributes
  end


  def setup_facebook_user!
    client = double('koala facebook api', get_object: facebook_attributes)
    Koala::Facebook::API.stub(:new).and_return(client)
  end
end
