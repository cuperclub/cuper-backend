json.promotions do
    json.array!(
      promotions,
      partial: "api/shared/promotion",
      as: :promotion
    )
end
