json.promotions do
    json.array!(
      promotions,
      partial: "api/shared/public_promotion",
      as: :promotion
    )
end
