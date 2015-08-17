App.route('sessions') do |r|
  r.is do
    r.get do
      begin
        SessionValidator.call(r.params)
        user = rom.relation(:users).login_by(r.params['email']).map_with(:users).one!
        json_error(r, 401, "Invalid password for user: #{r.params['email']}") unless user.password == r.params['password']
        { users: { access_token: user.token } }
      rescue ROM::TupleCountMismatchError
        record_not_found(r, [r.params['email'], r.params['password']], [:email, :password])
      rescue ValidationError => e
        invalid_params(r, e.params)
      end
    end
  end
end
