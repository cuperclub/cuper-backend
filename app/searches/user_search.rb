class UserSearch < Searchlight::Search
  def base_query
    User.all
  end

  def search_q
    query.where("unaccent(users.name) ILIKE :q OR unaccent(users.national_id) ILIKE :q OR unaccent(users.email) ILIKE :q", q: "%#{options[:q]}%")
          .where.not("users.id = :id", id: options[:id])
  end
end
