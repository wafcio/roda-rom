App.route('products') do |r|
  r.is do
    r.get do
      begin
        attrs = PaginationParams.new(r.params)
        PaginationValidator.call(attrs)
        products = rom.relation(:products).ordered.
          page(attrs.page).per_page(attrs.per_page).to_a
        { products: products }
      rescue ValidationError => e
        invalid_params(r, e.params)
      end
    end

    r.post do
      begin
        result = rom.command(:products).try do
          rom.command(:products).create.call(r.params)
        end
        r.response.status = 201
        { products: result.value }
      rescue ValidationError => e
        invalid_params(r, e.params)
      end
    end
  end

  r.is :id do |id|
    r.get do
      begin
        product = rom.relation(:products).by_id(id).one!
        { products: product }
      rescue ROM::TupleCountMismatchError
        record_not_found(r, id)
      end
    end

    r.patch do
      begin
        product = rom.relation(:products).by_id(id).one!
        attrs = product.merge(r.params.symbolize_keys)
        result = rom.command(:products).try do
          rom.command(:products).update.by_id(id).set(attrs)
        end
        { products: result.value }
      rescue ROM::TupleCountMismatchError
        record_not_found(r, id)
      end
    end

    r.delete do
      result = rom.command(:products).try do
        rom.command(:products).delete.by_id(id).call
      end
      result.value ? delete_response(r) : record_not_found(r, id)
    end
  end
end
