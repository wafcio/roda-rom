App.route('users') do |r|
  r.is do
    r.get do
      users = rom.relation(:users).ordered.to_a
      { users: users }
    end

    r.post do
      begin
        SessionValidator.call(r.params)
        result = rom.command(:users).try do
          rom.command(:users).create.call(r.params)
        end
        raise ROM::Error.new(result.error) if result.error
        r.response.status =  201
        { users: result.value }
      rescue ValidationError => e
        invalid_params(r, e.params)
      rescue ROM::Error => e
        json_error(r, 422, e.message)
      end
    end
  end

  r.is :id do |id|
    r.get do
      begin
        user = rom.relation(:users).by_id(id).one!
        { users: user }
      rescue ROM::TupleCountMismatchError
        record_not_found(r, id)
      end
    end

    r.patch do
      begin
        user = rom.relation(:users).by_id(id).one!
        attrs = user.merge(r.params.symbolize_keys)
        SessionValidator.call(attrs) if attrs[:password]
        result = rom.command(:users).try do
          rom.command(:users).update.by_id(id).set(attrs)
        end
        { users: result.value }
      rescue ValidationError => e
        invalid_params(r, e.params)
      rescue Sequel::DatabaseError => e
        json_error(r, 422, e.message)
      rescue ROM::TupleCountMismatchError
        record_not_found(r, id)
      end
    end

    r.delete do
      result = rom.command(:users).try do
        rom.command(:users).delete.by_id(id).call
      end
      result.value ? delete_response(r) : record_not_found(r, id)
    end
  end
end
